with transactions as (
    select
        date_time::date as date,
        country,
        sum(usd_amount) as total_usd_amount,
        array_agg(ref) filter (where not chargeback)
    from {{ref('trn_transactions')}}
    group by 1, 2
)

select * from transactions