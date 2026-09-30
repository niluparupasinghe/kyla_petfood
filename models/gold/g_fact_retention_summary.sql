with cte_paused_counts as (
	select distinct
		customer_id 
		,count(customer_id) over(partition by customer_id) paused_count
		,max(date) over(partition by customer_id order by date rows between unbounded preceding and unbounded following) most_recent_paused_date
		,last_value(reason) over(partition by customer_id order by date rows between unbounded preceding and unbounded following) as most_recent_paused_reason
	from {{ref('s_fact_customer_snapshot')}} cs 
	where action='paused' 
)
, cte_cancelled_counts as (
	select distinct
		customer_id 
		,count(customer_id) over(partition by customer_id) cancelled_count
		,max(date) over(partition by customer_id order by date rows between unbounded preceding and unbounded following) most_recent_cancelled_date
		,last_value(reason) over(partition by customer_id order by date rows between unbounded preceding and unbounded following) as most_recent_cancelled_reason
	from {{ref('s_fact_customer_snapshot')}} cs 
	where action='cancelled' 
)
--select * from cte_cancelled_counts where customer_id=16592;
select
	c.customer_id 
	, coalesce(c.active_cats, 0) as active_cats
	, coalesce(pc.paused_count, 0) as paused_count 
	, pc.most_recent_paused_date 
	, pc.most_recent_paused_reason 
	, coalesce(cc.cancelled_count, 0) cancelled_count
	, cc.most_recent_cancelled_date 
	, cc.most_recent_cancelled_reason 
from (select distinct customer_id, active_cats from {{ref('s_fact_customer_snapshot')}}) c
left join cte_paused_counts pc on c.customer_id = pc.customer_id
left join cte_cancelled_counts cc on c.customer_id = cc.customer_id 