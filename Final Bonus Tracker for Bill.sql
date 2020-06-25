use reverse_dw
--- JULY POP 

select final2.*, case when mca_percent < 97.5 and [Next Month MCA] >= 97.5 then 'Y' else 'N' end as 'Will Roll to Assignable' into  ##julypop from 
(select final.*, round([Accrual]/current_total_upb,3) + mca_percent as 'Next Month MCA' from
(select base.*, hld.[Tag_2_Val], [Group], [Incurable Flag],ROUND(CURRENT_TOTAL_UPB * CURRENT_INTEREST_RATE /12,2)+ROUND(CURRENT_TOTAL_UPB * MIP_RATE /12,2)+[MTH_SRVC_FEE_AMT]  as 'Accrual' --
 from
(select loan_nbr, loan_key, mca_percent, mip_rate, pool_name, status_code, current_total_upb, current_interest_rate,  case 
when mca_percent < 91 then '90-90.99'
when mca_percent < 92 then '91-91.99'
when mca_percent < 95 then 'Segment 1'
when mca_percent < 97 then 'Segment 2'
when mca_percent < 97.5 then 'Segment 2B'
when mca_percent < 100 then 'Segment 3A'
else 'Segment 3B' end as MCA_Bucket, prop_state, [PROP_ZIP_CODE] as 'Zip_Code'
 from [dbo].[RM_CHAMPION_MASTER_TBL_VW]('2020-03-31',20200331) where 
status_code = 0 and mca_percent >= 89 and mip_rate > 0 and

pool_name not in ('BOAHOLDOVER','BOAWarehouse','NSBOA Warehouse','NSBOAWarehouse')) base
 left join
   
(select loan_key, [MTH_SRVC_FEE_AMT] from [dbo].[RVRS_LOAN_BAL] where curr_ind = 'Y') msv on base.loan_key=msv.loan_key 

left join
(select a.[Loan Number], b.[group], b.[Tag_2_Val], b.[Incurable Flag] from
(select [Loan Number], max(eff_dttm) as 'Effective Date' from rm_dmart01.dbo.dm_hud_dim(nolock)
where eff_dttm < '2020-04-01'
 group by [Loan Number]) a
left join
(select [Loan Number], eff_dttm, [Group] ,[HUD Assigned Loans Tag2] as [TAG_2_VAL]
                           ,[Incurable Flag] 
                     from RM_DMART01.dbo.dm_hud_dim(nolock)) b on a.[Loan Number]=b.[Loan Number] and a.[Effective Date]=b.eff_dttm ) hld on cast(base.loan_nbr as varchar)=hld.[loan number]) final ) final2
					  where (final2.tag_2_val not in ('HOLD', 'Servicer Cure', 'Finance HOLD', 'FNMA Finance Hold') or final2.tag_2_val is null)  and (final2.[group] <> 'Grp 5 BofA GNMAs' or final2.[group] is null) and [incurable flag] not in ('1.00000000000000', '2.00000000000000', '3.00000000000000', '4.00000000000000', '5.00000000000000','6.00000000000000', '7.00000000000000') 

-------------------------- Georgia and Shawn Pop
select final2.*, case when mca_percent < 97.5 and [Next Month MCA] >= 97.5 then 'Y' else 'N' end as 'Will Roll to Assignable' into  ##julypop2 from 
(select final.*, round([Accrual]/current_total_upb,3) + mca_percent as 'Next Month MCA' from
(select base.*, hld.[Tag_2_Val], [Group], [Incurable Flag],ROUND(CURRENT_TOTAL_UPB * CURRENT_INTEREST_RATE /12,2)+ROUND(CURRENT_TOTAL_UPB * MIP_RATE /12,2)+[MTH_SRVC_FEE_AMT]  as 'Accrual' --
 from
(select loan_nbr, loan_key, mca_percent, mip_rate, pool_name, status_code, current_total_upb, current_interest_rate,  case 
when mca_percent < 91 then '90-90.99'
when mca_percent < 92 then '91-91.99'
when mca_percent < 95 then 'Segment 1'
when mca_percent < 97 then 'Segment 2'
when mca_percent < 97.5 then 'Segment 2B'
when mca_percent < 100 then 'Segment 3A'
else 'Segment 3B' end as MCA_Bucket, prop_state, [PROP_ZIP_CODE] as 'Zip_Code'
 from [dbo].[RM_CHAMPION_MASTER_TBL_VW]('2020-03-31',20200331) where 
status_code = 0 and mca_percent between 89 and 96.99 and mip_rate > 0 and

pool_name not in ('BOAHOLDOVER','BOAWarehouse','NSBOA Warehouse','NSBOAWarehouse')) base
 left join
   
(select loan_key, [MTH_SRVC_FEE_AMT] from [dbo].[RVRS_LOAN_BAL] where curr_ind = 'Y') msv on base.loan_key=msv.loan_key 

left join
(select a.[Loan Number], b.[group], b.[Tag_2_Val], b.[Incurable Flag] from
(select [Loan Number], max(eff_dttm) as 'Effective Date' from rm_dmart01.dbo.dm_hud_dim(nolock)
where eff_dttm < '2020-04-01'
 group by [Loan Number]) a
left join
(select [Loan Number], eff_dttm, [Group] ,[HUD Assigned Loans Tag2] as [TAG_2_VAL]
                           ,[Incurable Flag] 
                     from RM_DMART01.dbo.dm_hud_dim(nolock)) b on a.[Loan Number]=b.[Loan Number] and a.[Effective Date]=b.eff_dttm ) hld on cast(base.loan_nbr as varchar)=hld.[loan number]) final ) final2
					  where (final2.tag_2_val not in ('HOLD', 'Servicer Cure', 'Finance HOLD', 'FNMA Finance Hold') or final2.tag_2_val is null)  and (final2.[group] <> 'Grp 5 BofA GNMAs' or final2.[group] is null) and [incurable flag] not in ('1.00000000000000', '2.00000000000000', '3.00000000000000', '4.00000000000000', '5.00000000000000','6.00000000000000', '7.00000000000000') 



-- Starting Tax Base
select final.*, mcan.[Valid 2B], case when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 16 then '1-15 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 31 then '16-30 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 61 then '31-60 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 91 then '61-90 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  >= 91 then '91+ Days' end as 'Exception Aging2', row_number() over (partition by final.loan_nbr order by  [EXCP_RQST_DTTM] asc) as XRank 
into ##Taxeom1
 from
(select a.[loan_nbr], a.[excp_id], b.doc_desc, b.issu_desc, b.excp_sts_desc, b.excp_rqst_dttm, datediff(day,[EXCP_RQST_DTTM],'2020-04-01') as 'Days Open'
from
(select loan_nbr, excp_id, max(eff_dttm) as 'Eff Date' from [dbo].[HUD_ASGN_EXCP_EDW]
where doc_desc = 'Tax Bill'  and eff_dttm < '2020-04-01' and excp_id is not null and loan_nbr is not null and doc_desc is not null group by loan_nbr, excp_id ) a
left join
(select loan_nbr, doc_desc, issu_desc, excp_id, eff_dttm, excp_sts_desc, excp_rqst_dttm from [dbo].[HUD_ASGN_EXCP_EDW]
) b on a.loan_nbr=b.loan_nbr and a.excp_id=b.excp_id and a.[eff date]=b.eff_dttm 
)final
left join
(select loan_nbr, case when mca_percent >= 97.5 then 'Y' else 'N' end as 'Valid 2B' from [dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW]) mcan on final.loan_nbr=cast(mcan.loan_nbr as varchar)
where [EXCP_STS_DESC] not in ('Closed with Vendor', 'Resolved by ML', 'Resolved', 'Not Valid', 'Cancelled', 'Incurable')
--------------------------------------------------------------------------------
-- Starting Emiliya Base
select final.*, mcan.[Valid 2B], case when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 16 then '1-15 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 31 then '16-30 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 61 then '31-60 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 91 then '61-90 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  >= 91 then '91+ Days' end as 'Exception Aging2', row_number() over (partition by final.loan_nbr order by  [EXCP_RQST_DTTM] asc) as XRank 
into  ##emyeom1
 from
(select a.[loan_nbr], a.[excp_id], b.doc_desc, b.issu_desc, b.excp_sts_desc, b.excp_asgn_to_desc, b.excp_rqst_dttm, datediff(day,[EXCP_RQST_DTTM],'2020-04-01') as 'Days Open'
from
(select loan_nbr, excp_id, max(eff_dttm) as 'Eff Date' from [dbo].[HUD_ASGN_EXCP_EDW]
where doc_desc in ('Trust', 'Trust - HACG', 'Death Cert HACG', 'POA', 'Signed Pay Plan', 'Proof of Repair', 'MIC', 'Death Cert', 'Life Estate') --and excp_asgn_to_desc = 'Emiliya Ivanova' 
and eff_dttm < '2020-04-01' and excp_id is not null and loan_nbr is not null and doc_desc is not null group by loan_nbr, excp_id ) a
left join
(select loan_nbr, doc_desc, issu_desc, excp_id, eff_dttm, excp_sts_desc, excp_rqst_dttm, excp_asgn_to_desc from [dbo].[HUD_ASGN_EXCP_EDW]
) b on a.loan_nbr=b.loan_nbr and a.excp_id=b.excp_id and a.[eff date]=b.eff_dttm 
)final
left join
(select loan_nbr, case when mca_percent >= 97.5 then 'Y' else 'N' end as 'Valid 2B' from [dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW]) mcan on final.loan_nbr=cast(mcan.loan_nbr as varchar)
where [EXCP_STS_DESC] not in ('Closed with Vendor', 'Resolved', 'Resolved by ML', 'Not Valid', 'Cancelled', 'Incurable') and excp_asgn_to_desc = 'Emiliya Ivanova'
--------------
-- Starting Georgia Base 
select final.*, mcan.[Valid 2B], case when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 16 then '1-15 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 31 then '16-30 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 61 then '31-60 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 91 then '61-90 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  >= 91 then '91+ Days' end as 'Exception Aging2', row_number() over (partition by final.loan_nbr order by  [EXCP_RQST_DTTM] asc) as XRank 
into  ##georgiaeom1
 from
(select a.[loan_nbr], [eff date], a.[excp_id], b.doc_desc, b.issu_desc, b.excp_sts_desc, b.excp_rqst_dttm, excp_asgn_to_desc, datediff(day,[EXCP_RQST_DTTM],'2020-04-01') as 'Days Open'
from
(select loan_nbr, excp_id, max(eff_dttm) as 'Eff Date' from [dbo].[HUD_ASGN_EXCP_EDW]
where doc_desc in ('Trust', 'Trust - HACG', 'Death Cert HACG', 'POA', 'Signed Pay Plan', 'Proof of Repair', 'MIC', 'Death Cert', 'Life Estate')  and eff_dttm < '2020-04-01' and excp_id is not null and loan_nbr is not null and doc_desc is not null group by loan_nbr, excp_id ) a
left join
(select loan_nbr, doc_desc, issu_desc, excp_id, eff_dttm, excp_sts_desc, excp_rqst_dttm, excp_asgn_to_desc from [dbo].[HUD_ASGN_EXCP_EDW]
) b on a.loan_nbr=b.loan_nbr and a.excp_id=b.excp_id and a.[eff date]=b.eff_dttm 
)final
left join
(select loan_nbr, case when mca_percent >= 97.5 then 'Y' else 'N' end as 'Valid 2B' from [dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW]) mcan on final.loan_nbr=cast(mcan.loan_nbr as varchar)
where [EXCP_STS_DESC] not in ('Closed with Vendor', 'Resolved', 'Resolved by ML', 'Not Valid', 'Cancelled', 'Incurable') and excp_asgn_to_desc = 'Georgia Rowe'


-- Starting HOABase select * from ##hoaeom1
select final.*, [valid 2B],case when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 16 then '1-15 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 31 then '16-30 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 61 then '31-60 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 91 then '61-90 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  >= 91 then '91+ Days' end as 'Exception Aging2', row_number() over (partition by final.loan_nbr order by  [EXCP_RQST_DTTM] asc) as XRank 
into ##HOAeom1
 from
(select a.[loan_nbr], a.[excp_id], b.doc_desc, b.issu_desc, b.excp_sts_desc, b.excp_rqst_dttm, datediff(day,[EXCP_RQST_DTTM],'2020-04-01') as 'Days Open'
from
(select loan_nbr, excp_id, max(eff_dttm) as 'Eff Date' from [dbo].[HUD_ASGN_EXCP_EDW]
where doc_desc = 'HOA'  and eff_dttm < '2020-04-01' and excp_id is not null and loan_nbr is not null and doc_desc is not null group by loan_nbr, excp_id ) a
left join
(select loan_nbr, doc_desc, issu_desc, excp_id, eff_dttm, excp_sts_desc, excp_rqst_dttm from [dbo].[HUD_ASGN_EXCP_EDW]
) b on a.loan_nbr=b.loan_nbr and a.excp_id=b.excp_id and a.[eff date]=b.eff_dttm 
)final
left join
(select loan_nbr, case when mca_percent >= 97.5 then 'Y' else 'N' end as 'Valid 2B' from [dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW]) mcan on final.loan_nbr=cast(mcan.loan_nbr as varchar)
where [EXCP_STS_DESC] not in ('Closed with Vendor', 'Resolved', 'Resolved by ML', 'Not Valid', 'Cancelled', 'Incurable')
-- Starting OCC Cert Base

select final.*, [valid 2B], case when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 16 then '1-15 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 31 then '16-30 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 61 then '31-60 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  < 91 then '61-90 Days'
when DATEDIFF(day,excp_rqst_dttm,'2020-04-01')  >= 91 then '91+ Days' end as 'Exception Aging2', row_number() over (partition by final.loan_nbr order by  [EXCP_RQST_DTTM] asc) as XRank 
into  ##OCCeom1
 from
(select a.[loan_nbr], a.[excp_id], b.doc_desc, b.issu_desc, b.excp_sts_desc, b.excp_rqst_dttm, datediff(day,[EXCP_RQST_DTTM],'2020-04-01') as 'Days Open'
from
(select loan_nbr, excp_id, max(eff_dttm) as 'Eff Date' from [dbo].[HUD_ASGN_EXCP_EDW]
where doc_desc = 'Current OCC Cert'  and eff_dttm < '2020-04-01' and excp_id is not null and loan_nbr is not null and doc_desc is not null group by loan_nbr, excp_id ) a
left join
(select loan_nbr, doc_desc, issu_desc, excp_id, eff_dttm, excp_sts_desc, excp_rqst_dttm from [dbo].[HUD_ASGN_EXCP_EDW]
) b on a.loan_nbr=b.loan_nbr and a.excp_id=b.excp_id and a.[eff date]=b.eff_dttm 
)final
left join
(select loan_nbr, case when mca_percent >= 97.5 then 'Y' else 'N' end as 'Valid 2B' from [dbo].[RM_CHAMPION_MASTER_TBL_CURR_VW]) mcan on final.loan_nbr=cast(mcan.loan_nbr as varchar)
where [EXCP_STS_DESC] not in ('Closed with Vendor', 'Resolved', 'Resolved by ML', 'Not Valid', 'Cancelled', 'Incurable')


/*select * from ##georgiaeom1 where excp_id = '519168'
select eff_dttm as 'eff date', * from [dbo].[HUD_ASGN_EXCP_EDW] where excp_id = '519168'
order by eff_dttm desc*/

