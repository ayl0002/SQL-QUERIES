SELECT A.[Loan Number],B.[INVESTOR],POOL_NAME,
[FNMA Denied Date]
,[FNMA Approved Date]
,A.[TAG 2],ISNULL([Incurable Count],0) AS 'Incurable Count',B.MCA_PERCENT
,CASE WHEN B.MCA_PERCENT >= 105 THEN '>=105'
WHEN B.MCA_PERCENT >= 100 THEN '>=100'
WHEN B.MCA_PERCENT >= 97.5 THEN '>=97.5'
ELSE '<=97.49'
END AS 'MCA_Bucket'
,[MAX_CLAIM_AMOUNT],[CURRENT_TOTAL_UPB]
,CASE WHEN B.MCA_PERCENT >= 100 THEN [CURRENT_TOTAL_UPB] - [MAX_CLAIM_AMOUNT] 
ELSE 0
END AS 'CrossOver Amount'
FROM SharepointData.Dbo.HUDAssignLoans A
INNER JOIN [VRSQLRODS\RODS_PROD].REVERSE_DW.[dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW] B
	ON A.[Loan Number] = B.LOAN_NBR
LEFT JOIN (SELECT [LOAN NUMBER],COUNT([LOAN NUMBER]) AS 'Incurable Count' FROM SharepointData.Dbo.HUDAssignLoans WHERE [Incurable Flag] <> '0' GROUP BY [LOAN NUMBER]) C
	ON A.[Loan Number] = C.[Loan Number]
LEFT JOIN SharepointData.[dbo].[HUDAssignHUDStatus] D
	ON A.[Loan Number] = D.[Loan Number]

WHERE B.LOAN_STATUS = 'ACTIVE' AND ISNULL(A.[TAG 2],'No Tag') NOT IN ('SERVICER CURE','No Tag') AND isnull(B.[INVESTOR],'No Pool') = 'FNMA'

ORDER BY MCA_PERCENT DESC