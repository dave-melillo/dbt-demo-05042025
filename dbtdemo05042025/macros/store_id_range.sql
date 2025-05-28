{% test store_id_range(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} NOT IN (1, 2)
{% endtest %}