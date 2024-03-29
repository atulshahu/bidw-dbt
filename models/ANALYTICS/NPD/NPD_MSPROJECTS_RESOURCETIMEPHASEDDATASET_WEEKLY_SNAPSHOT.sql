--[   NPD_MSPROJECTS_RESOURCETIMEPHASEDDATASET_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF RESOURCETIMEPHASEDDATASET ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_RESOURCETIMEPHASEDDATASET_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
RESOURCETIMEPHASEDDATASET_KEY
, SNAPSHOT_WEEK_KEY
,RESOURCEID
, TIMEBYDAY , CONVERT_TIMEZONE('UTC','America/Phoenix',TIMEBYDAY) AS BIW_TIMEBYDAY_MST
, BASECAPACITY
, CAPACITY
, FISCALPERIODID
, RESOURCEMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCEMODIFIEDDATE) AS BIW_RESOURCEMODIFIEDDATE_MST
, RESOURCENAME
, LINKEDRESOURCE
, LINKEDTIME
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_RESOURCETIMEPHASEDDATASET_WEEKLY_SNAPSHOT')}}  
