update ap_invoice_distributions_all set attribute5 = null
where attribute_category = 'AR'  
           and attribute5 is not null and  REGEXP_instr(attribute5,'[^0-9]') > 0;
           
-- Total de filas a actualizar = 377 