{{ 
config
(
  description = 'EFK view for INVENTORY_CHEMICAL_USAGE_RPT table', 
  materialized = 'view', 
  schema = 'GSCO', 
  tags = ['GSCO_EFK'],
  alias = 'INVENTORY_CHEMICAL_USAGE_RPT'
) 
}}

SELECT 
  TRANSACTION_ID,
  CHARGE_COST_CENTER,
  DESCRIPTION,
  TRANSACTION_DATE,
  TRANSACTION_UOM,
  TRX_YEAR AS TRANSACTION_YEAR,
  TRX_MONTH AS TRANSACTION_MONTH,
  TRANSACTION_QUANTITY,
  PART_NUMBER,
  AVG_UNIT_COST AS AVERAGE_UNIT_COST,
  TOTAL_COST, 
  INVENTORY_ITEM_ID,
  NATURAL_ACCOUNT_CHARGED,
  ACCT_CODE_DESCRIPTION,
  REQUEST_NUMBER,
  COST_CENTER_CODE_DESCRIPTION,
  WEEK_OF_YEAR,
  GF_CATEGORY_CODE AS CATEGORY_COMBINATION,
  CONSIGNED_FLAG AS CONSIGNED,
  DROP_LOCATION,
  FROM_LOCATOR,
  LOT_NUMBER,
  PLANNER_CODE,
  ORGANIZATION_CODE AS FAB_NAME,
  TRANSACTION_TYPE_NAME AS TRANSACTION_TYPE,
  BIW_INS_DTTM,
  BIW_UPD_DTTM,
  BIW_BATCH_ID 
FROM {{source('STG_EBS_APPS','XXON_INV_CHEMICAL_USAGE_V')}}
QUALIFY (ROW_NUMBER() OVER (PARTITION BY TRANSACTION_ID ORDER BY BIW_UPD_DTTM DESC )=1)