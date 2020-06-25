DECLARE @DateFilter DATE

SET @DateFilter = getdate()

SET NOCOUNT ON

SELECT A.Loan_Nbr,GETDATE() AS 'Last_Refeshed',B.EXCP_ID,B.DOC_DESC,B.EXCP_STS_DESC,A.LOAN_STATUS,D.GRP_DESC,A.MCA_PERCENT,D.TAG_2_VAL,Made_Incur
,CASE WHEN DATEDIFF(DAY,Made_Incur,GETDATE()) < 30 THEN '< 30'
	  WHEN DATEDIFF(DAY,Made_Incur,GETDATE()) < 60 THEN '< 60'
	  WHEN DATEDIFF(DAY,Made_Incur,GETDATE()) < 90 THEN '< 90'
	  WHEN DATEDIFF(DAY,Made_Incur,GETDATE()) < 120 THEN '< 120'
	  WHEN DATEDIFF(DAY,Made_Incur,GETDATE()) < 180 THEN '< 180'
	  ELSE '> 180'
END AS 'Incur_Aging',
DATEDIFF(DAY,Made_Incur,GETDATE()) AS 'Count of Days Incurable',
C.[EXCP_STS_UPDT_BY_DESC]
,CASE WHEN WRK_GRP_DESC ='LandTran' THEN 'Curative'
ELSE WRK_GRP_DESC
END AS 'Work_Group'
INTO #Excp
FROM Reverse_DW.[dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW] A
RIGHT JOIN Reverse_DW.DBO.HUD_ASGN_EXCP_EDW B
ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT XX.EXCP_ID,EXCP_STS_UPDT_BY_DESC,MADE_INCUR FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW  XX
			LEFT JOIN (SELECT AA.EXCP_ID,MIN(EFF_DTTM) AS 'Made_Incur' FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW AA
						LEFT JOIN (SELECT EXCP_ID,MAX(END_DTTM) AS 'Made_Incur' FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW WHERE CURR_IND NOT IN ('Y') AND EXCP_STS_DESC <> 'INCURABLE' GROUP BY EXCP_ID) BB 
						ON AA.EXCP_ID = BB.EXCP_ID WHERE EFF_DTTM > Made_Incur GROUP BY AA.EXCP_ID) ZZ
			ON XX.EXCP_ID=ZZ.EXCP_ID WHERE XX.EFF_DTTM = MADE_INCUR) C	
ON B.EXCP_ID = C.EXCP_ID
LEFT JOIN (SELECT LOAN_NBR,TAG_2_VAL,[GRP_DESC] FROM Reverse_DW.DBO.HUD_ASGN_LOANS WHERE CURR_IND = 'Y') D
ON B.LOAN_NBR  = D.LOAN_NBR
LEFT JOIN (SELECT EXCP_ID,MAX(EFF_DTTM) AS 'Date_Filter' FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW WHERE CAST(EFF_DTTM AS DATE) <= CAST(@DateFilter AS DATE) AND EXCP_STS_DESC ='Incurable' GROUP BY EXCP_ID) E
ON B.EXCP_ID = E.EXCP_ID	

WHERE B.EXCP_STS_DESC = 'Incurable' 

AND B.CURR_IND = 'Y' --AND DATEDIFF(DAY,Made_Incur,GETDATE()) <= 120

AND B.EFF_DTTM = Date_Filter

AND ISNULL(D.GRP_DESC,'No Group') <> 'Grp 5 BofA GNMAs' 

--AND Loan_Status = 'Active' AND TAG_2_VAL IS NULL

ORDER BY Work_Group DESC,Made_Incur ASC

--Exception Level--

--SELECT * FROM #Excp

--Loan Level--
SELECT DISTINCT A.Loan_Nbr,	A.Last_Refeshed,A.LOAN_STATUS,	A.GRP_DESC,	A.MCA_PERCENT,	A.TAG_2_VAL,	A.Made_Incur,	A.Incur_Aging,	A.[Count of Days Incurable],	A.Work_Group,Excp_Count
FROM #Excp A
LEFT JOIN (SELECT Loan_Nbr,MIN(Made_Incur) AS 'Made_Incur' FROM #Excp GROUP BY Loan_Nbr) B
ON A.LOAN_NBR = B.LOAN_NBR
LEFT JOIN (SELECT Loan_Nbr,Count(Loan_Nbr) AS 'Excp_Count' FROM #Excp GROUP BY Loan_Nbr) C
ON A.LOAN_NBR = C.LOAN_NBR

WHERE A.Made_Incur = B.Made_Incur

DROP TABLE #Excp