 {{  config (   
     description = "S2P DATA DISCOVERY VIEW OF AP_TERMS_TL ",    
     materialized = "view",    
     schema = "PROCUREMENT",    
     tags = ["PROCUREMENT"],   
     alias = "AP_TERMS_TL" 
     )  
}} 
SELECT 
TERM_ID 
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_LOGIN
, NAME
, ENABLED_FLAG
, DUE_CUTOFF_DAY
, DESCRIPTION
, TYPE
, START_DATE_ACTIVE
, END_DATE_ACTIVE
, RANK
, ATTRIBUTE_CATEGORY
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE5
, ATTRIBUTE6
, ATTRIBUTE7
, ATTRIBUTE8
, ATTRIBUTE9
, ATTRIBUTE10
, ATTRIBUTE11
, ATTRIBUTE12
, ATTRIBUTE13
, ATTRIBUTE14
, ATTRIBUTE15
, LANGUAGE
, SOURCE_LANG
, BIW_INS_DTTM
, BIW_UPD_DTTM
, BIW_BATCH_ID
FROM {{source("STG_EBS_AP","AP_TERMS_TL")}}     
QUALIFY( ROW_NUMBER() OVER (PARTITION BY TERM_ID ORDER BY BIW_UPD_DTTM DESC)=1)