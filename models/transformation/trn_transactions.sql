with acceptance as (
    select
        ref,
        external_ref,
        country,
        local_currency,
        local_amount,
        usd_amount,
        date_time
    from {{ref('stg_acceptance')}}
),

chargeback as (
    select
        external_ref,
        chargeback
    from {{ref('stg_chargeback')}}
),

final as (
    select
        acceptance.ref,
        chargeback.chargeback,
        acceptance.date_time,
        acceptance.country,
        acceptance.local_currency,
        acceptance.local_amount,
        acceptance.usd_amount
    from acceptance
    left join chargeback
        on acceptance.external_ref = chargeback.external_ref
)

select * from final