with source as (
    select
        ref::varchar,
        external_ref::varchar,
        source::varchar,
        state::varchar,
        status::boolean,
        cvv_provided::boolean,
        country::varchar,
        currency::varchar,
        rates::json as rates,
        rates::json->currency as usd_exchange_rate,
        amount::numeric(38,2),
        date_time::timestamp
    from {{ref('acceptance_data')}}
),

-- this CTE would not be needed in snowflake because snowflake allows to referenced columns aliased within the same CTE
-- also postgres requires an extra step to cast json data to numbers, which would not be needed in snowflake either
cast_json as (
    select
        ref,
        external_ref,
        source,
        state,
        status,
        cvv_provided,
        country,
        currency as local_currency,
        rates,
        1 / usd_exchange_rate::text::numeric(38, 16) as usd_exchange_rate,
        amount as local_amount,
        date_time
    from source
),

final as (
    select
        ref,
        external_ref,
        source,
        state,
        status,
        cvv_provided,
        country,
        local_currency,
        rates,
        usd_exchange_rate,
        local_amount,
        (local_amount * usd_exchange_rate)::numeric(38, 2) as usd_amount,
        date_time
    from cast_json
)

select * from final