select
    c.*
from {{ ref('customers') }} c
inner join {{ ref('vip_customers') }} v
    on c.customer_id = v.customer_id