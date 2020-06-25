SELECT [Loan Number],
	CASE WHEN C.[Loan_nbr] IS NOT NULL THEN 'DO NOT FILE'
		 WHEN B.[Loan_nbr] IS NOT NULL THEN 'FNMA Pre-Approved'
		 WHEN C.[Loan_nbr] IS NULL AND B.[Loan_nbr] IS NULL THEN 'N/A'
		 ELSE 'Error'
		 END AS 'FNMA Pre-Approve Flag'
INTO #FNMAFlag
FROM SharepointData.Dbo.HUDAssignLoans A
LEFT JOIN Tact_Rev.[dbo].[HACGFNMAPreApprove] B
	ON A.[Loan Number] = B.[Loan_nbr]
LEFT JOIN Tact_Rev.[dbo].[HACGFNMAHold] C
	ON A.[Loan Number] = C.[Loan_nbr]

WHERE A.[loan number] IN ('2694467',
'2813063',
'2698381',
'2785957',
'2756348',
'1153022',
'2727273',
'2786151',
'2127448',
'2231376',
'2783158',
'2771860',
'2707703',
'2675362',
'2779573',
'2759067',
'1153426',
'2241447',
'2788142',
'2677308',
'2685193',
'2676090',
'2681359',
'2802812',
'1150568',
'2784160',
'2677729',
'2684535',
'2739529',
'2681565',
'2753959',
'2766749',
'2778549',
'2776865',
'2333266',
'2774408',
'2765511',
'2758501',
'1155214',
'1152336',
'2675921',
'2716613',
'2747062',
'2705949',
'2676615',
'2677912',
'341693',
'2736003',
'2676432',
'2806086',
'2117402',
'2279088',
'2716920',
'2679333',
'1151228',
'2139545',
'1151510',
'2680768',
'2772714',
'2716953',
'1154414',
'2795824',
'2829390',
'2779265',
'2706702',
'2785194',
'2787620',
'2709282',
'2177860',
'2163728',
'2753948',
'2775933',
'2718853',
'2769797',
'1150735',
'2782830',
'316455',
'1151519',
'2723805',
'2704813',
'2101518',
'2677295',
'2761390',
'2680600',
'2727284',
'2698007',
'1153390',
'1153762',
'2812006',
'2726089',
'2842182',
'2735923',
'2781076',
'1154404',
'2681075',
'2676693',
'2807145',
'2843149',
'2711538',
'2774909',
'2740383',
'2719240',
'2786195',
'2839780',
'2769296',
'2740602',
'2755940',
'2751047',
'2675351',
'2726363',
'2783078',
'1152684',
'342162',
'2681440',
'2215742',
'2686899',
'2704209',
'2680575',
'2275095',
'2755597',
'1012946',
'2696891',
'1151655',
'2695969',
'2767875',
'2788095',
'1025241',
'1152939',
'2856167',
'2752093',
'2259552',
'2836812',
'2777866',
'2777888',
'2179305',
'2799964',
'2148977',
'2790339',
'2760685',
'2714757',
'2860835',
'2111587',
'2802413',
'2711947',
'2770972',
'2860700',
'2786823',
'2782670',
'2712390',
'2823884',
'2807931',
'2759498',
'2797007',
'2727581',
'2782351',
'2793560',
'2775012',
'2827230',
'2794765',
'2821542',
'2743854',
'2794311',
'2118675',
'2167345',
'2150632',
'2813677',
'2684740',
'2373631',
'2747529',
'2772849',
'2758260',
'2858352',
'2792956',
'2757577',
'2852118',
'2791181',
'2787766',
'2679173',
'2157800',
'2758910',
'2698074',
'2775078',
'2830348',
'2788734',
'2862110',
'2780075',
'2769150',
'2788950',
'2775410',
'2750503',
'2787686',
'2829403',
'2763096',
'2129667',
'2681064',
'2116161',
'2804949',
'2795458',
'2768592',
'2792785',
'2802297',
'2847837',
'2780985',
'2785935',
'2723827',
'2677796',
'2754404',
'2766475',
'2787152',
'2764587',
'2754028',
'2824658',
'2820552',
'2788346',
'2762665',
'1154409',
'2147807',
'2788277',
'2808841',
'2685444',
'2715246',
'2770379',
'2725567',
'2806417',
'2156228',
'2776397',
'2794550',
'2683965',
'2701843',
'2139818',
'2781236',
'2861062',
'2754448',
'2755405',
'2849544',
'2796869',
'2721266',
'2836059',
'2757975',
'2755860',
'2780337',
'2756543',
'2243655',
'2853563',
'2791409',
'2147738',
'2798907',
'2776148',
'2780612',
'2728537',
'2778311',
'2775922',
'2816705',
'2811312',
'2713541',
'2755768',
'2780348',
'2158093',
'2806406',
'2723097',
'2764337',
'2787038',
'2785606',
'2800091',
'2842115',
'2776137',
'2768912',
'2782965',
'2782340',
'2764872',
'2743832',
'2812869',
'2768239',
'1150107',
'2713368',
'2796448',
'2791170',
'2676181',
'2777775',
'2840124',
'2758475',
'2104646',
'2767933',
'2865373',
'2753130',
'2788803',
'2746824',
'2195076',
'2743080',
'2730290',
'2732862',
'2770391',
'2780758',
'2804448',
'2800444',
'2867386',
'2796222',
'1154967',
'2222694',
'2755187',
'1153587',
'2157230',
'2813779',
'2127927',
'2757372',
'2786516',
'2170088',
'2770119',
'2756667',
'2777478',
'2213682',
'2704835',
'2694639',
'2689153',
'2814177',
'2779287',
'2764941',
'2769138',
'2791352',
'2802823',
'2763893',
'2771995',
'2810140',
'2840987',
'2195167',
'2236428',
'2796916',
'2778936',
'2236929',
'2782022',
'2170102',
'2715166',
'2777241',
'2779835',
'2765599',
'2782976',
'2758453',
'2846790',
'2757225',
'2726261',
'2715996',
'2742067',
'2316904',
'1010320',
'2805508',
'2707177',
'2700034',
'2731736',
'2752106',
'2689723',
'2777899',
'2720049',
'2783853',
'2732635',
'2736504',
'2729925',
'2312409',
'2731246',
'2689949',
'2693193',
'2730336',
'2692170',
'2729709',
'2693035',
'2676933',
'2698520',
'2428669',
'1012640',
'1017043',
'1011730',
'2708418',
'2759136',
'2718580',
'2749428',
'1154756',
'2752413',
'2762530',
'1024984')

SELECT Loan_Nbr,[MCA_Crossover_DT],[MAX_CLAIM_AMOUNT] ,A.[CURRENT_TOTAL_UPB]
INTO #BASE
FROM SharepointData.Dbo.HUDAssignLoans B 
Right Join #FNMAFlag C
	ON C.[loan number] = B.[loan number]
INNER JOIN [VRSQLRODS\RODS_PROD].Reverse_DW.[dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW] A
	ON A.[loan_nbr] = c.[loan number]


--Incurable Scrub--
SELECT 
A.*,B.Excp_ID,B.[DOC_DESC],B.EXCP_STS_DESC,B.EFF_DTTM,B.Row_Nbr
INTO #Incur_Scrub
FROM #BASE A
LEFT JOIN (SELECT Loan_Nbr,Excp_ID,[DOC_DESC],EXCP_STS_DESC,EFF_DTTM,ROW_NUMBER() OVER (Partition by Excp_ID ORDER BY EFF_DTTM ASC) AS 'Row_Nbr'  FROM SharepointData.dbo.HUDAssignLoans A INNER JOIN [VRSQLRODS\RODS_PROD].Reverse_Dw.[dbo].[HUD_ASGN_EXCP_EDW] B ON A.[Loan Number] = B.Loan_Nbr WHERE EXCP_STS_DESC IN ('INCURABLE') AND CAST(eff_DTTM AS DATE) < CAST('8/1/2019' AS DATE)) B 
On A.Loan_Nbr = B.Loan_Nbr

SELECT 
A.*,B.Excp_ID,B.[DOC_DESC],B.EXCP_STS_DESC,B.EFF_DTTM,B.Row_Nbr
INTO #POR_Scrub
FROM #BASE A
LEFT JOIN (SELECT Loan_Nbr,Excp_ID,[DOC_DESC],EXCP_STS_DESC,EFF_DTTM,ROW_NUMBER() OVER (Partition by Excp_ID ORDER BY EFF_DTTM ASC) AS 'Row_Nbr'  FROM SharepointData.dbo.HUDAssignLoans A INNER JOIN [VRSQLRODS\RODS_PROD].Reverse_Dw.[dbo].[HUD_ASGN_EXCP_EDW] B ON A.[Loan Number] = B.Loan_Nbr WHERE DOC_DESC = 'Proof of Repair') B 
On A.Loan_Nbr = B.Loan_Nbr

--UPB Scrub--
SELECT A.Loan_Nbr,TXN_EFF_DT,UPB_AMT AS 'June_UPB',ROW_NUMBER() OVER (Partition BY A.Loan_Nbr ORDER BY TXN_EFF_DT) AS 'MaxDate'
INTO #UPB 
FROM #Incur_Scrub A
LEFT JOIN [VRSQLRODS\RODS_PROD].[Reverse_DW].[dbo].[RM_MASTER_TXN_VW] B
ON A.Loan_Nbr = B.Loan_Nbr
WHERE CAST(TXN_EFF_DT AS DATE) <= CAST('6/24/2019' AS DATE) AND CAST(TXN_EFF_DT AS DATE) >= CAST('5/31/2019' AS DATE)
------

SELECT DISTINCT A.Loan_Nbr,CAST(A.[MCA_Crossover_DT] AS DATE) AS 'Crossover_Date',A.[MAX_CLAIM_AMOUNT] AS 'MCA',CAST(A.[CURRENT_TOTAL_UPB] AS FLOAT(2)) AS 'Current_UPB',(A.[CURRENT_TOTAL_UPB] - A.[MAX_CLAIM_AMOUNT])  AS 'TOTAL_CROSSOVER'
,TXN_EFF_DT,JUNE_UPB,(JUNE_UPB - A.[MAX_CLAIM_AMOUNT]) AS 'June_CrossOver'
,C.EXCP_ID,C.[DOC_DESC],C.Min_Excp_Dt,E.EXCP_ID AS 'POR_EXCP_ID',E.DOC_DESC AS 'POR_DOC_DESC',D.MIN_EXCP_DT AS 'POR_EXCP_DT',A.[MAX_CLAIM_AMOUNT] ,A.[CURRENT_TOTAL_UPB]
INTO #BASE2
FROM #Incur_Scrub A
LEFT JOIN (SELECT UPB.* FROM #UPB UPB
	LEFT JOIN (SELECT Loan_Nbr,MAX(MaxDate) AS 'MaxDate' FROM #UPB GROUP BY Loan_Nbr) MaxUpb ON  UPB.Loan_NBR = MaxUpb.Loan_Nbr WHERE UPB.MaxDate =  MaxUpb.MaxDate) B
ON A.Loan_Nbr = B.LOAN_NBR
LEFT JOIN (SELECT A.Loan_Nbr,A.Excp_ID,A.[DOC_DESC],A.EXCP_STS_DESC,A.EFF_DTTM AS 'Min_Excp_Dt' FROM #Incur_Scrub A LEFT JOIN
			(SELECT Excp_ID AS 'Min_Excp_ID',MIN(Row_Nbr) AS 'Min_Row' FROM #Incur_Scrub GROUP BY Excp_ID ) B ON A.EXCP_ID = B.Min_Excp_ID WHERE Row_Nbr = Min_Row AND Min_Excp_ID = A.Excp_ID) C
ON A.Excp_ID = C.Excp_ID
/*LEFT JOIN (SELECT A.Loan_Nbr,A.Excp_ID,A.[DOC_DESC],A.EXCP_STS_DESC,A.EFF_DTTM AS 'Max_Excp_Dt' FROM #Incur_Scrub A LEFT JOIN
			(SELECT Excp_ID AS 'Max_Excp_ID',Max(Row_Nbr) AS 'Max_Row' FROM #Incur_Scrub GROUP BY Excp_ID ) B ON A.EXCP_ID = B.Max_Excp_ID WHERE Row_Nbr = Max_Row AND Max_Excp_ID = A.Excp_ID) 
 D
ON A.Excp_ID = D.Excp_ID*/
LEFT JOIN #POR_Scrub E
ON A.LOAN_NBR = E.LOAN_NBR
LEFT JOIN (SELECT A.Loan_Nbr,A.Excp_ID,A.[DOC_DESC],A.EXCP_STS_DESC,A.EFF_DTTM AS 'Min_Excp_Dt' FROM #POR_Scrub A LEFT JOIN
			(SELECT Excp_ID AS 'Min_Excp_ID',MIN(Row_Nbr) AS 'Min_Row' FROM #Incur_Scrub GROUP BY Excp_ID ) B ON A.EXCP_ID = B.Min_Excp_ID WHERE Row_Nbr = Min_Row AND Min_Excp_ID = A.Excp_ID) D
ON E.Excp_ID = D.Excp_ID


--Final1--
SELECT Loan_Nbr,POR_EXCP_ID,LOAN_NBR|+POR_EXCP_ID AS 'POR_KEY',Excp_ID,Loan_Nbr+Excp_ID AS 'Excp_Key'
,ISNULL(DOC_DESC,'No Incurable') AS 'Exception_Type'
,CASE 
WHEN EXCP_ID IS NULL AND POR_EXCP_ID IS NULL THEN 'No Incurable'
WHEN EXCP_ID IS NOT NULL THEN 'Check Excp Type - Eligible'
ELSE 'Not Eligible'
END AS 'Incurable Flag'
,ISNULL(POR_DOC_DESC,'No POR') AS 'POR_Flag',
CAST((TOTAL_CROSSOVER - June_CrossOver) AS FLOAT(2)) AS 'Recommended Servicer Loss Amount',
CAST('6/24/2019' AS DATE) AS 'Recommended Servicer Loss Period Start Date',
CAST(GETDATE() AS DATE) AS 'Recommended Servicer Loss Period End Date'
,CASE 
	WHEN CAST(June_CrossOver AS FLOAT(2)) < 0 THEN 'Crossed 100% After 6/25/2019 - Review with Management'
ELSE Cast(CAST(June_CrossOver AS FLOAT(2)) AS NVarchar)
END AS 'Recommended Fannie Mae Loss Amount' 
,CAST([Crossover_Date] AS DATE) AS 'Recommended Fannie Mae Loss Period Start Date',
CAST('6/24/2019' AS DATE) AS 'Recommended Fannie Mae Loss Period End Date'

,TOTAL_CROSSOVER,[MAX_CLAIM_AMOUNT] ,[CURRENT_TOTAL_UPB],Crossover_Date
,CAST(Min_Excp_Dt AS DATE) AS 'Min_Incur_Date'
INTO #Final1
FROM #BASE2

--Final2--
SELECT DISTINCT A.*,ROW_NUMBER () Over (Partition By Loan_Nbr Order By A.[Incurable Flag]) AS 'RowFlag',ROW_NUMBER () OVER (Partition By Loan_Nbr Order by A.POR_FLAG) AS 'PORFlag'
INTO #Final2 
FROM #Final1 A
	LEFT JOIN (SELECT Excp_Key FROM #Final1 WHERE [Incurable Flag] IN ('Eligible')) B
	ON A.Excp_Key = B.Excp_Key
	LEFT JOIN (SELECT Excp_Key FROM #Final1 WHERE [Incurable Flag]IN ('Not Eligible')) C
	ON A.Excp_Key = C.Excp_Key
	LEFT JOIN (SELECT POR_KEY FROM #Final1 WHERE POR_Flag = 'Proof of Repair') D
	ON A.POR_KEY = D.POR_KEY

--Final 3--
SELECT A.[Loan_Nbr],[FNMA Pre-Approve Flag],A.POR_EXCP_ID,POR_Flag,A.[Excp_ID],A.[Incurable Flag],A.[Exception_Type],A.[Recommended Servicer Loss Amount],A.[Recommended Servicer Loss Period Start Date],A.[Recommended Servicer Loss Period End Date],A.[Recommended Fannie Mae Loss Amount],A.[Recommended Fannie Mae Loss Period Start Date],A.[Recommended Fannie Mae Loss Period End Date],A.[TOTAL_CROSSOVER],A.[MAX_CLAIM_AMOUNT],A.[CURRENT_TOTAL_UPB],A.[Crossover_Date],A.[Min_Incur_Date]

FROM #Final2 A
INNER JOIN #FNMAFlag B
ON A.Loan_Nbr = B.[Loan Number]
WHERE RowFlag = 1 OR PORFlag = 1

ORDER BY A.POR_FLAG DESC,A.[Incurable Flag]





DROP TABLE #Incur_Scrub,#POR_SCRUB,#BASE,#UPB,#BASE2,#Final1,#Final2,#FNMAFlag