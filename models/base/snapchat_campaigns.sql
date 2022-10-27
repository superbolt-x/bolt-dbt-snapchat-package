{%- set selected_fields = [
    "id",
    "name",
    "status",
    "daily_budget_micro",
    "ad_account_id",
    "updated_at"
] -%}
{%- set schema_name, table_name = 'snapchat_raw', 'campaigns' -%}

WITH staging AS 
    (SELECT
    
        {% for field in selected_fields -%}
        {{ get_snapchat_clean_field(table_name, field) }},
        {% endfor -%}
        MAX(updated_at) OVER (PARTITION BY id) as last_updated_at

    FROM {{ source(schema_name, table_name) }}
    )

SELECT *,
    campaign_id as unique_key
FROM staging 
WHERE updated_at = last_updated_at