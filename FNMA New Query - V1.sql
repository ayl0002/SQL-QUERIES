--FNMA BASE--
SELECT tab1.*,[FNM_APRV_DTTM],[FNM_APRV_RQST_DTTM],[FNM_DND_DTTM],tab3.[HUD_STS_DESC],DATE_SUBMIT_TO_HUD,Claim_Filed
INTO #BASE
FROM Reverse_DW.[dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW] tab1
LEFT JOIN (SELECT Loan_Nbr,[FNM_APRV_DTTM],[FNM_APRV_RQST_DTTM],[FNM_DND_DTTM] FROM Reverse_DW.[dbo].[HUD_ASGN_HUD_STS] where curr_ind ='y') tab2
	ON tab1.loan_nbr = tab2.loan_nbr 
LEFT JOIN (SELECT Loan_Nbr,[HUD_STS_DESC] FROM Reverse_dw.[dbo].[HUD_ASGN_HUD_STS] where curr_ind = 'y'AND [HUD_STS_DESC] in ('Pkg Submitted to HUD','HUD Approval','Resubmitted to HUD','AOM Sent to HUD','HUD Approved')) tab3
	ON tab1.loan_nbr = tab3.loan_nbr
LEFT JOIN (SELECT LOAN_NBR,MAX([DT_SBMT_TO_HUD]) AS 'DATE_SUBMIT_TO_HUD'  FROM REVERSE_DW.[dbo].[HUD_ASSGN_DT_SBMT_RESBMT] GROUP BY LOAN_NBR) B
	ON CAST(tab1.LOAN_NBR AS VARCHAR) = CAST(B.LOAN_NBR AS VARCHAR)
LEFT JOIN (select loan_key, max([TXN_DT]) as 'Claim_Filed' from REVERSE_DW.[dbo].[LOAN_STS_EVT_TXN] where [OLD_LOAN_STS_CD] = '0' and [NEW_LOAN_STS_CD] = '72' group by loan_key) C
	ON tab1.loan_key = c.loan_key

WHERE isnull(tab1.[INVESTOR],'No Pool') = 'FNMA'  AND ((tab1.MCA_PERCENT >= 98 AND tab1.[LOAN_STATUS] = 'Active' --AND tab3.[HUD_STS_DESC] IS NOT NULL
) or 
(tab1.[LOAN_STATUS] LIKE ('%Liquidated/Assigned to HU%') AND tab2.[FNM_APRV_DTTM] IS NOT NULL))

--POR SCRUB--
SELECT A.*,B.Excp_ID AS 'POR_EXCP_ID',B.[DOC_DESC] AS 'POR_DOC_DESC',B.EXCP_STS_DESC AS 'POR_EXCP_STS_DESC',B.EFF_DTTM AS 'POR_EFF_DTTM',RN AS 'POR_RN'
INTO #BASE2
FROM #BASE A
LEFT JOIN (SELECT LOAN_NBR,SUB1.EXCP_ID,[DOC_DESC],EXCP_STS_DESC,SUB1.EFF_DTTM,ROW_NUMBER () OVER (Partition by SUB1.Loan_Nbr Order by SUB1.EXCP_ID) AS 'RN'  
					FROM REVERSE_DW.[dbo].[HUD_ASGN_EXCP_EDW] SUB1
					INNER JOIN (SELECT EXCP_ID,MAX(EFF_DTTM) AS 'EFF_DTTM' FROM REVERSE_DW.[dbo].[HUD_ASGN_EXCP_EDW] WHERE [DOC_DESC] = 'Proof of Repair' GROUP BY EXCP_ID) SUB2
					ON SUB1.EXCP_ID	 = SUB2.EXCP_ID	
					WHERE SUB1.EFF_DTTM = SUB2.EFF_DTTM) B
ON A.Loan_Nbr = B.Loan_Nbr
WHERE [RN] = 1 or RN is NULL
			
--INCURABLE SCRUB--
SELECT A.*,B.Excp_ID AS 'INCUR_EXCP_ID',B.[DOC_DESC] AS 'INCUR_DOC_DESC',B.EXCP_STS_DESC AS 'INCUR_EXCP_STS_DESC',B.EFF_DTTM AS 'INCUR_EFF_DTTM',RN AS 'INCUR_RN'
INTO #BASE3
FROM #BASE2 A
LEFT JOIN (SELECT LOAN_NBR,SUB1.EXCP_ID,[DOC_DESC],EXCP_STS_DESC,SUB1.EFF_DTTM,ROW_NUMBER () OVER (Partition by SUB1.Loan_Nbr Order by SUB1.EXCP_ID) AS 'RN'   
					FROM REVERSE_DW.[dbo].[HUD_ASGN_EXCP_EDW] SUB1
					INNER JOIN (SELECT EXCP_ID,MAX(EFF_DTTM) AS 'EFF_DTTM' FROM REVERSE_DW.[dbo].[HUD_ASGN_EXCP_EDW] WHERE [DOC_DESC] IN ('Loan Agreement','Orig Appraisal','Orig Loan App','HUD1') AND  [EXCP_STS_DESC] = 'Incurable' AND CAST(EFF_DTTM AS DATE) <= CAST('8/1/2019' AS DATE) GROUP BY EXCP_ID) SUB2
					ON SUB1.EXCP_ID	 = SUB2.EXCP_ID	
					WHERE SUB1.EFF_DTTM = SUB2.EFF_DTTM) B
ON A.Loan_Nbr = B.Loan_Nbr
WHERE [RN] = 1 or RN is NULL

--EXCEPTION SCRUB--
SELECT B.loan_nbr,B.Excp_ID,B.[DOC_DESC],B.EXCP_STS_DESC,B.EFF_DTTM,ROW_NUMBER () OVER (Partition by B.Loan_Nbr ORDER BY B.Excp_ID) AS 'EXCP COUNT'
INTO #EXCP
FROM #BASE3 A
LEFT JOIN REVERSE_DW.[dbo].[HUD_ASGN_EXCP_EDW] B
ON A.Loan_Nbr = B.Loan_Nbr
WHERE B.CURR_IND = 'Y' AND EXCP_STS_DESC IN ('Resolved')

--SET ANSI_WARNINGS OFF
CREATE TABLE #PreApproved
(Loan_Nbr INT,
Approved VarChar(MAX),
Batch VarChar(MAX),
Population VarChar(MAX))

INSERT INTO #PreApproved

VALUES
('2682009','Not Approved','Batch 2','Curative'),
('2740189','Not Approved','Batch 2','Curative'),
('2682112','Not Approved','Batch 2','Curative'),
('2797154','Not Approved','Batch 2','Curative'),
('2679867','Not Approved','Batch 2','Curative'),
('2682032','Not Approved','Batch 2','Curative'),
('316554','Not Approved','Batch 2','Curative'),
('2166468','Not Approved','Batch 2','Curative'),
('2754847','Not Approved','Batch 2','Curative'),
('2682076','Not Approved','Batch 2','Curative'),
('2675179','Not Approved','Batch 2','Curative'),
('2693672','Not Approved','Batch 2','Curative'),
('2752856','Not Approved','Batch 2','Curative'),
('2778468','Not Approved','Batch 2','Curative'),
('2693763','Not Approved','Batch 2','Curative'),
('2678183','Not Approved','Batch 2','Curative'),
('2681918','Not Approved','Batch 2','Curative'),
('2755611','Not Approved','Batch 2','Curative'),
('2691044','Not Approved','Batch 2','Curative'),
('2819537','Not Approved','Batch 2','Curative'),
('2686401','Not Approved','Batch 2','Curative'),
('2681941','Not Approved','Batch 2','Curative'),
('2679527','Not Approved','Batch 2','Curative'),
('2681020','Not Approved','Batch 2','Curative'),
('2792901','Not Approved','Batch 2','Curative'),
('2698449','Not Approved','Batch 2','Curative'),
('2687355','Not Approved','Batch 2','Curative'),
('2677160','Not Approved','Batch 2','Curative'),
('2783831','Not Approved','Batch 2','Curative'),
('2686172','Not Approved','Batch 2','Curative'),
('357988','Not Approved','Batch 2','Curative'),
('2683408','Not Approved','Batch 2','Curative'),
('403527','Not Approved','Batch 2','Curative'),
('2684181','Not Approved','Batch 2','Curative'),
('2755438','Not Approved','Batch 2','Curative'),
('2127233','Not Approved','Batch 2','Curative'),
('2683328','Not Approved','Batch 2','Curative'),
('2399971','Not Approved','Batch 2','Curative'),
('2676897','Not Approved','Batch 2','Curative'),
('2393726','Not Approved','Batch 2','Curative'),
('2707440','Not Approved','Batch 2','Curative'),
('2770654','Not Approved','Batch 2','Curative'),
('2680007','Not Approved','Batch 2','Curative'),
('2678786','Not Approved','Batch 2','Curative'),
('2845436','Not Approved','Batch 2','Curative'),
('2680848','Not Approved','Batch 2','Curative'),
('2681371','Not Approved','Batch 2','Curative'),
('2792353','Not Approved','Batch 2','Curative'),
('2681053','Not Approved','Batch 2','Curative'),
('2678296','Not Approved','Batch 2','Curative'),
('2796211','Not Approved','Batch 2','Curative'),
('2686445','Not Approved','Batch 2','Curative'),
('2164707','Not Approved','Batch 2','Curative'),
('2688210','Not Approved','Batch 2','Curative'),
('2677707','Not Approved','Batch 2','Curative'),
('2797109','Not Approved','Batch 2','Curative'),
('2791136','Not Approved','Batch 2','Curative'),
('2683431','Not Approved','Batch 2','Curative'),
('2682418','Not Approved','Batch 2','Curative'),
('386219','Not Approved','Batch 2','Curative'),
('2681714','Not Approved','Batch 2','Curative'),
('2806304','Not Approved','Batch 2','Curative'),
('2734205','Not Approved','Batch 2','Curative'),
('2687446','Not Approved','Batch 2','Curative'),
('2816204','Not Approved','Batch 2','Curative'),
('2798337','Not Approved','Batch 2','Curative'),
('2803016','Not Approved','Batch 2','Curative'),
('2203602','Not Approved','Batch 2','Curative'),
('2385839','Not Approved','Batch 2','Curative'),
('1152909','Not Approved','Batch 2','Curative'),
('2675340','Not Approved','Batch 2','Curative'),
('2786743','Not Approved','Batch 2','Curative'),
('2689222','Not Approved','Batch 2','Curative'),
('2767410','Not Approved','Batch 2','Curative'),
('2709066','Not Approved','Batch 2','Curative'),
('2759784','Not Approved','Batch 2','Curative'),
('2432084','Not Approved','Batch 2','Curative'),
('2715894','Not Approved','Batch 2','Curative'),
('2795107','Not Approved','Batch 2','Curative'),
('2754712','Not Approved','Batch 2','Curative'),
('2697541','Not Approved','Batch 2','Curative'),
('1029482','Not Approved','Batch 2','Curative'),
('2676227','Not Approved','Batch 2','Curative'),
('2774896','Not Approved','Batch 2','Curative'),
('2159777','Not Approved','Batch 2','Curative'),
('2788040','Not Approved','Batch 2','Curative'),
('2823997','Not Approved','Batch 2','Curative'),
('2794889','Not Approved','Batch 2','Curative'),
('2812994','Not Approved','Batch 2','Curative'),
('2695787','Not Approved','Batch 2','Curative'),
('2757327','Not Approved','Batch 2','Curative'),
('2680882','Not Approved','Batch 2','Curative'),
('2754391','Not Approved','Batch 2','Curative'),
('2776433','Not Approved','Batch 2','Curative'),
('2676591','Not Approved','Batch 2','Curative'),
('2747905','Not Approved','Batch 2','Curative'),
('2694070','Not Approved','Batch 2','Curative'),
('2697006','Not Approved','Batch 2','Curative'),
('2680416','Not Approved','Batch 2','Curative'),
('2804530','Not Approved','Batch 2','Curative'),
('2784002','Not Approved','Batch 2','Curative'),
('2776650','Not Approved','Batch 2','Curative'),
('2786231','Not Approved','Batch 2','Curative'),
('2704506','Not Approved','Batch 2','Curative'),
('2776752','Not Approved','Batch 2','Curative'),
('2784547','Not Approved','Batch 2','Curative'),
('2680110','Not Approved','Batch 2','Curative'),
('2118492','Not Approved','Batch 2','Curative'),
('2797508','Not Approved','Batch 2','Curative'),
('2689379','Not Approved','Batch 2','Curative'),
('2766829','Not Approved','Batch 2','Curative'),
('2709954','Not Approved','Batch 2','Curative'),
('2680176','Not Approved','Batch 2','Curative'),
('2784558','Not Approved','Batch 2','Curative'),
('2682269','Not Approved','Batch 2','Curative'),
('2848849','Not Approved','Batch 2','Curative'),
('2732953','Not Approved','Batch 2','Curative'),
('2808420','Not Approved','Batch 2','Curative'),
('2800104','Not Approved','Batch 2','Curative'),
('2731656','Not Approved','Batch 2','Curative'),
('2755655','Not Approved','Batch 2','Curative'),
('2720857','Not Approved','Batch 2','Curative'),
('2776228','Not Approved','Batch 2','Curative'),
('2795813','Not Approved','Batch 2','Curative'),
('1023888','Not Approved','Batch 2','Curative'),
('2717293','Not Approved','Batch 2','Curative'),
('2781010','Not Approved','Batch 2','Curative'),
('2685002','Not Approved','Batch 2','Curative'),
('2680096','Not Approved','Batch 2','Curative'),
('2791831','Not Approved','Batch 2','Curative'),
('2780280','Not Approved','Batch 2','Curative'),
('2785559','Not Approved','Batch 2','Curative'),
('2781533','Not Approved','Batch 2','Curative'),
('2756202','Not Approved','Batch 2','Curative'),
('2775502','Not Approved','Batch 2','Curative'),
('2781884','Not Approved','Batch 2','Curative'),
('1153052','Not Approved','Batch 2','Curative'),
('2703195','Not Approved','Batch 2','Curative'),
('2790011','Not Approved','Batch 2','Curative'),
('2746993','Not Approved','Batch 2','Curative'),
('2750763','Not Approved','Batch 2','Curative'),
('2739870','Not Approved','Batch 2','Curative'),
('2764484','Not Approved','Batch 2','Curative'),
('2762938','Not Approved','Batch 2','Curative'),
('2679754','Not Approved','Batch 2','Curative'),
('2731769','Not Approved','Batch 2','Curative'),
('2793811','Not Approved','Batch 2','Curative'),
('2760128','Not Approved','Batch 2','Curative'),
('2711765','Not Approved','Batch 2','Curative'),
('2861734','Not Approved','Batch 2','Curative'),
('2785924','Not Approved','Batch 2','Curative'),
('2859592','Not Approved','Batch 2','Curative'),
('2773134','Not Approved','Batch 2','Curative'),
('2866023','Not Approved','Batch 2','Curative'),
('2124775','Not Approved','Batch 2','Curative'),
('2707100','Not Approved','Batch 2','Curative'),
('2746185','Not Approved','Batch 2','Curative'),
('2771962','Not Approved','Batch 2','Curative'),
('2750057','Not Approved','Batch 2','Curative'),
('2776342','Not Approved','Batch 2','Curative'),
('2716679','Not Approved','Batch 2','Curative'),
('2276735','Not Approved','Batch 2','Curative'),
('2781496','Not Approved','Batch 2','Curative'),
('2777105','Not Approved','Batch 2','Curative'),
('2766000','Not Approved','Batch 2','Curative'),
('2824987','Not Approved','Batch 2','Curative'),
('2810958','Not Approved','Batch 2','Curative'),
('2707758','Not Approved','Batch 2','Curative'),
('2732485','Not Approved','Batch 2','Curative'),
('2267379','Not Approved','Batch 2','Curative'),
('2713186','Not Approved','Batch 2','Curative'),
('2759615','Not Approved','Batch 2','Curative'),
('2777467','Not Approved','Batch 2','Curative'),
('2773555','Not Approved','Batch 2','Curative'),
('2789483','Not Approved','Batch 2','Curative'),
('2822451','Not Approved','Batch 2','Curative'),
('2851311','Not Approved','Batch 2','Curative'),
('2771848','Not Approved','Batch 2','Curative'),
('2716076','Not Approved','Batch 2','Curative'),
('2813542','Not Approved','Batch 2','Curative'),
('2773407','Not Approved','Batch 2','Curative'),
('2704868','Not Approved','Batch 2','Curative'),
('2791535','Not Approved','Batch 2','Curative'),
('2676045','Not Approved','Batch 2','Curative'),
('2794173','Not Approved','Batch 2','Curative'),
('2772941','Not Approved','Batch 2','Curative'),
('2796870','Not Approved','Batch 2','Curative'),
('2769899','Not Approved','Batch 2','Curative'),
('2782909','Not Approved','Batch 2','Curative'),
('2785218','Not Approved','Batch 2','Curative'),
('2798031','Not Approved','Batch 2','Curative'),
('2795744','Not Approved','Batch 2','Curative'),
('2104839','Not Approved','Batch 2','Curative'),
('2798565','Not Approved','Batch 2','Curative'),
('2157866','Not Approved','Batch 2','Curative'),
('2167573','Not Approved','Batch 2','Curative'),
('2679787','Not Approved','Batch 2','Curative'),
('2681770','Not Approved','Batch 2','Curative'),
('2823054','Not Approved','Batch 2','Curative'),
('2684966','Not Approved','Batch 2','Curative'),
('2689574','Not Approved','Batch 2','Curative'),
('2115400','Not Approved','Batch 2','Curative'),
('1152787','Not Approved','Batch 2','Curative'),
('2706289','Not Approved','Batch 2','Curative'),
('2740975','Not Approved','Batch 2','Curative'),
('2716500','Not Approved','Batch 2','Curative'),
('2782885','Not Approved','Batch 2','Curative'),
('316455','Pre-Approved','Batch 2','Curative'),
('341693','Pre-Approved','Batch 2','Curative'),
('342162','Pre-Approved','Batch 2','Curative'),
('1012946','Pre-Approved','Batch 2','Curative'),
('1025241','Pre-Approved','Batch 2','Curative'),
('1150568','Pre-Approved','Batch 2','Curative'),
('1150735','Pre-Approved','Batch 2','Curative'),
('1151228','Pre-Approved','Batch 2','Curative'),
('1151510','Pre-Approved','Batch 2','Curative'),
('1151519','Pre-Approved','Batch 2','Curative'),
('1151655','Pre-Approved','Batch 2','Curative'),
('1152336','Pre-Approved','Batch 2','Curative'),
('1152684','Pre-Approved','Batch 2','Curative'),
('1152939','Pre-Approved','Batch 2','Curative'),
('1153022','Pre-Approved','Batch 2','Curative'),
('1153390','Pre-Approved','Batch 2','Curative'),
('1153426','Pre-Approved','Batch 2','Curative'),
('1153762','Pre-Approved','Batch 2','Curative'),
('1154404','Pre-Approved','Batch 2','Curative'),
('1154414','Pre-Approved','Batch 2','Curative'),
('1155214','Pre-Approved','Batch 2','Curative'),
('2101518','Pre-Approved','Batch 2','Curative'),
('2117402','Pre-Approved','Batch 2','Curative'),
('2127448','Pre-Approved','Batch 2','Curative'),
('2139545','Pre-Approved','Batch 2','Curative'),
('2163728','Pre-Approved','Batch 2','Curative'),
('2177860','Pre-Approved','Batch 2','Curative'),
('2215742','Pre-Approved','Batch 2','Curative'),
('2231376','Pre-Approved','Batch 2','Curative'),
('2241447','Pre-Approved','Batch 2','Curative'),
('2275095','Pre-Approved','Batch 2','Curative'),
('2279088','Pre-Approved','Batch 2','Curative'),
('2333266','Pre-Approved','Batch 2','Curative'),
('2675351','Pre-Approved','Batch 2','Curative'),
('2675362','Pre-Approved','Batch 2','Curative'),
('2675921','Pre-Approved','Batch 2','Curative'),
('2676090','Pre-Approved','Batch 2','Curative'),
('2676432','Pre-Approved','Batch 2','Curative'),
('2676615','Pre-Approved','Batch 2','Curative'),
('2676693','Pre-Approved','Batch 2','Curative'),
('2677295','Pre-Approved','Batch 2','Curative'),
('2677308','Pre-Approved','Batch 2','Curative'),
('2677729','Pre-Approved','Batch 2','Curative'),
('2677912','Pre-Approved','Batch 2','Curative'),
('2679333','Pre-Approved','Batch 2','Curative'),
('2680575','Pre-Approved','Batch 2','Curative'),
('2680600','Pre-Approved','Batch 2','Curative'),
('2680768','Pre-Approved','Batch 2','Curative'),
('2681075','Pre-Approved','Batch 2','Curative'),
('2681359','Pre-Approved','Batch 2','Curative'),
('2681440','Pre-Approved','Batch 2','Curative'),
('2681565','Pre-Approved','Batch 2','Curative'),
('2684535','Pre-Approved','Batch 2','Curative'),
('2685193','Pre-Approved','Batch 2','Curative'),
('2686899','Pre-Approved','Batch 2','Curative'),
('2694467','Pre-Approved','Batch 2','Curative'),
('2695969','Pre-Approved','Batch 2','Curative'),
('2696891','Pre-Approved','Batch 2','Curative'),
('2698007','Pre-Approved','Batch 2','Curative'),
('2698381','Pre-Approved','Batch 2','Curative'),
('2704209','Pre-Approved','Batch 2','Curative'),
('2704813','Pre-Approved','Batch 2','Curative'),
('2705949','Pre-Approved','Batch 2','Curative'),
('2706702','Pre-Approved','Batch 2','Curative'),
('2707703','Pre-Approved','Batch 2','Curative'),
('2709282','Pre-Approved','Batch 2','Curative'),
('2711538','Pre-Approved','Batch 2','Curative'),
('2716613','Pre-Approved','Batch 2','Curative'),
('2716920','Pre-Approved','Batch 2','Curative'),
('2716953','Pre-Approved','Batch 2','Curative'),
('2718853','Pre-Approved','Batch 2','Curative'),
('2719240','Pre-Approved','Batch 2','Curative'),
('2723805','Pre-Approved','Batch 2','Curative'),
('2726089','Pre-Approved','Batch 2','Curative'),
('2726363','Pre-Approved','Batch 2','Curative'),
('2727273','Pre-Approved','Batch 2','Curative'),
('2727284','Pre-Approved','Batch 2','Curative'),
('2735923','Pre-Approved','Batch 2','Curative'),
('2736003','Pre-Approved','Batch 2','Curative'),
('2739529','Pre-Approved','Batch 2','Curative'),
('2740383','Pre-Approved','Batch 2','Curative'),
('2740602','Pre-Approved','Batch 2','Curative'),
('2747062','Pre-Approved','Batch 2','Curative'),
('2751047','Pre-Approved','Batch 2','Curative'),
('2753948','Pre-Approved','Batch 2','Curative'),
('2753959','Pre-Approved','Batch 2','Curative'),
('2755597','Pre-Approved','Batch 2','Curative'),
('2755940','Pre-Approved','Batch 2','Curative'),
('2756348','Pre-Approved','Batch 2','Curative'),
('2758501','Pre-Approved','Batch 2','Curative'),
('2759067','Pre-Approved','Batch 2','Curative'),
('2761390','Pre-Approved','Batch 2','Curative'),
('2765511','Pre-Approved','Batch 2','Curative'),
('2766749','Pre-Approved','Batch 2','Curative'),
('2767875','Pre-Approved','Batch 2','Curative'),
('2769296','Pre-Approved','Batch 2','Curative'),
('2769797','Pre-Approved','Batch 2','Curative'),
('2771860','Pre-Approved','Batch 2','Curative'),
('2772714','Pre-Approved','Batch 2','Curative'),
('2774408','Pre-Approved','Batch 2','Curative'),
('2774909','Pre-Approved','Batch 2','Curative'),
('2775933','Pre-Approved','Batch 2','Curative'),
('2776865','Pre-Approved','Batch 2','Curative'),
('2778549','Pre-Approved','Batch 2','Curative'),
('2779265','Pre-Approved','Batch 2','Curative'),
('2779573','Pre-Approved','Batch 2','Curative'),
('2781076','Pre-Approved','Batch 2','Curative'),
('2782830','Pre-Approved','Batch 2','Curative'),
('2783078','Pre-Approved','Batch 2','Curative'),
('2783158','Pre-Approved','Batch 2','Curative'),
('2784160','Pre-Approved','Batch 2','Curative'),
('2785194','Pre-Approved','Batch 2','Curative'),
('2785957','Pre-Approved','Batch 2','Curative'),
('2786151','Pre-Approved','Batch 2','Curative'),
('2786195','Pre-Approved','Batch 2','Curative'),
('2787620','Pre-Approved','Batch 2','Curative'),
('2788095','Pre-Approved','Batch 2','Curative'),
('2788142','Pre-Approved','Batch 2','Curative'),
('2795824','Pre-Approved','Batch 2','Curative'),
('2802812','Pre-Approved','Batch 2','Curative'),
('2806086','Pre-Approved','Batch 2','Curative'),
('2807145','Pre-Approved','Batch 2','Curative'),
('2812006','Pre-Approved','Batch 2','Curative'),
('2813063','Pre-Approved','Batch 2','Curative'),
('2829390','Pre-Approved','Batch 2','Curative'),
('2839780','Pre-Approved','Batch 2','Curative'),
('2842182','Pre-Approved','Batch 2','Curative'),
('2843149','Pre-Approved','Batch 2','Curative'),
('2701273','Not Approved','Batch 2','POR'),
('2780144','Not Approved','Batch 2','POR'),
('2685536','Not Approved','Batch 2','POR'),
('2729527','Not Approved','Batch 2','POR'),
('2703479','Not Approved','Batch 2','POR'),
('1016955','Not Approved','Batch 2','POR'),
('1006773','Not Approved','Batch 2','POR'),
('2695618','Not Approved','Batch 2','POR'),
('2750638','Not Approved','Batch 2','POR'),
('2695195','Not Approved','Batch 2','POR'),
('2705596','Not Approved','Batch 2','POR'),
('1006244','Not Approved','Batch 2','POR'),
('2800364','Not Approved','Batch 2','POR'),
('2726682','Not Approved','Batch 2','POR'),
('2757964','Not Approved','Batch 2','POR'),
('2851479','Not Approved','Batch 2','POR'),
('2732292','Not Approved','Batch 2','POR'),
('2689858','Not Approved','Batch 2','POR'),
('2766636','Not Approved','Batch 2','POR'),
('1004520','Not Approved','Batch 2','POR'),
('2705814','Not Approved','Batch 2','POR'),
('2706369','Not Approved','Batch 2','POR'),
('2728183','Not Approved','Batch 2','POR'),
('2762379','Not Approved','Batch 2','POR'),
('2272811','Not Approved','Batch 2','POR'),
('2758419','Not Approved','Batch 2','POR'),
('2765782','Not Approved','Batch 2','POR'),
('2734773','Not Approved','Batch 2','POR'),
('2773817','Not Approved','Batch 2','POR'),
('2725124','Not Approved','Batch 2','POR'),
('1000925','Not Approved','Batch 2','POR'),
('1004139','Not Approved','Batch 2','POR'),
('2779891','Not Approved','Batch 2','POR'),
('2759728','Not Approved','Batch 2','POR'),
('2214898','Not Approved','Batch 2','POR'),
('2790362','Not Approved','Batch 2','POR'),
('2695491','Not Approved','Batch 2','POR'),
('1015420','Not Approved','Batch 2','POR'),
('2782783','Not Approved','Batch 2','POR'),
('2700181','Not Approved','Batch 2','POR'),
('1012636','Not Approved','Batch 2','POR'),
('2795993','Not Approved','Batch 2','POR'),
('2238420','Not Approved','Batch 2','POR'),
('1010320','Pre-Approved','Batch 2','POR'),
('1011730','Pre-Approved','Batch 2','POR'),
('1012640','Pre-Approved','Batch 2','POR'),
('1017043','Pre-Approved','Batch 2','POR'),
('1024984','Pre-Approved','Batch 2','POR'),
('1154756','Pre-Approved','Batch 2','POR'),
('2312409','Pre-Approved','Batch 2','POR'),
('2316904','Pre-Approved','Batch 2','POR'),
('2428669','Pre-Approved','Batch 2','POR'),
('2676933','Pre-Approved','Batch 2','POR'),
('2689723','Pre-Approved','Batch 2','POR'),
('2689949','Pre-Approved','Batch 2','POR'),
('2692170','Pre-Approved','Batch 2','POR'),
('2693035','Pre-Approved','Batch 2','POR'),
('2693193','Pre-Approved','Batch 2','POR'),
('2698520','Pre-Approved','Batch 2','POR'),
('2700034','Pre-Approved','Batch 2','POR'),
('2707177','Pre-Approved','Batch 2','POR'),
('2708418','Pre-Approved','Batch 2','POR'),
('2715996','Pre-Approved','Batch 2','POR'),
('2718580','Pre-Approved','Batch 2','POR'),
('2720049','Pre-Approved','Batch 2','POR'),
('2726261','Pre-Approved','Batch 2','POR'),
('2729709','Pre-Approved','Batch 2','POR'),
('2729925','Pre-Approved','Batch 2','POR'),
('2730336','Pre-Approved','Batch 2','POR'),
('2731246','Pre-Approved','Batch 2','POR'),
('2731736','Pre-Approved','Batch 2','POR'),
('2732635','Pre-Approved','Batch 2','POR'),
('2736504','Pre-Approved','Batch 2','POR'),
('2742067','Pre-Approved','Batch 2','POR'),
('2749428','Pre-Approved','Batch 2','POR'),
('2752106','Pre-Approved','Batch 2','POR'),
('2752413','Pre-Approved','Batch 2','POR'),
('2759136','Pre-Approved','Batch 2','POR'),
('2762530','Pre-Approved','Batch 2','POR'),
('2777899','Pre-Approved','Batch 2','POR'),
('2783853','Pre-Approved','Batch 2','POR'),
('2805508','Pre-Approved','Batch 2','POR'),
('2775067','Not Approved','Batch 1','Curative'),
('2814360','Not Approved','Batch 1','Curative'),
('2787005','Not Approved','Batch 1','Curative'),
('2762200','Not Approved','Batch 1','Curative'),
('2756792','Not Approved','Batch 1','Curative'),
('2734693','Not Approved','Batch 1','Curative'),
('2775023','Not Approved','Batch 1','Curative'),
('2817502','Not Approved','Batch 1','Curative'),
('2809089','Not Approved','Batch 1','Curative'),
('2811824','Not Approved','Batch 1','Curative'),
('2785401','Not Approved','Batch 1','Curative'),
('2132855','Not Approved','Batch 1','Curative'),
('2786457','Not Approved','Batch 1','Curative'),
('2693239','Not Approved','Batch 1','Curative'),
('2743364','Not Approved','Batch 1','Curative'),
('2786801','Not Approved','Batch 1','Curative'),
('2258755','Not Approved','Batch 1','Curative'),
('2780781','Not Approved','Batch 1','Curative'),
('2770687','Not Approved','Batch 1','Curative'),
('2755256','Not Approved','Batch 1','Curative'),
('2699199','Not Approved','Batch 1','Curative'),
('2851162','Not Approved','Batch 1','Curative'),
('2820448','Not Approved','Batch 1','Curative'),
('2747335','Not Approved','Batch 1','Curative'),
('2770380','Not Approved','Batch 1','Curative'),
('2230638','Not Approved','Batch 1','Curative'),
('2444408','Not Approved','Batch 1','Curative'),
('2767227','Not Approved','Batch 1','Curative'),
('2809465','Not Approved','Batch 1','Curative'),
('2787824','Not Approved','Batch 1','Curative'),
('2792217','Not Approved','Batch 1','Curative'),
('2775648','Not Approved','Batch 1','Curative'),
('2112715','Not Approved','Batch 1','Curative'),
('2752947','Not Approved','Batch 1','Curative'),
('2796415','Not Approved','Batch 1','Curative'),
('2744731','Not Approved','Batch 1','Curative'),
('2788222','Not Approved','Batch 1','Curative'),
('1009961','Not Approved','Batch 1','Curative'),
('2763314','Not Approved','Batch 1','Curative'),
('2782841','Not Approved','Batch 1','Curative'),
('2783012','Not Approved','Batch 1','Curative'),
('2835376','Not Approved','Batch 1','Curative'),
('2779528','Not Approved','Batch 1','Curative'),
('1153352','Not Approved','Batch 1','Curative'),
('2778663','Not Approved','Batch 1','Curative'),
('2169223','Not Approved','Batch 1','Curative'),
('2858580','Not Approved','Batch 1','Curative'),
('2792455','Not Approved','Batch 1','Curative'),
('2779880','Not Approved','Batch 1','Curative'),
('2832420','Not Approved','Batch 1','Curative'),
('2742900','Not Approved','Batch 1','Curative'),
('2176197','Not Approved','Batch 1','Curative'),
('2795185','Not Approved','Batch 1','Curative'),
('1154476','Not Approved','Batch 1','Curative'),
('2758738','Not Approved','Batch 1','Curative'),
('2806473','Not Approved','Batch 1','Curative'),
('2788927','Not Approved','Batch 1','Curative'),
('2787027','Not Approved','Batch 1','Curative'),
('2104555','Not Approved','Batch 1','Curative'),
('2789791','Not Approved','Batch 1','Curative'),
('2856167','Pre-Approved','Batch 1','Curative'),
('2752093','Pre-Approved','Batch 1','Curative'),
('2259552','Pre-Approved','Batch 1','Curative'),
('2836812','Pre-Approved','Batch 1','Curative'),
('2777866','Pre-Approved','Batch 1','Curative'),
('2777888','Pre-Approved','Batch 1','Curative'),
('2179305','Pre-Approved','Batch 1','Curative'),
('2799964','Pre-Approved','Batch 1','Curative'),
('2148977','Pre-Approved','Batch 1','Curative'),
('2790339','Pre-Approved','Batch 1','Curative'),
('2760685','Pre-Approved','Batch 1','Curative'),
('2714757','Pre-Approved','Batch 1','Curative'),
('2860835','Pre-Approved','Batch 1','Curative'),
('2111587','Pre-Approved','Batch 1','Curative'),
('2802413','Pre-Approved','Batch 1','Curative'),
('2711947','Pre-Approved','Batch 1','Curative'),
('2770972','Pre-Approved','Batch 1','Curative'),
('2860700','Pre-Approved','Batch 1','Curative'),
('2786823','Pre-Approved','Batch 1','Curative'),
('2782670','Pre-Approved','Batch 1','Curative'),
('2712390','Pre-Approved','Batch 1','Curative'),
('2823884','Pre-Approved','Batch 1','Curative'),
('2807931','Pre-Approved','Batch 1','Curative'),
('2759498','Pre-Approved','Batch 1','Curative'),
('2797007','Pre-Approved','Batch 1','Curative'),
('2727581','Pre-Approved','Batch 1','Curative'),
('2782351','Pre-Approved','Batch 1','Curative'),
('2793560','Pre-Approved','Batch 1','Curative'),
('2775012','Pre-Approved','Batch 1','Curative'),
('2827230','Pre-Approved','Batch 1','Curative'),
('2794765','Pre-Approved','Batch 1','Curative'),
('2821542','Pre-Approved','Batch 1','Curative'),
('2743854','Pre-Approved','Batch 1','Curative'),
('2794311','Pre-Approved','Batch 1','Curative'),
('2118675','Pre-Approved','Batch 1','Curative'),
('2167345','Pre-Approved','Batch 1','Curative'),
('2150632','Pre-Approved','Batch 1','Curative'),
('2813677','Pre-Approved','Batch 1','Curative'),
('2684740','Pre-Approved','Batch 1','Curative'),
('2373631','Pre-Approved','Batch 1','Curative'),
('2747529','Pre-Approved','Batch 1','Curative'),
('2772849','Pre-Approved','Batch 1','Curative'),
('2758260','Pre-Approved','Batch 1','Curative'),
('2858352','Pre-Approved','Batch 1','Curative'),
('2792956','Pre-Approved','Batch 1','Curative'),
('2757577','Pre-Approved','Batch 1','Curative'),
('2852118','Pre-Approved','Batch 1','Curative'),
('2791181','Pre-Approved','Batch 1','Curative'),
('2787766','Pre-Approved','Batch 1','Curative'),
('2679173','Pre-Approved','Batch 1','Curative'),
('2157800','Pre-Approved','Batch 1','Curative'),
('2758910','Pre-Approved','Batch 1','Curative'),
('2698074','Pre-Approved','Batch 1','Curative'),
('2775078','Pre-Approved','Batch 1','Curative'),
('2830348','Pre-Approved','Batch 1','Curative'),
('2788734','Pre-Approved','Batch 1','Curative'),
('2862110','Pre-Approved','Batch 1','Curative'),
('2780075','Pre-Approved','Batch 1','Curative'),
('2769150','Pre-Approved','Batch 1','Curative'),
('2788950','Pre-Approved','Batch 1','Curative'),
('2775410','Pre-Approved','Batch 1','Curative'),
('2750503','Pre-Approved','Batch 1','Curative'),
('2787686','Pre-Approved','Batch 1','Curative'),
('2829403','Pre-Approved','Batch 1','Curative'),
('2763096','Pre-Approved','Batch 1','Curative'),
('2129667','Pre-Approved','Batch 1','Curative'),
('2681064','Pre-Approved','Batch 1','Curative'),
('2116161','Pre-Approved','Batch 1','Curative'),
('2804949','Pre-Approved','Batch 1','Curative'),
('2795458','Pre-Approved','Batch 1','Curative'),
('2768592','Pre-Approved','Batch 1','Curative'),
('2792785','Pre-Approved','Batch 1','Curative'),
('2802297','Pre-Approved','Batch 1','Curative'),
('2847837','Pre-Approved','Batch 1','Curative'),
('2780985','Pre-Approved','Batch 1','Curative'),
('2785935','Pre-Approved','Batch 1','Curative'),
('2723827','Pre-Approved','Batch 1','Curative'),
('2677796','Pre-Approved','Batch 1','Curative'),
('2754404','Pre-Approved','Batch 1','Curative'),
('2766475','Pre-Approved','Batch 1','Curative'),
('2787152','Pre-Approved','Batch 1','Curative'),
('2764587','Pre-Approved','Batch 1','Curative'),
('2754028','Pre-Approved','Batch 1','Curative'),
('2824658','Pre-Approved','Batch 1','Curative'),
('2820552','Pre-Approved','Batch 1','Curative'),
('2788346','Pre-Approved','Batch 1','Curative'),
('2762665','Pre-Approved','Batch 1','Curative'),
('1154409','Pre-Approved','Batch 1','Curative'),
('2147807','Pre-Approved','Batch 1','Curative'),
('2788277','Pre-Approved','Batch 1','Curative'),
('2808841','Pre-Approved','Batch 1','Curative'),
('2685444','Pre-Approved','Batch 1','Curative'),
('2715246','Pre-Approved','Batch 1','Curative'),
('2770379','Pre-Approved','Batch 1','Curative'),
('2725567','Pre-Approved','Batch 1','Curative'),
('2806417','Pre-Approved','Batch 1','Curative'),
('2156228','Pre-Approved','Batch 1','Curative'),
('2776397','Pre-Approved','Batch 1','Curative'),
('2794550','Pre-Approved','Batch 1','Curative'),
('2683965','Pre-Approved','Batch 1','Curative'),
('2701843','Pre-Approved','Batch 1','Curative'),
('2139818','Pre-Approved','Batch 1','Curative'),
('2781236','Pre-Approved','Batch 1','Curative'),
('2861062','Pre-Approved','Batch 1','Curative'),
('2754448','Pre-Approved','Batch 1','Curative'),
('2755405','Pre-Approved','Batch 1','Curative'),
('2849544','Pre-Approved','Batch 1','Curative'),
('2796869','Pre-Approved','Batch 1','Curative'),
('2721266','Pre-Approved','Batch 1','Curative'),
('2836059','Pre-Approved','Batch 1','Curative'),
('2757975','Pre-Approved','Batch 1','Curative'),
('2755860','Pre-Approved','Batch 1','Curative'),
('2780337','Pre-Approved','Batch 1','Curative'),
('2756543','Pre-Approved','Batch 1','Curative'),
('2243655','Pre-Approved','Batch 1','Curative'),
('2853563','Pre-Approved','Batch 1','Curative'),
('2791409','Pre-Approved','Batch 1','Curative'),
('2147738','Pre-Approved','Batch 1','Curative'),
('2798907','Pre-Approved','Batch 1','Curative'),
('2776148','Pre-Approved','Batch 1','Curative'),
('2780612','Pre-Approved','Batch 1','Curative'),
('2728537','Pre-Approved','Batch 1','Curative'),
('2778311','Pre-Approved','Batch 1','Curative'),
('2775922','Pre-Approved','Batch 1','Curative'),
('2816705','Pre-Approved','Batch 1','Curative'),
('2811312','Pre-Approved','Batch 1','Curative'),
('2713541','Pre-Approved','Batch 1','Curative'),
('2755768','Pre-Approved','Batch 1','Curative'),
('2780348','Pre-Approved','Batch 1','Curative'),
('2158093','Pre-Approved','Batch 1','Curative'),
('2806406','Pre-Approved','Batch 1','Curative'),
('2723097','Pre-Approved','Batch 1','Curative'),
('2764337','Pre-Approved','Batch 1','Curative'),
('2787038','Pre-Approved','Batch 1','Curative'),
('2785606','Pre-Approved','Batch 1','Curative'),
('2800091','Pre-Approved','Batch 1','Curative'),
('2842115','Pre-Approved','Batch 1','Curative'),
('2776137','Pre-Approved','Batch 1','Curative'),
('2768912','Pre-Approved','Batch 1','Curative'),
('2782965','Pre-Approved','Batch 1','Curative'),
('2782340','Pre-Approved','Batch 1','Curative'),
('2764872','Pre-Approved','Batch 1','Curative'),
('2743832','Pre-Approved','Batch 1','Curative'),
('2812869','Pre-Approved','Batch 1','Curative'),
('2768239','Pre-Approved','Batch 1','Curative'),
('1150107','Pre-Approved','Batch 1','Curative'),
('2713368','Pre-Approved','Batch 1','Curative'),
('2796448','Pre-Approved','Batch 1','Curative'),
('2791170','Pre-Approved','Batch 1','Curative'),
('2676181','Pre-Approved','Batch 1','Curative'),
('2777775','Pre-Approved','Batch 1','Curative'),
('2840124','Pre-Approved','Batch 1','Curative'),
('2758475','Pre-Approved','Batch 1','Curative'),
('2104646','Pre-Approved','Batch 1','Curative'),
('2767933','Pre-Approved','Batch 1','Curative'),
('2865373','Pre-Approved','Batch 1','Curative'),
('2753130','Pre-Approved','Batch 1','Curative'),
('2788803','Pre-Approved','Batch 1','Curative'),
('2746824','Pre-Approved','Batch 1','Curative'),
('2195076','Pre-Approved','Batch 1','Curative'),
('2743080','Pre-Approved','Batch 1','Curative'),
('2730290','Pre-Approved','Batch 1','Curative'),
('2732862','Pre-Approved','Batch 1','Curative'),
('2770391','Pre-Approved','Batch 1','Curative'),
('2780758','Pre-Approved','Batch 1','Curative'),
('2804448','Pre-Approved','Batch 1','Curative'),
('2800444','Pre-Approved','Batch 1','Curative'),
('2867386','Pre-Approved','Batch 1','Curative'),
('2796222','Pre-Approved','Batch 1','Curative'),
('1154967','Pre-Approved','Batch 1','Curative'),
('2222694','Pre-Approved','Batch 1','Curative'),
('2755187','Pre-Approved','Batch 1','Curative'),
('1153587','Pre-Approved','Batch 1','Curative'),
('2157230','Pre-Approved','Batch 1','Curative'),
('2813779','Pre-Approved','Batch 1','Curative'),
('2127927','Pre-Approved','Batch 1','Curative'),
('2757372','Pre-Approved','Batch 1','Curative'),
('2786516','Pre-Approved','Batch 1','Curative'),
('2170088','Pre-Approved','Batch 1','Curative'),
('2770119','Pre-Approved','Batch 1','Curative'),
('2756667','Pre-Approved','Batch 1','Curative'),
('2777478','Pre-Approved','Batch 1','Curative'),
('2213682','Pre-Approved','Batch 1','Curative'),
('2704835','Pre-Approved','Batch 1','Curative'),
('2694639','Pre-Approved','Batch 1','Curative'),
('2689153','Pre-Approved','Batch 1','Curative'),
('2814177','Pre-Approved','Batch 1','Curative'),
('2779287','Pre-Approved','Batch 1','Curative'),
('2764941','Pre-Approved','Batch 1','Curative'),
('2769138','Pre-Approved','Batch 1','Curative'),
('2791352','Pre-Approved','Batch 1','Curative'),
('2802823','Pre-Approved','Batch 1','Curative'),
('2763893','Pre-Approved','Batch 1','Curative'),
('2771995','Pre-Approved','Batch 1','Curative'),
('2810140','Pre-Approved','Batch 1','Curative'),
('2840987','Pre-Approved','Batch 1','Curative'),
('2195167','Pre-Approved','Batch 1','Curative'),
('2236428','Pre-Approved','Batch 1','Curative'),
('2796916','Pre-Approved','Batch 1','Curative'),
('2778936','Pre-Approved','Batch 1','Curative'),
('2236929','Pre-Approved','Batch 1','Curative'),
('2782022','Pre-Approved','Batch 1','Curative'),
('2170102','Pre-Approved','Batch 1','Curative'),
('2715166','Pre-Approved','Batch 1','Curative'),
('2777241','Pre-Approved','Batch 1','Curative'),
('2779835','Pre-Approved','Batch 1','Curative'),
('2765599','Pre-Approved','Batch 1','Curative'),
('2782976','Pre-Approved','Batch 1','Curative'),
('2758453','Pre-Approved','Batch 1','Curative'),
('2846790','Pre-Approved','Batch 1','Curative'),
('2757225','Pre-Approved','Batch 1','Curative')

SELECT * FROM #PreApproved

SELECT A.LOAN_NBR,	A.FHA_CASE_NBR,	A.INVESTOR_LOAN_NBR,	A.STATUS_CODE,	A.STATUS_DESCRIPTION,	A.INVESTOR,	A.MAX_CLAIM_AMOUNT,	A.MCA_PERCENT,	A.MCA_CLAIM_DT,	A.MCA_SUBMIT_DT,	A.MCA_PREP_DT,	A.LOAN_STATUS_CATEGORY,	A.LOAN_STATUS,	A.POOL_NAME,	A.MCA_CROSSOVER_DT,	A.PROJECTED_MCA_PREP_DT,	A.PROJECTED_MCA_CLAIM_DT,	A.PROJECTED_MCA_CROSSOVER_DT,	A.FNM_APRV_DTTM,	A.FNM_APRV_RQST_DTTM,	A.FNM_DND_DTTM,	A.HUD_STS_DESC,	A.DATE_SUBMIT_TO_HUD,	A.POR_EXCP_ID,	A.POR_DOC_DESC,	A.POR_EXCP_STS_DESC,	A.POR_EFF_DTTM,	A.INCUR_EXCP_ID,	A.INCUR_DOC_DESC,	A.INCUR_EXCP_STS_DESC,	A.INCUR_EFF_DTTM,B.EXCP_COUNT,POR_COUNT,INCUR_COUNT,ISNULL(C.Approved,'NA') AS 'Pre-Approval Status',ISNULL(C.BATCH,'NA') AS 'Pre-Approval Batch',ISNULL(C.Population,'NA') AS 'Pre-Approval Pop' 
INTO ##NEW_FNMA_BASE
FROM #BASE3 A
LEFT JOIN (SELECT Loan_Nbr,MAX([EXCP COUNT]) AS 'EXCP_COUNT' FROM #EXCP GROUP BY Loan_Nbr) B
	ON A.Loan_Nbr = B.Loan_Nbr
LEFT JOIN #PreApproved C
	ON A.LOAN_NBR = C.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MAX(POR_RN) AS 'POR_COUNT' FROM #BASE3 GROUP BY LOAN_NBR) D
	ON A.LOAN_NBR = D.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MAX(INCUR_RN) AS 'INCUR_COUNT' FROM #BASE3 GROUP BY LOAN_NBR) E
	ON A.LOAN_NBR = E.LOAN_NBR

SELECT * INTO ##NEW_FNMA_BASE_EXCP FROM #EXCP

		
DROP TABLE #BASE,#BASE2,#BASE3,#EXCP,#PreApproved


	