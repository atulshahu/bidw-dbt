--[   NPD_MSPROJECTS_TASKTIMEPHASEDDATASET_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF TASKTIMEPHASEDDATASET ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_TASKTIMEPHASEDDATASET_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
TASKTIMEPHASEDDATASET_KEY
, SNAPSHOT_WEEK_KEY
,PROJECTID
, TASKID
, TIMEBYDAY , CONVERT_TIMEZONE('UTC','America/Phoenix',TIMEBYDAY) AS BIW_TIMEBYDAY_MST
, FISCALPERIODID
, PROJECTNAME
, TASKACTUALCOST
, TASKACTUALWORK
, TASKBUDGETCOST
, TASKBUDGETWORK
, TASKCOST
, TASKISACTIVE
, TASKISPROJECTSUMMARY
, TASKMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',TASKMODIFIEDDATE) AS BIW_TASKMODIFIEDDATE_MST
, TASKNAME
, TASKOVERTIMEWORK
, TASKRESOURCEPLANWORK
, TASKWORK
, LINKEDPROJECT
, LINKEDTASK
, LINKEDTIME
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_TASKTIMEPHASEDDATASET_WEEKLY_SNAPSHOT')}}  
