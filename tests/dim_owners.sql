select * from {{ref('b_dim_cats')}}
where 
--1>2 and -- remove this to show the test result
owner_id not in (select distinct customer_id from {{ref('b_dim_customers')}})