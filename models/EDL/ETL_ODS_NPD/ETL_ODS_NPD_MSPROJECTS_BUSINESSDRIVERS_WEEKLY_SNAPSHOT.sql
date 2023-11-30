/*---------------------------------------------------------------------------
Command to run model:
-- dbt run --select ETL_ODS_NPD_MSPROJECTS_BUSINESSDRIVERS_WEEKLY_SNAPSHOT 
-- dbt build --full-refresh --select ETL_ODS_NPD_MSPROJECTS_BUSINESSDRIVERS_WEEKLY_SNAPSHOT 

Version     Date            Author              Description
-------     --------        -----------         ----------------------------------
1.0         25-JAN-2023     KALI DANDAPANI      Initial Version
---------------------------------------------------------------------------*/

{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['BUSINESSDRIVERID']-%}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ETL_ODS_NPD_MSPROJECTS_BUSINESSDRIVERS_WEEKLY_SNAPSHOT'-%}
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
         description = 'Building ETL table BUSINESSDRIVERS_WEEKLY_SNAPSHOT for NPD LANDING PROJECT'
        ,transient=true   
        ,materialized='table'
        ,schema ='ETL_ODS_NPD'
        ,alias= 'MSPROJECTS_BUSINESSDRIVERS_WEEKLY_SNAPSHOT'
        ,tags =['ODS_NPD']
        ,post_hook= [v_sql_upd_success_batch]	
        )
}}

WITH FISCAL_WEEK AS 
(
    SELECT 
        DISTINCT FISCAL_WEEK_KEY
    FROM 
    {{ref('MART_DATE') }}
    WHERE 
        CALENDAR_DATE = (CURRENT_TIMESTAMP() - INTERVAL '7 HOUR')::DATE
        or CALENDAR_DATE = (CURRENT_TIMESTAMP() )::DATE
)

,BUSINESSDRIVERS AS (
SELECT BUSINESSDRIVERID
, BUSINESSDRIVERCREATEDDATE
, BUSINESSDRIVERDESCRIPTION
, BUSINESSDRIVERISACTIVE
, BUSINESSDRIVERMODIFIEDDATE
, BUSINESSDRIVERNAME
, CREATEDBYRESOURCEID
, CREATEDBYRESOURCENAME
, IMPACTDESCRIPTIONEXTREME
, IMPACTDESCRIPTIONLOW
, IMPACTDESCRIPTIONMODERATE
, IMPACTDESCRIPTIONNONE
, IMPACTDESCRIPTIONSTRONG
, MODIFIEDBYRESOURCEID
, MODIFIEDBYRESOURCENAME
, LINKEDCREATEDBYRESOURCE
, LINKEDDEPARTMENTS
, LINKEDMODIFIEDBYRESOURCE
, BIW_INS_DTTM
, BIW_UPD_DTTM
FROM 
    {{source ('STG_NPD_MSPROJECTS_ODATAV1','BUSINESSDRIVERS')}}  
    QUALIFY( ROW_NUMBER() OVER (PARTITION BY BUSINESSDRIVERID  ORDER BY BIW_UPD_DTTM DESC) =1)
)

SELECT 
    MD5(OBJECT_CONSTRUCT (  'COL1',FSC_WK.FISCAL_WEEK_KEY::STRING
                            ,'COL2',STG.BUSINESSDRIVERID::STRING
                         )::STRING 
        )::BINARY AS BUSINESSDRIVERS_KEY 
    ,FSC_WK.FISCAL_WEEK_KEY AS SNAPSHOT_WEEK_KEY
    ,BUSINESSDRIVERID
, STG.BUSINESSDRIVERCREATEDDATE
, STG.BUSINESSDRIVERDESCRIPTION
, STG.BUSINESSDRIVERISACTIVE
, STG.BUSINESSDRIVERMODIFIEDDATE
, STG.BUSINESSDRIVERNAME
, STG.CREATEDBYRESOURCEID
, STG.CREATEDBYRESOURCENAME
, STG.IMPACTDESCRIPTIONEXTREME
, STG.IMPACTDESCRIPTIONLOW
, STG.IMPACTDESCRIPTIONMODERATE
, STG.IMPACTDESCRIPTIONNONE
, STG.IMPACTDESCRIPTIONSTRONG
, STG.MODIFIEDBYRESOURCEID
, STG.MODIFIEDBYRESOURCENAME
, STG.LINKEDCREATEDBYRESOURCE
, STG.LINKEDDEPARTMENTS
,STG.LINKEDMODIFIEDBYRESOURCE

,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM 
    ,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM 
   ,{{V_BIW_BATCH_ID}}::NUMBER as BIW_BATCH_ID ,
   md5(object_construct ('COL1',BUSINESSDRIVERID::string ,'COL2',BUSINESSDRIVERCREATEDDATE::string ,'COL3',BUSINESSDRIVERDESCRIPTION::string ,'COL4',BUSINESSDRIVERISACTIVE::string ,'COL5',BUSINESSDRIVERMODIFIEDDATE::string ,'COL6',BUSINESSDRIVERNAME::string ,'COL7',CREATEDBYRESOURCEID::string ,'COL8',CREATEDBYRESOURCENAME::string ,'COL9',IMPACTDESCRIPTIONEXTREME::string ,'COL10',IMPACTDESCRIPTIONLOW::string ,'COL11',IMPACTDESCRIPTIONMODERATE::string ,'COL12',IMPACTDESCRIPTIONNONE::string ,'COL13',IMPACTDESCRIPTIONSTRONG::string ,'COL14',MODIFIEDBYRESOURCEID::string ,'COL15',MODIFIEDBYRESOURCENAME::string ,'COL16',LINKEDCREATEDBYRESOURCE::string ,'COL17',LINKEDDEPARTMENTS::string ,'COL18',LINKEDMODIFIEDBYRESOURCE::string )::string )::BINARY as BIW_MD5_KEY

FROM     
BUSINESSDRIVERS  STG 

CROSS JOIN FISCAL_WEEK FSC_WK
