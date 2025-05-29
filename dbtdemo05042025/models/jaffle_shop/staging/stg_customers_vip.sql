select
    c.*
from {{ ref('stg_customers') }} c
inner join {{ ref('vip_customers') }} v
    on c.customer_id = v.customer_id