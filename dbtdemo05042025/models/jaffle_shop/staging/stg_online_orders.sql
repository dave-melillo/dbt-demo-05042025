select
    order_number,
    customer,
    item,
    timestamp_of_purchase,
    status
from {{ ref('online_orders') }}