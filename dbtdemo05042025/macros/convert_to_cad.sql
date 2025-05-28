{% macro convert_to_cad(usd_amount, exchange_rate=1.35) %}
    ({{ usd_amount }} * {{ exchange_rate }})
{% endmacro %}
