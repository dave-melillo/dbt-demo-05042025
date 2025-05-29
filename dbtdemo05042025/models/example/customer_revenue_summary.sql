{{ config(materialized='view') }}

with base as (

    select 
        customer_id,
        sum(amount) as total_revenue
    from {{ source('pagila', 'payment') }}
    group by customer_id

),

final as (

    select 
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        customer_id,
        total_revenue
    from base

)

select * from final
