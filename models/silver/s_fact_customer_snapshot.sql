with cte_pauses as (
	select p.user_id ,p.paused_date ,p.unpaused_date , pr.reason from {{ref('b_fact_pauses')}} p 
	left join {{ref('b_dim_pause_reasons')}} pr
	on p.reason_id = pr.id 
)
, cte_cancels as (
	select c.user_id, c.cancelled_date ,c.reactivated_date , cr.reason from {{ref('b_fact_cancellations')}} c 
	left join {{ref('b_dim_cancellation_reasons')}} cr 
	on c.reason_id = cr.id 
)
,cte_union as (
	select distinct customer_id, 'joined' as action, date_acquired as date, null as reason from {{ref('b_dim_customers')}} c where date_acquired  is not null 
	union all
	select distinct user_id, 'paused' as action, paused_date as date, reason from cte_pauses where paused_date is not null
	union all
	select distinct user_id, 'unpaused' as action, unpaused_date date, reason from cte_pauses where unpaused_date is not null
	union all
	select distinct user_id, 'cancelled' as action, cancelled_date as date, reason from cte_cancels where cancelled_date is not null
	union all
	select distinct user_id, 'reactivated' as action, reactivated_date as date, reason from cte_cancels where reactivated_date is not null
)
, cte_cats as (
	select owner_id, count(*) active_cats from {{ref('b_dim_cats')}} where animal_deceased=false group by 1
)
select 
	customer_id,
	action,
	date,
	reason,
	active_cats
from cte_union u
left join cte_cats c
on u.customer_id = c.owner_id