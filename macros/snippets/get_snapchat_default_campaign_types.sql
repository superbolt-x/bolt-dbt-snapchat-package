{%- macro get_snapchat_default_campaign_types(campaign_name) -%}

 CASE 
    WHEN {{ campaign_name }} ~* 'prospecting' THEN 'Campaign Type: Prospecting'
    WHEN {{ campaign_name }} ~* 'retargeting' THEN 'Campaign Type: Retargeting'
    ELSE ''
    END AS campaign_type_default

{%- endmacro -%}