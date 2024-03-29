--[   NPD_MSPROJECTS_RISKTASKASSOCIATIONS_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF RISKTASKASSOCIATIONS ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_RISKTASKASSOCIATIONS_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
RISKTASKASSOCIATIONS_KEY
, SNAPSHOT_WEEK_KEY
,PROJECTID
, RELATIONSHIPTYPE
, RISKID
, TASKID
, PROJECTNAME
, RELATEDPROJECTID
, RELATEDPROJECTNAME
, TASKNAME
, TITLE
, LINKEDPROJECT
, LINKEDRELATEDPROJECT
, LINKEDRISK
, LINKEDTASK
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_RISKTASKASSOCIATIONS_WEEKLY_SNAPSHOT')}}  
