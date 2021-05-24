UPDATE apps.hz_parties
SET    attribute7 = 'N'
WHERE  party_id IN (
SELECT party_id
FROM   apps.hz_cust_accounts
WHERE  customer_class_code = 'INTERCOMPANY'
AND    attribute_category = 'AR');
--18 Registros