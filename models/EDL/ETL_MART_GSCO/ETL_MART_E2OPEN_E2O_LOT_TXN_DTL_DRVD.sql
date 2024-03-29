--dbt run --full-refresh --select ETL_MART_E2OPEN_E2O_LOT_TXN_DTL_DRVD
-- dbt run --select ETL_MART_E2OPEN_E2O_LOT_TXN_DTL_DRVD
{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['LOT_TRANSACTION_ID','SYSTEM_LOT_NUMBER']-%}
{% if is_incremental() %}
{%-set v_house_keeping_column = ['BIW_INS_DTTM','BIW_UPD_DTTM','BIW_BATCH_ID','BIW_MD5_KEY']-%}
{%-set v_all_column_list =  edw_get_column_list( this ) -%}
{%-set v_update_column_list =  edw_get_quoted_column_list( this ,v_pk_list|list + ['BIW_INS_DTTM']|list) -%}
{%-set v_md5_column_list =  edw_get_md5_column_list( this ,v_pk_list|list+ v_house_keeping_column|list ) -%}
--DBT Variable
--SELECT {{v_all_column_list}}
--SELECT {{v_update_column_list}}
--SELECT {{v_md5_column_list}}
{% endif %}

{################# Batch control insert and update SQL #################}
-- ORACLE JOB NAME: HUB_E2O_LOT_TXN_DTL_DRVD_UPSERT_MAP
{%- set v_dbt_job_name = 'DBT_ETL_MART_E2OPEN_E2O_LOT_TXN_DTL_DRVD'-%}
-- Step 1 Batch process info
{%- set v_watermark = edw_batch_control(v_dbt_job_name,config.get('schema'),config.get('alias') ,config.get('tags'),config.get('materialized') ) -%}
{%- set V_LWM = v_watermark[0] -%}
{%- set V_HWM = v_watermark[1] -%}
{%- set V_START_DTTM = v_watermark[2] -%}
{%- set V_BIW_BATCH_ID = v_watermark[3] -%}
{%- set v_sql_upd_success_batch = "CALL UTILITY.EDW_BATCH_SUCCESS_PROC('"~v_dbt_job_name~"')" -%}

{################# Snowflake Object Configuration #################}
{{
    config(
          description = 'Building table E2O_LOT_TXN_DTL_DRVD for MART_E2OPEN'
          ,transient=true
          ,materialized='incremental'
          ,schema ='ETL_MART_E2OPEN'
          ,alias='E2O_LOT_TXN_DTL_DRVD'
          ,unique_key= v_pk_list
          ,tags =['E2OPEN']
          ,merge_update_columns = 
                              ['MES_LOT_NAME', 'LOT_ID', 'LOCATION', 'LOT_TYPE', 'LOT_CATEGORY', 'LOT_STATE', 'STAGE_SET', 'TRANSACTION_SOURCE', 'TRANSACTION_PHYSICAL_SOURCE', 
                              'ROW_NUMBER', 'TRANSACTION_POST_UDT', 'SYSTEM_TRANSACTION_UDT', 'TRANSACTION_PROCEDURE_SEGMENT', 'TRANSACTION_TYPE', 'TRANSACTION_REASON_CODE', 'TRANSACTION_COMMENTS', 
                              'TRANSACTION_ERROR_THRESHOLD_ID', 'IS_TRANSACTION_REVERSED', 'MES_TRANSACTION_TYPE', 'MES_TRANSACTION_UDT', 'MES_TRANSACTION_TIME_WW', 'MES_USER_NAME', 'FROM_LOT_ID', 
                              'FROM_MES_LOT_NAME', 'PREVIOUS_MES_LOT_NAME', 'NEW_MES_LOT_NAME', 'EXTERNAL_LOT_NAME', 'IMMEDIATE_PARENT_EXTERNAL_LOT', 'BOH_LOT_TYPE', 'EOH_LOT_TYPE', 'BOH_PART_ID', 
                              'EOH_PART_ID', 'PART_ID', 'PACKAGE_TYPE', 'ECAT', 'IS_IN_TRANSIT', 'IS_HOLD', 'IS_REWORK', 'HOLD_COUNT', 'LOT_HOLD_REASON', 'LOT_HOLD_TRANSACTION_UDT', 'EXTERNAL_PART_ID', 
                              'FROM_LOT_PART_ID', 'BOH_STAGE_SET', 'EOH_STAGE_SET', 'BOH_GOOD_WAFER_QUANTITY', 'EOH_GOOD_WAFER_QUANTITY', 'GOOD_WAFER_QUANTITY', 'BOH_REJECT_WAFER_QUANTITY', 
                              'EOH_REJECT_WAFER_QUANTITY', 'REJECT_WAFER_QUANTITY', 'BOH_TOTAL_WAFER_QUANTITY', 'EOH_TOTAL_WAFER_QUANTITY', 'BOH_GOOD_DIE_QUANTITY', 'EOH_GOOD_DIE_QUANTITY', 
                              'GOOD_DIE_QUANTITY', 'BOH_REJECT_DIE_QUANTITY', 'EOH_REJECT_DIE_QUANTITY', 'REJECT_DIE_QUANTITY', 'BOH_TOTAL_DIE_QUANTITY', 'EOH_TOTAL_DIE_QUANTITY', 'IS_VALUE', 
                              'RMA_NUMBER', 'MRB_CASE_NUMBERS', 'IS_MAVERICK_LOT', 'HTS_COUNTRY', 'SUPPLIER', 'SUPPLIER_NAME', 'SUPPLIER_LOCATION', 'SUPPLIER_PO_NUMBER', 'SALES_ORDER_ID', 
                              'SHIPMENT_INVOICE_NUMBER', 'SHIPMENT_TRANSFER_PRICE_USED', 'IS_RETURN_SHIPMENT', 'SHIP_TO_CUSTOMER', 'JIT_LOCATION', 'WIP_START_UDT', 'WIP_END_UDT', 'PROCESS_PATH', 
                              'COUNTRY_OF_SUBSTRATE', 'COUNTRY_OF_DIFFUSION', 'COUNTRY_OF_FAB', 'FAB_LOCATION', 'FAB_AREA', 'FAB_MES_LOT_NAME', 'FAB_PART_ID', 'FAB_START_UDT', 'FAB_END_UDT', 
                              'FAB_DATE_CODE', 'MASK_SET', 'MASK_SET_REVISION', 'SHELF_RACK', 'SHELF_ROW', 'SHELF_BIN', 'PDPW', 'SEAL_OPEN_UDT', 'DISPOSITION_UDT', 'COUNTRY_OF_SORT', 'SORT_LOCATION', 
                              'SORT_AREA', 'SORT_MES_LOT_NAME', 'SORT_PART_ID', 'SORT_START_UDT', 'SORT_END_UDT', 'INK_UDT', 'SORT_PROGRAM_NAME', 'SORT_PROGRAM_REVISION', 'SORT_PROGRAM_CHECKSUM', 
                              'SORT_TESTER_ID', 'SORT_PROBER_ID', 'SORT_PROBE_CARD', 'SORT_LOADBOARD_ID', 'SORT_DUT_BOARD_ID', 'COUNTRY_OF_BUMP', 'BUMP_LOCATION', 'COUNTRY_OF_ASSEMBLY', 'ASSEMBLY_LOCATION', 
                              'ASSEMBLY_AREA', 'ASSEMBLY_MES_LOT_NAME', 'ASSEMBLY_PART_ID', 'ASSEMBLY_START_UDT', 'ASSEMBLY_END_UDT', 'TOP_SIDE_MARK', 'BACK_SIDE_MARK', 'IS_MARKED', 'DATE_CODE', 'DATE2_CODE', 
                              'TRACE_CODE', 'TRACE2_CODE', 'COUNTRY_OF_FINAL_TEST', 'FINAL_TEST_LOCATION', 'FINAL_TEST_AREA', 'FINAL_TEST_MES_LOT_NAME', 'FINAL_TEST_PART_ID', 'FINAL_TEST_START_UDT', 
                              'FINAL_TEST_END_UDT', 'FINAL_TEST_TEMP', 'FINAL_TEST_PROGRAM_NAME', 'FINAL_TEST_PROGRAM_REVISION', 'FINAL_TEST_PROGRAM_CHECKSUM', 'FINAL_TEST_TESTER_ID', 'FINAL_TEST_HANDLER_ID', 
                              'FINAL_TEST_LOADBOARD_ID', 'FINAL_TEST_DUT_BOARD_ID', 'DRY_PACK_SEAL_UDT', 'SCHEDULED_START_UDT', 'PROJECTED_OUT_UDT', 'PROJECTED_OUT_WW', 'TARGET_PART_ID', 'ASSIGNED_TO', 
                              'MOST_RECENT_MOVE_TRANSACTION_UDT', 'LOCATION_MOVE_IN_MES_TRANSACTION_UDT', 'GOOD_WAFER_NET_CHANGE', 'GOOD_DIE_NET_CHANGE', 'TO_MES_LOT_NAME', 'IS_GENERATED', 'BIW_UPD_DTTM', 
                              'BIW_BATCH_ID']
          ,post_hook= [v_sql_upd_success_batch]	
        )
}}


WITH 
CTE_E2O_LOT_TXN_DTL_CMPLT AS 
(
SELECT 
  * 
  ,ROW_NUMBER() OVER( PARTITION BY SYSTEM_LOT_NUMBER ORDER BY  LOT_TRANSACTION_ID ASC NULLS LAST) as RANK_COL
FROM 
{{ ref('ETL_MART_E2OPEN_E2O_LOT_TXN_DTL_CMPLT') }}
-- FOR TESTING --WHERE SYSTEM_LOT_NUMBER iN (958817,1738193)
{% if is_incremental() %}
  WHERE BIW_UPD_DTTM >= '{{V_LWM}}'
  AND BIW_UPD_DTTM < '{{V_HWM}}'
{% endif %}
),
CTE_E2O_STAGE_SET AS 
(
SELECT 
  STAGE_SET,
  COUNTRY_CODE,
  AREA_NAME
FROM {{ ref('ETL_MART_E2OPEN_E2O_STAGE_SET') }}
),
--STEP 1 calculate LOT_TXN_ID
-- remove pablo's incrmental check as it required in the view and derived columns are dependend on it
-- Get comments from Vinay/Brain
CTE_E2O_LOT_TXN_DTL_DRVD_LATST_TXN AS
(
{% if is_incremental() %}
  SELECT 
    SYSTEM_LOT_NUMBER,
    LOT_TRANSACTION_ID,
    LOCATION,
    MES_TRANSACTION_UDT
  FROM {{ this }} 
  WHERE SYSTEM_LOT_NUMBER in (
                              SELECT SYSTEM_LOT_NUMBER 
                              FROM CTE_E2O_LOT_TXN_DTL_CMPLT
                              )
  QUALIFY(ROW_NUMBER() OVER(PARTITION BY SYSTEM_LOT_NUMBER ORDER BY LOT_TRANSACTION_ID DESC NULLS LAST))=1
{%- else -%} 
  SELECT 
    NULL AS SYSTEM_LOT_NUMBER,
    NULL AS LOT_TRANSACTION_ID,
    NULL AS LOCATION,
    NULL AS MES_TRANSACTION_UDT
{% endif %}
),
--select * from CTE_E2O_LOT_TXN_DTL_DRVD_LATST_TXN;
--STEP 2 calculate Hold,Release txn type 
-- Get comments from Vinay/Brain
CTE_E2O_LOT_FIRST_HOLD_TXN AS
(
SELECT 
  SYSTEM_LOT_NUMBER,
  LOT_TRANSACTION_ID
FROM CTE_E2O_LOT_TXN_DTL_CMPLT 
WHERE TRANSACTION_TYPE in ('HoldLot')
AND SYSTEM_LOT_NUMBER IN (
                          SELECT 
                            SYSTEM_LOT_NUMBER 
                          FROM CTE_E2O_LOT_TXN_DTL_CMPLT
                          WHERE TRANSACTION_TYPE IN ('HoldLot','ReleaseLot') 
                          )
QUALIFY(ROW_NUMBER() OVER (PARTITION BY SYSTEM_LOT_NUMBER ORDER BY LOT_TRANSACTION_ID ASC))=1
)
--select * from CTE_E2O_LOT_FIRST_HOLD_TXN;
,
-- Get comments from Vinay/Brain
CTE_E2O_LOT_HOLD_REL_TXN AS
(
SELECT 
  S.SYSTEM_LOT_NUMBER,
  S.LOT_TRANSACTION_ID,
  S.TRANSACTION_TYPE,
  S.TRANSACTION_REASON_CODE,
  S.MES_TRANSACTION_UDT,
  TXN.LOT_TRANSACTION_ID AS FIRST_HOLD_TXN 
FROM CTE_E2O_LOT_TXN_DTL_CMPLT S
INNER JOIN  CTE_E2O_LOT_FIRST_HOLD_TXN TXN
    ON S.SYSTEM_LOT_NUMBER = TXN.SYSTEM_LOT_NUMBER
WHERE S.TRANSACTION_TYPE in ('HoldLot','ReleaseLot') 
AND S.SYSTEM_LOT_NUMBER IN (
                          SELECT 
                            SYSTEM_LOT_NUMBER 
                          FROM CTE_E2O_LOT_TXN_DTL_CMPLT
                          WHERE TRANSACTION_TYPE in ('HoldLot','ReleaseLot')
                          )
)
--select * from CTE_E2O_LOT_HOLD_REL_TXN;
,
CTE_HOLD_LOT_TXN AS
(
SELECT 
  LOT_TRANSACTION_ID,
  TRANSACTION_REASON_CODE,
  MES_TRANSACTION_UDT,
  SYSTEM_LOT_NUMBER,
  row_number() OVER (PARTITION BY SYSTEM_LOT_NUMBER ORDER BY LOT_TRANSACTION_ID) as RN 
FROM 
CTE_E2O_LOT_HOLD_REL_TXN
WHERE TRANSACTION_TYPE = 'HoldLot'
)
--select * from CTE_HOLD_LOT_TXN;
,

CTE_REL_LOT_TXN AS
(
SELECT 
  LOT_TRANSACTION_ID AS REL_LOT_TRANSACTION_ID,
  SYSTEM_LOT_NUMBER,
  row_number() OVER (PARTITION BY SYSTEM_LOT_NUMBER ORDER BY LOT_TRANSACTION_ID) as RN 
FROM 
CTE_E2O_LOT_HOLD_REL_TXN
WHERE TRANSACTION_TYPE = 'ReleaseLot'
AND LOT_TRANSACTION_ID > FIRST_HOLD_TXN
)
--select * from CTE_REL_LOT_TXN;
,
CTE_HOLDLOT_TXN_DTL AS
(
  SELECT
  HLD.LOT_TRANSACTION_ID,
  HLD.TRANSACTION_REASON_CODE,
  HLD.MES_TRANSACTION_UDT,
  HLD.SYSTEM_LOT_NUMBER,
  REL.REL_LOT_TRANSACTION_ID
  FROM   CTE_HOLD_LOT_TXN HLD
  LEFT JOIN   CTE_REL_LOT_TXN REL
    ON HLD.SYSTEM_LOT_NUMBER= REL.SYSTEM_LOT_NUMBER
    AND HLD.RN= REL.RN
)
--select * from CTE_HOLDLOT_TXN_DTL;
,
-- Step 3 Oracle Merge Dataset
CTE_E2O_LOT_TXN_DTL_DRVD_SRC_VW
AS
(
SELECT 
  LOT_TXN_DTL_CMPLT.LOT_TRANSACTION_ID ,
  LOT_TXN_DTL_CMPLT.SYSTEM_LOT_NUMBER ,
  LOT_TXN_DTL_CMPLT.MES_LOT_NAME ,
  LOT_TXN_DTL_CMPLT.LOT_ID ,
  LOT_TXN_DTL_CMPLT.LOCATION ,
  LOT_TXN_DTL_CMPLT.LOT_TYPE ,
  LOT_TXN_DTL_CMPLT.LOT_CATEGORY ,
  LOT_TXN_DTL_CMPLT.LOT_STATE ,
  LOT_TXN_DTL_CMPLT.STAGE_SET ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_SOURCE ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_PHYSICAL_SOURCE ,
  LOT_TXN_DTL_CMPLT.ROW_NUMBER ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_POST_UDT ,
  LOT_TXN_DTL_CMPLT.SYSTEM_TRANSACTION_UDT,
  LOT_TXN_DTL_CMPLT.TRANSACTION_PROCEDURE_SEGMENT ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_REASON_CODE ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_COMMENTS ,
  LOT_TXN_DTL_CMPLT.TRANSACTION_ERROR_THRESHOLD_ID ,
  LOT_TXN_DTL_CMPLT.IS_TRANSACTION_REVERSED ,
  LOT_TXN_DTL_CMPLT.MES_TRANSACTION_TYPE ,
  LOT_TXN_DTL_CMPLT.MES_TRANSACTION_UDT,
  LOT_TXN_DTL_CMPLT.MES_TRANSACTION_TIME_WW ,
  LOT_TXN_DTL_CMPLT.MES_USER_NAME ,
  LOT_TXN_DTL_CMPLT.FROM_LOT_ID ,
  LOT_TXN_DTL_CMPLT.FROM_MES_LOT_NAME ,
  LOT_TXN_DTL_CMPLT.PREVIOUS_MES_LOT_NAME ,
  LOT_TXN_DTL_CMPLT.NEW_MES_LOT_NAME ,
  LOT_TXN_DTL_CMPLT.EXTERNAL_LOT_NAME ,
  LOT_TXN_DTL_CMPLT.IMMEDIATE_PARENT_EXTERNAL_LOT ,
  LOT_TXN_DTL_CMPLT.BOH_LOT_TYPE ,
  LOT_TXN_DTL_CMPLT.EOH_LOT_TYPE ,
  LOT_TXN_DTL_CMPLT.BOH_PART_ID ,
  LOT_TXN_DTL_CMPLT.EOH_PART_ID ,
  LOT_TXN_DTL_CMPLT.PART_ID ,
  LOT_TXN_DTL_CMPLT.PACKAGE_TYPE ,
  LOT_TXN_DTL_CMPLT.ECAT,
  case 
    when LOT_TXN_DTL_CMPLT.LOT_STATE='INTRANSIT' 
    then 'Y' 
    else 'N' 
  END::boolean IS_IN_TRANSIT,
  case
    when LOT_TXN_DTL_CMPLT.LOT_STATE ='WAIT' 
    then 'Y'
    else 'N' 
  END::boolean IS_HOLD ,
  case 
    when LOT_TXN_DTL_CMPLT.LOT_CATEGORY='REWORK' 
    then 'Y' 
    else 'N' 
  END::boolean IS_REWORK,
  case 
    WHEN LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE not in ('HoldLot' ,'ReleaseLot') AND HOLDLOT_TXN_DTL.LOT_TRANSACTION_ID is NULL 
      then 0
    WHEN LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE not in ('HoldLot' ,'ReleaseLot') AND HOLDLOT_TXN_DTL.LOT_TRANSACTION_ID is NOT NULL 
      THEN 1 
  END HOLD_COUNT,
  case 
    WHEN LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE='HoldLot' 
      then LOT_TXN_DTL_CMPLT.TRANSACTION_REASON_CODE
    WHEN LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE='ReleaseLot' 
      then NULL 
    else HOLDLOT_TXN_DTL.TRANSACTION_REASON_CODE 
  END  LOT_HOLD_REASON,
  case 
    WHEN LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE='HoldLot' 
      then LOT_TXN_DTL_CMPLT.MES_TRANSACTION_UDT
    WHEN LOT_TXN_DTL_CMPLT.TRANSACTION_TYPE='ReleaseLot' 
      then NULL 
    else HOLDLOT_TXN_DTL.MES_TRANSACTION_UDT 
  END LOT_HOLD_TRANSACTION_UDT,
  LOT_TXN_DTL_CMPLT.EXTERNAL_PART_ID ,
  LOT_TXN_DTL_CMPLT.FROM_LOT_PART_ID ,
  LOT_TXN_DTL_CMPLT.BOH_STAGE_SET ,
  LOT_TXN_DTL_CMPLT.EOH_STAGE_SET ,
    -- Wafer
  LOT_TXN_DTL_CMPLT.BOH_GOOD_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.EOH_GOOD_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.GOOD_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.BOH_REJECT_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.EOH_REJECT_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.REJECT_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.BOH_TOTAL_WAFER_QUANTITY,
  LOT_TXN_DTL_CMPLT.EOH_TOTAL_WAFER_QUANTITY,
  --die
  LOT_TXN_DTL_CMPLT.BOH_GOOD_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.EOH_GOOD_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.GOOD_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.BOH_REJECT_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.EOH_REJECT_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.REJECT_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.BOH_TOTAL_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.EOH_TOTAL_DIE_QUANTITY,
  LOT_TXN_DTL_CMPLT.IS_VALUE ,
  LOT_TXN_DTL_CMPLT.RMA_NUMBER ,
  LOT_TXN_DTL_CMPLT.MRB_CASE_NUMBERS ,
  LOT_TXN_DTL_CMPLT.IS_MAVERICK_LOT ,
  LOT_TXN_DTL_CMPLT.HTS_COUNTRY ,
  LOT_TXN_DTL_CMPLT.SUPPLIER ,
  LOT_TXN_DTL_CMPLT.SUPPLIER_NAME ,
  LOT_TXN_DTL_CMPLT.SUPPLIER_LOCATION ,
  LOT_TXN_DTL_CMPLT.SUPPLIER_PO_NUMBER ,
  LOT_TXN_DTL_CMPLT.SALES_ORDER_ID ,
  LOT_TXN_DTL_CMPLT.SHIPMENT_INVOICE_NUMBER ,
  LOT_TXN_DTL_CMPLT.SHIPMENT_TRANSFER_PRICE_USED ,
  LOT_TXN_DTL_CMPLT.IS_RETURN_SHIPMENT ,
  LOT_TXN_DTL_CMPLT.SHIP_TO_CUSTOMER ,
  LOT_TXN_DTL_CMPLT.JIT_LOCATION ,
  LOT_TXN_DTL_CMPLT.WIP_START_UDT ,
  LOT_TXN_DTL_CMPLT.WIP_END_UDT ,
  LOT_TXN_DTL_CMPLT.PROCESS_PATH ,
  LOT_TXN_DTL_CMPLT.COUNTRY_OF_SUBSTRATE ,
  LOT_TXN_DTL_CMPLT.COUNTRY_OF_DIFFUSION ,
  case 
    when  LOT_TXN_DTL_CMPLT.FAB_MES_LOT_NAME is not null 
    then STAGE_SET.COUNTRY_CODE 
  END COUNTRY_OF_FAB,
  LOT_TXN_DTL_CMPLT.FAB_LOCATION,
  case 
    when  LOT_TXN_DTL_CMPLT.FAB_MES_LOT_NAME is not null 
    then STAGE_SET.AREA_NAME 
  END  FAB_AREA,
  LOT_TXN_DTL_CMPLT.FAB_MES_LOT_NAME ,
  case 
    when LOT_TXN_DTL_CMPLT.FAB_MES_LOT_NAME is not null
    then LOT_TXN_DTL_CMPLT.EOH_PART_ID 
  END FAB_PART_ID,
  LOT_TXN_DTL_CMPLT.FAB_START_UDT ,
  LOT_TXN_DTL_CMPLT.FAB_END_UDT ,
  LOT_TXN_DTL_CMPLT.FAB_DATE_CODE ,
  LOT_TXN_DTL_CMPLT.MASK_SET ,
  LOT_TXN_DTL_CMPLT.MASK_SET_REVISION ,
  LOT_TXN_DTL_CMPLT.SHELF_RACK ,
  LOT_TXN_DTL_CMPLT.SHELF_ROW ,
  LOT_TXN_DTL_CMPLT.SHELF_BIN ,
  LOT_TXN_DTL_CMPLT.PDPW ,
  LOT_TXN_DTL_CMPLT.SEAL_OPEN_UDT ,
  LOT_TXN_DTL_CMPLT.DISPOSITION_UDT ,
  case
    when LOT_TXN_DTL_CMPLT.SORT_MES_LOT_NAME is not null 
    then STAGE_SET.COUNTRY_CODE 
  END COUNTRY_OF_SORT ,
  case 
    when LOT_TXN_DTL_CMPLT.SORT_MES_LOT_NAME is not null 
    then LOT_TXN_DTL_CMPLT.LOCATION 
  END SORT_LOCATION,
  case 
    when LOT_TXN_DTL_CMPLT.SORT_MES_LOT_NAME is not null 
    then STAGE_SET.AREA_NAME 
  END   SORT_AREA,
  LOT_TXN_DTL_CMPLT.SORT_MES_LOT_NAME ,
  case 
    when LOT_TXN_DTL_CMPLT.SORT_MES_LOT_NAME is not null 
    then LOT_TXN_DTL_CMPLT.EOH_PART_ID 
  END SORT_PART_ID,
  LOT_TXN_DTL_CMPLT.SORT_START_UDT ,
  LOT_TXN_DTL_CMPLT.SORT_END_UDT ,
  LOT_TXN_DTL_CMPLT.INK_UDT ,
  LOT_TXN_DTL_CMPLT.SORT_PROGRAM_NAME ,
  LOT_TXN_DTL_CMPLT.SORT_PROGRAM_REVISION ,
  LOT_TXN_DTL_CMPLT.SORT_PROGRAM_CHECKSUM ,
  LOT_TXN_DTL_CMPLT.SORT_TESTER_ID ,
  LOT_TXN_DTL_CMPLT.SORT_PROBER_ID ,
  LOT_TXN_DTL_CMPLT.SORT_PROBE_CARD ,
  LOT_TXN_DTL_CMPLT.SORT_LOADBOARD_ID ,
  LOT_TXN_DTL_CMPLT.SORT_DUT_BOARD_ID ,
  LOT_TXN_DTL_CMPLT.COUNTRY_OF_BUMP ,
  LOT_TXN_DTL_CMPLT.BUMP_LOCATION ,
  case 
    when LOT_TXN_DTL_CMPLT.ASSEMBLY_MES_LOT_NAME is not null 
    then STAGE_SET.COUNTRY_CODE 
  END COUNTRY_OF_ASSEMBLY,
  case 
    when LOT_TXN_DTL_CMPLT.ASSEMBLY_MES_LOT_NAME is not null 
    then LOT_TXN_DTL_CMPLT.LOCATION 
  END ASSEMBLY_LOCATION,
  case 
    when LOT_TXN_DTL_CMPLT.ASSEMBLY_MES_LOT_NAME is not null 
    then STAGE_SET.AREA_NAME 
  END ASSEMBLY_AREA,
  LOT_TXN_DTL_CMPLT.ASSEMBLY_MES_LOT_NAME ,
  Case 
    when LOT_TXN_DTL_CMPLT.ASSEMBLY_MES_LOT_NAME is not null 
    then LOT_TXN_DTL_CMPLT.EOH_PART_ID 
  END ASSEMBLY_PART_ID,
  LOT_TXN_DTL_CMPLT.ASSEMBLY_START_UDT ,
  LOT_TXN_DTL_CMPLT.ASSEMBLY_END_UDT ,
  LOT_TXN_DTL_CMPLT.TOP_SIDE_MARK ,
  LOT_TXN_DTL_CMPLT.BACK_SIDE_MARK ,
  LOT_TXN_DTL_CMPLT.IS_MARKED ,
  LOT_TXN_DTL_CMPLT.DATE_CODE ,
  LOT_TXN_DTL_CMPLT.DATE2_CODE ,
  LOT_TXN_DTL_CMPLT.TRACE_CODE ,
  LOT_TXN_DTL_CMPLT.TRACE2_CODE ,
  case 
    when LOT_TXN_DTL_CMPLT.FINAL_TEST_MES_LOT_NAME is not null 
    then STAGE_SET.COUNTRY_CODE
  END COUNTRY_OF_FINAL_TEST,
  case 
    when LOT_TXN_DTL_CMPLT.FINAL_TEST_MES_LOT_NAME is not null 
    then LOT_TXN_DTL_CMPLT.LOCATION 
  END FINAL_TEST_LOCATION,
  case
    when LOT_TXN_DTL_CMPLT.FINAL_TEST_MES_LOT_NAME is not null 
    then STAGE_SET.AREA_NAME 
  END FINAL_TEST_AREA,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_MES_LOT_NAME ,
  case
    when LOT_TXN_DTL_CMPLT.FINAL_TEST_MES_LOT_NAME is not null 
    then LOT_TXN_DTL_CMPLT.EOH_PART_ID 
  END FINAL_TEST_PART_ID,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_START_UDT ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_END_UDT ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_TEMP ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_PROGRAM_NAME ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_PROGRAM_REVISION ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_PROGRAM_CHECKSUM ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_TESTER_ID ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_HANDLER_ID ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_LOADBOARD_ID ,
  LOT_TXN_DTL_CMPLT.FINAL_TEST_DUT_BOARD_ID ,
  LOT_TXN_DTL_CMPLT.DRY_PACK_SEAL_UDT ,
  LOT_TXN_DTL_CMPLT.SCHEDULED_START_UDT ,
  LOT_TXN_DTL_CMPLT.PROJECTED_OUT_UDT ,
  LOT_TXN_DTL_CMPLT.PROJECTED_OUT_WW ,
  LOT_TXN_DTL_CMPLT.TARGET_PART_ID ,
  LOT_TXN_DTL_CMPLT.ASSIGNED_TO,  
  case 
    when LOT_TXN_DTL_CMPLT.BOH_STAGE_SET <> LOT_TXN_DTL_CMPLT.EOH_STAGE_SET 
    then LOT_TXN_DTL_CMPLT.MES_TRANSACTION_UDT 
  END MOST_RECENT_MOVE_TRANSACTION_UDT,
  case 
    when LATEST_TXN.LOCATION IS NULL
     AND LOT_TXN_DTL_CMPLT.LOCATION <> LAG (LOT_TXN_DTL_CMPLT.LOCATION,1) OVER (PARTITION BY LOT_TXN_DTL_CMPLT.SYSTEM_LOT_NUMBER ORDER BY LOT_TXN_DTL_CMPLT.LOT_TRANSACTION_ID)
    then LOT_TXN_DTL_CMPLT.MES_TRANSACTION_UDT 
    when  LATEST_TXN.LOCATION IS NOT NULL AND LOT_TXN_DTL_CMPLT.LOCATION <> LATEST_TXN.LOCATION
    then LOT_TXN_DTL_CMPLT.MES_TRANSACTION_UDT 
  END AS LOCATION_MOVE_IN_MES_TRANSACTION_UDT,
  LOT_TXN_DTL_CMPLT.GOOD_WAFER_NET_CHANGE,
  LOT_TXN_DTL_CMPLT.GOOD_DIE_NET_CHANGE,
  LOT_TXN_DTL_CMPLT.TO_MES_LOT_NAME,
  LOT_TXN_DTL_CMPLT.IS_GENERATED,
  '{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM ,
  '{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM ,
  {{V_BIW_BATCH_ID}}	 as BIW_BATCH_ID
FROM

CTE_E2O_LOT_TXN_DTL_CMPLT AS LOT_TXN_DTL_CMPLT
LEFT OUTER JOIN  CTE_E2O_STAGE_SET AS STAGE_SET
  ON  LOT_TXN_DTL_CMPLT.STAGE_SET = STAGE_SET.STAGE_SET
LEFT OUTER JOIN CTE_HOLDLOT_TXN_DTL AS HOLDLOT_TXN_DTL
	ON LOT_TXN_DTL_CMPLT.SYSTEM_LOT_NUMBER = HOLDLOT_TXN_DTL.SYSTEM_LOT_NUMBER 
  AND	LOT_TXN_DTL_CMPLT.LOT_TRANSACTION_ID > HOLDLOT_TXN_DTL.LOT_TRANSACTION_ID
	AND LOT_TXN_DTL_CMPLT.LOT_TRANSACTION_ID < NVL(HOLDLOT_TXN_DTL.REL_LOT_TRANSACTION_ID,99999999999)
LEFT OUTER JOIN		CTE_E2O_LOT_TXN_DTL_DRVD_LATST_TXN  LATEST_TXN
  ON LOT_TXN_DTL_CMPLT.SYSTEM_LOT_NUMBER= LATEST_TXN.SYSTEM_LOT_NUMBER
  AND LOT_TXN_DTL_CMPLT.RANK_COL = 1
)
SELECT 
*,
md5(object_construct ('col1',MES_LOT_NAME, 'col2',LOT_ID, 'col3',LOCATION, 'col4',LOT_TYPE, 'col5',LOT_CATEGORY, 'col6',LOT_STATE, 'col7',STAGE_SET, 'col8',TRANSACTION_SOURCE, 
'col9',TRANSACTION_PHYSICAL_SOURCE, 'col10',ROW_NUMBER, 'col11',TRANSACTION_POST_UDT, 'col12',SYSTEM_TRANSACTION_UDT, 'col13',TRANSACTION_PROCEDURE_SEGMENT, 'col14',TRANSACTION_TYPE, 
'col15',TRANSACTION_REASON_CODE, 'col16',TRANSACTION_COMMENTS, 'col17',TRANSACTION_ERROR_THRESHOLD_ID, 'col18',IS_TRANSACTION_REVERSED, 'col19',MES_TRANSACTION_TYPE, 
'col20',MES_TRANSACTION_UDT, 'col21',MES_TRANSACTION_TIME_WW, 'col22',MES_USER_NAME, 'col23',FROM_LOT_ID, 'col24',FROM_MES_LOT_NAME, 'col25',PREVIOUS_MES_LOT_NAME, 
'col26',NEW_MES_LOT_NAME, 'col27',EXTERNAL_LOT_NAME, 'col28',IMMEDIATE_PARENT_EXTERNAL_LOT, 'col29',BOH_LOT_TYPE, 'col30',EOH_LOT_TYPE, 'col31',BOH_PART_ID, 
'col32',EOH_PART_ID, 'col33',PART_ID, 'col34',PACKAGE_TYPE, 'col35',ECAT, 'col36',IS_IN_TRANSIT, 'col37',IS_HOLD, 'col38',IS_REWORK, 'col39',HOLD_COUNT, 
'col40',LOT_HOLD_REASON, 'col41',LOT_HOLD_TRANSACTION_UDT, 'col42',EXTERNAL_PART_ID, 'col43',FROM_LOT_PART_ID, 'col44',BOH_STAGE_SET, 'col45',EOH_STAGE_SET, 
'col46',BOH_GOOD_WAFER_QUANTITY, 'col47',EOH_GOOD_WAFER_QUANTITY, 'col48',GOOD_WAFER_QUANTITY, 'col49',BOH_REJECT_WAFER_QUANTITY, 'col50',EOH_REJECT_WAFER_QUANTITY, 
'col51',REJECT_WAFER_QUANTITY, 'col52',BOH_TOTAL_WAFER_QUANTITY, 'col53',EOH_TOTAL_WAFER_QUANTITY, 'col54',BOH_GOOD_DIE_QUANTITY, 'col55',EOH_GOOD_DIE_QUANTITY, 
'col56',GOOD_DIE_QUANTITY, 'col57',BOH_REJECT_DIE_QUANTITY, 'col58',EOH_REJECT_DIE_QUANTITY, 'col59',REJECT_DIE_QUANTITY, 'col60',BOH_TOTAL_DIE_QUANTITY, 
'col61',EOH_TOTAL_DIE_QUANTITY, 'col62',IS_VALUE, 'col63',RMA_NUMBER, 'col64',MRB_CASE_NUMBERS, 'col65',IS_MAVERICK_LOT, 'col66',HTS_COUNTRY, 'col67',SUPPLIER, 
'col68',SUPPLIER_NAME, 'col69',SUPPLIER_LOCATION, 'col70',SUPPLIER_PO_NUMBER, 'col71',SALES_ORDER_ID, 'col72',SHIPMENT_INVOICE_NUMBER, 'col73',SHIPMENT_TRANSFER_PRICE_USED, 
'col74',IS_RETURN_SHIPMENT, 'col75',SHIP_TO_CUSTOMER, 'col76',JIT_LOCATION, 'col77',WIP_START_UDT, 'col78',WIP_END_UDT, 'col79',PROCESS_PATH, 'col80',COUNTRY_OF_SUBSTRATE, 
'col81',COUNTRY_OF_DIFFUSION, 'col82',COUNTRY_OF_FAB, 'col83',FAB_LOCATION, 'col84',FAB_AREA, 'col85',FAB_MES_LOT_NAME, 'col86',FAB_PART_ID, 'col87',FAB_START_UDT, 
'col88',FAB_END_UDT, 'col89',FAB_DATE_CODE, 'col90',MASK_SET, 'col91',MASK_SET_REVISION, 'col92',SHELF_RACK, 'col93',SHELF_ROW, 'col94',SHELF_BIN, 'col95',PDPW, 
'col96',SEAL_OPEN_UDT, 'col97',DISPOSITION_UDT, 'col98',COUNTRY_OF_SORT, 'col99',SORT_LOCATION, 'col100',SORT_AREA, 'col101',SORT_MES_LOT_NAME, 'col102',SORT_PART_ID, 
'col103',SORT_START_UDT, 'col104',SORT_END_UDT, 'col105',INK_UDT, 'col106',SORT_PROGRAM_NAME, 'col107',SORT_PROGRAM_REVISION, 'col108',SORT_PROGRAM_CHECKSUM, 
'col109',SORT_TESTER_ID, 'col110',SORT_PROBER_ID, 'col111',SORT_PROBE_CARD, 'col112',SORT_LOADBOARD_ID, 'col113',SORT_DUT_BOARD_ID, 'col114',COUNTRY_OF_BUMP, 
'col115',BUMP_LOCATION, 'col116',COUNTRY_OF_ASSEMBLY, 'col117',ASSEMBLY_LOCATION, 'col118',ASSEMBLY_AREA, 'col119',ASSEMBLY_MES_LOT_NAME, 'col120',ASSEMBLY_PART_ID, 
'col121',ASSEMBLY_START_UDT, 'col122',ASSEMBLY_END_UDT, 'col123',TOP_SIDE_MARK, 'col124',BACK_SIDE_MARK, 'col125',IS_MARKED, 'col126',DATE_CODE, 'col127',DATE2_CODE, 
'col128',TRACE_CODE, 'col129',TRACE2_CODE, 'col130',COUNTRY_OF_FINAL_TEST, 'col131',FINAL_TEST_LOCATION, 'col132',FINAL_TEST_AREA, 'col133',FINAL_TEST_MES_LOT_NAME, 
'col134',FINAL_TEST_PART_ID, 'col135',FINAL_TEST_START_UDT, 'col136',FINAL_TEST_END_UDT, 'col137',FINAL_TEST_TEMP, 'col138',FINAL_TEST_PROGRAM_NAME, 
'col139',FINAL_TEST_PROGRAM_REVISION, 'col140',FINAL_TEST_PROGRAM_CHECKSUM, 'col141',FINAL_TEST_TESTER_ID, 'col142',FINAL_TEST_HANDLER_ID, 'col143',FINAL_TEST_LOADBOARD_ID, 
'col144',FINAL_TEST_DUT_BOARD_ID, 'col145',DRY_PACK_SEAL_UDT, 'col146',SCHEDULED_START_UDT, 'col147',PROJECTED_OUT_UDT, 'col148',PROJECTED_OUT_WW, 'col149',TARGET_PART_ID, 
'col150',ASSIGNED_TO, 'col151',MOST_RECENT_MOVE_TRANSACTION_UDT, 'col152',LOCATION_MOVE_IN_MES_TRANSACTION_UDT, 'col153',GOOD_WAFER_NET_CHANGE, 'col154',GOOD_DIE_NET_CHANGE, 
'col155',TO_MES_LOT_NAME, 'col156',IS_GENERATED)::string ) as BIW_MD5_KEY
FROM 
CTE_E2O_LOT_TXN_DTL_DRVD_SRC_VW