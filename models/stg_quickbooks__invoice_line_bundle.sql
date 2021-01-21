--To disable this model, set the using_invoice_bundle variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_invoice_bundle', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__invoice_line_bundle_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__invoice_line_bundle_tmp')),
                staging_columns=get_invoice_line_bundle_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        invoice_id,
        index,
        class_id,
        description,
        amount,
        sales_item_item_id,
        item_id,
        quantity,
        sales_item_quantity,
        account_id,
        unit_price
    from fields
)

select * 
from final