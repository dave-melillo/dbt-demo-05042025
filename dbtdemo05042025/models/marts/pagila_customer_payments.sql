WITH 

payment as (select * from {{ ref('stg_payment') }}),

customer as (select * from {{ ref('stg_customer') }}),

payment_totals AS (
  SELECT 
    customer_id,
    SUM(amount) AS total_revenue
  FROM payment
  GROUP BY customer_id
),

customer_details AS (
  SELECT 
    customer_id,
    first_name,
    last_name
  FROM customer
),

final AS (
  SELECT 
    cd.customer_id,
    cd.first_name,
    cd.last_name,
    pt.total_revenue
  FROM customer_details cd
  LEFT JOIN payment_totals pt ON cd.customer_id = pt.customer_id
)

SELECT * FROM final
