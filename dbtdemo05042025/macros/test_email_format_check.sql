{% test email_format_check(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} NOT LIKE '%@%.%'
{% endtest %}