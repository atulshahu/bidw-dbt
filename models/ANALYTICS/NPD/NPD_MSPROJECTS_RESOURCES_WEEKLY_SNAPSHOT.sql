--[   NPD_MSPROJECTS_RESOURCES_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF RESOURCES ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_RESOURCES_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
RESOURCES_KEY
, SNAPSHOT_WEEK_KEY
,RESOURCEID
, COSTTYPE
, RBS
, RESOURCEBASECALENDAR
, RESOURCEBOOKINGTYPE
, RESOURCECANLEVEL
, RESOURCECODE
, RESOURCECOSTCENTER
, RESOURCECOSTPERUSE
, RESOURCECREATEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCECREATEDDATE) AS BIW_RESOURCECREATEDDATE_MST
, RESOURCEDEPARTMENTS
, RESOURCEEARLIESTAVAILABLEFROM , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCEEARLIESTAVAILABLEFROM) AS BIW_RESOURCEEARLIESTAVAILABLEFROM_MST
, RESOURCEEMAILADDRESS
, RESOURCEGROUP
, RESOURCEHYPERLINK
, RESOURCEHYPERLINKHREF
, RESOURCEINITIALS
, RESOURCEISACTIVE
, RESOURCEISGENERIC
, RESOURCEISTEAM
, RESOURCELATESTAVAILABLETO , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCELATESTAVAILABLETO) AS BIW_RESOURCELATESTAVAILABLETO_MST
, RESOURCEMATERIALLABEL
, RESOURCEMAXUNITS
, RESOURCEMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',RESOURCEMODIFIEDDATE) AS BIW_RESOURCEMODIFIEDDATE_MST
, RESOURCENAME
, RESOURCENTACCOUNT
, RESOURCEOVERTIMERATE
, RESOURCESTANDARDRATE
, RESOURCESTATUSID
, RESOURCESTATUSNAME
, RESOURCETIMESHEETMANAGEID
, RESOURCETYPE
, RESOURCEWORKGROUP
, ROLE
, TYPEDESCRIPTION
, TYPENAME
, LINKEDASSIGNMENTS
, LINKEDRESOURCEDEMANDTIMEPHASEDINFO
, LINKEDTIMEPHASEDINFODATASET
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_RESOURCES_WEEKLY_SNAPSHOT')}}  
