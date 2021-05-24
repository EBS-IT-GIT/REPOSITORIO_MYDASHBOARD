update ap_invoice_lines_all
set item_description = XX_UTIL_PK.xml_accepted_chars(item_description)
     , description = XX_UTIL_PK.xml_accepted_chars(description)
     , last_updated_by = 2070
     , last_update_date = sysdate
where invoice_id = 6121695
and  (XX_UTIL_PK.xml_accepted_chars(item_description) <> item_description  or XX_UTIL_PK.xml_accepted_chars(description) <>description);

-- Cantidad de Filas a actualizar = 2