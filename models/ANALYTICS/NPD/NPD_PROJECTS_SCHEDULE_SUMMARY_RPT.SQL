{{ 
config
(
  description = 'NPD LANDING PAGE REPORT VIEW ', 
  materialized = 'view', 
  schema = 'NPD', 
  tags = ['MART_NPD'],
  alias = 'PROJECTS_SCHEDULE_SUMMARY_RPT'
) 
}}

SELECT 
    PROJECT_SCHEDULE_SUMMARY_KEY,
    SNAPSHOT_WEEK_KEY,
    PROJECT_NUMBER,
    PROJECT_ID,
    STEP_TYPE,
    STEP_NAME,
    SORT_ORDER,
    STATUS,
    OS_STEP_COLUMN_NAME,
    OS_DATE,
    OS_DATE_WEEK,
    CS_STEP_COLUMN_NAME,
    CS_DATE,
    CS_DATE_WEEK,
    FORECAST_STEP_COLUMN_NAME,
    FORECAST_DATE,
    FORECAST_DATE_WEEK,
    ACTUAL_STEP_COLUMN_NAME,
    ACTUAL_DATE,
    ACTUAL_DATE_WEEK,
    NUMBER_OF_DEV_PASSES,
    PRODUCT_REVENUE_XCLUDING_NRE_$,
    TOTAL_NUMBER_OF_NEW_MASK,
    IDEAL_NUMBER_OF_NEW_MASK,
    PROJECTED_TOTAL_OTHER_EXPENSES,
    PROJECTED_TOTAL_LABOR_COST,
    PTC_TOTAL_COST,
    PTC_PROJ_COMPLEXITY,
    PRODUCT_GM_EXCLUDING_NRE_PCT,
    PRODUCT_GM_EXCLUDING_NRE,
    TOTAL_UNITS,
    NEXT_MILESTONE,
    BIW_INS_DTTM, 
    BIW_UPD_DTTM, 
    BIW_BATCH_ID, 
    BIW_MD5_KEY
FROM 
    {{ref ('MART_NPD_PROJECTS_SCHEDULE_SUMMARY_RPT')}}
WHERE SNAPSHOT_WEEK_KEY > (SELECT (SUBSTRING(MAX(SNAPSHOT_WEEK_KEY)-200,1,4)||'00')::NUMBER FROM {{ref ('MART_NPD_PROJECTS_SCHEDULE_SUMMARY_RPT')}})