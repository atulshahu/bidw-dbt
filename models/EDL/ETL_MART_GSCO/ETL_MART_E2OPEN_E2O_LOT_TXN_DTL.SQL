--dbt run --full-refresh --select ETL_MART_E2OPEN_E2O_LOT_TXN_DTL
-- dbt run --select ETL_MART_E2OPEN_E2O_LOT_TXN_DTL
{################# EDW Job Template Variables #################}
{%-set v_pk_list = ['LOT_TRANSACTION_ID']-%}
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
{%- set v_dbt_job_name = 'DBT_ETL_MART_E2OPEN_E2O_LOT_TXN_DTL'-%}
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
         description = 'Building table E2O_LOT_TXN_DTL for MART_E2OPEN'
        ,transient=true
        ,materialized='incremental'
        ,schema ='ETL_MART_E2OPEN'
        ,alias='E2O_LOT_TXN_DTL'
		,unique_key= v_pk_list
        ,tags =['E2OPEN']
		,merge_update_columns = ['SYSTEM_LOT_NUMBER', 'MES_LOT_NAME', 'LOT_ID', 'LOCATION', 'LOT_TYPE', 'LOT_CATEGORY', 'LOT_STATE', 'STAGE_SET', 'TRANSACTION_SOURCE', 
                                'TRANSACTION_PHYSICAL_SOURCE', 'ROW_NUMBER', 'TRANSACTION_POST_UDT', 'SYSTEM_TRANSACTION_UDT', 'TRANSACTION_PROCEDURE_SEGMENT', 'TRANSACTION_TYPE', 
                                'TRANSACTION_REASON_CODE', 'TRANSACTION_COMMENTS', 'TRANSACTION_ERROR_THRESHOLD_ID', 'IS_TRANSACTION_REVERSED', 'MES_TRANSACTION_TYPE', 'MES_TRANSACTION_UDT',
                                'MES_TRANSACTION_TIME_WW', 'MES_USER_NAME', 'FROM_LOT_ID', 'FROM_MES_LOT_NAME', 'PREVIOUS_MES_LOT_NAME', 'NEW_MES_LOT_NAME', 'EXTERNAL_LOT_NAME',
                                'IMMEDIATE_PARENT_EXTERNAL_LOT', 'BOH_LOT_TYPE', 'EOH_LOT_TYPE', 'BOH_PART_ID', 'EOH_PART_ID', 'PART_ID', 'PACKAGE_TYPE', 'ECAT', 'EXTERNAL_PART_ID', 
                                'FROM_LOT_PART_ID', 'BOH_STAGE_SET', 'EOH_STAGE_SET', 'BOH_GOOD_WAFER_QUANTITY', 'EOH_GOOD_WAFER_QUANTITY', 'GOOD_WAFER_QUANTITY', 
                                'BOH_REJECT_WAFER_QUANTITY', 'EOH_REJECT_WAFER_QUANTITY', 'REJECT_WAFER_QUANTITY', 'BOH_TOTAL_WAFER_QUANTITY', 'EOH_TOTAL_WAFER_QUANTITY',
                                'BOH_GOOD_DIE_QUANTITY', 'EOH_GOOD_DIE_QUANTITY', 'GOOD_DIE_QUANTITY', 'BOH_REJECT_DIE_QUANTITY', 'EOH_REJECT_DIE_QUANTITY', 'REJECT_DIE_QUANTITY',
                                'BOH_TOTAL_DIE_QUANTITY', 'EOH_TOTAL_DIE_QUANTITY', 'BOH_FROM_LOT_GOOD_WAFER_QUANTITY', 'EOH_FROM_GOOD_WAFER_QUANTITY', 'BOH_FROM_REJECT_WAFER_QUANTITY',
                                'EOH_FROM_REJECT_WAFER_QUANTITY', 'BOH_FROM_TOTAL_WAFER_QUANTITY', 'EOH_FROM_TOTAL_WAFER_QUANTITY', 'BOH_FROM_GOOD_DIE_QUANTITY',
                                'EOH_FROM_GOOD_DIE_QUANTITY', 'BOH_FROM_REJECT_DIE_QUANTITY', 'EOH_FROM_REJECT_DIE_QUANTITY', 'BOH_FROM_TOTAL_DIE_QUANTITY', 
                                'EOH_FROM_TOTAL_DIE_QUANTITY', 'IS_VALUE', 'RMA_NUMBER', 'MRB_CASE_NUMBERS', 'IS_MAVERICK_LOT', 'HTS_COUNTRY', 'SUPPLIER', 'SUPPLIER_NAME', 
                                'SUPPLIER_LOCATION', 'SUPPLIER_PO_NUMBER', 'SALES_ORDER_ID', 'SHIPMENT_INVOICE_NUMBER', 'SHIPMENT_TRANSFER_PRICE_USED', 'IS_RETURN_SHIPMENT',
                                'SHIP_TO_CUSTOMER', 'JIT_LOCATION', 'WIP_START_UDT', 'WIP_END_UDT', 'PROCESS_PATH', 'COUNTRY_OF_SUBSTRATE', 'COUNTRY_OF_DIFFUSION', 
                                'FAB_LOCATION', 'FAB_MES_LOT_NAME', 'FAB_START_UDT', 'FAB_END_UDT', 'FAB_DATE_CODE', 'MASK_SET', 'MASK_SET_REVISION', 'SHELF_RACK',
                                'SHELF_ROW', 'SHELF_BIN', 'PDPW', 'SEAL_OPEN_UDT', 'DISPOSITION_UDT', 'SORT_MES_LOT_NAME', 'SORT_START_UDT', 'SORT_END_UDT',
                                'INK_UDT', 'SORT_PROGRAM_NAME', 'SORT_PROGRAM_REVISION', 'SORT_PROGRAM_CHECKSUM', 'SORT_TESTER_ID', 'SORT_PROBER_ID',
                                'SORT_PROBE_CARD', 'SORT_LOADBOARD_ID', 'SORT_DUT_BOARD_ID', 'COUNTRY_OF_BUMP', 'BUMP_LOCATION', 'ASSEMBLY_MES_LOT_NAME',
                                'ASSEMBLY_START_UDT', 'ASSEMBLY_END_UDT', 'TOP_SIDE_MARK', 'BACK_SIDE_MARK', 'IS_MARKED', 'DATE_CODE', 'DATE2_CODE',
                                'TRACE_CODE', 'TRACE2_CODE', 'FINAL_TEST_MES_LOT_NAME', 'FINAL_TEST_START_UDT', 'FINAL_TEST_END_UDT', 'FINAL_TEST_TEMP', 
                                'FINAL_TEST_PROGRAM_NAME', 'FINAL_TEST_PROGRAM_REVISION', 'FINAL_TEST_PROGRAM_CHECKSUM', 'FINAL_TEST_TESTER_ID', 'FINAL_TEST_HANDLER_ID', 
                                'FINAL_TEST_LOADBOARD_ID', 'FINAL_TEST_DUT_BOARD_ID', 'DRY_PACK_SEAL_UDT', 'SCHEDULED_START_UDT', 'PROJECTED_OUT_UDT', 'PROJECTED_OUT_WW',
                                'TARGET_PART_ID', 'ASSIGNED_TO', 'BIW_UPD_DTTM', 'BIW_BATCH_ID']					
		,post_hook= [v_sql_upd_success_batch]	
        )
}}
WITH 
STG_LOT_TXN_DTL AS
(
SELECT 
    LOT_TX_ID  AS LOT_TRANSACTION_ID,
    SYSTEM_LOT_NAME  AS SYSTEM_LOT_NUMBER,
    MES_LOT_NAME  ,
    LOT_ID ,
    LOCATION  ,
    LOT_TYPE  ,
    LOT_CATEGORY  ,
    LOT_STATE  ,
    STAGE_SET  ,
    TX_SOURCE  AS TRANSACTION_SOURCE,
    TX_PHYSICAL_SRC  AS TRANSACTION_PHYSICAL_SOURCE,
    ROW_NUMBER  AS ROW_NUMBER,
    TO_TIMESTAMP_TZ(SUBSTR(TX_POST_TIME,1,length(TX_POST_TIME)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM')   AS TRANSACTION_POST_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(SYSTEM_TX_TIME,1,length(SYSTEM_TX_TIME)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM')   AS SYSTEM_TRANSACTION_UDT,
    TX_PROC_SEGMENT  AS TRANSACTION_PROCEDURE_SEGMENT,
    TX_TYPE  AS TRANSACTION_TYPE,
    TX_REASON_CODE  AS TRANSACTION_REASON_CODE,
    TX_COMMENTS  AS TRANSACTION_COMMENTS,
    TX_ERROR_THRESHOLD_ID  AS TRANSACTION_ERROR_THRESHOLD_ID,
    coalesce(try_to_boolean(IS_TX_REVERSED),'False')::BOOLEAN  AS IS_TRANSACTION_REVERSED,
    MES_TX_TYPE  AS MES_TRANSACTION_TYPE,
    TO_TIMESTAMP_TZ(SUBSTR(MES_TX_TIME,1,length(MES_TX_TIME)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM') AS MES_TRANSACTION_UDT,
    MES_TX_TIME_WW  AS MES_TRANSACTION_TIME_WW,
    MES_USER_NAME  ,
    FROM_LOT_ID  ,
    FROM_MES_LOT_NAME  ,
    PREVIOUS_MES_LOT_NAME  ,
    NEW_MES_LOT_NAME  ,
    EXTERNAL_LOT_NAME  ,
    IMMEDIATE_PARENT_EXTERNAL_LOT  ,
    BOH_LOT_TYPE  ,
    EOH_LOT_TYPE  ,
    BOH_PART  AS BOH_PART_ID,
    EOH_PART  AS EOH_PART_ID,
    PART_NAME  AS PART_ID,
    PACKAGE_TYPE  ,
    ECAT  ,
    EXTERNAL_PART_NAME AS EXTERNAL_PART_ID  ,
    FROM_LOT_PART_NAME AS FROM_LOT_PART_ID ,
    BOH_STAGE_SET  ,
    EOH_STAGE_SET  ,
    BOH_GOOD_WAFER_QUANTITY  AS BOH_GOOD_WAFER_QUANTITY,
    EOH_GOOD_WAFER_QUANTITY  AS EOH_GOOD_WAFER_QUANTITY,
    GOOD_WAFER_QUANTITY  AS GOOD_WAFER_QUANTITY,
    BOH_REJECT_WAFER_QUANTITY  AS BOH_REJECT_WAFER_QUANTITY,
    EOH_REJECT_WAFER_QUANTITY  AS EOH_REJECT_WAFER_QUANTITY,
    REJECT_WAFER_QUANTITY  AS REJECT_WAFER_QUANTITY,
    BOH_TOTAL_WAFER_QUANTITY  AS BOH_TOTAL_WAFER_QUANTITY,
    EOH_TOTAL_WAFER_QUANTITY  AS EOH_TOTAL_WAFER_QUANTITY,
    BOH_GOOD_DIE_QUANTITY  AS BOH_GOOD_DIE_QUANTITY,
    EOH_GOOD_DIE_QUANTITY  AS EOH_GOOD_DIE_QUANTITY,
    GOOD_DIE_QUANTITY  AS GOOD_DIE_QUANTITY,
    BOH_REJECT_DIE_QUANTITY  AS BOH_REJECT_DIE_QUANTITY,
    EOH_REJECT_DIE_QUANTITY  AS EOH_REJECT_DIE_QUANTITY,
    REJECT_DIE_QUANTITY  AS REJECT_DIE_QUANTITY,
    BOH_TOTAL_DIE_QUANTITY  AS BOH_TOTAL_DIE_QUANTITY,
    EOH_TOTAL_DIE_QUANTITY  AS EOH_TOTAL_DIE_QUANTITY,
    BOH_FROM_LOT_GOOD_WAFER_QTY  AS BOH_FROM_LOT_GOOD_WAFER_QUANTITY,
    EOH_FROM_GOOD_WAFER_QTY  AS EOH_FROM_GOOD_WAFER_QUANTITY,
    BOH_FROM_REJECT_WAFER_QTY  AS BOH_FROM_REJECT_WAFER_QUANTITY,
    EOH_FROM_REJECT_WAFER_QTY  AS EOH_FROM_REJECT_WAFER_QUANTITY,
    BOH_FROM_TOTAL_WAFER_QTY  AS BOH_FROM_TOTAL_WAFER_QUANTITY,
    EOH_FROM_TOTAL_WAFER_QTY  AS EOH_FROM_TOTAL_WAFER_QUANTITY,
    BOH_FROM_GOOD_DIE_QTY  AS BOH_FROM_GOOD_DIE_QUANTITY,
    EOH_FROM_GOOD_DIE_QTY  AS EOH_FROM_GOOD_DIE_QUANTITY,
    BOH_FROM_REJECT_DIE_QTY  AS BOH_FROM_REJECT_DIE_QUANTITY,
    EOH_FROM_REJECT_DIE_QTY  AS EOH_FROM_REJECT_DIE_QUANTITY,
    BOH_FROM_TOTAL_DIE_QTY  AS BOH_FROM_TOTAL_DIE_QUANTITY,
    EOH_FROM_TOTAL_DIE_QTY  AS EOH_FROM_TOTAL_DIE_QUANTITY,
    coalesce(try_to_boolean(VALUE_CODE),'False')::Boolean AS IS_VALUE,
    RMA_NUMBER  ,
    MRB_CASE_NUMBERS ,
    coalesce(try_to_boolean(MAVERICK_LOT_FLAG),'False')::Boolean AS IS_MAVERICK_LOT,
    HTS_COUNTRY  ,
    SUPPLIER  ,
    SUPPLIER_NAME  ,
    SUPPLIER_LOCATION  ,
    SUPPLIER_PO_NUMBER  ,
    SALES_ORDER_ID  ,
    SHIPMENT_INVOICE_NUMBER,
    SHIPMENT_TRANSFER_PRICE_USED  AS SHIPMENT_TRANSFER_PRICE_USED,
    coalesce(try_to_boolean(RETURN_SHIPMENT_FLAG),'False')::Boolean   AS IS_RETURN_SHIPMENT,
    SHIP_TO_CUSTOMER  ,
    JIT_LOCATION ,
    TO_TIMESTAMP_TZ(SUBSTR(WIP_START_DATE,1,length(WIP_START_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')   AS WIP_START_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(WIP_END_DATE,1,length(WIP_END_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS WIP_END_UDT,
    PROCESS_PATH  ,
    COUNTRY_OF_SUBSTRATE  ,
    COUNTRY_OF_DIFFUSION,
    FAB_LOCATION  ,
    FAB_LOT_ID as FAB_MES_LOT_NAME,
    TO_TIMESTAMP_TZ(SUBSTR(FAB_START_DATE,1,length(FAB_START_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS FAB_START_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(FAB_END_DATE,1,length(FAB_END_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS FAB_END_UDT,
    FAB_DATE_CODE  ,
    MASK_SET  ,
    MASK_SET_REVISION  ,
    SHELF_RACK  ,
    SHELF_ROW  ,
    SHELF_BIN  ,
    PDPW  ,
    TO_TIMESTAMP_TZ(SUBSTR(SEAL_OPEN_DATE,1,length(SEAL_OPEN_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS SEAL_OPEN_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(DISPOSITION_DATE,1,length(DISPOSITION_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS DISPOSITION_UDT,
    SORT_LOT_ID AS SORT_MES_LOT_NAME  ,
    TO_TIMESTAMP_TZ(SUBSTR(SORT_START_DATE,1,length(SORT_START_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS SORT_START_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(SORT_END_DATE,1,length(SORT_END_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS SORT_END_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(INK_DATE,1,length(INK_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS INK_UDT,
    SORT_PROGRAM_NAME  ,
    SORT_PROGRAM_REVISION  ,
    SORT_PROGRAM_CHECKSUM  ,
    SORT_TESTER_ID  ,
    SORT_PROBER_ID  ,
    SORT_PROBE_CARD  ,
    SORT_LOADBOARD_ID  ,
    SORT_DUT_BOARD_ID  ,
    COUNTRY_OF_BUMP  ,
    BUMP_LOCATION  ,
    ASSEMBLY_LOT_ID  AS ASSEMBLY_MES_LOT_NAME,
    TO_TIMESTAMP_TZ(SUBSTR(ASSEMBLY_START_DATE,1,length(ASSEMBLY_START_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS ASSEMBLY_START_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(ASSEMBLY_END_DATE,1,length(ASSEMBLY_END_DATE)-3)  || ' +00:00','DD-MON-YYYY HH24:MI:SS TZH:TZM')  AS ASSEMBLY_END_UDT,
    TOP_SIDE_MARK  ,
    BACK_SIDE_MARK  ,
    coalesce(try_to_boolean(MARK_FLAG),'False')::BOOLEAN AS IS_MARKED,
    DATE_CODE  ,
    DATE_CODE_2  AS DATE2_CODE,
    TRACE_CODE  ,
    TRACE_CODE_2  AS TRACE2_CODE,
    FINAL_TEST_LOT_ID AS FINAL_TEST_MES_LOT_NAME ,
    TO_TIMESTAMP_TZ(SUBSTR(FINAL_TEST_START_DATE,1,length(FINAL_TEST_START_DATE)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM')  AS FINAL_TEST_START_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(FINAL_TEST_END_DATE,1,length(FINAL_TEST_END_DATE)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM')  AS FINAL_TEST_END_UDT,
    FINAL_TEST_TEMP  ,
    FINAL_TEST_PROGRAM_NAME  ,
    FINAL_TEST_PROGRAM_REV AS FINAL_TEST_PROGRAM_REVISION ,
    FINAL_TEST_PROGRAM_CHECKSUM  ,
    FINAL_TEST_TESTER_ID  ,
    FINAL_TEST_HANDLER_ID  ,
    FINAL_TEST_LOADBOARD_ID  ,
    FINAL_TEST_DUT_BOARD_ID  ,
    TO_TIMESTAMP_TZ(SUBSTR(DRY_PACK_SEAL_DATE,1,length(DRY_PACK_SEAL_DATE)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM') AS DRY_PACK_SEAL_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(SCHEDULED_START_DATE,1,length(SCHEDULED_START_DATE)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM')  AS SCHEDULED_START_UDT,
    TO_TIMESTAMP_TZ(SUBSTR(PROJECTED_OUT_DATE,1,length(PROJECTED_OUT_DATE)-3)  || ' +00:00','MM/DD/YYYY HH24:MI:SS TZH:TZM')   AS PROJECTED_OUT_UDT,
    PROJECTED_OUT_WW  ,
    TARGET_PART_ID  ,
    ASSIGNED_TO  ,
    '{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_INS_DTTM ,
	'{{V_START_DTTM}}'::TIMESTAMP_NTZ BIW_UPD_DTTM ,
	{{V_BIW_BATCH_ID}} as BIW_BATCH_ID   ,
    md5(object_construct ('col1',SYSTEM_LOT_NUMBER, 'col2',MES_LOT_NAME, 'col3',LOT_ID, 'col4',LOCATION, 'col5',LOT_TYPE, 'col6',LOT_CATEGORY, 'col7',LOT_STATE,
    'col8',STAGE_SET, 'col9',TRANSACTION_SOURCE, 'col10',TRANSACTION_PHYSICAL_SOURCE, 'col11',ROW_NUMBER, 'col12',TRANSACTION_POST_UDT, 'col13',SYSTEM_TRANSACTION_UDT,
    'col14',TRANSACTION_PROCEDURE_SEGMENT, 'col15',TRANSACTION_TYPE, 'col16',TRANSACTION_REASON_CODE, 'col17',TRANSACTION_COMMENTS, 'col18',TRANSACTION_ERROR_THRESHOLD_ID,
    'col19',IS_TRANSACTION_REVERSED, 'col20',MES_TRANSACTION_TYPE, 'col21',MES_TRANSACTION_UDT, 'col22',MES_TRANSACTION_TIME_WW, 'col23',MES_USER_NAME, 
    'col24',FROM_LOT_ID, 'col25',FROM_MES_LOT_NAME, 'col26',PREVIOUS_MES_LOT_NAME, 'col27',NEW_MES_LOT_NAME, 'col28',EXTERNAL_LOT_NAME, 'col29',IMMEDIATE_PARENT_EXTERNAL_LOT,
    'col30',BOH_LOT_TYPE, 'col31',EOH_LOT_TYPE, 'col32',BOH_PART_ID, 'col33',EOH_PART_ID, 'col34',PART_ID, 'col35',PACKAGE_TYPE, 'col36',ECAT, 'col37',EXTERNAL_PART_ID,
    'col38',FROM_LOT_PART_ID, 'col39',BOH_STAGE_SET, 'col40',EOH_STAGE_SET, 'col41',BOH_GOOD_WAFER_QUANTITY, 'col42',EOH_GOOD_WAFER_QUANTITY, 'col43',GOOD_WAFER_QUANTITY,
    'col44',BOH_REJECT_WAFER_QUANTITY, 'col45',EOH_REJECT_WAFER_QUANTITY, 'col46',REJECT_WAFER_QUANTITY, 'col47',BOH_TOTAL_WAFER_QUANTITY, 'col48',EOH_TOTAL_WAFER_QUANTITY,
    'col49',BOH_GOOD_DIE_QUANTITY, 'col50',EOH_GOOD_DIE_QUANTITY, 'col51',GOOD_DIE_QUANTITY, 'col52',BOH_REJECT_DIE_QUANTITY, 'col53',EOH_REJECT_DIE_QUANTITY,
    'col54',REJECT_DIE_QUANTITY, 'col55',BOH_TOTAL_DIE_QUANTITY, 'col56',EOH_TOTAL_DIE_QUANTITY, 'col57',BOH_FROM_LOT_GOOD_WAFER_QUANTITY,
    'col58',EOH_FROM_GOOD_WAFER_QUANTITY, 'col59',BOH_FROM_REJECT_WAFER_QUANTITY, 'col60',EOH_FROM_REJECT_WAFER_QUANTITY,
    'col61',BOH_FROM_TOTAL_WAFER_QUANTITY, 'col62',EOH_FROM_TOTAL_WAFER_QUANTITY, 'col63',BOH_FROM_GOOD_DIE_QUANTITY, 'col64',EOH_FROM_GOOD_DIE_QUANTITY, 
    'col65',BOH_FROM_REJECT_DIE_QUANTITY, 'col66',EOH_FROM_REJECT_DIE_QUANTITY, 'col67',BOH_FROM_TOTAL_DIE_QUANTITY, 'col68',EOH_FROM_TOTAL_DIE_QUANTITY, 
    'col69',IS_VALUE, 'col70',RMA_NUMBER, 'col71',MRB_CASE_NUMBERS, 'col72',IS_MAVERICK_LOT, 'col73',HTS_COUNTRY, 'col74',SUPPLIER, 'col75',SUPPLIER_NAME, 
    'col76',SUPPLIER_LOCATION, 'col77',SUPPLIER_PO_NUMBER, 'col78',SALES_ORDER_ID, 'col79',SHIPMENT_INVOICE_NUMBER, 'col80',SHIPMENT_TRANSFER_PRICE_USED, 
    'col81',IS_RETURN_SHIPMENT, 'col82',SHIP_TO_CUSTOMER, 'col83',JIT_LOCATION, 'col84',WIP_START_UDT, 'col85',WIP_END_UDT, 'col86',PROCESS_PATH, 
    'col87',COUNTRY_OF_SUBSTRATE, 'col88',COUNTRY_OF_DIFFUSION, 'col89',FAB_LOCATION, 'col90',FAB_MES_LOT_NAME, 'col91',FAB_START_UDT, 'col92',FAB_END_UDT, 
    'col93',FAB_DATE_CODE, 'col94',MASK_SET, 'col95',MASK_SET_REVISION, 'col96',SHELF_RACK, 'col97',SHELF_ROW, 'col98',SHELF_BIN, 'col99',PDPW, 'col100',SEAL_OPEN_UDT, 
    'col101',DISPOSITION_UDT, 'col102',SORT_MES_LOT_NAME, 'col103',SORT_START_UDT, 'col104',SORT_END_UDT, 'col105',INK_UDT, 'col106',SORT_PROGRAM_NAME, 
    'col107',SORT_PROGRAM_REVISION, 'col108',SORT_PROGRAM_CHECKSUM, 'col109',SORT_TESTER_ID, 'col110',SORT_PROBER_ID, 'col111',SORT_PROBE_CARD, 'col112',SORT_LOADBOARD_ID, 
    'col113',SORT_DUT_BOARD_ID, 'col114',COUNTRY_OF_BUMP, 'col115',BUMP_LOCATION, 'col116',ASSEMBLY_MES_LOT_NAME, 'col117',ASSEMBLY_START_UDT, 'col118',ASSEMBLY_END_UDT, 
    'col119',TOP_SIDE_MARK, 'col120',BACK_SIDE_MARK, 'col121',IS_MARKED, 'col122',DATE_CODE, 'col123',DATE2_CODE, 'col124',TRACE_CODE, 'col125',TRACE2_CODE, 
    'col126',FINAL_TEST_MES_LOT_NAME, 'col127',FINAL_TEST_START_UDT, 'col128',FINAL_TEST_END_UDT, 'col129',FINAL_TEST_TEMP, 'col130',FINAL_TEST_PROGRAM_NAME, 
    'col131',FINAL_TEST_PROGRAM_REVISION, 'col132',FINAL_TEST_PROGRAM_CHECKSUM, 'col133',FINAL_TEST_TESTER_ID, 'col134',FINAL_TEST_HANDLER_ID, 'col135',FINAL_TEST_LOADBOARD_ID, 
    'col136',FINAL_TEST_DUT_BOARD_ID, 'col137',DRY_PACK_SEAL_UDT, 'col138',SCHEDULED_START_UDT, 'col139',PROJECTED_OUT_UDT, 'col140',PROJECTED_OUT_WW, 'col141',TARGET_PART_ID, 
    'col142',ASSIGNED_TO)::string ) as BIW_MD5_KEY
FROM 
{{source('STG_E2OPEN','LOT_TXN_DTL')}}
{% if is_incremental() %}
    WHERE BIW_UPD_DTTM >= '{{V_LWM}}'
    AND BIW_UPD_DTTM < '{{V_HWM}}'
{% endif %}
QUALIFY (
    ROW_NUMBER() OVER (PARTITION BY LOT_TRANSACTION_ID ORDER BY BIW_UPD_DTTM DESC)=1 -- LATEST ON EACH PK
    )
)
SELECT
STG.*
FROM STG_LOT_TXN_DTL STG
--- ADD IF EXISTING ON UPDATE
{% if is_incremental() %}
    LEFT JOIN {{ this }} TGT
    on STG.LOT_TRANSACTION_ID= TGT.LOT_TRANSACTION_ID
    WHERE TGT.BIW_MD5_KEY<>STG.BIW_MD5_KEY OR TGT.BIW_MD5_KEY IS NULL
{% endif %}