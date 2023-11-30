--[   NPD_MSPROJECTS_TIMESET_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF TIMESET ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_TIMESET_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
TIMESET_KEY
, SNAPSHOT_WEEK_KEY
,TIMEBYDAY , CONVERT_TIMEZONE('UTC','America/Phoenix',TIMEBYDAY) AS BIW_TIMEBYDAY_MST
, FISCALPERIODID
, FISCALPERIODMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',FISCALPERIODMODIFIEDDATE) AS BIW_FISCALPERIODMODIFIEDDATE_MST
, FISCALPERIODNAME
, FISCALPERIODSTART , CONVERT_TIMEZONE('UTC','America/Phoenix',FISCALPERIODSTART) AS BIW_FISCALPERIODSTART_MST
, FISCALPERIODYEAR
, FISCALQUARTER
, TIMEDAYOFTHEMONTH
, TIMEDAYOFTHEWEEK
, TIMEMONTHOFTHEYEAR
, TIMEQUARTER
, TIMEWEEKOFTHEYEAR
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_TIMESET_WEEKLY_SNAPSHOT')}}  