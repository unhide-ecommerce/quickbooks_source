--To disable this model, set the using_bill_payment variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__bill_payment_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__bill_payment_tmp')),
                staging_columns=get_bill_payment_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as bill_payment_id,
        cast(check_bank_account_id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as check_bank_account_id,
        check_print_status,
        cast(credit_card_account_id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as credit_card_account_id,
        exchange_rate,
        currency_id,
        department_id,
        pay_type,
        total_amount,
        transaction_date,
        vendor_id,
        _fivetran_deleted
    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
