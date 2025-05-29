-- models/core/language.sql
{{ config(materialized='view', tags=['jinjalab']) }}

SELECT * FROM {{ source('pagila', 'language') }}