/*---------------------------------------------------------------------------
Command to run model:
-- dbt run --select ODS_NPD_MSPROJECTS_PROJECTS_WEEKLY_SNAPSHOT
-- dbt build --full-refresh --select ODS_NPD_MSPROJECTS_PROJECTS_WEEKLY_SNAPSHOT

Version     Date            Author              Description
-------     --------        -----------         ----------------------------------
1.0         25-JAN-2023     KALI DANDAPANI      Initial Version
---------------------------------------------------------------------------*/

{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['PROJECTS_KEY']-%}

{################# Batch control insert and update SQL #################}
{%- set v_dbt_job_name = 'DBT_ODS_NPD_MSPROJECTS_PROJECTS_WEEKLY_SNAPSHOT'-%}
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
         description = 'Building ODS table PROJECTS_WEEKLY_SNAPSHOT for NPD LANDING PROJECT'
        ,transient=false   
         ,materialized='incremental'
        ,schema ='ODS_NPD'
        ,alias= 'MSPROJECTS_PROJECTS_WEEKLY_SNAPSHOT'
        ,tags =['ODS_NPD']
        ,unique_key= v_pk_list
        ,merge_update_columns = ['PROJECTID','AGILE','BUSINESSUNIT','CSAGILE','DIVISIONPRIORITY','ENGRPRODOWNER','ENTERPRISEPROJECTTYPEDESCRIPTION','ENTERPRISEPROJECTTYPEID','ENTERPRISEPROJECTTYPEISDEFAULT','ENTERPRISEPROJECTTYPENAME','FINANCIAL','OPTIMIZERCOMMITDATE','OPTIMIZERDECISIONALIASLOOKUPTABLEID','OPTIMIZERDECISIONALIASLOOKUPTABLEVALUEID','OPTIMIZERDECISIONID','OPTIMIZERDECISIONNAME','OPTIMIZERSOLUTIONNAME','OSAGILE','OTHER','PARENTPROJECTID','PLANNERCOMMITDATE','PLANNERDECISIONALIASLOOKUPTABLEID','PLANNERDECISIONALIASLOOKUPTABLEVALUEID','PLANNERDECISIONID','PLANNERDECISIONNAME','PLANNERENDDATE','PLANNERSOLUTIONNAME','PLANNERSTARTDATE','PRODMRKTLEAD','PROJECTACTUALCOST','PROJECTACTUALDURATION','PROJECTACTUALFINISHDATE','PROJECTACTUALOVERTIMECOST','PROJECTACTUALOVERTIMEWORK','PROJECTACTUALREGULARCOST','PROJECTACTUALREGULARWORK','PROJECTACTUALSTARTDATE','PROJECTACTUALWORK','PROJECTACWP','PROJECTAUTHORNAME','PROJECTBCWP','PROJECTBCWS','PROJECTBUDGETCOST','PROJECTBUDGETWORK','PROJECTCALCULATIONSARESTALE','PROJECTCALENDARDURATION','PROJECTCATEGORYNAME','PROJECTCOMPANYNAME','PROJECTCOST','PROJECTCOSTVARIANCE','PROJECTCPI','PROJECTCREATEDDATE','PROJECTCURRENCY','PROJECTCV','PROJECTCVP','PROJECTDEPARTMENTS','PROJECTDESCRIPTION','PROJECTDURATION','PROJECTDURATIONVARIANCE','PROJECTEAC','PROJECTEARLYFINISH','PROJECTEARLYSTART','PROJECTEARNEDVALUEISSTALE','PROJECTENTERPRISEFEATURES','PROJECTFINISHDATE','PROJECTFINISHVARIANCE','PROJECTFIXEDCOST','PROJECTIDENTIFIER','PROJECTKEYWORDS','PROJECTLASTPUBLISHEDDATE','PROJECTLATEFINISH','PROJECTLATESTART','PROJECTMANAGERNAME','PROJECTMODIFIEDDATE','PROJECTNAME','PROJECTOVERTIMECOST','PROJECTOVERTIMEWORK','PROJECTOWNERID','PROJECTOWNERNAME','PROJECTPERCENTCOMPLETED','PROJECTPERCENTWORKCOMPLETED','PROJECTREGULARCOST','PROJECTREGULARWORK','PROJECTREMAININGCOST','PROJECTREMAININGDURATION','PROJECTREMAININGOVERTIMECOST','PROJECTREMAININGOVERTIMEWORK','PROJECTREMAININGREGULARCOST','PROJECTREMAININGREGULARWORK','PROJECTREMAININGWORK','PROJECTRESOURCEPLANWORK','PROJECTSPI','PROJECTSTARTDATE','PROJECTSTARTVARIANCE','PROJECTSTATUSDATE','PROJECTSUBJECT','PROJECTSV','PROJECTSVP','PROJECTTCPI','PROJECTTIMEPHASED','PROJECTTITLE','PROJECTTYPE','PROJECTVAC','PROJECTWORK','PROJECTWORKSPACEINTERNALURL','PROJECTWORKVARIANCE','RESOURCE','RESOURCEPLANUTILIZATIONDATE','RESOURCEPLANUTILIZATIONTYPE','SCHEDULE','SPEC','STATUSCOMMENTS','TOPPROJECT','WORKFLOWCREATEDDATE','WORKFLOWERROR','WORKFLOWERRORRESPONSECODE','WORKFLOWINSTANCEID','WORKFLOWOWNERID','WORKFLOWOWNERNAME','LINKEDASSIGNMENTBASELINES','LINKEDASSIGNMENTS','LINKEDDELIVERABLES','LINKEDDEPENDENCIES','LINKEDISSUES','LINKEDRISKS','LINKEDSTAGESINFO','LINKEDTASKS','BIW_UPD_DTTM','BIW_BATCH_ID','BIW_MD5_KEY']
        ,post_hook= [v_sql_upd_success_batch]	
        )
}}

SELECT 
STG.PROJECTS_KEY
,STG.SNAPSHOT_WEEK_KEY
,STG.PROJECTID
,STG.AGILE
,STG.BUSINESSUNIT
,STG.CSAGILE
,STG.DIVISIONPRIORITY
,STG.ENGRPRODOWNER
,STG.ENTERPRISEPROJECTTYPEDESCRIPTION
,STG.ENTERPRISEPROJECTTYPEID
,STG.ENTERPRISEPROJECTTYPEISDEFAULT
,STG.ENTERPRISEPROJECTTYPENAME
,STG.FINANCIAL
,STG.OPTIMIZERCOMMITDATE
,STG.OPTIMIZERDECISIONALIASLOOKUPTABLEID
,STG.OPTIMIZERDECISIONALIASLOOKUPTABLEVALUEID
,STG.OPTIMIZERDECISIONID
,STG.OPTIMIZERDECISIONNAME
,STG.OPTIMIZERSOLUTIONNAME
,STG.OSAGILE
,STG.OTHER
,STG.PARENTPROJECTID
,STG.PLANNERCOMMITDATE
,STG.PLANNERDECISIONALIASLOOKUPTABLEID
,STG.PLANNERDECISIONALIASLOOKUPTABLEVALUEID
,STG.PLANNERDECISIONID
,STG.PLANNERDECISIONNAME
,STG.PLANNERENDDATE
,STG.PLANNERSOLUTIONNAME
,STG.PLANNERSTARTDATE
,STG.PRODMRKTLEAD
,STG.PROJECTACTUALCOST
,STG.PROJECTACTUALDURATION
,STG.PROJECTACTUALFINISHDATE
,STG.PROJECTACTUALOVERTIMECOST
,STG.PROJECTACTUALOVERTIMEWORK
,STG.PROJECTACTUALREGULARCOST
,STG.PROJECTACTUALREGULARWORK
,STG.PROJECTACTUALSTARTDATE
,STG.PROJECTACTUALWORK
,STG.PROJECTACWP
,STG.PROJECTAUTHORNAME
,STG.PROJECTBCWP
,STG.PROJECTBCWS
,STG.PROJECTBUDGETCOST
,STG.PROJECTBUDGETWORK
,STG.PROJECTCALCULATIONSARESTALE
,STG.PROJECTCALENDARDURATION
,STG.PROJECTCATEGORYNAME
,STG.PROJECTCOMPANYNAME
,STG.PROJECTCOST
,STG.PROJECTCOSTVARIANCE
,STG.PROJECTCPI
,STG.PROJECTCREATEDDATE
,STG.PROJECTCURRENCY
,STG.PROJECTCV
,STG.PROJECTCVP
,STG.PROJECTDEPARTMENTS
,STG.PROJECTDESCRIPTION
,STG.PROJECTDURATION
,STG.PROJECTDURATIONVARIANCE
,STG.PROJECTEAC
,STG.PROJECTEARLYFINISH
,STG.PROJECTEARLYSTART
,STG.PROJECTEARNEDVALUEISSTALE
,STG.PROJECTENTERPRISEFEATURES
,STG.PROJECTFINISHDATE
,STG.PROJECTFINISHVARIANCE
,STG.PROJECTFIXEDCOST
,STG.PROJECTIDENTIFIER
,STG.PROJECTKEYWORDS
,STG.PROJECTLASTPUBLISHEDDATE
,STG.PROJECTLATEFINISH
,STG.PROJECTLATESTART
,STG.PROJECTMANAGERNAME
,STG.PROJECTMODIFIEDDATE
,STG.PROJECTNAME
,STG.PROJECTOVERTIMECOST
,STG.PROJECTOVERTIMEWORK
,STG.PROJECTOWNERID
,STG.PROJECTOWNERNAME
,STG.PROJECTPERCENTCOMPLETED
,STG.PROJECTPERCENTWORKCOMPLETED
,STG.PROJECTREGULARCOST
,STG.PROJECTREGULARWORK
,STG.PROJECTREMAININGCOST
,STG.PROJECTREMAININGDURATION
,STG.PROJECTREMAININGOVERTIMECOST
,STG.PROJECTREMAININGOVERTIMEWORK
,STG.PROJECTREMAININGREGULARCOST
,STG.PROJECTREMAININGREGULARWORK
,STG.PROJECTREMAININGWORK
,STG.PROJECTRESOURCEPLANWORK
,STG.PROJECTSPI
,STG.PROJECTSTARTDATE
,STG.PROJECTSTARTVARIANCE
,STG.PROJECTSTATUSDATE
,STG.PROJECTSUBJECT
,STG.PROJECTSV
,STG.PROJECTSVP
,STG.PROJECTTCPI
,STG.PROJECTTIMEPHASED
,STG.PROJECTTITLE
,STG.PROJECTTYPE
,STG.PROJECTVAC
,STG.PROJECTWORK
,STG.PROJECTWORKSPACEINTERNALURL
,STG.PROJECTWORKVARIANCE
,STG.RESOURCE
,STG.RESOURCEPLANUTILIZATIONDATE
,STG.RESOURCEPLANUTILIZATIONTYPE
,STG.SCHEDULE
,STG.SPEC
,STG.STATUSCOMMENTS
,STG.TOPPROJECT
,STG.WORKFLOWCREATEDDATE
,STG.WORKFLOWERROR
,STG.WORKFLOWERRORRESPONSECODE
,STG.WORKFLOWINSTANCEID
,STG.WORKFLOWOWNERID
,STG.WORKFLOWOWNERNAME
,STG.LINKEDASSIGNMENTBASELINES
,STG.LINKEDASSIGNMENTS
,STG.LINKEDDELIVERABLES
,STG.LINKEDDEPENDENCIES
,STG.LINKEDISSUES
,STG.LINKEDRISKS
,STG.LINKEDSTAGESINFO
,STG.LINKEDTASKS
,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM 
    ,'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM 
   ,{{V_BIW_BATCH_ID}}::NUMBER as BIW_BATCH_ID ,STG.BIW_MD5_KEY
    FROM 
        {{ref ('ETL_ODS_NPD_MSPROJECTS_PROJECTS_WEEKLY_SNAPSHOT')}}  STG  
{% if is_incremental() %}
  LEFT JOIN {{ this }} TGT
  on STG.PROJECTS_KEY= TGT.PROJECTS_KEY
  WHERE TGT.BIW_MD5_KEY<>STG.BIW_MD5_KEY OR TGT.BIW_MD5_KEY IS NULL
{% endif %}