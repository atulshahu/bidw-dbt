--[   NPD_MSPROJECTS_PORTFOLIOANALYSES_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF PORTFOLIOANALYSES ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_PORTFOLIOANALYSES_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
PORTFOLIOANALYSES_KEY
, SNAPSHOT_WEEK_KEY
,ANALYSISID
, ALTERNATEPROJECTENDDATECUSTOMFIELDID
, ALTERNATEPROJECTENDDATECUSTOMFIELDNAME
, ALTERNATEPROJECTSTARTDATECUSTOMFIELDID
, ALTERNATEPROJECTSTARTDATECUSTOMFIELDNAME
, ANALYSISDESCRIPTION
, ANALYSISNAME
, ANALYSISTYPE
, BOOKINGTYPE
, CREATEDBYRESOURCEID
, CREATEDBYRESOURCENAME
, CREATEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',CREATEDDATE) AS BIW_CREATEDDATE_MST
, DEPARTMENTID
, DEPARTMENTNAME
, FILTERRESOURCESBYDEPARTMENT
, FILTERRESOURCESBYRBS
, FILTERRESOURCESBYRBSVALUEID
, FILTERRESOURCESBYRBSVALUETEXT
, FORCEDINALIASLOOKUPTABLEID
, FORCEDINALIASLOOKUPTABLENAME
, FORCEDOUTALIASLOOKUPTABLEID
, FORCEDOUTALIASLOOKUPTABLENAME
, HARDCONSTRAINTCUSTOMFIELDID
, HARDCONSTRAINTCUSTOMFIELDNAME
, MODIFIEDBYRESOURCEID
, MODIFIEDBYRESOURCENAME
, MODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',MODIFIEDDATE) AS BIW_MODIFIEDDATE_MST
, PLANNINGHORIZONENDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',PLANNINGHORIZONENDDATE) AS BIW_PLANNINGHORIZONENDDATE_MST
, PLANNINGHORIZONSTARTDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',PLANNINGHORIZONSTARTDATE) AS BIW_PLANNINGHORIZONSTARTDATE_MST
, PRIORITIZATIONID
, PRIORITIZATIONNAME
, PRIORITIZATIONTYPE
, ROLECUSTOMFIELDID
, ROLECUSTOMFIELDNAME
, TIMESCALE
, USEALTERNATEPROJECTDATESFORRESOURCEPLANS
, LINKEDANALYSISPROJECTS
, LINKEDCOSTCONSTRAINTSCENARIOS
, LINKEDCREATEDBYRESOURCE
, LINKEDMODIFIEDBYRESOURCE
, LINKEDPRIORITIZATION
, LINKEDRESOURCECONSTRAINTSCENARIOS
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_PORTFOLIOANALYSES_WEEKLY_SNAPSHOT')}}  
