/*---------------------------------------------------------------------------
Command to run model:
-- dbt run --select ODS_NPD_MSPROJECTS_TASKS_WEEKLY_SNAPSHOT
-- dbt build --full-refresh --select ODS_NPD_MSPROJECTS_TASKS_WEEKLY_SNAPSHOT

Version     Date            Author              Description
-------     --------        -----------         ----------------------------------
1.0         25-JAN-2023     KALI DANDAPANI      Initial Version
---------------------------------------------------------------------------*/

{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['TASKS_KEY']-%}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ODS_NPD_MSPROJECTS_TASKS_WEEKLY_SNAPSHOT'-%}
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
         description = 'Building ODS table TASKS_WEEKLY_SNAPSHOT for NPD LANDING PROJECT'
        ,transient=false   
         ,materialized='incremental'
        ,schema ='ODS_NPD'
        ,alias= 'MSPROJECTS_TASKS_WEEKLY_SNAPSHOT'
        ,tags =['ODS_NPD']
        ,unique_key= v_pk_list
        ,merge_update_columns = ['PROJECTID','TASKID','DETECTABILITY','FLAGSTATUS','HEALTH','IMPACT','MITIGATIONFLAG','NPDGATE','NPDMILESTONE','PARENTTASKID','PARENTTASKNAME','PROBABILITY','PROJECTNAME','RISK','RISKFLAG','RISKLEVEL','RISKSCORE','TASKACTUALCOST','TASKACTUALDURATION','TASKACTUALFINISHDATE','TASKACTUALFIXEDCOST','TASKACTUALOVERTIMECOST','TASKACTUALOVERTIMEWORK','TASKACTUALREGULARCOST','TASKACTUALREGULARWORK','TASKACTUALSTARTDATE','TASKACTUALWORK','TASKACWP','TASKBCWP','TASKBCWS','TASKBUDGETCOST','TASKBUDGETWORK','TASKCLIENTUNIQUEID','TASKCOST','TASKCOSTVARIANCE','TASKCPI','TASKCREATEDDATE','TASKCREATEDREVISIONCOUNTER','TASKCV','TASKCVP','TASKDEADLINE','TASKDELIVERABLEFINISHDATE','TASKDELIVERABLESTARTDATE','TASKDURATION','TASKDURATIONISESTIMATED','TASKDURATIONSTRING','TASKDURATIONVARIANCE','TASKEAC','TASKEARLYFINISH','TASKEARLYSTART','TASKFINISHDATE','TASKFINISHDATESTRING','TASKFINISHVARIANCE','TASKFIXEDCOST','TASKFIXEDCOSTASSIGNMENTID','TASKFREESLACK','TASKHYPERLINKADDRESS','TASKHYPERLINKFRIENDLYNAME','TASKHYPERLINKSUBADDRESS','TASKIGNORESRESOURCECALENDAR','TASKINDEX','TASKISACTIVE','TASKISCRITICAL','TASKISEFFORTDRIVEN','TASKISEXTERNAL','TASKISMANUALLYSCHEDULED','TASKISMARKED','TASKISMILESTONE','TASKISOVERALLOCATED','TASKISPROJECTSUMMARY','TASKISRECURRING','TASKISSUMMARY','TASKLATEFINISH','TASKLATESTART','TASKLEVELINGDELAY','TASKMODIFIEDDATE','TASKMODIFIEDREVISIONCOUNTER','TASKNAME','TASKOUTLINELEVEL','TASKOUTLINENUMBER','TASKOVERTIMECOST','TASKOVERTIMEWORK','TASKPERCENTCOMPLETED','TASKPERCENTWORKCOMPLETED','TASKPHYSICALPERCENTCOMPLETED','TASKPRIORITY','TASKREGULARCOST','TASKREGULARWORK','TASKREMAININGCOST','TASKREMAININGDURATION','TASKREMAININGOVERTIMECOST','TASKREMAININGOVERTIMEWORK','TASKREMAININGREGULARCOST','TASKREMAININGREGULARWORK','TASKREMAININGWORK','TASKRESOURCEPLANWORK','TASKSPI','TASKSTARTDATE','TASKSTARTDATESTRING','TASKSTARTVARIANCE','TASKSTATUSMANAGERUID','TASKSV','TASKSVP','TASKTCPI','TASKTOTALSLACK','TASKVAC','TASKWBS','TASKWORK','TASKWORKVARIANCE','LINKEDASSIGNMENTS','LINKEDASSIGNMENTSBASELINES','LINKEDASSIGNMENTSBASELINETIMEPHASEDDATA','LINKEDBASELINES','LINKEDBASELINESTIMEPHASEDDATASET','LINKEDISSUES','LINKEDPROJECT','LINKEDRISKS','LINKEDTIMEPHASEDINFO','BIW_UPD_DTTM','BIW_BATCH_ID','BIW_MD5_KEY']
        ,post_hook= [v_sql_upd_success_batch]	
        )
}}

SELECT 
STG.TASKS_KEY
,STG.SNAPSHOT_WEEK_KEY
,STG.PROJECTID
,STG.TASKID
,STG.DETECTABILITY
,STG.FLAGSTATUS
,STG.HEALTH
,STG.IMPACT
,STG.MITIGATIONFLAG
,STG.NPDGATE
,STG.NPDMILESTONE
,STG.PARENTTASKID
,STG.PARENTTASKNAME
,STG.PROBABILITY
,STG.PROJECTNAME
,STG.RISK
,STG.RISKFLAG
,STG.RISKLEVEL
,STG.RISKSCORE
,STG.TASKACTUALCOST
,STG.TASKACTUALDURATION
,STG.TASKACTUALFINISHDATE
,STG.TASKACTUALFIXEDCOST
,STG.TASKACTUALOVERTIMECOST
,STG.TASKACTUALOVERTIMEWORK
,STG.TASKACTUALREGULARCOST
,STG.TASKACTUALREGULARWORK
,STG.TASKACTUALSTARTDATE
,STG.TASKACTUALWORK
,STG.TASKACWP
,STG.TASKBCWP
,STG.TASKBCWS
,STG.TASKBUDGETCOST
,STG.TASKBUDGETWORK
,STG.TASKCLIENTUNIQUEID
,STG.TASKCOST
,STG.TASKCOSTVARIANCE
,STG.TASKCPI
,STG.TASKCREATEDDATE
,STG.TASKCREATEDREVISIONCOUNTER
,STG.TASKCV
,STG.TASKCVP
,STG.TASKDEADLINE
,STG.TASKDELIVERABLEFINISHDATE
,STG.TASKDELIVERABLESTARTDATE
,STG.TASKDURATION
,STG.TASKDURATIONISESTIMATED
,STG.TASKDURATIONSTRING
,STG.TASKDURATIONVARIANCE
,STG.TASKEAC
,STG.TASKEARLYFINISH
,STG.TASKEARLYSTART
,STG.TASKFINISHDATE
,STG.TASKFINISHDATESTRING
,STG.TASKFINISHVARIANCE
,STG.TASKFIXEDCOST
,STG.TASKFIXEDCOSTASSIGNMENTID
,STG.TASKFREESLACK
,STG.TASKHYPERLINKADDRESS
,STG.TASKHYPERLINKFRIENDLYNAME
,STG.TASKHYPERLINKSUBADDRESS
,STG.TASKIGNORESRESOURCECALENDAR
,STG.TASKINDEX
,STG.TASKISACTIVE
,STG.TASKISCRITICAL
,STG.TASKISEFFORTDRIVEN
,STG.TASKISEXTERNAL
,STG.TASKISMANUALLYSCHEDULED
,STG.TASKISMARKED
,STG.TASKISMILESTONE
,STG.TASKISOVERALLOCATED
,STG.TASKISPROJECTSUMMARY
,STG.TASKISRECURRING
,STG.TASKISSUMMARY
,STG.TASKLATEFINISH
,STG.TASKLATESTART
,STG.TASKLEVELINGDELAY
,STG.TASKMODIFIEDDATE
,STG.TASKMODIFIEDREVISIONCOUNTER
,STG.TASKNAME
,STG.TASKOUTLINELEVEL
,STG.TASKOUTLINENUMBER
,STG.TASKOVERTIMECOST
,STG.TASKOVERTIMEWORK
,STG.TASKPERCENTCOMPLETED
,STG.TASKPERCENTWORKCOMPLETED
,STG.TASKPHYSICALPERCENTCOMPLETED
,STG.TASKPRIORITY
,STG.TASKREGULARCOST
,STG.TASKREGULARWORK
,STG.TASKREMAININGCOST
,STG.TASKREMAININGDURATION
,STG.TASKREMAININGOVERTIMECOST
,STG.TASKREMAININGOVERTIMEWORK
,STG.TASKREMAININGREGULARCOST
,STG.TASKREMAININGREGULARWORK
,STG.TASKREMAININGWORK
,STG.TASKRESOURCEPLANWORK
,STG.TASKSPI
,STG.TASKSTARTDATE
,STG.TASKSTARTDATESTRING
,STG.TASKSTARTVARIANCE
,STG.TASKSTATUSMANAGERUID
,STG.TASKSV
,STG.TASKSVP
,STG.TASKTCPI
,STG.TASKTOTALSLACK
,STG.TASKVAC
,STG.TASKWBS
,STG.TASKWORK
,STG.TASKWORKVARIANCE
,STG.LINKEDASSIGNMENTS
,STG.LINKEDASSIGNMENTSBASELINES
,STG.LINKEDASSIGNMENTSBASELINETIMEPHASEDDATA
,STG.LINKEDBASELINES
,STG.LINKEDBASELINESTIMEPHASEDDATASET
,STG.LINKEDISSUES
,STG.LINKEDPROJECT
,STG.LINKEDRISKS
,STG.LINKEDTIMEPHASEDINFO
,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM 
,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM 
,{{V_BIW_BATCH_ID}}::NUMBER as BIW_BATCH_ID 
,STG.BIW_MD5_KEY
    FROM 
        {{ref ('ETL_ODS_NPD_MSPROJECTS_TASKS_WEEKLY_SNAPSHOT')}}  STG  
{% if is_incremental() %}
  LEFT JOIN {{ this }} TGT
  on STG.TASKS_KEY= TGT.TASKS_KEY
  WHERE TGT.BIW_MD5_KEY<>STG.BIW_MD5_KEY OR TGT.BIW_MD5_KEY IS NULL
{% endif %}