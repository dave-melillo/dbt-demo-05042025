{{ config(
    materialized = 'view',
    tags = ['lab3']
) }}

select
  c.customer_id,
  c.customer_name, 
  o.total_orders,
  o.first_order_date,
  o.most_recent_order_date,
  p.unique_products_purchased
from {{ ref('stg_customers') }} c
left join {{ ref('order_metrics_lab3') }} o on c.customer_id = o.customer_id
left join {{ ref('product_metrics_lab3') }} p on c.customer_id = p.customer_id