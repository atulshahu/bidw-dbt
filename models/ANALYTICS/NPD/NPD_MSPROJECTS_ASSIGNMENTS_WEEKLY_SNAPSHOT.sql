--[   NPD_MSPROJECTS_ASSIGNMENTS_WEEKLY_SNAPSHOT    ]
{{ 
config
(
description = 'NPD LANDING PAGE DATA DISCOVERY VIEW OF ASSIGNMENTS ', 
materialized = 'view', 
schema = 'NPD', 
tags = ['ODS_NPD'],
alias = 'MSPROJECTS_ASSIGNMENTS_WEEKLY_SNAPSHOT'
) 
}}

SELECT  
ASSIGNMENTS_KEY
, SNAPSHOT_WEEK_KEY
,ASSIGNMENTID
, PROJECTID
, ASSIGNMENTACTUALCOST
, ASSIGNMENTACTUALFINISHDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTACTUALFINISHDATE) AS BIW_ASSIGNMENTACTUALFINISHDATE_MST
, ASSIGNMENTACTUALOVERTIMECOST
, ASSIGNMENTACTUALOVERTIMEWORK
, ASSIGNMENTACTUALREGULARCOST
, ASSIGNMENTACTUALREGULARWORK
, ASSIGNMENTACTUALSTARTDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTACTUALSTARTDATE) AS BIW_ASSIGNMENTACTUALSTARTDATE_MST
, ASSIGNMENTACTUALWORK
, ASSIGNMENTACWP
, ASSIGNMENTALLUPDATESAPPLIED
, ASSIGNMENTBCWP
, ASSIGNMENTBCWS
, ASSIGNMENTBOOKINGDESCRIPTION
, ASSIGNMENTBOOKINGID
, ASSIGNMENTBOOKINGNAME
, ASSIGNMENTBUDGETCOST
, ASSIGNMENTBUDGETMATERIALWORK
, ASSIGNMENTBUDGETWORK
, ASSIGNMENTCOST
, ASSIGNMENTCOSTVARIANCE
, ASSIGNMENTCREATEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTCREATEDDATE) AS BIW_ASSIGNMENTCREATEDDATE_MST
, ASSIGNMENTCREATEDREVISIONCOUNTER
, ASSIGNMENTCV
, ASSIGNMENTDELAY
, ASSIGNMENTFINISHDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTFINISHDATE) AS BIW_ASSIGNMENTFINISHDATE_MST
, ASSIGNMENTFINISHVARIANCE
, ASSIGNMENTISOVERALLOCATED
, ASSIGNMENTISPUBLISHED
, ASSIGNMENTMATERIALACTUALWORK
, ASSIGNMENTMATERIALWORK
, ASSIGNMENTMODIFIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTMODIFIEDDATE) AS BIW_ASSIGNMENTMODIFIEDDATE_MST
, ASSIGNMENTMODIFIEDREVISIONCOUNTER
, ASSIGNMENTOVERTIMECOST
, ASSIGNMENTOVERTIMEWORK
, ASSIGNMENTPEAKUNITS
, ASSIGNMENTPERCENTWORKCOMPLETED
, ASSIGNMENTREGULARCOST
, ASSIGNMENTREGULARWORK
, ASSIGNMENTREMAININGCOST
, ASSIGNMENTREMAININGOVERTIMECOST
, ASSIGNMENTREMAININGOVERTIMEWORK
, ASSIGNMENTREMAININGREGULARCOST
, ASSIGNMENTREMAININGREGULARWORK
, ASSIGNMENTREMAININGWORK
, ASSIGNMENTRESOURCEPLANWORK
, ASSIGNMENTRESOURCETYPE
, ASSIGNMENTSTARTDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTSTARTDATE) AS BIW_ASSIGNMENTSTARTDATE_MST
, ASSIGNMENTSTARTVARIANCE
, ASSIGNMENTSV
, ASSIGNMENTTYPE
, ASSIGNMENTUPDATESAPPLIEDDATE , CONVERT_TIMEZONE('UTC','America/Phoenix',ASSIGNMENTUPDATESAPPLIEDDATE) AS BIW_ASSIGNMENTUPDATESAPPLIEDDATE_MST
, ASSIGNMENTVAC
, ASSIGNMENTWORK
, ASSIGNMENTWORKVARIANCE
, COSTTYPE_R
, DETECTABILITY_T
, FLAGSTATUS_T
, HEALTH_T
, IMPACT_T
, ISPUBLIC
, MITIGATIONFLAG_T
, NPDGATE_T
, NPDMILESTONE_T
, PROBABILITY_T
, PROJECTNAME
, RBS_R
, RESOURCEDEPARTMENTS_R
, RESOURCEID
, RESOURCENAME
, RISKFLAG_T
, RISKLEVEL_T
, RISKSCORE_T
, RISK_T
, ROLE_R
, TASKID
, TASKISACTIVE
, TASKNAME
, TIMESHEETCLASSID
, TYPEDESCRIPTION
, TYPENAME
, LINKEDBASELINE
, LINKEDPROJECT
, LINKEDRESOURCE
, LINKEDTASK
, LINKEDTIMEPHASEDDATA
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID, BIW_MD5_KEY 
FROM 
{{ref ('ODS_NPD_MSPROJECTS_ASSIGNMENTS_WEEKLY_SNAPSHOT')}}  
