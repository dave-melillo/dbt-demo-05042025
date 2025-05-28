
select
  id,
  name,
  align,
  true as is_active  -- add static field to make hard delete examples easier later
from {{ source('marvel', 'marvel_wikia_data') }}
where name is not null