{%- set v_sql_update_tgt -%}
     update ETL_MART_E2OPEN.E2O_LOT_TXN_DTL_DRVD TGT
     set  HOLD_COUNT =  STG.HOLD_COUNT
     from ETL_MART_E2OPEN.E2O_LOT_TXN_DTL_DRVD_UPDATE_STG  STG
     where TGT.SYSTEM_LOT_NUMBER = STG.SYSTEM_LOT_NUMBER
     and TGT.LOT_TRANSACTION_ID = STG.LOT_TRANSACTION_ID;
{%endset%}
{{ config(
    description = 'Update E2O_LOT_TXN_DTL_DRVD with new hold_count', 
    materialized = 'table', 
    schema ='ETL_MART_E2OPEN',
    alias= 'E2O_LOT_TXN_DTL_DRVD_UPDATE_STG',
    tags =['E2OPEN'],
    post_hook = v_sql_update_tgt
    ) 
}} 
WITH 
MISSING_HOLD_LOTS AS 
(
SELECT  
    DISTINCT  
    SYSTEM_LOT_NUMBER
FROM  {{ref('ETL_MART_E2OPEN_E2O_LOT_TXN_DTL_DRVD')}}
WHERE  TRANSACTION_TYPE IN ('HoldLot','ReleaseLot') 
AND HOLD_COUNT IS NULL
),
MISSING_HOLD_TXN AS
(
SELECT 
    TXN.SYSTEM_LOT_NUMBER,
    TXN.LOT_TRANSACTION_ID,
    TXN.TRANSACTION_TYPE,
    TXN.TRANSACTION_REASON_CODE,
    TXN.HOLD_COUNT,
    LAG(TXN.HOLD_COUNT) OVER (PARTITION BY TXN.SYSTEM_LOT_NUMBER ORDER BY TXN.LOT_TRANSACTION_ID) as PRIOR_HOLD_COUNT,
    LAG(TXN.TRANSACTION_TYPE) OVER (PARTITION BY TXN.SYSTEM_LOT_NUMBER ORDER BY TXN.LOT_TRANSACTION_ID) as PRIOR_TRANSACTION_TYPE,
    CASE 
    WHEN PRIOR_TRANSACTION_TYPE not in  ('HoldLot','ReleaseLot')  and TRANSACTION_TYPE in  ('HoldLot','ReleaseLot') 
    THEN 1 
    ELSE 0 
    END TRXN_CHANGE_TYPE
FROM
{{ref('ETL_MART_E2OPEN_E2O_LOT_TXN_DTL_DRVD')}} TXN
INNER JOIN MISSING_HOLD_LOTS LOT
 on LOT.SYSTEM_LOT_NUMBER = txn.SYSTEM_LOT_NUMBER
)
--SETTING SEQUENCE ON LOTS 
,SUB_MISSING_HOLD_TXN as(
SELECT 
    SYSTEM_LOT_NUMBER,
    LOT_TRANSACTION_ID,
    TRANSACTION_TYPE,
    TRANSACTION_REASON_CODE,
    TRXN_CHANGE_TYPE,
    HOLD_COUNT,
    PRIOR_HOLD_COUNT,
    ROW_NUMBER()OVER (PARTITION BY SYSTEM_LOT_NUMBER ORDER BY LOT_TRANSACTION_ID ) TRXN_ORDER
FROM MISSING_HOLD_TXN
WHERE HOLD_COUNT IS NULL 
--AND SYSTEM_LOT_NUMBER IN (539577,1696415,1180276,1702133,1695956)
ORDER BY 2
)
,RECURSIVE_DATA as (
SELECT 
  SYSTEM_LOT_NUMBER,
  LOT_TRANSACTION_ID,
  TRANSACTION_TYPE,
  TRANSACTION_REASON_CODE,
  CASE
    WHEN TRANSACTION_TYPE='HoldLot' 
            THEN coalesce(PRIOR_HOLD_COUNT,0)+1
    WHEN TRANSACTION_TYPE ='ReleaseLot' and TRANSACTION_REASON_CODE !='ReleaseAll' and coalesce(PRIOR_HOLD_COUNT,0)>0
            THEN  coalesce(PRIOR_HOLD_COUNT,0)-1
   ELSE 0    
  END as HOLD_COUNT,
  TRXN_ORDER
FROM 
SUB_MISSING_HOLD_TXN
WHERE 
TRXN_CHANGE_TYPE = 1
  
UNION ALL

SELECT 
    P.SYSTEM_LOT_NUMBER,
    C.LOT_TRANSACTION_ID,
    C.TRANSACTION_TYPE,
    C.TRANSACTION_REASON_CODE,
    CASE
    WHEN C.TRANSACTION_TYPE='HoldLot' 
        THEN P.HOLD_COUNT + 1
    WHEN C.TRANSACTION_TYPE ='ReleaseLot' and C.TRANSACTION_REASON_CODE !='ReleaseAll' and P.HOLD_COUNT >0
        THEN  P.HOLD_COUNT -1
    ELSE 0    
    END HOLD_COUNT,
    C.TRXN_ORDER
FROM 
SUB_MISSING_HOLD_TXN C
INNER JOIN
RECURSIVE_DATA P
 ON C.SYSTEM_LOT_NUMBER = P.SYSTEM_LOT_NUMBER
  and C.TRXN_ORDER -1 = P.TRXN_ORDER
WHERE 
C.TRXN_CHANGE_TYPE <> 1
)
SELECT 
    SYSTEM_LOT_NUMBER,
    LOT_TRANSACTION_ID,
    TRANSACTION_TYPE,
    TRANSACTION_REASON_CODE,
    HOLD_COUNT
FROM 
RECURSIVE_DATA