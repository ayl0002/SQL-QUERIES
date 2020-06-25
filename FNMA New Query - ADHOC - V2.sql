SET ANSI_WARNINGS OFF
SET NOCOUNT ON
SELECT A.*,C.* INTO #BASE FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP A
	LEFT JOIN (SELECT * FROM SharepointData.DBO.HUDASSIGNEXCEPTIONS WHERE [EXCEPTION ID] IS NOT NULL) C
	ON CAST(A.EXCP_ID AS VARCHAR) = CAST(C.[EXCEPTION ID] AS VARCHAR)
	

	
--GC DATA--
SELECT DISTINCT A.*,B.[DOCUMENT],ISNULL(GC_COUNT,0) + ISNULL(LEDGER_GC_COUNT,0) AS 'GC_COUNT',ISNULL(HOA_LTRS,0)+ISNULL(OCC_LTRS,0)+ISNULL(DC_LTRS,0)+ISNULL(TRUST_LTRS,0)+ISNULL(POR_LTRS,0) AS 'LTR_COUNT',ISNULL(HOA_DK_COUNT,0)+ISNULL(POR_DK_COUNT,0) AS 'DK_COUNT',HOA_LTRS,OCC_LTRS,DC_LTRS,ISNULL(HOA_DK_COUNT,0) AS 'HOA_DK_COUNT',ISNULL(POR_DK_COUNT,0) AS 'POR_DK_COUNT'
INTO #BASE1
FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP A
LEFT JOIN #BASE B
ON A.Excp_ID = B.Excp_ID
LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES ([GFT_CRD_LTR_SNT_DTTM]),([GFT_CRD_LTR_SNT_2_DTTM]),	([GFT_CRD_LTR_SNT_3_DTTM]),([Ledger Letter Sent 1]),	([Ledger Letter Sent 2]),	([Ledger Letter Sent 3]),	([Non GC Letter Sent 1]),	([Non GC Letter Sent 2]),	([Non GC Letter Sent 3])) AS VALUE (V)) 
AS [HOA_LTRS]
FROM #BASE WHERE [Document] IN ('HOA')) C
ON B.[EXCEPTION ID] = C.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES ([GFT_CRD_LTR_SNT_DTTM]),([GFT_CRD_LTR_SNT_2_DTTM]),	([GFT_CRD_LTR_SNT_3_DTTM]),([Non GC Letter Sent 1]),	([Non GC Letter Sent 2]),	([Non GC Letter Sent 3])) AS VALUE (V)) 
AS 'OCC_LTRS'
FROM #BASE
WHERE [Document] IN ('Current OCC Cert')) D
ON B.[EXCEPTION ID] = D.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES ([GFT_CRD_LTR_SNT_DTTM]),([GFT_CRD_LTR_SNT_2_DTTM]),	([GFT_CRD_LTR_SNT_3_DTTM])) AS VALUE (V)) 
AS 'DC_LTRS'
FROM #BASE
WHERE [DOCUMENT] IN ('Death Cert HACG')) E
ON B.[EXCEPTION ID] = E.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID], COUNT([SNT_FR_GFT_CRD_PROC_DTTM]) AS 'GC_COUNT' FROM #BASE WHERE [SNT_FR_GFT_CRD_PROC_DTTM] IS NOT NULL AND [DOCUMENT] IN ('Death Cert HACG','Trust - HACG','Proof of Repair','Current OCC Cert','HOA') GROUP BY [EXCEPTION ID]) F
ON B.[EXCEPTION ID] = F.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID], COUNT([Ledger Sent for Gift Card Processing]) AS 'LEDGER_GC_COUNT' FROM #BASE WHERE [Ledger Sent for Gift Card Processing] IS NOT NULL AND [DOCUMENT] IN ('HOA') GROUP BY [EXCEPTION ID]) G
ON B.[EXCEPTION ID] = G.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES ([Ledger Letter Sent 1]),([Ledger Letter Sent 2]),([Ledger Letter Sent 3]),([SNT_TO_INSPT_VNDR_DTTM])) AS VALUE (V)) AS 'OCC_DK_COUNT'
FROM #BASE
WHERE [DOCUMENT] IN ('CURRENT OCC CERT')) H
ON B.[EXCEPTION ID] = H.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES ([Ledger Letter Document Returned]),	([SNT_TO_INSPT_VNDR_DTTM])) AS VALUE (V)) AS 'HOA_DK_COUNT'
FROM #BASE
WHERE [DOCUMENT] IN ('HOA')) I
ON B.[EXCEPTION ID] = I.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES ([Ledger Letter Sent 1])) AS VALUE (V)) AS 'POR_DK_COUNT'
FROM #BASE
WHERE [DOCUMENT] IN ('Proof of Repair')) J
ON B.[EXCEPTION ID] = J.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES (GFT_CRD_LTR_SNT_DTTM),([GFT_CRD_LTR_SNT_2_DTTM]),	([GFT_CRD_LTR_SNT_3_DTTM])) AS VALUE (V)) 
AS 'TRUST_LTRS'
FROM #BASE
WHERE [DOCUMENT] IN ('Trust - HACG')) AA
ON B.[EXCEPTION ID] = AA.[EXCEPTION ID]

LEFT JOIN (SELECT [EXCEPTION ID],(SELECT COUNT(V) FROM (VALUES (GFT_CRD_LTR_SNT_DTTM),([GFT_CRD_LTR_SNT_2_DTTM]),	([GFT_CRD_LTR_SNT_3_DTTM])) AS VALUE (V)) 
AS 'POR_LTRS'
FROM #BASE
WHERE [DOCUMENT] IN ('Proof of Repair')) BB
ON B.[EXCEPTION ID] = BB.[EXCEPTION ID]


--RN--
--GC--
SELECT A.LOAN_NBR,[DOCUMENT],GC_COUNT,ROW_NUMBER() OVER(PARTITION BY [LOAN_NBR] ORDER BY [DOCUMENT]) AS 'GC_RN'
INTO #GC_RN
		FROM #BASE1 A
WHERE GC_COUNT > 0
--DK--
SELECT A.LOAN_NBR,[DOCUMENT],DK_COUNT,ROW_NUMBER() OVER(PARTITION BY [LOAN_NBR] ORDER BY [DOCUMENT]) AS 'DK_RN'
INTO #DK_RN
		FROM #BASE1 A
WHERE DK_COUNT > 0
--LTR--
SELECT A.LOAN_NBR,[DOCUMENT],LTR_COUNT,ROW_NUMBER() OVER(PARTITION BY [LOAN_NBR] ORDER BY [DOCUMENT]) AS 'LTR_RN'
INTO #LTR_RN
		FROM #BASE1 A
WHERE LTR_COUNT > 0

--TREATMENT AGGREGATE--
SELECT DISTINCT BASE.*,ISNULL(GC_COUNT_TOTAL,0) 'GC_COUNT_TOTAL',ISNULL(DK_COUNT_TOTAL,0) 'DK_COUNT_TOTAL',ISNULL(LTR_COUNT_TOTAL,0) AS 'LTR_COUNT_TOTAL',ISNULL(NTS_COUNT,0) AS 'NTS_COUNT',ISNULL(ISGN_COUNT,0) AS 'ISGN_COUNT',ISNULL(LRES_COUNT,0) AS 'LRES_COUNT'
,CAST(ISNULL(GC_COUNT_TOTAL,0) * 56.95 AS FLOAT) AS 'GC_EXPENSE',CAST(ISNULL(DK_COUNT_TOTAL,0)*89.00 AS FLOAT) AS'DK_EXPENSE',CAST (ISNULL(LTR_COUNT_TOTAL,0) * 15.95 AS FLOAT) AS 'LTR_EXPENSE',CAST(ISNULL(NTS_COUNT,0) * 75.00 AS FLOAT) AS 'NTS_EXPENSE',CAST(ISNULL(LRES_COUNT,0) * 175.00 AS FLOAT) AS 'LRES_EXPENSE'--,ISNULL(ISGN_COUNT,0) AS 'ISGN_COUNT' 
INTO #FINAL
FROM TACT_REV.DBO.NEW_FNMA_BASE BASE
LEFT JOIN (SELECT  A.LOAN_NBR,ISNULL(GC1.GC_COUNT,0)+ISNULL(GC2.GC_COUNT,0)+ISNULL(GC3.GC_COUNT,0)+ISNULL(GC4.GC_COUNT,0)+ISNULL(GC5.GC_COUNT,0)+ISNULL(GC6.GC_COUNT,0)+ISNULL(GC7.GC_COUNT,0) AS 'GC_COUNT_TOTAL'
			FROM #GC_RN A
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 1) GC1
			ON GC1.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 2) GC2
			ON GC2.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 3) GC3
			ON GC3.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 4) GC4
			ON GC4.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 5) GC5
			ON GC5.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 6) GC6
			ON GC6.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #GC_RN A WHERE GC_RN = 7) GC7
			ON GC7.LOAN_NBR = A.LOAN_NBR) GC_TOTAL
	ON GC_TOTAL.LOAN_NBR = BASE.LOAN_NBR
LEFT JOIN (SELECT  A.LOAN_NBR,ISNULL(DK1.DK_COUNT,0)+ISNULL(DK2.DK_COUNT,0)+ISNULL(DK3.DK_COUNT,0)+ISNULL(DK4.DK_COUNT,0)+ISNULL(DK5.DK_COUNT,0)+ISNULL(DK6.DK_COUNT,0)+ISNULL(DK7.DK_COUNT,0) AS 'DK_COUNT_TOTAL'
			FROM #DK_RN A
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 1) DK1
			ON DK1.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 2) DK2
			ON DK2.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 3) DK3
			ON DK3.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 4) DK4
			ON DK4.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 5) DK5
			ON DK5.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 6) DK6
			ON DK6.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #DK_RN A WHERE DK_RN = 7) DK7
			ON DK7.LOAN_NBR = A.LOAN_NBR) DK_TOTAL
	ON DK_TOTAL.LOAN_NBR = BASE.LOAN_NBR
LEFT JOIN (SELECT  A.LOAN_NBR,ISNULL(LTR1.LTR_COUNT,0)+ISNULL(LTR2.LTR_COUNT,0)+ISNULL(LTR3.LTR_COUNT,0)+ISNULL(LTR4.LTR_COUNT,0)+ISNULL(LTR5.LTR_COUNT,0)+ISNULL(LTR6.LTR_COUNT,0)+ISNULL(LTR7.LTR_COUNT,0) AS 'LTR_COUNT_TOTAL'
			FROM #LTR_RN A
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 1) LTR1
			ON LTR1.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 2) LTR2
			ON LTR2.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 3) LTR3
			ON LTR3.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 4) LTR4
			ON LTR4.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 5) LTR5
			ON LTR5.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 6) LTR6
			ON LTR6.LOAN_NBR = A.LOAN_NBR 
			LEFT JOIN (SELECT A.* FROM #LTR_RN A WHERE LTR_RN = 7) LTR7
			ON LTR7.LOAN_NBR = A.LOAN_NBR) LTR_TOTAL
	ON LTR_TOTAL.LOAN_NBR = BASE.LOAN_NBR
LEFT JOIN (SELECT BB.LOAN_NBR,MAX(NTS_COUNT) AS 'NTS_COUNT' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP BB
			INNER JOIN (SELECT LOAN_NBR,TAX_VENDOR,ROW_NUMBER() OVER (Partition By Loan_Nbr ORDER BY TAX_VENDOR) AS 'NTS_COUNT' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP WHERE TAX_VENDOR = 'NTS') AA
			ON AA.LOAN_NBR = BB.LOAN_NBR  GROUP BY BB.LOAN_NBR) NTS
	ON NTS.LOAN_NBR = BASE.LOAN_NBR
LEFT JOIN (SELECT BB.LOAN_NBR,MAX(ISGN_COUNT) AS 'ISGN_COUNT' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP BB
			INNER JOIN (SELECT LOAN_NBR,TAX_VENDOR,ROW_NUMBER() OVER (Partition By Loan_Nbr ORDER BY TAX_VENDOR) AS 'ISGN_COUNT' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP WHERE TAX_VENDOR = 'ISGN') AA
			ON AA.LOAN_NBR = BB.LOAN_NBR GROUP BY BB.LOAN_NBR) ISGN
	ON ISGN.LOAN_NBR = BASE.LOAN_NBR
LEFT JOIN (SELECT BB.LOAN_NBR,MAX(LRES_COUNT) AS 'LRES_COUNT' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP BB
			INNER JOIN (SELECT LOAN_NBR,HOA_VENDOR,ROW_NUMBER() OVER (Partition By Loan_Nbr ORDER BY TAX_VENDOR) AS 'LRES_COUNT' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP WHERE HOA_VENDOR = 'Local Vendor') AA
			ON AA.LOAN_NBR = BB.LOAN_NBR GROUP BY BB.LOAN_NBR) LRES
	ON LRES.LOAN_NBR = BASE.LOAN_NBR

SELECT DISTINCT B.*,Agg_Status,EXCP_OPEN_AGING,EXCP_AGING,B.CLAIM_FILED_MCA,E.[Tag 2],E.[Incurable Flag],COUNT_OF_OPEN_SM,OPEN_AGING AS 'SM_OPEN_AGING',
GC_EXPENSE+DK_EXPENSE+LTR_EXPENSE+NTS_EXPENSE+LRES_EXPENSE AS 'TOTAL_EXPENSE',Slow_Mover_Count,Slow_Mover_Aging
FROM #FINAL B
LEFT JOIN (SELECT LOAN_NBR,MAX(SM_COUNT) AS 'Slow_Mover_Count' FROM tact_rev.dbo.NEW_FNMA_BASE_SM GROUP BY LOAN_NBR) C
	ON B.LOAN_NBR = C.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MAX(Aging) AS 'Slow_Mover_Aging' FROM tact_rev.dbo.NEW_FNMA_BASE_SM GROUP BY LOAN_NBR) D
	ON B.LOAN_NBR = D.LOAN_NBR
LEFT JOIN SharepointData.Dbo.HUDAssignLoans E
	ON CAST(B.Loan_Nbr AS VARCHAR) = CAST(E.[Loan Number] AS VARCHAR)
LEFT JOIN (SELECT LOAN_NBR,SUM(DAYS_TO_CLOSE) AS 'EXCP_AGING' FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP GROUP BY LOAN_NBR) F
	ON B.LOAN_NBR = F.LOAN_NBR
LEFT JOIN  tact_rev.dbo.NEW_FNMA_BASE_SM H
	ON B.LOAN_NBR = H.LOAN_NBR


--SET NOCOUNT ON SELECT B.*,D.[Tag 2],D.[Incurable Flag] FROM TACT_REV.DBO.NEW_FNMA_BASE_EXCP B LEFT JOIN SharepointData.dbo.HUDAssignLoans D ON CAST(B.Loan_Nbr AS VARCHAR) = CAST(D.[Loan Number] AS VARCHAR)

--SET NOCOUNT ON SELECT b.*,D.[Tag 2],D.[Incurable Flag] FROM TACT_REV.DBO.NEW_FNMA_BASE_SM B LEFT JOIN SharepointData.dbo.HUDAssignLoans D ON CAST(B.Loan_Nbr AS VARCHAR) = CAST(D.[Loan Number] AS VARCHAR)

/*
SELECT A,B.LOANS_TOTAL,LRES_EXPENSE,NTS_EXPENSE,DK_EXPENSE,LTR_EXPENSE,LRES_EXPENSE/LOANS_TOTAL AS 'LRes Avg Per Claim'
,NTS_EXPENSE/LOANS_TOTAL AS 'NTS Avg Per Claim'
,DK_EXPENSE/LOANS_TOTAL AS 'DK Avg Per Claim'
,LTR_EXPENSE/LOANS_TOTAL AS 'LTR Avg Per Claim'
 FROM (SELECT 'A' AS 'PRIME_KEY',A.* FROM #FINAL A) A
LEFT JOIN (SELECT 'A' AS 'PRIME_KEY', COUNT(LOAN_NBR) AS 'LOANS_TOTAL' FROM #FINAL WHERE (CLAIM_FILED IS NULL OR DATEPART(YEAR,CLAIM_FILED) = 2020)) B
	ON A.PRIME_KEY = B.PRIME_KEY
LEFT JOIN (SELECT 'A' AS 'PRIME_KEY',SUM(LRES_EXPENSE)  AS 'LRES_TOTAL' FROM #FINAL WHERE (CLAIM_FILED IS NULL OR DATEPART(YEAR,CLAIM_FILED) = 2020)) LRES
	ON A.PRIME_KEY  = LRES.PRIME_KEY
LEFT JOIN (SELECT 'A' AS 'PRIME_KEY',SUM(NTS_EXPENSE)  AS 'NTS_TOTAL' FROM #FINAL WHERE (CLAIM_FILED IS NULL OR DATEPART(YEAR,CLAIM_FILED) = 2020)) NTS
	ON A.PRIME_KEY = NTS.PRIME_KEY
LEFT JOIN (SELECT 'A' AS 'PRIME_KEY',SUM(DK_EXPENSE)  AS 'DK_TOTAL' FROM #FINAL WHERE (CLAIM_FILED IS NULL OR DATEPART(YEAR,CLAIM_FILED) = 2020)) DK
	ON A.PRIME_KEY = DK.PRIME_KEY
LEFT JOIN (SELECT 'A' AS 'PRIME_KEY',SUM(LTR_EXPENSE)  AS 'LTR_TOTAL' FROM #FINAL WHERE (CLAIM_FILED IS NULL OR DATEPART(YEAR,CLAIM_FILED) = 2020)) LTR
	ON A.PRIME_KEY = LRES.PRIME_KEY*/



DROP TABLE #FINAL,#BASE,#BASE1,#LTR_RN,#DK_RN,#GC_RN






