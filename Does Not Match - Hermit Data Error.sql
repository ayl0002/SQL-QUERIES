SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF OBJECT_ID ('tempdb..#BASE0') IS NOT NULL
	BEGIN
	DROP TABLE #BASE0
	END

SELECT A.LOAN_NBR,A.MCA_PERCENT,
CASE 
	WHEN MCA_PERCENT >= 100 THEN '>= 100'
	WHEN MCA_PERCENT >= 98 THEN '>= 98'
	WHEN MCA_PERCENT >= 97.5 THEN '>= 97.5'
	WHEN MCA_PERCENT >= 96.5 THEN '>= 96.5'
	WHEN MCA_PERCENT >= 95.0 THEN '>= 95.0'
	ELSE '< 95.0'
END AS 'MCA_FLAG'
,A.[LOAN_STATUS]
INTO #BASE0
FROM tbl1 A
LEFT JOIN (SELECT LOAN_NBR,TAG_2_VAL,[INCRBL_FLG_DESC],[GRP_DESC] FROM tbl2 WHERE CURR_IND = 'Y') B	
	ON CAST(A.LOAN_NBR AS VARCHAR) = CAST(B.LOAN_NBR AS VARCHAR)
WHERE A.[LOAN_STATUS] = 'Active' AND TAG_2_VAL IS NULL AND [INCRBL_FLG_DESC] = '0' AND ISNULL([GRP_DESC],'No Group') <> 'Grp 5 BofA GNMAs'

--HUD STATUS--
IF OBJECT_ID ('tempdb..#BASE') IS NOT NULL
	BEGIN
	DROP TABLE #BASE
	END

SELECT A.*,B.HUD_STS_DESC
INTO #BASE
FROM #BASE0 A
LEFT JOIN (SELECT LOAN_NBR,HUD_STS_DESC FROM tbl3 WHERE CURR_IND = 'Y') B
ON A.LOAN_NBR = B.LOAN_NBR

WHERE HUD_STS_DESC NOT IN ('Pkg Submitted to HUD','Rebuttal to HUD','Resubmitted to HUD','HUD Approved')

--EXCP META--
IF OBJECT_ID ('tempdb..#EXCP0') IS NOT NULL
	BEGIN
	DROP TABLE #EXCP0
	END

SELECT A.* INTO #EXCP0 
FROM tbl3 A 
INNER JOIN #BASE B 
ON A.LOAN_NBR = B.LOAN_NBR
WHERE DOC_DESC = 'Not Doc Issue' AND (ISSU_DESC = 'Does Not Match System' OR ISSU_DESC = 'HERMIT DATA ERROR')

--EXCP SCRUB--
IF OBJECT_ID ('tempdb..#BASE1') IS NOT NULL
	BEGIN
	DROP TABLE #BASE1
	END

SELECT A.*,B.EXCP_ID,B.DOC_DESC,B.ISSU_DESC,B.EXCP_STS_DESC,B.[EXCP_DESC]--,E.[EXCP_MM_DESC]
,B.[EXCP_STS_UPDT_BY_DESC],B.[EXCP_STS_DTTM]
,CASE WHEN FIRST_REOPEN IS NOT NULL THEN FIRST_REOPEN 
	  ELSE B.EXCP_RQST_DTTM
END AS 'TRUE_OPEN'
INTO #BASE1
FROM #BASE A
INNER JOIN #EXCP0 B
	ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT EXCP_ID,MIN(EFF_DTTM) AS 'FIRST_CLOSE' FROM #EXCP0 WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML','Canceled') GROUP BY EXCP_ID) C
	ON B.EXCP_ID = C.EXCP_ID
LEFT JOIN (SELECT EXCP1.EXCP_ID,MIN(EXCP1.EFF_DTTM) AS 'FIRST_REOPEN' FROM #EXCP0 EXCP1	
	LEFT JOIN (SELECT EXCP_ID,MIN(EFF_DTTM) AS 'FIRST_CLOSE' FROM #EXCP0 WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML','Canceled') GROUP BY EXCP_ID) EXCP2
		ON EXCP1.EXCP_ID = EXCP2.EXCP_ID
		WHERE EXCP1.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML','Canceled') AND EXCP1.EFF_DTTM > FIRST_CLOSE GROUP BY EXCP1.EXCP_ID) D
	ON B.EXCP_ID = D.EXCP_ID


WHERE B.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML','Canceled') AND B.CURR_IND = 'Y'

IF OBJECT_ID ('tempdb..#FINAL') IS NOT NULL
	BEGIN
	DROP TABLE #FINAL
	END

--PREP--
SELECT DISTINCT A.LOAN_NBR,A.MCA_PERCENT,A.MCA_FLAG,B.EXCP_ID,B.ISSU_DESC,B.[EXCP_DESC],B.[EXCP_STS_UPDT_BY_DESC],D.EXCP_MM_DESC
,CASE WHEN SECOND_REOPEN IS NOT NULL THEN SECOND_REOPEN
ELSE TRUE_OPEN
END AS 'TRUE_OPEN'
,CASE WHEN SECOND_REOPEN IS NOT NULL THEN ABS(DATEDIFF(DAY,SECOND_REOPEN,GETDATE()))
ELSE ABS(DATEDIFF(DAY,TRUE_OPEN,GETDATE()))
END AS 'EXCP_AGING'
,ABS(DATEDIFF(DAY,GETDATE(),ISNULL(EXCP_STS_DTTM,GETDATE()))) AS 'LAST_UPDATE'
INTO #FINAL
FROM #BASE A
INNER JOIN #BASE1 B
ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT EXCP1.EXCP_ID,MIN(EFF_DTTM) AS 'SECOND_REOPEN' FROM #EXCP0 EXCP1
	LEFT JOIN (SELECT EXCP1.EXCP_ID,MIN(EFF_DTTM) AS 'SECOND_CLOSE' FROM #EXCP0 EXCP1 LEFT JOIN #BASE1 EXCP2 ON EXCP1.EXCP_ID = EXCP2.EXCP_ID WHERE EXCP1.EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML','Canceled') AND EXCP1.EFF_DTTM > TRUE_OPEN GROUP BY EXCP1.EXCP_ID) EXCP2
			ON EXCP1.EXCP_ID = EXCP2.EXCP_ID WHERE EXCP1.EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML','Canceled')  AND EXCP1.EFF_DTTM > SECOND_CLOSE GROUP BY EXCP1.EXCP_ID) C
ON B.EXCP_ID = C.EXCP_ID   
LEFT JOIN (SELECT EXCP1.EXCP_ID,EXCP_MM_DESC FROM tbl3 EXCP1
	INNER JOIN (SELECT EXCP_ID,MAX(EFF_DTTM) AS 'MAX_TIME' FROM tbl4 GROUP BY EXCP_ID) EXCP2
	ON EXCP1.EXCP_ID = EXCP2.EXCP_ID WHERE EXCP1.EFF_DTTM = MAX_TIME) D
ON B.EXCP_ID = D.EXCP_ID      

ORDER BY ISSU_DESC,[EXCP_AGING] DESC

--FINAL--
SELECT A.* 
,CASE WHEN EXCP_AGING > 100 THEN '> 100 Days'
	WHEN EXCP_AGING > 50 THEN '> 50 Days'
	WHEN EXCP_AGING > 30 THEN '> 30 Days'
	WHEN EXCP_AGING > 20 THEN '> 20 Days'
	WHEN EXCP_AGING > 10 THEN '> 10 Days'
	WHEN EXCP_AGING > 7 THEN '> 7 Days'
	WHEN EXCP_AGING > 3 THEN '> 3 Days'
	ELSE '3 Days or Fewer'
END AS 'EXCP_AGING_FLAG'
,CASE WHEN LAST_UPDATE > 100 THEN '> 100 Days'
	WHEN LAST_UPDATE > 50 THEN '> 50 Days'
	WHEN LAST_UPDATE > 30 THEN '> 30 Days'
	WHEN LAST_UPDATE > 20 THEN '> 20 Days'
	WHEN LAST_UPDATE > 10 THEN '> 10 Days'
	WHEN LAST_UPDATE > 7 THEN '> 7 Days'
	WHEN LAST_UPDATE > 3 THEN '> 3 Days'
	ELSE '3 Days or Fewer'
END AS 'LAST_UPDATED'
FROM #FINAL A
