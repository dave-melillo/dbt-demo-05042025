-- models/core/actor.sql
{{ config(materialized='view') }}

SELECT * FROM {{ source('pagila', 'actor') }}