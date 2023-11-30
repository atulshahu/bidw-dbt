/*---------------------------------------------------------------------------
Command to run model:
-- dbt run --select ETL_ODS_NPD_MSPROJECTS_COSTCONSTRAINTSCENARIOS_WEEKLY_SNAPSHOT 
-- dbt build --full-refresh --select ETL_ODS_NPD_MSPROJECTS_COSTCONSTRAINTSCENARIOS_WEEKLY_SNAPSHOT 

Version     Date            Author              Description
-------     --------        -----------         ----------------------------------
1.0         25-JAN-2023     KALI DANDAPANI      Initial Version
---------------------------------------------------------------------------*/

{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['SCENARIOID']-%}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ETL_ODS_NPD_MSPROJECTS_COSTCONSTRAINTSCENARIOS_WEEKLY_SNAPSHOT'-%}
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
         description = 'Building ETL table COSTCONSTRAINTSCENARIOS_WEEKLY_SNAPSHOT for NPD LANDING PROJECT'
        ,transient=true   
        ,materialized='table'
        ,schema ='ETL_ODS_NPD'
        ,alias= 'MSPROJECTS_COSTCONSTRAINTSCENARIOS_WEEKLY_SNAPSHOT'
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

,COSTCONSTRAINTSCENARIOS AS (
SELECT SCENARIOID
, ANALYSISID
, ANALYSISNAME
, CREATEDBYRESOURCEID
, CREATEDBYRESOURCENAME
, CREATEDDATE
, MODIFIEDBYRESOURCEID
, MODIFIEDBYRESOURCENAME
, MODIFIEDDATE
, SCENARIODESCRIPTION
, SCENARIONAME
, SELECTEDPROJECTSCOST
, SELECTEDPROJECTSPRIORITY
, UNSELECTEDPROJECTSCOST
, UNSELECTEDPROJECTSPRIORITY
, USEDEPENDENCIES
, LINKEDANALYSIS
, LINKEDCOSTSCENARIOPROJECTS
, LINKEDCREATEDBYRESOURCE
, LINKEDMODIFIEDBYRESOURCE
, LINKEDRESOURCECONSTRAINTSCENARIOS
, BIW_INS_DTTM
, BIW_UPD_DTTM
FROM 
    {{source ('STG_NPD_MSPROJECTS_ODATAV1','COSTCONSTRAINTSCENARIOS')}}  
    QUALIFY( ROW_NUMBER() OVER (PARTITION BY SCENARIOID  ORDER BY BIW_UPD_DTTM DESC) =1)
)

SELECT 
    MD5(OBJECT_CONSTRUCT (  'COL1',FSC_WK.FISCAL_WEEK_KEY::STRING
                            ,'COL2',STG.SCENARIOID::STRING
                         )::STRING 
        )::BINARY AS COSTCONSTRAINTSCENARIOS_KEY 
    ,FSC_WK.FISCAL_WEEK_KEY AS SNAPSHOT_WEEK_KEY
    ,SCENARIOID
, STG.ANALYSISID
, STG.ANALYSISNAME
, STG.CREATEDBYRESOURCEID
, STG.CREATEDBYRESOURCENAME
, STG.CREATEDDATE
, STG.MODIFIEDBYRESOURCEID
, STG.MODIFIEDBYRESOURCENAME
, STG.MODIFIEDDATE
, STG.SCENARIODESCRIPTION
, STG.SCENARIONAME
, STG.SELECTEDPROJECTSCOST
, STG.SELECTEDPROJECTSPRIORITY
, STG.UNSELECTEDPROJECTSCOST
, STG.UNSELECTEDPROJECTSPRIORITY
, STG.USEDEPENDENCIES
, STG.LINKEDANALYSIS
, STG.LINKEDCOSTSCENARIOPROJECTS
, STG.LINKEDCREATEDBYRESOURCE
, STG.LINKEDMODIFIEDBYRESOURCE
,STG.LINKEDRESOURCECONSTRAINTSCENARIOS

,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM 
    ,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM 
   ,{{V_BIW_BATCH_ID}}::NUMBER as BIW_BATCH_ID ,
   md5(object_construct ('COL1',SCENARIOID::string ,'COL2',ANALYSISID::string ,'COL3',ANALYSISNAME::string ,'COL4',CREATEDBYRESOURCEID::string ,'COL5',CREATEDBYRESOURCENAME::string ,'COL6',CREATEDDATE::string ,'COL7',MODIFIEDBYRESOURCEID::string ,'COL8',MODIFIEDBYRESOURCENAME::string ,'COL9',MODIFIEDDATE::string ,'COL10',SCENARIODESCRIPTION::string ,'COL11',SCENARIONAME::string ,'COL12',SELECTEDPROJECTSCOST::string ,'COL13',SELECTEDPROJECTSPRIORITY::string ,'COL14',UNSELECTEDPROJECTSCOST::string ,'COL15',UNSELECTEDPROJECTSPRIORITY::string ,'COL16',USEDEPENDENCIES::string ,'COL17',LINKEDANALYSIS::string ,'COL18',LINKEDCOSTSCENARIOPROJECTS::string ,'COL19',LINKEDCREATEDBYRESOURCE::string ,'COL20',LINKEDMODIFIEDBYRESOURCE::string ,'COL21',LINKEDRESOURCECONSTRAINTSCENARIOS::string )::string )::BINARY as BIW_MD5_KEY

FROM     
COSTCONSTRAINTSCENARIOS  STG 

CROSS JOIN FISCAL_WEEK FSC_WK
