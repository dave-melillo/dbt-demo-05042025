{{ config(
    materialized = 'ephemeral',
    tags = ['lab3']
) }}

select
  o.customer_id,
  count(distinct i.product_id) as unique_products_purchased
from {{ ref('stg_orders') }} o
join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
group by o.customer_id