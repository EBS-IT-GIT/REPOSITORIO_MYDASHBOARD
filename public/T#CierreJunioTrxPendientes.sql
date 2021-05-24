UPDATE 
apps.mtl_Transactions_interface a
SET 
a.last_update_date = sysdate,
a.last_updated_by = 2070,
A.DISTRIBUTION_aCCOUNT_ID = 9093942
WHERE 
A.TRANSACTION_INTERFACE_ID IN (103236430,103236431);


UPDATE 
apps.mtl_Transactions_interface a
SET
a.last_update_date = sysdate,
a.last_updated_by = 2070, 
A.DISTRIBUTION_aCCOUNT_ID = 9093943
WHERE 
A.TRANSACTION_INTERFACE_ID IN (103236432);


UPDATE 
apps.mtl_Transactions_interface a
SET 
a.last_update_date = sysdate,
a.last_updated_by = 2070,
A.DISTRIBUTION_aCCOUNT_ID = 9093944
WHERE 
A.TRANSACTION_INTERFACE_ID IN (103236433,103236434)
;