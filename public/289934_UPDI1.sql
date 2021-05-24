update ra_interface_lines_all
set interface_line_id = null
,trx_date = TRUNC(SYSDATE)
,gl_date = TRUNC(SYSDATE)
where interface_line_attribute1 IN ('289934');
--2 rows
/
EXIT