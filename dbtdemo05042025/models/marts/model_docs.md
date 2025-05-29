{% docs fct_revenue_by_film_doc %}
This model calculates **daily revenue per film** by joining:

- `stg_rentals` for rental and film-level info
- `pagila.payment` for payment amounts

Used in: revenue dashboard, monthly film reports.
{% enddocs %}

{% docs fct_monthly_top_customers %}
This model calculates **monthly top customers** by joining:

- `x` for rental and film-level info
- `y` for payment amounts

{% enddocs %}