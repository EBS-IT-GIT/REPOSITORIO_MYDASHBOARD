update ra_interface_lines_all
set reference_line_id = 11087510
where interface_line_attribute1 IN ('289934')
and reference_line_id is null;
--1 rows
/
EXIT