select
  name,
  id,
  align
from {{ ref('marvel_short') }}
where name is not null