update ra_customer_trx_lines_all
set interfacE_line_context = null
,interface_line_attribute1 = null
,interface_line_attribute2 = null
,interface_line_attribute3 = null
,interface_line_attribute4 = null
,interface_line_attribute5 = null
,interface_line_attribute6 = null
,interface_line_attribute7 = null
,interface_line_attribute8 = null
,interface_line_attribute9 = null
,interface_line_attribute10 = null
,interface_line_attribute11 = null
,interface_line_attribute12 = null
,interface_line_attribute13 = null
,interface_line_attribute14 = null
,interface_line_attribute15 = null
,attribute7 = null
where customer_trx_id IN ( 15465427)
and interface_line_attribute1 is not null;
--2 Row
/
EXIT