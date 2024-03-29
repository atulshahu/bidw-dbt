{{ 
config
(
  description = 'EFK view for INVENTORY_WORKING_CAPITAL_MONTHLY_RPT table', 
  materialized = 'view', 
  schema = 'GSCO', 
  tags = ['GSCO_EFK'],
  alias = 'INVENTORY_WORKING_CAPITAL_MONTHLY_RPT'
) 
}}

SELECT 
    WORKING_CAPITAL_MONTH_KEY, 
    SNAPSHOT_MONTH_KEY, 
    TRANSACTION_ID, 
    LOT_NUMBER, 
    CATEGORY, 
    CATEGORY_LEVEL_2, 
    CATEGORY_LEVEL_3, 
    IS_CONSIGNED, 
    SUPPLIER, 
    TRANSACTION_QUANTITY, 
    SUBINVENTORY_CODE, 
    INVENTORY_ITEM_ID, 
    LAST_MOVE_ORDER, 
    ONHAND_QUANTITY, 
    EXPIRY_DATE, 
    LINE_NUMBER, 
    UOM, 
    DESCRIPTION, 
    ORG_CODE, 
    PART_NUMBER, 
    MOVE_ORDER_LINE_ID, 
    INVENTORY_AMOUNT, 
    DATE_RECEIVED, 
    ITEM_COST, 
    CONSIGNED_AMOUNT,
    OWNED_AMOUNT,
    TRANSACTION_YEAR,
    QTR_OF_YEAR,
    TRANSACTION_MONTH,
    WEEK_OF_YEAR,     
    BIW_INS_DTTM, 
    BIW_UPD_DTTM, 
    BIW_BATCH_ID, 
    BIW_MD5_KEY
FROM {{ref('MART_GSCO_INVENTORY_WORKING_CAPITAL_MONTHLY_RPT')}}