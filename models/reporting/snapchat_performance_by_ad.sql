{{ config (
    alias = target.database + '_snapchat_performance_by_ad'
)}}

{%- set date_granularity_list = ['day','week','month','quarter','year'] -%}
{%- set exclude_fields = ['date','day','week','month','quarter','year','last_updated','unique_key'] -%}
{%- set dimensions = ['ad_id'] -%}
{%- set measures = adapter.get_columns_in_relation(ref('snapchat_ads_insights'))
                    |map(attribute="name")
                    |reject("in",exclude_fields)
                    |reject("in",dimensions)
                    |list
                    -%}  

WITH 
    {%- for date_granularity in date_granularity_list %}

    performance_{{date_granularity}} AS 
    (SELECT 
        '{{date_granularity}}' as date_granularity,
        {{date_granularity}} as date,
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        {% for measure in measures -%}
        COALESCE(SUM("{{ measure }}"),0) as "{{ measure }}"
        {%- if not loop.last %},{%- endif %}
        {% endfor %}
    FROM {{ ref('snapchat_ads_insights') }}
    GROUP BY {{ range(1, dimensions|length +2 +1)|list|join(',') }}),
    {%- endfor %}

    ads AS 
    (SELECT ad_id, ad_squad_id, ad_name, ad_status
    FROM {{ ref('snapchat_ads') }}
    ),

    ad_squads AS 
    (SELECT ad_squad_id, campaign_id, ad_squad_name, ad_squad_status
    FROM {{ ref('snapchat_ad_squads') }}
    ),

    campaigns AS 
    (SELECT campaign_id, account_id, campaign_name, campaign_status
    FROM {{ ref('snapchat_campaigns') }}
    ),

    accounts AS 
    (SELECT account_id, account_name
    FROM {{ ref('snapchat_accounts') }}
    )

SELECT *,
    {{ get_snapchat_default_campaign_types('campaign_name')}}
FROM 
    ({% for date_granularity in date_granularity_list -%}
    SELECT *
    FROM performance_{{date_granularity}}
    {% if not loop.last %}UNION ALL
    {% endif %}

    {%- endfor %}
    )
LEFT JOIN ads USING(ad_id)
LEFT JOIN ad_squads USING(ad_squad_id)
LEFT JOIN campaigns USING(campaign_id)
LEFT JOIN accounts USING(account_id)