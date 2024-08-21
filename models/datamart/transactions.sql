{{
    config(materialized='view')
}}

select * 
from {{ref('trn_transactions')}}

