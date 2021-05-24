insert into ra_interface_lines_all
select *
from apps.xx_ar_iface_lines_all ustom
where interface_line_attribute1 IN ('139074','139076');
--4 rows
/
EXIT