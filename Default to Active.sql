DECLARE @BOM AS DATE = '2020-05-01'
DECLARE @EOM AS DATE = '2020-05-31'
DECLARE @BINT AS INT = REPLACE(@BOM,'-','')
DECLARE @EINT AS INT = REPLACE(@EOM,'-','')

--HUD ASSIGN SCRUB--
SELECT A.LOAN_NBR,[TAG_2_VAL],[INCRBL_FLG_DESC],[GRP_DESC]
INTO #BASE
FROM tbl1 A
INNER JOIN (SELECT LOAN_NBR, MAX(EFF_DTTM) AS 'MAX_DT' FROM tbl1 WHERE EFF_DTTM <= @EOM GROUP BY LOAN_NBR) B
ON A.LOAN_NBR = B.LOAN_NBR

WHERE A.EFF_DTTM = MAX_DT

--FINAL--

SELECT A.LOAN_NBR,A.MCA_PERCENT AS 'BOM_MCA',A.LOAN_STATUS AS 'BOM_STATUS',@BOM AS 'BOM',B.MCA_PERCENT AS 'EOM_MCA',B.LOAN_STATUS AS 'EOM_STATUS',@EOM AS 'EOM'
FROM tbl1 (@BOM,@BINT) A
LEFT JOIN 
	(SELECT LOAN_NBR,LOAN_STATUS,MCA_PERCENT FROM tbl1 (@EOM,@EINT) WHERE LOAN_STATUS IN ('Active','Liquidated/Assigned to HU')) B
	ON A.LOAN_NBR = B.LOAN_NBR 
LEFT JOIN #BASE C
	ON A.LOAN_NBR = C.LOAN_NBR
	
WHERE (A.LOAN_STATUS IN ('Default: Tax & Insurance w/repay plan',	'Called Due: Non-Occupancy',	'Called Due: Other',	'Default: HOA Dues',	'Default: Non-Occupancy',	'Called Due: HOA Dues',	'Default: Insurance',	'Default: Non-Completed Repairs',	'Default: Other',	'Default: Tax & Insurance',	'Refer for FCL: HOA Dues',	'Refer for FCL: Non-Occupancy',	'Refer for FCL: Other',	'Refer for FCL: Tax & Insurance',	'Called Due: Tax & Insurance')
 AND B.LOAN_STATUS IS NOT NULL
 AND (B.MCA_PERCENT >= 97.5 OR B.LOAN_STATUS = 'Liquidated/Assigned to HU') OR (A.MCA_PERCENT < 97.5 AND B.MCA_PERCENT >= 97.5 AND B.LOAN_STATUS IS NOT NULL)) 
 AND C.TAG_2_VAL IS NULL AND C.INCRBL_FLG_DESC = '0' AND ISNULL([GRP_DESC],'No Group') <> 'Grp 5 BofA GNMAs' AND A.LOAN_STATUS <> 'Active'

 DROP TABLE #BASE
