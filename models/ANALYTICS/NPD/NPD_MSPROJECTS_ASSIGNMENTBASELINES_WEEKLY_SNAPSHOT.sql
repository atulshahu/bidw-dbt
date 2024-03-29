--[   NPD_MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF ASSIGNMENTBASELINES ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
ASSIGNMENTBASELINES_KEY
, SNAPSHOT_WEEK_KEY
,ASSIGNMENTID
, BASELINENUMBER
, PROJECTID
, ASSIGNMENTBASELINEBUDGETCOST
, ASSIGNMENTBASELINEBUDGETMATERIALWORK
, ASSIGNMENTBASELINEBUDGETWORK
, ASSIGNMENTBASELINECOST
, ASSIGNMENTBASELINEFINISHDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTBASELINEFINISHDATE) AS BIW_ASSIGNMENTBASELINEFINISHDATE_MST
, ASSIGNMENTBASELINEMATERIALWORK
, ASSIGNMENTBASELINEMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTBASELINEMODIFIEDDATE) AS BIW_ASSIGNMENTBASELINEMODIFIEDDATE_MST
, ASSIGNMENTBASELINESTARTDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTBASELINESTARTDATE) AS BIW_ASSIGNMENTBASELINESTARTDATE_MST
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
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_ASSIGNMENTBASELINES_WEEKLY_SNAPSHOT')}}  
