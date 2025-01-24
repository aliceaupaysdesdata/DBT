with status_data as (

    select *

    from {{ ref('customer_status') }}

)

select *

from status_data