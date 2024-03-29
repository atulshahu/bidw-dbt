--[   NPD_MSPROJECTS_ISSUETASKASSOCIATIONS_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF ISSUETASKASSOCIATIONS ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_ISSUETASKASSOCIATIONS_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
ISSUETASKASSOCIATIONS_KEY
, SNAPSHOT_WEEK_KEY
,ISSUEID
, PROJECTID
, RELATIONSHIPTYPE
, TASKID
, PROJECTNAME
, RELATEDPROJECTID
, RELATEDPROJECTNAME
, TASKNAME
, TITLE
, LINKEDISSUE
, LINKEDPROJECT
, LINKEDRELATEDPROJECT
, LINKEDTASK
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_ISSUETASKASSOCIATIONS_WEEKLY_SNAPSHOT')}}  
