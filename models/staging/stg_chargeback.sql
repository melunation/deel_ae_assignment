with chargeback as (
    select
        external_ref::varchar,
        source::varchar,
        status::boolean,
        chargeback::boolean
    from {{ref('chargeback_data')}}
)

select * from chargeback