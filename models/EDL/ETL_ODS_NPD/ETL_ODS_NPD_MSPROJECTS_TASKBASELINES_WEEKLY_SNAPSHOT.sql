
/*---------------------------------------------------------------------------
Command to run model:
-- dbt run --select ETL_ODS_NPD_MSPROJECTS_TASKBASELINES_WEEKLY_SNAPSHOT 
-- dbt build --full-refresh --select ETL_ODS_NPD_MSPROJECTS_TASKBASELINES_WEEKLY_SNAPSHOT 

Version     Date            Author              Description
-------     --------        -----------         ----------------------------------
1.0         25-JAN-2023     KALI DANDAPANI      Initial Version
---------------------------------------------------------------------------*/

{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['BASELINENUMBER','PROJECTID','TASKID']-%}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ETL_ODS_NPD_MSPROJECTS_TASKBASELINES_WEEKLY_SNAPSHOT'-%}
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
         description = 'Building ETL table TASKBASELINES_WEEKLY_SNAPSHOT for NPD LANDING PROJECT'
        ,transient=true   
        ,materialized='table'
        ,schema ='ETL_ODS_NPD'
        ,alias= 'MSPROJECTS_TASKBASELINES_WEEKLY_SNAPSHOT'
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

,TASKBASELINES AS (
SELECT BASELINENUMBER
, PROJECTID
, TASKID
, PROJECTNAME
, TASKBASELINEBUDGETCOST
, TASKBASELINEBUDGETWORK
, TASKBASELINECOST
, TASKBASELINEDELIVERABLEFINISHDATE
, TASKBASELINEDELIVERABLESTARTDATE
, TASKBASELINEDURATION
, TASKBASELINEDURATIONSTRING
, TASKBASELINEFINISHDATE
, TASKBASELINEFINISHDATESTRING
, TASKBASELINEFIXEDCOST
, TASKBASELINEMODIFIEDDATE
, TASKBASELINESTARTDATE
, TASKBASELINESTARTDATESTRING
, TASKBASELINEWORK
, TASKNAME
, LINKEDPROJECT
, LINKEDTASK
, LINKEDTASKBASELINETIMEPHASEDDATASET
, BIW_INS_DTTM
, BIW_UPD_DTTM
FROM 
    {{source ('STG_NPD_MSPROJECTS_ODATAV1','TASKBASELINES')}}  
    QUALIFY( ROW_NUMBER() OVER (PARTITION BY BASELINENUMBER,PROJECTID,TASKID  ORDER BY BIW_UPD_DTTM DESC) =1)
)

SELECT 
    MD5(OBJECT_CONSTRUCT (  'COL1',FSC_WK.FISCAL_WEEK_KEY::STRING
                            ,'COL2',STG.BASELINENUMBER::STRING
                            ,'COL3',STG.PROJECTID::STRING
                            ,'COL4',STG.TASKID::STRING
                         )::STRING 
        )::BINARY AS TASKBASELINES_KEY 
    ,FSC_WK.FISCAL_WEEK_KEY AS SNAPSHOT_WEEK_KEY
    ,BASELINENUMBER
, STG.PROJECTID
, STG.TASKID
, STG.PROJECTNAME
, STG.TASKBASELINEBUDGETCOST
, STG.TASKBASELINEBUDGETWORK
, STG.TASKBASELINECOST
, STG.TASKBASELINEDELIVERABLEFINISHDATE
, STG.TASKBASELINEDELIVERABLESTARTDATE
, STG.TASKBASELINEDURATION
, STG.TASKBASELINEDURATIONSTRING
, STG.TASKBASELINEFINISHDATE
, STG.TASKBASELINEFINISHDATESTRING
, STG.TASKBASELINEFIXEDCOST
, STG.TASKBASELINEMODIFIEDDATE
, STG.TASKBASELINESTARTDATE
, STG.TASKBASELINESTARTDATESTRING
, STG.TASKBASELINEWORK
, STG.TASKNAME
, STG.LINKEDPROJECT
, STG.LINKEDTASK
,STG.LINKEDTASKBASELINETIMEPHASEDDATASET
,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM 
    ,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM 
   ,{{V_BIW_BATCH_ID}}::NUMBER as BIW_BATCH_ID 
   ,md5(object_construct ('COL1',BASELINENUMBER::string ,'COL2',PROJECTID::string ,'COL3',TASKID::string ,'COL4',PROJECTNAME::string ,'COL5',TASKBASELINEBUDGETCOST::string ,'COL6',TASKBASELINEBUDGETWORK::string ,'COL7',TASKBASELINECOST::string ,'COL8',TASKBASELINEDELIVERABLEFINISHDATE::string ,'COL9',TASKBASELINEDELIVERABLESTARTDATE::string ,'COL10',TASKBASELINEDURATION::string ,'COL11',TASKBASELINEDURATIONSTRING::string ,'COL12',TASKBASELINEFINISHDATE::string ,'COL13',TASKBASELINEFINISHDATESTRING::string ,'COL14',TASKBASELINEFIXEDCOST::string ,'COL15',TASKBASELINEMODIFIEDDATE::string ,'COL16',TASKBASELINESTARTDATE::string ,'COL17',TASKBASELINESTARTDATESTRING::string ,'COL18',TASKBASELINEWORK::string ,'COL19',TASKNAME::string ,'COL20',LINKEDPROJECT::string ,'COL21',LINKEDTASK::string ,'COL22',LINKEDTASKBASELINETIMEPHASEDDATASET::string )::string )::BINARY as BIW_MD5_KEY

FROM     
TASKBASELINES  STG 

CROSS JOIN FISCAL_WEEK FSC_WK
