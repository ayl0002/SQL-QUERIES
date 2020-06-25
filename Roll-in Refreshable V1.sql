select final.*, case when [exception 1] is null then [Distribution Tier] else 'Tier 2' end as 'Tier Distribution Group' from 
(select base.*, case when [tax due date] between '2020-04-10' and '2020-05-20' and [Tax Close Date] is not null and datediff(day,[Tax Close Date],getdate()) between 31 and 90
and [has loss draft] = 'N' and [In Curative] = 'N' and [HAS FPI] = 'N'  and [Has Open OCC] = 'N' and [Has Open HOA] = 'N' and [Has FPI] = 'N'
and [Has Loss Draft] = 'N' and [HAC Exceptions] is null 

 then 'Tier 1A Review'
when [tax due date] between '2020-04-10' and '2020-05-20'  and [Tax Close Date] is not null
and [has loss draft] = 'N' and [In Curative] = 'N' and [HAS FPI] = 'N'  and [Has Open OCC] = 'N' and [Has Open HOA] = 'N' and [Has FPI] = 'N'
and [Has Loss Draft] = 'N' and [HAC Exceptions] is null
 then 'Tier 1A'

when [OCC close date] is null and [OCC] between '2020-04-10' and '2020-05-20' 
and [has loss draft] = 'N' and [In Curative] = 'N' and [HAS FPI] = 'N' and [Has Open Tax] = 'N' and [Has Open HOA] = 'N' and [Has FPI] = 'N'
and [Has Loss Draft] = 'N' and [HAC Exceptions] is null 
then 'Tier 1A'
when [HOA Close Date] is not null  and [Has Open Tax] = 'N' and [Has Open OCC] = 'N' and [Has FPI] = 'N' and [Has Loss Draft] = 'N' then 'Tier 1A'
--when [HOA Close Date] is not null and [Has Open Tax] = 'N' and [Has Open OCC] = 'N' and [Has FPI] = 'N' and [Has Loss Draft] = 'N' then 'Tier 1A'
when [Has Open Tax] = 'N' and [Has Open OCC] = 'N' and [Has Open HOA] = 'N' and [Has FPI] = 'N' and [has loss draft] = 'N' and [In Curative] = 'N' 
and [HAC Exceptions] is null then 'Tier 1'

else 'Tier 2' end as 'Distribution Tier', [HAC Exceptions], [Final Review Assigned To] as 'Final Review Agent', ([next month mca] * [max_claim_amount]/100) as 'Projected New Loan Balance',
case when chb.status_code <> 0 then 'Y' else 'N' end as 'Now in Default',
case when [HAC Exceptions] is not null then 'Y' else 'N' end as 'Has Open HAC Exceptions',
exc1.document as [Exception 1], exc1.[issue] as [Issue 1]
,chb.status_description
,[Final Review Status]
,HS.[HUD Status]
 from  
(select *
from dbo.tierload5) base
left join
(select [loan number],[Final Review Status],[Final Review Assigned To] from sharepointdata.[dbo].[HUDAssignFinalReview]) fnl on base.[loan_nbr]=fnl.[loan number]
left join
(select loan_nbr, max_claim_amount from tact_rev.dbo.champbase) cb on base.loan_nbr=cb.loan_nbr
left join
(select [loan number], count(*) as 'HAC Exceptions' from sharepointdata.[dbo].[HUDAssignExceptions] where
[work group] = 'HACG' and [exception status] not in ('Not Valid', 'Cancelled', 'Canceled', 'Closed with Vendor', 'Resolved', 'Incurable')
group by [loan number]) cha on base.loan_nbr=cha.[loan number]
LEFT JOIN SharepointData.[dbo].[HUDAssignHUDStatus] HS
ON base.loan_nbr = HS.[Loan Number]
left join
(select loan_nbr, [status_description],status_code from dbo.champbase) chb on base.loan_nbr=chb.loan_nbr

 left join

(select * from 
(select [loan number], document, [issue], [exception request date],[exception assigned to], row_number() over (partition by [loan number] order by  [exception request date] asc) as XRank
from sharepointdata.[dbo].[HUDAssignExceptions]
where [exception status]  not in ('Closed with Vendor', 'Resolved', 'Not Valid', 'Cancelled', 'Incurable') and [work group] = 'HACG'
) exc1a where xrank = 1) exc1 on base.[loan_nbr]=exc1.[loan number]) final

order by [distribution tier] asc