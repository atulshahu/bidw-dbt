{{ config(
  description = 'E2open view for E2O_LOT_TRANSACTION table', 
  materialized = 'view', 
  schema = 'GSCO', 
  tags = ['E2OPEN'],
  alias = 'E2O_LOT_TRANSACTION'
) }} 

SELECT 
    LOT_TRANSACTION_KEY,
    LOT_TRANSACTION_ID, 
    UPDATED_ON_UDT ,
    SYSTEM_LOT_NUMBER, 
    MES_LOT_NAME, 
    LOT_ID, 
    LOCATION, 
    LOT_TYPE, 
    LOT_CATEGORY, 
    LOT_STATE, 
    ECAT, 
    IS_IN_TRANSIT, 
    IS_HOLD, 
    IS_REWORK, 
    IS_MAVERICK_LOT, 
    RMA_NUMBER, 
    MRB_CASE_NUMBERS, 
    EXTERNAL_LOT_NAME, 
    IMMEDIATE_PARENT_EXTERNAL_LOT, 
    PART_ID, 
    PDPW, 
    STAGE_SET, 
    HOLD_COUNT, 
    LOT_HOLD_REASON, 
    LOT_HOLD_TRANSACTION_UDT, 
    SUPPLIER, 
    SUPPLIER_NAME, 
    SUPPLIER_LOCATION, 
    SUPPLIER_PO_NUMBER, 
    SALES_ORDER_ID, 
    SHIPMENT_INVOICE_NUMBER, 
    SHIPMENT_TRANSFER_PRICE_USED, 
    IS_RETURN_SHIPMENT, 
    SHIP_TO_CUSTOMER, 
    JIT_LOCATION, 
    SHELF_RACK, 
    SHELF_ROW, 
    SHELF_BIN, 
    WIP_START_UDT, 
    WIP_END_UDT, 
    PROCESS_PATH, 
    HTS_COUNTRY, 
    COUNTRY_OF_SUBSTRATE, 
    COUNTRY_OF_DIFFUSION, 
    COUNTRY_OF_FAB, 
    FAB_LOCATION, 
    FAB_AREA, 
    FAB_MES_LOT_NAME, 
    FAB_PART_ID, 
    FAB_START_UDT, 
    FAB_END_UDT, 
    FAB_DATE_CODE, 
    MASK_SET, 
    MASK_SET_REVISION, 
    DISPOSITION_UDT, 
    COUNTRY_OF_SORT, 
    SORT_LOCATION, 
    SORT_AREA, 
    SORT_MES_LOT_NAME, 
    SORT_PART_ID, 
    INK_UDT, 
    SORT_START_UDT, 
    SORT_END_UDT, 
    SORT_PROGRAM_NAME, 
    SORT_PROGRAM_REVISION, 
    SORT_PROGRAM_CHECKSUM, 
    SORT_TESTER_ID, 
    SORT_PROBER_ID, 
    SORT_PROBE_CARD, 
    SORT_LOADBOARD_ID, 
    SORT_DUT_BOARD_ID, 
    COUNTRY_OF_BUMP, 
    BUMP_LOCATION, 
    COUNTRY_OF_ASSEMBLY, 
    ASSEMBLY_LOCATION, 
    ASSEMBLY_AREA, 
    ASSEMBLY_MES_LOT_NAME, 
    ASSEMBLY_PART_ID, 
    ASSEMBLY_START_UDT, 
    ASSEMBLY_END_UDT, 
    DATE_CODE, 
    DATE2_CODE, 
    IS_MARKED, 
    TOP_SIDE_MARK, 
    BACK_SIDE_MARK, 
    TRACE_CODE, 
    TRACE2_CODE, 
    COUNTRY_OF_FINAL_TEST, 
    FINAL_TEST_LOCATION, 
    FINAL_TEST_AREA, 
    FINAL_TEST_MES_LOT_NAME, 
    FINAL_TEST_PART_ID, 
    FINAL_TEST_START_UDT, 
    FINAL_TEST_END_UDT, 
    FINAL_TEST_TEMP, 
    FINAL_TEST_PROGRAM_NAME, 
    FINAL_TEST_PROGRAM_REVISION, 
    FINAL_TEST_PROGRAM_CHECKSUM, 
    FINAL_TEST_TESTER_ID, 
    FINAL_TEST_HANDLER_ID, 
    FINAL_TEST_LOADBOARD_ID, 
    FINAL_TEST_DUT_BOARD_ID, 
    DRY_PACK_SEAL_UDT, 
    SEAL_OPEN_UDT, 
    MES_USER_NAME, 
    TRANSACTION_COMMENTS, 
    TRANSACTION_TYPE, 
    TRANSACTION_SOURCE, 
    TRANSACTION_PHYSICAL_SOURCE, 
    ROW_NUMBER, 
    TRANSACTION_POST_UDT, 
    TRANSACTION_PROCEDURE_SEGMENT, 
    TRANSACTION_REASON_CODE, 
    TRANSACTION_ERROR_THRESHOLD_ID, 
    TARGET_PART_ID, 
    SCHEDULED_START_UDT, 
    PROJECTED_OUT_UDT, 
    PROJECTED_OUT_WW, 
    SOURCE_UPDATED_UDT ,
    SOURCE_UPDATED_WW ,
    MOST_RECENT_MOVE_TRANSACTION_UDT, 
    LOCATION_MOVE_IN_MES_TRANSACTION_UDT, 
    IS_TRANSACTION_REVERSED, 
    MES_TRANSACTION_UDT, 
    MES_TRANSACTION_TYPE, 
    FROM_LOT_ID, 
    FROM_MES_LOT_NAME, 
    PREVIOUS_MES_LOT_NAME, 
    NEW_MES_LOT_NAME, 
    BOH_LOT_TYPE, 
    EOH_LOT_TYPE, 
    BOH_PART_ID, 
    EOH_PART_ID, 
    PACKAGE_TYPE, 
    EXTERNAL_PART_ID, 
    FROM_LOT_PART_ID, 
    BOH_STAGE_SET, 
    EOH_STAGE_SET, 
    IS_VALUE, 
    ASSIGNED_TO, 
    TO_MES_LOT_NAME, 
    IS_GENERATED, 
    BIW_INS_DTTM ,
    BIW_UPD_DTTM ,
    BIW_BATCH_ID 
FROM {{ref('MART_E2OPEN_E2O_LOT_TRANSACTION')}}
