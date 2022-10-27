{{ config( 
        materialized='incremental',
        unique_key='unique_key'
) }}

{%- set schema_name, table_name = 'snapchat_raw', 'ad_daily_report' -%}

{%- set exclude_fields = [
   "quartile_1",
   "quartile_2",
   "quartile_3",
   "attachment_avg_view_time_millis",
   "attachment_quartile_1",
   "attachment_quartile_2",
   "attachment_quartile_3",
   "attachment_total_view_time_millis",
   "attachment_view_completion",
   "avg_view_time_millis",
   "avg_screen_time_millis",
   "swipe_up_percent"
]
-%}

{%- set fields = adapter.get_columns_in_relation(source(schema_name, table_name))
                    |map(attribute="name")
                    |reject("in",exclude_fields)
                    -%}  

WITH insights AS 
    (SELECT 
        {%- for field in fields %}
        {{ get_snapchat_clean_field(table_name, field) }}
        {%- if not loop.last %},{%- endif %}
        {%- endfor %}
    FROM {{ source(schema_name, table_name) }}
    )

SELECT *,
    MAX(_fivetran_synced) over () as last_updated,
    ad_id||'_'||date as unique_key
FROM insights
{% if is_incremental() -%}

  -- this filter will only be applied on an incremental run
where date >= (select max(date)-30 from {{ this }})

{% endif %}
