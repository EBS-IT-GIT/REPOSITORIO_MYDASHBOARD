-- logado com bolinf 
GRANT ALL ON SAE_ATIVA_FORNECEDOR_COMPRA to apps;

-- logado com apps
CREATE OR REPLACE SYNONYM SAE_ATIVA_FORNECEDOR_COMPRA FOR bolinf.SAE_ATIVA_FORNECEDOR_COMPRA;

GRANT ALL ON ap_supplier_sites_all TO bolinf; 

GRANT ALL ON hz_party_site_uses_pkg TO bolinf;
GRANT ALL ON HZ_PARTY_SITE_USES TO bolinf;