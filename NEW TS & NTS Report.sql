DECLARE @CURR_MONTH_END AS DATE = EOMONTH(GETDATE()) --EOMONTH('2020-05-01')
DECLARE @CURR_MONTH_INT AS INT = REPLACE(@CURR_MONTH_END,'-','')

DECLARE @CURR_MONTH_BEG AS DATE = DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-1))

/*
--EXCP_META--
IF OBJECT_ID ('tempdb..#EXCP') IS NOT NULL
	BEGIN
	DROP TABLE #EXCP
	END
	
SELECT B.* 
INTO #EXCP
FROM (SELECT * FROM REVERSE_dw.[dbo].[HUD_ASGN_EXCP_EDW] where doc_desc in ('Tax Bill', 'HOA', 'Hazard Insurance', 'Current OCC Cert', 'Flood Insurance', 'Condo Insurance', 'Death Cert', 'Death Cert HACG', 'Flood Cert', 'Hardest Hit Funds', 'Life Estate', 'Loss Draft', 'Manufactured Home', 'Master Policy', 'Name Affidavit', 'Not Doc Issue', 'Orig Appraisal', 'POA', 'Proof of Repair', 'Signed Pay Plan', 'Trust', 'Trust - HACG', 'Walls In Policy', 'Not Enough Repay') 
and excp_sts_desc in ('Resolved', 'Resolved by ML', 'Closed with Vendor') and EFF_DTTM BETWEEN @CURR_MONTH_BEG AND @CURR_MONTH_END) A
INNER JOIN REVERSE_dw.[dbo].[HUD_ASGN_EXCP_EDW] B
ON A.EXCP_ID = B.EXCP_ID


--HUD_ASGN META DATA--
IF OBJECT_ID ('tempdb..#HUD_ASGN_0') IS NOT NULL
	BEGIN
	DROP TABLE #HUD_ASGN_0
	END

SELECT B.*
INTO #HUD_ASGN_0
FROM (SELECT DISTINCT LOAN_NBR FROM #EXCP0) A
LEFT JOIN HUD_ASGN_LOANS B
ON A.LOAN_NBR = B.LOAN_NBR


--HUD_ASGN SCRUB--
IF OBJECT_ID ('tempdb..#MAX_DEFAULT') IS NOT NULL
	BEGIN
	DROP TABLE #MAX_DEFAULT
	END

SELECT A.LOAN_NBR,(SELECT MAX(V) FROM (VALUES (LAST_TAG_2),(LAST_INCUR),(LAST_DEFAULT)) AS VALUE (V)) AS 'MAX_DEFAULT'
INTO #MAX_DEFAULT
FROM (SELECT DISTINCT LOAN_NBR FROM #HUD_ASGN_0) A
LEFT JOIN (SELECT LOAN_NBR,MAX(EFF_DTTM) AS 'LAST_TAG_2' FROM #HUD_ASGN_0 WHERE TAG_2_VAL IS NOT NULL GROUP BY LOAN_NBR) B
	ON A.LOAN_NBR = B.LOAN_NBR 
LEFT JOIN (SELECT LOAN_NBR,MAX(EFF_DTTM) AS 'LAST_INCUR' FROM #HUD_ASGN_0 WHERE [INCRBL_FLG_DESC] <> '0' GROUP BY LOAN_NBR) C
	ON A.LOAN_NBR = C.LOAN_NBR 
LEFT JOIN (SELECT LOAN_NBR,MAX(EFF_DTTM) AS 'LAST_DEFAULT' FROM #HUD_ASGN_0 WHERE LOAN_STS_DESC NOT IN ('ACTIVE','Liquidated/Assigned to HU') GROUP BY LOAN_NBR) D
	ON A.LOAN_NBR = D.LOAN_NBR 

--EXCP_SCRUB--
IF OBJECT_ID ('tempdb..#EXCP1') IS NOT NULL
	BEGIN
	DROP TABLE #EXCP1
	END

SELECT DISTINCT A.LOAN_NBR,A.EXCP_ID,A.DOC_DESC,A.EXCP_RQST_DTTM,A.EXCP_STS_DESC,A.EXCP_STS_DTTM,A.EXCP_STS_UPDT_BY_DESC,A.ISSU_DESC,A.EFF_DTTM,TRUE_CLOSE AS 'CLOSE2',TRUE_OPEN AS 'OPEN2'
INTO #EXCP1
FROM #EXCP A
LEFT JOIN (SELECT EXCP_ID,MAX(EFF_DTTM) AS 'CURR_EFF_DTTM' FROM #EXCP GROUP BY EXCP_ID) B
	ON A.EXCP_ID = B.EXCP_ID
LEFT JOIN (SELECT TC.EXCP_ID,MIN(EFF_DTTM) AS 'TRUE_CLOSE' FROM #EXCP TC
			LEFT JOIN (SELECT EXCP4.EXCP_ID,MIN(EFF_DTTM) AS 'TRUE_OPEN' FROM #EXCP EXCP4
							LEFT JOIN (SELECT EXCP_ID,MIN(EFF_DTTM) AS 'FIRST_CLOSE' FROM #EXCP WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') GROUP BY EXCP_ID) EXCP3
							ON EXCP3.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP4.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP4.EFF_DTTM > FIRST_CLOSE GROUP BY EXCP4.EXCP_ID) TRUE_OPEN
						ON TC.EXCP_ID = TRUE_OPEN.EXCP_ID
						WHERE TC.EFF_DTTM > TRUE_OPEN AND EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') GROUP BY TC.EXCP_ID) D					
 ON A.EXCP_ID = D.EXCP_ID
 LEFT JOIN (SELECT EXCP4.EXCP_ID,MIN(EFF_DTTM) AS 'TRUE_OPEN' FROM #EXCP EXCP4
							LEFT JOIN (SELECT EXCP_ID,MIN(EFF_DTTM) AS 'FIRST_CLOSE' FROM #EXCP WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') GROUP BY EXCP_ID) EXCP3
							ON EXCP3.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP4.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP4.EFF_DTTM > FIRST_CLOSE GROUP BY EXCP4.EXCP_ID) E
ON A.EXCP_ID = E.EXCP_ID
LEFT JOIN (SELECT EXCP_ID,MIN(EFF_DTTM) AS 'FIRST_CLOSE' FROM #EXCP WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') GROUP BY EXCP_ID) F
ON A.EXCP_ID = F.EXCP_ID

WHERE A.EFF_DTTM = CURR_EFF_DTTM

--EXCP_SCRUB_2--
IF OBJECT_ID ('tempdb..#EXCP2') IS NOT NULL
	BEGIN
	DROP TABLE #EXCP2
	END

SELECT A.*,(SELECT MAX(V) FROM (VALUES (A.EXCP_RQST_DTTM),(OPEN2),(OPEN3),(OPEN4)) AS VALUE (V)) AS 'TRUE_EXCP_OPEN'
INTO #EXCP2
FROM #EXCP1 A
LEFT JOIN (SELECT LOAN_NBR,MAX_DEFAULT FROM #MAX_DEFAULT) B
	ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT EXCP4.EXCP_ID,MIN(EFF_DTTM) AS 'OPEN3' FROM #EXCP EXCP4
				LEFT JOIN (SELECT EXCP_ID,CLOSE2 FROM #EXCP1) EXCP3
						ON EXCP3.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP4.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP4.EFF_DTTM > CLOSE2 GROUP BY EXCP4.EXCP_ID) C
	ON A.EXCP_ID = C.EXCP_ID
LEFT JOIN (SELECT EXCP5.EXCP_ID,MIN(EFF_DTTM) AS 'CLOSE3' FROM #EXCP EXCP5	
	LEFT JOIN (SELECT EXCP4.EXCP_ID,MIN(EFF_DTTM) AS 'OPEN3' FROM #EXCP EXCP4
					LEFT JOIN (SELECT EXCP_ID,CLOSE2 FROM #EXCP1 WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML')) EXCP3
							ON EXCP3.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP4.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP4.EFF_DTTM > CLOSE2 GROUP BY EXCP4.EXCP_ID) EXCP4
		ON EXCP5.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP5.EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP5.EFF_DTTM > OPEN3 GROUP BY EXCP5.EXCP_ID) D
	ON A.EXCP_ID = D.EXCP_ID
LEFT JOIN (SELECT EXCP6.EXCP_ID,MIN(EFF_DTTM) AS 'OPEN4' FROM #EXCP EXCP6	
	LEFT JOIN (SELECT EXCP5.EXCP_ID,MIN(EFF_DTTM) AS 'CLOSE3' FROM #EXCP EXCP5
		LEFT JOIN (SELECT EXCP4.EXCP_ID,MIN(EFF_DTTM) AS 'OPEN3' FROM #EXCP EXCP4
					LEFT JOIN (SELECT EXCP_ID,CLOSE2 FROM #EXCP1 WHERE EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML')) EXCP3
							ON EXCP3.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP4.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP4.EFF_DTTM > CLOSE2 GROUP BY EXCP4.EXCP_ID) EXCP4
			ON EXCP5.EXCP_ID = EXCP4.EXCP_ID WHERE EXCP5.EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP5.EFF_DTTM > OPEN3 GROUP BY EXCP5.EXCP_ID) EXCP5
		ON EXCP6.EXCP_ID = EXCP5.EXCP_ID WHERE EXCP6.EXCP_STS_DESC NOT IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') AND EXCP6.EFF_DTTM > CLOSE3 GROUP BY EXCP6.EXCP_ID) E
	ON A.EXCP_ID = E.EXCP_ID

--ARCHIVE DATA 1--
IF OBJECT_ID ('tempdb..#ARCHIVE1') IS NOT NULL
	BEGIN
	DROP TABLE #ARCHIVE1
	END

SELECT A.LOAN_NBR,B.MCA_PERCENT AS 'CURR_MCA',B.LOAN_STATUS AS 'CURR_LOAN_STATUS'
,PREV_MONTH_1_MCA,PREV_MONTH_1_STATUS,PREV_MONTH_1
,PREV_MONTH_2_MCA,PREV_MONTH_2_STATUS,PREV_MONTH_2
,PREV_MONTH_3_MCA,PREV_MONTH_3_STATUS,PREV_MONTH_3
,PREV_MONTH_4_MCA,PREV_MONTH_4_STATUS,PREV_MONTH_4
,PREV_MONTH_5_MCA,PREV_MONTH_5_STATUS,PREV_MONTH_5
,PREV_MONTH_6_MCA,PREV_MONTH_6_STATUS,PREV_MONTH_6
INTO #ARCHIVE1
FROM (SELECT DISTINCT LOAN_NBR FROM #EXCP0) A
INNER JOIN (SELECT LOAN_NBR,MCA_PERCENT,LOAN_STATUS FROM REVERSE_DW.DBO.[RM_CHAMPION_MASTER_TBL_CURR_VW]) B
	ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'PREV_MONTH_1_MCA',LOAN_STATUS AS 'PREV_MONTH_1_STATUS',DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-2)) AS 'PREV_MONTH_1' FROM REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_VW] (DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-2)),CAST(REPLACE(DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-2)),'-','') AS INT))) C
	ON A.LOAN_NBR = C.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'PREV_MONTH_2_MCA',LOAN_STATUS AS 'PREV_MONTH_2_STATUS',DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-3)) AS 'PREV_MONTH_2' FROM REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_VW] (DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-3)),CAST(REPLACE(DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-3)),'-','') AS INT))) D
	ON A.LOAN_NBR = D.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'PREV_MONTH_3_MCA',LOAN_STATUS AS 'PREV_MONTH_3_STATUS',DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-4)) AS 'PREV_MONTH_3' FROM REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_VW] (DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-4)),CAST(REPLACE(DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-4)),'-','') AS INT))) E
	ON A.LOAN_NBR = E.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'PREV_MONTH_4_MCA',LOAN_STATUS AS 'PREV_MONTH_4_STATUS',DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-5)) AS 'PREV_MONTH_4' FROM REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_VW] (DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-5)),CAST(REPLACE(DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-5)),'-','') AS INT))) F
	ON A.LOAN_NBR = F.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'PREV_MONTH_5_MCA',LOAN_STATUS AS 'PREV_MONTH_5_STATUS',DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-6)) AS 'PREV_MONTH_5' FROM REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_VW] (DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-6)),CAST(REPLACE(DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-6)),'-','') AS INT))) G
	ON A.LOAN_NBR = G.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'PREV_MONTH_6_MCA',LOAN_STATUS AS 'PREV_MONTH_6_STATUS',DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-7)) AS 'PREV_MONTH_6' FROM REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_VW] (DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-7)),CAST(REPLACE(DATEADD(DAY,1,EOMONTH(@CURR_MONTH_END,-7)),'-','') AS INT))) H
	ON A.LOAN_NBR = H.LOAN_NBR
*/

SELECT DISTINCT A.LOAN_NBR,CURR_MCA,CURR_LOAN_STATUS,A.EXCP_ID,A.DOC_DESC,A.EXCP_STS_DESC,A.ISSU_DESC,EXCP_CLOSED_BY,EXCP_CLOSE_DATE
FROM #EXCP2 A
LEFT JOIN #ARCHIVE1 B
	ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT EXCP4.EXCP_ID,EXCP4.EXCP_STS_UPDT_BY_DESC AS 'EXCP_CLOSED_BY',EXCP4.EFF_DTTM AS 'EXCP_CLOSE_DATE' FROM #EXCP EXCP4
				LEFT JOIN (SELECT EXCP1.EXCP_ID,MIN(EXCP1.EFF_DTTM) AS 'TRUE_CLOSE' FROM #EXCP EXCP1 
					LEFT JOIN (SELECT EXCP_ID,TRUE_EXCP_OPEN FROM #EXCP2) EXCP2
						ON EXCP1.EXCP_ID = EXCP2.EXCP_ID
					WHERE EFF_DTTM > TRUE_EXCP_OPEN AND EXCP_STS_DESC IN ('RESOLVED','CLOSED','NOT VALID','CLOSED WITH VENDOR','Resolved by ML') GROUP BY EXCP1.EXCP_ID) EXCP3
				ON EXCP4.EXCP_ID = EXCP3.EXCP_ID WHERE EXCP4.EFF_DTTM = EXCP3.TRUE_CLOSE) C
	ON A.EXCP_ID = C.EXCP_ID
LEFT JOIN (SELECT LOAN_NBR,PREV_MONTH_1_MCA,PREV_MONTH_1_STATUS,PREV_MONTH_1
			,PREV_MONTH_2_MCA,PREV_MONTH_2_STATUS,PREV_MONTH_2
			,PREV_MONTH_3_MCA,PREV_MONTH_3_STATUS,PREV_MONTH_3
			,PREV_MONTH_4_MCA,PREV_MONTH_4_STATUS,PREV_MONTH_4
			,PREV_MONTH_5_MCA,PREV_MONTH_5_STATUS,PREV_MONTH_5
			,PREV_MONTH_6_MCA,PREV_MONTH_6_STATUS,PREV_MONTH_6
			FROM #ARCHIVE1 WHERE PREV_MONTH_1_MCA >= 97.5 OR PREV_MONTH_2_MCA >= 97.5 OR PREV_MONTH_3_MCA >= 97.5 OR PREV_MONTH_4_MCA >= 97.5 OR PREV_MONTH_5_MCA >= 97.5 OR PREV_MONTH_6_MCA >= 97.5) D
	ON A.LOAN_NBR = D.LOAN_NBR


