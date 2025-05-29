-- models/core/actor.sql
{{ config(materialized='view', tags=['jinjalab']) }}

SELECT * FROM {{ source('pagila', 'actor') }}