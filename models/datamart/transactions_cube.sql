with transactions as (
    select
        date_time::date as date,
        country,
        sum(usd_amount) as total_usd_amount,
        array_agg(ref) filter (where not chargeback)
    from {{ref('trn_transactions')}}
    group by 1, 2
)

-- this is again something that in snowflake we could have done inside the cte above because it allows for alias refering
select 
    *,
    {{dbt_utils.generate_surrogate_key(['date', 'country'])}} as unique_key
from transactions