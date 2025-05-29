{{ config(
    materialized = 'view',
    tags = ['lab3']
) }}

select
  c.customer_id,
  c.customer_name, 
  (
    select count(*) 
    from {{ ref('stg_orders') }} o
    where o.customer_id = c.customer_id
  ) as total_orders,
  (
    select min(ordered_at) 
    from {{ ref('stg_orders') }} o
    where o.customer_id = c.customer_id
  ) as first_order_date,
  (
    select max(ordered_at) 
    from {{ ref('stg_orders') }} o
    where o.customer_id = c.customer_id
  ) as most_recent_order_date,
  (
    select count(distinct i.product_id)
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
    where o.customer_id = c.customer_id
  ) as unique_products_purchased
from {{ ref('stg_customers') }} c