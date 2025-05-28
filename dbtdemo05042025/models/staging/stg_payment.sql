{{ config(materialized='view', tags=['pagila']) }}

SELECT
*
FROM {{ source('pagila','payment') }}