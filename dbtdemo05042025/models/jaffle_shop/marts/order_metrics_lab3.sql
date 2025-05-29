{{ config(
    materialized = 'ephemeral',
    tags = ['lab3']
) }}

select
  customer_id,
  count(*) as total_orders,
  min(ordered_at) as first_order_date,
  max(ordered_at) as most_recent_order_date
from {{ ref('stg_orders') }}
group by customer_id