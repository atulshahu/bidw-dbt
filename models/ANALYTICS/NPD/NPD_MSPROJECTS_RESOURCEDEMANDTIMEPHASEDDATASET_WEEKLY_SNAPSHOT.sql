--[   NPD_MSPROJECTS_RESOURCEDEMANDTIMEPHASEDDATASET_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF RESOURCEDEMANDTIMEPHASEDDATASET ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_RESOURCEDEMANDTIMEPHASEDDATASET_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
RESOURCEDEMANDTIMEPHASEDDATASET_KEY
, SNAPSHOT_WEEK_KEY
,PROJECTID
, RESOURCEID
, TIMEBYDAY , CONVERT_TIMEZONE('UTC','America/Phoenix',TIMEBYDAY) AS BIW_TIMEBYDAY_MST
, FISCALPERIODID
, PROJECTNAME
, RESOURCEDEMAND
, RESOURCEDEMANDMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCEDEMANDMODIFIEDDATE) AS BIW_RESOURCEDEMANDMODIFIEDDATE_MST
, RESOURCENAME
, RESOURCEPLANUTILIZATIONDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCEPLANUTILIZATIONDATE) AS BIW_RESOURCEPLANUTILIZATIONDATE_MST
, RESOURCEPLANUTILIZATIONTYPE
, LINKEDPROJECT
, LINKEDRESOURCE
, LINKEDTIME
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_RESOURCEDEMANDTIMEPHASEDDATASET_WEEKLY_SNAPSHOT')}}  
