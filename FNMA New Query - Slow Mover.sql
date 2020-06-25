SELECT TAB1.* INTO #BASE FROM ##NEW_FNMA_BASE TAB1

--MAX EXCP--
SELECT B.* INTO #EXCP FROM #BASE A LEFT JOIN Reverse_DW.DBO.HUD_ASGN_EXCP_EDW B ON CAST(A.LOAN_NBR AS VARCHAR) = CAST(B.LOAN_NBR AS VARCHAR)

--EXCP SCRUB--
SELECT D.*
INTO #EXCP1
FROM #BASE A
	LEFT JOIN (SELECT EXCP.*,BASE_DTTM.MIN_DTTM AS 'FIRST_OPEN' FROM #EXCP EXCP
					INNER JOIN (SELECT EXCP_ID,MIN(EFF_DTTM) AS 'MIN_DTTM' FROM #EXCP WHERE ISNULL([EXCP_STS_DESC],'No Status') not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') AND 
					([DOC_DESC] ='LOSS DRAFT' OR ISSU_DESC ='Forced Placed Insurance' OR ([DOC_DESC] IN ('TAX BILL','HOA') AND ISSU_DESC IN ('Delinquent','Delinquent-Super Lien','Delinquent- Junior Lien'))) GROUP BY EXCP_ID) BASE_DTTM
						ON BASE_DTTM.EXCP_ID = EXCP.EXCP_ID WHERE EXCP.EFF_DTTM = BASE_DTTM.MIN_DTTM) D 	
	ON A.LOAN_NBR = D.LOAN_NBR


--SM SCRUB--
SELECT DISTINCT A.[LOAN_NBR],E.EXCP_ID,SM_DOC,SM_ISSUE,E.[EXCP_STS_DESC],FIRST_OPEN,TRUE_CLOSE,DATEDIFF(D,FIRST_OPEN,ISNULL(TRUE_CLOSE,GETDATE())) AS 'Aging',MCA_PERCENT,CLAIM_FILED,CURRENT_MCA_BUCKET,CLAIM_FILED_MCA,CLAIM_FILED_MCA_BUCKET
INTO #FINAL
FROM #BASE A
LEFT JOIN (SELECT EXCP1.*,EXCP2.[DOC_DESC] AS 'SM_DOC',EXCP2.[ISSU_DESC] AS 'SM_ISSUE',FIRST_OPEN FROM #EXCP EXCP1
			INNER JOIN (SELECT * FROM #EXCP1) EXCP2
				ON EXCP1.EXCP_ID =  EXCP2.EXCP_ID  WHERE EXCP1.EFF_DTTM >= FIRST_OPEN) B
ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT EXCP1.EXCP_ID,MAX(EXCP1.EFF_DTTM) AS 'True_Close' FROM #EXCP EXCP1
			INNER JOIN (SELECT EXCP_ID,FIRST_OPEN FROM #EXCP1) EXCP2
				ON EXCP1.EXCP_ID =  EXCP2.EXCP_ID  WHERE EXCP1.EFF_DTTM > FIRST_OPEN AND ISNULL([EXCP_STS_DESC],'No Status') not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') and curr_ind = 'N' group by EXCP1.EXCP_ID) C
ON B.EXCP_ID = C.EXCP_ID
LEFT JOIN (SELECT * FROM #EXCP WHERE CURR_IND = 'Y') E
ON B.EXCP_ID = E.EXCP_ID
WHERE SM_DOC IS NOT NULL

SELECT A.*,Row_Number() OVER(Partition by A.Loan_Nbr Order by Excp_Id) AS 'SM_COUNT',COUNT_OF_OPEN_SM,OPEN_AGING INTO ##NEW_FNMA_BASE_SM FROM #FINAL A
LEFT JOIN (SELECT Loan_Nbr,COUNT(Loan_Nbr) AS 'COUNT_OF_OPEN_SM' FROM #FINAL WHERE [EXCP_STS_DESC] NOT IN ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') GROUP BY LOAN_NBR) B
ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR, SUM(Aging) AS 'OPEN_AGING' FROM #FINAL WHERE [EXCP_STS_DESC] not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') GROUP BY LOAN_NBR) C
ON A.LOAN_NBR = C.LOAN_NBR



--DROP TABLE ##NEW_FNMA_BASE_SM	
	
	
	/*INNER JOIN (SELECT MIN_DTTM.EXCP_ID,MIN(EFF_DTTM) AS 'TRUE_CLOSE' FROM #EXCP MIN_DTTM
						RIGHT JOIN 
						(SELECT EXCP_ID,MAX(EFF_DTTM) AS 'MAX_DTTM' FROM #EXCP WHERE [EXCP_STS_DESC] not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') AND 
								([DOC_DESC] ='LOSS DRAFT' OR ISSU_DESC ='Forced Placed Insurance' OR ([DOC_DESC] = 'TAX BILL' AND ISSU_DESC ='Delinquent')) GROUP BY EXCP_ID) MAX_DTTM
								ON MIN_DTTM.EXCP_ID = MAX_DTTM.EXCP_ID
								WHERE ISNULL(MIN_DTTM.EFF_DTTM,'1/1/1900') >= MAX_DTTM.MAX_DTTM AND [EXCP_STS_DESC] in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') GROUP BY MIN_DTTM.EXCP_ID) C
	ON C.EXCP_ID = D.EXCP_ID
	INNER JOIN (SELECT EXCP_ID,MAX(EFF_DTTM) AS 'TRUE_OPEN' FROM #EXCP WHERE [EXCP_STS_DESC] not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') AND 
				([DOC_DESC] ='LOSS DRAFT' OR ISSU_DESC ='Forced Placed Insurance' OR ([DOC_DESC] = 'TAX BILL' AND ISSU_DESC ='Delinquent')) GROUP BY EXCP_ID) E
	ON E.EXCP_ID = D.EXCP_ID
	INNER JOIN (SELECT EXCP_ID,EXCP_STS_DESC AS 'CURR_STATUS' FROM #EXCP WHERE CURR_IND = 'Y') CURR_EXCP
	ON CURR_EXCP.EXCP_ID = D.EXCP_ID*/


	
--SLOW MOVER SCRUB--
/*SELECT C.* 

	LEFT JOIN #EXCP1 A
	ON A.LOAN_NBR = C.LOAN_NBR
	LEFT JOIN 
	
	SELECT EXCP_ID,MAX(EFF_DTTM) AS 'TRUE_CLOSE' FROM #EXCP WHERE [EXCP_STS_DESC] not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable','Resolved by ML') GROUP BY EXCP_ID) B

	ON A.EXCP_ID = B.EXCP_ID*/



--DROP TABLE #BASE,#EXCP,#EXCP1,#FINAL
