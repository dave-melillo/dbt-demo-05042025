{% docs fct_revenue_by_film_doc %}
This model calculates **daily revenue per film** by joining:

- `stg_rentals` for rental and film-level info
- `pagila.payment` for payment amounts

Used in: revenue dashboard, monthly film reports.
{% enddocs %}
