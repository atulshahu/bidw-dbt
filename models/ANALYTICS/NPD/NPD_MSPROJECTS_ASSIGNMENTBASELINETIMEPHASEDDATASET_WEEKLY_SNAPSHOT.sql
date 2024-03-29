--[   NPD_MSPROJECTS_ASSIGNMENTBASELINETIMEPHASEDDATASET_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF ASSIGNMENTBASELINETIMEPHASEDDATASET ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_ASSIGNMENTBASELINETIMEPHASEDDATASET_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
ASSIGNMENTBASELINETIMEPHASEDDATASET_KEY
, SNAPSHOT_WEEK_KEY
,ASSIGNMENTID
, BASELINENUMBER
, PROJECTID
, TIMEBYDAY , CONVERT_TIMEZONE('UTC','America/Phoenix',TIMEBYDAY) AS BIW_TIMEBYDAY_MST
, ASSIGNMENTBASELINEBUDGETCOST
, ASSIGNMENTBASELINEBUDGETMATERIALWORK
, ASSIGNMENTBASELINEBUDGETWORK
, ASSIGNMENTBASELINECOST
, ASSIGNMENTBASELINEMATERIALWORK
, ASSIGNMENTBASELINEMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTBASELINEMODIFIEDDATE) AS BIW_ASSIGNMENTBASELINEMODIFIEDDATE_MST
, ASSIGNMENTBASELINEWORK
, FISCALPERIODID
, PROJECTNAME
, RESOURCEID
, TASKID
, TASKNAME
, LINKEDASSIGNMENT
, LINKEDBASELINE
, LINKEDPROJECT
, LINKEDTASKS
, LINKEDTIME
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_ASSIGNMENTBASELINETIMEPHASEDDATASET_WEEKLY_SNAPSHOT')}}  
