update ra_customer_trx_all
set interfacE_header_context = null
,interface_header_attribute1 = null
,interface_header_attribute2 = null
,interface_header_attribute3 = null
,interface_header_attribute4 = null
,interface_header_attribute5 = null
,interface_header_attribute6 = null
,interface_header_attribute7 = null
,interface_header_attribute8 = null
,interface_header_attribute9 = null
,interface_header_attribute10 = null
,interface_header_attribute11 = null
,interface_header_attribute12 = null
,interface_header_attribute13 = null
,interface_header_attribute14 = null
,interface_header_attribute15 = null
,ct_reference = null
where customer_trx_id IN ( 14174240)
and interface_header_attribute1 is not null;
--1 Rows
/
EXIT