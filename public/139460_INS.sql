insert into ra_interface_lines_all
select distinct *
from apps.xx_ar_iface_lines_all ustom
where interface_line_attribute1 IN ('139460')
and interface_line_id is null;
--2 rows
/
EXIT
