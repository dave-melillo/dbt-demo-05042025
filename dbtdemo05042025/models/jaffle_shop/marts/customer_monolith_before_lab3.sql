{{ config(
    materialized = 'view',
    tags = ['lab3']
) }}

with order_metrics as (
  select
    customer_id,
    count(*) as total_orders,
    min(ordered_at) as first_order_date,
    max(ordered_at) as most_recent_order_date
  from {{ ref('stg_orders') }}
  group by customer_id
),

product_metrics as (
  select
    o.customer_id,
    count(distinct i.product_id) as unique_products_purchased
  from {{ ref('stg_orders') }} o
  join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
  group by o.customer_id
)

select
  c.customer_id,
  c.customer_name, 
  o.total_orders,
  o.first_order_date,
  o.most_recent_order_date,
  p.unique_products_purchased
from {{ ref('stg_customers') }} c
left join order_metrics o on c.customer_id = o.customer_id
left join product_metrics p on c.customer_id = p.customer_id
