DECLARE @MonthYear AS DATE = '2019-10-01'
DECLARE @MonthYearInt AS INT = REPLACE(@MonthYear,'-','')
DECLARE @MonthEnd AS DATE = EOMONTH(@MonthYear)
DECLARE @MonthEndInt AS INT = REPLACE(@MonthEnd,'-','')

IF OBJECT_ID ('tempdb..##FNMA_ROLL_BASE') IS NOT NULL
	BEGIN
	DROP TABLE ##FNMA_ROLL_BASE
	END

SELECT B.*,B.[MCA_PERCENT] AS 'Beg_Month_MCA',
CASE WHEN B.[MCA_PERCENT] >= 100 THEN '>= 100'
	 WHEN B.[MCA_PERCENT] >= 98 THEN '>= 98'
	 ELSE '< 98'
	 END AS 'BOM_MCA_FLAG'
,B.[LOAN_STATUS] AS 'Beg_Month_Status',C.[MCA_PERCENT] AS 'End_Month_MCA',
CASE WHEN C.[MCA_PERCENT] >= 100 THEN '>= 100'
	 WHEN C.[MCA_PERCENT] >= 98 THEN '>= 98'
	 ELSE '< 98'
END AS 'EOM_MCA_FLAG'
,C.LOAN_STATUS AS 'End_Month_Status',ISNULL(HUD_STS_DESC,'Not Submitted') AS 'EOM_HUD_STS'
,CASE WHEN B.[MCA_PERCENT] < 98 AND C.[MCA_PERCENT] >= 98 AND D.HUD_STS_DESC IS NULL AND C.LOAN_STATUS ='Active'  THEN 'Y'
ELSE 'N'
END AS 'BuyOut_Flag'

INTO ##FNMA_ROLL_BASE
FROM tbl1 (@MonthYear,@MonthYearInt) B
LEFT JOIN tbl1 (@MonthEnd,@MonthEndInt) C
	ON B.LOAN_NBR = C.LOAN_NBR
LEFT JOIN (SELECT STS1.LOAN_NBR,STS1.HUD_STS_DESC FROM tbl5 STS1
			LEFT JOIN (SELECT LOAN_NBR,MAX(EFF_DTTM) AS 'EFF_DTTM' FROM tbl5 WHERE EFF_DTTM <= @MonthEnd GROUP BY LOAN_NBR) STS2
			ON STS2.LOAN_NBR = STS1.LOAN_NBR WHERE STS1.EFF_DTTM = STS2.EFF_DTTM AND STS1.HUD_STS_DESC IN ('HUD Approval',	'HUD Approved',	'Pkg Submitted to HUD',	'Preliminary Title Approved',	'Rebuttal to HUD',	'Resubmitted to HUD')) D
	ON B.LOAN_NBR = D.LOAN_NBR




WHERE isnull(B.[INVESTOR],'No Pool') = 'FNMA' AND B.MCA_PERCENT >= 97.5 AND B.[LOAN_STATUS] = 'Active'

SELECT * FROM ##FNMA_ROLL_BASE

--MCA Month--
SELECT tab1.Loan_Nbr,[Aug-19_MCA%],[Sept-19_MCA%],[Oct-19_MCA%],[Nov-19_MCA%],[Dec-19_MCA%],[Jan-20_MCA%],[FEB-20_MCA%],[MAR-20_MCA%],[APR-20_MCA%],[May-20_MCA%],[June-20_MCA%]
INTO ##FNMA_ARCHIVE
FROM tbl2 tab1
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'Aug-19_MCA%' FROM tbl1 ('2019-08-01',20190801)) Aug
	ON tab1.LOAN_NBR =Aug.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'Sept-19_MCA%' FROM tbl1 ('2019-09-01',20190901)) Sept
	ON tab1.LOAN_NBR = Sept.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'Oct-19_MCA%' FROM tbl1 ('2019-10-01',20191001)) OCT
	ON tab1.LOAN_NBR = OCT.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'Nov-19_MCA%' FROM tbl1 ('2019-11-01',20191101)) NOV
	ON tab1.LOAN_NBR = NOV.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'Dec-19_MCA%' FROM tbl1 ('2019-12-01',20191201)) DEC1
	ON tab1.LOAN_NBR = DEC1.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'Jan-20_MCA%' FROM tbl1 ('2020-01-01',20200101)) JAN
	ON tab1.LOAN_NBR = JAN.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'FEB-20_MCA%' FROM tbl1 ('2020-02-01',20200201)) FEB
	ON tab1.LOAN_NBR = FEB.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'MAR-20_MCA%' FROM tbl1 ('2020-03-01',20200301)) MAR
	ON tab1.LOAN_NBR = MAR.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'APR-20_MCA%' FROM tbl1 ('2020-04-01',20200401)) APR
	ON tab1.LOAN_NBR = APR.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'May-20_MCA%' FROM tbl1 ('2020-05-01',20200501)) MAY
	ON tab1.LOAN_NBR = MAY.LOAN_NBR
LEFT JOIN (SELECT LOAN_NBR,MCA_PERCENT AS 'June-20_MCA%' FROM tbl1 ('2020-06-01',20200601)) JUNE
	ON tab1.LOAN_NBR = JUNE.LOAN_NBR
WHERE isnull(tab1.[INVESTOR],'No Pool') = 'FNMA'
