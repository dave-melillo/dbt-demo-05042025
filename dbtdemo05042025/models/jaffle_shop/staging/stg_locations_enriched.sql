select
    l.*,
    d.population,
    d.avg_median_income,
    d.avg_age
from {{ ref('stg_locations') }} l
left join {{ ref('city_demographics') }} d
  on l.location_name = d.city