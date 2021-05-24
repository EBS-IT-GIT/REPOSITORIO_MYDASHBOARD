update apps.ra_customer_trx_lines_all
set customer_trx_id = -customer_trx_id
where customer_trx_id = 16411379
and (customer_trx_line_id IN (22870233,22870234) or link_to_cust_trx_line_id IN (22870233,22870234));
--6 rows
/
EXIT