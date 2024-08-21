with transactions as (
    select
        date_time::date as date,
        country,
        sum(accepted::int) as accepted_transactions,
        count(*) as total_transactions,
        sum(case when accepted then usd_amount end) as total_usd_amount_accepted,
        sum(case when not accepted then usd_amount end) as total_usd_amount_declined,
        sum(usd_amount) as total_usd_amount,
        array_agg(ref) filter (where not chargeback) as transactions_without_chargeback
    from {{ref('trn_transactions')}}
    group by 1, 2
)

-- this is again something that in snowflake we could have done inside the cte above because it allows for alias refering
select 
    *,
    {{dbt_utils.generate_surrogate_key(['date', 'country'])}} as unique_key
from transactions