/*---------------------------------------------------------------------------
Command to run model:
--dbt run --select ETL_MART_SALES_POINT_OF_SALES_CUSTOMER_BRIDGE

Version     Date            Author          Description
-------     --------        -----------     ----------------------------------
1.0         10/18/2022      Sruthi Kasbe    Updated customer columns and its order
---------------------------------------------------------------------------*/
{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['TRANSACTION_ID']-%}
{%-set v_house_keeping_column = ['BIW_INS_DTTM','BIW_UPD_DTTM','BIW_BATCH_ID','BIW_MD5_KEY']-%}
/*--DBT Variable used during development*/
{% if is_incremental() %}
{%-set v_all_column_list =  edw_get_column_list( this ) -%}
{%-set v_update_column_list = edw_get_quoted_column_list( this ,v_pk_list|list + ['BIW_INS_DTTM']|list) -%}
{%-set v_md5_column_list =  edw_get_md5_column_list( this ,v_pk_list|list+ v_house_keeping_column|list ) -%}
/*--DBT Variable*/
/*--SELECT {{v_all_column_list}}*/
/*--SELECT {{v_update_column_list}}*/
/*--SELECT {{v_md5_column_list}}*/
{% endif %}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ETL_MART_SALES_POINT_OF_SALES_CUSTOMER_BRIDGE'-%}
-- Step 1 Batch process info
{%- set v_watermark = edw_batch_control(v_dbt_job_name,config.get('schema'),config.get('alias') ,config.get('tags'),config.get('materialized') ) -%}
{%- set V_LWM = v_watermark[0] -%}
{%- set V_HWM = v_watermark[1] -%}
{%- set V_START_DTTM = v_watermark[2] -%}
{%- set V_BIW_BATCH_ID = v_watermark[3] -%}
{%- set v_sql_upd_success_batch = "CALL UTILITY.EDW_BATCH_SUCCESS_PROC('"~v_dbt_job_name~"')" -%}


{################# Snowflake Object Configuration #################}
{{
    config(
         description = 'Building ETL table POS_FACT for Sales Mart '
        ,transient=true
        ,materialized='table'
        ,schema ='ETL_MART_SALES'
        ,alias='POINT_OF_SALES_CUSTOMER_BRIDGE'
        ,tags =['MART_SALES']
        ,post_hook= [v_sql_upd_success_batch]	
        )
}}

WITH POS_DATA AS 
(
SELECT 
    TRANSACTION_KEY,
    FISCAL_SHIP_DATE_KEY,
    MARKET_PRODUCT_NUMBER_KEY,
----------------CODE --------------------------------
    TRANSACTION_ID,
    FISCAL_SHIP_DATE,
    MARKET_PRODUCT_NUMBER,
    DIRECT_CUSTOMER_CODE,
    INDIRECT_CUSTOMER_CODE,
    END_CUSTOMER_CODE,
    END_CORPORATION_CODE,
    INDIRECT_CORPORATION_CODE
FROM {{ref('MART_SALES_POINT_OF_SALES_FACT')}}
WHERE BIW_LOGICAL_DELETE_FLAG ='N'
),

---------------------------CORPORATION REFERENCE ---------------------------------------
ADJUSTED_END_CORPORATION AS
(
SELECT
    MPN AS PRODUCT_ID,
    NULLIF(DIR_CUST_CD,'') AS DIR_CUST_CD,
    NULLIF(IND_CUST_CD,'') AS IND_CUST_CD,
    NULLIF(END_CORP_CD,'') AS END_CORP_CD,
    NULLIF(ADJUSTED_END_CORP_CD,'') AS ADJUSTED_END_CORP_CD,
    EFFECTIVE_START_DATE AS EFFECTIVE_FROM_DATE,
    EFFECTIVE_END_DATE AS EFFECTIVE_TO_DATE
FROM {{source('STG_SHAREPOINT_MDL','ADJUSTED_END_CORPORATION')}}
QUALIFY (ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID,DIR_CUST_CD,IND_CUST_CD,END_CORP_CD,EFFECTIVE_FROM_DATE,EFFECTIVE_TO_DATE ORDER BY BIW_UPD_DTTM DESC )=1)
)
,REFERENCE_DESIGN_CUSTOMER AS
(
SELECT
    MPN AS PRODUCT_ID,
    NULLIF(DIR_CUST_CD,'') AS DIR_CUST_CD,
    NULLIF(IND_CUST_CD,'') AS IND_CUST_CD,
    NULLIF(END_CORP_CD,'') AS END_CORP_CD,
    NULLIF(REFERENCE_CORP_CD,'')  AS REFERENCE_CORP_CD,
    EFFECTIVE_START_DATE AS EFFECTIVE_FROM_DATE,
    EFFECTIVE_END_DATE AS EFFECTIVE_TO_DATE
FROM {{source('STG_SHAREPOINT_MDL','REFERENCE_DESIGN_CUSTOMER')}}
QUALIFY (ROW_NUMBER() OVER (PARTITION BY MPN,DIR_CUST_CD,IND_CUST_CD,END_CORP_CD,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE ORDER BY BIW_UPD_DTTM DESC )=1)
),

FINAL_SQL AS 
(SELECT 
    POS.TRANSACTION_KEY,
    POS.FISCAL_SHIP_DATE_KEY,
    POS.MARKET_PRODUCT_NUMBER_KEY,
----------------CODE --------------------------------
    POS.TRANSACTION_ID,
    POS.FISCAL_SHIP_DATE,
    POS.MARKET_PRODUCT_NUMBER,
    COALESCE(ADJ_CORP.ADJUSTED_END_CORP_CD
            ,ADJ_CORP_DIR_CUST.ADJUSTED_END_CORP_CD
            ,ADJ_CORP_INDIR_CUST.ADJUSTED_END_CORP_CD
            ,POS.END_CORPORATION_CODE
            ) AS ADJUSTED_END_CORPORATION_CODE,
    MD5(COALESCE(ADJUSTED_END_CORPORATION_CODE,'-1')::STRING)   AS ADJUSTED_END_CORPORATION_KEY,

    COALESCE(REF_CORP.REFERENCE_CORP_CD
            ,REF_CORP_DIR_CUST.REFERENCE_CORP_CD
            ,REF_CORP_INDIR_CUST.REFERENCE_CORP_CD
            ,POS.END_CORPORATION_CODE
            ) AS REFERENCE_CORPORATION_CODE,
    MD5(COALESCE(REFERENCE_CORPORATION_CODE,'-1')::STRING) AS REFERENCE_CORPORATION_KEY
FROM 
POS_DATA  POS

------------- ADJUSTED END CORP WITH END CORP-------------
LEFT JOIN  ADJUSTED_END_CORPORATION ADJ_CORP
    ON POS.MARKET_PRODUCT_NUMBER = ADJ_CORP.PRODUCT_ID
    AND POS.DIRECT_CUSTOMER_CODE = ADJ_CORP.DIR_CUST_CD
    AND POS.INDIRECT_CUSTOMER_CODE = ADJ_CORP.IND_CUST_CD
    AND POS.END_CORPORATION_CODE = ADJ_CORP.END_CORP_CD
    AND POS.FISCAL_SHIP_DATE BETWEEN ADJ_CORP.EFFECTIVE_FROM_DATE AND ADJ_CORP.EFFECTIVE_TO_DATE 
    
------------- ADJUSTED END CORP WITH INDIRECT CUSTOMER (WHICH IS END CORP) -------------
LEFT JOIN  ADJUSTED_END_CORPORATION ADJ_CORP_INDIR_CUST
    ON POS.MARKET_PRODUCT_NUMBER = ADJ_CORP_INDIR_CUST.PRODUCT_ID
    AND POS.DIRECT_CUSTOMER_CODE = ADJ_CORP_INDIR_CUST.DIR_CUST_CD
    AND POS.INDIRECT_CUSTOMER_CODE = ADJ_CORP_INDIR_CUST.IND_CUST_CD
    AND POS.INDIRECT_CORPORATION_CODE= ADJ_CORP_INDIR_CUST.END_CORP_CD    
    AND POS.END_CORPORATION_CODE IS NULL
    AND POS.FISCAL_SHIP_DATE  BETWEEN ADJ_CORP_INDIR_CUST.EFFECTIVE_FROM_DATE AND ADJ_CORP_INDIR_CUST.EFFECTIVE_TO_DATE 

------------- ADJUSTED END CORP WITH DIRECT CUSTOMER -------------
LEFT JOIN  ADJUSTED_END_CORPORATION ADJ_CORP_DIR_CUST
    ON POS.MARKET_PRODUCT_NUMBER = ADJ_CORP_DIR_CUST.PRODUCT_ID
    AND ADJ_CORP_DIR_CUST.IND_CUST_CD IS NULL 
    AND POS.FISCAL_SHIP_DATE  BETWEEN ADJ_CORP_DIR_CUST.EFFECTIVE_FROM_DATE AND ADJ_CORP_DIR_CUST.EFFECTIVE_TO_DATE 



------------- REFERENCE CORP WITH END CORP-------------
LEFT JOIN  REFERENCE_DESIGN_CUSTOMER REF_CORP
    ON POS.MARKET_PRODUCT_NUMBER = REF_CORP.PRODUCT_ID
    AND POS.DIRECT_CUSTOMER_CODE = REF_CORP.DIR_CUST_CD
    AND POS.INDIRECT_CUSTOMER_CODE = REF_CORP.IND_CUST_CD
    AND POS.END_CORPORATION_CODE = REF_CORP.END_CORP_CD
    AND POS.FISCAL_SHIP_DATE  BETWEEN REF_CORP.EFFECTIVE_FROM_DATE AND REF_CORP.EFFECTIVE_TO_DATE 
    
------------- REFERENCE END CORP WITH INDIRECT CUSTOMER (WHICH IS END CORP) -------------
LEFT JOIN  REFERENCE_DESIGN_CUSTOMER REF_CORP_INDIR_CUST
    ON POS.MARKET_PRODUCT_NUMBER = REF_CORP_INDIR_CUST.PRODUCT_ID
    AND POS.DIRECT_CUSTOMER_CODE = REF_CORP_INDIR_CUST.DIR_CUST_CD
    AND POS.INDIRECT_CUSTOMER_CODE = REF_CORP_INDIR_CUST.IND_CUST_CD
    AND POS.INDIRECT_CORPORATION_CODE= REF_CORP_INDIR_CUST.END_CORP_CD    
    AND POS.END_CORPORATION_CODE IS NULL
    AND POS.FISCAL_SHIP_DATE  BETWEEN REF_CORP_INDIR_CUST.EFFECTIVE_FROM_DATE AND REF_CORP_INDIR_CUST.EFFECTIVE_TO_DATE 

------------- REFERENCE END CORP WITH DIRECT CUSTOMER -------------
LEFT JOIN  REFERENCE_DESIGN_CUSTOMER REF_CORP_DIR_CUST
    ON POS.MARKET_PRODUCT_NUMBER = REF_CORP_DIR_CUST.PRODUCT_ID
    AND REF_CORP_DIR_CUST.IND_CUST_CD IS NULL 
    AND POS.FISCAL_SHIP_DATE  BETWEEN REF_CORP_DIR_CUST.EFFECTIVE_FROM_DATE AND REF_CORP_DIR_CUST.EFFECTIVE_TO_DATE 
)

SELECT 
    TRANSACTION_KEY,
    FISCAL_SHIP_DATE_KEY,
    ADJUSTED_END_CORPORATION_KEY,
    REFERENCE_CORPORATION_KEY,
    MARKET_PRODUCT_NUMBER_KEY,
    TRANSACTION_ID,
    FISCAL_SHIP_DATE,
    ADJUSTED_END_CORPORATION_CODE,
    REFERENCE_CORPORATION_CODE,
    MARKET_PRODUCT_NUMBER,
    '{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM ,
    '{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM ,
    {{V_BIW_BATCH_ID}} AS BIW_BATCH_ID,
    md5(object_construct ('col1',TRANSACTION_KEY, 'col2',FISCAL_SHIP_DATE_KEY, 'col3',MARKET_PRODUCT_NUMBER_KEY, 'col4',ADJUSTED_END_CORPORATION_KEY, 
    'col5',REFERENCE_CORPORATION_KEY, 'col6',FISCAL_SHIP_DATE, 'col7',MARKET_PRODUCT_NUMBER, 'col8',ADJUSTED_END_CORPORATION_CODE, 
    'col9',REFERENCE_CORPORATION_CODE)::string ) as BIW_MD5_KEY
FROM FINAL_SQL
