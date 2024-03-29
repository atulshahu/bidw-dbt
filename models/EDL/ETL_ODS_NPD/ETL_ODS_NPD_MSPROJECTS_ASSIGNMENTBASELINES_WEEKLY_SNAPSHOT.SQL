/*---------------------------------------------------------------------------
Command to run model:
-- dbt run --select ETL_ODS_NPD_MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT 
-- dbt build --full-refresh --select ETL_ODS_NPD_MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT 
pk: AssignmentId ,BaselineNumber ,ProjectId 
Version     Date            Author              Description
-------     --------        -----------         ----------------------------------
1.0         25-JAN-2023     KALI DANDAPANI      Initial Version
---------------------------------------------------------------------------*/

{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['ASSIGNMENTID','BaselineNumber','ProjectId']-%}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ETL_ODS_NPD_MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT'-%}
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
         description = 'Building ETL table ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT for NPD LANDING PROJECT'
        ,transient=true   
        ,materialized='table'
        ,schema ='ETL_ODS_NPD'
        ,alias= 'MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT'
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

,ASSIGNMENTBASELINES AS (
SELECT ASSIGNMENTID
, BASELINENUMBER
, PROJECTID
, ASSIGNMENTBASELINEBUDGETCOST
, ASSIGNMENTBASELINEBUDGETMATERIALWORK
, ASSIGNMENTBASELINEBUDGETWORK
, ASSIGNMENTBASELINECOST
, ASSIGNMENTBASELINEFINISHDATE
, ASSIGNMENTBASELINEMATERIALWORK
, ASSIGNMENTBASELINEMODIFIEDDATE
, ASSIGNMENTBASELINESTARTDATE
, ASSIGNMENTBASELINEWORK
, ASSIGNMENTTYPE
, PROJECTNAME
, TASKID
, TASKNAME
, LINKEDASSIGNMENT
, LINKEDASSIGNMENTBASELINETIMEPHASEDDATASET
, LINKEDPROJECT
, LINKEDTASK
, BIW_INS_DTTM
, BIW_UPD_DTTM
FROM 
    {{source ('STG_NPD_MSPROJECTS_ODATAV1','ASSIGNMENTBASELINES')}}  
    QUALIFY( ROW_NUMBER() OVER (PARTITION BY AssignmentId ,BaselineNumber ,ProjectId   ORDER BY BIW_UPD_DTTM DESC) =1)
)

SELECT 
    MD5(OBJECT_CONSTRUCT (  'COL1',FSC_WK.FISCAL_WEEK_KEY::STRING
                            ,'COL2',STG.ASSIGNMENTID::STRING
                            ,'COL3',STG.BaselineNumber::STRING 
                            ,'COL4',STG.ProjectId::STRING 
                         )::STRING 
        )::BINARY AS ASSIGNMENTBASELINES_KEY 
    ,FSC_WK.FISCAL_WEEK_KEY AS SNAPSHOT_WEEK_KEY
    ,ASSIGNMENTID
, STG.BASELINENUMBER
, STG.PROJECTID
, STG.ASSIGNMENTBASELINEBUDGETCOST
, STG.ASSIGNMENTBASELINEBUDGETMATERIALWORK
, STG.ASSIGNMENTBASELINEBUDGETWORK
, STG.ASSIGNMENTBASELINECOST
, STG.ASSIGNMENTBASELINEFINISHDATE
, STG.ASSIGNMENTBASELINEMATERIALWORK
, STG.ASSIGNMENTBASELINEMODIFIEDDATE
, STG.ASSIGNMENTBASELINESTARTDATE
, STG.ASSIGNMENTBASELINEWORK
, STG.ASSIGNMENTTYPE
, STG.PROJECTNAME
, STG.TASKID
, STG.TASKNAME
, STG.LINKEDASSIGNMENT
, STG.LINKEDASSIGNMENTBASELINETIMEPHASEDDATASET
, STG.LINKEDPROJECT
, STG.LINKEDTASK
,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM 
,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM 
,{{V_BIW_BATCH_ID}}::NUMBER as BIW_BATCH_ID
,md5(object_construct ('COL1',ASSIGNMENTID::string ,'COL2',BASELINENUMBER::string ,'COL3',PROJECTID::string ,'COL4',ASSIGNMENTBASELINEBUDGETCOST::string ,'COL5',ASSIGNMENTBASELINEBUDGETMATERIALWORK::string ,'COL6',ASSIGNMENTBASELINEBUDGETWORK::string ,'COL7',ASSIGNMENTBASELINECOST::string ,'COL8',ASSIGNMENTBASELINEFINISHDATE::string ,'COL9',ASSIGNMENTBASELINEMATERIALWORK::string ,'COL10',ASSIGNMENTBASELINEMODIFIEDDATE::string ,'COL11',ASSIGNMENTBASELINESTARTDATE::string ,'COL12',ASSIGNMENTBASELINEWORK::string ,'COL13',ASSIGNMENTTYPE::string ,'COL14',PROJECTNAME::string ,'COL15',TASKID::string ,'COL16',TASKNAME::string ,'COL17',LINKEDASSIGNMENT::string ,'COL18',LINKEDASSIGNMENTBASELINETIMEPHASEDDATASET::string ,'COL19',LINKEDPROJECT::string ,'COL20',LINKEDTASK::string)::string )::BINARY as BIW_MD5_KEY

FROM     
ASSIGNMENTBASELINES  STG 

CROSS JOIN FISCAL_WEEK FSC_WK
