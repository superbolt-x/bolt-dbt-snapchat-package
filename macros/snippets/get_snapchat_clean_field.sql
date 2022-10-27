{%- macro get_snapchat_clean_field(table_name, column_name) %}
    {%- if column_name == 'updated_at' -%}
        {{column_name}}

    {%- elif table_name == 'ad_daily_report' -%}
        {%- if column_name == 'date' -%}
        {{column_name}}::date as date

        {%- elif '_millis' in column_name -%}
        {{column_name}}::float/1000000 as {{column_name.split('_millis')[0]}}

        {%- else -%}
        {{column_name}}
        
        {%- endif -%}

    {%- elif table_name == 'accounts' -%}

        {{column_name}} as account_{{column_name}}

    {%- elif table_name == 'campaigns' -%}
        {%- if column_name == 'ad_account_id' -%}
        {{column_name}} as account_id

        {%- elif column_name == 'daily_budget_micro' -%}
        {{column_name}}::float/1000000 as campaign_daily_budget

        {%- else -%}
        {{column_name}} as campaign_{{column_name}}
        
        {%- endif -%}

    {%- elif table_name == 'ad_squads' -%}

        {%- if column_name == 'daily_budget_micro' -%}
        {{column_name}}::float/1000000 as ad_squad_daily_budget

        {%- elif column_name == 'campaign_id' -%}
        {{column_name}}

        {%- else -%}
        {{column_name}} as ad_squad_{{column_name}}
        
        {%- endif -%}

    {%- elif table_name == 'ads' -%}

        {%- if column_name == 'ad_squad_id' -%}
        {{column_name}}

        {%- else -%}
        {{column_name}} as ad_{{column_name}}
        
        {%- endif -%}


    {%- else -%}
    
       {{column_name}}

    {%- endif -%}

{% endmacro -%}
Footer
