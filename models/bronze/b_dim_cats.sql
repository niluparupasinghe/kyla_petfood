select
    *
from {{ source('staging', 'cats') }}