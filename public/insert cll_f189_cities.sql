set serveroutput on size unlimited
declare
   cursor cidades is
select 'RO' state_code, 'ALTA FLORESTA D''OESTE' city_code, '1100015' ibge_code from dual union
select 'RO' state_code, 'ALTO ALEGRE DOS PARECIS' city_code, '1100379' ibge_code from dual union
select 'RO' state_code, 'ALTO PARAISO' city_code, '1100403' ibge_code from dual union
select 'RO' state_code, 'ALVORADA D''OESTE' city_code, '1100346' ibge_code from dual union
select 'RO' state_code, 'ARIQUEMES' city_code, '1100023' ibge_code from dual union
select 'RO' state_code, 'BURITIS' city_code, '1100452' ibge_code from dual union
select 'RO' state_code, 'CABIXI' city_code, '1100031' ibge_code from dual union
select 'RO' state_code, 'CACAULANDIA' city_code, '1100601' ibge_code from dual union
select 'RO' state_code, 'CACOAL' city_code, '1100049' ibge_code from dual union
select 'RO' state_code, 'CAMPO NOVO DE RONDONIA' city_code, '1100700' ibge_code from dual union
select 'RO' state_code, 'CANDEIAS DO JAMARI' city_code, '1100809' ibge_code from dual union
select 'RO' state_code, 'CASTANHEIRAS' city_code, '1100908' ibge_code from dual union
select 'RO' state_code, 'CEREJEIRAS' city_code, '1100056' ibge_code from dual union
select 'RO' state_code, 'CHUPINGUAIA' city_code, '1100924' ibge_code from dual union
select 'RO' state_code, 'COLORADO DO OESTE' city_code, '1100064' ibge_code from dual union
select 'RO' state_code, 'CORUMBIARA' city_code, '1100072' ibge_code from dual union
select 'RO' state_code, 'COSTA MARQUES' city_code, '1100080' ibge_code from dual union
select 'RO' state_code, 'CUJUBIM' city_code, '1100940' ibge_code from dual union
select 'RO' state_code, 'ESPIGAO D''OESTE' city_code, '1100098' ibge_code from dual union
select 'RO' state_code, 'GOVERNADOR JORGE TEIXEIRA' city_code, '1101005' ibge_code from dual union
select 'RO' state_code, 'GUAJARA-MIRIM' city_code, '1100106' ibge_code from dual union
select 'RO' state_code, 'ITAPUA DO OESTE' city_code, '1101104' ibge_code from dual union
select 'RO' state_code, 'JARU' city_code, '1100114' ibge_code from dual union
select 'RO' state_code, 'JI-PARANA' city_code, '1100122' ibge_code from dual union
select 'RO' state_code, 'MACHADINHO D''OESTE' city_code, '1100130' ibge_code from dual union
select 'RO' state_code, 'MINISTRO ANDREAZZA' city_code, '1101203' ibge_code from dual union
select 'RO' state_code, 'MIRANTE DA SERRA' city_code, '1101302' ibge_code from dual union
select 'RO' state_code, 'MONTE NEGRO' city_code, '1101401' ibge_code from dual union
select 'RO' state_code, 'NOVA BRASILANDIA D''OESTE' city_code, '1100148' ibge_code from dual union
select 'RO' state_code, 'NOVA MAMORE' city_code, '1100338' ibge_code from dual union
select 'RO' state_code, 'NOVA UNIAO' city_code, '1101435' ibge_code from dual union
select 'RO' state_code, 'NOVO HORIZONTE DO OESTE' city_code, '1100502' ibge_code from dual union
select 'RO' state_code, 'OURO PRETO DO OESTE' city_code, '1100155' ibge_code from dual union
select 'RO' state_code, 'PARECIS' city_code, '1101450' ibge_code from dual union
select 'RO' state_code, 'PIMENTA BUENO' city_code, '1100189' ibge_code from dual union
select 'RO' state_code, 'PIMENTEIRAS DO OESTE' city_code, '1101468' ibge_code from dual union
select 'RO' state_code, 'PORTO VELHO' city_code, '1100205' ibge_code from dual union
select 'RO' state_code, 'PRESIDENTE MEDICI' city_code, '1100254' ibge_code from dual union
select 'RO' state_code, 'PRIMAVERA DE RONDONIA' city_code, '1101476' ibge_code from dual union
select 'RO' state_code, 'RIO CRESPO' city_code, '1100262' ibge_code from dual union
select 'RO' state_code, 'ROLIM DE MOURA' city_code, '1100288' ibge_code from dual union
select 'RO' state_code, 'SANTA LUZIA D''OESTE' city_code, '1100296' ibge_code from dual union
select 'RO' state_code, 'SAO FELIPE D''OESTE' city_code, '1101484' ibge_code from dual union
select 'RO' state_code, 'SAO FRANCISCO DO GUAPORE' city_code, '1101492' ibge_code from dual union
select 'RO' state_code, 'SAO MIGUEL DO GUAPORE' city_code, '1100320' ibge_code from dual union
select 'RO' state_code, 'SERINGUEIRAS' city_code, '1101500' ibge_code from dual union
select 'RO' state_code, 'TEIXEIROPOLIS' city_code, '1101559' ibge_code from dual union
select 'RO' state_code, 'THEOBROMA' city_code, '1101609' ibge_code from dual union
select 'RO' state_code, 'URUPA' city_code, '1101708' ibge_code from dual union
select 'RO' state_code, 'VALE DO ANARI' city_code, '1101757' ibge_code from dual union
select 'RO' state_code, 'VALE DO PARAISO' city_code, '1101807' ibge_code from dual union
select 'RO' state_code, 'VILHENA' city_code, '1100304' ibge_code from dual union
select 'AC' state_code, 'ACRELANDIA' city_code, '1200013' ibge_code from dual union
select 'AC' state_code, 'ASSIS BRASIL' city_code, '1200054' ibge_code from dual union
select 'AC' state_code, 'BRASILEIA' city_code, '1200104' ibge_code from dual union
select 'AC' state_code, 'BUJARI' city_code, '1200138' ibge_code from dual union
select 'AC' state_code, 'CAPIXABA' city_code, '1200179' ibge_code from dual union
select 'AC' state_code, 'CRUZEIRO DO SUL' city_code, '1200203' ibge_code from dual union
select 'AC' state_code, 'EPITACIOLANDIA' city_code, '1200252' ibge_code from dual union
select 'AC' state_code, 'FEIJO' city_code, '1200302' ibge_code from dual union
select 'AC' state_code, 'JORDAO' city_code, '1200328' ibge_code from dual union
select 'AC' state_code, 'MANCIO LIMA' city_code, '1200336' ibge_code from dual union
select 'AC' state_code, 'MANOEL URBANO' city_code, '1200344' ibge_code from dual union
select 'AC' state_code, 'MARECHAL THAUMATURGO' city_code, '1200351' ibge_code from dual union
select 'AC' state_code, 'PLACIDO DE CASTRO' city_code, '1200385' ibge_code from dual union
select 'AC' state_code, 'PORTO ACRE' city_code, '1200807' ibge_code from dual union
select 'AC' state_code, 'PORTO WALTER' city_code, '1200393' ibge_code from dual union
select 'AC' state_code, 'RIO BRANCO' city_code, '1200401' ibge_code from dual union
select 'AC' state_code, 'RODRIGUES ALVES' city_code, '1200427' ibge_code from dual union
select 'AC' state_code, 'SANTA ROSA DO PURUS' city_code, '1200435' ibge_code from dual union
select 'AC' state_code, 'SENA MADUREIRA' city_code, '1200500' ibge_code from dual union
select 'AC' state_code, 'SENADOR GUIOMARD' city_code, '1200450' ibge_code from dual union
select 'AC' state_code, 'TARAUACA' city_code, '1200609' ibge_code from dual union
select 'AC' state_code, 'XAPURI' city_code, '1200708' ibge_code from dual union
select 'AM' state_code, 'ALVARAES' city_code, '1300029' ibge_code from dual union
select 'AM' state_code, 'AMATURA' city_code, '1300060' ibge_code from dual union
select 'AM' state_code, 'ANAMA' city_code, '1300086' ibge_code from dual union
select 'AM' state_code, 'ANORI' city_code, '1300102' ibge_code from dual union
select 'AM' state_code, 'APUI' city_code, '1300144' ibge_code from dual union
select 'AM' state_code, 'ATALAIA DO NORTE' city_code, '1300201' ibge_code from dual union
select 'AM' state_code, 'AUTAZES' city_code, '1300300' ibge_code from dual union
select 'AM' state_code, 'BARCELOS' city_code, '1300409' ibge_code from dual union
select 'AM' state_code, 'BARREIRINHA' city_code, '1300508' ibge_code from dual union
select 'AM' state_code, 'BENJAMIN CONSTANT' city_code, '1300607' ibge_code from dual union
select 'AM' state_code, 'BERURI' city_code, '1300631' ibge_code from dual union
select 'AM' state_code, 'BOA VISTA DO RAMOS' city_code, '1300680' ibge_code from dual union
select 'AM' state_code, 'BOCA DO ACRE' city_code, '1300706' ibge_code from dual union
select 'AM' state_code, 'BORBA' city_code, '1300805' ibge_code from dual union
select 'AM' state_code, 'CAAPIRANGA' city_code, '1300839' ibge_code from dual union
select 'AM' state_code, 'CANUTAMA' city_code, '1300904' ibge_code from dual union
select 'AM' state_code, 'CARAUARI' city_code, '1301001' ibge_code from dual union
select 'AM' state_code, 'CAREIRO' city_code, '1301100' ibge_code from dual union
select 'AM' state_code, 'CAREIRO DA VARZEA' city_code, '1301159' ibge_code from dual union
select 'AM' state_code, 'COARI' city_code, '1301209' ibge_code from dual union
select 'AM' state_code, 'CODAJAS' city_code, '1301308' ibge_code from dual union
select 'AM' state_code, 'EIRUNEPE' city_code, '1301407' ibge_code from dual union
select 'AM' state_code, 'ENVIRA' city_code, '1301506' ibge_code from dual union
select 'AM' state_code, 'FONTE BOA' city_code, '1301605' ibge_code from dual union
select 'AM' state_code, 'GUAJARA' city_code, '1301654' ibge_code from dual union
select 'AM' state_code, 'HUMAITA' city_code, '1301704' ibge_code from dual union
select 'AM' state_code, 'IPIXUNA' city_code, '1301803' ibge_code from dual union
select 'AM' state_code, 'IRANDUBA' city_code, '1301852' ibge_code from dual union
select 'AM' state_code, 'ITACOATIARA' city_code, '1301902' ibge_code from dual union
select 'AM' state_code, 'ITAMARATI' city_code, '1301951' ibge_code from dual union
select 'AM' state_code, 'ITAPIRANGA' city_code, '1302009' ibge_code from dual union
select 'AM' state_code, 'JAPURA' city_code, '1302108' ibge_code from dual union
select 'AM' state_code, 'JURUA' city_code, '1302207' ibge_code from dual union
select 'AM' state_code, 'JUTAI' city_code, '1302306' ibge_code from dual union
select 'AM' state_code, 'LABREA' city_code, '1302405' ibge_code from dual union
select 'AM' state_code, 'MANACAPURU' city_code, '1302504' ibge_code from dual union
select 'AM' state_code, 'MANAQUIRI' city_code, '1302553' ibge_code from dual union
select 'AM' state_code, 'MANAUS' city_code, '1302603' ibge_code from dual union
select 'AM' state_code, 'MANICORE' city_code, '1302702' ibge_code from dual union
select 'AM' state_code, 'MARAA' city_code, '1302801' ibge_code from dual union
select 'AM' state_code, 'MAUES' city_code, '1302900' ibge_code from dual union
select 'AM' state_code, 'NHAMUNDA' city_code, '1303007' ibge_code from dual union
select 'AM' state_code, 'NOVA OLINDA DO NORTE' city_code, '1303106' ibge_code from dual union
select 'AM' state_code, 'NOVO AIRAO' city_code, '1303205' ibge_code from dual union
select 'AM' state_code, 'NOVO ARIPUANA' city_code, '1303304' ibge_code from dual union
select 'AM' state_code, 'PARINTINS' city_code, '1303403' ibge_code from dual union
select 'AM' state_code, 'PAUINI' city_code, '1303502' ibge_code from dual union
select 'AM' state_code, 'PRESIDENTE FIGUEIREDO' city_code, '1303536' ibge_code from dual union
select 'AM' state_code, 'RIO PRETO DA EVA' city_code, '1303569' ibge_code from dual union
select 'AM' state_code, 'SANTA ISABEL DO RIO NEGRO' city_code, '1303601' ibge_code from dual union
select 'AM' state_code, 'SANTO ANTONIO DO ICA' city_code, '1303700' ibge_code from dual union
select 'AM' state_code, 'SAO GABRIEL DA CACHOEIRA' city_code, '1303809' ibge_code from dual union
select 'AM' state_code, 'SAO PAULO DE OLIVENCA' city_code, '1303908' ibge_code from dual union
select 'AM' state_code, 'SAO SEBASTIAO DO UATUMA' city_code, '1303957' ibge_code from dual union
select 'AM' state_code, 'SILVES' city_code, '1304005' ibge_code from dual union
select 'AM' state_code, 'TABATINGA' city_code, '1304062' ibge_code from dual union
select 'AM' state_code, 'TAPAUA' city_code, '1304104' ibge_code from dual union
select 'AM' state_code, 'TEFE' city_code, '1304203' ibge_code from dual union
select 'AM' state_code, 'TONANTINS' city_code, '1304237' ibge_code from dual union
select 'AM' state_code, 'UARINI' city_code, '1304260' ibge_code from dual union
select 'AM' state_code, 'URUCARA' city_code, '1304302' ibge_code from dual union
select 'AM' state_code, 'URUCURITUBA' city_code, '1304401' ibge_code from dual union
select 'RR' state_code, 'ALTO ALEGRE' city_code, '1400050' ibge_code from dual union
select 'RR' state_code, 'AMAJARI' city_code, '1400027' ibge_code from dual union
select 'RR' state_code, 'BOA VISTA' city_code, '1400100' ibge_code from dual union
select 'RR' state_code, 'BONFIM' city_code, '1400159' ibge_code from dual union
select 'RR' state_code, 'CANTA' city_code, '1400175' ibge_code from dual union
select 'RR' state_code, 'CARACARAI' city_code, '1400209' ibge_code from dual union
select 'RR' state_code, 'CAROEBE' city_code, '1400233' ibge_code from dual union
select 'RR' state_code, 'IRACEMA' city_code, '1400282' ibge_code from dual union
select 'RR' state_code, 'MUCAJAI' city_code, '1400308' ibge_code from dual union
select 'RR' state_code, 'NORMANDIA' city_code, '1400407' ibge_code from dual union
select 'RR' state_code, 'PACARAIMA' city_code, '1400456' ibge_code from dual union
select 'RR' state_code, 'RORAINOPOLIS' city_code, '1400472' ibge_code from dual union
select 'RR' state_code, 'SAO JOAO DA BALIZA' city_code, '1400506' ibge_code from dual union
select 'RR' state_code, 'SAO LUIZ' city_code, '1400605' ibge_code from dual union
select 'RR' state_code, 'UIRAMUTA' city_code, '1400704' ibge_code from dual union
select 'PA' state_code, 'ABAETETUBA' city_code, '1500107' ibge_code from dual union
select 'PA' state_code, 'ABEL FIGUEIREDO' city_code, '1500131' ibge_code from dual union
select 'PA' state_code, 'ACARA' city_code, '1500206' ibge_code from dual union
select 'PA' state_code, 'AFUA' city_code, '1500305' ibge_code from dual union
select 'PA' state_code, 'AGUA AZUL DO NORTE' city_code, '1500347' ibge_code from dual union
select 'PA' state_code, 'ALENQUER' city_code, '1500404' ibge_code from dual union
select 'PA' state_code, 'ALMEIRIM' city_code, '1500503' ibge_code from dual union
select 'PA' state_code, 'ALTAMIRA' city_code, '1500602' ibge_code from dual union
select 'PA' state_code, 'ANAJAS' city_code, '1500701' ibge_code from dual union
select 'PA' state_code, 'ANANINDEUA' city_code, '1500800' ibge_code from dual union
select 'PA' state_code, 'ANAPU' city_code, '1500859' ibge_code from dual union
select 'PA' state_code, 'AUGUSTO CORREA' city_code, '1500909' ibge_code from dual union
select 'PA' state_code, 'AURORA DO PARA' city_code, '1500958' ibge_code from dual union
select 'PA' state_code, 'AVEIRO' city_code, '1501006' ibge_code from dual union
select 'PA' state_code, 'BAGRE' city_code, '1501105' ibge_code from dual union
select 'PA' state_code, 'BAIAO' city_code, '1501204' ibge_code from dual union
select 'PA' state_code, 'BANNACH' city_code, '1501253' ibge_code from dual union
select 'PA' state_code, 'BARCARENA' city_code, '1501303' ibge_code from dual union
select 'PA' state_code, 'BELEM' city_code, '1501402' ibge_code from dual union
select 'PA' state_code, 'BELTERRA' city_code, '1501451' ibge_code from dual union
select 'PA' state_code, 'BENEVIDES' city_code, '1501501' ibge_code from dual union
select 'PA' state_code, 'BOM JESUS DO TOCANTINS' city_code, '1501576' ibge_code from dual union
select 'PA' state_code, 'BONITO' city_code, '1501600' ibge_code from dual union
select 'PA' state_code, 'BRAGANCA' city_code, '1501709' ibge_code from dual union
select 'PA' state_code, 'BRASIL NOVO' city_code, '1501725' ibge_code from dual union
select 'PA' state_code, 'BREJO GRANDE DO ARAGUAIA' city_code, '1501758' ibge_code from dual union
select 'PA' state_code, 'BREU BRANCO' city_code, '1501782' ibge_code from dual union
select 'PA' state_code, 'BREVES' city_code, '1501808' ibge_code from dual union
select 'PA' state_code, 'BUJARU' city_code, '1501907' ibge_code from dual union
select 'PA' state_code, 'CACHOEIRA DO ARARI' city_code, '1502004' ibge_code from dual union
select 'PA' state_code, 'CACHOEIRA DO PIRIA' city_code, '1501956' ibge_code from dual union
select 'PA' state_code, 'CAMETA' city_code, '1502103' ibge_code from dual union
select 'PA' state_code, 'CANAA DOS CARAJAS' city_code, '1502152' ibge_code from dual union
select 'PA' state_code, 'CAPANEMA' city_code, '1502202' ibge_code from dual union
select 'PA' state_code, 'CAPITAO POCO' city_code, '1502301' ibge_code from dual union
select 'PA' state_code, 'CASTANHAL' city_code, '1502400' ibge_code from dual union
select 'PA' state_code, 'CHAVES' city_code, '1502509' ibge_code from dual union
select 'PA' state_code, 'COLARES' city_code, '1502608' ibge_code from dual union
select 'PA' state_code, 'CONCEICAO DO ARAGUAIA' city_code, '1502707' ibge_code from dual union
select 'PA' state_code, 'CONCORDIA DO PARA' city_code, '1502756' ibge_code from dual union
select 'PA' state_code, 'CUMARU DO NORTE' city_code, '1502764' ibge_code from dual union
select 'PA' state_code, 'CURIONOPOLIS' city_code, '1502772' ibge_code from dual union
select 'PA' state_code, 'CURRALINHO' city_code, '1502806' ibge_code from dual union
select 'PA' state_code, 'CURUA' city_code, '1502855' ibge_code from dual union
select 'PA' state_code, 'CURUCA' city_code, '1502905' ibge_code from dual union
select 'PA' state_code, 'DOM ELISEU' city_code, '1502939' ibge_code from dual union
select 'PA' state_code, 'ELDORADO DO CARAJAS' city_code, '1502954' ibge_code from dual union
select 'PA' state_code, 'FARO' city_code, '1503002' ibge_code from dual union
select 'PA' state_code, 'FLORESTA DO ARAGUAIA' city_code, '1503044' ibge_code from dual union
select 'PA' state_code, 'GARRAFAO DO NORTE' city_code, '1503077' ibge_code from dual union
select 'PA' state_code, 'GOIANESIA DO PARA' city_code, '1503093' ibge_code from dual union
select 'PA' state_code, 'GURUPA' city_code, '1503101' ibge_code from dual union
select 'PA' state_code, 'IGARAPE-ACU' city_code, '1503200' ibge_code from dual union
select 'PA' state_code, 'IGARAPE-MIRI' city_code, '1503309' ibge_code from dual union
select 'PA' state_code, 'INHANGAPI' city_code, '1503408' ibge_code from dual union
select 'PA' state_code, 'IPIXUNA DO PARA' city_code, '1503457' ibge_code from dual union
select 'PA' state_code, 'IRITUIA' city_code, '1503507' ibge_code from dual union
select 'PA' state_code, 'ITAITUBA' city_code, '1503606' ibge_code from dual union
select 'PA' state_code, 'ITUPIRANGA' city_code, '1503705' ibge_code from dual union
select 'PA' state_code, 'JACAREACANGA' city_code, '1503754' ibge_code from dual union
select 'PA' state_code, 'JACUNDA' city_code, '1503804' ibge_code from dual union
select 'PA' state_code, 'JURUTI' city_code, '1503903' ibge_code from dual union
select 'PA' state_code, 'LIMOEIRO DO AJURU' city_code, '1504000' ibge_code from dual union
select 'PA' state_code, 'MAE DO RIO' city_code, '1504059' ibge_code from dual union
select 'PA' state_code, 'MAGALHAES BARATA' city_code, '1504109' ibge_code from dual union
select 'PA' state_code, 'MARABA' city_code, '1504208' ibge_code from dual union
select 'PA' state_code, 'MARACANA' city_code, '1504307' ibge_code from dual union
select 'PA' state_code, 'MARAPANIM' city_code, '1504406' ibge_code from dual union
select 'PA' state_code, 'MARITUBA' city_code, '1504422' ibge_code from dual union
select 'PA' state_code, 'MEDICILANDIA' city_code, '1504455' ibge_code from dual union
select 'PA' state_code, 'MELGACO' city_code, '1504505' ibge_code from dual union
select 'PA' state_code, 'MOCAJUBA' city_code, '1504604' ibge_code from dual union
select 'PA' state_code, 'MOJU' city_code, '1504703' ibge_code from dual union
select 'PA' state_code, 'MOJUI DOS CAMPOS' city_code, '1504752' ibge_code from dual union
select 'PA' state_code, 'MONTE ALEGRE' city_code, '1504802' ibge_code from dual union
select 'PA' state_code, 'MUANA' city_code, '1504901' ibge_code from dual union
select 'PA' state_code, 'NOVA ESPERANCA DO PIRIA' city_code, '1504950' ibge_code from dual union
select 'PA' state_code, 'NOVA IPIXUNA' city_code, '1504976' ibge_code from dual union
select 'PA' state_code, 'NOVA TIMBOTEUA' city_code, '1505007' ibge_code from dual union
select 'PA' state_code, 'NOVO PROGRESSO' city_code, '1505031' ibge_code from dual union
select 'PA' state_code, 'NOVO REPARTIMENTO' city_code, '1505064' ibge_code from dual union
select 'PA' state_code, 'OBIDOS' city_code, '1505106' ibge_code from dual union
select 'PA' state_code, 'OEIRAS DO PARA' city_code, '1505205' ibge_code from dual union
select 'PA' state_code, 'ORIXIMINA' city_code, '1505304' ibge_code from dual union
select 'PA' state_code, 'OUREM' city_code, '1505403' ibge_code from dual union
select 'PA' state_code, 'OURILANDIA DO NORTE' city_code, '1505437' ibge_code from dual union
select 'PA' state_code, 'PACAJA' city_code, '1505486' ibge_code from dual union
select 'PA' state_code, 'PALESTINA DO PARA' city_code, '1505494' ibge_code from dual union
select 'PA' state_code, 'PARAGOMINAS' city_code, '1505502' ibge_code from dual union
select 'PA' state_code, 'PARAUAPEBAS' city_code, '1505536' ibge_code from dual union
select 'PA' state_code, 'PAU D''ARCO' city_code, '1505551' ibge_code from dual union
select 'PA' state_code, 'PEIXE-BOI' city_code, '1505601' ibge_code from dual union
select 'PA' state_code, 'PICARRA' city_code, '1505635' ibge_code from dual union
select 'PA' state_code, 'PLACAS' city_code, '1505650' ibge_code from dual union
select 'PA' state_code, 'PONTA DE PEDRAS' city_code, '1505700' ibge_code from dual union
select 'PA' state_code, 'PORTEL' city_code, '1505809' ibge_code from dual union
select 'PA' state_code, 'PORTO DE MOZ' city_code, '1505908' ibge_code from dual union
select 'PA' state_code, 'PRAINHA' city_code, '1506005' ibge_code from dual union
select 'PA' state_code, 'PRIMAVERA' city_code, '1506104' ibge_code from dual union
select 'PA' state_code, 'QUATIPURU' city_code, '1506112' ibge_code from dual union
select 'PA' state_code, 'REDENCAO' city_code, '1506138' ibge_code from dual union
select 'PA' state_code, 'RIO MARIA' city_code, '1506161' ibge_code from dual union
select 'PA' state_code, 'RONDON DO PARA' city_code, '1506187' ibge_code from dual union
select 'PA' state_code, 'RUROPOLIS' city_code, '1506195' ibge_code from dual union
select 'PA' state_code, 'SALINOPOLIS' city_code, '1506203' ibge_code from dual union
select 'PA' state_code, 'SALVATERRA' city_code, '1506302' ibge_code from dual union
select 'PA' state_code, 'SANTA BARBARA DO PARA' city_code, '1506351' ibge_code from dual union
select 'PA' state_code, 'SANTA CRUZ DO ARARI' city_code, '1506401' ibge_code from dual union
select 'PA' state_code, 'SANTA IZABEL DO PARA' city_code, '1506500' ibge_code from dual union
select 'PA' state_code, 'SANTA LUZIA DO PARA' city_code, '1506559' ibge_code from dual union
select 'PA' state_code, 'SANTA MARIA DAS BARREIRAS' city_code, '1506583' ibge_code from dual union
select 'PA' state_code, 'SANTA MARIA DO PARA' city_code, '1506609' ibge_code from dual union
select 'PA' state_code, 'SANTANA DO ARAGUAIA' city_code, '1506708' ibge_code from dual union
select 'PA' state_code, 'SANTAREM' city_code, '1506807' ibge_code from dual union
select 'PA' state_code, 'SANTAREM NOVO' city_code, '1506906' ibge_code from dual union
select 'PA' state_code, 'SANTO ANTONIO DO TAUA' city_code, '1507003' ibge_code from dual union
select 'PA' state_code, 'SAO CAETANO DE ODIVELAS' city_code, '1507102' ibge_code from dual union
select 'PA' state_code, 'SAO DOMINGOS DO ARAGUAIA' city_code, '1507151' ibge_code from dual union
select 'PA' state_code, 'SAO DOMINGOS DO CAPIM' city_code, '1507201' ibge_code from dual union
select 'PA' state_code, 'SAO FELIX DO XINGU' city_code, '1507300' ibge_code from dual union
select 'PA' state_code, 'SAO FRANCISCO DO PARA' city_code, '1507409' ibge_code from dual union
select 'PA' state_code, 'SAO GERALDO DO ARAGUAIA' city_code, '1507458' ibge_code from dual union
select 'PA' state_code, 'SAO JOAO DA PONTA' city_code, '1507466' ibge_code from dual union
select 'PA' state_code, 'SAO JOAO DE PIRABAS' city_code, '1507474' ibge_code from dual union
select 'PA' state_code, 'SAO JOAO DO ARAGUAIA' city_code, '1507508' ibge_code from dual union
select 'PA' state_code, 'SAO MIGUEL DO GUAMA' city_code, '1507607' ibge_code from dual union
select 'PA' state_code, 'SAO SEBASTIAO DA BOA VISTA' city_code, '1507706' ibge_code from dual union
select 'PA' state_code, 'SAPUCAIA' city_code, '1507755' ibge_code from dual union
select 'PA' state_code, 'SENADOR JOSE PORFIRIO' city_code, '1507805' ibge_code from dual union
select 'PA' state_code, 'SOURE' city_code, '1507904' ibge_code from dual union
select 'PA' state_code, 'TAILANDIA' city_code, '1507953' ibge_code from dual union
select 'PA' state_code, 'TERRA ALTA' city_code, '1507961' ibge_code from dual union
select 'PA' state_code, 'TERRA SANTA' city_code, '1507979' ibge_code from dual union
select 'PA' state_code, 'TOME-ACU' city_code, '1508001' ibge_code from dual union
select 'PA' state_code, 'TRACUATEUA' city_code, '1508035' ibge_code from dual union
select 'PA' state_code, 'TRAIRAO' city_code, '1508050' ibge_code from dual union
select 'PA' state_code, 'TUCUMA' city_code, '1508084' ibge_code from dual union
select 'PA' state_code, 'TUCURUI' city_code, '1508100' ibge_code from dual union
select 'PA' state_code, 'ULIANOPOLIS' city_code, '1508126' ibge_code from dual union
select 'PA' state_code, 'URUARA' city_code, '1508159' ibge_code from dual union
select 'PA' state_code, 'VIGIA' city_code, '1508209' ibge_code from dual union
select 'PA' state_code, 'VISEU' city_code, '1508308' ibge_code from dual union
select 'PA' state_code, 'VITORIA DO XINGU' city_code, '1508357' ibge_code from dual union
select 'PA' state_code, 'XINGUARA' city_code, '1508407' ibge_code from dual union
select 'AP' state_code, 'AMAPA' city_code, '1600105' ibge_code from dual union
select 'AP' state_code, 'CALCOENE' city_code, '1600204' ibge_code from dual union
select 'AP' state_code, 'CUTIAS' city_code, '1600212' ibge_code from dual union
select 'AP' state_code, 'FERREIRA GOMES' city_code, '1600238' ibge_code from dual union
select 'AP' state_code, 'ITAUBAL' city_code, '1600253' ibge_code from dual union
select 'AP' state_code, 'LARANJAL DO JARI' city_code, '1600279' ibge_code from dual union
select 'AP' state_code, 'MACAPA' city_code, '1600303' ibge_code from dual union
select 'AP' state_code, 'MAZAGAO' city_code, '1600402' ibge_code from dual union
select 'AP' state_code, 'OIAPOQUE' city_code, '1600501' ibge_code from dual union
select 'AP' state_code, 'PEDRA BRANCA DO AMAPARI' city_code, '1600154' ibge_code from dual union
select 'AP' state_code, 'PORTO GRANDE' city_code, '1600535' ibge_code from dual union
select 'AP' state_code, 'PRACUUBA' city_code, '1600550' ibge_code from dual union
select 'AP' state_code, 'SANTANA' city_code, '1600600' ibge_code from dual union
select 'AP' state_code, 'SERRA DO NAVIO' city_code, '1600055' ibge_code from dual union
select 'AP' state_code, 'TARTARUGALZINHO' city_code, '1600709' ibge_code from dual union
select 'AP' state_code, 'VITORIA DO JARI' city_code, '1600808' ibge_code from dual union
select 'TO' state_code, 'ABREULANDIA' city_code, '1700251' ibge_code from dual union
select 'TO' state_code, 'AGUIARNOPOLIS' city_code, '1700301' ibge_code from dual union
select 'TO' state_code, 'ALIANCA DO TOCANTINS' city_code, '1700350' ibge_code from dual union
select 'TO' state_code, 'ALMAS' city_code, '1700400' ibge_code from dual union
select 'TO' state_code, 'ALVORADA' city_code, '1700707' ibge_code from dual union
select 'TO' state_code, 'ANANAS' city_code, '1701002' ibge_code from dual union
select 'TO' state_code, 'ANGICO' city_code, '1701051' ibge_code from dual union
select 'TO' state_code, 'APARECIDA DO RIO NEGRO' city_code, '1701101' ibge_code from dual union
select 'TO' state_code, 'ARAGOMINAS' city_code, '1701309' ibge_code from dual union
select 'TO' state_code, 'ARAGUACEMA' city_code, '1701903' ibge_code from dual union
select 'TO' state_code, 'ARAGUACU' city_code, '1702000' ibge_code from dual union
select 'TO' state_code, 'ARAGUAINA' city_code, '1702109' ibge_code from dual union
select 'TO' state_code, 'ARAGUANA' city_code, '1702158' ibge_code from dual union
select 'TO' state_code, 'ARAGUATINS' city_code, '1702208' ibge_code from dual union
select 'TO' state_code, 'ARAPOEMA' city_code, '1702307' ibge_code from dual union
select 'TO' state_code, 'ARRAIAS' city_code, '1702406' ibge_code from dual union
select 'TO' state_code, 'AUGUSTINOPOLIS' city_code, '1702554' ibge_code from dual union
select 'TO' state_code, 'AURORA DO TOCANTINS' city_code, '1702703' ibge_code from dual union
select 'TO' state_code, 'AXIXA DO TOCANTINS' city_code, '1702901' ibge_code from dual union
select 'TO' state_code, 'BABACULANDIA' city_code, '1703008' ibge_code from dual union
select 'TO' state_code, 'BANDEIRANTES DO TOCANTINS' city_code, '1703057' ibge_code from dual union
select 'TO' state_code, 'BARRA DO OURO' city_code, '1703073' ibge_code from dual union
select 'TO' state_code, 'BARROLANDIA' city_code, '1703107' ibge_code from dual union
select 'TO' state_code, 'BERNARDO SAYAO' city_code, '1703206' ibge_code from dual union
select 'TO' state_code, 'BOM JESUS DO TOCANTINS' city_code, '1703305' ibge_code from dual union
select 'TO' state_code, 'BRASILANDIA DO TOCANTINS' city_code, '1703602' ibge_code from dual union
select 'TO' state_code, 'BREJINHO DE NAZARE' city_code, '1703701' ibge_code from dual union
select 'TO' state_code, 'BURITI DO TOCANTINS' city_code, '1703800' ibge_code from dual union
select 'TO' state_code, 'CACHOEIRINHA' city_code, '1703826' ibge_code from dual union
select 'TO' state_code, 'CAMPOS LINDOS' city_code, '1703842' ibge_code from dual union
select 'TO' state_code, 'CARIRI DO TOCANTINS' city_code, '1703867' ibge_code from dual union
select 'TO' state_code, 'CARMOLANDIA' city_code, '1703883' ibge_code from dual union
select 'TO' state_code, 'CARRASCO BONITO' city_code, '1703891' ibge_code from dual union
select 'TO' state_code, 'CASEARA' city_code, '1703909' ibge_code from dual union
select 'TO' state_code, 'CENTENARIO' city_code, '1704105' ibge_code from dual union
select 'TO' state_code, 'CHAPADA DA NATIVIDADE' city_code, '1705102' ibge_code from dual union
select 'TO' state_code, 'CHAPADA DE AREIA' city_code, '1704600' ibge_code from dual union
select 'TO' state_code, 'COLINAS DO TOCANTINS' city_code, '1705508' ibge_code from dual union
select 'TO' state_code, 'COLMEIA' city_code, '1716703' ibge_code from dual union
select 'TO' state_code, 'COMBINADO' city_code, '1705557' ibge_code from dual union
select 'TO' state_code, 'CONCEICAO DO TOCANTINS' city_code, '1705607' ibge_code from dual union
select 'TO' state_code, 'COUTO MAGALHAES' city_code, '1706001' ibge_code from dual union
select 'TO' state_code, 'CRISTALANDIA' city_code, '1706100' ibge_code from dual union
select 'TO' state_code, 'CRIXAS DO TOCANTINS' city_code, '1706258' ibge_code from dual union
select 'TO' state_code, 'DARCINOPOLIS' city_code, '1706506' ibge_code from dual union
select 'TO' state_code, 'DIANOPOLIS' city_code, '1707009' ibge_code from dual union
select 'TO' state_code, 'DIVINOPOLIS DO TOCANTINS' city_code, '1707108' ibge_code from dual union
select 'TO' state_code, 'DOIS IRMAOS DO TOCANTINS' city_code, '1707207' ibge_code from dual union
select 'TO' state_code, 'DUERE' city_code, '1707306' ibge_code from dual union
select 'TO' state_code, 'ESPERANTINA' city_code, '1707405' ibge_code from dual union
select 'TO' state_code, 'FATIMA' city_code, '1707553' ibge_code from dual union
select 'TO' state_code, 'FIGUEIROPOLIS' city_code, '1707652' ibge_code from dual union
select 'TO' state_code, 'FILADELFIA' city_code, '1707702' ibge_code from dual union
select 'TO' state_code, 'FORMOSO DO ARAGUAIA' city_code, '1708205' ibge_code from dual union
select 'TO' state_code, 'FORTALEZA DO TABOCAO' city_code, '1708254' ibge_code from dual union
select 'TO' state_code, 'GOIANORTE' city_code, '1708304' ibge_code from dual union
select 'TO' state_code, 'GOIATINS' city_code, '1709005' ibge_code from dual union
select 'TO' state_code, 'GUARAI' city_code, '1709302' ibge_code from dual union
select 'TO' state_code, 'GURUPI' city_code, '1709500' ibge_code from dual union
select 'TO' state_code, 'IPUEIRAS' city_code, '1709807' ibge_code from dual union
select 'TO' state_code, 'ITACAJA' city_code, '1710508' ibge_code from dual union
select 'TO' state_code, 'ITAGUATINS' city_code, '1710706' ibge_code from dual union
select 'TO' state_code, 'ITAPIRATINS' city_code, '1710904' ibge_code from dual union
select 'TO' state_code, 'ITAPORA DO TOCANTINS' city_code, '1711100' ibge_code from dual union
select 'TO' state_code, 'JAU DO TOCANTINS' city_code, '1711506' ibge_code from dual union
select 'TO' state_code, 'JUARINA' city_code, '1711803' ibge_code from dual union
select 'TO' state_code, 'LAGOA DA CONFUSAO' city_code, '1711902' ibge_code from dual union
select 'TO' state_code, 'LAGOA DO TOCANTINS' city_code, '1711951' ibge_code from dual union
select 'TO' state_code, 'LAJEADO' city_code, '1712009' ibge_code from dual union
select 'TO' state_code, 'LAVANDEIRA' city_code, '1712157' ibge_code from dual union
select 'TO' state_code, 'LIZARDA' city_code, '1712405' ibge_code from dual union
select 'TO' state_code, 'LUZINOPOLIS' city_code, '1712454' ibge_code from dual union
select 'TO' state_code, 'MARIANOPOLIS DO TOCANTINS' city_code, '1712504' ibge_code from dual union
select 'TO' state_code, 'MATEIROS' city_code, '1712702' ibge_code from dual union
select 'TO' state_code, 'MAURILANDIA DO TOCANTINS' city_code, '1712801' ibge_code from dual union
select 'TO' state_code, 'MIRACEMA DO TOCANTINS' city_code, '1713205' ibge_code from dual union
select 'TO' state_code, 'MIRANORTE' city_code, '1713304' ibge_code from dual union
select 'TO' state_code, 'MONTE DO CARMO' city_code, '1713601' ibge_code from dual union
select 'TO' state_code, 'MONTE SANTO DO TOCANTINS' city_code, '1713700' ibge_code from dual union
select 'TO' state_code, 'MURICILANDIA' city_code, '1713957' ibge_code from dual union
select 'TO' state_code, 'NATIVIDADE' city_code, '1714203' ibge_code from dual union
select 'TO' state_code, 'NAZARE' city_code, '1714302' ibge_code from dual union
select 'TO' state_code, 'NOVA OLINDA' city_code, '1714880' ibge_code from dual union
select 'TO' state_code, 'NOVA ROSALANDIA' city_code, '1715002' ibge_code from dual union
select 'TO' state_code, 'NOVO ACORDO' city_code, '1715101' ibge_code from dual union
select 'TO' state_code, 'NOVO ALEGRE' city_code, '1715150' ibge_code from dual union
select 'TO' state_code, 'NOVO JARDIM' city_code, '1715259' ibge_code from dual union
select 'TO' state_code, 'OLIVEIRA DE FATIMA' city_code, '1715507' ibge_code from dual union
select 'TO' state_code, 'PALMAS' city_code, '1721000' ibge_code from dual union
select 'TO' state_code, 'PALMEIRANTE' city_code, '1715705' ibge_code from dual union
select 'TO' state_code, 'PALMEIRAS DO TOCANTINS' city_code, '1713809' ibge_code from dual union
select 'TO' state_code, 'PALMEIROPOLIS' city_code, '1715754' ibge_code from dual union
select 'TO' state_code, 'PARAISO DO TOCANTINS' city_code, '1716109' ibge_code from dual union
select 'TO' state_code, 'PARANA' city_code, '1716208' ibge_code from dual union
select 'TO' state_code, 'PAU D''ARCO' city_code, '1716307' ibge_code from dual union
select 'TO' state_code, 'PEDRO AFONSO' city_code, '1716505' ibge_code from dual union
select 'TO' state_code, 'PEIXE' city_code, '1716604' ibge_code from dual union
select 'TO' state_code, 'PEQUIZEIRO' city_code, '1716653' ibge_code from dual union
select 'TO' state_code, 'PINDORAMA DO TOCANTINS' city_code, '1717008' ibge_code from dual union
select 'TO' state_code, 'PIRAQUE' city_code, '1717206' ibge_code from dual union
select 'TO' state_code, 'PIUM' city_code, '1717503' ibge_code from dual union
select 'TO' state_code, 'PONTE ALTA DO BOM JESUS' city_code, '1717800' ibge_code from dual union
select 'TO' state_code, 'PONTE ALTA DO TOCANTINS' city_code, '1717909' ibge_code from dual union
select 'TO' state_code, 'PORTO ALEGRE DO TOCANTINS' city_code, '1718006' ibge_code from dual union
select 'TO' state_code, 'PORTO NACIONAL' city_code, '1718204' ibge_code from dual union
select 'TO' state_code, 'PRAIA NORTE' city_code, '1718303' ibge_code from dual union
select 'TO' state_code, 'PRESIDENTE KENNEDY' city_code, '1718402' ibge_code from dual union
select 'TO' state_code, 'PUGMIL' city_code, '1718451' ibge_code from dual union
select 'TO' state_code, 'RECURSOLANDIA' city_code, '1718501' ibge_code from dual union
select 'TO' state_code, 'RIACHINHO' city_code, '1718550' ibge_code from dual union
select 'TO' state_code, 'RIO DA CONCEICAO' city_code, '1718659' ibge_code from dual union
select 'TO' state_code, 'RIO DOS BOIS' city_code, '1718709' ibge_code from dual union
select 'TO' state_code, 'RIO SONO' city_code, '1718758' ibge_code from dual union
select 'TO' state_code, 'SAMPAIO' city_code, '1718808' ibge_code from dual union
select 'TO' state_code, 'SANDOLANDIA' city_code, '1718840' ibge_code from dual union
select 'TO' state_code, 'SANTA FE DO ARAGUAIA' city_code, '1718865' ibge_code from dual union
select 'TO' state_code, 'SANTA MARIA DO TOCANTINS' city_code, '1718881' ibge_code from dual union
select 'TO' state_code, 'SANTA RITA DO TOCANTINS' city_code, '1718899' ibge_code from dual union
select 'TO' state_code, 'SANTA ROSA DO TOCANTINS' city_code, '1718907' ibge_code from dual union
select 'TO' state_code, 'SANTA TEREZA DO TOCANTINS' city_code, '1719004' ibge_code from dual union
select 'TO' state_code, 'SANTA TEREZINHA DO TOCANTINS' city_code, '1720002' ibge_code from dual union
select 'TO' state_code, 'SAO BENTO DO TOCANTINS' city_code, '1720101' ibge_code from dual union
select 'TO' state_code, 'SAO FELIX DO TOCANTINS' city_code, '1720150' ibge_code from dual union
select 'TO' state_code, 'SAO MIGUEL DO TOCANTINS' city_code, '1720200' ibge_code from dual union
select 'TO' state_code, 'SAO SALVADOR DO TOCANTINS' city_code, '1720259' ibge_code from dual union
select 'TO' state_code, 'SAO SEBASTIAO DO TOCANTINS' city_code, '1720309' ibge_code from dual union
select 'TO' state_code, 'SAO VALERIO' city_code, '1720499' ibge_code from dual union
select 'TO' state_code, 'SILVANOPOLIS' city_code, '1720655' ibge_code from dual union
select 'TO' state_code, 'SITIO NOVO DO TOCANTINS' city_code, '1720804' ibge_code from dual union
select 'TO' state_code, 'SUCUPIRA' city_code, '1720853' ibge_code from dual union
select 'TO' state_code, 'TAGUATINGA' city_code, '1720903' ibge_code from dual union
select 'TO' state_code, 'TAIPAS DO TOCANTINS' city_code, '1720937' ibge_code from dual union
select 'TO' state_code, 'TALISMA' city_code, '1720978' ibge_code from dual union
select 'TO' state_code, 'TOCANTINIA' city_code, '1721109' ibge_code from dual union
select 'TO' state_code, 'TOCANTINOPOLIS' city_code, '1721208' ibge_code from dual union
select 'TO' state_code, 'TUPIRAMA' city_code, '1721257' ibge_code from dual union
select 'TO' state_code, 'TUPIRATINS' city_code, '1721307' ibge_code from dual union
select 'TO' state_code, 'WANDERLANDIA' city_code, '1722081' ibge_code from dual union
select 'TO' state_code, 'XAMBIOA' city_code, '1722107' ibge_code from dual union
select 'MA' state_code, 'ACAILANDIA' city_code, '2100055' ibge_code from dual union
select 'MA' state_code, 'AFONSO CUNHA' city_code, '2100105' ibge_code from dual union
select 'MA' state_code, 'AGUA DOCE DO MARANHAO' city_code, '2100154' ibge_code from dual union
select 'MA' state_code, 'ALCANTARA' city_code, '2100204' ibge_code from dual union
select 'MA' state_code, 'ALDEIAS ALTAS' city_code, '2100303' ibge_code from dual union
select 'MA' state_code, 'ALTAMIRA DO MARANHAO' city_code, '2100402' ibge_code from dual union
select 'MA' state_code, 'ALTO ALEGRE DO MARANHAO' city_code, '2100436' ibge_code from dual union
select 'MA' state_code, 'ALTO ALEGRE DO PINDARE' city_code, '2100477' ibge_code from dual union
select 'MA' state_code, 'ALTO PARNAIBA' city_code, '2100501' ibge_code from dual union
select 'MA' state_code, 'AMAPA DO MARANHAO' city_code, '2100550' ibge_code from dual union
select 'MA' state_code, 'AMARANTE DO MARANHAO' city_code, '2100600' ibge_code from dual union
select 'MA' state_code, 'ANAJATUBA' city_code, '2100709' ibge_code from dual union
select 'MA' state_code, 'ANAPURUS' city_code, '2100808' ibge_code from dual union
select 'MA' state_code, 'APICUM-ACU' city_code, '2100832' ibge_code from dual union
select 'MA' state_code, 'ARAGUANA' city_code, '2100873' ibge_code from dual union
select 'MA' state_code, 'ARAIOSES' city_code, '2100907' ibge_code from dual union
select 'MA' state_code, 'ARAME' city_code, '2100956' ibge_code from dual union
select 'MA' state_code, 'ARARI' city_code, '2101004' ibge_code from dual union
select 'MA' state_code, 'AXIXA' city_code, '2101103' ibge_code from dual union
select 'MA' state_code, 'BACABAL' city_code, '2101202' ibge_code from dual union
select 'MA' state_code, 'BACABEIRA' city_code, '2101251' ibge_code from dual union
select 'MA' state_code, 'BACURI' city_code, '2101301' ibge_code from dual union
select 'MA' state_code, 'BACURITUBA' city_code, '2101350' ibge_code from dual union
select 'MA' state_code, 'BALSAS' city_code, '2101400' ibge_code from dual union
select 'MA' state_code, 'BARAO DE GRAJAU' city_code, '2101509' ibge_code from dual union
select 'MA' state_code, 'BARRA DO CORDA' city_code, '2101608' ibge_code from dual union
select 'MA' state_code, 'BARREIRINHAS' city_code, '2101707' ibge_code from dual union
select 'MA' state_code, 'BELA VISTA DO MARANHAO' city_code, '2101772' ibge_code from dual union
select 'MA' state_code, 'BELAGUA' city_code, '2101731' ibge_code from dual union
select 'MA' state_code, 'BENEDITO LEITE' city_code, '2101806' ibge_code from dual union
select 'MA' state_code, 'BEQUIMAO' city_code, '2101905' ibge_code from dual union
select 'MA' state_code, 'BERNARDO DO MEARIM' city_code, '2101939' ibge_code from dual union
select 'MA' state_code, 'BOA VISTA DO GURUPI' city_code, '2101970' ibge_code from dual union
select 'MA' state_code, 'BOM JARDIM' city_code, '2102002' ibge_code from dual union
select 'MA' state_code, 'BOM JESUS DAS SELVAS' city_code, '2102036' ibge_code from dual union
select 'MA' state_code, 'BOM LUGAR' city_code, '2102077' ibge_code from dual union
select 'MA' state_code, 'BREJO' city_code, '2102101' ibge_code from dual union
select 'MA' state_code, 'BREJO DE AREIA' city_code, '2102150' ibge_code from dual union
select 'MA' state_code, 'BURITI' city_code, '2102200' ibge_code from dual union
select 'MA' state_code, 'BURITI BRAVO' city_code, '2102309' ibge_code from dual union
select 'MA' state_code, 'BURITICUPU' city_code, '2102325' ibge_code from dual union
select 'MA' state_code, 'BURITIRANA' city_code, '2102358' ibge_code from dual union
select 'MA' state_code, 'CACHOEIRA GRANDE' city_code, '2102374' ibge_code from dual union
select 'MA' state_code, 'CAJAPIO' city_code, '2102408' ibge_code from dual union
select 'MA' state_code, 'CAJARI' city_code, '2102507' ibge_code from dual union
select 'MA' state_code, 'CAMPESTRE DO MARANHAO' city_code, '2102556' ibge_code from dual union
select 'MA' state_code, 'CANDIDO MENDES' city_code, '2102606' ibge_code from dual union
select 'MA' state_code, 'CANTANHEDE' city_code, '2102705' ibge_code from dual union
select 'MA' state_code, 'CAPINZAL DO NORTE' city_code, '2102754' ibge_code from dual union
select 'MA' state_code, 'CAROLINA' city_code, '2102804' ibge_code from dual union
select 'MA' state_code, 'CARUTAPERA' city_code, '2102903' ibge_code from dual union
select 'MA' state_code, 'CAXIAS' city_code, '2103000' ibge_code from dual union
select 'MA' state_code, 'CEDRAL' city_code, '2103109' ibge_code from dual union
select 'MA' state_code, 'CENTRAL DO MARANHAO' city_code, '2103125' ibge_code from dual union
select 'MA' state_code, 'CENTRO DO GUILHERME' city_code, '2103158' ibge_code from dual union
select 'MA' state_code, 'CENTRO NOVO DO MARANHAO' city_code, '2103174' ibge_code from dual union
select 'MA' state_code, 'CHAPADINHA' city_code, '2103208' ibge_code from dual union
select 'MA' state_code, 'CIDELANDIA' city_code, '2103257' ibge_code from dual union
select 'MA' state_code, 'CODO' city_code, '2103307' ibge_code from dual union
select 'MA' state_code, 'COELHO NETO' city_code, '2103406' ibge_code from dual union
select 'MA' state_code, 'COLINAS' city_code, '2103505' ibge_code from dual union
select 'MA' state_code, 'CONCEICAO DO LAGO-ACU' city_code, '2103554' ibge_code from dual union
select 'MA' state_code, 'COROATA' city_code, '2103604' ibge_code from dual union
select 'MA' state_code, 'CURURUPU' city_code, '2103703' ibge_code from dual union
select 'MA' state_code, 'DAVINOPOLIS' city_code, '2103752' ibge_code from dual union
select 'MA' state_code, 'DOM PEDRO' city_code, '2103802' ibge_code from dual union
select 'MA' state_code, 'DUQUE BACELAR' city_code, '2103901' ibge_code from dual union
select 'MA' state_code, 'ESPERANTINOPOLIS' city_code, '2104008' ibge_code from dual union
select 'MA' state_code, 'ESTREITO' city_code, '2104057' ibge_code from dual union
select 'MA' state_code, 'FEIRA NOVA DO MARANHAO' city_code, '2104073' ibge_code from dual union
select 'MA' state_code, 'FERNANDO FALCAO' city_code, '2104081' ibge_code from dual union
select 'MA' state_code, 'FORMOSA DA SERRA NEGRA' city_code, '2104099' ibge_code from dual union
select 'MA' state_code, 'FORTALEZA DOS NOGUEIRAS' city_code, '2104107' ibge_code from dual union
select 'MA' state_code, 'FORTUNA' city_code, '2104206' ibge_code from dual union
select 'MA' state_code, 'GODOFREDO VIANA' city_code, '2104305' ibge_code from dual union
select 'MA' state_code, 'GONCALVES DIAS' city_code, '2104404' ibge_code from dual union
select 'MA' state_code, 'GOVERNADOR ARCHER' city_code, '2104503' ibge_code from dual union
select 'MA' state_code, 'GOVERNADOR EDISON LOBAO' city_code, '2104552' ibge_code from dual union
select 'MA' state_code, 'GOVERNADOR EUGENIO BARROS' city_code, '2104602' ibge_code from dual union
select 'MA' state_code, 'GOVERNADOR LUIZ ROCHA' city_code, '2104628' ibge_code from dual union
select 'MA' state_code, 'GOVERNADOR NEWTON BELLO' city_code, '2104651' ibge_code from dual union
select 'MA' state_code, 'GOVERNADOR NUNES FREIRE' city_code, '2104677' ibge_code from dual union
select 'MA' state_code, 'GRACA ARANHA' city_code, '2104701' ibge_code from dual union
select 'MA' state_code, 'GRAJAU' city_code, '2104800' ibge_code from dual union
select 'MA' state_code, 'GUIMARAES' city_code, '2104909' ibge_code from dual union
select 'MA' state_code, 'HUMBERTO DE CAMPOS' city_code, '2105005' ibge_code from dual union
select 'MA' state_code, 'ICATU' city_code, '2105104' ibge_code from dual union
select 'MA' state_code, 'IGARAPE DO MEIO' city_code, '2105153' ibge_code from dual union
select 'MA' state_code, 'IGARAPE GRANDE' city_code, '2105203' ibge_code from dual union
select 'MA' state_code, 'IMPERATRIZ' city_code, '2105302' ibge_code from dual union
select 'MA' state_code, 'ITAIPAVA DO GRAJAU' city_code, '2105351' ibge_code from dual union
select 'MA' state_code, 'ITAPECURU MIRIM' city_code, '2105401' ibge_code from dual union
select 'MA' state_code, 'ITINGA DO MARANHAO' city_code, '2105427' ibge_code from dual union
select 'MA' state_code, 'JATOBA' city_code, '2105450' ibge_code from dual union
select 'MA' state_code, 'JENIPAPO DOS VIEIRAS' city_code, '2105476' ibge_code from dual union
select 'MA' state_code, 'JOAO LISBOA' city_code, '2105500' ibge_code from dual union
select 'MA' state_code, 'JOSELANDIA' city_code, '2105609' ibge_code from dual union
select 'MA' state_code, 'JUNCO DO MARANHAO' city_code, '2105658' ibge_code from dual union
select 'MA' state_code, 'LAGO DA PEDRA' city_code, '2105708' ibge_code from dual union
select 'MA' state_code, 'LAGO DO JUNCO' city_code, '2105807' ibge_code from dual union
select 'MA' state_code, 'LAGO DOS RODRIGUES' city_code, '2105948' ibge_code from dual union
select 'MA' state_code, 'LAGO VERDE' city_code, '2105906' ibge_code from dual union
select 'MA' state_code, 'LAGOA DO MATO' city_code, '2105922' ibge_code from dual union
select 'MA' state_code, 'LAGOA GRANDE DO MARANHAO' city_code, '2105963' ibge_code from dual union
select 'MA' state_code, 'LAJEADO NOVO' city_code, '2105989' ibge_code from dual union
select 'MA' state_code, 'LIMA CAMPOS' city_code, '2106003' ibge_code from dual union
select 'MA' state_code, 'LORETO' city_code, '2106102' ibge_code from dual union
select 'MA' state_code, 'LUIS DOMINGUES' city_code, '2106201' ibge_code from dual union
select 'MA' state_code, 'MAGALHAES DE ALMEIDA' city_code, '2106300' ibge_code from dual union
select 'MA' state_code, 'MARACACUME' city_code, '2106326' ibge_code from dual union
select 'MA' state_code, 'MARAJA DO SENA' city_code, '2106359' ibge_code from dual union
select 'MA' state_code, 'MARANHAOZINHO' city_code, '2106375' ibge_code from dual union
select 'MA' state_code, 'MATA ROMA' city_code, '2106409' ibge_code from dual union
select 'MA' state_code, 'MATINHA' city_code, '2106508' ibge_code from dual union
select 'MA' state_code, 'MATÕES' city_code, '2106607' ibge_code from dual union
select 'MA' state_code, 'MATÕES DO NORTE' city_code, '2106631' ibge_code from dual union
select 'MA' state_code, 'MILAGRES DO MARANHAO' city_code, '2106672' ibge_code from dual union
select 'MA' state_code, 'MIRADOR' city_code, '2106706' ibge_code from dual union
select 'MA' state_code, 'MIRANDA DO NORTE' city_code, '2106755' ibge_code from dual union
select 'MA' state_code, 'MIRINZAL' city_code, '2106805' ibge_code from dual union
select 'MA' state_code, 'MONCAO' city_code, '2106904' ibge_code from dual union
select 'MA' state_code, 'MONTES ALTOS' city_code, '2107001' ibge_code from dual union
select 'MA' state_code, 'MORROS' city_code, '2107100' ibge_code from dual union
select 'MA' state_code, 'NINA RODRIGUES' city_code, '2107209' ibge_code from dual union
select 'MA' state_code, 'NOVA COLINAS' city_code, '2107258' ibge_code from dual union
select 'MA' state_code, 'NOVA IORQUE' city_code, '2107308' ibge_code from dual union
select 'MA' state_code, 'NOVA OLINDA DO MARANHAO' city_code, '2107357' ibge_code from dual union
select 'MA' state_code, 'OLHO D''AGUA DAS CUNHAS' city_code, '2107407' ibge_code from dual union
select 'MA' state_code, 'OLINDA NOVA DO MARANHAO' city_code, '2107456' ibge_code from dual union
select 'MA' state_code, 'PACO DO LUMIAR' city_code, '2107506' ibge_code from dual union
select 'MA' state_code, 'PALMEIRANDIA' city_code, '2107605' ibge_code from dual union
select 'MA' state_code, 'PARAIBANO' city_code, '2107704' ibge_code from dual union
select 'MA' state_code, 'PARNARAMA' city_code, '2107803' ibge_code from dual union
select 'MA' state_code, 'PASSAGEM FRANCA' city_code, '2107902' ibge_code from dual union
select 'MA' state_code, 'PASTOS BONS' city_code, '2108009' ibge_code from dual union
select 'MA' state_code, 'PAULINO NEVES' city_code, '2108058' ibge_code from dual union
select 'MA' state_code, 'PAULO RAMOS' city_code, '2108108' ibge_code from dual union
select 'MA' state_code, 'PEDREIRAS' city_code, '2108207' ibge_code from dual union
select 'MA' state_code, 'PEDRO DO ROSARIO' city_code, '2108256' ibge_code from dual union
select 'MA' state_code, 'PENALVA' city_code, '2108306' ibge_code from dual union
select 'MA' state_code, 'PERI MIRIM' city_code, '2108405' ibge_code from dual union
select 'MA' state_code, 'PERITORO' city_code, '2108454' ibge_code from dual union
select 'MA' state_code, 'PINDARE-MIRIM' city_code, '2108504' ibge_code from dual union
select 'MA' state_code, 'PINHEIRO' city_code, '2108603' ibge_code from dual union
select 'MA' state_code, 'PIO XII' city_code, '2108702' ibge_code from dual union
select 'MA' state_code, 'PIRAPEMAS' city_code, '2108801' ibge_code from dual union
select 'MA' state_code, 'POCAO DE PEDRAS' city_code, '2108900' ibge_code from dual union
select 'MA' state_code, 'PORTO FRANCO' city_code, '2109007' ibge_code from dual union
select 'MA' state_code, 'PORTO RICO DO MARANHAO' city_code, '2109056' ibge_code from dual union
select 'MA' state_code, 'PRESIDENTE DUTRA' city_code, '2109106' ibge_code from dual union
select 'MA' state_code, 'PRESIDENTE JUSCELINO' city_code, '2109205' ibge_code from dual union
select 'MA' state_code, 'PRESIDENTE MEDICI' city_code, '2109239' ibge_code from dual union
select 'MA' state_code, 'PRESIDENTE SARNEY' city_code, '2109270' ibge_code from dual union
select 'MA' state_code, 'PRESIDENTE VARGAS' city_code, '2109304' ibge_code from dual union
select 'MA' state_code, 'PRIMEIRA CRUZ' city_code, '2109403' ibge_code from dual union
select 'MA' state_code, 'RAPOSA' city_code, '2109452' ibge_code from dual union
select 'MA' state_code, 'RIACHAO' city_code, '2109502' ibge_code from dual union
select 'MA' state_code, 'RIBAMAR FIQUENE' city_code, '2109551' ibge_code from dual union
select 'MA' state_code, 'ROSARIO' city_code, '2109601' ibge_code from dual union
select 'MA' state_code, 'SAMBAIBA' city_code, '2109700' ibge_code from dual union
select 'MA' state_code, 'SANTA FILOMENA DO MARANHAO' city_code, '2109759' ibge_code from dual union
select 'MA' state_code, 'SANTA HELENA' city_code, '2109809' ibge_code from dual union
select 'MA' state_code, 'SANTA INES' city_code, '2109908' ibge_code from dual union
select 'MA' state_code, 'SANTA LUZIA' city_code, '2110005' ibge_code from dual union
select 'MA' state_code, 'SANTA LUZIA DO PARUA' city_code, '2110039' ibge_code from dual union
select 'MA' state_code, 'SANTA QUITERIA DO MARANHAO' city_code, '2110104' ibge_code from dual union
select 'MA' state_code, 'SANTA RITA' city_code, '2110203' ibge_code from dual union
select 'MA' state_code, 'SANTANA DO MARANHAO' city_code, '2110237' ibge_code from dual union
select 'MA' state_code, 'SANTO AMARO DO MARANHAO' city_code, '2110278' ibge_code from dual union
select 'MA' state_code, 'SANTO ANTONIO DOS LOPES' city_code, '2110302' ibge_code from dual union
select 'MA' state_code, 'SAO BENEDITO DO RIO PRETO' city_code, '2110401' ibge_code from dual union
select 'MA' state_code, 'SAO BENTO' city_code, '2110500' ibge_code from dual union
select 'MA' state_code, 'SAO BERNARDO' city_code, '2110609' ibge_code from dual union
select 'MA' state_code, 'SAO DOMINGOS DO AZEITAO' city_code, '2110658' ibge_code from dual union
select 'MA' state_code, 'SAO DOMINGOS DO MARANHAO' city_code, '2110708' ibge_code from dual union
select 'MA' state_code, 'SAO FELIX DE BALSAS' city_code, '2110807' ibge_code from dual union
select 'MA' state_code, 'SAO FRANCISCO DO BREJAO' city_code, '2110856' ibge_code from dual union
select 'MA' state_code, 'SAO FRANCISCO DO MARANHAO' city_code, '2110906' ibge_code from dual union
select 'MA' state_code, 'SAO JOAO BATISTA' city_code, '2111003' ibge_code from dual union
select 'MA' state_code, 'SAO JOAO DO CARU' city_code, '2111029' ibge_code from dual union
select 'MA' state_code, 'SAO JOAO DO PARAISO' city_code, '2111052' ibge_code from dual union
select 'MA' state_code, 'SAO JOAO DO SOTER' city_code, '2111078' ibge_code from dual union
select 'MA' state_code, 'SAO JOAO DOS PATOS' city_code, '2111102' ibge_code from dual union
select 'MA' state_code, 'SAO JOSE DE RIBAMAR' city_code, '2111201' ibge_code from dual union
select 'MA' state_code, 'SAO JOSE DOS BASILIOS' city_code, '2111250' ibge_code from dual union
select 'MA' state_code, 'SAO LUIS' city_code, '2111300' ibge_code from dual union
select 'MA' state_code, 'SAO LUIS GONZAGA DO MARANHAO' city_code, '2111409' ibge_code from dual union
select 'MA' state_code, 'SAO MATEUS DO MARANHAO' city_code, '2111508' ibge_code from dual union
select 'MA' state_code, 'SAO PEDRO DA AGUA BRANCA' city_code, '2111532' ibge_code from dual union
select 'MA' state_code, 'SAO PEDRO DOS CRENTES' city_code, '2111573' ibge_code from dual union
select 'MA' state_code, 'SAO RAIMUNDO DAS MANGABEIRAS' city_code, '2111607' ibge_code from dual union
select 'MA' state_code, 'SAO RAIMUNDO DO DOCA BEZERRA' city_code, '2111631' ibge_code from dual union
select 'MA' state_code, 'SAO ROBERTO' city_code, '2111672' ibge_code from dual union
select 'MA' state_code, 'SAO VICENTE FERRER' city_code, '2111706' ibge_code from dual union
select 'MA' state_code, 'SATUBINHA' city_code, '2111722' ibge_code from dual union
select 'MA' state_code, 'SENADOR ALEXANDRE COSTA' city_code, '2111748' ibge_code from dual union
select 'MA' state_code, 'SENADOR LA ROCQUE' city_code, '2111763' ibge_code from dual union
select 'MA' state_code, 'SERRANO DO MARANHAO' city_code, '2111789' ibge_code from dual union
select 'MA' state_code, 'SITIO NOVO' city_code, '2111805' ibge_code from dual union
select 'MA' state_code, 'SUCUPIRA DO NORTE' city_code, '2111904' ibge_code from dual union
select 'MA' state_code, 'SUCUPIRA DO RIACHAO' city_code, '2111953' ibge_code from dual union
select 'MA' state_code, 'TASSO FRAGOSO' city_code, '2112001' ibge_code from dual union
select 'MA' state_code, 'TIMBIRAS' city_code, '2112100' ibge_code from dual union
select 'MA' state_code, 'TIMON' city_code, '2112209' ibge_code from dual union
select 'MA' state_code, 'TRIZIDELA DO VALE' city_code, '2112233' ibge_code from dual union
select 'MA' state_code, 'TUFILANDIA' city_code, '2112274' ibge_code from dual union
select 'MA' state_code, 'TUNTUM' city_code, '2112308' ibge_code from dual union
select 'MA' state_code, 'TURIACU' city_code, '2112407' ibge_code from dual union
select 'MA' state_code, 'TURILANDIA' city_code, '2112456' ibge_code from dual union
select 'MA' state_code, 'TUTOIA' city_code, '2112506' ibge_code from dual union
select 'MA' state_code, 'URBANO SANTOS' city_code, '2112605' ibge_code from dual union
select 'MA' state_code, 'VARGEM GRANDE' city_code, '2112704' ibge_code from dual union
select 'MA' state_code, 'VIANA' city_code, '2112803' ibge_code from dual union
select 'MA' state_code, 'VILA NOVA DOS MARTIRIOS' city_code, '2112852' ibge_code from dual union
select 'MA' state_code, 'VITORIA DO MEARIM' city_code, '2112902' ibge_code from dual union
select 'MA' state_code, 'VITORINO FREIRE' city_code, '2113009' ibge_code from dual union
select 'MA' state_code, 'ZE DOCA' city_code, '2114007' ibge_code from dual union
select 'PI' state_code, 'ACAUA' city_code, '2200053' ibge_code from dual union
select 'PI' state_code, 'AGRICOLANDIA' city_code, '2200103' ibge_code from dual union
select 'PI' state_code, 'AGUA BRANCA' city_code, '2200202' ibge_code from dual union
select 'PI' state_code, 'ALAGOINHA DO PIAUI' city_code, '2200251' ibge_code from dual union
select 'PI' state_code, 'ALEGRETE DO PIAUI' city_code, '2200277' ibge_code from dual union
select 'PI' state_code, 'ALTO LONGA' city_code, '2200301' ibge_code from dual union
select 'PI' state_code, 'ALTOS' city_code, '2200400' ibge_code from dual union
select 'PI' state_code, 'ALVORADA DO GURGUEIA' city_code, '2200459' ibge_code from dual union
select 'PI' state_code, 'AMARANTE' city_code, '2200509' ibge_code from dual union
select 'PI' state_code, 'ANGICAL DO PIAUI' city_code, '2200608' ibge_code from dual union
select 'PI' state_code, 'ANISIO DE ABREU' city_code, '2200707' ibge_code from dual union
select 'PI' state_code, 'ANTONIO ALMEIDA' city_code, '2200806' ibge_code from dual union
select 'PI' state_code, 'AROAZES' city_code, '2200905' ibge_code from dual union
select 'PI' state_code, 'AROEIRAS DO ITAIM' city_code, '2200954' ibge_code from dual union
select 'PI' state_code, 'ARRAIAL' city_code, '2201002' ibge_code from dual union
select 'PI' state_code, 'ASSUNCAO DO PIAUI' city_code, '2201051' ibge_code from dual union
select 'PI' state_code, 'AVELINO LOPES' city_code, '2201101' ibge_code from dual union
select 'PI' state_code, 'BAIXA GRANDE DO RIBEIRO' city_code, '2201150' ibge_code from dual union
select 'PI' state_code, 'BARRA D''ALCANTARA' city_code, '2201176' ibge_code from dual union
select 'PI' state_code, 'BARRAS' city_code, '2201200' ibge_code from dual union
select 'PI' state_code, 'BARREIRAS DO PIAUI' city_code, '2201309' ibge_code from dual union
select 'PI' state_code, 'BARRO DURO' city_code, '2201408' ibge_code from dual union
select 'PI' state_code, 'BATALHA' city_code, '2201507' ibge_code from dual union
select 'PI' state_code, 'BELA VISTA DO PIAUI' city_code, '2201556' ibge_code from dual union
select 'PI' state_code, 'BELEM DO PIAUI' city_code, '2201572' ibge_code from dual union
select 'PI' state_code, 'BENEDITINOS' city_code, '2201606' ibge_code from dual union
select 'PI' state_code, 'BERTOLINIA' city_code, '2201705' ibge_code from dual union
select 'PI' state_code, 'BETANIA DO PIAUI' city_code, '2201739' ibge_code from dual union
select 'PI' state_code, 'BOA HORA' city_code, '2201770' ibge_code from dual union
select 'PI' state_code, 'BOCAINA' city_code, '2201804' ibge_code from dual union
select 'PI' state_code, 'BOM JESUS' city_code, '2201903' ibge_code from dual union
select 'PI' state_code, 'BOM PRINCIPIO DO PIAUI' city_code, '2201919' ibge_code from dual union
select 'PI' state_code, 'BONFIM DO PIAUI' city_code, '2201929' ibge_code from dual union
select 'PI' state_code, 'BOQUEIRAO DO PIAUI' city_code, '2201945' ibge_code from dual union
select 'PI' state_code, 'BRASILEIRA' city_code, '2201960' ibge_code from dual union
select 'PI' state_code, 'BREJO DO PIAUI' city_code, '2201988' ibge_code from dual union
select 'PI' state_code, 'BURITI DOS LOPES' city_code, '2202000' ibge_code from dual union
select 'PI' state_code, 'BURITI DOS MONTES' city_code, '2202026' ibge_code from dual union
select 'PI' state_code, 'CABECEIRAS DO PIAUI' city_code, '2202059' ibge_code from dual union
select 'PI' state_code, 'CAJAZEIRAS DO PIAUI' city_code, '2202075' ibge_code from dual union
select 'PI' state_code, 'CAJUEIRO DA PRAIA' city_code, '2202083' ibge_code from dual union
select 'PI' state_code, 'CALDEIRAO GRANDE DO PIAUI' city_code, '2202091' ibge_code from dual union
select 'PI' state_code, 'CAMPINAS DO PIAUI' city_code, '2202109' ibge_code from dual union
select 'PI' state_code, 'CAMPO ALEGRE DO FIDALGO' city_code, '2202117' ibge_code from dual union
select 'PI' state_code, 'CAMPO GRANDE DO PIAUI' city_code, '2202133' ibge_code from dual union
select 'PI' state_code, 'CAMPO LARGO DO PIAUI' city_code, '2202174' ibge_code from dual union
select 'PI' state_code, 'CAMPO MAIOR' city_code, '2202208' ibge_code from dual union
select 'PI' state_code, 'CANAVIEIRA' city_code, '2202251' ibge_code from dual union
select 'PI' state_code, 'CANTO DO BURITI' city_code, '2202307' ibge_code from dual union
select 'PI' state_code, 'CAPITAO DE CAMPOS' city_code, '2202406' ibge_code from dual union
select 'PI' state_code, 'CAPITAO GERVASIO OLIVEIRA' city_code, '2202455' ibge_code from dual union
select 'PI' state_code, 'CARACOL' city_code, '2202505' ibge_code from dual union
select 'PI' state_code, 'CARAUBAS DO PIAUI' city_code, '2202539' ibge_code from dual union
select 'PI' state_code, 'CARIDADE DO PIAUI' city_code, '2202554' ibge_code from dual union
select 'PI' state_code, 'CASTELO DO PIAUI' city_code, '2202604' ibge_code from dual union
select 'PI' state_code, 'CAXINGO' city_code, '2202653' ibge_code from dual union
select 'PI' state_code, 'COCAL' city_code, '2202703' ibge_code from dual union
select 'PI' state_code, 'COCAL DE TELHA' city_code, '2202711' ibge_code from dual union
select 'PI' state_code, 'COCAL DOS ALVES' city_code, '2202729' ibge_code from dual union
select 'PI' state_code, 'COIVARAS' city_code, '2202737' ibge_code from dual union
select 'PI' state_code, 'COLONIA DO GURGUEIA' city_code, '2202752' ibge_code from dual union
select 'PI' state_code, 'COLONIA DO PIAUI' city_code, '2202778' ibge_code from dual union
select 'PI' state_code, 'CONCEICAO DO CANINDE' city_code, '2202802' ibge_code from dual union
select 'PI' state_code, 'CORONEL JOSE DIAS' city_code, '2202851' ibge_code from dual union
select 'PI' state_code, 'CORRENTE' city_code, '2202901' ibge_code from dual union
select 'PI' state_code, 'CRISTALANDIA DO PIAUI' city_code, '2203008' ibge_code from dual union
select 'PI' state_code, 'CRISTINO CASTRO' city_code, '2203107' ibge_code from dual union
select 'PI' state_code, 'CURIMATA' city_code, '2203206' ibge_code from dual union
select 'PI' state_code, 'CURRAIS' city_code, '2203230' ibge_code from dual union
select 'PI' state_code, 'CURRAL NOVO DO PIAUI' city_code, '2203271' ibge_code from dual union
select 'PI' state_code, 'CURRALINHOS' city_code, '2203255' ibge_code from dual union
select 'PI' state_code, 'DEMERVAL LOBAO' city_code, '2203305' ibge_code from dual union
select 'PI' state_code, 'DIRCEU ARCOVERDE' city_code, '2203354' ibge_code from dual union
select 'PI' state_code, 'DOM EXPEDITO LOPES' city_code, '2203404' ibge_code from dual union
select 'PI' state_code, 'DOM INOCENCIO' city_code, '2203453' ibge_code from dual union
select 'PI' state_code, 'DOMINGOS MOURAO' city_code, '2203420' ibge_code from dual union
select 'PI' state_code, 'ELESBAO VELOSO' city_code, '2203503' ibge_code from dual union
select 'PI' state_code, 'ELISEU MARTINS' city_code, '2203602' ibge_code from dual union
select 'PI' state_code, 'ESPERANTINA' city_code, '2203701' ibge_code from dual union
select 'PI' state_code, 'FARTURA DO PIAUI' city_code, '2203750' ibge_code from dual union
select 'PI' state_code, 'FLORES DO PIAUI' city_code, '2203800' ibge_code from dual union
select 'PI' state_code, 'FLORESTA DO PIAUI' city_code, '2203859' ibge_code from dual union
select 'PI' state_code, 'FLORIANO' city_code, '2203909' ibge_code from dual union
select 'PI' state_code, 'FRANCINOPOLIS' city_code, '2204006' ibge_code from dual union
select 'PI' state_code, 'FRANCISCO AYRES' city_code, '2204105' ibge_code from dual union
select 'PI' state_code, 'FRANCISCO MACEDO' city_code, '2204154' ibge_code from dual union
select 'PI' state_code, 'FRANCISCO SANTOS' city_code, '2204204' ibge_code from dual union
select 'PI' state_code, 'FRONTEIRAS' city_code, '2204303' ibge_code from dual union
select 'PI' state_code, 'GEMINIANO' city_code, '2204352' ibge_code from dual union
select 'PI' state_code, 'GILBUES' city_code, '2204402' ibge_code from dual union
select 'PI' state_code, 'GUADALUPE' city_code, '2204501' ibge_code from dual union
select 'PI' state_code, 'GUARIBAS' city_code, '2204550' ibge_code from dual union
select 'PI' state_code, 'HUGO NAPOLEAO' city_code, '2204600' ibge_code from dual union
select 'PI' state_code, 'ILHA GRANDE' city_code, '2204659' ibge_code from dual union
select 'PI' state_code, 'INHUMA' city_code, '2204709' ibge_code from dual union
select 'PI' state_code, 'IPIRANGA DO PIAUI' city_code, '2204808' ibge_code from dual union
select 'PI' state_code, 'ISAIAS COELHO' city_code, '2204907' ibge_code from dual union
select 'PI' state_code, 'ITAINOPOLIS' city_code, '2205003' ibge_code from dual union
select 'PI' state_code, 'ITAUEIRA' city_code, '2205102' ibge_code from dual union
select 'PI' state_code, 'JACOBINA DO PIAUI' city_code, '2205151' ibge_code from dual union
select 'PI' state_code, 'JAICOS' city_code, '2205201' ibge_code from dual union
select 'PI' state_code, 'JARDIM DO MULATO' city_code, '2205250' ibge_code from dual union
select 'PI' state_code, 'JATOBA DO PIAUI' city_code, '2205276' ibge_code from dual union
select 'PI' state_code, 'JERUMENHA' city_code, '2205300' ibge_code from dual union
select 'PI' state_code, 'JOAO COSTA' city_code, '2205359' ibge_code from dual union
select 'PI' state_code, 'JOAQUIM PIRES' city_code, '2205409' ibge_code from dual union
select 'PI' state_code, 'JOCA MARQUES' city_code, '2205458' ibge_code from dual union
select 'PI' state_code, 'JOSE DE FREITAS' city_code, '2205508' ibge_code from dual union
select 'PI' state_code, 'JUAZEIRO DO PIAUI' city_code, '2205516' ibge_code from dual union
select 'PI' state_code, 'JULIO BORGES' city_code, '2205524' ibge_code from dual union
select 'PI' state_code, 'JUREMA' city_code, '2205532' ibge_code from dual union
select 'PI' state_code, 'LAGOA ALEGRE' city_code, '2205557' ibge_code from dual union
select 'PI' state_code, 'LAGOA DE SAO FRANCISCO' city_code, '2205573' ibge_code from dual union
select 'PI' state_code, 'LAGOA DO BARRO DO PIAUI' city_code, '2205565' ibge_code from dual union
select 'PI' state_code, 'LAGOA DO PIAUI' city_code, '2205581' ibge_code from dual union
select 'PI' state_code, 'LAGOA DO SITIO' city_code, '2205599' ibge_code from dual union
select 'PI' state_code, 'LAGOINHA DO PIAUI' city_code, '2205540' ibge_code from dual union
select 'PI' state_code, 'LANDRI SALES' city_code, '2205607' ibge_code from dual union
select 'PI' state_code, 'LUIS CORREIA' city_code, '2205706' ibge_code from dual union
select 'PI' state_code, 'LUZILANDIA' city_code, '2205805' ibge_code from dual union
select 'PI' state_code, 'MADEIRO' city_code, '2205854' ibge_code from dual union
select 'PI' state_code, 'MANOEL EMIDIO' city_code, '2205904' ibge_code from dual union
select 'PI' state_code, 'MARCOLANDIA' city_code, '2205953' ibge_code from dual union
select 'PI' state_code, 'MARCOS PARENTE' city_code, '2206001' ibge_code from dual union
select 'PI' state_code, 'MASSAPE DO PIAUI' city_code, '2206050' ibge_code from dual union
select 'PI' state_code, 'MATIAS OLIMPIO' city_code, '2206100' ibge_code from dual union
select 'PI' state_code, 'MIGUEL ALVES' city_code, '2206209' ibge_code from dual union
select 'PI' state_code, 'MIGUEL LEAO' city_code, '2206308' ibge_code from dual union
select 'PI' state_code, 'MILTON BRANDAO' city_code, '2206357' ibge_code from dual union
select 'PI' state_code, 'MONSENHOR GIL' city_code, '2206407' ibge_code from dual union
select 'PI' state_code, 'MONSENHOR HIPOLITO' city_code, '2206506' ibge_code from dual union
select 'PI' state_code, 'MONTE ALEGRE DO PIAUI' city_code, '2206605' ibge_code from dual union
select 'PI' state_code, 'MORRO CABECA NO TEMPO' city_code, '2206654' ibge_code from dual union
select 'PI' state_code, 'MORRO DO CHAPEU DO PIAUI' city_code, '2206670' ibge_code from dual union
select 'PI' state_code, 'MURICI DOS PORTELAS' city_code, '2206696' ibge_code from dual union
select 'PI' state_code, 'NAZARE DO PIAUI' city_code, '2206704' ibge_code from dual union
select 'PI' state_code, 'NAZARIA' city_code, '2206720' ibge_code from dual union
select 'PI' state_code, 'NOSSA SENHORA DE NAZARE' city_code, '2206753' ibge_code from dual union
select 'PI' state_code, 'NOSSA SENHORA DOS REMEDIOS' city_code, '2206803' ibge_code from dual union
select 'PI' state_code, 'NOVA SANTA RITA' city_code, '2207959' ibge_code from dual union
select 'PI' state_code, 'NOVO ORIENTE DO PIAUI' city_code, '2206902' ibge_code from dual union
select 'PI' state_code, 'NOVO SANTO ANTONIO' city_code, '2206951' ibge_code from dual union
select 'PI' state_code, 'OEIRAS' city_code, '2207009' ibge_code from dual union
select 'PI' state_code, 'OLHO D''AGUA DO PIAUI' city_code, '2207108' ibge_code from dual union
select 'PI' state_code, 'PADRE MARCOS' city_code, '2207207' ibge_code from dual union
select 'PI' state_code, 'PAES LANDIM' city_code, '2207306' ibge_code from dual union
select 'PI' state_code, 'PAJEU DO PIAUI' city_code, '2207355' ibge_code from dual union
select 'PI' state_code, 'PALMEIRA DO PIAUI' city_code, '2207405' ibge_code from dual union
select 'PI' state_code, 'PALMEIRAIS' city_code, '2207504' ibge_code from dual union
select 'PI' state_code, 'PAQUETA' city_code, '2207553' ibge_code from dual union
select 'PI' state_code, 'PARNAGUA' city_code, '2207603' ibge_code from dual union
select 'PI' state_code, 'PARNAIBA' city_code, '2207702' ibge_code from dual union
select 'PI' state_code, 'PASSAGEM FRANCA DO PIAUI' city_code, '2207751' ibge_code from dual union
select 'PI' state_code, 'PATOS DO PIAUI' city_code, '2207777' ibge_code from dual union
select 'PI' state_code, 'PAU D''ARCO DO PIAUI' city_code, '2207793' ibge_code from dual union
select 'PI' state_code, 'PAULISTANA' city_code, '2207801' ibge_code from dual union
select 'PI' state_code, 'PAVUSSU' city_code, '2207850' ibge_code from dual union
select 'PI' state_code, 'PEDRO II' city_code, '2207900' ibge_code from dual union
select 'PI' state_code, 'PEDRO LAURENTINO' city_code, '2207934' ibge_code from dual union
select 'PI' state_code, 'PICOS' city_code, '2208007' ibge_code from dual union
select 'PI' state_code, 'PIMENTEIRAS' city_code, '2208106' ibge_code from dual union
select 'PI' state_code, 'PIO IX' city_code, '2208205' ibge_code from dual union
select 'PI' state_code, 'PIRACURUCA' city_code, '2208304' ibge_code from dual union
select 'PI' state_code, 'PIRIPIRI' city_code, '2208403' ibge_code from dual union
select 'PI' state_code, 'PORTO' city_code, '2208502' ibge_code from dual union
select 'PI' state_code, 'PORTO ALEGRE DO PIAUI' city_code, '2208551' ibge_code from dual union
select 'PI' state_code, 'PRATA DO PIAUI' city_code, '2208601' ibge_code from dual union
select 'PI' state_code, 'QUEIMADA NOVA' city_code, '2208650' ibge_code from dual union
select 'PI' state_code, 'REDENCAO DO GURGUEIA' city_code, '2208700' ibge_code from dual union
select 'PI' state_code, 'REGENERACAO' city_code, '2208809' ibge_code from dual union
select 'PI' state_code, 'RIACHO FRIO' city_code, '2208858' ibge_code from dual union
select 'PI' state_code, 'RIBEIRA DO PIAUI' city_code, '2208874' ibge_code from dual union
select 'PI' state_code, 'RIBEIRO GONCALVES' city_code, '2208908' ibge_code from dual union
select 'PI' state_code, 'RIO GRANDE DO PIAUI' city_code, '2209005' ibge_code from dual union
select 'PI' state_code, 'SANTA CRUZ DO PIAUI' city_code, '2209104' ibge_code from dual union
select 'PI' state_code, 'SANTA CRUZ DOS MILAGRES' city_code, '2209153' ibge_code from dual union
select 'PI' state_code, 'SANTA FILOMENA' city_code, '2209203' ibge_code from dual union
select 'PI' state_code, 'SANTA LUZ' city_code, '2209302' ibge_code from dual union
select 'PI' state_code, 'SANTA ROSA DO PIAUI' city_code, '2209377' ibge_code from dual union
select 'PI' state_code, 'SANTANA DO PIAUI' city_code, '2209351' ibge_code from dual union
select 'PI' state_code, 'SANTO ANTONIO DE LISBOA' city_code, '2209401' ibge_code from dual union
select 'PI' state_code, 'SANTO ANTONIO DOS MILAGRES' city_code, '2209450' ibge_code from dual union
select 'PI' state_code, 'SANTO INACIO DO PIAUI' city_code, '2209500' ibge_code from dual union
select 'PI' state_code, 'SAO BRAZ DO PIAUI' city_code, '2209559' ibge_code from dual union
select 'PI' state_code, 'SAO FELIX DO PIAUI' city_code, '2209609' ibge_code from dual union
select 'PI' state_code, 'SAO FRANCISCO DE ASSIS DO PIAUI' city_code, '2209658' ibge_code from dual union
select 'PI' state_code, 'SAO FRANCISCO DO PIAUI' city_code, '2209708' ibge_code from dual union
select 'PI' state_code, 'SAO GONCALO DO GURGUEIA' city_code, '2209757' ibge_code from dual union
select 'PI' state_code, 'SAO GONCALO DO PIAUI' city_code, '2209807' ibge_code from dual union
select 'PI' state_code, 'SAO JOAO DA CANABRAVA' city_code, '2209856' ibge_code from dual union
select 'PI' state_code, 'SAO JOAO DA FRONTEIRA' city_code, '2209872' ibge_code from dual union
select 'PI' state_code, 'SAO JOAO DA SERRA' city_code, '2209906' ibge_code from dual union
select 'PI' state_code, 'SAO JOAO DA VARJOTA' city_code, '2209955' ibge_code from dual union
select 'PI' state_code, 'SAO JOAO DO ARRAIAL' city_code, '2209971' ibge_code from dual union
select 'PI' state_code, 'SAO JOAO DO PIAUI' city_code, '2210003' ibge_code from dual union
select 'PI' state_code, 'SAO JOSE DO DIVINO' city_code, '2210052' ibge_code from dual union
select 'PI' state_code, 'SAO JOSE DO PEIXE' city_code, '2210102' ibge_code from dual union
select 'PI' state_code, 'SAO JOSE DO PIAUI' city_code, '2210201' ibge_code from dual union
select 'PI' state_code, 'SAO JULIAO' city_code, '2210300' ibge_code from dual union
select 'PI' state_code, 'SAO LOURENCO DO PIAUI' city_code, '2210359' ibge_code from dual union
select 'PI' state_code, 'SAO LUIS DO PIAUI' city_code, '2210375' ibge_code from dual union
select 'PI' state_code, 'SAO MIGUEL DA BAIXA GRANDE' city_code, '2210383' ibge_code from dual union
select 'PI' state_code, 'SAO MIGUEL DO FIDALGO' city_code, '2210391' ibge_code from dual union
select 'PI' state_code, 'SAO MIGUEL DO TAPUIO' city_code, '2210409' ibge_code from dual union
select 'PI' state_code, 'SAO PEDRO DO PIAUI' city_code, '2210508' ibge_code from dual union
select 'PI' state_code, 'SAO RAIMUNDO NONATO' city_code, '2210607' ibge_code from dual union
select 'PI' state_code, 'SEBASTIAO BARROS' city_code, '2210623' ibge_code from dual union
select 'PI' state_code, 'SEBASTIAO LEAL' city_code, '2210631' ibge_code from dual union
select 'PI' state_code, 'SIGEFREDO PACHECO' city_code, '2210656' ibge_code from dual union
select 'PI' state_code, 'SIMÕES' city_code, '2210706' ibge_code from dual union
select 'PI' state_code, 'SIMPLICIO MENDES' city_code, '2210805' ibge_code from dual union
select 'PI' state_code, 'SOCORRO DO PIAUI' city_code, '2210904' ibge_code from dual union
select 'PI' state_code, 'SUSSUAPARA' city_code, '2210938' ibge_code from dual union
select 'PI' state_code, 'TAMBORIL DO PIAUI' city_code, '2210953' ibge_code from dual union
select 'PI' state_code, 'TANQUE DO PIAUI' city_code, '2210979' ibge_code from dual union
select 'PI' state_code, 'TERESINA' city_code, '2211001' ibge_code from dual union
select 'PI' state_code, 'UNIAO' city_code, '2211100' ibge_code from dual union
select 'PI' state_code, 'URUCUI' city_code, '2211209' ibge_code from dual union
select 'PI' state_code, 'VALENCA DO PIAUI' city_code, '2211308' ibge_code from dual union
select 'PI' state_code, 'VARZEA BRANCA' city_code, '2211357' ibge_code from dual union
select 'PI' state_code, 'VARZEA GRANDE' city_code, '2211407' ibge_code from dual union
select 'PI' state_code, 'VERA MENDES' city_code, '2211506' ibge_code from dual union
select 'PI' state_code, 'VILA NOVA DO PIAUI' city_code, '2211605' ibge_code from dual union
select 'PI' state_code, 'WALL FERRAZ' city_code, '2211704' ibge_code from dual union
select 'CE' state_code, 'ABAIARA' city_code, '2300101' ibge_code from dual union
select 'CE' state_code, 'ACARAPE' city_code, '2300150' ibge_code from dual union
select 'CE' state_code, 'ACARAU' city_code, '2300200' ibge_code from dual union
select 'CE' state_code, 'ACOPIARA' city_code, '2300309' ibge_code from dual union
select 'CE' state_code, 'AIUABA' city_code, '2300408' ibge_code from dual union
select 'CE' state_code, 'ALCANTARAS' city_code, '2300507' ibge_code from dual union
select 'CE' state_code, 'ALTANEIRA' city_code, '2300606' ibge_code from dual union
select 'CE' state_code, 'ALTO SANTO' city_code, '2300705' ibge_code from dual union
select 'CE' state_code, 'AMONTADA' city_code, '2300754' ibge_code from dual union
select 'CE' state_code, 'ANTONINA DO NORTE' city_code, '2300804' ibge_code from dual union
select 'CE' state_code, 'APUIARES' city_code, '2300903' ibge_code from dual union
select 'CE' state_code, 'AQUIRAZ' city_code, '2301000' ibge_code from dual union
select 'CE' state_code, 'ARACATI' city_code, '2301109' ibge_code from dual union
select 'CE' state_code, 'ARACOIABA' city_code, '2301208' ibge_code from dual union
select 'CE' state_code, 'ARARENDA' city_code, '2301257' ibge_code from dual union
select 'CE' state_code, 'ARARIPE' city_code, '2301307' ibge_code from dual union
select 'CE' state_code, 'ARATUBA' city_code, '2301406' ibge_code from dual union
select 'CE' state_code, 'ARNEIROZ' city_code, '2301505' ibge_code from dual union
select 'CE' state_code, 'ASSARE' city_code, '2301604' ibge_code from dual union
select 'CE' state_code, 'AURORA' city_code, '2301703' ibge_code from dual union
select 'CE' state_code, 'BAIXIO' city_code, '2301802' ibge_code from dual union
select 'CE' state_code, 'BANABUIU' city_code, '2301851' ibge_code from dual union
select 'CE' state_code, 'BARBALHA' city_code, '2301901' ibge_code from dual union
select 'CE' state_code, 'BARREIRA' city_code, '2301950' ibge_code from dual union
select 'CE' state_code, 'BARRO' city_code, '2302008' ibge_code from dual union
select 'CE' state_code, 'BARROQUINHA' city_code, '2302057' ibge_code from dual union
select 'CE' state_code, 'BATURITE' city_code, '2302107' ibge_code from dual union
select 'CE' state_code, 'BEBERIBE' city_code, '2302206' ibge_code from dual union
select 'CE' state_code, 'BELA CRUZ' city_code, '2302305' ibge_code from dual union
select 'CE' state_code, 'BOA VIAGEM' city_code, '2302404' ibge_code from dual union
select 'CE' state_code, 'BREJO SANTO' city_code, '2302503' ibge_code from dual union
select 'CE' state_code, 'CAMOCIM' city_code, '2302602' ibge_code from dual union
select 'CE' state_code, 'CAMPOS SALES' city_code, '2302701' ibge_code from dual union
select 'CE' state_code, 'CANINDE' city_code, '2302800' ibge_code from dual union
select 'CE' state_code, 'CAPISTRANO' city_code, '2302909' ibge_code from dual union
select 'CE' state_code, 'CARIDADE' city_code, '2303006' ibge_code from dual union
select 'CE' state_code, 'CARIRE' city_code, '2303105' ibge_code from dual union
select 'CE' state_code, 'CARIRIACU' city_code, '2303204' ibge_code from dual union
select 'CE' state_code, 'CARIUS' city_code, '2303303' ibge_code from dual union
select 'CE' state_code, 'CARNAUBAL' city_code, '2303402' ibge_code from dual union
select 'CE' state_code, 'CASCAVEL' city_code, '2303501' ibge_code from dual union
select 'CE' state_code, 'CATARINA' city_code, '2303600' ibge_code from dual union
select 'CE' state_code, 'CATUNDA' city_code, '2303659' ibge_code from dual union
select 'CE' state_code, 'CAUCAIA' city_code, '2303709' ibge_code from dual union
select 'CE' state_code, 'CEDRO' city_code, '2303808' ibge_code from dual union
select 'CE' state_code, 'CHAVAL' city_code, '2303907' ibge_code from dual union
select 'CE' state_code, 'CHORO' city_code, '2303931' ibge_code from dual union
select 'CE' state_code, 'CHOROZINHO' city_code, '2303956' ibge_code from dual union
select 'CE' state_code, 'COREAU' city_code, '2304004' ibge_code from dual union
select 'CE' state_code, 'CRATEUS' city_code, '2304103' ibge_code from dual union
select 'CE' state_code, 'CRATO' city_code, '2304202' ibge_code from dual union
select 'CE' state_code, 'CROATA' city_code, '2304236' ibge_code from dual union
select 'CE' state_code, 'CRUZ' city_code, '2304251' ibge_code from dual union
select 'CE' state_code, 'DEPUTADO IRAPUAN PINHEIRO' city_code, '2304269' ibge_code from dual union
select 'CE' state_code, 'ERERE' city_code, '2304277' ibge_code from dual union
select 'CE' state_code, 'EUSEBIO' city_code, '2304285' ibge_code from dual union
select 'CE' state_code, 'FARIAS BRITO' city_code, '2304301' ibge_code from dual union
select 'CE' state_code, 'FORQUILHA' city_code, '2304350' ibge_code from dual union
select 'CE' state_code, 'FORTALEZA' city_code, '2304400' ibge_code from dual union
select 'CE' state_code, 'FORTIM' city_code, '2304459' ibge_code from dual union
select 'CE' state_code, 'FRECHEIRINHA' city_code, '2304509' ibge_code from dual union
select 'CE' state_code, 'GENERAL SAMPAIO' city_code, '2304608' ibge_code from dual union
select 'CE' state_code, 'GRACA' city_code, '2304657' ibge_code from dual union
select 'CE' state_code, 'GRANJA' city_code, '2304707' ibge_code from dual union
select 'CE' state_code, 'GRANJEIRO' city_code, '2304806' ibge_code from dual union
select 'CE' state_code, 'GROAIRAS' city_code, '2304905' ibge_code from dual union
select 'CE' state_code, 'GUAIUBA' city_code, '2304954' ibge_code from dual union
select 'CE' state_code, 'GUARACIABA DO NORTE' city_code, '2305001' ibge_code from dual union
select 'CE' state_code, 'GUARAMIRANGA' city_code, '2305100' ibge_code from dual union
select 'CE' state_code, 'HIDROLANDIA' city_code, '2305209' ibge_code from dual union
select 'CE' state_code, 'HORIZONTE' city_code, '2305233' ibge_code from dual union
select 'CE' state_code, 'IBARETAMA' city_code, '2305266' ibge_code from dual union
select 'CE' state_code, 'IBIAPINA' city_code, '2305308' ibge_code from dual union
select 'CE' state_code, 'IBICUITINGA' city_code, '2305332' ibge_code from dual union
select 'CE' state_code, 'ICAPUI' city_code, '2305357' ibge_code from dual union
select 'CE' state_code, 'ICO' city_code, '2305407' ibge_code from dual union
select 'CE' state_code, 'IGUATU' city_code, '2305506' ibge_code from dual union
select 'CE' state_code, 'INDEPENDENCIA' city_code, '2305605' ibge_code from dual union
select 'CE' state_code, 'IPAPORANGA' city_code, '2305654' ibge_code from dual union
select 'CE' state_code, 'IPAUMIRIM' city_code, '2305704' ibge_code from dual union
select 'CE' state_code, 'IPU' city_code, '2305803' ibge_code from dual union
select 'CE' state_code, 'IPUEIRAS' city_code, '2305902' ibge_code from dual union
select 'CE' state_code, 'IRACEMA' city_code, '2306009' ibge_code from dual union
select 'CE' state_code, 'IRAUCUBA' city_code, '2306108' ibge_code from dual union
select 'CE' state_code, 'ITAICABA' city_code, '2306207' ibge_code from dual union
select 'CE' state_code, 'ITAITINGA' city_code, '2306256' ibge_code from dual union
select 'CE' state_code, 'ITAPAJE' city_code, '2306306' ibge_code from dual union
select 'CE' state_code, 'ITAPIPOCA' city_code, '2306405' ibge_code from dual union
select 'CE' state_code, 'ITAPIUNA' city_code, '2306504' ibge_code from dual union
select 'CE' state_code, 'ITAREMA' city_code, '2306553' ibge_code from dual union
select 'CE' state_code, 'ITATIRA' city_code, '2306603' ibge_code from dual union
select 'CE' state_code, 'JAGUARETAMA' city_code, '2306702' ibge_code from dual union
select 'CE' state_code, 'JAGUARIBARA' city_code, '2306801' ibge_code from dual union
select 'CE' state_code, 'JAGUARIBE' city_code, '2306900' ibge_code from dual union
select 'CE' state_code, 'JAGUARUANA' city_code, '2307007' ibge_code from dual union
select 'CE' state_code, 'JARDIM' city_code, '2307106' ibge_code from dual union
select 'CE' state_code, 'JATI' city_code, '2307205' ibge_code from dual union
select 'CE' state_code, 'JIJOCA DE JERICOACOARA' city_code, '2307254' ibge_code from dual union
select 'CE' state_code, 'JUAZEIRO DO NORTE' city_code, '2307304' ibge_code from dual union
select 'CE' state_code, 'JUCAS' city_code, '2307403' ibge_code from dual union
select 'CE' state_code, 'LAVRAS DA MANGABEIRA' city_code, '2307502' ibge_code from dual union
select 'CE' state_code, 'LIMOEIRO DO NORTE' city_code, '2307601' ibge_code from dual union
select 'CE' state_code, 'MADALENA' city_code, '2307635' ibge_code from dual union
select 'CE' state_code, 'MARACANAU' city_code, '2307650' ibge_code from dual union
select 'CE' state_code, 'MARANGUAPE' city_code, '2307700' ibge_code from dual union
select 'CE' state_code, 'MARCO' city_code, '2307809' ibge_code from dual union
select 'CE' state_code, 'MARTINOPOLE' city_code, '2307908' ibge_code from dual union
select 'CE' state_code, 'MASSAPE' city_code, '2308005' ibge_code from dual union
select 'CE' state_code, 'MAURITI' city_code, '2308104' ibge_code from dual union
select 'CE' state_code, 'MERUOCA' city_code, '2308203' ibge_code from dual union
select 'CE' state_code, 'MILAGRES' city_code, '2308302' ibge_code from dual union
select 'CE' state_code, 'MILHA' city_code, '2308351' ibge_code from dual union
select 'CE' state_code, 'MIRAIMA' city_code, '2308377' ibge_code from dual union
select 'CE' state_code, 'MISSAO VELHA' city_code, '2308401' ibge_code from dual union
select 'CE' state_code, 'MOMBACA' city_code, '2308500' ibge_code from dual union
select 'CE' state_code, 'MONSENHOR TABOSA' city_code, '2308609' ibge_code from dual union
select 'CE' state_code, 'MORADA NOVA' city_code, '2308708' ibge_code from dual union
select 'CE' state_code, 'MORAUJO' city_code, '2308807' ibge_code from dual union
select 'CE' state_code, 'MORRINHOS' city_code, '2308906' ibge_code from dual union
select 'CE' state_code, 'MUCAMBO' city_code, '2309003' ibge_code from dual union
select 'CE' state_code, 'MULUNGU' city_code, '2309102' ibge_code from dual union
select 'CE' state_code, 'NOVA OLINDA' city_code, '2309201' ibge_code from dual union
select 'CE' state_code, 'NOVA RUSSAS' city_code, '2309300' ibge_code from dual union
select 'CE' state_code, 'NOVO ORIENTE' city_code, '2309409' ibge_code from dual union
select 'CE' state_code, 'OCARA' city_code, '2309458' ibge_code from dual union
select 'CE' state_code, 'OROS' city_code, '2309508' ibge_code from dual union
select 'CE' state_code, 'PACAJUS' city_code, '2309607' ibge_code from dual union
select 'CE' state_code, 'PACATUBA' city_code, '2309706' ibge_code from dual union
select 'CE' state_code, 'PACOTI' city_code, '2309805' ibge_code from dual union
select 'CE' state_code, 'PACUJA' city_code, '2309904' ibge_code from dual union
select 'CE' state_code, 'PALHANO' city_code, '2310001' ibge_code from dual union
select 'CE' state_code, 'PALMACIA' city_code, '2310100' ibge_code from dual union
select 'CE' state_code, 'PARACURU' city_code, '2310209' ibge_code from dual union
select 'CE' state_code, 'PARAIPABA' city_code, '2310258' ibge_code from dual union
select 'CE' state_code, 'PARAMBU' city_code, '2310308' ibge_code from dual union
select 'CE' state_code, 'PARAMOTI' city_code, '2310407' ibge_code from dual union
select 'CE' state_code, 'PEDRA BRANCA' city_code, '2310506' ibge_code from dual union
select 'CE' state_code, 'PENAFORTE' city_code, '2310605' ibge_code from dual union
select 'CE' state_code, 'PENTECOSTE' city_code, '2310704' ibge_code from dual union
select 'CE' state_code, 'PEREIRO' city_code, '2310803' ibge_code from dual union
select 'CE' state_code, 'PINDORETAMA' city_code, '2310852' ibge_code from dual union
select 'CE' state_code, 'PIQUET CARNEIRO' city_code, '2310902' ibge_code from dual union
select 'CE' state_code, 'PIRES FERREIRA' city_code, '2310951' ibge_code from dual union
select 'CE' state_code, 'PORANGA' city_code, '2311009' ibge_code from dual union
select 'CE' state_code, 'PORTEIRAS' city_code, '2311108' ibge_code from dual union
select 'CE' state_code, 'POTENGI' city_code, '2311207' ibge_code from dual union
select 'CE' state_code, 'POTIRETAMA' city_code, '2311231' ibge_code from dual union
select 'CE' state_code, 'QUITERIANOPOLIS' city_code, '2311264' ibge_code from dual union
select 'CE' state_code, 'QUIXADA' city_code, '2311306' ibge_code from dual union
select 'CE' state_code, 'QUIXELO' city_code, '2311355' ibge_code from dual union
select 'CE' state_code, 'QUIXERAMOBIM' city_code, '2311405' ibge_code from dual union
select 'CE' state_code, 'QUIXERE' city_code, '2311504' ibge_code from dual union
select 'CE' state_code, 'REDENCAO' city_code, '2311603' ibge_code from dual union
select 'CE' state_code, 'RERIUTABA' city_code, '2311702' ibge_code from dual union
select 'CE' state_code, 'RUSSAS' city_code, '2311801' ibge_code from dual union
select 'CE' state_code, 'SABOEIRO' city_code, '2311900' ibge_code from dual union
select 'CE' state_code, 'SALITRE' city_code, '2311959' ibge_code from dual union
select 'CE' state_code, 'SANTA QUITERIA' city_code, '2312205' ibge_code from dual union
select 'CE' state_code, 'SANTANA DO ACARAU' city_code, '2312007' ibge_code from dual union
select 'CE' state_code, 'SANTANA DO CARIRI' city_code, '2312106' ibge_code from dual union
select 'CE' state_code, 'SAO BENEDITO' city_code, '2312304' ibge_code from dual union
select 'CE' state_code, 'SAO GONCALO DO AMARANTE' city_code, '2312403' ibge_code from dual union
select 'CE' state_code, 'SAO JOAO DO JAGUARIBE' city_code, '2312502' ibge_code from dual union
select 'CE' state_code, 'SAO LUIS DO CURU' city_code, '2312601' ibge_code from dual union
select 'CE' state_code, 'SENADOR POMPEU' city_code, '2312700' ibge_code from dual union
select 'CE' state_code, 'SENADOR SA' city_code, '2312809' ibge_code from dual union
select 'CE' state_code, 'SOBRAL' city_code, '2312908' ibge_code from dual union
select 'CE' state_code, 'SOLONOPOLE' city_code, '2313005' ibge_code from dual union
select 'CE' state_code, 'TABULEIRO DO NORTE' city_code, '2313104' ibge_code from dual union
select 'CE' state_code, 'TAMBORIL' city_code, '2313203' ibge_code from dual union
select 'CE' state_code, 'TARRAFAS' city_code, '2313252' ibge_code from dual union
select 'CE' state_code, 'TAUA' city_code, '2313302' ibge_code from dual union
select 'CE' state_code, 'TEJUCUOCA' city_code, '2313351' ibge_code from dual union
select 'CE' state_code, 'TIANGUA' city_code, '2313401' ibge_code from dual union
select 'CE' state_code, 'TRAIRI' city_code, '2313500' ibge_code from dual union
select 'CE' state_code, 'TURURU' city_code, '2313559' ibge_code from dual union
select 'CE' state_code, 'UBAJARA' city_code, '2313609' ibge_code from dual union
select 'CE' state_code, 'UMARI' city_code, '2313708' ibge_code from dual union
select 'CE' state_code, 'UMIRIM' city_code, '2313757' ibge_code from dual union
select 'CE' state_code, 'URUBURETAMA' city_code, '2313807' ibge_code from dual union
select 'CE' state_code, 'URUOCA' city_code, '2313906' ibge_code from dual union
select 'CE' state_code, 'VARJOTA' city_code, '2313955' ibge_code from dual union
select 'CE' state_code, 'VARZEA ALEGRE' city_code, '2314003' ibge_code from dual union
select 'CE' state_code, 'VICOSA DO CEARA' city_code, '2314102' ibge_code from dual union
select 'RN' state_code, 'ACARI' city_code, '2400109' ibge_code from dual union
select 'RN' state_code, 'ACU' city_code, '2400208' ibge_code from dual union
select 'RN' state_code, 'AFONSO BEZERRA' city_code, '2400307' ibge_code from dual union
select 'RN' state_code, 'AGUA NOVA' city_code, '2400406' ibge_code from dual union
select 'RN' state_code, 'ALEXANDRIA' city_code, '2400505' ibge_code from dual union
select 'RN' state_code, 'ALMINO AFONSO' city_code, '2400604' ibge_code from dual union
select 'RN' state_code, 'ALTO DO RODRIGUES' city_code, '2400703' ibge_code from dual union
select 'RN' state_code, 'ANGICOS' city_code, '2400802' ibge_code from dual union
select 'RN' state_code, 'ANTONIO MARTINS' city_code, '2400901' ibge_code from dual union
select 'RN' state_code, 'APODI' city_code, '2401008' ibge_code from dual union
select 'RN' state_code, 'AREIA BRANCA' city_code, '2401107' ibge_code from dual union
select 'RN' state_code, 'ARES' city_code, '2401206' ibge_code from dual union
select 'RN' state_code, 'AUGUSTO SEVERO' city_code, '2401305' ibge_code from dual union
select 'RN' state_code, 'BAIA FORMOSA' city_code, '2401404' ibge_code from dual union
select 'RN' state_code, 'BARAUNA' city_code, '2401453' ibge_code from dual union
select 'RN' state_code, 'BARCELONA' city_code, '2401503' ibge_code from dual union
select 'RN' state_code, 'BENTO FERNANDES' city_code, '2401602' ibge_code from dual union
select 'RN' state_code, 'BODO' city_code, '2401651' ibge_code from dual union
select 'RN' state_code, 'BOM JESUS' city_code, '2401701' ibge_code from dual union
select 'RN' state_code, 'BREJINHO' city_code, '2401800' ibge_code from dual union
select 'RN' state_code, 'CAICARA DO NORTE' city_code, '2401859' ibge_code from dual union
select 'RN' state_code, 'CAICARA DO RIO DO VENTO' city_code, '2401909' ibge_code from dual union
select 'RN' state_code, 'CAICO' city_code, '2402006' ibge_code from dual union
select 'RN' state_code, 'CAMPO REDONDO' city_code, '2402105' ibge_code from dual union
select 'RN' state_code, 'CANGUARETAMA' city_code, '2402204' ibge_code from dual union
select 'RN' state_code, 'CARAUBAS' city_code, '2402303' ibge_code from dual union
select 'RN' state_code, 'CARNAUBA DOS DANTAS' city_code, '2402402' ibge_code from dual union
select 'RN' state_code, 'CARNAUBAIS' city_code, '2402501' ibge_code from dual union
select 'RN' state_code, 'CEARA-MIRIM' city_code, '2402600' ibge_code from dual union
select 'RN' state_code, 'CERRO CORA' city_code, '2402709' ibge_code from dual union
select 'RN' state_code, 'CORONEL EZEQUIEL' city_code, '2402808' ibge_code from dual union
select 'RN' state_code, 'CORONEL JOAO PESSOA' city_code, '2402907' ibge_code from dual union
select 'RN' state_code, 'CRUZETA' city_code, '2403004' ibge_code from dual union
select 'RN' state_code, 'CURRAIS NOVOS' city_code, '2403103' ibge_code from dual union
select 'RN' state_code, 'DOUTOR SEVERIANO' city_code, '2403202' ibge_code from dual union
select 'RN' state_code, 'ENCANTO' city_code, '2403301' ibge_code from dual union
select 'RN' state_code, 'EQUADOR' city_code, '2403400' ibge_code from dual union
select 'RN' state_code, 'ESPIRITO SANTO' city_code, '2403509' ibge_code from dual union
select 'RN' state_code, 'EXTREMOZ' city_code, '2403608' ibge_code from dual union
select 'RN' state_code, 'FELIPE GUERRA' city_code, '2403707' ibge_code from dual union
select 'RN' state_code, 'FERNANDO PEDROZA' city_code, '2403756' ibge_code from dual union
select 'RN' state_code, 'FLORANIA' city_code, '2403806' ibge_code from dual union
select 'RN' state_code, 'FRANCISCO DANTAS' city_code, '2403905' ibge_code from dual union
select 'RN' state_code, 'FRUTUOSO GOMES' city_code, '2404002' ibge_code from dual union
select 'RN' state_code, 'GALINHOS' city_code, '2404101' ibge_code from dual union
select 'RN' state_code, 'GOIANINHA' city_code, '2404200' ibge_code from dual union
select 'RN' state_code, 'GOVERNADOR DIX-SEPT ROSADO' city_code, '2404309' ibge_code from dual union
select 'RN' state_code, 'GROSSOS' city_code, '2404408' ibge_code from dual union
select 'RN' state_code, 'GUAMARE' city_code, '2404507' ibge_code from dual union
select 'RN' state_code, 'IELMO MARINHO' city_code, '2404606' ibge_code from dual union
select 'RN' state_code, 'IPANGUACU' city_code, '2404705' ibge_code from dual union
select 'RN' state_code, 'IPUEIRA' city_code, '2404804' ibge_code from dual union
select 'RN' state_code, 'ITAJA' city_code, '2404853' ibge_code from dual union
select 'RN' state_code, 'ITAU' city_code, '2404903' ibge_code from dual union
select 'RN' state_code, 'JACANA' city_code, '2405009' ibge_code from dual union
select 'RN' state_code, 'JANDAIRA' city_code, '2405108' ibge_code from dual union
select 'RN' state_code, 'JANDUIS' city_code, '2405207' ibge_code from dual union
select 'RN' state_code, 'JANUARIO CICCO' city_code, '2405306' ibge_code from dual union
select 'RN' state_code, 'JAPI' city_code, '2405405' ibge_code from dual union
select 'RN' state_code, 'JARDIM DE ANGICOS' city_code, '2405504' ibge_code from dual union
select 'RN' state_code, 'JARDIM DE PIRANHAS' city_code, '2405603' ibge_code from dual union
select 'RN' state_code, 'JARDIM DO SERIDO' city_code, '2405702' ibge_code from dual union
select 'RN' state_code, 'JOAO CAMARA' city_code, '2405801' ibge_code from dual union
select 'RN' state_code, 'JOAO DIAS' city_code, '2405900' ibge_code from dual union
select 'RN' state_code, 'JOSE DA PENHA' city_code, '2406007' ibge_code from dual union
select 'RN' state_code, 'JUCURUTU' city_code, '2406106' ibge_code from dual union
select 'RN' state_code, 'JUNDIA' city_code, '2406155' ibge_code from dual union
select 'RN' state_code, 'LAGOA D''ANTA' city_code, '2406205' ibge_code from dual union
select 'RN' state_code, 'LAGOA DE PEDRAS' city_code, '2406304' ibge_code from dual union
select 'RN' state_code, 'LAGOA DE VELHOS' city_code, '2406403' ibge_code from dual union
select 'RN' state_code, 'LAGOA NOVA' city_code, '2406502' ibge_code from dual union
select 'RN' state_code, 'LAGOA SALGADA' city_code, '2406601' ibge_code from dual union
select 'RN' state_code, 'LAJES' city_code, '2406700' ibge_code from dual union
select 'RN' state_code, 'LAJES PINTADAS' city_code, '2406809' ibge_code from dual union
select 'RN' state_code, 'LUCRECIA' city_code, '2406908' ibge_code from dual union
select 'RN' state_code, 'LUIS GOMES' city_code, '2407005' ibge_code from dual union
select 'RN' state_code, 'MACAIBA' city_code, '2407104' ibge_code from dual union
select 'RN' state_code, 'MACAU' city_code, '2407203' ibge_code from dual union
select 'RN' state_code, 'MAJOR SALES' city_code, '2407252' ibge_code from dual union
select 'RN' state_code, 'MARCELINO VIEIRA' city_code, '2407302' ibge_code from dual union
select 'RN' state_code, 'MARTINS' city_code, '2407401' ibge_code from dual union
select 'RN' state_code, 'MAXARANGUAPE' city_code, '2407500' ibge_code from dual union
select 'RN' state_code, 'MESSIAS TARGINO' city_code, '2407609' ibge_code from dual union
select 'RN' state_code, 'MONTANHAS' city_code, '2407708' ibge_code from dual union
select 'RN' state_code, 'MONTE ALEGRE' city_code, '2407807' ibge_code from dual union
select 'RN' state_code, 'MONTE DAS GAMELEIRAS' city_code, '2407906' ibge_code from dual union
select 'RN' state_code, 'MOSSORO' city_code, '2408003' ibge_code from dual union
select 'RN' state_code, 'NATAL' city_code, '2408102' ibge_code from dual union
select 'RN' state_code, 'NISIA FLORESTA' city_code, '2408201' ibge_code from dual union
select 'RN' state_code, 'NOVA CRUZ' city_code, '2408300' ibge_code from dual union
select 'RN' state_code, 'OLHO D''AGUA DO BORGES' city_code, '2408409' ibge_code from dual union
select 'RN' state_code, 'OURO BRANCO' city_code, '2408508' ibge_code from dual union
select 'RN' state_code, 'PARANA' city_code, '2408607' ibge_code from dual union
select 'RN' state_code, 'PARAU' city_code, '2408706' ibge_code from dual union
select 'RN' state_code, 'PARAZINHO' city_code, '2408805' ibge_code from dual union
select 'RN' state_code, 'PARELHAS' city_code, '2408904' ibge_code from dual union
select 'RN' state_code, 'PARNAMIRIM' city_code, '2403251' ibge_code from dual union
select 'RN' state_code, 'PASSA E FICA' city_code, '2409100' ibge_code from dual union
select 'RN' state_code, 'PASSAGEM' city_code, '2409209' ibge_code from dual union
select 'RN' state_code, 'PATU' city_code, '2409308' ibge_code from dual union
select 'RN' state_code, 'PAU DOS FERROS' city_code, '2409407' ibge_code from dual union
select 'RN' state_code, 'PEDRA GRANDE' city_code, '2409506' ibge_code from dual union
select 'RN' state_code, 'PEDRA PRETA' city_code, '2409605' ibge_code from dual union
select 'RN' state_code, 'PEDRO AVELINO' city_code, '2409704' ibge_code from dual union
select 'RN' state_code, 'PEDRO VELHO' city_code, '2409803' ibge_code from dual union
select 'RN' state_code, 'PENDENCIAS' city_code, '2409902' ibge_code from dual union
select 'RN' state_code, 'PILÕES' city_code, '2410009' ibge_code from dual union
select 'RN' state_code, 'POCO BRANCO' city_code, '2410108' ibge_code from dual union
select 'RN' state_code, 'PORTALEGRE' city_code, '2410207' ibge_code from dual union
select 'RN' state_code, 'PORTO DO MANGUE' city_code, '2410256' ibge_code from dual union
select 'RN' state_code, 'PUREZA' city_code, '2410405' ibge_code from dual union
select 'RN' state_code, 'RAFAEL FERNANDES' city_code, '2410504' ibge_code from dual union
select 'RN' state_code, 'RAFAEL GODEIRO' city_code, '2410603' ibge_code from dual union
select 'RN' state_code, 'RIACHO DA CRUZ' city_code, '2410702' ibge_code from dual union
select 'RN' state_code, 'RIACHO DE SANTANA' city_code, '2410801' ibge_code from dual union
select 'RN' state_code, 'RIACHUELO' city_code, '2410900' ibge_code from dual union
select 'RN' state_code, 'RIO DO FOGO' city_code, '2408953' ibge_code from dual union
select 'RN' state_code, 'RODOLFO FERNANDES' city_code, '2411007' ibge_code from dual union
select 'RN' state_code, 'RUY BARBOSA' city_code, '2411106' ibge_code from dual union
select 'RN' state_code, 'SANTA CRUZ' city_code, '2411205' ibge_code from dual union
select 'RN' state_code, 'SANTA MARIA' city_code, '2409332' ibge_code from dual union
select 'RN' state_code, 'SANTANA DO MATOS' city_code, '2411403' ibge_code from dual union
select 'RN' state_code, 'SANTANA DO SERIDO' city_code, '2411429' ibge_code from dual union
select 'RN' state_code, 'SANTO ANTONIO' city_code, '2411502' ibge_code from dual union
select 'RN' state_code, 'SAO BENTO DO NORTE' city_code, '2411601' ibge_code from dual union
select 'RN' state_code, 'SAO BENTO DO TRAIRI' city_code, '2411700' ibge_code from dual union
select 'RN' state_code, 'SAO FERNANDO' city_code, '2411809' ibge_code from dual union
select 'RN' state_code, 'SAO FRANCISCO DO OESTE' city_code, '2411908' ibge_code from dual union
select 'RN' state_code, 'SAO GONCALO DO AMARANTE' city_code, '2412005' ibge_code from dual union
select 'RN' state_code, 'SAO JOAO DO SABUGI' city_code, '2412104' ibge_code from dual union
select 'RN' state_code, 'SAO JOSE DE MIPIBU' city_code, '2412203' ibge_code from dual union
select 'RN' state_code, 'SAO JOSE DO CAMPESTRE' city_code, '2412302' ibge_code from dual union
select 'RN' state_code, 'SAO JOSE DO SERIDO' city_code, '2412401' ibge_code from dual union
select 'RN' state_code, 'SAO MIGUEL' city_code, '2412500' ibge_code from dual union
select 'RN' state_code, 'SAO MIGUEL DO GOSTOSO' city_code, '2412559' ibge_code from dual union
select 'RN' state_code, 'SAO PAULO DO POTENGI' city_code, '2412609' ibge_code from dual union
select 'RN' state_code, 'SAO PEDRO' city_code, '2412708' ibge_code from dual union
select 'RN' state_code, 'SAO RAFAEL' city_code, '2412807' ibge_code from dual union
select 'RN' state_code, 'SAO TOME' city_code, '2412906' ibge_code from dual union
select 'RN' state_code, 'SAO VICENTE' city_code, '2413003' ibge_code from dual union
select 'RN' state_code, 'SENADOR ELOI DE SOUZA' city_code, '2413102' ibge_code from dual union
select 'RN' state_code, 'SENADOR GEORGINO AVELINO' city_code, '2413201' ibge_code from dual union
select 'RN' state_code, 'SERRA CAIADA' city_code, '2410306' ibge_code from dual union
select 'RN' state_code, 'SERRA DE SAO BENTO' city_code, '2413300' ibge_code from dual union
select 'RN' state_code, 'SERRA DO MEL' city_code, '2413359' ibge_code from dual union
select 'RN' state_code, 'SERRA NEGRA DO NORTE' city_code, '2413409' ibge_code from dual union
select 'RN' state_code, 'SERRINHA' city_code, '2413508' ibge_code from dual union
select 'RN' state_code, 'SERRINHA DOS PINTOS' city_code, '2413557' ibge_code from dual union
select 'RN' state_code, 'SEVERIANO MELO' city_code, '2413607' ibge_code from dual union
select 'RN' state_code, 'SITIO NOVO' city_code, '2413706' ibge_code from dual union
select 'RN' state_code, 'TABOLEIRO GRANDE' city_code, '2413805' ibge_code from dual union
select 'RN' state_code, 'TAIPU' city_code, '2413904' ibge_code from dual union
select 'RN' state_code, 'TANGARA' city_code, '2414001' ibge_code from dual union
select 'RN' state_code, 'TENENTE ANANIAS' city_code, '2414100' ibge_code from dual union
select 'RN' state_code, 'TENENTE LAURENTINO CRUZ' city_code, '2414159' ibge_code from dual union
select 'RN' state_code, 'TIBAU' city_code, '2411056' ibge_code from dual union
select 'RN' state_code, 'TIBAU DO SUL' city_code, '2414209' ibge_code from dual union
select 'RN' state_code, 'TIMBAUBA DOS BATISTAS' city_code, '2414308' ibge_code from dual union
select 'RN' state_code, 'TOUROS' city_code, '2414407' ibge_code from dual union
select 'RN' state_code, 'TRIUNFO POTIGUAR' city_code, '2414456' ibge_code from dual union
select 'RN' state_code, 'UMARIZAL' city_code, '2414506' ibge_code from dual union
select 'RN' state_code, 'UPANEMA' city_code, '2414605' ibge_code from dual union
select 'RN' state_code, 'VARZEA' city_code, '2414704' ibge_code from dual union
select 'RN' state_code, 'VENHA-VER' city_code, '2414753' ibge_code from dual union
select 'RN' state_code, 'VERA CRUZ' city_code, '2414803' ibge_code from dual union
select 'RN' state_code, 'VICOSA' city_code, '2414902' ibge_code from dual union
select 'RN' state_code, 'VILA FLOR' city_code, '2415008' ibge_code from dual union
select 'PB' state_code, 'AGUA BRANCA' city_code, '2500106' ibge_code from dual union
select 'PB' state_code, 'AGUIAR' city_code, '2500205' ibge_code from dual union
select 'PB' state_code, 'ALAGOA GRANDE' city_code, '2500304' ibge_code from dual union
select 'PB' state_code, 'ALAGOA NOVA' city_code, '2500403' ibge_code from dual union
select 'PB' state_code, 'ALAGOINHA' city_code, '2500502' ibge_code from dual union
select 'PB' state_code, 'ALCANTIL' city_code, '2500536' ibge_code from dual union
select 'PB' state_code, 'ALGODAO DE JANDAIRA' city_code, '2500577' ibge_code from dual union
select 'PB' state_code, 'ALHANDRA' city_code, '2500601' ibge_code from dual union
select 'PB' state_code, 'AMPARO' city_code, '2500734' ibge_code from dual union
select 'PB' state_code, 'APARECIDA' city_code, '2500775' ibge_code from dual union
select 'PB' state_code, 'ARACAGI' city_code, '2500809' ibge_code from dual union
select 'PB' state_code, 'ARARA' city_code, '2500908' ibge_code from dual union
select 'PB' state_code, 'ARARUNA' city_code, '2501005' ibge_code from dual union
select 'PB' state_code, 'AREIA' city_code, '2501104' ibge_code from dual union
select 'PB' state_code, 'AREIA DE BARAUNAS' city_code, '2501153' ibge_code from dual union
select 'PB' state_code, 'AREIAL' city_code, '2501203' ibge_code from dual union
select 'PB' state_code, 'AROEIRAS' city_code, '2501302' ibge_code from dual union
select 'PB' state_code, 'ASSUNCAO' city_code, '2501351' ibge_code from dual union
select 'PB' state_code, 'BAIA DA TRAICAO' city_code, '2501401' ibge_code from dual union
select 'PB' state_code, 'BANANEIRAS' city_code, '2501500' ibge_code from dual union
select 'PB' state_code, 'BARAUNA' city_code, '2501534' ibge_code from dual union
select 'PB' state_code, 'BARRA DE SANTA ROSA' city_code, '2501609' ibge_code from dual union
select 'PB' state_code, 'BARRA DE SANTANA' city_code, '2501575' ibge_code from dual union
select 'PB' state_code, 'BARRA DE SAO MIGUEL' city_code, '2501708' ibge_code from dual union
select 'PB' state_code, 'BAYEUX' city_code, '2501807' ibge_code from dual union
select 'PB' state_code, 'BELEM' city_code, '2501906' ibge_code from dual union
select 'PB' state_code, 'BELEM DO BREJO DO CRUZ' city_code, '2502003' ibge_code from dual union
select 'PB' state_code, 'BERNARDINO BATISTA' city_code, '2502052' ibge_code from dual union
select 'PB' state_code, 'BOA VENTURA' city_code, '2502102' ibge_code from dual union
select 'PB' state_code, 'BOA VISTA' city_code, '2502151' ibge_code from dual union
select 'PB' state_code, 'BOM JESUS' city_code, '2502201' ibge_code from dual union
select 'PB' state_code, 'BOM SUCESSO' city_code, '2502300' ibge_code from dual union
select 'PB' state_code, 'BONITO DE SANTA FE' city_code, '2502409' ibge_code from dual union
select 'PB' state_code, 'BOQUEIRAO' city_code, '2502508' ibge_code from dual union
select 'PB' state_code, 'BORBOREMA' city_code, '2502706' ibge_code from dual union
select 'PB' state_code, 'BREJO DO CRUZ' city_code, '2502805' ibge_code from dual union
select 'PB' state_code, 'BREJO DOS SANTOS' city_code, '2502904' ibge_code from dual union
select 'PB' state_code, 'CAAPORA' city_code, '2503001' ibge_code from dual union
select 'PB' state_code, 'CABACEIRAS' city_code, '2503100' ibge_code from dual union
select 'PB' state_code, 'CABEDELO' city_code, '2503209' ibge_code from dual union
select 'PB' state_code, 'CACHOEIRA DOS INDIOS' city_code, '2503308' ibge_code from dual union
select 'PB' state_code, 'CACIMBA DE AREIA' city_code, '2503407' ibge_code from dual union
select 'PB' state_code, 'CACIMBA DE DENTRO' city_code, '2503506' ibge_code from dual union
select 'PB' state_code, 'CACIMBAS' city_code, '2503555' ibge_code from dual union
select 'PB' state_code, 'CAICARA' city_code, '2503605' ibge_code from dual union
select 'PB' state_code, 'CAJAZEIRAS' city_code, '2503704' ibge_code from dual union
select 'PB' state_code, 'CAJAZEIRINHAS' city_code, '2503753' ibge_code from dual union
select 'PB' state_code, 'CALDAS BRANDAO' city_code, '2503803' ibge_code from dual union
select 'PB' state_code, 'CAMALAU' city_code, '2503902' ibge_code from dual union
select 'PB' state_code, 'CAMPINA GRANDE' city_code, '2504009' ibge_code from dual union
select 'PB' state_code, 'CAPIM' city_code, '2504033' ibge_code from dual union
select 'PB' state_code, 'CARAUBAS' city_code, '2504074' ibge_code from dual union
select 'PB' state_code, 'CARRAPATEIRA' city_code, '2504108' ibge_code from dual union
select 'PB' state_code, 'CASSERENGUE' city_code, '2504157' ibge_code from dual union
select 'PB' state_code, 'CATINGUEIRA' city_code, '2504207' ibge_code from dual union
select 'PB' state_code, 'CATOLE DO ROCHA' city_code, '2504306' ibge_code from dual union
select 'PB' state_code, 'CATURITE' city_code, '2504355' ibge_code from dual union
select 'PB' state_code, 'CONCEICAO' city_code, '2504405' ibge_code from dual union
select 'PB' state_code, 'CONDADO' city_code, '2504504' ibge_code from dual union
select 'PB' state_code, 'CONDE' city_code, '2504603' ibge_code from dual union
select 'PB' state_code, 'CONGO' city_code, '2504702' ibge_code from dual union
select 'PB' state_code, 'COREMAS' city_code, '2504801' ibge_code from dual union
select 'PB' state_code, 'COXIXOLA' city_code, '2504850' ibge_code from dual union
select 'PB' state_code, 'CRUZ DO ESPIRITO SANTO' city_code, '2504900' ibge_code from dual union
select 'PB' state_code, 'CUBATI' city_code, '2505006' ibge_code from dual union
select 'PB' state_code, 'CUITE' city_code, '2505105' ibge_code from dual union
select 'PB' state_code, 'CUITE DE MAMANGUAPE' city_code, '2505238' ibge_code from dual union
select 'PB' state_code, 'CUITEGI' city_code, '2505204' ibge_code from dual union
select 'PB' state_code, 'CURRAL DE CIMA' city_code, '2505279' ibge_code from dual union
select 'PB' state_code, 'CURRAL VELHO' city_code, '2505303' ibge_code from dual union
select 'PB' state_code, 'DAMIAO' city_code, '2505352' ibge_code from dual union
select 'PB' state_code, 'DESTERRO' city_code, '2505402' ibge_code from dual union
select 'PB' state_code, 'DIAMANTE' city_code, '2505600' ibge_code from dual union
select 'PB' state_code, 'DONA INES' city_code, '2505709' ibge_code from dual union
select 'PB' state_code, 'DUAS ESTRADAS' city_code, '2505808' ibge_code from dual union
select 'PB' state_code, 'EMAS' city_code, '2505907' ibge_code from dual union
select 'PB' state_code, 'ESPERANCA' city_code, '2506004' ibge_code from dual union
select 'PB' state_code, 'FAGUNDES' city_code, '2506103' ibge_code from dual union
select 'PB' state_code, 'FREI MARTINHO' city_code, '2506202' ibge_code from dual union
select 'PB' state_code, 'GADO BRAVO' city_code, '2506251' ibge_code from dual union
select 'PB' state_code, 'GUARABIRA' city_code, '2506301' ibge_code from dual union
select 'PB' state_code, 'GURINHEM' city_code, '2506400' ibge_code from dual union
select 'PB' state_code, 'GURJAO' city_code, '2506509' ibge_code from dual union
select 'PB' state_code, 'IBIARA' city_code, '2506608' ibge_code from dual union
select 'PB' state_code, 'IGARACY' city_code, '2502607' ibge_code from dual union
select 'PB' state_code, 'IMACULADA' city_code, '2506707' ibge_code from dual union
select 'PB' state_code, 'INGA' city_code, '2506806' ibge_code from dual union
select 'PB' state_code, 'ITABAIANA' city_code, '2506905' ibge_code from dual union
select 'PB' state_code, 'ITAPORANGA' city_code, '2507002' ibge_code from dual union
select 'PB' state_code, 'ITAPOROROCA' city_code, '2507101' ibge_code from dual union
select 'PB' state_code, 'ITATUBA' city_code, '2507200' ibge_code from dual union
select 'PB' state_code, 'JACARAU' city_code, '2507309' ibge_code from dual union
select 'PB' state_code, 'JERICO' city_code, '2507408' ibge_code from dual union
select 'PB' state_code, 'JOAO PESSOA' city_code, '2507507' ibge_code from dual union
select 'PB' state_code, 'JOCA CLAUDINO' city_code, '2513653' ibge_code from dual union
select 'PB' state_code, 'JUAREZ TAVORA' city_code, '2507606' ibge_code from dual union
select 'PB' state_code, 'JUAZEIRINHO' city_code, '2507705' ibge_code from dual union
select 'PB' state_code, 'JUNCO DO SERIDO' city_code, '2507804' ibge_code from dual union
select 'PB' state_code, 'JURIPIRANGA' city_code, '2507903' ibge_code from dual union
select 'PB' state_code, 'JURU' city_code, '2508000' ibge_code from dual union
select 'PB' state_code, 'LAGOA' city_code, '2508109' ibge_code from dual union
select 'PB' state_code, 'LAGOA DE DENTRO' city_code, '2508208' ibge_code from dual union
select 'PB' state_code, 'LAGOA SECA' city_code, '2508307' ibge_code from dual union
select 'PB' state_code, 'LASTRO' city_code, '2508406' ibge_code from dual union
select 'PB' state_code, 'LIVRAMENTO' city_code, '2508505' ibge_code from dual union
select 'PB' state_code, 'LOGRADOURO' city_code, '2508554' ibge_code from dual union
select 'PB' state_code, 'LUCENA' city_code, '2508604' ibge_code from dual union
select 'PB' state_code, 'MAE D''AGUA' city_code, '2508703' ibge_code from dual union
select 'PB' state_code, 'MALTA' city_code, '2508802' ibge_code from dual union
select 'PB' state_code, 'MAMANGUAPE' city_code, '2508901' ibge_code from dual union
select 'PB' state_code, 'MANAIRA' city_code, '2509008' ibge_code from dual union
select 'PB' state_code, 'MARCACAO' city_code, '2509057' ibge_code from dual union
select 'PB' state_code, 'MARI' city_code, '2509107' ibge_code from dual union
select 'PB' state_code, 'MARIZOPOLIS' city_code, '2509156' ibge_code from dual union
select 'PB' state_code, 'MASSARANDUBA' city_code, '2509206' ibge_code from dual union
select 'PB' state_code, 'MATARACA' city_code, '2509305' ibge_code from dual union
select 'PB' state_code, 'MATINHAS' city_code, '2509339' ibge_code from dual union
select 'PB' state_code, 'MATO GROSSO' city_code, '2509370' ibge_code from dual union
select 'PB' state_code, 'MATUREIA' city_code, '2509396' ibge_code from dual union
select 'PB' state_code, 'MOGEIRO' city_code, '2509404' ibge_code from dual union
select 'PB' state_code, 'MONTADAS' city_code, '2509503' ibge_code from dual union
select 'PB' state_code, 'MONTE HOREBE' city_code, '2509602' ibge_code from dual union
select 'PB' state_code, 'MONTEIRO' city_code, '2509701' ibge_code from dual union
select 'PB' state_code, 'MULUNGU' city_code, '2509800' ibge_code from dual union
select 'PB' state_code, 'NATUBA' city_code, '2509909' ibge_code from dual union
select 'PB' state_code, 'NAZAREZINHO' city_code, '2510006' ibge_code from dual union
select 'PB' state_code, 'NOVA FLORESTA' city_code, '2510105' ibge_code from dual union
select 'PB' state_code, 'NOVA OLINDA' city_code, '2510204' ibge_code from dual union
select 'PB' state_code, 'NOVA PALMEIRA' city_code, '2510303' ibge_code from dual union
select 'PB' state_code, 'OLHO D''AGUA' city_code, '2510402' ibge_code from dual union
select 'PB' state_code, 'OLIVEDOS' city_code, '2510501' ibge_code from dual union
select 'PB' state_code, 'OURO VELHO' city_code, '2510600' ibge_code from dual union
select 'PB' state_code, 'PARARI' city_code, '2510659' ibge_code from dual union
select 'PB' state_code, 'PASSAGEM' city_code, '2510709' ibge_code from dual union
select 'PB' state_code, 'PATOS' city_code, '2510808' ibge_code from dual union
select 'PB' state_code, 'PAULISTA' city_code, '2510907' ibge_code from dual union
select 'PB' state_code, 'PEDRA BRANCA' city_code, '2511004' ibge_code from dual union
select 'PB' state_code, 'PEDRA LAVRADA' city_code, '2511103' ibge_code from dual union
select 'PB' state_code, 'PEDRAS DE FOGO' city_code, '2511202' ibge_code from dual union
select 'PB' state_code, 'PEDRO REGIS' city_code, '2512721' ibge_code from dual union
select 'PB' state_code, 'PIANCO' city_code, '2511301' ibge_code from dual union
select 'PB' state_code, 'PICUI' city_code, '2511400' ibge_code from dual union
select 'PB' state_code, 'PILAR' city_code, '2511509' ibge_code from dual union
select 'PB' state_code, 'PILÕES' city_code, '2511608' ibge_code from dual union
select 'PB' state_code, 'PILÕEZINHOS' city_code, '2511707' ibge_code from dual union
select 'PB' state_code, 'PIRPIRITUBA' city_code, '2511806' ibge_code from dual union
select 'PB' state_code, 'PITIMBU' city_code, '2511905' ibge_code from dual union
select 'PB' state_code, 'POCINHOS' city_code, '2512002' ibge_code from dual union
select 'PB' state_code, 'POCO DANTAS' city_code, '2512036' ibge_code from dual union
select 'PB' state_code, 'POCO DE JOSE DE MOURA' city_code, '2512077' ibge_code from dual union
select 'PB' state_code, 'POMBAL' city_code, '2512101' ibge_code from dual union
select 'PB' state_code, 'PRATA' city_code, '2512200' ibge_code from dual union
select 'PB' state_code, 'PRINCESA ISABEL' city_code, '2512309' ibge_code from dual union
select 'PB' state_code, 'PUXINANA' city_code, '2512408' ibge_code from dual union
select 'PB' state_code, 'QUEIMADAS' city_code, '2512507' ibge_code from dual union
select 'PB' state_code, 'QUIXABA' city_code, '2512606' ibge_code from dual union
select 'PB' state_code, 'REMIGIO' city_code, '2512705' ibge_code from dual union
select 'PB' state_code, 'RIACHAO' city_code, '2512747' ibge_code from dual union
select 'PB' state_code, 'RIACHAO DO BACAMARTE' city_code, '2512754' ibge_code from dual union
select 'PB' state_code, 'RIACHAO DO POCO' city_code, '2512762' ibge_code from dual union
select 'PB' state_code, 'RIACHO DE SANTO ANTONIO' city_code, '2512788' ibge_code from dual union
select 'PB' state_code, 'RIACHO DOS CAVALOS' city_code, '2512804' ibge_code from dual union
select 'PB' state_code, 'RIO TINTO' city_code, '2512903' ibge_code from dual union
select 'PB' state_code, 'SALGADINHO' city_code, '2513000' ibge_code from dual union
select 'PB' state_code, 'SALGADO DE SAO FELIX' city_code, '2513109' ibge_code from dual union
select 'PB' state_code, 'SANTA CECILIA' city_code, '2513158' ibge_code from dual union
select 'PB' state_code, 'SANTA CRUZ' city_code, '2513208' ibge_code from dual union
select 'PB' state_code, 'SANTA HELENA' city_code, '2513307' ibge_code from dual union
select 'PB' state_code, 'SANTA INES' city_code, '2513356' ibge_code from dual union
select 'PB' state_code, 'SANTA LUZIA' city_code, '2513406' ibge_code from dual union
select 'PB' state_code, 'SANTA RITA' city_code, '2513703' ibge_code from dual union
select 'PB' state_code, 'SANTA TERESINHA' city_code, '2513802' ibge_code from dual union
select 'PB' state_code, 'SANTANA DE MANGUEIRA' city_code, '2513505' ibge_code from dual union
select 'PB' state_code, 'SANTANA DOS GARROTES' city_code, '2513604' ibge_code from dual union
select 'PB' state_code, 'SANTO ANDRE' city_code, '2513851' ibge_code from dual union
select 'PB' state_code, 'SAO BENTINHO' city_code, '2513927' ibge_code from dual union
select 'PB' state_code, 'SAO BENTO' city_code, '2513901' ibge_code from dual union
select 'PB' state_code, 'SAO DOMINGOS' city_code, '2513968' ibge_code from dual union
select 'PB' state_code, 'SAO DOMINGOS DO CARIRI' city_code, '2513943' ibge_code from dual union
select 'PB' state_code, 'SAO FRANCISCO' city_code, '2513984' ibge_code from dual union
select 'PB' state_code, 'SAO JOAO DO CARIRI' city_code, '2514008' ibge_code from dual union
select 'PB' state_code, 'SAO JOAO DO RIO DO PEIXE' city_code, '2500700' ibge_code from dual union
select 'PB' state_code, 'SAO JOAO DO TIGRE' city_code, '2514107' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DA LAGOA TAPADA' city_code, '2514206' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DE CAIANA' city_code, '2514305' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DE ESPINHARAS' city_code, '2514404' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DE PIRANHAS' city_code, '2514503' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DE PRINCESA' city_code, '2514552' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DO BONFIM' city_code, '2514602' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DO BREJO DO CRUZ' city_code, '2514651' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DO SABUGI' city_code, '2514701' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DOS CORDEIROS' city_code, '2514800' ibge_code from dual union
select 'PB' state_code, 'SAO JOSE DOS RAMOS' city_code, '2514453' ibge_code from dual union
select 'PB' state_code, 'SAO MAMEDE' city_code, '2514909' ibge_code from dual union
select 'PB' state_code, 'SAO MIGUEL DE TAIPU' city_code, '2515005' ibge_code from dual union
select 'PB' state_code, 'SAO SEBASTIAO DE LAGOA DE ROCA' city_code, '2515104' ibge_code from dual union
select 'PB' state_code, 'SAO SEBASTIAO DO UMBUZEIRO' city_code, '2515203' ibge_code from dual union
select 'PB' state_code, 'SAO VICENTE DO SERIDO' city_code, '2515401' ibge_code from dual union
select 'PB' state_code, 'SAPE' city_code, '2515302' ibge_code from dual union
select 'PB' state_code, 'SERRA BRANCA' city_code, '2515500' ibge_code from dual union
select 'PB' state_code, 'SERRA DA RAIZ' city_code, '2515609' ibge_code from dual union
select 'PB' state_code, 'SERRA GRANDE' city_code, '2515708' ibge_code from dual union
select 'PB' state_code, 'SERRA REDONDA' city_code, '2515807' ibge_code from dual union
select 'PB' state_code, 'SERRARIA' city_code, '2515906' ibge_code from dual union
select 'PB' state_code, 'SERTAOZINHO' city_code, '2515930' ibge_code from dual union
select 'PB' state_code, 'SOBRADO' city_code, '2515971' ibge_code from dual union
select 'PB' state_code, 'SOLANEA' city_code, '2516003' ibge_code from dual union
select 'PB' state_code, 'SOLEDADE' city_code, '2516102' ibge_code from dual union
select 'PB' state_code, 'SOSSEGO' city_code, '2516151' ibge_code from dual union
select 'PB' state_code, 'SOUSA' city_code, '2516201' ibge_code from dual union
select 'PB' state_code, 'SUME' city_code, '2516300' ibge_code from dual union
select 'PB' state_code, 'TACIMA' city_code, '2516409' ibge_code from dual union
select 'PB' state_code, 'TAPEROA' city_code, '2516508' ibge_code from dual union
select 'PB' state_code, 'TAVARES' city_code, '2516607' ibge_code from dual union
select 'PB' state_code, 'TEIXEIRA' city_code, '2516706' ibge_code from dual union
select 'PB' state_code, 'TENORIO' city_code, '2516755' ibge_code from dual union
select 'PB' state_code, 'TRIUNFO' city_code, '2516805' ibge_code from dual union
select 'PB' state_code, 'UIRAUNA' city_code, '2516904' ibge_code from dual union
select 'PB' state_code, 'UMBUZEIRO' city_code, '2517001' ibge_code from dual union
select 'PB' state_code, 'VARZEA' city_code, '2517100' ibge_code from dual union
select 'PB' state_code, 'VIEIROPOLIS' city_code, '2517209' ibge_code from dual union
select 'PB' state_code, 'VISTA SERRANA' city_code, '2505501' ibge_code from dual union
select 'PB' state_code, 'ZABELE' city_code, '2517407' ibge_code from dual union
select 'PE' state_code, 'ABREU E LIMA' city_code, '2600054' ibge_code from dual union
select 'PE' state_code, 'AFOGADOS DA INGAZEIRA' city_code, '2600104' ibge_code from dual union
select 'PE' state_code, 'AFRANIO' city_code, '2600203' ibge_code from dual union
select 'PE' state_code, 'AGRESTINA' city_code, '2600302' ibge_code from dual union
select 'PE' state_code, 'AGUA PRETA' city_code, '2600401' ibge_code from dual union
select 'PE' state_code, 'AGUAS BELAS' city_code, '2600500' ibge_code from dual union
select 'PE' state_code, 'ALAGOINHA' city_code, '2600609' ibge_code from dual union
select 'PE' state_code, 'ALIANCA' city_code, '2600708' ibge_code from dual union
select 'PE' state_code, 'ALTINHO' city_code, '2600807' ibge_code from dual union
select 'PE' state_code, 'AMARAJI' city_code, '2600906' ibge_code from dual union
select 'PE' state_code, 'ANGELIM' city_code, '2601003' ibge_code from dual union
select 'PE' state_code, 'ARACOIABA' city_code, '2601052' ibge_code from dual union
select 'PE' state_code, 'ARARIPINA' city_code, '2601102' ibge_code from dual union
select 'PE' state_code, 'ARCOVERDE' city_code, '2601201' ibge_code from dual union
select 'PE' state_code, 'BARRA DE GUABIRABA' city_code, '2601300' ibge_code from dual union
select 'PE' state_code, 'BARREIROS' city_code, '2601409' ibge_code from dual union
select 'PE' state_code, 'BELEM DE MARIA' city_code, '2601508' ibge_code from dual union
select 'PE' state_code, 'BELEM DO SAO FRANCISCO' city_code, '2601607' ibge_code from dual union
select 'PE' state_code, 'BELO JARDIM' city_code, '2601706' ibge_code from dual union
select 'PE' state_code, 'BETANIA' city_code, '2601805' ibge_code from dual union
select 'PE' state_code, 'BEZERROS' city_code, '2601904' ibge_code from dual union
select 'PE' state_code, 'BODOCO' city_code, '2602001' ibge_code from dual union
select 'PE' state_code, 'BOM CONSELHO' city_code, '2602100' ibge_code from dual union
select 'PE' state_code, 'BOM JARDIM' city_code, '2602209' ibge_code from dual union
select 'PE' state_code, 'BONITO' city_code, '2602308' ibge_code from dual union
select 'PE' state_code, 'BREJAO' city_code, '2602407' ibge_code from dual union
select 'PE' state_code, 'BREJINHO' city_code, '2602506' ibge_code from dual union
select 'PE' state_code, 'BREJO DA MADRE DE DEUS' city_code, '2602605' ibge_code from dual union
select 'PE' state_code, 'BUENOS AIRES' city_code, '2602704' ibge_code from dual union
select 'PE' state_code, 'BUIQUE' city_code, '2602803' ibge_code from dual union
select 'PE' state_code, 'CABO DE SANTO AGOSTINHO' city_code, '2602902' ibge_code from dual union
select 'PE' state_code, 'CABROBO' city_code, '2603009' ibge_code from dual union
select 'PE' state_code, 'CACHOEIRINHA' city_code, '2603108' ibge_code from dual union
select 'PE' state_code, 'CAETES' city_code, '2603207' ibge_code from dual union
select 'PE' state_code, 'CALCADO' city_code, '2603306' ibge_code from dual union
select 'PE' state_code, 'CALUMBI' city_code, '2603405' ibge_code from dual union
select 'PE' state_code, 'CAMARAGIBE' city_code, '2603454' ibge_code from dual union
select 'PE' state_code, 'CAMOCIM DE SAO FELIX' city_code, '2603504' ibge_code from dual union
select 'PE' state_code, 'CAMUTANGA' city_code, '2603603' ibge_code from dual union
select 'PE' state_code, 'CANHOTINHO' city_code, '2603702' ibge_code from dual union
select 'PE' state_code, 'CAPOEIRAS' city_code, '2603801' ibge_code from dual union
select 'PE' state_code, 'CARNAIBA' city_code, '2603900' ibge_code from dual union
select 'PE' state_code, 'CARNAUBEIRA DA PENHA' city_code, '2603926' ibge_code from dual union
select 'PE' state_code, 'CARPINA' city_code, '2604007' ibge_code from dual union
select 'PE' state_code, 'CARUARU' city_code, '2604106' ibge_code from dual union
select 'PE' state_code, 'CASINHAS' city_code, '2604155' ibge_code from dual union
select 'PE' state_code, 'CATENDE' city_code, '2604205' ibge_code from dual union
select 'PE' state_code, 'CEDRO' city_code, '2604304' ibge_code from dual union
select 'PE' state_code, 'CHA DE ALEGRIA' city_code, '2604403' ibge_code from dual union
select 'PE' state_code, 'CHA GRANDE' city_code, '2604502' ibge_code from dual union
select 'PE' state_code, 'CONDADO' city_code, '2604601' ibge_code from dual union
select 'PE' state_code, 'CORRENTES' city_code, '2604700' ibge_code from dual union
select 'PE' state_code, 'CORTES' city_code, '2604809' ibge_code from dual union
select 'PE' state_code, 'CUMARU' city_code, '2604908' ibge_code from dual union
select 'PE' state_code, 'CUPIRA' city_code, '2605004' ibge_code from dual union
select 'PE' state_code, 'CUSTODIA' city_code, '2605103' ibge_code from dual union
select 'PE' state_code, 'DORMENTES' city_code, '2605152' ibge_code from dual union
select 'PE' state_code, 'ESCADA' city_code, '2605202' ibge_code from dual union
select 'PE' state_code, 'EXU' city_code, '2605301' ibge_code from dual union
select 'PE' state_code, 'FEIRA NOVA' city_code, '2605400' ibge_code from dual union
select 'PE' state_code, 'FERNANDO DE NORONHA' city_code, '2605459' ibge_code from dual union
select 'PE' state_code, 'FERREIROS' city_code, '2605509' ibge_code from dual union
select 'PE' state_code, 'FLORES' city_code, '2605608' ibge_code from dual union
select 'PE' state_code, 'FLORESTA' city_code, '2605707' ibge_code from dual union
select 'PE' state_code, 'FREI MIGUELINHO' city_code, '2605806' ibge_code from dual union
select 'PE' state_code, 'GAMELEIRA' city_code, '2605905' ibge_code from dual union
select 'PE' state_code, 'GARANHUNS' city_code, '2606002' ibge_code from dual union
select 'PE' state_code, 'GLORIA DO GOITA' city_code, '2606101' ibge_code from dual union
select 'PE' state_code, 'GOIANA' city_code, '2606200' ibge_code from dual union
select 'PE' state_code, 'GRANITO' city_code, '2606309' ibge_code from dual union
select 'PE' state_code, 'GRAVATA' city_code, '2606408' ibge_code from dual union
select 'PE' state_code, 'IATI' city_code, '2606507' ibge_code from dual union
select 'PE' state_code, 'IBIMIRIM' city_code, '2606606' ibge_code from dual union
select 'PE' state_code, 'IBIRAJUBA' city_code, '2606705' ibge_code from dual union
select 'PE' state_code, 'IGARASSU' city_code, '2606804' ibge_code from dual union
select 'PE' state_code, 'IGUARACY' city_code, '2606903' ibge_code from dual union
select 'PE' state_code, 'ILHA DE ITAMARACA' city_code, '2607604' ibge_code from dual union
select 'PE' state_code, 'INAJA' city_code, '2607000' ibge_code from dual union
select 'PE' state_code, 'INGAZEIRA' city_code, '2607109' ibge_code from dual union
select 'PE' state_code, 'IPOJUCA' city_code, '2607208' ibge_code from dual union
select 'PE' state_code, 'IPUBI' city_code, '2607307' ibge_code from dual union
select 'PE' state_code, 'ITACURUBA' city_code, '2607406' ibge_code from dual union
select 'PE' state_code, 'ITAIBA' city_code, '2607505' ibge_code from dual union
select 'PE' state_code, 'ITAMBE' city_code, '2607653' ibge_code from dual union
select 'PE' state_code, 'ITAPETIM' city_code, '2607703' ibge_code from dual union
select 'PE' state_code, 'ITAPISSUMA' city_code, '2607752' ibge_code from dual union
select 'PE' state_code, 'ITAQUITINGA' city_code, '2607802' ibge_code from dual union
select 'PE' state_code, 'JABOATAO DOS GUARARAPES' city_code, '2607901' ibge_code from dual union
select 'PE' state_code, 'JAQUEIRA' city_code, '2607950' ibge_code from dual union
select 'PE' state_code, 'JATAUBA' city_code, '2608008' ibge_code from dual union
select 'PE' state_code, 'JATOBA' city_code, '2608057' ibge_code from dual union
select 'PE' state_code, 'JOAO ALFREDO' city_code, '2608107' ibge_code from dual union
select 'PE' state_code, 'JOAQUIM NABUCO' city_code, '2608206' ibge_code from dual union
select 'PE' state_code, 'JUCATI' city_code, '2608255' ibge_code from dual union
select 'PE' state_code, 'JUPI' city_code, '2608305' ibge_code from dual union
select 'PE' state_code, 'JUREMA' city_code, '2608404' ibge_code from dual union
select 'PE' state_code, 'LAGOA DE ITAENGA' city_code, '2608503' ibge_code from dual union
select 'PE' state_code, 'LAGOA DO CARRO' city_code, '2608453' ibge_code from dual union
select 'PE' state_code, 'LAGOA DO OURO' city_code, '2608602' ibge_code from dual union
select 'PE' state_code, 'LAGOA DOS GATOS' city_code, '2608701' ibge_code from dual union
select 'PE' state_code, 'LAGOA GRANDE' city_code, '2608750' ibge_code from dual union
select 'PE' state_code, 'LAJEDO' city_code, '2608800' ibge_code from dual union
select 'PE' state_code, 'LIMOEIRO' city_code, '2608909' ibge_code from dual union
select 'PE' state_code, 'MACAPARANA' city_code, '2609006' ibge_code from dual union
select 'PE' state_code, 'MACHADOS' city_code, '2609105' ibge_code from dual union
select 'PE' state_code, 'MANARI' city_code, '2609154' ibge_code from dual union
select 'PE' state_code, 'MARAIAL' city_code, '2609204' ibge_code from dual union
select 'PE' state_code, 'MIRANDIBA' city_code, '2609303' ibge_code from dual union
select 'PE' state_code, 'MOREILANDIA' city_code, '2614303' ibge_code from dual union
select 'PE' state_code, 'MORENO' city_code, '2609402' ibge_code from dual union
select 'PE' state_code, 'NAZARE DA MATA' city_code, '2609501' ibge_code from dual union
select 'PE' state_code, 'OLINDA' city_code, '2609600' ibge_code from dual union
select 'PE' state_code, 'OROBO' city_code, '2609709' ibge_code from dual union
select 'PE' state_code, 'OROCO' city_code, '2609808' ibge_code from dual union
select 'PE' state_code, 'OURICURI' city_code, '2609907' ibge_code from dual union
select 'PE' state_code, 'PALMARES' city_code, '2610004' ibge_code from dual union
select 'PE' state_code, 'PALMEIRINA' city_code, '2610103' ibge_code from dual union
select 'PE' state_code, 'PANELAS' city_code, '2610202' ibge_code from dual union
select 'PE' state_code, 'PARANATAMA' city_code, '2610301' ibge_code from dual union
select 'PE' state_code, 'PARNAMIRIM' city_code, '2610400' ibge_code from dual union
select 'PE' state_code, 'PASSIRA' city_code, '2610509' ibge_code from dual union
select 'PE' state_code, 'PAUDALHO' city_code, '2610608' ibge_code from dual union
select 'PE' state_code, 'PAULISTA' city_code, '2610707' ibge_code from dual union
select 'PE' state_code, 'PEDRA' city_code, '2610806' ibge_code from dual union
select 'PE' state_code, 'PESQUEIRA' city_code, '2610905' ibge_code from dual union
select 'PE' state_code, 'PETROLANDIA' city_code, '2611002' ibge_code from dual union
select 'PE' state_code, 'PETROLINA' city_code, '2611101' ibge_code from dual union
select 'PE' state_code, 'POCAO' city_code, '2611200' ibge_code from dual union
select 'PE' state_code, 'POMBOS' city_code, '2611309' ibge_code from dual union
select 'PE' state_code, 'PRIMAVERA' city_code, '2611408' ibge_code from dual union
select 'PE' state_code, 'QUIPAPA' city_code, '2611507' ibge_code from dual union
select 'PE' state_code, 'QUIXABA' city_code, '2611533' ibge_code from dual union
select 'PE' state_code, 'RECIFE' city_code, '2611606' ibge_code from dual union
select 'PE' state_code, 'RIACHO DAS ALMAS' city_code, '2611705' ibge_code from dual union
select 'PE' state_code, 'RIBEIRAO' city_code, '2611804' ibge_code from dual union
select 'PE' state_code, 'RIO FORMOSO' city_code, '2611903' ibge_code from dual union
select 'PE' state_code, 'SAIRE' city_code, '2612000' ibge_code from dual union
select 'PE' state_code, 'SALGADINHO' city_code, '2612109' ibge_code from dual union
select 'PE' state_code, 'SALGUEIRO' city_code, '2612208' ibge_code from dual union
select 'PE' state_code, 'SALOA' city_code, '2612307' ibge_code from dual union
select 'PE' state_code, 'SANHARO' city_code, '2612406' ibge_code from dual union
select 'PE' state_code, 'SANTA CRUZ' city_code, '2612455' ibge_code from dual union
select 'PE' state_code, 'SANTA CRUZ DA BAIXA VERDE' city_code, '2612471' ibge_code from dual union
select 'PE' state_code, 'SANTA CRUZ DO CAPIBARIBE' city_code, '2612505' ibge_code from dual union
select 'PE' state_code, 'SANTA FILOMENA' city_code, '2612554' ibge_code from dual union
select 'PE' state_code, 'SANTA MARIA DA BOA VISTA' city_code, '2612604' ibge_code from dual union
select 'PE' state_code, 'SANTA MARIA DO CAMBUCA' city_code, '2612703' ibge_code from dual union
select 'PE' state_code, 'SANTA TEREZINHA' city_code, '2612802' ibge_code from dual union
select 'PE' state_code, 'SAO BENEDITO DO SUL' city_code, '2612901' ibge_code from dual union
select 'PE' state_code, 'SAO BENTO DO UNA' city_code, '2613008' ibge_code from dual union
select 'PE' state_code, 'SAO CAITANO' city_code, '2613107' ibge_code from dual union
select 'PE' state_code, 'SAO JOAO' city_code, '2613206' ibge_code from dual union
select 'PE' state_code, 'SAO JOAQUIM DO MONTE' city_code, '2613305' ibge_code from dual union
select 'PE' state_code, 'SAO JOSE DA COROA GRANDE' city_code, '2613404' ibge_code from dual union
select 'PE' state_code, 'SAO JOSE DO BELMONTE' city_code, '2613503' ibge_code from dual union
select 'PE' state_code, 'SAO JOSE DO EGITO' city_code, '2613602' ibge_code from dual union
select 'PE' state_code, 'SAO LOURENCO DA MATA' city_code, '2613701' ibge_code from dual union
select 'PE' state_code, 'SAO VICENTE FERRER' city_code, '2613800' ibge_code from dual union
select 'PE' state_code, 'SERRA TALHADA' city_code, '2613909' ibge_code from dual union
select 'PE' state_code, 'SERRITA' city_code, '2614006' ibge_code from dual union
select 'PE' state_code, 'SERTANIA' city_code, '2614105' ibge_code from dual union
select 'PE' state_code, 'SIRINHAEM' city_code, '2614204' ibge_code from dual union
select 'PE' state_code, 'SOLIDAO' city_code, '2614402' ibge_code from dual union
select 'PE' state_code, 'SURUBIM' city_code, '2614501' ibge_code from dual union
select 'PE' state_code, 'TABIRA' city_code, '2614600' ibge_code from dual union
select 'PE' state_code, 'TACAIMBO' city_code, '2614709' ibge_code from dual union
select 'PE' state_code, 'TACARATU' city_code, '2614808' ibge_code from dual union
select 'PE' state_code, 'TAMANDARE' city_code, '2614857' ibge_code from dual union
select 'PE' state_code, 'TAQUARITINGA DO NORTE' city_code, '2615003' ibge_code from dual union
select 'PE' state_code, 'TEREZINHA' city_code, '2615102' ibge_code from dual union
select 'PE' state_code, 'TERRA NOVA' city_code, '2615201' ibge_code from dual union
select 'PE' state_code, 'TIMBAUBA' city_code, '2615300' ibge_code from dual union
select 'PE' state_code, 'TORITAMA' city_code, '2615409' ibge_code from dual union
select 'PE' state_code, 'TRACUNHAEM' city_code, '2615508' ibge_code from dual union
select 'PE' state_code, 'TRINDADE' city_code, '2615607' ibge_code from dual union
select 'PE' state_code, 'TRIUNFO' city_code, '2615706' ibge_code from dual union
select 'PE' state_code, 'TUPANATINGA' city_code, '2615805' ibge_code from dual union
select 'PE' state_code, 'TUPARETAMA' city_code, '2615904' ibge_code from dual union
select 'PE' state_code, 'VENTUROSA' city_code, '2616001' ibge_code from dual union
select 'PE' state_code, 'VERDEJANTE' city_code, '2616100' ibge_code from dual union
select 'PE' state_code, 'VERTENTE DO LERIO' city_code, '2616183' ibge_code from dual union
select 'PE' state_code, 'VERTENTES' city_code, '2616209' ibge_code from dual union
select 'PE' state_code, 'VICENCIA' city_code, '2616308' ibge_code from dual union
select 'PE' state_code, 'VITORIA DE SANTO ANTAO' city_code, '2616407' ibge_code from dual union
select 'PE' state_code, 'XEXEU' city_code, '2616506' ibge_code from dual union
select 'AL' state_code, 'AGUA BRANCA' city_code, '2700102' ibge_code from dual union
select 'AL' state_code, 'ANADIA' city_code, '2700201' ibge_code from dual union
select 'AL' state_code, 'ARAPIRACA' city_code, '2700300' ibge_code from dual union
select 'AL' state_code, 'ATALAIA' city_code, '2700409' ibge_code from dual union
select 'AL' state_code, 'BARRA DE SANTO ANTONIO' city_code, '2700508' ibge_code from dual union
select 'AL' state_code, 'BARRA DE SAO MIGUEL' city_code, '2700607' ibge_code from dual union
select 'AL' state_code, 'BATALHA' city_code, '2700706' ibge_code from dual union
select 'AL' state_code, 'BELEM' city_code, '2700805' ibge_code from dual union
select 'AL' state_code, 'BELO MONTE' city_code, '2700904' ibge_code from dual union
select 'AL' state_code, 'BOCA DA MATA' city_code, '2701001' ibge_code from dual union
select 'AL' state_code, 'BRANQUINHA' city_code, '2701100' ibge_code from dual union
select 'AL' state_code, 'CACIMBINHAS' city_code, '2701209' ibge_code from dual union
select 'AL' state_code, 'CAJUEIRO' city_code, '2701308' ibge_code from dual union
select 'AL' state_code, 'CAMPESTRE' city_code, '2701357' ibge_code from dual union
select 'AL' state_code, 'CAMPO ALEGRE' city_code, '2701407' ibge_code from dual union
select 'AL' state_code, 'CAMPO GRANDE' city_code, '2701506' ibge_code from dual union
select 'AL' state_code, 'CANAPI' city_code, '2701605' ibge_code from dual union
select 'AL' state_code, 'CAPELA' city_code, '2701704' ibge_code from dual union
select 'AL' state_code, 'CARNEIROS' city_code, '2701803' ibge_code from dual union
select 'AL' state_code, 'CHA PRETA' city_code, '2701902' ibge_code from dual union
select 'AL' state_code, 'COITE DO NOIA' city_code, '2702009' ibge_code from dual union
select 'AL' state_code, 'COLONIA LEOPOLDINA' city_code, '2702108' ibge_code from dual union
select 'AL' state_code, 'COQUEIRO SECO' city_code, '2702207' ibge_code from dual union
select 'AL' state_code, 'CORURIPE' city_code, '2702306' ibge_code from dual union
select 'AL' state_code, 'CRAIBAS' city_code, '2702355' ibge_code from dual union
select 'AL' state_code, 'DELMIRO GOUVEIA' city_code, '2702405' ibge_code from dual union
select 'AL' state_code, 'DOIS RIACHOS' city_code, '2702504' ibge_code from dual union
select 'AL' state_code, 'ESTRELA DE ALAGOAS' city_code, '2702553' ibge_code from dual union
select 'AL' state_code, 'FEIRA GRANDE' city_code, '2702603' ibge_code from dual union
select 'AL' state_code, 'FELIZ DESERTO' city_code, '2702702' ibge_code from dual union
select 'AL' state_code, 'FLEXEIRAS' city_code, '2702801' ibge_code from dual union
select 'AL' state_code, 'GIRAU DO PONCIANO' city_code, '2702900' ibge_code from dual union
select 'AL' state_code, 'IBATEGUARA' city_code, '2703007' ibge_code from dual union
select 'AL' state_code, 'IGACI' city_code, '2703106' ibge_code from dual union
select 'AL' state_code, 'IGREJA NOVA' city_code, '2703205' ibge_code from dual union
select 'AL' state_code, 'INHAPI' city_code, '2703304' ibge_code from dual union
select 'AL' state_code, 'JACARE DOS HOMENS' city_code, '2703403' ibge_code from dual union
select 'AL' state_code, 'JACUIPE' city_code, '2703502' ibge_code from dual union
select 'AL' state_code, 'JAPARATINGA' city_code, '2703601' ibge_code from dual union
select 'AL' state_code, 'JARAMATAIA' city_code, '2703700' ibge_code from dual union
select 'AL' state_code, 'JEQUIA DA PRAIA' city_code, '2703759' ibge_code from dual union
select 'AL' state_code, 'JOAQUIM GOMES' city_code, '2703809' ibge_code from dual union
select 'AL' state_code, 'JUNDIA' city_code, '2703908' ibge_code from dual union
select 'AL' state_code, 'JUNQUEIRO' city_code, '2704005' ibge_code from dual union
select 'AL' state_code, 'LAGOA DA CANOA' city_code, '2704104' ibge_code from dual union
select 'AL' state_code, 'LIMOEIRO DE ANADIA' city_code, '2704203' ibge_code from dual union
select 'AL' state_code, 'MACEIO' city_code, '2704302' ibge_code from dual union
select 'AL' state_code, 'MAJOR ISIDORO' city_code, '2704401' ibge_code from dual union
select 'AL' state_code, 'MAR VERMELHO' city_code, '2704906' ibge_code from dual union
select 'AL' state_code, 'MARAGOGI' city_code, '2704500' ibge_code from dual union
select 'AL' state_code, 'MARAVILHA' city_code, '2704609' ibge_code from dual union
select 'AL' state_code, 'MARECHAL DEODORO' city_code, '2704708' ibge_code from dual union
select 'AL' state_code, 'MARIBONDO' city_code, '2704807' ibge_code from dual union
select 'AL' state_code, 'MATA GRANDE' city_code, '2705002' ibge_code from dual union
select 'AL' state_code, 'MATRIZ DE CAMARAGIBE' city_code, '2705101' ibge_code from dual union
select 'AL' state_code, 'MESSIAS' city_code, '2705200' ibge_code from dual union
select 'AL' state_code, 'MINADOR DO NEGRAO' city_code, '2705309' ibge_code from dual union
select 'AL' state_code, 'MONTEIROPOLIS' city_code, '2705408' ibge_code from dual union
select 'AL' state_code, 'MURICI' city_code, '2705507' ibge_code from dual union
select 'AL' state_code, 'NOVO LINO' city_code, '2705606' ibge_code from dual union
select 'AL' state_code, 'OLHO D''AGUA DAS FLORES' city_code, '2705705' ibge_code from dual union
select 'AL' state_code, 'OLHO D''AGUA DO CASADO' city_code, '2705804' ibge_code from dual union
select 'AL' state_code, 'OLHO D''AGUA GRANDE' city_code, '2705903' ibge_code from dual union
select 'AL' state_code, 'OLIVENCA' city_code, '2706000' ibge_code from dual union
select 'AL' state_code, 'OURO BRANCO' city_code, '2706109' ibge_code from dual union
select 'AL' state_code, 'PALESTINA' city_code, '2706208' ibge_code from dual union
select 'AL' state_code, 'PALMEIRA DOS INDIOS' city_code, '2706307' ibge_code from dual union
select 'AL' state_code, 'PAO DE ACUCAR' city_code, '2706406' ibge_code from dual union
select 'AL' state_code, 'PARICONHA' city_code, '2706422' ibge_code from dual union
select 'AL' state_code, 'PARIPUEIRA' city_code, '2706448' ibge_code from dual union
select 'AL' state_code, 'PASSO DE CAMARAGIBE' city_code, '2706505' ibge_code from dual union
select 'AL' state_code, 'PAULO JACINTO' city_code, '2706604' ibge_code from dual union
select 'AL' state_code, 'PENEDO' city_code, '2706703' ibge_code from dual union
select 'AL' state_code, 'PIACABUCU' city_code, '2706802' ibge_code from dual union
select 'AL' state_code, 'PILAR' city_code, '2706901' ibge_code from dual union
select 'AL' state_code, 'PINDOBA' city_code, '2707008' ibge_code from dual union
select 'AL' state_code, 'PIRANHAS' city_code, '2707107' ibge_code from dual union
select 'AL' state_code, 'POCO DAS TRINCHEIRAS' city_code, '2707206' ibge_code from dual union
select 'AL' state_code, 'PORTO CALVO' city_code, '2707305' ibge_code from dual union
select 'AL' state_code, 'PORTO DE PEDRAS' city_code, '2707404' ibge_code from dual union
select 'AL' state_code, 'PORTO REAL DO COLEGIO' city_code, '2707503' ibge_code from dual union
select 'AL' state_code, 'QUEBRANGULO' city_code, '2707602' ibge_code from dual union
select 'AL' state_code, 'RIO LARGO' city_code, '2707701' ibge_code from dual union
select 'AL' state_code, 'ROTEIRO' city_code, '2707800' ibge_code from dual union
select 'AL' state_code, 'SANTA LUZIA DO NORTE' city_code, '2707909' ibge_code from dual union
select 'AL' state_code, 'SANTANA DO IPANEMA' city_code, '2708006' ibge_code from dual union
select 'AL' state_code, 'SANTANA DO MUNDAU' city_code, '2708105' ibge_code from dual union
select 'AL' state_code, 'SAO BRAS' city_code, '2708204' ibge_code from dual union
select 'AL' state_code, 'SAO JOSE DA LAJE' city_code, '2708303' ibge_code from dual union
select 'AL' state_code, 'SAO JOSE DA TAPERA' city_code, '2708402' ibge_code from dual union
select 'AL' state_code, 'SAO LUIS DO QUITUNDE' city_code, '2708501' ibge_code from dual union
select 'AL' state_code, 'SAO MIGUEL DOS CAMPOS' city_code, '2708600' ibge_code from dual union
select 'AL' state_code, 'SAO MIGUEL DOS MILAGRES' city_code, '2708709' ibge_code from dual union
select 'AL' state_code, 'SAO SEBASTIAO' city_code, '2708808' ibge_code from dual union
select 'AL' state_code, 'SATUBA' city_code, '2708907' ibge_code from dual union
select 'AL' state_code, 'SENADOR RUI PALMEIRA' city_code, '2708956' ibge_code from dual union
select 'AL' state_code, 'TANQUE D''ARCA' city_code, '2709004' ibge_code from dual union
select 'AL' state_code, 'TAQUARANA' city_code, '2709103' ibge_code from dual union
select 'AL' state_code, 'TEOTONIO VILELA' city_code, '2709152' ibge_code from dual union
select 'AL' state_code, 'TRAIPU' city_code, '2709202' ibge_code from dual union
select 'AL' state_code, 'UNIAO DOS PALMARES' city_code, '2709301' ibge_code from dual union
select 'AL' state_code, 'VICOSA' city_code, '2709400' ibge_code from dual union
select 'SE' state_code, 'AMPARO DE SAO FRANCISCO' city_code, '2800100' ibge_code from dual union
select 'SE' state_code, 'AQUIDABA' city_code, '2800209' ibge_code from dual union
select 'SE' state_code, 'ARACAJU' city_code, '2800308' ibge_code from dual union
select 'SE' state_code, 'ARAUA' city_code, '2800407' ibge_code from dual union
select 'SE' state_code, 'AREIA BRANCA' city_code, '2800506' ibge_code from dual union
select 'SE' state_code, 'BARRA DOS COQUEIROS' city_code, '2800605' ibge_code from dual union
select 'SE' state_code, 'BOQUIM' city_code, '2800670' ibge_code from dual union
select 'SE' state_code, 'BREJO GRANDE' city_code, '2800704' ibge_code from dual union
select 'SE' state_code, 'CAMPO DO BRITO' city_code, '2801009' ibge_code from dual union
select 'SE' state_code, 'CANHOBA' city_code, '2801108' ibge_code from dual union
select 'SE' state_code, 'CANINDE DE SAO FRANCISCO' city_code, '2801207' ibge_code from dual union
select 'SE' state_code, 'CAPELA' city_code, '2801306' ibge_code from dual union
select 'SE' state_code, 'CARIRA' city_code, '2801405' ibge_code from dual union
select 'SE' state_code, 'CARMOPOLIS' city_code, '2801504' ibge_code from dual union
select 'SE' state_code, 'CEDRO DE SAO JOAO' city_code, '2801603' ibge_code from dual union
select 'SE' state_code, 'CRISTINAPOLIS' city_code, '2801702' ibge_code from dual union
select 'SE' state_code, 'CUMBE' city_code, '2801900' ibge_code from dual union
select 'SE' state_code, 'DIVINA PASTORA' city_code, '2802007' ibge_code from dual union
select 'SE' state_code, 'ESTANCIA' city_code, '2802106' ibge_code from dual union
select 'SE' state_code, 'FEIRA NOVA' city_code, '2802205' ibge_code from dual union
select 'SE' state_code, 'FREI PAULO' city_code, '2802304' ibge_code from dual union
select 'SE' state_code, 'GARARU' city_code, '2802403' ibge_code from dual union
select 'SE' state_code, 'GENERAL MAYNARD' city_code, '2802502' ibge_code from dual union
select 'SE' state_code, 'GRACHO CARDOSO' city_code, '2802601' ibge_code from dual union
select 'SE' state_code, 'ILHA DAS FLORES' city_code, '2802700' ibge_code from dual union
select 'SE' state_code, 'INDIAROBA' city_code, '2802809' ibge_code from dual union
select 'SE' state_code, 'ITABAIANA' city_code, '2802908' ibge_code from dual union
select 'SE' state_code, 'ITABAIANINHA' city_code, '2803005' ibge_code from dual union
select 'SE' state_code, 'ITABI' city_code, '2803104' ibge_code from dual union
select 'SE' state_code, 'ITAPORANGA D''AJUDA' city_code, '2803203' ibge_code from dual union
select 'SE' state_code, 'JAPARATUBA' city_code, '2803302' ibge_code from dual union
select 'SE' state_code, 'JAPOATA' city_code, '2803401' ibge_code from dual union
select 'SE' state_code, 'LAGARTO' city_code, '2803500' ibge_code from dual union
select 'SE' state_code, 'LARANJEIRAS' city_code, '2803609' ibge_code from dual union
select 'SE' state_code, 'MACAMBIRA' city_code, '2803708' ibge_code from dual union
select 'SE' state_code, 'MALHADA DOS BOIS' city_code, '2803807' ibge_code from dual union
select 'SE' state_code, 'MALHADOR' city_code, '2803906' ibge_code from dual union
select 'SE' state_code, 'MARUIM' city_code, '2804003' ibge_code from dual union
select 'SE' state_code, 'MOITA BONITA' city_code, '2804102' ibge_code from dual union
select 'SE' state_code, 'MONTE ALEGRE DE SERGIPE' city_code, '2804201' ibge_code from dual union
select 'SE' state_code, 'MURIBECA' city_code, '2804300' ibge_code from dual union
select 'SE' state_code, 'NEOPOLIS' city_code, '2804409' ibge_code from dual union
select 'SE' state_code, 'NOSSA SENHORA APARECIDA' city_code, '2804458' ibge_code from dual union
select 'SE' state_code, 'NOSSA SENHORA DA GLORIA' city_code, '2804508' ibge_code from dual union
select 'SE' state_code, 'NOSSA SENHORA DAS DORES' city_code, '2804607' ibge_code from dual union
select 'SE' state_code, 'NOSSA SENHORA DE LOURDES' city_code, '2804706' ibge_code from dual union
select 'SE' state_code, 'NOSSA SENHORA DO SOCORRO' city_code, '2804805' ibge_code from dual union
select 'SE' state_code, 'PACATUBA' city_code, '2804904' ibge_code from dual union
select 'SE' state_code, 'PEDRA MOLE' city_code, '2805000' ibge_code from dual union
select 'SE' state_code, 'PEDRINHAS' city_code, '2805109' ibge_code from dual union
select 'SE' state_code, 'PINHAO' city_code, '2805208' ibge_code from dual union
select 'SE' state_code, 'PIRAMBU' city_code, '2805307' ibge_code from dual union
select 'SE' state_code, 'POCO REDONDO' city_code, '2805406' ibge_code from dual union
select 'SE' state_code, 'POCO VERDE' city_code, '2805505' ibge_code from dual union
select 'SE' state_code, 'PORTO DA FOLHA' city_code, '2805604' ibge_code from dual union
select 'SE' state_code, 'PROPRIA' city_code, '2805703' ibge_code from dual union
select 'SE' state_code, 'RIACHAO DO DANTAS' city_code, '2805802' ibge_code from dual union
select 'SE' state_code, 'RIACHUELO' city_code, '2805901' ibge_code from dual union
select 'SE' state_code, 'RIBEIROPOLIS' city_code, '2806008' ibge_code from dual union
select 'SE' state_code, 'ROSARIO DO CATETE' city_code, '2806107' ibge_code from dual union
select 'SE' state_code, 'SALGADO' city_code, '2806206' ibge_code from dual union
select 'SE' state_code, 'SANTA LUZIA DO ITANHY' city_code, '2806305' ibge_code from dual union
select 'SE' state_code, 'SANTA ROSA DE LIMA' city_code, '2806503' ibge_code from dual union
select 'SE' state_code, 'SANTANA DO SAO FRANCISCO' city_code, '2806404' ibge_code from dual union
select 'SE' state_code, 'SANTO AMARO DAS BROTAS' city_code, '2806602' ibge_code from dual union
select 'SE' state_code, 'SAO CRISTOVAO' city_code, '2806701' ibge_code from dual union
select 'SE' state_code, 'SAO DOMINGOS' city_code, '2806800' ibge_code from dual union
select 'SE' state_code, 'SAO FRANCISCO' city_code, '2806909' ibge_code from dual union
select 'SE' state_code, 'SAO MIGUEL DO ALEIXO' city_code, '2807006' ibge_code from dual union
select 'SE' state_code, 'SIMAO DIAS' city_code, '2807105' ibge_code from dual union
select 'SE' state_code, 'SIRIRI' city_code, '2807204' ibge_code from dual union
select 'SE' state_code, 'TELHA' city_code, '2807303' ibge_code from dual union
select 'SE' state_code, 'TOBIAS BARRETO' city_code, '2807402' ibge_code from dual union
select 'SE' state_code, 'TOMAR DO GERU' city_code, '2807501' ibge_code from dual union
select 'SE' state_code, 'UMBAUBA' city_code, '2807600' ibge_code from dual union
select 'BA' state_code, 'ABAIRA' city_code, '2900108' ibge_code from dual union
select 'BA' state_code, 'ABARE' city_code, '2900207' ibge_code from dual union
select 'BA' state_code, 'ACAJUTIBA' city_code, '2900306' ibge_code from dual union
select 'BA' state_code, 'ADUSTINA' city_code, '2900355' ibge_code from dual union
select 'BA' state_code, 'AGUA FRIA' city_code, '2900405' ibge_code from dual union
select 'BA' state_code, 'AIQUARA' city_code, '2900603' ibge_code from dual union
select 'BA' state_code, 'ALAGOINHAS' city_code, '2900702' ibge_code from dual union
select 'BA' state_code, 'ALCOBACA' city_code, '2900801' ibge_code from dual union
select 'BA' state_code, 'ALMADINA' city_code, '2900900' ibge_code from dual union
select 'BA' state_code, 'AMARGOSA' city_code, '2901007' ibge_code from dual union
select 'BA' state_code, 'AMELIA RODRIGUES' city_code, '2901106' ibge_code from dual union
select 'BA' state_code, 'AMERICA DOURADA' city_code, '2901155' ibge_code from dual union
select 'BA' state_code, 'ANAGE' city_code, '2901205' ibge_code from dual union
select 'BA' state_code, 'ANDARAI' city_code, '2901304' ibge_code from dual union
select 'BA' state_code, 'ANDORINHA' city_code, '2901353' ibge_code from dual union
select 'BA' state_code, 'ANGICAL' city_code, '2901403' ibge_code from dual union
select 'BA' state_code, 'ANGUERA' city_code, '2901502' ibge_code from dual union
select 'BA' state_code, 'ANTAS' city_code, '2901601' ibge_code from dual union
select 'BA' state_code, 'ANTONIO CARDOSO' city_code, '2901700' ibge_code from dual union
select 'BA' state_code, 'ANTONIO GONCALVES' city_code, '2901809' ibge_code from dual union
select 'BA' state_code, 'APORA' city_code, '2901908' ibge_code from dual union
select 'BA' state_code, 'APUAREMA' city_code, '2901957' ibge_code from dual union
select 'BA' state_code, 'ARACAS' city_code, '2902054' ibge_code from dual union
select 'BA' state_code, 'ARACATU' city_code, '2902005' ibge_code from dual union
select 'BA' state_code, 'ARACI' city_code, '2902104' ibge_code from dual union
select 'BA' state_code, 'ARAMARI' city_code, '2902203' ibge_code from dual union
select 'BA' state_code, 'ARATACA' city_code, '2902252' ibge_code from dual union
select 'BA' state_code, 'ARATUIPE' city_code, '2902302' ibge_code from dual union
select 'BA' state_code, 'AURELINO LEAL' city_code, '2902401' ibge_code from dual union
select 'BA' state_code, 'BAIANOPOLIS' city_code, '2902500' ibge_code from dual union
select 'BA' state_code, 'BAIXA GRANDE' city_code, '2902609' ibge_code from dual union
select 'BA' state_code, 'BANZAE' city_code, '2902658' ibge_code from dual union
select 'BA' state_code, 'BARRA' city_code, '2902708' ibge_code from dual union
select 'BA' state_code, 'BARRA DA ESTIVA' city_code, '2902807' ibge_code from dual union
select 'BA' state_code, 'BARRA DO CHOCA' city_code, '2902906' ibge_code from dual union
select 'BA' state_code, 'BARRA DO MENDES' city_code, '2903003' ibge_code from dual union
select 'BA' state_code, 'BARRA DO ROCHA' city_code, '2903102' ibge_code from dual union
select 'BA' state_code, 'BARREIRAS' city_code, '2903201' ibge_code from dual union
select 'BA' state_code, 'BARRO ALTO' city_code, '2903235' ibge_code from dual union
select 'BA' state_code, 'BARRO PRETO' city_code, '2903300' ibge_code from dual union
select 'BA' state_code, 'BARROCAS' city_code, '2903276' ibge_code from dual union
select 'BA' state_code, 'BELMONTE' city_code, '2903409' ibge_code from dual union
select 'BA' state_code, 'BELO CAMPO' city_code, '2903508' ibge_code from dual union
select 'BA' state_code, 'BIRITINGA' city_code, '2903607' ibge_code from dual union
select 'BA' state_code, 'BOA NOVA' city_code, '2903706' ibge_code from dual union
select 'BA' state_code, 'BOA VISTA DO TUPIM' city_code, '2903805' ibge_code from dual union
select 'BA' state_code, 'BOM JESUS DA LAPA' city_code, '2903904' ibge_code from dual union
select 'BA' state_code, 'BOM JESUS DA SERRA' city_code, '2903953' ibge_code from dual union
select 'BA' state_code, 'BONINAL' city_code, '2904001' ibge_code from dual union
select 'BA' state_code, 'BONITO' city_code, '2904050' ibge_code from dual union
select 'BA' state_code, 'BOQUIRA' city_code, '2904100' ibge_code from dual union
select 'BA' state_code, 'BOTUPORA' city_code, '2904209' ibge_code from dual union
select 'BA' state_code, 'BREJÕES' city_code, '2904308' ibge_code from dual union
select 'BA' state_code, 'BREJOLANDIA' city_code, '2904407' ibge_code from dual union
select 'BA' state_code, 'BROTAS DE MACAUBAS' city_code, '2904506' ibge_code from dual union
select 'BA' state_code, 'BRUMADO' city_code, '2904605' ibge_code from dual union
select 'BA' state_code, 'BUERAREMA' city_code, '2904704' ibge_code from dual union
select 'BA' state_code, 'BURITIRAMA' city_code, '2904753' ibge_code from dual union
select 'BA' state_code, 'CAATIBA' city_code, '2904803' ibge_code from dual union
select 'BA' state_code, 'CABACEIRAS DO PARAGUACU' city_code, '2904852' ibge_code from dual union
select 'BA' state_code, 'CACHOEIRA' city_code, '2904902' ibge_code from dual union
select 'BA' state_code, 'CACULE' city_code, '2905008' ibge_code from dual union
select 'BA' state_code, 'CAEM' city_code, '2905107' ibge_code from dual union
select 'BA' state_code, 'CAETANOS' city_code, '2905156' ibge_code from dual union
select 'BA' state_code, 'CAETITE' city_code, '2905206' ibge_code from dual union
select 'BA' state_code, 'CAFARNAUM' city_code, '2905305' ibge_code from dual union
select 'BA' state_code, 'CAIRU' city_code, '2905404' ibge_code from dual union
select 'BA' state_code, 'CALDEIRAO GRANDE' city_code, '2905503' ibge_code from dual union
select 'BA' state_code, 'CAMACAN' city_code, '2905602' ibge_code from dual union
select 'BA' state_code, 'CAMACARI' city_code, '2905701' ibge_code from dual union
select 'BA' state_code, 'CAMAMU' city_code, '2905800' ibge_code from dual union
select 'BA' state_code, 'CAMPO ALEGRE DE LOURDES' city_code, '2905909' ibge_code from dual union
select 'BA' state_code, 'CAMPO FORMOSO' city_code, '2906006' ibge_code from dual union
select 'BA' state_code, 'CANAPOLIS' city_code, '2906105' ibge_code from dual union
select 'BA' state_code, 'CANARANA' city_code, '2906204' ibge_code from dual union
select 'BA' state_code, 'CANAVIEIRAS' city_code, '2906303' ibge_code from dual union
select 'BA' state_code, 'CANDEAL' city_code, '2906402' ibge_code from dual union
select 'BA' state_code, 'CANDEIAS' city_code, '2906501' ibge_code from dual union
select 'BA' state_code, 'CANDIBA' city_code, '2906600' ibge_code from dual union
select 'BA' state_code, 'CANDIDO SALES' city_code, '2906709' ibge_code from dual union
select 'BA' state_code, 'CANSANCAO' city_code, '2906808' ibge_code from dual union
select 'BA' state_code, 'CANUDOS' city_code, '2906824' ibge_code from dual union
select 'BA' state_code, 'CAPELA DO ALTO ALEGRE' city_code, '2906857' ibge_code from dual union
select 'BA' state_code, 'CAPIM GROSSO' city_code, '2906873' ibge_code from dual union
select 'BA' state_code, 'CARAIBAS' city_code, '2906899' ibge_code from dual union
select 'BA' state_code, 'CARAVELAS' city_code, '2906907' ibge_code from dual union
select 'BA' state_code, 'CARDEAL DA SILVA' city_code, '2907004' ibge_code from dual union
select 'BA' state_code, 'CARINHANHA' city_code, '2907103' ibge_code from dual union
select 'BA' state_code, 'CASA NOVA' city_code, '2907202' ibge_code from dual union
select 'BA' state_code, 'CASTRO ALVES' city_code, '2907301' ibge_code from dual union
select 'BA' state_code, 'CATOLANDIA' city_code, '2907400' ibge_code from dual union
select 'BA' state_code, 'CATU' city_code, '2907509' ibge_code from dual union
select 'BA' state_code, 'CATURAMA' city_code, '2907558' ibge_code from dual union
select 'BA' state_code, 'CENTRAL' city_code, '2907608' ibge_code from dual union
select 'BA' state_code, 'CHORROCHO' city_code, '2907707' ibge_code from dual union
select 'BA' state_code, 'CICERO DANTAS' city_code, '2907806' ibge_code from dual union
select 'BA' state_code, 'CIPO' city_code, '2907905' ibge_code from dual union
select 'BA' state_code, 'COARACI' city_code, '2908002' ibge_code from dual union
select 'BA' state_code, 'COCOS' city_code, '2908101' ibge_code from dual union
select 'BA' state_code, 'CONCEICAO DA FEIRA' city_code, '2908200' ibge_code from dual union
select 'BA' state_code, 'CONCEICAO DO ALMEIDA' city_code, '2908309' ibge_code from dual union
select 'BA' state_code, 'CONCEICAO DO COITE' city_code, '2908408' ibge_code from dual union
select 'BA' state_code, 'CONCEICAO DO JACUIPE' city_code, '2908507' ibge_code from dual union
select 'BA' state_code, 'CONDE' city_code, '2908606' ibge_code from dual union
select 'BA' state_code, 'CONDEUBA' city_code, '2908705' ibge_code from dual union
select 'BA' state_code, 'CONTENDAS DO SINCORA' city_code, '2908804' ibge_code from dual union
select 'BA' state_code, 'CORACAO DE MARIA' city_code, '2908903' ibge_code from dual union
select 'BA' state_code, 'CORDEIROS' city_code, '2909000' ibge_code from dual union
select 'BA' state_code, 'CORIBE' city_code, '2909109' ibge_code from dual union
select 'BA' state_code, 'CORONEL JOAO SA' city_code, '2909208' ibge_code from dual union
select 'BA' state_code, 'CORRENTINA' city_code, '2909307' ibge_code from dual union
select 'BA' state_code, 'COTEGIPE' city_code, '2909406' ibge_code from dual union
select 'BA' state_code, 'CRAVOLANDIA' city_code, '2909505' ibge_code from dual union
select 'BA' state_code, 'CRISOPOLIS' city_code, '2909604' ibge_code from dual union
select 'BA' state_code, 'CRISTOPOLIS' city_code, '2909703' ibge_code from dual union
select 'BA' state_code, 'CRUZ DAS ALMAS' city_code, '2909802' ibge_code from dual union
select 'BA' state_code, 'CURACA' city_code, '2909901' ibge_code from dual union
select 'BA' state_code, 'DARIO MEIRA' city_code, '2910008' ibge_code from dual union
select 'BA' state_code, 'DIAS D''AVILA' city_code, '2910057' ibge_code from dual union
select 'BA' state_code, 'DOM BASILIO' city_code, '2910107' ibge_code from dual union
select 'BA' state_code, 'DOM MACEDO COSTA' city_code, '2910206' ibge_code from dual union
select 'BA' state_code, 'ELISIO MEDRADO' city_code, '2910305' ibge_code from dual union
select 'BA' state_code, 'ENCRUZILHADA' city_code, '2910404' ibge_code from dual union
select 'BA' state_code, 'ENTRE RIOS' city_code, '2910503' ibge_code from dual union
select 'BA' state_code, 'ERICO CARDOSO' city_code, '2900504' ibge_code from dual union
select 'BA' state_code, 'ESPLANADA' city_code, '2910602' ibge_code from dual union
select 'BA' state_code, 'EUCLIDES DA CUNHA' city_code, '2910701' ibge_code from dual union
select 'BA' state_code, 'EUNAPOLIS' city_code, '2910727' ibge_code from dual union
select 'BA' state_code, 'FATIMA' city_code, '2910750' ibge_code from dual union
select 'BA' state_code, 'FEIRA DA MATA' city_code, '2910776' ibge_code from dual union
select 'BA' state_code, 'FEIRA DE SANTANA' city_code, '2910800' ibge_code from dual union
select 'BA' state_code, 'FILADELFIA' city_code, '2910859' ibge_code from dual union
select 'BA' state_code, 'FIRMINO ALVES' city_code, '2910909' ibge_code from dual union
select 'BA' state_code, 'FLORESTA AZUL' city_code, '2911006' ibge_code from dual union
select 'BA' state_code, 'FORMOSA DO RIO PRETO' city_code, '2911105' ibge_code from dual union
select 'BA' state_code, 'GANDU' city_code, '2911204' ibge_code from dual union
select 'BA' state_code, 'GAVIAO' city_code, '2911253' ibge_code from dual union
select 'BA' state_code, 'GENTIO DO OURO' city_code, '2911303' ibge_code from dual union
select 'BA' state_code, 'GLORIA' city_code, '2911402' ibge_code from dual union
select 'BA' state_code, 'GONGOGI' city_code, '2911501' ibge_code from dual union
select 'BA' state_code, 'GOVERNADOR MANGABEIRA' city_code, '2911600' ibge_code from dual union
select 'BA' state_code, 'GUAJERU' city_code, '2911659' ibge_code from dual union
select 'BA' state_code, 'GUANAMBI' city_code, '2911709' ibge_code from dual union
select 'BA' state_code, 'GUARATINGA' city_code, '2911808' ibge_code from dual union
select 'BA' state_code, 'HELIOPOLIS' city_code, '2911857' ibge_code from dual union
select 'BA' state_code, 'IACU' city_code, '2911907' ibge_code from dual union
select 'BA' state_code, 'IBIASSUCE' city_code, '2912004' ibge_code from dual union
select 'BA' state_code, 'IBICARAI' city_code, '2912103' ibge_code from dual union
select 'BA' state_code, 'IBICOARA' city_code, '2912202' ibge_code from dual union
select 'BA' state_code, 'IBICUI' city_code, '2912301' ibge_code from dual union
select 'BA' state_code, 'IBIPEBA' city_code, '2912400' ibge_code from dual union
select 'BA' state_code, 'IBIPITANGA' city_code, '2912509' ibge_code from dual union
select 'BA' state_code, 'IBIQUERA' city_code, '2912608' ibge_code from dual union
select 'BA' state_code, 'IBIRAPITANGA' city_code, '2912707' ibge_code from dual union
select 'BA' state_code, 'IBIRAPUA' city_code, '2912806' ibge_code from dual union
select 'BA' state_code, 'IBIRATAIA' city_code, '2912905' ibge_code from dual union
select 'BA' state_code, 'IBITIARA' city_code, '2913002' ibge_code from dual union
select 'BA' state_code, 'IBITITA' city_code, '2913101' ibge_code from dual union
select 'BA' state_code, 'IBOTIRAMA' city_code, '2913200' ibge_code from dual union
select 'BA' state_code, 'ICHU' city_code, '2913309' ibge_code from dual union
select 'BA' state_code, 'IGAPORA' city_code, '2913408' ibge_code from dual union
select 'BA' state_code, 'IGRAPIUNA' city_code, '2913457' ibge_code from dual union
select 'BA' state_code, 'IGUAI' city_code, '2913507' ibge_code from dual union
select 'BA' state_code, 'ILHEUS' city_code, '2913606' ibge_code from dual union
select 'BA' state_code, 'INHAMBUPE' city_code, '2913705' ibge_code from dual union
select 'BA' state_code, 'IPECAETA' city_code, '2913804' ibge_code from dual union
select 'BA' state_code, 'IPIAU' city_code, '2913903' ibge_code from dual union
select 'BA' state_code, 'IPIRA' city_code, '2914000' ibge_code from dual union
select 'BA' state_code, 'IPUPIARA' city_code, '2914109' ibge_code from dual union
select 'BA' state_code, 'IRAJUBA' city_code, '2914208' ibge_code from dual union
select 'BA' state_code, 'IRAMAIA' city_code, '2914307' ibge_code from dual union
select 'BA' state_code, 'IRAQUARA' city_code, '2914406' ibge_code from dual union
select 'BA' state_code, 'IRARA' city_code, '2914505' ibge_code from dual union
select 'BA' state_code, 'IRECE' city_code, '2914604' ibge_code from dual union
select 'BA' state_code, 'ITABELA' city_code, '2914653' ibge_code from dual union
select 'BA' state_code, 'ITABERABA' city_code, '2914703' ibge_code from dual union
select 'BA' state_code, 'ITABUNA' city_code, '2914802' ibge_code from dual union
select 'BA' state_code, 'ITACARE' city_code, '2914901' ibge_code from dual union
select 'BA' state_code, 'ITAETE' city_code, '2915007' ibge_code from dual union
select 'BA' state_code, 'ITAGI' city_code, '2915106' ibge_code from dual union
select 'BA' state_code, 'ITAGIBA' city_code, '2915205' ibge_code from dual union
select 'BA' state_code, 'ITAGIMIRIM' city_code, '2915304' ibge_code from dual union
select 'BA' state_code, 'ITAGUACU DA BAHIA' city_code, '2915353' ibge_code from dual union
select 'BA' state_code, 'ITAJU DO COLONIA' city_code, '2915403' ibge_code from dual union
select 'BA' state_code, 'ITAJUIPE' city_code, '2915502' ibge_code from dual union
select 'BA' state_code, 'ITAMARAJU' city_code, '2915601' ibge_code from dual union
select 'BA' state_code, 'ITAMARI' city_code, '2915700' ibge_code from dual union
select 'BA' state_code, 'ITAMBE' city_code, '2915809' ibge_code from dual union
select 'BA' state_code, 'ITANAGRA' city_code, '2915908' ibge_code from dual union
select 'BA' state_code, 'ITANHEM' city_code, '2916005' ibge_code from dual union
select 'BA' state_code, 'ITAPARICA' city_code, '2916104' ibge_code from dual union
select 'BA' state_code, 'ITAPE' city_code, '2916203' ibge_code from dual union
select 'BA' state_code, 'ITAPEBI' city_code, '2916302' ibge_code from dual union
select 'BA' state_code, 'ITAPETINGA' city_code, '2916401' ibge_code from dual union
select 'BA' state_code, 'ITAPICURU' city_code, '2916500' ibge_code from dual union
select 'BA' state_code, 'ITAPITANGA' city_code, '2916609' ibge_code from dual union
select 'BA' state_code, 'ITAQUARA' city_code, '2916708' ibge_code from dual union
select 'BA' state_code, 'ITARANTIM' city_code, '2916807' ibge_code from dual union
select 'BA' state_code, 'ITATIM' city_code, '2916856' ibge_code from dual union
select 'BA' state_code, 'ITIRUCU' city_code, '2916906' ibge_code from dual union
select 'BA' state_code, 'ITIUBA' city_code, '2917003' ibge_code from dual union
select 'BA' state_code, 'ITORORO' city_code, '2917102' ibge_code from dual union
select 'BA' state_code, 'ITUACU' city_code, '2917201' ibge_code from dual union
select 'BA' state_code, 'ITUBERA' city_code, '2917300' ibge_code from dual union
select 'BA' state_code, 'IUIU' city_code, '2917334' ibge_code from dual union
select 'BA' state_code, 'JABORANDI' city_code, '2917359' ibge_code from dual union
select 'BA' state_code, 'JACARACI' city_code, '2917409' ibge_code from dual union
select 'BA' state_code, 'JACOBINA' city_code, '2917508' ibge_code from dual union
select 'BA' state_code, 'JAGUAQUARA' city_code, '2917607' ibge_code from dual union
select 'BA' state_code, 'JAGUARARI' city_code, '2917706' ibge_code from dual union
select 'BA' state_code, 'JAGUARIPE' city_code, '2917805' ibge_code from dual union
select 'BA' state_code, 'JANDAIRA' city_code, '2917904' ibge_code from dual union
select 'BA' state_code, 'JEQUIE' city_code, '2918001' ibge_code from dual union
select 'BA' state_code, 'JEREMOABO' city_code, '2918100' ibge_code from dual union
select 'BA' state_code, 'JIQUIRICA' city_code, '2918209' ibge_code from dual union
select 'BA' state_code, 'JITAUNA' city_code, '2918308' ibge_code from dual union
select 'BA' state_code, 'JOAO DOURADO' city_code, '2918357' ibge_code from dual union
select 'BA' state_code, 'JUAZEIRO' city_code, '2918407' ibge_code from dual union
select 'BA' state_code, 'JUCURUCU' city_code, '2918456' ibge_code from dual union
select 'BA' state_code, 'JUSSARA' city_code, '2918506' ibge_code from dual union
select 'BA' state_code, 'JUSSARI' city_code, '2918555' ibge_code from dual union
select 'BA' state_code, 'JUSSIAPE' city_code, '2918605' ibge_code from dual union
select 'BA' state_code, 'LAFAIETE COUTINHO' city_code, '2918704' ibge_code from dual union
select 'BA' state_code, 'LAGOA REAL' city_code, '2918753' ibge_code from dual union
select 'BA' state_code, 'LAJE' city_code, '2918803' ibge_code from dual union
select 'BA' state_code, 'LAJEDAO' city_code, '2918902' ibge_code from dual union
select 'BA' state_code, 'LAJEDINHO' city_code, '2919009' ibge_code from dual union
select 'BA' state_code, 'LAJEDO DO TABOCAL' city_code, '2919058' ibge_code from dual union
select 'BA' state_code, 'LAMARAO' city_code, '2919108' ibge_code from dual union
select 'BA' state_code, 'LAPAO' city_code, '2919157' ibge_code from dual union
select 'BA' state_code, 'LAURO DE FREITAS' city_code, '2919207' ibge_code from dual union
select 'BA' state_code, 'LENCOIS' city_code, '2919306' ibge_code from dual union
select 'BA' state_code, 'LICINIO DE ALMEIDA' city_code, '2919405' ibge_code from dual union
select 'BA' state_code, 'LIVRAMENTO DE NOSSA SENHORA' city_code, '2919504' ibge_code from dual union
select 'BA' state_code, 'LUIS EDUARDO MAGALHAES' city_code, '2919553' ibge_code from dual union
select 'BA' state_code, 'MACAJUBA' city_code, '2919603' ibge_code from dual union
select 'BA' state_code, 'MACARANI' city_code, '2919702' ibge_code from dual union
select 'BA' state_code, 'MACAUBAS' city_code, '2919801' ibge_code from dual union
select 'BA' state_code, 'MACURURE' city_code, '2919900' ibge_code from dual union
select 'BA' state_code, 'MADRE DE DEUS' city_code, '2919926' ibge_code from dual union
select 'BA' state_code, 'MAETINGA' city_code, '2919959' ibge_code from dual union
select 'BA' state_code, 'MAIQUINIQUE' city_code, '2920007' ibge_code from dual union
select 'BA' state_code, 'MAIRI' city_code, '2920106' ibge_code from dual union
select 'BA' state_code, 'MALHADA' city_code, '2920205' ibge_code from dual union
select 'BA' state_code, 'MALHADA DE PEDRAS' city_code, '2920304' ibge_code from dual union
select 'BA' state_code, 'MANOEL VITORINO' city_code, '2920403' ibge_code from dual union
select 'BA' state_code, 'MANSIDAO' city_code, '2920452' ibge_code from dual union
select 'BA' state_code, 'MARACAS' city_code, '2920502' ibge_code from dual union
select 'BA' state_code, 'MARAGOGIPE' city_code, '2920601' ibge_code from dual union
select 'BA' state_code, 'MARAU' city_code, '2920700' ibge_code from dual union
select 'BA' state_code, 'MARCIONILIO SOUZA' city_code, '2920809' ibge_code from dual union
select 'BA' state_code, 'MASCOTE' city_code, '2920908' ibge_code from dual union
select 'BA' state_code, 'MATA DE SAO JOAO' city_code, '2921005' ibge_code from dual union
select 'BA' state_code, 'MATINA' city_code, '2921054' ibge_code from dual union
select 'BA' state_code, 'MEDEIROS NETO' city_code, '2921104' ibge_code from dual union
select 'BA' state_code, 'MIGUEL CALMON' city_code, '2921203' ibge_code from dual union
select 'BA' state_code, 'MILAGRES' city_code, '2921302' ibge_code from dual union
select 'BA' state_code, 'MIRANGABA' city_code, '2921401' ibge_code from dual union
select 'BA' state_code, 'MIRANTE' city_code, '2921450' ibge_code from dual union
select 'BA' state_code, 'MONTE SANTO' city_code, '2921500' ibge_code from dual union
select 'BA' state_code, 'MORPARA' city_code, '2921609' ibge_code from dual union
select 'BA' state_code, 'MORRO DO CHAPEU' city_code, '2921708' ibge_code from dual union
select 'BA' state_code, 'MORTUGABA' city_code, '2921807' ibge_code from dual union
select 'BA' state_code, 'MUCUGE' city_code, '2921906' ibge_code from dual union
select 'BA' state_code, 'MUCURI' city_code, '2922003' ibge_code from dual union
select 'BA' state_code, 'MULUNGU DO MORRO' city_code, '2922052' ibge_code from dual union
select 'BA' state_code, 'MUNDO NOVO' city_code, '2922102' ibge_code from dual union
select 'BA' state_code, 'MUNIZ FERREIRA' city_code, '2922201' ibge_code from dual union
select 'BA' state_code, 'MUQUEM DO SAO FRANCISCO' city_code, '2922250' ibge_code from dual union
select 'BA' state_code, 'MURITIBA' city_code, '2922300' ibge_code from dual union
select 'BA' state_code, 'MUTUIPE' city_code, '2922409' ibge_code from dual union
select 'BA' state_code, 'NAZARE' city_code, '2922508' ibge_code from dual union
select 'BA' state_code, 'NILO PECANHA' city_code, '2922607' ibge_code from dual union
select 'BA' state_code, 'NORDESTINA' city_code, '2922656' ibge_code from dual union
select 'BA' state_code, 'NOVA CANAA' city_code, '2922706' ibge_code from dual union
select 'BA' state_code, 'NOVA FATIMA' city_code, '2922730' ibge_code from dual union
select 'BA' state_code, 'NOVA IBIA' city_code, '2922755' ibge_code from dual union
select 'BA' state_code, 'NOVA ITARANA' city_code, '2922805' ibge_code from dual union
select 'BA' state_code, 'NOVA REDENCAO' city_code, '2922854' ibge_code from dual union
select 'BA' state_code, 'NOVA SOURE' city_code, '2922904' ibge_code from dual union
select 'BA' state_code, 'NOVA VICOSA' city_code, '2923001' ibge_code from dual union
select 'BA' state_code, 'NOVO HORIZONTE' city_code, '2923035' ibge_code from dual union
select 'BA' state_code, 'NOVO TRIUNFO' city_code, '2923050' ibge_code from dual union
select 'BA' state_code, 'OLINDINA' city_code, '2923100' ibge_code from dual union
select 'BA' state_code, 'OLIVEIRA DOS BREJINHOS' city_code, '2923209' ibge_code from dual union
select 'BA' state_code, 'OURICANGAS' city_code, '2923308' ibge_code from dual union
select 'BA' state_code, 'OUROLANDIA' city_code, '2923357' ibge_code from dual union
select 'BA' state_code, 'PALMAS DE MONTE ALTO' city_code, '2923407' ibge_code from dual union
select 'BA' state_code, 'PALMEIRAS' city_code, '2923506' ibge_code from dual union
select 'BA' state_code, 'PARAMIRIM' city_code, '2923605' ibge_code from dual union
select 'BA' state_code, 'PARATINGA' city_code, '2923704' ibge_code from dual union
select 'BA' state_code, 'PARIPIRANGA' city_code, '2923803' ibge_code from dual union
select 'BA' state_code, 'PAU BRASIL' city_code, '2923902' ibge_code from dual union
select 'BA' state_code, 'PAULO AFONSO' city_code, '2924009' ibge_code from dual union
select 'BA' state_code, 'PE DE SERRA' city_code, '2924058' ibge_code from dual union
select 'BA' state_code, 'PEDRAO' city_code, '2924108' ibge_code from dual union
select 'BA' state_code, 'PEDRO ALEXANDRE' city_code, '2924207' ibge_code from dual union
select 'BA' state_code, 'PIATA' city_code, '2924306' ibge_code from dual union
select 'BA' state_code, 'PILAO ARCADO' city_code, '2924405' ibge_code from dual union
select 'BA' state_code, 'PINDAI' city_code, '2924504' ibge_code from dual union
select 'BA' state_code, 'PINDOBACU' city_code, '2924603' ibge_code from dual union
select 'BA' state_code, 'PINTADAS' city_code, '2924652' ibge_code from dual union
select 'BA' state_code, 'PIRAI DO NORTE' city_code, '2924678' ibge_code from dual union
select 'BA' state_code, 'PIRIPA' city_code, '2924702' ibge_code from dual union
select 'BA' state_code, 'PIRITIBA' city_code, '2924801' ibge_code from dual union
select 'BA' state_code, 'PLANALTINO' city_code, '2924900' ibge_code from dual union
select 'BA' state_code, 'PLANALTO' city_code, '2925006' ibge_code from dual union
select 'BA' state_code, 'POCÕES' city_code, '2925105' ibge_code from dual union
select 'BA' state_code, 'POJUCA' city_code, '2925204' ibge_code from dual union
select 'BA' state_code, 'PONTO NOVO' city_code, '2925253' ibge_code from dual union
select 'BA' state_code, 'PORTO SEGURO' city_code, '2925303' ibge_code from dual union
select 'BA' state_code, 'POTIRAGUA' city_code, '2925402' ibge_code from dual union
select 'BA' state_code, 'PRADO' city_code, '2925501' ibge_code from dual union
select 'BA' state_code, 'PRESIDENTE DUTRA' city_code, '2925600' ibge_code from dual union
select 'BA' state_code, 'PRESIDENTE JANIO QUADROS' city_code, '2925709' ibge_code from dual union
select 'BA' state_code, 'PRESIDENTE TANCREDO NEVES' city_code, '2925758' ibge_code from dual union
select 'BA' state_code, 'QUEIMADAS' city_code, '2925808' ibge_code from dual union
select 'BA' state_code, 'QUIJINGUE' city_code, '2925907' ibge_code from dual union
select 'BA' state_code, 'QUIXABEIRA' city_code, '2925931' ibge_code from dual union
select 'BA' state_code, 'RAFAEL JAMBEIRO' city_code, '2925956' ibge_code from dual union
select 'BA' state_code, 'REMANSO' city_code, '2926004' ibge_code from dual union
select 'BA' state_code, 'RETIROLANDIA' city_code, '2926103' ibge_code from dual union
select 'BA' state_code, 'RIACHAO DAS NEVES' city_code, '2926202' ibge_code from dual union
select 'BA' state_code, 'RIACHAO DO JACUIPE' city_code, '2926301' ibge_code from dual union
select 'BA' state_code, 'RIACHO DE SANTANA' city_code, '2926400' ibge_code from dual union
select 'BA' state_code, 'RIBEIRA DO AMPARO' city_code, '2926509' ibge_code from dual union
select 'BA' state_code, 'RIBEIRA DO POMBAL' city_code, '2926608' ibge_code from dual union
select 'BA' state_code, 'RIBEIRAO DO LARGO' city_code, '2926657' ibge_code from dual union
select 'BA' state_code, 'RIO DE CONTAS' city_code, '2926707' ibge_code from dual union
select 'BA' state_code, 'RIO DO ANTONIO' city_code, '2926806' ibge_code from dual union
select 'BA' state_code, 'RIO DO PIRES' city_code, '2926905' ibge_code from dual union
select 'BA' state_code, 'RIO REAL' city_code, '2927002' ibge_code from dual union
select 'BA' state_code, 'RODELAS' city_code, '2927101' ibge_code from dual union
select 'BA' state_code, 'RUY BARBOSA' city_code, '2927200' ibge_code from dual union
select 'BA' state_code, 'SALINAS DA MARGARIDA' city_code, '2927309' ibge_code from dual union
select 'BA' state_code, 'SALVADOR' city_code, '2927408' ibge_code from dual union
select 'BA' state_code, 'SANTA BARBARA' city_code, '2927507' ibge_code from dual union
select 'BA' state_code, 'SANTA BRIGIDA' city_code, '2927606' ibge_code from dual union
select 'BA' state_code, 'SANTA CRUZ CABRALIA' city_code, '2927705' ibge_code from dual union
select 'BA' state_code, 'SANTA CRUZ DA VITORIA' city_code, '2927804' ibge_code from dual union
select 'BA' state_code, 'SANTA INES' city_code, '2927903' ibge_code from dual union
select 'BA' state_code, 'SANTA LUZIA' city_code, '2928059' ibge_code from dual union
select 'BA' state_code, 'SANTA MARIA DA VITORIA' city_code, '2928109' ibge_code from dual union
select 'BA' state_code, 'SANTA RITA DE CASSIA' city_code, '2928406' ibge_code from dual union
select 'BA' state_code, 'SANTA TEREZINHA' city_code, '2928505' ibge_code from dual union
select 'BA' state_code, 'SANTALUZ' city_code, '2928000' ibge_code from dual union
select 'BA' state_code, 'SANTANA' city_code, '2928208' ibge_code from dual union
select 'BA' state_code, 'SANTANOPOLIS' city_code, '2928307' ibge_code from dual union
select 'BA' state_code, 'SANTO AMARO' city_code, '2928604' ibge_code from dual union
select 'BA' state_code, 'SANTO ANTONIO DE JESUS' city_code, '2928703' ibge_code from dual union
select 'BA' state_code, 'SANTO ESTEVAO' city_code, '2928802' ibge_code from dual union
select 'BA' state_code, 'SAO DESIDERIO' city_code, '2928901' ibge_code from dual union
select 'BA' state_code, 'SAO DOMINGOS' city_code, '2928950' ibge_code from dual union
select 'BA' state_code, 'SAO FELIPE' city_code, '2929107' ibge_code from dual union
select 'BA' state_code, 'SAO FELIX' city_code, '2929008' ibge_code from dual union
select 'BA' state_code, 'SAO FELIX DO CORIBE' city_code, '2929057' ibge_code from dual union
select 'BA' state_code, 'SAO FRANCISCO DO CONDE' city_code, '2929206' ibge_code from dual union
select 'BA' state_code, 'SAO GABRIEL' city_code, '2929255' ibge_code from dual union
select 'BA' state_code, 'SAO GONCALO DOS CAMPOS' city_code, '2929305' ibge_code from dual union
select 'BA' state_code, 'SAO JOSE DA VITORIA' city_code, '2929354' ibge_code from dual union
select 'BA' state_code, 'SAO JOSE DO JACUIPE' city_code, '2929370' ibge_code from dual union
select 'BA' state_code, 'SAO MIGUEL DAS MATAS' city_code, '2929404' ibge_code from dual union
select 'BA' state_code, 'SAO SEBASTIAO DO PASSE' city_code, '2929503' ibge_code from dual union
select 'BA' state_code, 'SAPEACU' city_code, '2929602' ibge_code from dual union
select 'BA' state_code, 'SATIRO DIAS' city_code, '2929701' ibge_code from dual union
select 'BA' state_code, 'SAUBARA' city_code, '2929750' ibge_code from dual union
select 'BA' state_code, 'SAUDE' city_code, '2929800' ibge_code from dual union
select 'BA' state_code, 'SEABRA' city_code, '2929909' ibge_code from dual union
select 'BA' state_code, 'SEBASTIAO LARANJEIRAS' city_code, '2930006' ibge_code from dual union
select 'BA' state_code, 'SENHOR DO BONFIM' city_code, '2930105' ibge_code from dual union
select 'BA' state_code, 'SENTO SE' city_code, '2930204' ibge_code from dual union
select 'BA' state_code, 'SERRA DO RAMALHO' city_code, '2930154' ibge_code from dual union
select 'BA' state_code, 'SERRA DOURADA' city_code, '2930303' ibge_code from dual union
select 'BA' state_code, 'SERRA PRETA' city_code, '2930402' ibge_code from dual union
select 'BA' state_code, 'SERRINHA' city_code, '2930501' ibge_code from dual union
select 'BA' state_code, 'SERROLANDIA' city_code, '2930600' ibge_code from dual union
select 'BA' state_code, 'SIMÕES FILHO' city_code, '2930709' ibge_code from dual union
select 'BA' state_code, 'SITIO DO MATO' city_code, '2930758' ibge_code from dual union
select 'BA' state_code, 'SITIO DO QUINTO' city_code, '2930766' ibge_code from dual union
select 'BA' state_code, 'SOBRADINHO' city_code, '2930774' ibge_code from dual union
select 'BA' state_code, 'SOUTO SOARES' city_code, '2930808' ibge_code from dual union
select 'BA' state_code, 'TABOCAS DO BREJO VELHO' city_code, '2930907' ibge_code from dual union
select 'BA' state_code, 'TANHACU' city_code, '2931004' ibge_code from dual union
select 'BA' state_code, 'TANQUE NOVO' city_code, '2931053' ibge_code from dual union
select 'BA' state_code, 'TANQUINHO' city_code, '2931103' ibge_code from dual union
select 'BA' state_code, 'TAPEROA' city_code, '2931202' ibge_code from dual union
select 'BA' state_code, 'TAPIRAMUTA' city_code, '2931301' ibge_code from dual union
select 'BA' state_code, 'TEIXEIRA DE FREITAS' city_code, '2931350' ibge_code from dual union
select 'BA' state_code, 'TEODORO SAMPAIO' city_code, '2931400' ibge_code from dual union
select 'BA' state_code, 'TEOFILANDIA' city_code, '2931509' ibge_code from dual union
select 'BA' state_code, 'TEOLANDIA' city_code, '2931608' ibge_code from dual union
select 'BA' state_code, 'TERRA NOVA' city_code, '2931707' ibge_code from dual union
select 'BA' state_code, 'TREMEDAL' city_code, '2931806' ibge_code from dual union
select 'BA' state_code, 'TUCANO' city_code, '2931905' ibge_code from dual union
select 'BA' state_code, 'UAUA' city_code, '2932002' ibge_code from dual union
select 'BA' state_code, 'UBAIRA' city_code, '2932101' ibge_code from dual union
select 'BA' state_code, 'UBAITABA' city_code, '2932200' ibge_code from dual union
select 'BA' state_code, 'UBATA' city_code, '2932309' ibge_code from dual union
select 'BA' state_code, 'UIBAI' city_code, '2932408' ibge_code from dual union
select 'BA' state_code, 'UMBURANAS' city_code, '2932457' ibge_code from dual union
select 'BA' state_code, 'UNA' city_code, '2932507' ibge_code from dual union
select 'BA' state_code, 'URANDI' city_code, '2932606' ibge_code from dual union
select 'BA' state_code, 'URUCUCA' city_code, '2932705' ibge_code from dual union
select 'BA' state_code, 'UTINGA' city_code, '2932804' ibge_code from dual union
select 'BA' state_code, 'VALENCA' city_code, '2932903' ibge_code from dual union
select 'BA' state_code, 'VALENTE' city_code, '2933000' ibge_code from dual union
select 'BA' state_code, 'VARZEA DA ROCA' city_code, '2933059' ibge_code from dual union
select 'BA' state_code, 'VARZEA DO POCO' city_code, '2933109' ibge_code from dual union
select 'BA' state_code, 'VARZEA NOVA' city_code, '2933158' ibge_code from dual union
select 'BA' state_code, 'VARZEDO' city_code, '2933174' ibge_code from dual union
select 'BA' state_code, 'VERA CRUZ' city_code, '2933208' ibge_code from dual union
select 'BA' state_code, 'VEREDA' city_code, '2933257' ibge_code from dual union
select 'BA' state_code, 'VITORIA DA CONQUISTA' city_code, '2933307' ibge_code from dual union
select 'BA' state_code, 'WAGNER' city_code, '2933406' ibge_code from dual union
select 'BA' state_code, 'WANDERLEY' city_code, '2933455' ibge_code from dual union
select 'BA' state_code, 'WENCESLAU GUIMARAES' city_code, '2933505' ibge_code from dual union
select 'BA' state_code, 'XIQUE-XIQUE' city_code, '2933604' ibge_code from dual union
select 'MG' state_code, 'ABADIA DOS DOURADOS' city_code, '3100104' ibge_code from dual union
select 'MG' state_code, 'ABAETE' city_code, '3100203' ibge_code from dual union
select 'MG' state_code, 'ABRE CAMPO' city_code, '3100302' ibge_code from dual union
select 'MG' state_code, 'ACAIACA' city_code, '3100401' ibge_code from dual union
select 'MG' state_code, 'ACUCENA' city_code, '3100500' ibge_code from dual union
select 'MG' state_code, 'AGUA BOA' city_code, '3100609' ibge_code from dual union
select 'MG' state_code, 'AGUA COMPRIDA' city_code, '3100708' ibge_code from dual union
select 'MG' state_code, 'AGUANIL' city_code, '3100807' ibge_code from dual union
select 'MG' state_code, 'AGUAS FORMOSAS' city_code, '3100906' ibge_code from dual union
select 'MG' state_code, 'AGUAS VERMELHAS' city_code, '3101003' ibge_code from dual union
select 'MG' state_code, 'AIMORES' city_code, '3101102' ibge_code from dual union
select 'MG' state_code, 'AIURUOCA' city_code, '3101201' ibge_code from dual union
select 'MG' state_code, 'ALAGOA' city_code, '3101300' ibge_code from dual union
select 'MG' state_code, 'ALBERTINA' city_code, '3101409' ibge_code from dual union
select 'MG' state_code, 'ALEM PARAIBA' city_code, '3101508' ibge_code from dual union
select 'MG' state_code, 'ALFENAS' city_code, '3101607' ibge_code from dual union
select 'MG' state_code, 'ALFREDO VASCONCELOS' city_code, '3101631' ibge_code from dual union
select 'MG' state_code, 'ALMENARA' city_code, '3101706' ibge_code from dual union
select 'MG' state_code, 'ALPERCATA' city_code, '3101805' ibge_code from dual union
select 'MG' state_code, 'ALPINOPOLIS' city_code, '3101904' ibge_code from dual union
select 'MG' state_code, 'ALTEROSA' city_code, '3102001' ibge_code from dual union
select 'MG' state_code, 'ALTO CAPARAO' city_code, '3102050' ibge_code from dual union
select 'MG' state_code, 'ALTO JEQUITIBA' city_code, '3153509' ibge_code from dual union
select 'MG' state_code, 'ALTO RIO DOCE' city_code, '3102100' ibge_code from dual union
select 'MG' state_code, 'ALVARENGA' city_code, '3102209' ibge_code from dual union
select 'MG' state_code, 'ALVINOPOLIS' city_code, '3102308' ibge_code from dual union
select 'MG' state_code, 'ALVORADA DE MINAS' city_code, '3102407' ibge_code from dual union
select 'MG' state_code, 'AMPARO DO SERRA' city_code, '3102506' ibge_code from dual union
select 'MG' state_code, 'ANDRADAS' city_code, '3102605' ibge_code from dual union
select 'MG' state_code, 'ANDRELANDIA' city_code, '3102803' ibge_code from dual union
select 'MG' state_code, 'ANGELANDIA' city_code, '3102852' ibge_code from dual union
select 'MG' state_code, 'ANTONIO CARLOS' city_code, '3102902' ibge_code from dual union
select 'MG' state_code, 'ANTONIO DIAS' city_code, '3103009' ibge_code from dual union
select 'MG' state_code, 'ANTONIO PRADO DE MINAS' city_code, '3103108' ibge_code from dual union
select 'MG' state_code, 'ARACAI' city_code, '3103207' ibge_code from dual union
select 'MG' state_code, 'ARACITABA' city_code, '3103306' ibge_code from dual union
select 'MG' state_code, 'ARACUAI' city_code, '3103405' ibge_code from dual union
select 'MG' state_code, 'ARAGUARI' city_code, '3103504' ibge_code from dual union
select 'MG' state_code, 'ARANTINA' city_code, '3103603' ibge_code from dual union
select 'MG' state_code, 'ARAPONGA' city_code, '3103702' ibge_code from dual union
select 'MG' state_code, 'ARAPORA' city_code, '3103751' ibge_code from dual union
select 'MG' state_code, 'ARAPUA' city_code, '3103801' ibge_code from dual union
select 'MG' state_code, 'ARAUJOS' city_code, '3103900' ibge_code from dual union
select 'MG' state_code, 'ARAXA' city_code, '3104007' ibge_code from dual union
select 'MG' state_code, 'ARCEBURGO' city_code, '3104106' ibge_code from dual union
select 'MG' state_code, 'ARCOS' city_code, '3104205' ibge_code from dual union
select 'MG' state_code, 'AREADO' city_code, '3104304' ibge_code from dual union
select 'MG' state_code, 'ARGIRITA' city_code, '3104403' ibge_code from dual union
select 'MG' state_code, 'ARICANDUVA' city_code, '3104452' ibge_code from dual union
select 'MG' state_code, 'ARINOS' city_code, '3104502' ibge_code from dual union
select 'MG' state_code, 'ASTOLFO DUTRA' city_code, '3104601' ibge_code from dual union
select 'MG' state_code, 'ATALEIA' city_code, '3104700' ibge_code from dual union
select 'MG' state_code, 'AUGUSTO DE LIMA' city_code, '3104809' ibge_code from dual union
select 'MG' state_code, 'BAEPENDI' city_code, '3104908' ibge_code from dual union
select 'MG' state_code, 'BALDIM' city_code, '3105004' ibge_code from dual union
select 'MG' state_code, 'BAMBUI' city_code, '3105103' ibge_code from dual union
select 'MG' state_code, 'BANDEIRA' city_code, '3105202' ibge_code from dual union
select 'MG' state_code, 'BANDEIRA DO SUL' city_code, '3105301' ibge_code from dual union
select 'MG' state_code, 'BARAO DE COCAIS' city_code, '3105400' ibge_code from dual union
select 'MG' state_code, 'BARAO DE MONTE ALTO' city_code, '3105509' ibge_code from dual union
select 'MG' state_code, 'BARBACENA' city_code, '3105608' ibge_code from dual union
select 'MG' state_code, 'BARRA LONGA' city_code, '3105707' ibge_code from dual union
select 'MG' state_code, 'BARROSO' city_code, '3105905' ibge_code from dual union
select 'MG' state_code, 'BELA VISTA DE MINAS' city_code, '3106002' ibge_code from dual union
select 'MG' state_code, 'BELMIRO BRAGA' city_code, '3106101' ibge_code from dual union
select 'MG' state_code, 'BELO HORIZONTE' city_code, '3106200' ibge_code from dual union
select 'MG' state_code, 'BELO ORIENTE' city_code, '3106309' ibge_code from dual union
select 'MG' state_code, 'BELO VALE' city_code, '3106408' ibge_code from dual union
select 'MG' state_code, 'BERILO' city_code, '3106507' ibge_code from dual union
select 'MG' state_code, 'BERIZAL' city_code, '3106655' ibge_code from dual union
select 'MG' state_code, 'BERTOPOLIS' city_code, '3106606' ibge_code from dual union
select 'MG' state_code, 'BETIM' city_code, '3106705' ibge_code from dual union
select 'MG' state_code, 'BIAS FORTES' city_code, '3106804' ibge_code from dual union
select 'MG' state_code, 'BICAS' city_code, '3106903' ibge_code from dual union
select 'MG' state_code, 'BIQUINHAS' city_code, '3107000' ibge_code from dual union
select 'MG' state_code, 'BOA ESPERANCA' city_code, '3107109' ibge_code from dual union
select 'MG' state_code, 'BOCAINA DE MINAS' city_code, '3107208' ibge_code from dual union
select 'MG' state_code, 'BOCAIUVA' city_code, '3107307' ibge_code from dual union
select 'MG' state_code, 'BOM DESPACHO' city_code, '3107406' ibge_code from dual union
select 'MG' state_code, 'BOM JARDIM DE MINAS' city_code, '3107505' ibge_code from dual union
select 'MG' state_code, 'BOM JESUS DA PENHA' city_code, '3107604' ibge_code from dual union
select 'MG' state_code, 'BOM JESUS DO AMPARO' city_code, '3107703' ibge_code from dual union
select 'MG' state_code, 'BOM JESUS DO GALHO' city_code, '3107802' ibge_code from dual union
select 'MG' state_code, 'BOM REPOUSO' city_code, '3107901' ibge_code from dual union
select 'MG' state_code, 'BOM SUCESSO' city_code, '3108008' ibge_code from dual union
select 'MG' state_code, 'BONFIM' city_code, '3108107' ibge_code from dual union
select 'MG' state_code, 'BONFINOPOLIS DE MINAS' city_code, '3108206' ibge_code from dual union
select 'MG' state_code, 'BONITO DE MINAS' city_code, '3108255' ibge_code from dual union
select 'MG' state_code, 'BORDA DA MATA' city_code, '3108305' ibge_code from dual union
select 'MG' state_code, 'BOTELHOS' city_code, '3108404' ibge_code from dual union
select 'MG' state_code, 'BOTUMIRIM' city_code, '3108503' ibge_code from dual union
select 'MG' state_code, 'BRAS PIRES' city_code, '3108701' ibge_code from dual union
select 'MG' state_code, 'BRASILANDIA DE MINAS' city_code, '3108552' ibge_code from dual union
select 'MG' state_code, 'BRASILIA DE MINAS' city_code, '3108602' ibge_code from dual union
select 'MG' state_code, 'BRAUNAS' city_code, '3108800' ibge_code from dual union
select 'MG' state_code, 'BRAZOPOLIS' city_code, '3108909' ibge_code from dual union
select 'MG' state_code, 'BRUMADINHO' city_code, '3109006' ibge_code from dual union
select 'MG' state_code, 'BUENO BRANDAO' city_code, '3109105' ibge_code from dual union
select 'MG' state_code, 'BUENOPOLIS' city_code, '3109204' ibge_code from dual union
select 'MG' state_code, 'BUGRE' city_code, '3109253' ibge_code from dual union
select 'MG' state_code, 'BURITIS' city_code, '3109303' ibge_code from dual union
select 'MG' state_code, 'BURITIZEIRO' city_code, '3109402' ibge_code from dual union
select 'MG' state_code, 'CABECEIRA GRANDE' city_code, '3109451' ibge_code from dual union
select 'MG' state_code, 'CABO VERDE' city_code, '3109501' ibge_code from dual union
select 'MG' state_code, 'CACHOEIRA DA PRATA' city_code, '3109600' ibge_code from dual union
select 'MG' state_code, 'CACHOEIRA DE MINAS' city_code, '3109709' ibge_code from dual union
select 'MG' state_code, 'CACHOEIRA DE PAJEU' city_code, '3102704' ibge_code from dual union
select 'MG' state_code, 'CACHOEIRA DOURADA' city_code, '3109808' ibge_code from dual union
select 'MG' state_code, 'CAETANOPOLIS' city_code, '3109907' ibge_code from dual union
select 'MG' state_code, 'CAETE' city_code, '3110004' ibge_code from dual union
select 'MG' state_code, 'CAIANA' city_code, '3110103' ibge_code from dual union
select 'MG' state_code, 'CAJURI' city_code, '3110202' ibge_code from dual union
select 'MG' state_code, 'CALDAS' city_code, '3110301' ibge_code from dual union
select 'MG' state_code, 'CAMACHO' city_code, '3110400' ibge_code from dual union
select 'MG' state_code, 'CAMANDUCAIA' city_code, '3110509' ibge_code from dual union
select 'MG' state_code, 'CAMBUI' city_code, '3110608' ibge_code from dual union
select 'MG' state_code, 'CAMBUQUIRA' city_code, '3110707' ibge_code from dual union
select 'MG' state_code, 'CAMPANARIO' city_code, '3110806' ibge_code from dual union
select 'MG' state_code, 'CAMPANHA' city_code, '3110905' ibge_code from dual union
select 'MG' state_code, 'CAMPESTRE' city_code, '3111002' ibge_code from dual union
select 'MG' state_code, 'CAMPINA VERDE' city_code, '3111101' ibge_code from dual union
select 'MG' state_code, 'CAMPO AZUL' city_code, '3111150' ibge_code from dual union
select 'MG' state_code, 'CAMPO BELO' city_code, '3111200' ibge_code from dual union
select 'MG' state_code, 'CAMPO DO MEIO' city_code, '3111309' ibge_code from dual union
select 'MG' state_code, 'CAMPO FLORIDO' city_code, '3111408' ibge_code from dual union
select 'MG' state_code, 'CAMPOS ALTOS' city_code, '3111507' ibge_code from dual union
select 'MG' state_code, 'CAMPOS GERAIS' city_code, '3111606' ibge_code from dual union
select 'MG' state_code, 'CANA VERDE' city_code, '3111903' ibge_code from dual union
select 'MG' state_code, 'CANAA' city_code, '3111705' ibge_code from dual union
select 'MG' state_code, 'CANAPOLIS' city_code, '3111804' ibge_code from dual union
select 'MG' state_code, 'CANDEIAS' city_code, '3112000' ibge_code from dual union
select 'MG' state_code, 'CANTAGALO' city_code, '3112059' ibge_code from dual union
select 'MG' state_code, 'CAPARAO' city_code, '3112109' ibge_code from dual union
select 'MG' state_code, 'CAPELA NOVA' city_code, '3112208' ibge_code from dual union
select 'MG' state_code, 'CAPELINHA' city_code, '3112307' ibge_code from dual union
select 'MG' state_code, 'CAPETINGA' city_code, '3112406' ibge_code from dual union
select 'MG' state_code, 'CAPIM BRANCO' city_code, '3112505' ibge_code from dual union
select 'MG' state_code, 'CAPINOPOLIS' city_code, '3112604' ibge_code from dual union
select 'MG' state_code, 'CAPITAO ANDRADE' city_code, '3112653' ibge_code from dual union
select 'MG' state_code, 'CAPITAO ENEAS' city_code, '3112703' ibge_code from dual union
select 'MG' state_code, 'CAPITOLIO' city_code, '3112802' ibge_code from dual union
select 'MG' state_code, 'CAPUTIRA' city_code, '3112901' ibge_code from dual union
select 'MG' state_code, 'CARAI' city_code, '3113008' ibge_code from dual union
select 'MG' state_code, 'CARANAIBA' city_code, '3113107' ibge_code from dual union
select 'MG' state_code, 'CARANDAI' city_code, '3113206' ibge_code from dual union
select 'MG' state_code, 'CARANGOLA' city_code, '3113305' ibge_code from dual union
select 'MG' state_code, 'CARATINGA' city_code, '3113404' ibge_code from dual union
select 'MG' state_code, 'CARBONITA' city_code, '3113503' ibge_code from dual union
select 'MG' state_code, 'CAREACU' city_code, '3113602' ibge_code from dual union
select 'MG' state_code, 'CARLOS CHAGAS' city_code, '3113701' ibge_code from dual union
select 'MG' state_code, 'CARMESIA' city_code, '3113800' ibge_code from dual union
select 'MG' state_code, 'CARMO DA CACHOEIRA' city_code, '3113909' ibge_code from dual union
select 'MG' state_code, 'CARMO DA MATA' city_code, '3114006' ibge_code from dual union
select 'MG' state_code, 'CARMO DE MINAS' city_code, '3114105' ibge_code from dual union
select 'MG' state_code, 'CARMO DO CAJURU' city_code, '3114204' ibge_code from dual union
select 'MG' state_code, 'CARMO DO PARANAIBA' city_code, '3114303' ibge_code from dual union
select 'MG' state_code, 'CARMO DO RIO CLARO' city_code, '3114402' ibge_code from dual union
select 'MG' state_code, 'CARMOPOLIS DE MINAS' city_code, '3114501' ibge_code from dual union
select 'MG' state_code, 'CARNEIRINHO' city_code, '3114550' ibge_code from dual union
select 'MG' state_code, 'CARRANCAS' city_code, '3114600' ibge_code from dual union
select 'MG' state_code, 'CARVALHOPOLIS' city_code, '3114709' ibge_code from dual union
select 'MG' state_code, 'CARVALHOS' city_code, '3114808' ibge_code from dual union
select 'MG' state_code, 'CASA GRANDE' city_code, '3114907' ibge_code from dual union
select 'MG' state_code, 'CASCALHO RICO' city_code, '3115003' ibge_code from dual union
select 'MG' state_code, 'CASSIA' city_code, '3115102' ibge_code from dual union
select 'MG' state_code, 'CATAGUASES' city_code, '3115300' ibge_code from dual union
select 'MG' state_code, 'CATAS ALTAS' city_code, '3115359' ibge_code from dual union
select 'MG' state_code, 'CATAS ALTAS DA NORUEGA' city_code, '3115409' ibge_code from dual union
select 'MG' state_code, 'CATUJI' city_code, '3115458' ibge_code from dual union
select 'MG' state_code, 'CATUTI' city_code, '3115474' ibge_code from dual union
select 'MG' state_code, 'CAXAMBU' city_code, '3115508' ibge_code from dual union
select 'MG' state_code, 'CEDRO DO ABAETE' city_code, '3115607' ibge_code from dual union
select 'MG' state_code, 'CENTRAL DE MINAS' city_code, '3115706' ibge_code from dual union
select 'MG' state_code, 'CENTRALINA' city_code, '3115805' ibge_code from dual union
select 'MG' state_code, 'CHACARA' city_code, '3115904' ibge_code from dual union
select 'MG' state_code, 'CHALE' city_code, '3116001' ibge_code from dual union
select 'MG' state_code, 'CHAPADA DO NORTE' city_code, '3116100' ibge_code from dual union
select 'MG' state_code, 'CHAPADA GAUCHA' city_code, '3116159' ibge_code from dual union
select 'MG' state_code, 'CHIADOR' city_code, '3116209' ibge_code from dual union
select 'MG' state_code, 'CIPOTANEA' city_code, '3116308' ibge_code from dual union
select 'MG' state_code, 'CLARAVAL' city_code, '3116407' ibge_code from dual union
select 'MG' state_code, 'CLARO DOS POCÕES' city_code, '3116506' ibge_code from dual union
select 'MG' state_code, 'CLAUDIO' city_code, '3116605' ibge_code from dual union
select 'MG' state_code, 'COIMBRA' city_code, '3116704' ibge_code from dual union
select 'MG' state_code, 'COLUNA' city_code, '3116803' ibge_code from dual union
select 'MG' state_code, 'COMENDADOR GOMES' city_code, '3116902' ibge_code from dual union
select 'MG' state_code, 'COMERCINHO' city_code, '3117009' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DA APARECIDA' city_code, '3117108' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DA BARRA DE MINAS' city_code, '3115201' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DAS ALAGOAS' city_code, '3117306' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DAS PEDRAS' city_code, '3117207' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DE IPANEMA' city_code, '3117405' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DO MATO DENTRO' city_code, '3117504' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DO PARA' city_code, '3117603' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DO RIO VERDE' city_code, '3117702' ibge_code from dual union
select 'MG' state_code, 'CONCEICAO DOS OUROS' city_code, '3117801' ibge_code from dual union
select 'MG' state_code, 'CONEGO MARINHO' city_code, '3117836' ibge_code from dual union
select 'MG' state_code, 'CONFINS' city_code, '3117876' ibge_code from dual union
select 'MG' state_code, 'CONGONHAL' city_code, '3117900' ibge_code from dual union
select 'MG' state_code, 'CONGONHAS' city_code, '3118007' ibge_code from dual union
select 'MG' state_code, 'CONGONHAS DO NORTE' city_code, '3118106' ibge_code from dual union
select 'MG' state_code, 'CONQUISTA' city_code, '3118205' ibge_code from dual union
select 'MG' state_code, 'CONSELHEIRO LAFAIETE' city_code, '3118304' ibge_code from dual union
select 'MG' state_code, 'CONSELHEIRO PENA' city_code, '3118403' ibge_code from dual union
select 'MG' state_code, 'CONSOLACAO' city_code, '3118502' ibge_code from dual union
select 'MG' state_code, 'CONTAGEM' city_code, '3118601' ibge_code from dual union
select 'MG' state_code, 'COQUEIRAL' city_code, '3118700' ibge_code from dual union
select 'MG' state_code, 'CORACAO DE JESUS' city_code, '3118809' ibge_code from dual union
select 'MG' state_code, 'CORDISBURGO' city_code, '3118908' ibge_code from dual union
select 'MG' state_code, 'CORDISLANDIA' city_code, '3119005' ibge_code from dual union
select 'MG' state_code, 'CORINTO' city_code, '3119104' ibge_code from dual union
select 'MG' state_code, 'COROACI' city_code, '3119203' ibge_code from dual union
select 'MG' state_code, 'COROMANDEL' city_code, '3119302' ibge_code from dual union
select 'MG' state_code, 'CORONEL FABRICIANO' city_code, '3119401' ibge_code from dual union
select 'MG' state_code, 'CORONEL MURTA' city_code, '3119500' ibge_code from dual union
select 'MG' state_code, 'CORONEL PACHECO' city_code, '3119609' ibge_code from dual union
select 'MG' state_code, 'CORONEL XAVIER CHAVES' city_code, '3119708' ibge_code from dual union
select 'MG' state_code, 'CORREGO DANTA' city_code, '3119807' ibge_code from dual union
select 'MG' state_code, 'CORREGO DO BOM JESUS' city_code, '3119906' ibge_code from dual union
select 'MG' state_code, 'CORREGO FUNDO' city_code, '3119955' ibge_code from dual union
select 'MG' state_code, 'CORREGO NOVO' city_code, '3120003' ibge_code from dual union
select 'MG' state_code, 'COUTO DE MAGALHAES DE MINAS' city_code, '3120102' ibge_code from dual union
select 'MG' state_code, 'CRISOLITA' city_code, '3120151' ibge_code from dual union
select 'MG' state_code, 'CRISTAIS' city_code, '3120201' ibge_code from dual union
select 'MG' state_code, 'CRISTALIA' city_code, '3120300' ibge_code from dual union
select 'MG' state_code, 'CRISTIANO OTONI' city_code, '3120409' ibge_code from dual union
select 'MG' state_code, 'CRISTINA' city_code, '3120508' ibge_code from dual union
select 'MG' state_code, 'CRUCILANDIA' city_code, '3120607' ibge_code from dual union
select 'MG' state_code, 'CRUZEIRO DA FORTALEZA' city_code, '3120706' ibge_code from dual union
select 'MG' state_code, 'CRUZILIA' city_code, '3120805' ibge_code from dual union
select 'MG' state_code, 'CUPARAQUE' city_code, '3120839' ibge_code from dual union
select 'MG' state_code, 'CURRAL DE DENTRO' city_code, '3120870' ibge_code from dual union
select 'MG' state_code, 'CURVELO' city_code, '3120904' ibge_code from dual union
select 'MG' state_code, 'DATAS' city_code, '3121001' ibge_code from dual union
select 'MG' state_code, 'DELFIM MOREIRA' city_code, '3121100' ibge_code from dual union
select 'MG' state_code, 'DELFINOPOLIS' city_code, '3121209' ibge_code from dual union
select 'MG' state_code, 'DELTA' city_code, '3121258' ibge_code from dual union
select 'MG' state_code, 'DESCOBERTO' city_code, '3121308' ibge_code from dual union
select 'MG' state_code, 'DESTERRO DE ENTRE RIOS' city_code, '3121407' ibge_code from dual union
select 'MG' state_code, 'DESTERRO DO MELO' city_code, '3121506' ibge_code from dual union
select 'MG' state_code, 'DIAMANTINA' city_code, '3121605' ibge_code from dual union
select 'MG' state_code, 'DIOGO DE VASCONCELOS' city_code, '3121704' ibge_code from dual union
select 'MG' state_code, 'DIONISIO' city_code, '3121803' ibge_code from dual union
select 'MG' state_code, 'DIVINESIA' city_code, '3121902' ibge_code from dual union
select 'MG' state_code, 'DIVINO' city_code, '3122009' ibge_code from dual union
select 'MG' state_code, 'DIVINO DAS LARANJEIRAS' city_code, '3122108' ibge_code from dual union
select 'MG' state_code, 'DIVINOLANDIA DE MINAS' city_code, '3122207' ibge_code from dual union
select 'MG' state_code, 'DIVINOPOLIS' city_code, '3122306' ibge_code from dual union
select 'MG' state_code, 'DIVISA ALEGRE' city_code, '3122355' ibge_code from dual union
select 'MG' state_code, 'DIVISA NOVA' city_code, '3122405' ibge_code from dual union
select 'MG' state_code, 'DIVISOPOLIS' city_code, '3122454' ibge_code from dual union
select 'MG' state_code, 'DOM BOSCO' city_code, '3122470' ibge_code from dual union
select 'MG' state_code, 'DOM CAVATI' city_code, '3122504' ibge_code from dual union
select 'MG' state_code, 'DOM JOAQUIM' city_code, '3122603' ibge_code from dual union
select 'MG' state_code, 'DOM SILVERIO' city_code, '3122702' ibge_code from dual union
select 'MG' state_code, 'DOM VICOSO' city_code, '3122801' ibge_code from dual union
select 'MG' state_code, 'DONA EUSEBIA' city_code, '3122900' ibge_code from dual union
select 'MG' state_code, 'DORES DE CAMPOS' city_code, '3123007' ibge_code from dual union
select 'MG' state_code, 'DORES DE GUANHAES' city_code, '3123106' ibge_code from dual union
select 'MG' state_code, 'DORES DO INDAIA' city_code, '3123205' ibge_code from dual union
select 'MG' state_code, 'DORES DO TURVO' city_code, '3123304' ibge_code from dual union
select 'MG' state_code, 'DORESOPOLIS' city_code, '3123403' ibge_code from dual union
select 'MG' state_code, 'DOURADOQUARA' city_code, '3123502' ibge_code from dual union
select 'MG' state_code, 'DURANDE' city_code, '3123528' ibge_code from dual union
select 'MG' state_code, 'ELOI MENDES' city_code, '3123601' ibge_code from dual union
select 'MG' state_code, 'ENGENHEIRO CALDAS' city_code, '3123700' ibge_code from dual union
select 'MG' state_code, 'ENGENHEIRO NAVARRO' city_code, '3123809' ibge_code from dual union
select 'MG' state_code, 'ENTRE FOLHAS' city_code, '3123858' ibge_code from dual union
select 'MG' state_code, 'ENTRE RIOS DE MINAS' city_code, '3123908' ibge_code from dual union
select 'MG' state_code, 'ERVALIA' city_code, '3124005' ibge_code from dual union
select 'MG' state_code, 'ESMERALDAS' city_code, '3124104' ibge_code from dual union
select 'MG' state_code, 'ESPERA FELIZ' city_code, '3124203' ibge_code from dual union
select 'MG' state_code, 'ESPINOSA' city_code, '3124302' ibge_code from dual union
select 'MG' state_code, 'ESPIRITO SANTO DO DOURADO' city_code, '3124401' ibge_code from dual union
select 'MG' state_code, 'ESTIVA' city_code, '3124500' ibge_code from dual union
select 'MG' state_code, 'ESTRELA DALVA' city_code, '3124609' ibge_code from dual union
select 'MG' state_code, 'ESTRELA DO INDAIA' city_code, '3124708' ibge_code from dual union
select 'MG' state_code, 'ESTRELA DO SUL' city_code, '3124807' ibge_code from dual union
select 'MG' state_code, 'EUGENOPOLIS' city_code, '3124906' ibge_code from dual union
select 'MG' state_code, 'EWBANK DA CAMARA' city_code, '3125002' ibge_code from dual union
select 'MG' state_code, 'EXTREMA' city_code, '3125101' ibge_code from dual union
select 'MG' state_code, 'FAMA' city_code, '3125200' ibge_code from dual union
select 'MG' state_code, 'FARIA LEMOS' city_code, '3125309' ibge_code from dual union
select 'MG' state_code, 'FELICIO DOS SANTOS' city_code, '3125408' ibge_code from dual union
select 'MG' state_code, 'FELISBURGO' city_code, '3125606' ibge_code from dual union
select 'MG' state_code, 'FELIXLANDIA' city_code, '3125705' ibge_code from dual union
select 'MG' state_code, 'FERNANDES TOURINHO' city_code, '3125804' ibge_code from dual union
select 'MG' state_code, 'FERROS' city_code, '3125903' ibge_code from dual union
select 'MG' state_code, 'FERVEDOURO' city_code, '3125952' ibge_code from dual union
select 'MG' state_code, 'FLORESTAL' city_code, '3126000' ibge_code from dual union
select 'MG' state_code, 'FORMIGA' city_code, '3126109' ibge_code from dual union
select 'MG' state_code, 'FORMOSO' city_code, '3126208' ibge_code from dual union
select 'MG' state_code, 'FORTALEZA DE MINAS' city_code, '3126307' ibge_code from dual union
select 'MG' state_code, 'FORTUNA DE MINAS' city_code, '3126406' ibge_code from dual union
select 'MG' state_code, 'FRANCISCO BADARO' city_code, '3126505' ibge_code from dual union
select 'MG' state_code, 'FRANCISCO DUMONT' city_code, '3126604' ibge_code from dual union
select 'MG' state_code, 'FRANCISCO SA' city_code, '3126703' ibge_code from dual union
select 'MG' state_code, 'FRANCISCOPOLIS' city_code, '3126752' ibge_code from dual union
select 'MG' state_code, 'FREI GASPAR' city_code, '3126802' ibge_code from dual union
select 'MG' state_code, 'FREI INOCENCIO' city_code, '3126901' ibge_code from dual union
select 'MG' state_code, 'FREI LAGONEGRO' city_code, '3126950' ibge_code from dual union
select 'MG' state_code, 'FRONTEIRA' city_code, '3127008' ibge_code from dual union
select 'MG' state_code, 'FRONTEIRA DOS VALES' city_code, '3127057' ibge_code from dual union
select 'MG' state_code, 'FRUTA DE LEITE' city_code, '3127073' ibge_code from dual union
select 'MG' state_code, 'FRUTAL' city_code, '3127107' ibge_code from dual union
select 'MG' state_code, 'FUNILANDIA' city_code, '3127206' ibge_code from dual union
select 'MG' state_code, 'GALILEIA' city_code, '3127305' ibge_code from dual union
select 'MG' state_code, 'GAMELEIRAS' city_code, '3127339' ibge_code from dual union
select 'MG' state_code, 'GLAUCILANDIA' city_code, '3127354' ibge_code from dual union
select 'MG' state_code, 'GOIABEIRA' city_code, '3127370' ibge_code from dual union
select 'MG' state_code, 'GOIANA' city_code, '3127388' ibge_code from dual union
select 'MG' state_code, 'GONCALVES' city_code, '3127404' ibge_code from dual union
select 'MG' state_code, 'GONZAGA' city_code, '3127503' ibge_code from dual union
select 'MG' state_code, 'GOUVEIA' city_code, '3127602' ibge_code from dual union
select 'MG' state_code, 'GOVERNADOR VALADARES' city_code, '3127701' ibge_code from dual union
select 'MG' state_code, 'GRAO MOGOL' city_code, '3127800' ibge_code from dual union
select 'MG' state_code, 'GRUPIARA' city_code, '3127909' ibge_code from dual union
select 'MG' state_code, 'GUANHAES' city_code, '3128006' ibge_code from dual union
select 'MG' state_code, 'GUAPE' city_code, '3128105' ibge_code from dual union
select 'MG' state_code, 'GUARACIABA' city_code, '3128204' ibge_code from dual union
select 'MG' state_code, 'GUARACIAMA' city_code, '3128253' ibge_code from dual union
select 'MG' state_code, 'GUARANESIA' city_code, '3128303' ibge_code from dual union
select 'MG' state_code, 'GUARANI' city_code, '3128402' ibge_code from dual union
select 'MG' state_code, 'GUARARA' city_code, '3128501' ibge_code from dual union
select 'MG' state_code, 'GUARDA-MOR' city_code, '3128600' ibge_code from dual union
select 'MG' state_code, 'GUAXUPE' city_code, '3128709' ibge_code from dual union
select 'MG' state_code, 'GUIDOVAL' city_code, '3128808' ibge_code from dual union
select 'MG' state_code, 'GUIMARANIA' city_code, '3128907' ibge_code from dual union
select 'MG' state_code, 'GUIRICEMA' city_code, '3129004' ibge_code from dual union
select 'MG' state_code, 'GURINHATA' city_code, '3129103' ibge_code from dual union
select 'MG' state_code, 'HELIODORA' city_code, '3129202' ibge_code from dual union
select 'MG' state_code, 'IAPU' city_code, '3129301' ibge_code from dual union
select 'MG' state_code, 'IBERTIOGA' city_code, '3129400' ibge_code from dual union
select 'MG' state_code, 'IBIA' city_code, '3129509' ibge_code from dual union
select 'MG' state_code, 'IBIAI' city_code, '3129608' ibge_code from dual union
select 'MG' state_code, 'IBIRACATU' city_code, '3129657' ibge_code from dual union
select 'MG' state_code, 'IBIRACI' city_code, '3129707' ibge_code from dual union
select 'MG' state_code, 'IBIRITE' city_code, '3129806' ibge_code from dual union
select 'MG' state_code, 'IBITIURA DE MINAS' city_code, '3129905' ibge_code from dual union
select 'MG' state_code, 'IBITURUNA' city_code, '3130002' ibge_code from dual union
select 'MG' state_code, 'ICARAI DE MINAS' city_code, '3130051' ibge_code from dual union
select 'MG' state_code, 'IGARAPE' city_code, '3130101' ibge_code from dual union
select 'MG' state_code, 'IGARATINGA' city_code, '3130200' ibge_code from dual union
select 'MG' state_code, 'IGUATAMA' city_code, '3130309' ibge_code from dual union
select 'MG' state_code, 'IJACI' city_code, '3130408' ibge_code from dual union
select 'MG' state_code, 'ILICINEA' city_code, '3130507' ibge_code from dual union
select 'MG' state_code, 'IMBE DE MINAS' city_code, '3130556' ibge_code from dual union
select 'MG' state_code, 'INCONFIDENTES' city_code, '3130606' ibge_code from dual union
select 'MG' state_code, 'INDAIABIRA' city_code, '3130655' ibge_code from dual union
select 'MG' state_code, 'INDIANOPOLIS' city_code, '3130705' ibge_code from dual union
select 'MG' state_code, 'INGAI' city_code, '3130804' ibge_code from dual union
select 'MG' state_code, 'INHAPIM' city_code, '3130903' ibge_code from dual union
select 'MG' state_code, 'INHAUMA' city_code, '3131000' ibge_code from dual union
select 'MG' state_code, 'INIMUTABA' city_code, '3131109' ibge_code from dual union
select 'MG' state_code, 'IPABA' city_code, '3131158' ibge_code from dual union
select 'MG' state_code, 'IPANEMA' city_code, '3131208' ibge_code from dual union
select 'MG' state_code, 'IPATINGA' city_code, '3131307' ibge_code from dual union
select 'MG' state_code, 'IPIACU' city_code, '3131406' ibge_code from dual union
select 'MG' state_code, 'IPUIUNA' city_code, '3131505' ibge_code from dual union
select 'MG' state_code, 'IRAI DE MINAS' city_code, '3131604' ibge_code from dual union
select 'MG' state_code, 'ITABIRA' city_code, '3131703' ibge_code from dual union
select 'MG' state_code, 'ITABIRINHA' city_code, '3131802' ibge_code from dual union
select 'MG' state_code, 'ITABIRITO' city_code, '3131901' ibge_code from dual union
select 'MG' state_code, 'ITACAMBIRA' city_code, '3132008' ibge_code from dual union
select 'MG' state_code, 'ITACARAMBI' city_code, '3132107' ibge_code from dual union
select 'MG' state_code, 'ITAGUARA' city_code, '3132206' ibge_code from dual union
select 'MG' state_code, 'ITAIPE' city_code, '3132305' ibge_code from dual union
select 'MG' state_code, 'ITAJUBA' city_code, '3132404' ibge_code from dual union
select 'MG' state_code, 'ITAMARANDIBA' city_code, '3132503' ibge_code from dual union
select 'MG' state_code, 'ITAMARATI DE MINAS' city_code, '3132602' ibge_code from dual union
select 'MG' state_code, 'ITAMBACURI' city_code, '3132701' ibge_code from dual union
select 'MG' state_code, 'ITAMBE DO MATO DENTRO' city_code, '3132800' ibge_code from dual union
select 'MG' state_code, 'ITAMOGI' city_code, '3132909' ibge_code from dual union
select 'MG' state_code, 'ITAMONTE' city_code, '3133006' ibge_code from dual union
select 'MG' state_code, 'ITANHANDU' city_code, '3133105' ibge_code from dual union
select 'MG' state_code, 'ITANHOMI' city_code, '3133204' ibge_code from dual union
select 'MG' state_code, 'ITAOBIM' city_code, '3133303' ibge_code from dual union
select 'MG' state_code, 'ITAPAGIPE' city_code, '3133402' ibge_code from dual union
select 'MG' state_code, 'ITAPECERICA' city_code, '3133501' ibge_code from dual union
select 'MG' state_code, 'ITAPEVA' city_code, '3133600' ibge_code from dual union
select 'MG' state_code, 'ITATIAIUCU' city_code, '3133709' ibge_code from dual union
select 'MG' state_code, 'ITAU DE MINAS' city_code, '3133758' ibge_code from dual union
select 'MG' state_code, 'ITAUNA' city_code, '3133808' ibge_code from dual union
select 'MG' state_code, 'ITAVERAVA' city_code, '3133907' ibge_code from dual union
select 'MG' state_code, 'ITINGA' city_code, '3134004' ibge_code from dual union
select 'MG' state_code, 'ITUETA' city_code, '3134103' ibge_code from dual union
select 'MG' state_code, 'ITUIUTABA' city_code, '3134202' ibge_code from dual union
select 'MG' state_code, 'ITUMIRIM' city_code, '3134301' ibge_code from dual union
select 'MG' state_code, 'ITURAMA' city_code, '3134400' ibge_code from dual union
select 'MG' state_code, 'ITUTINGA' city_code, '3134509' ibge_code from dual union
select 'MG' state_code, 'JABOTICATUBAS' city_code, '3134608' ibge_code from dual union
select 'MG' state_code, 'JACINTO' city_code, '3134707' ibge_code from dual union
select 'MG' state_code, 'JACUI' city_code, '3134806' ibge_code from dual union
select 'MG' state_code, 'JACUTINGA' city_code, '3134905' ibge_code from dual union
select 'MG' state_code, 'JAGUARACU' city_code, '3135001' ibge_code from dual union
select 'MG' state_code, 'JAIBA' city_code, '3135050' ibge_code from dual union
select 'MG' state_code, 'JAMPRUCA' city_code, '3135076' ibge_code from dual union
select 'MG' state_code, 'JANAUBA' city_code, '3135100' ibge_code from dual union
select 'MG' state_code, 'JANUARIA' city_code, '3135209' ibge_code from dual union
select 'MG' state_code, 'JAPARAIBA' city_code, '3135308' ibge_code from dual union
select 'MG' state_code, 'JAPONVAR' city_code, '3135357' ibge_code from dual union
select 'MG' state_code, 'JECEABA' city_code, '3135407' ibge_code from dual union
select 'MG' state_code, 'JENIPAPO DE MINAS' city_code, '3135456' ibge_code from dual union
select 'MG' state_code, 'JEQUERI' city_code, '3135506' ibge_code from dual union
select 'MG' state_code, 'JEQUITAI' city_code, '3135605' ibge_code from dual union
select 'MG' state_code, 'JEQUITIBA' city_code, '3135704' ibge_code from dual union
select 'MG' state_code, 'JEQUITINHONHA' city_code, '3135803' ibge_code from dual union
select 'MG' state_code, 'JESUANIA' city_code, '3135902' ibge_code from dual union
select 'MG' state_code, 'JOAIMA' city_code, '3136009' ibge_code from dual union
select 'MG' state_code, 'JOANESIA' city_code, '3136108' ibge_code from dual union
select 'MG' state_code, 'JOAO MONLEVADE' city_code, '3136207' ibge_code from dual union
select 'MG' state_code, 'JOAO PINHEIRO' city_code, '3136306' ibge_code from dual union
select 'MG' state_code, 'JOAQUIM FELICIO' city_code, '3136405' ibge_code from dual union
select 'MG' state_code, 'JORDANIA' city_code, '3136504' ibge_code from dual union
select 'MG' state_code, 'JOSE GONCALVES DE MINAS' city_code, '3136520' ibge_code from dual union
select 'MG' state_code, 'JOSE RAYDAN' city_code, '3136553' ibge_code from dual union
select 'MG' state_code, 'JOSENOPOLIS' city_code, '3136579' ibge_code from dual union
select 'MG' state_code, 'JUATUBA' city_code, '3136652' ibge_code from dual union
select 'MG' state_code, 'JUIZ DE FORA' city_code, '3136702' ibge_code from dual union
select 'MG' state_code, 'JURAMENTO' city_code, '3136801' ibge_code from dual union
select 'MG' state_code, 'JURUAIA' city_code, '3136900' ibge_code from dual union
select 'MG' state_code, 'JUVENILIA' city_code, '3136959' ibge_code from dual union
select 'MG' state_code, 'LADAINHA' city_code, '3137007' ibge_code from dual union
select 'MG' state_code, 'LAGAMAR' city_code, '3137106' ibge_code from dual union
select 'MG' state_code, 'LAGOA DA PRATA' city_code, '3137205' ibge_code from dual union
select 'MG' state_code, 'LAGOA DOS PATOS' city_code, '3137304' ibge_code from dual union
select 'MG' state_code, 'LAGOA DOURADA' city_code, '3137403' ibge_code from dual union
select 'MG' state_code, 'LAGOA FORMOSA' city_code, '3137502' ibge_code from dual union
select 'MG' state_code, 'LAGOA GRANDE' city_code, '3137536' ibge_code from dual union
select 'MG' state_code, 'LAGOA SANTA' city_code, '3137601' ibge_code from dual union
select 'MG' state_code, 'LAJINHA' city_code, '3137700' ibge_code from dual union
select 'MG' state_code, 'LAMBARI' city_code, '3137809' ibge_code from dual union
select 'MG' state_code, 'LAMIM' city_code, '3137908' ibge_code from dual union
select 'MG' state_code, 'LARANJAL' city_code, '3138005' ibge_code from dual union
select 'MG' state_code, 'LASSANCE' city_code, '3138104' ibge_code from dual union
select 'MG' state_code, 'LAVRAS' city_code, '3138203' ibge_code from dual union
select 'MG' state_code, 'LEANDRO FERREIRA' city_code, '3138302' ibge_code from dual union
select 'MG' state_code, 'LEME DO PRADO' city_code, '3138351' ibge_code from dual union
select 'MG' state_code, 'LEOPOLDINA' city_code, '3138401' ibge_code from dual union
select 'MG' state_code, 'LIBERDADE' city_code, '3138500' ibge_code from dual union
select 'MG' state_code, 'LIMA DUARTE' city_code, '3138609' ibge_code from dual union
select 'MG' state_code, 'LIMEIRA DO OESTE' city_code, '3138625' ibge_code from dual union
select 'MG' state_code, 'LONTRA' city_code, '3138658' ibge_code from dual union
select 'MG' state_code, 'LUISBURGO' city_code, '3138674' ibge_code from dual union
select 'MG' state_code, 'LUISLANDIA' city_code, '3138682' ibge_code from dual union
select 'MG' state_code, 'LUMINARIAS' city_code, '3138708' ibge_code from dual union
select 'MG' state_code, 'LUZ' city_code, '3138807' ibge_code from dual union
select 'MG' state_code, 'MACHACALIS' city_code, '3138906' ibge_code from dual union
select 'MG' state_code, 'MACHADO' city_code, '3139003' ibge_code from dual union
select 'MG' state_code, 'MADRE DE DEUS DE MINAS' city_code, '3139102' ibge_code from dual union
select 'MG' state_code, 'MALACACHETA' city_code, '3139201' ibge_code from dual union
select 'MG' state_code, 'MAMONAS' city_code, '3139250' ibge_code from dual union
select 'MG' state_code, 'MANGA' city_code, '3139300' ibge_code from dual union
select 'MG' state_code, 'MANHUACU' city_code, '3139409' ibge_code from dual union
select 'MG' state_code, 'MANHUMIRIM' city_code, '3139508' ibge_code from dual union
select 'MG' state_code, 'MANTENA' city_code, '3139607' ibge_code from dual union
select 'MG' state_code, 'MAR DE ESPANHA' city_code, '3139805' ibge_code from dual union
select 'MG' state_code, 'MARAVILHAS' city_code, '3139706' ibge_code from dual union
select 'MG' state_code, 'MARIA DA FE' city_code, '3139904' ibge_code from dual union
select 'MG' state_code, 'MARIANA' city_code, '3140001' ibge_code from dual union
select 'MG' state_code, 'MARILAC' city_code, '3140100' ibge_code from dual union
select 'MG' state_code, 'MARIO CAMPOS' city_code, '3140159' ibge_code from dual union
select 'MG' state_code, 'MARIPA DE MINAS' city_code, '3140209' ibge_code from dual union
select 'MG' state_code, 'MARLIERIA' city_code, '3140308' ibge_code from dual union
select 'MG' state_code, 'MARMELOPOLIS' city_code, '3140407' ibge_code from dual union
select 'MG' state_code, 'MARTINHO CAMPOS' city_code, '3140506' ibge_code from dual union
select 'MG' state_code, 'MARTINS SOARES' city_code, '3140530' ibge_code from dual union
select 'MG' state_code, 'MATA VERDE' city_code, '3140555' ibge_code from dual union
select 'MG' state_code, 'MATERLANDIA' city_code, '3140605' ibge_code from dual union
select 'MG' state_code, 'MATEUS LEME' city_code, '3140704' ibge_code from dual union
select 'MG' state_code, 'MATHIAS LOBATO' city_code, '3171501' ibge_code from dual union
select 'MG' state_code, 'MATIAS BARBOSA' city_code, '3140803' ibge_code from dual union
select 'MG' state_code, 'MATIAS CARDOSO' city_code, '3140852' ibge_code from dual union
select 'MG' state_code, 'MATIPO' city_code, '3140902' ibge_code from dual union
select 'MG' state_code, 'MATO VERDE' city_code, '3141009' ibge_code from dual union
select 'MG' state_code, 'MATOZINHOS' city_code, '3141108' ibge_code from dual union
select 'MG' state_code, 'MATUTINA' city_code, '3141207' ibge_code from dual union
select 'MG' state_code, 'MEDEIROS' city_code, '3141306' ibge_code from dual union
select 'MG' state_code, 'MEDINA' city_code, '3141405' ibge_code from dual union
select 'MG' state_code, 'MENDES PIMENTEL' city_code, '3141504' ibge_code from dual union
select 'MG' state_code, 'MERCES' city_code, '3141603' ibge_code from dual union
select 'MG' state_code, 'MESQUITA' city_code, '3141702' ibge_code from dual union
select 'MG' state_code, 'MINAS NOVAS' city_code, '3141801' ibge_code from dual union
select 'MG' state_code, 'MINDURI' city_code, '3141900' ibge_code from dual union
select 'MG' state_code, 'MIRABELA' city_code, '3142007' ibge_code from dual union
select 'MG' state_code, 'MIRADOURO' city_code, '3142106' ibge_code from dual union
select 'MG' state_code, 'MIRAI' city_code, '3142205' ibge_code from dual union
select 'MG' state_code, 'MIRAVANIA' city_code, '3142254' ibge_code from dual union
select 'MG' state_code, 'MOEDA' city_code, '3142304' ibge_code from dual union
select 'MG' state_code, 'MOEMA' city_code, '3142403' ibge_code from dual union
select 'MG' state_code, 'MONJOLOS' city_code, '3142502' ibge_code from dual union
select 'MG' state_code, 'MONSENHOR PAULO' city_code, '3142601' ibge_code from dual union
select 'MG' state_code, 'MONTALVANIA' city_code, '3142700' ibge_code from dual union
select 'MG' state_code, 'MONTE ALEGRE DE MINAS' city_code, '3142809' ibge_code from dual union
select 'MG' state_code, 'MONTE AZUL' city_code, '3142908' ibge_code from dual union
select 'MG' state_code, 'MONTE BELO' city_code, '3143005' ibge_code from dual union
select 'MG' state_code, 'MONTE CARMELO' city_code, '3143104' ibge_code from dual union
select 'MG' state_code, 'MONTE FORMOSO' city_code, '3143153' ibge_code from dual union
select 'MG' state_code, 'MONTE SANTO DE MINAS' city_code, '3143203' ibge_code from dual union
select 'MG' state_code, 'MONTE SIAO' city_code, '3143401' ibge_code from dual union
select 'MG' state_code, 'MONTES CLAROS' city_code, '3143302' ibge_code from dual union
select 'MG' state_code, 'MONTEZUMA' city_code, '3143450' ibge_code from dual union
select 'MG' state_code, 'MORADA NOVA DE MINAS' city_code, '3143500' ibge_code from dual union
select 'MG' state_code, 'MORRO DA GARCA' city_code, '3143609' ibge_code from dual union
select 'MG' state_code, 'MORRO DO PILAR' city_code, '3143708' ibge_code from dual union
select 'MG' state_code, 'MUNHOZ' city_code, '3143807' ibge_code from dual union
select 'MG' state_code, 'MURIAE' city_code, '3143906' ibge_code from dual union
select 'MG' state_code, 'MUTUM' city_code, '3144003' ibge_code from dual union
select 'MG' state_code, 'MUZAMBINHO' city_code, '3144102' ibge_code from dual union
select 'MG' state_code, 'NACIP RAYDAN' city_code, '3144201' ibge_code from dual union
select 'MG' state_code, 'NANUQUE' city_code, '3144300' ibge_code from dual union
select 'MG' state_code, 'NAQUE' city_code, '3144359' ibge_code from dual union
select 'MG' state_code, 'NATALANDIA' city_code, '3144375' ibge_code from dual union
select 'MG' state_code, 'NATERCIA' city_code, '3144409' ibge_code from dual union
select 'MG' state_code, 'NAZARENO' city_code, '3144508' ibge_code from dual union
select 'MG' state_code, 'NEPOMUCENO' city_code, '3144607' ibge_code from dual union
select 'MG' state_code, 'NINHEIRA' city_code, '3144656' ibge_code from dual union
select 'MG' state_code, 'NOVA BELEM' city_code, '3144672' ibge_code from dual union
select 'MG' state_code, 'NOVA ERA' city_code, '3144706' ibge_code from dual union
select 'MG' state_code, 'NOVA LIMA' city_code, '3144805' ibge_code from dual union
select 'MG' state_code, 'NOVA MODICA' city_code, '3144904' ibge_code from dual union
select 'MG' state_code, 'NOVA PONTE' city_code, '3145000' ibge_code from dual union
select 'MG' state_code, 'NOVA PORTEIRINHA' city_code, '3145059' ibge_code from dual union
select 'MG' state_code, 'NOVA RESENDE' city_code, '3145109' ibge_code from dual union
select 'MG' state_code, 'NOVA SERRANA' city_code, '3145208' ibge_code from dual union
select 'MG' state_code, 'NOVA UNIAO' city_code, '3136603' ibge_code from dual union
select 'MG' state_code, 'NOVO CRUZEIRO' city_code, '3145307' ibge_code from dual union
select 'MG' state_code, 'NOVO ORIENTE DE MINAS' city_code, '3145356' ibge_code from dual union
select 'MG' state_code, 'NOVORIZONTE' city_code, '3145372' ibge_code from dual union
select 'MG' state_code, 'OLARIA' city_code, '3145406' ibge_code from dual union
select 'MG' state_code, 'OLHOS-D''AGUA' city_code, '3145455' ibge_code from dual union
select 'MG' state_code, 'OLIMPIO NORONHA' city_code, '3145505' ibge_code from dual union
select 'MG' state_code, 'OLIVEIRA' city_code, '3145604' ibge_code from dual union
select 'MG' state_code, 'OLIVEIRA FORTES' city_code, '3145703' ibge_code from dual union
select 'MG' state_code, 'ONCA DE PITANGUI' city_code, '3145802' ibge_code from dual union
select 'MG' state_code, 'ORATORIOS' city_code, '3145851' ibge_code from dual union
select 'MG' state_code, 'ORIZANIA' city_code, '3145877' ibge_code from dual union
select 'MG' state_code, 'OURO BRANCO' city_code, '3145901' ibge_code from dual union
select 'MG' state_code, 'OURO FINO' city_code, '3146008' ibge_code from dual union
select 'MG' state_code, 'OURO PRETO' city_code, '3146107' ibge_code from dual union
select 'MG' state_code, 'OURO VERDE DE MINAS' city_code, '3146206' ibge_code from dual union
select 'MG' state_code, 'PADRE CARVALHO' city_code, '3146255' ibge_code from dual union
select 'MG' state_code, 'PADRE PARAISO' city_code, '3146305' ibge_code from dual union
select 'MG' state_code, 'PAI PEDRO' city_code, '3146552' ibge_code from dual union
select 'MG' state_code, 'PAINEIRAS' city_code, '3146404' ibge_code from dual union
select 'MG' state_code, 'PAINS' city_code, '3146503' ibge_code from dual union
select 'MG' state_code, 'PAIVA' city_code, '3146602' ibge_code from dual union
select 'MG' state_code, 'PALMA' city_code, '3146701' ibge_code from dual union
select 'MG' state_code, 'PALMOPOLIS' city_code, '3146750' ibge_code from dual union
select 'MG' state_code, 'PAPAGAIOS' city_code, '3146909' ibge_code from dual union
select 'MG' state_code, 'PARA DE MINAS' city_code, '3147105' ibge_code from dual union
select 'MG' state_code, 'PARACATU' city_code, '3147006' ibge_code from dual union
select 'MG' state_code, 'PARAGUACU' city_code, '3147204' ibge_code from dual union
select 'MG' state_code, 'PARAISOPOLIS' city_code, '3147303' ibge_code from dual union
select 'MG' state_code, 'PARAOPEBA' city_code, '3147402' ibge_code from dual union
select 'MG' state_code, 'PASSA QUATRO' city_code, '3147600' ibge_code from dual union
select 'MG' state_code, 'PASSA TEMPO' city_code, '3147709' ibge_code from dual union
select 'MG' state_code, 'PASSA VINTE' city_code, '3147808' ibge_code from dual union
select 'MG' state_code, 'PASSABEM' city_code, '3147501' ibge_code from dual union
select 'MG' state_code, 'PASSOS' city_code, '3147907' ibge_code from dual union
select 'MG' state_code, 'PATIS' city_code, '3147956' ibge_code from dual union
select 'MG' state_code, 'PATOS DE MINAS' city_code, '3148004' ibge_code from dual union
select 'MG' state_code, 'PATROCINIO' city_code, '3148103' ibge_code from dual union
select 'MG' state_code, 'PATROCINIO DO MURIAE' city_code, '3148202' ibge_code from dual union
select 'MG' state_code, 'PAULA CANDIDO' city_code, '3148301' ibge_code from dual union
select 'MG' state_code, 'PAULISTAS' city_code, '3148400' ibge_code from dual union
select 'MG' state_code, 'PAVAO' city_code, '3148509' ibge_code from dual union
select 'MG' state_code, 'PECANHA' city_code, '3148608' ibge_code from dual union
select 'MG' state_code, 'PEDRA AZUL' city_code, '3148707' ibge_code from dual union
select 'MG' state_code, 'PEDRA BONITA' city_code, '3148756' ibge_code from dual union
select 'MG' state_code, 'PEDRA DO ANTA' city_code, '3148806' ibge_code from dual union
select 'MG' state_code, 'PEDRA DO INDAIA' city_code, '3148905' ibge_code from dual union
select 'MG' state_code, 'PEDRA DOURADA' city_code, '3149002' ibge_code from dual union
select 'MG' state_code, 'PEDRALVA' city_code, '3149101' ibge_code from dual union
select 'MG' state_code, 'PEDRAS DE MARIA DA CRUZ' city_code, '3149150' ibge_code from dual union
select 'MG' state_code, 'PEDRINOPOLIS' city_code, '3149200' ibge_code from dual union
select 'MG' state_code, 'PEDRO LEOPOLDO' city_code, '3149309' ibge_code from dual union
select 'MG' state_code, 'PEDRO TEIXEIRA' city_code, '3149408' ibge_code from dual union
select 'MG' state_code, 'PEQUERI' city_code, '3149507' ibge_code from dual union
select 'MG' state_code, 'PEQUI' city_code, '3149606' ibge_code from dual union
select 'MG' state_code, 'PERDIGAO' city_code, '3149705' ibge_code from dual union
select 'MG' state_code, 'PERDIZES' city_code, '3149804' ibge_code from dual union
select 'MG' state_code, 'PERDÕES' city_code, '3149903' ibge_code from dual union
select 'MG' state_code, 'PERIQUITO' city_code, '3149952' ibge_code from dual union
select 'MG' state_code, 'PESCADOR' city_code, '3150000' ibge_code from dual union
select 'MG' state_code, 'PIAU' city_code, '3150109' ibge_code from dual union
select 'MG' state_code, 'PIEDADE DE CARATINGA' city_code, '3150158' ibge_code from dual union
select 'MG' state_code, 'PIEDADE DE PONTE NOVA' city_code, '3150208' ibge_code from dual union
select 'MG' state_code, 'PIEDADE DO RIO GRANDE' city_code, '3150307' ibge_code from dual union
select 'MG' state_code, 'PIEDADE DOS GERAIS' city_code, '3150406' ibge_code from dual union
select 'MG' state_code, 'PIMENTA' city_code, '3150505' ibge_code from dual union
select 'MG' state_code, 'PINGO D''AGUA' city_code, '3150539' ibge_code from dual union
select 'MG' state_code, 'PINTOPOLIS' city_code, '3150570' ibge_code from dual union
select 'MG' state_code, 'PIRACEMA' city_code, '3150604' ibge_code from dual union
select 'MG' state_code, 'PIRAJUBA' city_code, '3150703' ibge_code from dual union
select 'MG' state_code, 'PIRANGA' city_code, '3150802' ibge_code from dual union
select 'MG' state_code, 'PIRANGUCU' city_code, '3150901' ibge_code from dual union
select 'MG' state_code, 'PIRANGUINHO' city_code, '3151008' ibge_code from dual union
select 'MG' state_code, 'PIRAPETINGA' city_code, '3151107' ibge_code from dual union
select 'MG' state_code, 'PIRAPORA' city_code, '3151206' ibge_code from dual union
select 'MG' state_code, 'PIRAUBA' city_code, '3151305' ibge_code from dual union
select 'MG' state_code, 'PITANGUI' city_code, '3151404' ibge_code from dual union
select 'MG' state_code, 'PIUMHI' city_code, '3151503' ibge_code from dual union
select 'MG' state_code, 'PLANURA' city_code, '3151602' ibge_code from dual union
select 'MG' state_code, 'POCO FUNDO' city_code, '3151701' ibge_code from dual union
select 'MG' state_code, 'POCOS DE CALDAS' city_code, '3151800' ibge_code from dual union
select 'MG' state_code, 'POCRANE' city_code, '3151909' ibge_code from dual union
select 'MG' state_code, 'POMPEU' city_code, '3152006' ibge_code from dual union
select 'MG' state_code, 'PONTE NOVA' city_code, '3152105' ibge_code from dual union
select 'MG' state_code, 'PONTO CHIQUE' city_code, '3152131' ibge_code from dual union
select 'MG' state_code, 'PONTO DOS VOLANTES' city_code, '3152170' ibge_code from dual union
select 'MG' state_code, 'PORTEIRINHA' city_code, '3152204' ibge_code from dual union
select 'MG' state_code, 'PORTO FIRME' city_code, '3152303' ibge_code from dual union
select 'MG' state_code, 'POTE' city_code, '3152402' ibge_code from dual union
select 'MG' state_code, 'POUSO ALEGRE' city_code, '3152501' ibge_code from dual union
select 'MG' state_code, 'POUSO ALTO' city_code, '3152600' ibge_code from dual union
select 'MG' state_code, 'PRADOS' city_code, '3152709' ibge_code from dual union
select 'MG' state_code, 'PRATA' city_code, '3152808' ibge_code from dual union
select 'MG' state_code, 'PRATAPOLIS' city_code, '3152907' ibge_code from dual union
select 'MG' state_code, 'PRATINHA' city_code, '3153004' ibge_code from dual union
select 'MG' state_code, 'PRESIDENTE BERNARDES' city_code, '3153103' ibge_code from dual union
select 'MG' state_code, 'PRESIDENTE JUSCELINO' city_code, '3153202' ibge_code from dual union
select 'MG' state_code, 'PRESIDENTE KUBITSCHEK' city_code, '3153301' ibge_code from dual union
select 'MG' state_code, 'PRESIDENTE OLEGARIO' city_code, '3153400' ibge_code from dual union
select 'MG' state_code, 'PRUDENTE DE MORAIS' city_code, '3153608' ibge_code from dual union
select 'MG' state_code, 'QUARTEL GERAL' city_code, '3153707' ibge_code from dual union
select 'MG' state_code, 'QUELUZITO' city_code, '3153806' ibge_code from dual union
select 'MG' state_code, 'RAPOSOS' city_code, '3153905' ibge_code from dual union
select 'MG' state_code, 'RAUL SOARES' city_code, '3154002' ibge_code from dual union
select 'MG' state_code, 'RECREIO' city_code, '3154101' ibge_code from dual union
select 'MG' state_code, 'REDUTO' city_code, '3154150' ibge_code from dual union
select 'MG' state_code, 'RESENDE COSTA' city_code, '3154200' ibge_code from dual union
select 'MG' state_code, 'RESPLENDOR' city_code, '3154309' ibge_code from dual union
select 'MG' state_code, 'RESSAQUINHA' city_code, '3154408' ibge_code from dual union
select 'MG' state_code, 'RIACHINHO' city_code, '3154457' ibge_code from dual union
select 'MG' state_code, 'RIACHO DOS MACHADOS' city_code, '3154507' ibge_code from dual union
select 'MG' state_code, 'RIBEIRAO DAS NEVES' city_code, '3154606' ibge_code from dual union
select 'MG' state_code, 'RIBEIRAO VERMELHO' city_code, '3154705' ibge_code from dual union
select 'MG' state_code, 'RIO ACIMA' city_code, '3154804' ibge_code from dual union
select 'MG' state_code, 'RIO CASCA' city_code, '3154903' ibge_code from dual union
select 'MG' state_code, 'RIO DO PRADO' city_code, '3155108' ibge_code from dual union
select 'MG' state_code, 'RIO DOCE' city_code, '3155009' ibge_code from dual union
select 'MG' state_code, 'RIO ESPERA' city_code, '3155207' ibge_code from dual union
select 'MG' state_code, 'RIO MANSO' city_code, '3155306' ibge_code from dual union
select 'MG' state_code, 'RIO NOVO' city_code, '3155405' ibge_code from dual union
select 'MG' state_code, 'RIO PARANAIBA' city_code, '3155504' ibge_code from dual union
select 'MG' state_code, 'RIO PARDO DE MINAS' city_code, '3155603' ibge_code from dual union
select 'MG' state_code, 'RIO PIRACICABA' city_code, '3155702' ibge_code from dual union
select 'MG' state_code, 'RIO POMBA' city_code, '3155801' ibge_code from dual union
select 'MG' state_code, 'RIO PRETO' city_code, '3155900' ibge_code from dual union
select 'MG' state_code, 'RIO VERMELHO' city_code, '3156007' ibge_code from dual union
select 'MG' state_code, 'RITAPOLIS' city_code, '3156106' ibge_code from dual union
select 'MG' state_code, 'ROCHEDO DE MINAS' city_code, '3156205' ibge_code from dual union
select 'MG' state_code, 'RODEIRO' city_code, '3156304' ibge_code from dual union
select 'MG' state_code, 'ROMARIA' city_code, '3156403' ibge_code from dual union
select 'MG' state_code, 'ROSARIO DA LIMEIRA' city_code, '3156452' ibge_code from dual union
select 'MG' state_code, 'RUBELITA' city_code, '3156502' ibge_code from dual union
select 'MG' state_code, 'RUBIM' city_code, '3156601' ibge_code from dual union
select 'MG' state_code, 'SABARA' city_code, '3156700' ibge_code from dual union
select 'MG' state_code, 'SABINOPOLIS' city_code, '3156809' ibge_code from dual union
select 'MG' state_code, 'SACRAMENTO' city_code, '3156908' ibge_code from dual union
select 'MG' state_code, 'SALINAS' city_code, '3157005' ibge_code from dual union
select 'MG' state_code, 'SALTO DA DIVISA' city_code, '3157104' ibge_code from dual union
select 'MG' state_code, 'SANTA BARBARA' city_code, '3157203' ibge_code from dual union
select 'MG' state_code, 'SANTA BARBARA DO LESTE' city_code, '3157252' ibge_code from dual union
select 'MG' state_code, 'SANTA BARBARA DO MONTE VERDE' city_code, '3157278' ibge_code from dual union
select 'MG' state_code, 'SANTA BARBARA DO TUGURIO' city_code, '3157302' ibge_code from dual union
select 'MG' state_code, 'SANTA CRUZ DE MINAS' city_code, '3157336' ibge_code from dual union
select 'MG' state_code, 'SANTA CRUZ DE SALINAS' city_code, '3157377' ibge_code from dual union
select 'MG' state_code, 'SANTA CRUZ DO ESCALVADO' city_code, '3157401' ibge_code from dual union
select 'MG' state_code, 'SANTA EFIGENIA DE MINAS' city_code, '3157500' ibge_code from dual union
select 'MG' state_code, 'SANTA FE DE MINAS' city_code, '3157609' ibge_code from dual union
select 'MG' state_code, 'SANTA HELENA DE MINAS' city_code, '3157658' ibge_code from dual union
select 'MG' state_code, 'SANTA JULIANA' city_code, '3157708' ibge_code from dual union
select 'MG' state_code, 'SANTA LUZIA' city_code, '3157807' ibge_code from dual union
select 'MG' state_code, 'SANTA MARGARIDA' city_code, '3157906' ibge_code from dual union
select 'MG' state_code, 'SANTA MARIA DE ITABIRA' city_code, '3158003' ibge_code from dual union
select 'MG' state_code, 'SANTA MARIA DO SALTO' city_code, '3158102' ibge_code from dual union
select 'MG' state_code, 'SANTA MARIA DO SUACUI' city_code, '3158201' ibge_code from dual union
select 'MG' state_code, 'SANTA RITA DE CALDAS' city_code, '3159209' ibge_code from dual union
select 'MG' state_code, 'SANTA RITA DE IBITIPOCA' city_code, '3159407' ibge_code from dual union
select 'MG' state_code, 'SANTA RITA DE JACUTINGA' city_code, '3159308' ibge_code from dual union
select 'MG' state_code, 'SANTA RITA DE MINAS' city_code, '3159357' ibge_code from dual union
select 'MG' state_code, 'SANTA RITA DO ITUETO' city_code, '3159506' ibge_code from dual union
select 'MG' state_code, 'SANTA RITA DO SAPUCAI' city_code, '3159605' ibge_code from dual union
select 'MG' state_code, 'SANTA ROSA DA SERRA' city_code, '3159704' ibge_code from dual union
select 'MG' state_code, 'SANTA VITORIA' city_code, '3159803' ibge_code from dual union
select 'MG' state_code, 'SANTANA DA VARGEM' city_code, '3158300' ibge_code from dual union
select 'MG' state_code, 'SANTANA DE CATAGUASES' city_code, '3158409' ibge_code from dual union
select 'MG' state_code, 'SANTANA DE PIRAPAMA' city_code, '3158508' ibge_code from dual union
select 'MG' state_code, 'SANTANA DO DESERTO' city_code, '3158607' ibge_code from dual union
select 'MG' state_code, 'SANTANA DO GARAMBEU' city_code, '3158706' ibge_code from dual union
select 'MG' state_code, 'SANTANA DO JACARE' city_code, '3158805' ibge_code from dual union
select 'MG' state_code, 'SANTANA DO MANHUACU' city_code, '3158904' ibge_code from dual union
select 'MG' state_code, 'SANTANA DO PARAISO' city_code, '3158953' ibge_code from dual union
select 'MG' state_code, 'SANTANA DO RIACHO' city_code, '3159001' ibge_code from dual union
select 'MG' state_code, 'SANTANA DOS MONTES' city_code, '3159100' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO AMPARO' city_code, '3159902' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO AVENTUREIRO' city_code, '3160009' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO GRAMA' city_code, '3160108' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO ITAMBE' city_code, '3160207' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO JACINTO' city_code, '3160306' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO MONTE' city_code, '3160405' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO RETIRO' city_code, '3160454' ibge_code from dual union
select 'MG' state_code, 'SANTO ANTONIO DO RIO ABAIXO' city_code, '3160504' ibge_code from dual union
select 'MG' state_code, 'SANTO HIPOLITO' city_code, '3160603' ibge_code from dual union
select 'MG' state_code, 'SANTOS DUMONT' city_code, '3160702' ibge_code from dual union
select 'MG' state_code, 'SAO BENTO ABADE' city_code, '3160801' ibge_code from dual union
select 'MG' state_code, 'SAO BRAS DO SUACUI' city_code, '3160900' ibge_code from dual union
select 'MG' state_code, 'SAO DOMINGOS DAS DORES' city_code, '3160959' ibge_code from dual union
select 'MG' state_code, 'SAO DOMINGOS DO PRATA' city_code, '3161007' ibge_code from dual union
select 'MG' state_code, 'SAO FELIX DE MINAS' city_code, '3161056' ibge_code from dual union
select 'MG' state_code, 'SAO FRANCISCO' city_code, '3161106' ibge_code from dual union
select 'MG' state_code, 'SAO FRANCISCO DE PAULA' city_code, '3161205' ibge_code from dual union
select 'MG' state_code, 'SAO FRANCISCO DE SALES' city_code, '3161304' ibge_code from dual union
select 'MG' state_code, 'SAO FRANCISCO DO GLORIA' city_code, '3161403' ibge_code from dual union
select 'MG' state_code, 'SAO GERALDO' city_code, '3161502' ibge_code from dual union
select 'MG' state_code, 'SAO GERALDO DA PIEDADE' city_code, '3161601' ibge_code from dual union
select 'MG' state_code, 'SAO GERALDO DO BAIXIO' city_code, '3161650' ibge_code from dual union
select 'MG' state_code, 'SAO GONCALO DO ABAETE' city_code, '3161700' ibge_code from dual union
select 'MG' state_code, 'SAO GONCALO DO PARA' city_code, '3161809' ibge_code from dual union
select 'MG' state_code, 'SAO GONCALO DO RIO ABAIXO' city_code, '3161908' ibge_code from dual union
select 'MG' state_code, 'SAO GONCALO DO RIO PRETO' city_code, '3125507' ibge_code from dual union
select 'MG' state_code, 'SAO GONCALO DO SAPUCAI' city_code, '3162005' ibge_code from dual union
select 'MG' state_code, 'SAO GOTARDO' city_code, '3162104' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO BATISTA DO GLORIA' city_code, '3162203' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DA LAGOA' city_code, '3162252' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DA MATA' city_code, '3162302' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DA PONTE' city_code, '3162401' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DAS MISSÕES' city_code, '3162450' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DEL REI' city_code, '3162500' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DO MANHUACU' city_code, '3162559' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DO MANTENINHA' city_code, '3162575' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DO ORIENTE' city_code, '3162609' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DO PACUI' city_code, '3162658' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO DO PARAISO' city_code, '3162708' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO EVANGELISTA' city_code, '3162807' ibge_code from dual union
select 'MG' state_code, 'SAO JOAO NEPOMUCENO' city_code, '3162906' ibge_code from dual union
select 'MG' state_code, 'SAO JOAQUIM DE BICAS' city_code, '3162922' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DA BARRA' city_code, '3162948' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DA LAPA' city_code, '3162955' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DA SAFIRA' city_code, '3163003' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DA VARGINHA' city_code, '3163102' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DO ALEGRE' city_code, '3163201' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DO DIVINO' city_code, '3163300' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DO GOIABAL' city_code, '3163409' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DO JACURI' city_code, '3163508' ibge_code from dual union
select 'MG' state_code, 'SAO JOSE DO MANTIMENTO' city_code, '3163607' ibge_code from dual union
select 'MG' state_code, 'SAO LOURENCO' city_code, '3163706' ibge_code from dual union
select 'MG' state_code, 'SAO MIGUEL DO ANTA' city_code, '3163805' ibge_code from dual union
select 'MG' state_code, 'SAO PEDRO DA UNIAO' city_code, '3163904' ibge_code from dual union
select 'MG' state_code, 'SAO PEDRO DO SUACUI' city_code, '3164100' ibge_code from dual union
select 'MG' state_code, 'SAO PEDRO DOS FERROS' city_code, '3164001' ibge_code from dual union
select 'MG' state_code, 'SAO ROMAO' city_code, '3164209' ibge_code from dual union
select 'MG' state_code, 'SAO ROQUE DE MINAS' city_code, '3164308' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DA BELA VISTA' city_code, '3164407' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DA VARGEM ALEGRE' city_code, '3164431' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DO ANTA' city_code, '3164472' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DO MARANHAO' city_code, '3164506' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DO OESTE' city_code, '3164605' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DO PARAISO' city_code, '3164704' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DO RIO PRETO' city_code, '3164803' ibge_code from dual union
select 'MG' state_code, 'SAO SEBASTIAO DO RIO VERDE' city_code, '3164902' ibge_code from dual union
select 'MG' state_code, 'SAO THOME DAS LETRAS' city_code, '3165206' ibge_code from dual union
select 'MG' state_code, 'SAO TIAGO' city_code, '3165008' ibge_code from dual union
select 'MG' state_code, 'SAO TOMAS DE AQUINO' city_code, '3165107' ibge_code from dual union
select 'MG' state_code, 'SAO VICENTE DE MINAS' city_code, '3165305' ibge_code from dual union
select 'MG' state_code, 'SAPUCAI-MIRIM' city_code, '3165404' ibge_code from dual union
select 'MG' state_code, 'SARDOA' city_code, '3165503' ibge_code from dual union
select 'MG' state_code, 'SARZEDO' city_code, '3165537' ibge_code from dual union
select 'MG' state_code, 'SEM-PEIXE' city_code, '3165560' ibge_code from dual union
select 'MG' state_code, 'SENADOR AMARAL' city_code, '3165578' ibge_code from dual union
select 'MG' state_code, 'SENADOR CORTES' city_code, '3165602' ibge_code from dual union
select 'MG' state_code, 'SENADOR FIRMINO' city_code, '3165701' ibge_code from dual union
select 'MG' state_code, 'SENADOR JOSE BENTO' city_code, '3165800' ibge_code from dual union
select 'MG' state_code, 'SENADOR MODESTINO GONCALVES' city_code, '3165909' ibge_code from dual union
select 'MG' state_code, 'SENHORA DE OLIVEIRA' city_code, '3166006' ibge_code from dual union
select 'MG' state_code, 'SENHORA DO PORTO' city_code, '3166105' ibge_code from dual union
select 'MG' state_code, 'SENHORA DOS REMEDIOS' city_code, '3166204' ibge_code from dual union
select 'MG' state_code, 'SERICITA' city_code, '3166303' ibge_code from dual union
select 'MG' state_code, 'SERITINGA' city_code, '3166402' ibge_code from dual union
select 'MG' state_code, 'SERRA AZUL DE MINAS' city_code, '3166501' ibge_code from dual union
select 'MG' state_code, 'SERRA DA SAUDADE' city_code, '3166600' ibge_code from dual union
select 'MG' state_code, 'SERRA DO SALITRE' city_code, '3166808' ibge_code from dual union
select 'MG' state_code, 'SERRA DOS AIMORES' city_code, '3166709' ibge_code from dual union
select 'MG' state_code, 'SERRANIA' city_code, '3166907' ibge_code from dual union
select 'MG' state_code, 'SERRANOPOLIS DE MINAS' city_code, '3166956' ibge_code from dual union
select 'MG' state_code, 'SERRANOS' city_code, '3167004' ibge_code from dual union
select 'MG' state_code, 'SERRO' city_code, '3167103' ibge_code from dual union
select 'MG' state_code, 'SETE LAGOAS' city_code, '3167202' ibge_code from dual union
select 'MG' state_code, 'SETUBINHA' city_code, '3165552' ibge_code from dual union
select 'MG' state_code, 'SILVEIRANIA' city_code, '3167301' ibge_code from dual union
select 'MG' state_code, 'SILVIANOPOLIS' city_code, '3167400' ibge_code from dual union
select 'MG' state_code, 'SIMAO PEREIRA' city_code, '3167509' ibge_code from dual union
select 'MG' state_code, 'SIMONESIA' city_code, '3167608' ibge_code from dual union
select 'MG' state_code, 'SOBRALIA' city_code, '3167707' ibge_code from dual union
select 'MG' state_code, 'SOLEDADE DE MINAS' city_code, '3167806' ibge_code from dual union
select 'MG' state_code, 'TABULEIRO' city_code, '3167905' ibge_code from dual union
select 'MG' state_code, 'TAIOBEIRAS' city_code, '3168002' ibge_code from dual union
select 'MG' state_code, 'TAPARUBA' city_code, '3168051' ibge_code from dual union
select 'MG' state_code, 'TAPIRA' city_code, '3168101' ibge_code from dual union
select 'MG' state_code, 'TAPIRAI' city_code, '3168200' ibge_code from dual union
select 'MG' state_code, 'TAQUARACU DE MINAS' city_code, '3168309' ibge_code from dual union
select 'MG' state_code, 'TARUMIRIM' city_code, '3168408' ibge_code from dual union
select 'MG' state_code, 'TEIXEIRAS' city_code, '3168507' ibge_code from dual union
select 'MG' state_code, 'TEOFILO OTONI' city_code, '3168606' ibge_code from dual union
select 'MG' state_code, 'TIMOTEO' city_code, '3168705' ibge_code from dual union
select 'MG' state_code, 'TIRADENTES' city_code, '3168804' ibge_code from dual union
select 'MG' state_code, 'TIROS' city_code, '3168903' ibge_code from dual union
select 'MG' state_code, 'TOCANTINS' city_code, '3169000' ibge_code from dual union
select 'MG' state_code, 'TOCOS DO MOJI' city_code, '3169059' ibge_code from dual union
select 'MG' state_code, 'TOLEDO' city_code, '3169109' ibge_code from dual union
select 'MG' state_code, 'TOMBOS' city_code, '3169208' ibge_code from dual union
select 'MG' state_code, 'TRES CORACÕES' city_code, '3169307' ibge_code from dual union
select 'MG' state_code, 'TRES MARIAS' city_code, '3169356' ibge_code from dual union
select 'MG' state_code, 'TRES PONTAS' city_code, '3169406' ibge_code from dual union
select 'MG' state_code, 'TUMIRITINGA' city_code, '3169505' ibge_code from dual union
select 'MG' state_code, 'TUPACIGUARA' city_code, '3169604' ibge_code from dual union
select 'MG' state_code, 'TURMALINA' city_code, '3169703' ibge_code from dual union
select 'MG' state_code, 'TURVOLANDIA' city_code, '3169802' ibge_code from dual union
select 'MG' state_code, 'UBA' city_code, '3169901' ibge_code from dual union
select 'MG' state_code, 'UBAI' city_code, '3170008' ibge_code from dual union
select 'MG' state_code, 'UBAPORANGA' city_code, '3170057' ibge_code from dual union
select 'MG' state_code, 'UBERABA' city_code, '3170107' ibge_code from dual union
select 'MG' state_code, 'UBERLANDIA' city_code, '3170206' ibge_code from dual union
select 'MG' state_code, 'UMBURATIBA' city_code, '3170305' ibge_code from dual union
select 'MG' state_code, 'UNAI' city_code, '3170404' ibge_code from dual union
select 'MG' state_code, 'UNIAO DE MINAS' city_code, '3170438' ibge_code from dual union
select 'MG' state_code, 'URUANA DE MINAS' city_code, '3170479' ibge_code from dual union
select 'MG' state_code, 'URUCANIA' city_code, '3170503' ibge_code from dual union
select 'MG' state_code, 'URUCUIA' city_code, '3170529' ibge_code from dual union
select 'MG' state_code, 'VARGEM ALEGRE' city_code, '3170578' ibge_code from dual union
select 'MG' state_code, 'VARGEM BONITA' city_code, '3170602' ibge_code from dual union
select 'MG' state_code, 'VARGEM GRANDE DO RIO PARDO' city_code, '3170651' ibge_code from dual union
select 'MG' state_code, 'VARGINHA' city_code, '3170701' ibge_code from dual union
select 'MG' state_code, 'VARJAO DE MINAS' city_code, '3170750' ibge_code from dual union
select 'MG' state_code, 'VARZEA DA PALMA' city_code, '3170800' ibge_code from dual union
select 'MG' state_code, 'VARZELANDIA' city_code, '3170909' ibge_code from dual union
select 'MG' state_code, 'VAZANTE' city_code, '3171006' ibge_code from dual union
select 'MG' state_code, 'VERDELANDIA' city_code, '3171030' ibge_code from dual union
select 'MG' state_code, 'VEREDINHA' city_code, '3171071' ibge_code from dual union
select 'MG' state_code, 'VERISSIMO' city_code, '3171105' ibge_code from dual union
select 'MG' state_code, 'VERMELHO NOVO' city_code, '3171154' ibge_code from dual union
select 'MG' state_code, 'VESPASIANO' city_code, '3171204' ibge_code from dual union
select 'MG' state_code, 'VICOSA' city_code, '3171303' ibge_code from dual union
select 'MG' state_code, 'VIEIRAS' city_code, '3171402' ibge_code from dual union
select 'MG' state_code, 'VIRGEM DA LAPA' city_code, '3171600' ibge_code from dual union
select 'MG' state_code, 'VIRGINIA' city_code, '3171709' ibge_code from dual union
select 'MG' state_code, 'VIRGINOPOLIS' city_code, '3171808' ibge_code from dual union
select 'MG' state_code, 'VIRGOLANDIA' city_code, '3171907' ibge_code from dual union
select 'MG' state_code, 'VISCONDE DO RIO BRANCO' city_code, '3172004' ibge_code from dual union
select 'MG' state_code, 'VOLTA GRANDE' city_code, '3172103' ibge_code from dual union
select 'MG' state_code, 'WENCESLAU BRAZ' city_code, '3172202' ibge_code from dual union
select 'ES' state_code, 'AFONSO CLAUDIO' city_code, '3200102' ibge_code from dual union
select 'ES' state_code, 'AGUA DOCE DO NORTE' city_code, '3200169' ibge_code from dual union
select 'ES' state_code, 'AGUIA BRANCA' city_code, '3200136' ibge_code from dual union
select 'ES' state_code, 'ALEGRE' city_code, '3200201' ibge_code from dual union
select 'ES' state_code, 'ALFREDO CHAVES' city_code, '3200300' ibge_code from dual union
select 'ES' state_code, 'ALTO RIO NOVO' city_code, '3200359' ibge_code from dual union
select 'ES' state_code, 'ANCHIETA' city_code, '3200409' ibge_code from dual union
select 'ES' state_code, 'APIACA' city_code, '3200508' ibge_code from dual union
select 'ES' state_code, 'ARACRUZ' city_code, '3200607' ibge_code from dual union
select 'ES' state_code, 'ATILIO VIVACQUA' city_code, '3200706' ibge_code from dual union
select 'ES' state_code, 'BAIXO GUANDU' city_code, '3200805' ibge_code from dual union
select 'ES' state_code, 'BARRA DE SAO FRANCISCO' city_code, '3200904' ibge_code from dual union
select 'ES' state_code, 'BOA ESPERANCA' city_code, '3201001' ibge_code from dual union
select 'ES' state_code, 'BOM JESUS DO NORTE' city_code, '3201100' ibge_code from dual union
select 'ES' state_code, 'BREJETUBA' city_code, '3201159' ibge_code from dual union
select 'ES' state_code, 'CACHOEIRO DE ITAPEMIRIM' city_code, '3201209' ibge_code from dual union
select 'ES' state_code, 'CARIACICA' city_code, '3201308' ibge_code from dual union
select 'ES' state_code, 'CASTELO' city_code, '3201407' ibge_code from dual union
select 'ES' state_code, 'COLATINA' city_code, '3201506' ibge_code from dual union
select 'ES' state_code, 'CONCEICAO DA BARRA' city_code, '3201605' ibge_code from dual union
select 'ES' state_code, 'CONCEICAO DO CASTELO' city_code, '3201704' ibge_code from dual union
select 'ES' state_code, 'DIVINO DE SAO LOURENCO' city_code, '3201803' ibge_code from dual union
select 'ES' state_code, 'DOMINGOS MARTINS' city_code, '3201902' ibge_code from dual union
select 'ES' state_code, 'DORES DO RIO PRETO' city_code, '3202009' ibge_code from dual union
select 'ES' state_code, 'ECOPORANGA' city_code, '3202108' ibge_code from dual union
select 'ES' state_code, 'FUNDAO' city_code, '3202207' ibge_code from dual union
select 'ES' state_code, 'GOVERNADOR LINDENBERG' city_code, '3202256' ibge_code from dual union
select 'ES' state_code, 'GUACUI' city_code, '3202306' ibge_code from dual union
select 'ES' state_code, 'GUARAPARI' city_code, '3202405' ibge_code from dual union
select 'ES' state_code, 'IBATIBA' city_code, '3202454' ibge_code from dual union
select 'ES' state_code, 'IBIRACU' city_code, '3202504' ibge_code from dual union
select 'ES' state_code, 'IBITIRAMA' city_code, '3202553' ibge_code from dual union
select 'ES' state_code, 'ICONHA' city_code, '3202603' ibge_code from dual union
select 'ES' state_code, 'IRUPI' city_code, '3202652' ibge_code from dual union
select 'ES' state_code, 'ITAGUACU' city_code, '3202702' ibge_code from dual union
select 'ES' state_code, 'ITAPEMIRIM' city_code, '3202801' ibge_code from dual union
select 'ES' state_code, 'ITARANA' city_code, '3202900' ibge_code from dual union
select 'ES' state_code, 'IUNA' city_code, '3203007' ibge_code from dual union
select 'ES' state_code, 'JAGUARE' city_code, '3203056' ibge_code from dual union
select 'ES' state_code, 'JERONIMO MONTEIRO' city_code, '3203106' ibge_code from dual union
select 'ES' state_code, 'JOAO NEIVA' city_code, '3203130' ibge_code from dual union
select 'ES' state_code, 'LARANJA DA TERRA' city_code, '3203163' ibge_code from dual union
select 'ES' state_code, 'LINHARES' city_code, '3203205' ibge_code from dual union
select 'ES' state_code, 'MANTENOPOLIS' city_code, '3203304' ibge_code from dual union
select 'ES' state_code, 'MARATAIZES' city_code, '3203320' ibge_code from dual union
select 'ES' state_code, 'MARECHAL FLORIANO' city_code, '3203346' ibge_code from dual union
select 'ES' state_code, 'MARILANDIA' city_code, '3203353' ibge_code from dual union
select 'ES' state_code, 'MIMOSO DO SUL' city_code, '3203403' ibge_code from dual union
select 'ES' state_code, 'MONTANHA' city_code, '3203502' ibge_code from dual union
select 'ES' state_code, 'MUCURICI' city_code, '3203601' ibge_code from dual union
select 'ES' state_code, 'MUNIZ FREIRE' city_code, '3203700' ibge_code from dual union
select 'ES' state_code, 'MUQUI' city_code, '3203809' ibge_code from dual union
select 'ES' state_code, 'NOVA VENECIA' city_code, '3203908' ibge_code from dual union
select 'ES' state_code, 'PANCAS' city_code, '3204005' ibge_code from dual union
select 'ES' state_code, 'PEDRO CANARIO' city_code, '3204054' ibge_code from dual union
select 'ES' state_code, 'PINHEIROS' city_code, '3204104' ibge_code from dual union
select 'ES' state_code, 'PIUMA' city_code, '3204203' ibge_code from dual union
select 'ES' state_code, 'PONTO BELO' city_code, '3204252' ibge_code from dual union
select 'ES' state_code, 'PRESIDENTE KENNEDY' city_code, '3204302' ibge_code from dual union
select 'ES' state_code, 'RIO BANANAL' city_code, '3204351' ibge_code from dual union
select 'ES' state_code, 'RIO NOVO DO SUL' city_code, '3204401' ibge_code from dual union
select 'ES' state_code, 'SANTA LEOPOLDINA' city_code, '3204500' ibge_code from dual union
select 'ES' state_code, 'SANTA MARIA DE JETIBA' city_code, '3204559' ibge_code from dual union
select 'ES' state_code, 'SANTA TERESA' city_code, '3204609' ibge_code from dual union
select 'ES' state_code, 'SAO DOMINGOS DO NORTE' city_code, '3204658' ibge_code from dual union
select 'ES' state_code, 'SAO GABRIEL DA PALHA' city_code, '3204708' ibge_code from dual union
select 'ES' state_code, 'SAO JOSE DO CALCADO' city_code, '3204807' ibge_code from dual union
select 'ES' state_code, 'SAO MATEUS' city_code, '3204906' ibge_code from dual union
select 'ES' state_code, 'SAO ROQUE DO CANAA' city_code, '3204955' ibge_code from dual union
select 'ES' state_code, 'SERRA' city_code, '3205002' ibge_code from dual union
select 'ES' state_code, 'SOORETAMA' city_code, '3205010' ibge_code from dual union
select 'ES' state_code, 'VARGEM ALTA' city_code, '3205036' ibge_code from dual union
select 'ES' state_code, 'VENDA NOVA DO IMIGRANTE' city_code, '3205069' ibge_code from dual union
select 'ES' state_code, 'VIANA' city_code, '3205101' ibge_code from dual union
select 'ES' state_code, 'VILA PAVAO' city_code, '3205150' ibge_code from dual union
select 'ES' state_code, 'VILA VALERIO' city_code, '3205176' ibge_code from dual union
select 'ES' state_code, 'VILA VELHA' city_code, '3205200' ibge_code from dual union
select 'ES' state_code, 'VITORIA' city_code, '3205309' ibge_code from dual union
select 'RJ' state_code, 'ANGRA DOS REIS' city_code, '3300100' ibge_code from dual union
select 'RJ' state_code, 'APERIBE' city_code, '3300159' ibge_code from dual union
select 'RJ' state_code, 'ARARUAMA' city_code, '3300209' ibge_code from dual union
select 'RJ' state_code, 'AREAL' city_code, '3300225' ibge_code from dual union
select 'RJ' state_code, 'ARMACAO DOS BUZIOS' city_code, '3300233' ibge_code from dual union
select 'RJ' state_code, 'ARRAIAL DO CABO' city_code, '3300258' ibge_code from dual union
select 'RJ' state_code, 'BARRA DO PIRAI' city_code, '3300308' ibge_code from dual union
select 'RJ' state_code, 'BARRA MANSA' city_code, '3300407' ibge_code from dual union
select 'RJ' state_code, 'BELFORD ROXO' city_code, '3300456' ibge_code from dual union
select 'RJ' state_code, 'BOM JARDIM' city_code, '3300506' ibge_code from dual union
select 'RJ' state_code, 'BOM JESUS DO ITABAPOANA' city_code, '3300605' ibge_code from dual union
select 'RJ' state_code, 'CABO FRIO' city_code, '3300704' ibge_code from dual union
select 'RJ' state_code, 'CACHOEIRAS DE MACACU' city_code, '3300803' ibge_code from dual union
select 'RJ' state_code, 'CAMBUCI' city_code, '3300902' ibge_code from dual union
select 'RJ' state_code, 'CAMPOS DOS GOYTACAZES' city_code, '3301009' ibge_code from dual union
select 'RJ' state_code, 'CANTAGALO' city_code, '3301108' ibge_code from dual union
select 'RJ' state_code, 'CARAPEBUS' city_code, '3300936' ibge_code from dual union
select 'RJ' state_code, 'CARDOSO MOREIRA' city_code, '3301157' ibge_code from dual union
select 'RJ' state_code, 'CARMO' city_code, '3301207' ibge_code from dual union
select 'RJ' state_code, 'CASIMIRO DE ABREU' city_code, '3301306' ibge_code from dual union
select 'RJ' state_code, 'COMENDADOR LEVY GASPARIAN' city_code, '3300951' ibge_code from dual union
select 'RJ' state_code, 'CONCEICAO DE MACABU' city_code, '3301405' ibge_code from dual union
select 'RJ' state_code, 'CORDEIRO' city_code, '3301504' ibge_code from dual union
select 'RJ' state_code, 'DUAS BARRAS' city_code, '3301603' ibge_code from dual union
select 'RJ' state_code, 'DUQUE DE CAXIAS' city_code, '3301702' ibge_code from dual union
select 'RJ' state_code, 'ENGENHEIRO PAULO DE FRONTIN' city_code, '3301801' ibge_code from dual union
select 'RJ' state_code, 'GUAPIMIRIM' city_code, '3301850' ibge_code from dual union
select 'RJ' state_code, 'IGUABA GRANDE' city_code, '3301876' ibge_code from dual union
select 'RJ' state_code, 'ITABORAI' city_code, '3301900' ibge_code from dual union
select 'RJ' state_code, 'ITAGUAI' city_code, '3302007' ibge_code from dual union
select 'RJ' state_code, 'ITALVA' city_code, '3302056' ibge_code from dual union
select 'RJ' state_code, 'ITAOCARA' city_code, '3302106' ibge_code from dual union
select 'RJ' state_code, 'ITAPERUNA' city_code, '3302205' ibge_code from dual union
select 'RJ' state_code, 'ITATIAIA' city_code, '3302254' ibge_code from dual union
select 'RJ' state_code, 'JAPERI' city_code, '3302270' ibge_code from dual union
select 'RJ' state_code, 'LAJE DO MURIAE' city_code, '3302304' ibge_code from dual union
select 'RJ' state_code, 'MACAE' city_code, '3302403' ibge_code from dual union
select 'RJ' state_code, 'MACUCO' city_code, '3302452' ibge_code from dual union
select 'RJ' state_code, 'MAGE' city_code, '3302502' ibge_code from dual union
select 'RJ' state_code, 'MANGARATIBA' city_code, '3302601' ibge_code from dual union
select 'RJ' state_code, 'MARICA' city_code, '3302700' ibge_code from dual union
select 'RJ' state_code, 'MENDES' city_code, '3302809' ibge_code from dual union
select 'RJ' state_code, 'MESQUITA' city_code, '3302858' ibge_code from dual union
select 'RJ' state_code, 'MIGUEL PEREIRA' city_code, '3302908' ibge_code from dual union
select 'RJ' state_code, 'MIRACEMA' city_code, '3303005' ibge_code from dual union
select 'RJ' state_code, 'NATIVIDADE' city_code, '3303104' ibge_code from dual union
select 'RJ' state_code, 'NILOPOLIS' city_code, '3303203' ibge_code from dual union
select 'RJ' state_code, 'NITEROI' city_code, '3303302' ibge_code from dual union
select 'RJ' state_code, 'NOVA FRIBURGO' city_code, '3303401' ibge_code from dual union
select 'RJ' state_code, 'NOVA IGUACU' city_code, '3303500' ibge_code from dual union
select 'RJ' state_code, 'PARACAMBI' city_code, '3303609' ibge_code from dual union
select 'RJ' state_code, 'PARAIBA DO SUL' city_code, '3303708' ibge_code from dual union
select 'RJ' state_code, 'PARATY' city_code, '3303807' ibge_code from dual union
select 'RJ' state_code, 'PATY DO ALFERES' city_code, '3303856' ibge_code from dual union
select 'RJ' state_code, 'PETROPOLIS' city_code, '3303906' ibge_code from dual union
select 'RJ' state_code, 'PINHEIRAL' city_code, '3303955' ibge_code from dual union
select 'RJ' state_code, 'PIRAI' city_code, '3304003' ibge_code from dual union
select 'RJ' state_code, 'PORCIUNCULA' city_code, '3304102' ibge_code from dual union
select 'RJ' state_code, 'PORTO REAL' city_code, '3304110' ibge_code from dual union
select 'RJ' state_code, 'QUATIS' city_code, '3304128' ibge_code from dual union
select 'RJ' state_code, 'QUEIMADOS' city_code, '3304144' ibge_code from dual union
select 'RJ' state_code, 'QUISSAMA' city_code, '3304151' ibge_code from dual union
select 'RJ' state_code, 'RESENDE' city_code, '3304201' ibge_code from dual union
select 'RJ' state_code, 'RIO BONITO' city_code, '3304300' ibge_code from dual union
select 'RJ' state_code, 'RIO CLARO' city_code, '3304409' ibge_code from dual union
select 'RJ' state_code, 'RIO DAS FLORES' city_code, '3304508' ibge_code from dual union
select 'RJ' state_code, 'RIO DAS OSTRAS' city_code, '3304524' ibge_code from dual union
select 'RJ' state_code, 'RIO DE JANEIRO' city_code, '3304557' ibge_code from dual union
select 'RJ' state_code, 'SANTA MARIA MADALENA' city_code, '3304607' ibge_code from dual union
select 'RJ' state_code, 'SANTO ANTONIO DE PADUA' city_code, '3304706' ibge_code from dual union
select 'RJ' state_code, 'SAO FIDELIS' city_code, '3304805' ibge_code from dual union
select 'RJ' state_code, 'SAO FRANCISCO DE ITABAPOANA' city_code, '3304755' ibge_code from dual union
select 'RJ' state_code, 'SAO GONCALO' city_code, '3304904' ibge_code from dual union
select 'RJ' state_code, 'SAO JOAO DA BARRA' city_code, '3305000' ibge_code from dual union
select 'RJ' state_code, 'SAO JOAO DE MERITI' city_code, '3305109' ibge_code from dual union
select 'RJ' state_code, 'SAO JOSE DE UBA' city_code, '3305133' ibge_code from dual union
select 'RJ' state_code, 'SAO JOSE DO VALE DO RIO PRETO' city_code, '3305158' ibge_code from dual union
select 'RJ' state_code, 'SAO PEDRO DA ALDEIA' city_code, '3305208' ibge_code from dual union
select 'RJ' state_code, 'SAO SEBASTIAO DO ALTO' city_code, '3305307' ibge_code from dual union
select 'RJ' state_code, 'SAPUCAIA' city_code, '3305406' ibge_code from dual union
select 'RJ' state_code, 'SAQUAREMA' city_code, '3305505' ibge_code from dual union
select 'RJ' state_code, 'SEROPEDICA' city_code, '3305554' ibge_code from dual union
select 'RJ' state_code, 'SILVA JARDIM' city_code, '3305604' ibge_code from dual union
select 'RJ' state_code, 'SUMIDOURO' city_code, '3305703' ibge_code from dual union
select 'RJ' state_code, 'TANGUA' city_code, '3305752' ibge_code from dual union
select 'RJ' state_code, 'TERESOPOLIS' city_code, '3305802' ibge_code from dual union
select 'RJ' state_code, 'TRAJANO DE MORAES' city_code, '3305901' ibge_code from dual union
select 'RJ' state_code, 'TRES RIOS' city_code, '3306008' ibge_code from dual union
select 'RJ' state_code, 'VALENCA' city_code, '3306107' ibge_code from dual union
select 'RJ' state_code, 'VARRE-SAI' city_code, '3306156' ibge_code from dual union
select 'RJ' state_code, 'VASSOURAS' city_code, '3306206' ibge_code from dual union
select 'RJ' state_code, 'VOLTA REDONDA' city_code, '3306305' ibge_code from dual union
select 'SP' state_code, 'ADAMANTINA' city_code, '3500105' ibge_code from dual union
select 'SP' state_code, 'ADOLFO' city_code, '3500204' ibge_code from dual union
select 'SP' state_code, 'AGUAI' city_code, '3500303' ibge_code from dual union
select 'SP' state_code, 'AGUAS DA PRATA' city_code, '3500402' ibge_code from dual union
select 'SP' state_code, 'AGUAS DE LINDOIA' city_code, '3500501' ibge_code from dual union
select 'SP' state_code, 'AGUAS DE SANTA BARBARA' city_code, '3500550' ibge_code from dual union
select 'SP' state_code, 'AGUAS DE SAO PEDRO' city_code, '3500600' ibge_code from dual union
select 'SP' state_code, 'AGUDOS' city_code, '3500709' ibge_code from dual union
select 'SP' state_code, 'ALAMBARI' city_code, '3500758' ibge_code from dual union
select 'SP' state_code, 'ALFREDO MARCONDES' city_code, '3500808' ibge_code from dual union
select 'SP' state_code, 'ALTAIR' city_code, '3500907' ibge_code from dual union
select 'SP' state_code, 'ALTINOPOLIS' city_code, '3501004' ibge_code from dual union
select 'SP' state_code, 'ALTO ALEGRE' city_code, '3501103' ibge_code from dual union
select 'SP' state_code, 'ALUMINIO' city_code, '3501152' ibge_code from dual union
select 'SP' state_code, 'ALVARES FLORENCE' city_code, '3501202' ibge_code from dual union
select 'SP' state_code, 'ALVARES MACHADO' city_code, '3501301' ibge_code from dual union
select 'SP' state_code, 'ALVARO DE CARVALHO' city_code, '3501400' ibge_code from dual union
select 'SP' state_code, 'ALVINLANDIA' city_code, '3501509' ibge_code from dual union
select 'SP' state_code, 'AMERICANA' city_code, '3501608' ibge_code from dual union
select 'SP' state_code, 'AMERICO BRASILIENSE' city_code, '3501707' ibge_code from dual union
select 'SP' state_code, 'AMERICO DE CAMPOS' city_code, '3501806' ibge_code from dual union
select 'SP' state_code, 'AMPARO' city_code, '3501905' ibge_code from dual union
select 'SP' state_code, 'ANALANDIA' city_code, '3502002' ibge_code from dual union
select 'SP' state_code, 'ANDRADINA' city_code, '3502101' ibge_code from dual union
select 'SP' state_code, 'ANGATUBA' city_code, '3502200' ibge_code from dual union
select 'SP' state_code, 'ANHEMBI' city_code, '3502309' ibge_code from dual union
select 'SP' state_code, 'ANHUMAS' city_code, '3502408' ibge_code from dual union
select 'SP' state_code, 'APARECIDA' city_code, '3502507' ibge_code from dual union
select 'SP' state_code, 'APARECIDA D''OESTE' city_code, '3502606' ibge_code from dual union
select 'SP' state_code, 'APIAI' city_code, '3502705' ibge_code from dual union
select 'SP' state_code, 'ARACARIGUAMA' city_code, '3502754' ibge_code from dual union
select 'SP' state_code, 'ARACATUBA' city_code, '3502804' ibge_code from dual union
select 'SP' state_code, 'ARACOIABA DA SERRA' city_code, '3502903' ibge_code from dual union
select 'SP' state_code, 'ARAMINA' city_code, '3503000' ibge_code from dual union
select 'SP' state_code, 'ARANDU' city_code, '3503109' ibge_code from dual union
select 'SP' state_code, 'ARAPEI' city_code, '3503158' ibge_code from dual union
select 'SP' state_code, 'ARARAQUARA' city_code, '3503208' ibge_code from dual union
select 'SP' state_code, 'ARARAS' city_code, '3503307' ibge_code from dual union
select 'SP' state_code, 'ARCO-IRIS' city_code, '3503356' ibge_code from dual union
select 'SP' state_code, 'AREALVA' city_code, '3503406' ibge_code from dual union
select 'SP' state_code, 'AREIAS' city_code, '3503505' ibge_code from dual union
select 'SP' state_code, 'AREIOPOLIS' city_code, '3503604' ibge_code from dual union
select 'SP' state_code, 'ARIRANHA' city_code, '3503703' ibge_code from dual union
select 'SP' state_code, 'ARTUR NOGUEIRA' city_code, '3503802' ibge_code from dual union
select 'SP' state_code, 'ARUJA' city_code, '3503901' ibge_code from dual union
select 'SP' state_code, 'ASPASIA' city_code, '3503950' ibge_code from dual union
select 'SP' state_code, 'ASSIS' city_code, '3504008' ibge_code from dual union
select 'SP' state_code, 'ATIBAIA' city_code, '3504107' ibge_code from dual union
select 'SP' state_code, 'AURIFLAMA' city_code, '3504206' ibge_code from dual union
select 'SP' state_code, 'AVAI' city_code, '3504305' ibge_code from dual union
select 'SP' state_code, 'AVANHANDAVA' city_code, '3504404' ibge_code from dual union
select 'SP' state_code, 'AVARE' city_code, '3504503' ibge_code from dual union
select 'SP' state_code, 'BADY BASSITT' city_code, '3504602' ibge_code from dual union
select 'SP' state_code, 'BALBINOS' city_code, '3504701' ibge_code from dual union
select 'SP' state_code, 'BALSAMO' city_code, '3504800' ibge_code from dual union
select 'SP' state_code, 'BANANAL' city_code, '3504909' ibge_code from dual union
select 'SP' state_code, 'BARAO DE ANTONINA' city_code, '3505005' ibge_code from dual union
select 'SP' state_code, 'BARBOSA' city_code, '3505104' ibge_code from dual union
select 'SP' state_code, 'BARIRI' city_code, '3505203' ibge_code from dual union
select 'SP' state_code, 'BARRA BONITA' city_code, '3505302' ibge_code from dual union
select 'SP' state_code, 'BARRA DO CHAPEU' city_code, '3505351' ibge_code from dual union
select 'SP' state_code, 'BARRA DO TURVO' city_code, '3505401' ibge_code from dual union
select 'SP' state_code, 'BARRETOS' city_code, '3505500' ibge_code from dual union
select 'SP' state_code, 'BARRINHA' city_code, '3505609' ibge_code from dual union
select 'SP' state_code, 'BARUERI' city_code, '3505708' ibge_code from dual union
select 'SP' state_code, 'BASTOS' city_code, '3505807' ibge_code from dual union
select 'SP' state_code, 'BATATAIS' city_code, '3505906' ibge_code from dual union
select 'SP' state_code, 'BAURU' city_code, '3506003' ibge_code from dual union
select 'SP' state_code, 'BEBEDOURO' city_code, '3506102' ibge_code from dual union
select 'SP' state_code, 'BENTO DE ABREU' city_code, '3506201' ibge_code from dual union
select 'SP' state_code, 'BERNARDINO DE CAMPOS' city_code, '3506300' ibge_code from dual union
select 'SP' state_code, 'BERTIOGA' city_code, '3506359' ibge_code from dual union
select 'SP' state_code, 'BILAC' city_code, '3506409' ibge_code from dual union
select 'SP' state_code, 'BIRIGUI' city_code, '3506508' ibge_code from dual union
select 'SP' state_code, 'BIRITIBA MIRIM' city_code, '3506607' ibge_code from dual union
select 'SP' state_code, 'BOA ESPERANCA DO SUL' city_code, '3506706' ibge_code from dual union
select 'SP' state_code, 'BOCAINA' city_code, '3506805' ibge_code from dual union
select 'SP' state_code, 'BOFETE' city_code, '3506904' ibge_code from dual union
select 'SP' state_code, 'BOITUVA' city_code, '3507001' ibge_code from dual union
select 'SP' state_code, 'BOM JESUS DOS PERDÕES' city_code, '3507100' ibge_code from dual union
select 'SP' state_code, 'BOM SUCESSO DE ITARARE' city_code, '3507159' ibge_code from dual union
select 'SP' state_code, 'BORA' city_code, '3507209' ibge_code from dual union
select 'SP' state_code, 'BORACEIA' city_code, '3507308' ibge_code from dual union
select 'SP' state_code, 'BORBOREMA' city_code, '3507407' ibge_code from dual union
select 'SP' state_code, 'BOREBI' city_code, '3507456' ibge_code from dual union
select 'SP' state_code, 'BOTUCATU' city_code, '3507506' ibge_code from dual union
select 'SP' state_code, 'BRAGANCA PAULISTA' city_code, '3507605' ibge_code from dual union
select 'SP' state_code, 'BRAUNA' city_code, '3507704' ibge_code from dual union
select 'SP' state_code, 'BREJO ALEGRE' city_code, '3507753' ibge_code from dual union
select 'SP' state_code, 'BRODOWSKI' city_code, '3507803' ibge_code from dual union
select 'SP' state_code, 'BROTAS' city_code, '3507902' ibge_code from dual union
select 'SP' state_code, 'BURI' city_code, '3508009' ibge_code from dual union
select 'SP' state_code, 'BURITAMA' city_code, '3508108' ibge_code from dual union
select 'SP' state_code, 'BURITIZAL' city_code, '3508207' ibge_code from dual union
select 'SP' state_code, 'CABRALIA PAULISTA' city_code, '3508306' ibge_code from dual union
select 'SP' state_code, 'CABREUVA' city_code, '3508405' ibge_code from dual union
select 'SP' state_code, 'CACAPAVA' city_code, '3508504' ibge_code from dual union
select 'SP' state_code, 'CACHOEIRA PAULISTA' city_code, '3508603' ibge_code from dual union
select 'SP' state_code, 'CACONDE' city_code, '3508702' ibge_code from dual union
select 'SP' state_code, 'CAFELANDIA' city_code, '3508801' ibge_code from dual union
select 'SP' state_code, 'CAIABU' city_code, '3508900' ibge_code from dual union
select 'SP' state_code, 'CAIEIRAS' city_code, '3509007' ibge_code from dual union
select 'SP' state_code, 'CAIUA' city_code, '3509106' ibge_code from dual union
select 'SP' state_code, 'CAJAMAR' city_code, '3509205' ibge_code from dual union
select 'SP' state_code, 'CAJATI' city_code, '3509254' ibge_code from dual union
select 'SP' state_code, 'CAJOBI' city_code, '3509304' ibge_code from dual union
select 'SP' state_code, 'CAJURU' city_code, '3509403' ibge_code from dual union
select 'SP' state_code, 'CAMPINA DO MONTE ALEGRE' city_code, '3509452' ibge_code from dual union
select 'SP' state_code, 'CAMPINAS' city_code, '3509502' ibge_code from dual union
select 'SP' state_code, 'CAMPO LIMPO PAULISTA' city_code, '3509601' ibge_code from dual union
select 'SP' state_code, 'CAMPOS DO JORDAO' city_code, '3509700' ibge_code from dual union
select 'SP' state_code, 'CAMPOS NOVOS PAULISTA' city_code, '3509809' ibge_code from dual union
select 'SP' state_code, 'CANANEIA' city_code, '3509908' ibge_code from dual union
select 'SP' state_code, 'CANAS' city_code, '3509957' ibge_code from dual union
select 'SP' state_code, 'CANDIDO MOTA' city_code, '3510005' ibge_code from dual union
select 'SP' state_code, 'CANDIDO RODRIGUES' city_code, '3510104' ibge_code from dual union
select 'SP' state_code, 'CANITAR' city_code, '3510153' ibge_code from dual union
select 'SP' state_code, 'CAPAO BONITO' city_code, '3510203' ibge_code from dual union
select 'SP' state_code, 'CAPELA DO ALTO' city_code, '3510302' ibge_code from dual union
select 'SP' state_code, 'CAPIVARI' city_code, '3510401' ibge_code from dual union
select 'SP' state_code, 'CARAGUATATUBA' city_code, '3510500' ibge_code from dual union
select 'SP' state_code, 'CARAPICUIBA' city_code, '3510609' ibge_code from dual union
select 'SP' state_code, 'CARDOSO' city_code, '3510708' ibge_code from dual union
select 'SP' state_code, 'CASA BRANCA' city_code, '3510807' ibge_code from dual union
select 'SP' state_code, 'CASSIA DOS COQUEIROS' city_code, '3510906' ibge_code from dual union
select 'SP' state_code, 'CASTILHO' city_code, '3511003' ibge_code from dual union
select 'SP' state_code, 'CATANDUVA' city_code, '3511102' ibge_code from dual union
select 'SP' state_code, 'CATIGUA' city_code, '3511201' ibge_code from dual union
select 'SP' state_code, 'CEDRAL' city_code, '3511300' ibge_code from dual union
select 'SP' state_code, 'CERQUEIRA CESAR' city_code, '3511409' ibge_code from dual union
select 'SP' state_code, 'CERQUILHO' city_code, '3511508' ibge_code from dual union
select 'SP' state_code, 'CESARIO LANGE' city_code, '3511607' ibge_code from dual union
select 'SP' state_code, 'CHARQUEADA' city_code, '3511706' ibge_code from dual union
select 'SP' state_code, 'CHAVANTES' city_code, '3557204' ibge_code from dual union
select 'SP' state_code, 'CLEMENTINA' city_code, '3511904' ibge_code from dual union
select 'SP' state_code, 'COLINA' city_code, '3512001' ibge_code from dual union
select 'SP' state_code, 'COLOMBIA' city_code, '3512100' ibge_code from dual union
select 'SP' state_code, 'CONCHAL' city_code, '3512209' ibge_code from dual union
select 'SP' state_code, 'CONCHAS' city_code, '3512308' ibge_code from dual union
select 'SP' state_code, 'CORDEIROPOLIS' city_code, '3512407' ibge_code from dual union
select 'SP' state_code, 'COROADOS' city_code, '3512506' ibge_code from dual union
select 'SP' state_code, 'CORONEL MACEDO' city_code, '3512605' ibge_code from dual union
select 'SP' state_code, 'CORUMBATAI' city_code, '3512704' ibge_code from dual union
select 'SP' state_code, 'COSMOPOLIS' city_code, '3512803' ibge_code from dual union
select 'SP' state_code, 'COSMORAMA' city_code, '3512902' ibge_code from dual union
select 'SP' state_code, 'COTIA' city_code, '3513009' ibge_code from dual union
select 'SP' state_code, 'CRAVINHOS' city_code, '3513108' ibge_code from dual union
select 'SP' state_code, 'CRISTAIS PAULISTA' city_code, '3513207' ibge_code from dual union
select 'SP' state_code, 'CRUZALIA' city_code, '3513306' ibge_code from dual union
select 'SP' state_code, 'CRUZEIRO' city_code, '3513405' ibge_code from dual union
select 'SP' state_code, 'CUBATAO' city_code, '3513504' ibge_code from dual union
select 'SP' state_code, 'CUNHA' city_code, '3513603' ibge_code from dual union
select 'SP' state_code, 'DESCALVADO' city_code, '3513702' ibge_code from dual union
select 'SP' state_code, 'DIADEMA' city_code, '3513801' ibge_code from dual union
select 'SP' state_code, 'DIRCE REIS' city_code, '3513850' ibge_code from dual union
select 'SP' state_code, 'DIVINOLANDIA' city_code, '3513900' ibge_code from dual union
select 'SP' state_code, 'DOBRADA' city_code, '3514007' ibge_code from dual union
select 'SP' state_code, 'DOIS CORREGOS' city_code, '3514106' ibge_code from dual union
select 'SP' state_code, 'DOLCINOPOLIS' city_code, '3514205' ibge_code from dual union
select 'SP' state_code, 'DOURADO' city_code, '3514304' ibge_code from dual union
select 'SP' state_code, 'DRACENA' city_code, '3514403' ibge_code from dual union
select 'SP' state_code, 'DUARTINA' city_code, '3514502' ibge_code from dual union
select 'SP' state_code, 'DUMONT' city_code, '3514601' ibge_code from dual union
select 'SP' state_code, 'ECHAPORA' city_code, '3514700' ibge_code from dual union
select 'SP' state_code, 'ELDORADO' city_code, '3514809' ibge_code from dual union
select 'SP' state_code, 'ELIAS FAUSTO' city_code, '3514908' ibge_code from dual union
select 'SP' state_code, 'ELISIARIO' city_code, '3514924' ibge_code from dual union
select 'SP' state_code, 'EMBAUBA' city_code, '3514957' ibge_code from dual union
select 'SP' state_code, 'EMBU DAS ARTES' city_code, '3515004' ibge_code from dual union
select 'SP' state_code, 'EMBU-GUACU' city_code, '3515103' ibge_code from dual union
select 'SP' state_code, 'EMILIANOPOLIS' city_code, '3515129' ibge_code from dual union
select 'SP' state_code, 'ENGENHEIRO COELHO' city_code, '3515152' ibge_code from dual union
select 'SP' state_code, 'ESPIRITO SANTO DO PINHAL' city_code, '3515186' ibge_code from dual union
select 'SP' state_code, 'ESPIRITO SANTO DO TURVO' city_code, '3515194' ibge_code from dual union
select 'SP' state_code, 'ESTIVA GERBI' city_code, '3557303' ibge_code from dual union
select 'SP' state_code, 'ESTRELA DO NORTE' city_code, '3515301' ibge_code from dual union
select 'SP' state_code, 'ESTRELA D''OESTE' city_code, '3515202' ibge_code from dual union
select 'SP' state_code, 'EUCLIDES DA CUNHA PAULISTA' city_code, '3515350' ibge_code from dual union
select 'SP' state_code, 'FARTURA' city_code, '3515400' ibge_code from dual union
select 'SP' state_code, 'FERNANDO PRESTES' city_code, '3515608' ibge_code from dual union
select 'SP' state_code, 'FERNANDOPOLIS' city_code, '3515509' ibge_code from dual union
select 'SP' state_code, 'FERNAO' city_code, '3515657' ibge_code from dual union
select 'SP' state_code, 'FERRAZ DE VASCONCELOS' city_code, '3515707' ibge_code from dual union
select 'SP' state_code, 'FLORA RICA' city_code, '3515806' ibge_code from dual union
select 'SP' state_code, 'FLOREAL' city_code, '3515905' ibge_code from dual union
select 'SP' state_code, 'FLORIDA PAULISTA' city_code, '3516002' ibge_code from dual union
select 'SP' state_code, 'FLORINEA' city_code, '3516101' ibge_code from dual union
select 'SP' state_code, 'FRANCA' city_code, '3516200' ibge_code from dual union
select 'SP' state_code, 'FRANCISCO MORATO' city_code, '3516309' ibge_code from dual union
select 'SP' state_code, 'FRANCO DA ROCHA' city_code, '3516408' ibge_code from dual union
select 'SP' state_code, 'GABRIEL MONTEIRO' city_code, '3516507' ibge_code from dual union
select 'SP' state_code, 'GALIA' city_code, '3516606' ibge_code from dual union
select 'SP' state_code, 'GARCA' city_code, '3516705' ibge_code from dual union
select 'SP' state_code, 'GASTAO VIDIGAL' city_code, '3516804' ibge_code from dual union
select 'SP' state_code, 'GAVIAO PEIXOTO' city_code, '3516853' ibge_code from dual union
select 'SP' state_code, 'GENERAL SALGADO' city_code, '3516903' ibge_code from dual union
select 'SP' state_code, 'GETULINA' city_code, '3517000' ibge_code from dual union
select 'SP' state_code, 'GLICERIO' city_code, '3517109' ibge_code from dual union
select 'SP' state_code, 'GUAICARA' city_code, '3517208' ibge_code from dual union
select 'SP' state_code, 'GUAIMBE' city_code, '3517307' ibge_code from dual union
select 'SP' state_code, 'GUAIRA' city_code, '3517406' ibge_code from dual union
select 'SP' state_code, 'GUAPIACU' city_code, '3517505' ibge_code from dual union
select 'SP' state_code, 'GUAPIARA' city_code, '3517604' ibge_code from dual union
select 'SP' state_code, 'GUARA' city_code, '3517703' ibge_code from dual union
select 'SP' state_code, 'GUARACAI' city_code, '3517802' ibge_code from dual union
select 'SP' state_code, 'GUARACI' city_code, '3517901' ibge_code from dual union
select 'SP' state_code, 'GUARANI D''OESTE' city_code, '3518008' ibge_code from dual union
select 'SP' state_code, 'GUARANTA' city_code, '3518107' ibge_code from dual union
select 'SP' state_code, 'GUARARAPES' city_code, '3518206' ibge_code from dual union
select 'SP' state_code, 'GUARAREMA' city_code, '3518305' ibge_code from dual union
select 'SP' state_code, 'GUARATINGUETA' city_code, '3518404' ibge_code from dual union
select 'SP' state_code, 'GUAREI' city_code, '3518503' ibge_code from dual union
select 'SP' state_code, 'GUARIBA' city_code, '3518602' ibge_code from dual union
select 'SP' state_code, 'GUARUJA' city_code, '3518701' ibge_code from dual union
select 'SP' state_code, 'GUARULHOS' city_code, '3518800' ibge_code from dual union
select 'SP' state_code, 'GUATAPARA' city_code, '3518859' ibge_code from dual union
select 'SP' state_code, 'GUZOLANDIA' city_code, '3518909' ibge_code from dual union
select 'SP' state_code, 'HERCULANDIA' city_code, '3519006' ibge_code from dual union
select 'SP' state_code, 'HOLAMBRA' city_code, '3519055' ibge_code from dual union
select 'SP' state_code, 'HORTOLANDIA' city_code, '3519071' ibge_code from dual union
select 'SP' state_code, 'IACANGA' city_code, '3519105' ibge_code from dual union
select 'SP' state_code, 'IACRI' city_code, '3519204' ibge_code from dual union
select 'SP' state_code, 'IARAS' city_code, '3519253' ibge_code from dual union
select 'SP' state_code, 'IBATE' city_code, '3519303' ibge_code from dual union
select 'SP' state_code, 'IBIRA' city_code, '3519402' ibge_code from dual union
select 'SP' state_code, 'IBIRAREMA' city_code, '3519501' ibge_code from dual union
select 'SP' state_code, 'IBITINGA' city_code, '3519600' ibge_code from dual union
select 'SP' state_code, 'IBIUNA' city_code, '3519709' ibge_code from dual union
select 'SP' state_code, 'ICEM' city_code, '3519808' ibge_code from dual union
select 'SP' state_code, 'IEPE' city_code, '3519907' ibge_code from dual union
select 'SP' state_code, 'IGARACU DO TIETE' city_code, '3520004' ibge_code from dual union
select 'SP' state_code, 'IGARAPAVA' city_code, '3520103' ibge_code from dual union
select 'SP' state_code, 'IGARATA' city_code, '3520202' ibge_code from dual union
select 'SP' state_code, 'IGUAPE' city_code, '3520301' ibge_code from dual union
select 'SP' state_code, 'ILHA COMPRIDA' city_code, '3520426' ibge_code from dual union
select 'SP' state_code, 'ILHA SOLTEIRA' city_code, '3520442' ibge_code from dual union
select 'SP' state_code, 'ILHABELA' city_code, '3520400' ibge_code from dual union
select 'SP' state_code, 'INDAIATUBA' city_code, '3520509' ibge_code from dual union
select 'SP' state_code, 'INDIANA' city_code, '3520608' ibge_code from dual union
select 'SP' state_code, 'INDIAPORA' city_code, '3520707' ibge_code from dual union
select 'SP' state_code, 'INUBIA PAULISTA' city_code, '3520806' ibge_code from dual union
select 'SP' state_code, 'IPAUSSU' city_code, '3520905' ibge_code from dual union
select 'SP' state_code, 'IPERO' city_code, '3521002' ibge_code from dual union
select 'SP' state_code, 'IPEUNA' city_code, '3521101' ibge_code from dual union
select 'SP' state_code, 'IPIGUA' city_code, '3521150' ibge_code from dual union
select 'SP' state_code, 'IPORANGA' city_code, '3521200' ibge_code from dual union
select 'SP' state_code, 'IPUA' city_code, '3521309' ibge_code from dual union
select 'SP' state_code, 'IRACEMAPOLIS' city_code, '3521408' ibge_code from dual union
select 'SP' state_code, 'IRAPUA' city_code, '3521507' ibge_code from dual union
select 'SP' state_code, 'IRAPURU' city_code, '3521606' ibge_code from dual union
select 'SP' state_code, 'ITABERA' city_code, '3521705' ibge_code from dual union
select 'SP' state_code, 'ITAI' city_code, '3521804' ibge_code from dual union
select 'SP' state_code, 'ITAJOBI' city_code, '3521903' ibge_code from dual union
select 'SP' state_code, 'ITAJU' city_code, '3522000' ibge_code from dual union
select 'SP' state_code, 'ITANHAEM' city_code, '3522109' ibge_code from dual union
select 'SP' state_code, 'ITAOCA' city_code, '3522158' ibge_code from dual union
select 'SP' state_code, 'ITAPECERICA DA SERRA' city_code, '3522208' ibge_code from dual union
select 'SP' state_code, 'ITAPETININGA' city_code, '3522307' ibge_code from dual union
select 'SP' state_code, 'ITAPEVA' city_code, '3522406' ibge_code from dual union
select 'SP' state_code, 'ITAPEVI' city_code, '3522505' ibge_code from dual union
select 'SP' state_code, 'ITAPIRA' city_code, '3522604' ibge_code from dual union
select 'SP' state_code, 'ITAPIRAPUA PAULISTA' city_code, '3522653' ibge_code from dual union
select 'SP' state_code, 'ITAPOLIS' city_code, '3522703' ibge_code from dual union
select 'SP' state_code, 'ITAPORANGA' city_code, '3522802' ibge_code from dual union
select 'SP' state_code, 'ITAPUI' city_code, '3522901' ibge_code from dual union
select 'SP' state_code, 'ITAPURA' city_code, '3523008' ibge_code from dual union
select 'SP' state_code, 'ITAQUAQUECETUBA' city_code, '3523107' ibge_code from dual union
select 'SP' state_code, 'ITARARE' city_code, '3523206' ibge_code from dual union
select 'SP' state_code, 'ITARIRI' city_code, '3523305' ibge_code from dual union
select 'SP' state_code, 'ITATIBA' city_code, '3523404' ibge_code from dual union
select 'SP' state_code, 'ITATINGA' city_code, '3523503' ibge_code from dual union
select 'SP' state_code, 'ITIRAPINA' city_code, '3523602' ibge_code from dual union
select 'SP' state_code, 'ITIRAPUA' city_code, '3523701' ibge_code from dual union
select 'SP' state_code, 'ITOBI' city_code, '3523800' ibge_code from dual union
select 'SP' state_code, 'ITU' city_code, '3523909' ibge_code from dual union
select 'SP' state_code, 'ITUPEVA' city_code, '3524006' ibge_code from dual union
select 'SP' state_code, 'ITUVERAVA' city_code, '3524105' ibge_code from dual union
select 'SP' state_code, 'JABORANDI' city_code, '3524204' ibge_code from dual union
select 'SP' state_code, 'JABOTICABAL' city_code, '3524303' ibge_code from dual union
select 'SP' state_code, 'JACAREI' city_code, '3524402' ibge_code from dual union
select 'SP' state_code, 'JACI' city_code, '3524501' ibge_code from dual union
select 'SP' state_code, 'JACUPIRANGA' city_code, '3524600' ibge_code from dual union
select 'SP' state_code, 'JAGUARIUNA' city_code, '3524709' ibge_code from dual union
select 'SP' state_code, 'JALES' city_code, '3524808' ibge_code from dual union
select 'SP' state_code, 'JAMBEIRO' city_code, '3524907' ibge_code from dual union
select 'SP' state_code, 'JANDIRA' city_code, '3525003' ibge_code from dual union
select 'SP' state_code, 'JARDINOPOLIS' city_code, '3525102' ibge_code from dual union
select 'SP' state_code, 'JARINU' city_code, '3525201' ibge_code from dual union
select 'SP' state_code, 'JAU' city_code, '3525300' ibge_code from dual union
select 'SP' state_code, 'JERIQUARA' city_code, '3525409' ibge_code from dual union
select 'SP' state_code, 'JOANOPOLIS' city_code, '3525508' ibge_code from dual union
select 'SP' state_code, 'JOAO RAMALHO' city_code, '3525607' ibge_code from dual union
select 'SP' state_code, 'JOSE BONIFACIO' city_code, '3525706' ibge_code from dual union
select 'SP' state_code, 'JULIO MESQUITA' city_code, '3525805' ibge_code from dual union
select 'SP' state_code, 'JUMIRIM' city_code, '3525854' ibge_code from dual union
select 'SP' state_code, 'JUNDIAI' city_code, '3525904' ibge_code from dual union
select 'SP' state_code, 'JUNQUEIROPOLIS' city_code, '3526001' ibge_code from dual union
select 'SP' state_code, 'JUQUIA' city_code, '3526100' ibge_code from dual union
select 'SP' state_code, 'JUQUITIBA' city_code, '3526209' ibge_code from dual union
select 'SP' state_code, 'LAGOINHA' city_code, '3526308' ibge_code from dual union
select 'SP' state_code, 'LARANJAL PAULISTA' city_code, '3526407' ibge_code from dual union
select 'SP' state_code, 'LAVINIA' city_code, '3526506' ibge_code from dual union
select 'SP' state_code, 'LAVRINHAS' city_code, '3526605' ibge_code from dual union
select 'SP' state_code, 'LEME' city_code, '3526704' ibge_code from dual union
select 'SP' state_code, 'LENCOIS PAULISTA' city_code, '3526803' ibge_code from dual union
select 'SP' state_code, 'LIMEIRA' city_code, '3526902' ibge_code from dual union
select 'SP' state_code, 'LINDOIA' city_code, '3527009' ibge_code from dual union
select 'SP' state_code, 'LINS' city_code, '3527108' ibge_code from dual union
select 'SP' state_code, 'LORENA' city_code, '3527207' ibge_code from dual union
select 'SP' state_code, 'LOURDES' city_code, '3527256' ibge_code from dual union
select 'SP' state_code, 'LOUVEIRA' city_code, '3527306' ibge_code from dual union
select 'SP' state_code, 'LUCELIA' city_code, '3527405' ibge_code from dual union
select 'SP' state_code, 'LUCIANOPOLIS' city_code, '3527504' ibge_code from dual union
select 'SP' state_code, 'LUIS ANTONIO' city_code, '3527603' ibge_code from dual union
select 'SP' state_code, 'LUIZIANIA' city_code, '3527702' ibge_code from dual union
select 'SP' state_code, 'LUPERCIO' city_code, '3527801' ibge_code from dual union
select 'SP' state_code, 'LUTECIA' city_code, '3527900' ibge_code from dual union
select 'SP' state_code, 'MACATUBA' city_code, '3528007' ibge_code from dual union
select 'SP' state_code, 'MACAUBAL' city_code, '3528106' ibge_code from dual union
select 'SP' state_code, 'MACEDONIA' city_code, '3528205' ibge_code from dual union
select 'SP' state_code, 'MAGDA' city_code, '3528304' ibge_code from dual union
select 'SP' state_code, 'MAIRINQUE' city_code, '3528403' ibge_code from dual union
select 'SP' state_code, 'MAIRIPORA' city_code, '3528502' ibge_code from dual union
select 'SP' state_code, 'MANDURI' city_code, '3528601' ibge_code from dual union
select 'SP' state_code, 'MARABA PAULISTA' city_code, '3528700' ibge_code from dual union
select 'SP' state_code, 'MARACAI' city_code, '3528809' ibge_code from dual union
select 'SP' state_code, 'MARAPOAMA' city_code, '3528858' ibge_code from dual union
select 'SP' state_code, 'MARIAPOLIS' city_code, '3528908' ibge_code from dual union
select 'SP' state_code, 'MARILIA' city_code, '3529005' ibge_code from dual union
select 'SP' state_code, 'MARINOPOLIS' city_code, '3529104' ibge_code from dual union
select 'SP' state_code, 'MARTINOPOLIS' city_code, '3529203' ibge_code from dual union
select 'SP' state_code, 'MATAO' city_code, '3529302' ibge_code from dual union
select 'SP' state_code, 'MAUA' city_code, '3529401' ibge_code from dual union
select 'SP' state_code, 'MENDONCA' city_code, '3529500' ibge_code from dual union
select 'SP' state_code, 'MERIDIANO' city_code, '3529609' ibge_code from dual union
select 'SP' state_code, 'MESOPOLIS' city_code, '3529658' ibge_code from dual union
select 'SP' state_code, 'MIGUELOPOLIS' city_code, '3529708' ibge_code from dual union
select 'SP' state_code, 'MINEIROS DO TIETE' city_code, '3529807' ibge_code from dual union
select 'SP' state_code, 'MIRA ESTRELA' city_code, '3530003' ibge_code from dual union
select 'SP' state_code, 'MIRACATU' city_code, '3529906' ibge_code from dual union
select 'SP' state_code, 'MIRANDOPOLIS' city_code, '3530102' ibge_code from dual union
select 'SP' state_code, 'MIRANTE DO PARANAPANEMA' city_code, '3530201' ibge_code from dual union
select 'SP' state_code, 'MIRASSOL' city_code, '3530300' ibge_code from dual union
select 'SP' state_code, 'MIRASSOLANDIA' city_code, '3530409' ibge_code from dual union
select 'SP' state_code, 'MOCOCA' city_code, '3530508' ibge_code from dual union
select 'SP' state_code, 'MOGI DAS CRUZES' city_code, '3530607' ibge_code from dual union
select 'SP' state_code, 'MOGI GUACU' city_code, '3530706' ibge_code from dual union
select 'SP' state_code, 'MOGI MIRIM' city_code, '3530805' ibge_code from dual union
select 'SP' state_code, 'MOMBUCA' city_code, '3530904' ibge_code from dual union
select 'SP' state_code, 'MONCÕES' city_code, '3531001' ibge_code from dual union
select 'SP' state_code, 'MONGAGUA' city_code, '3531100' ibge_code from dual union
select 'SP' state_code, 'MONTE ALEGRE DO SUL' city_code, '3531209' ibge_code from dual union
select 'SP' state_code, 'MONTE ALTO' city_code, '3531308' ibge_code from dual union
select 'SP' state_code, 'MONTE APRAZIVEL' city_code, '3531407' ibge_code from dual union
select 'SP' state_code, 'MONTE AZUL PAULISTA' city_code, '3531506' ibge_code from dual union
select 'SP' state_code, 'MONTE CASTELO' city_code, '3531605' ibge_code from dual union
select 'SP' state_code, 'MONTE MOR' city_code, '3531803' ibge_code from dual union
select 'SP' state_code, 'MONTEIRO LOBATO' city_code, '3531704' ibge_code from dual union
select 'SP' state_code, 'MORRO AGUDO' city_code, '3531902' ibge_code from dual union
select 'SP' state_code, 'MORUNGABA' city_code, '3532009' ibge_code from dual union
select 'SP' state_code, 'MOTUCA' city_code, '3532058' ibge_code from dual union
select 'SP' state_code, 'MURUTINGA DO SUL' city_code, '3532108' ibge_code from dual union
select 'SP' state_code, 'NANTES' city_code, '3532157' ibge_code from dual union
select 'SP' state_code, 'NARANDIBA' city_code, '3532207' ibge_code from dual union
select 'SP' state_code, 'NATIVIDADE DA SERRA' city_code, '3532306' ibge_code from dual union
select 'SP' state_code, 'NAZARE PAULISTA' city_code, '3532405' ibge_code from dual union
select 'SP' state_code, 'NEVES PAULISTA' city_code, '3532504' ibge_code from dual union
select 'SP' state_code, 'NHANDEARA' city_code, '3532603' ibge_code from dual union
select 'SP' state_code, 'NIPOA' city_code, '3532702' ibge_code from dual union
select 'SP' state_code, 'NOVA ALIANCA' city_code, '3532801' ibge_code from dual union
select 'SP' state_code, 'NOVA CAMPINA' city_code, '3532827' ibge_code from dual union
select 'SP' state_code, 'NOVA CANAA PAULISTA' city_code, '3532843' ibge_code from dual union
select 'SP' state_code, 'NOVA CASTILHO' city_code, '3532868' ibge_code from dual union
select 'SP' state_code, 'NOVA EUROPA' city_code, '3532900' ibge_code from dual union
select 'SP' state_code, 'NOVA GRANADA' city_code, '3533007' ibge_code from dual union
select 'SP' state_code, 'NOVA GUATAPORANGA' city_code, '3533106' ibge_code from dual union
select 'SP' state_code, 'NOVA INDEPENDENCIA' city_code, '3533205' ibge_code from dual union
select 'SP' state_code, 'NOVA LUZITANIA' city_code, '3533304' ibge_code from dual union
select 'SP' state_code, 'NOVA ODESSA' city_code, '3533403' ibge_code from dual union
select 'SP' state_code, 'NOVAIS' city_code, '3533254' ibge_code from dual union
select 'SP' state_code, 'NOVO HORIZONTE' city_code, '3533502' ibge_code from dual union
select 'SP' state_code, 'NUPORANGA' city_code, '3533601' ibge_code from dual union
select 'SP' state_code, 'OCAUCU' city_code, '3533700' ibge_code from dual union
select 'SP' state_code, 'OLEO' city_code, '3533809' ibge_code from dual union
select 'SP' state_code, 'OLIMPIA' city_code, '3533908' ibge_code from dual union
select 'SP' state_code, 'ONDA VERDE' city_code, '3534005' ibge_code from dual union
select 'SP' state_code, 'ORIENTE' city_code, '3534104' ibge_code from dual union
select 'SP' state_code, 'ORINDIUVA' city_code, '3534203' ibge_code from dual union
select 'SP' state_code, 'ORLANDIA' city_code, '3534302' ibge_code from dual union
select 'SP' state_code, 'OSASCO' city_code, '3534401' ibge_code from dual union
select 'SP' state_code, 'OSCAR BRESSANE' city_code, '3534500' ibge_code from dual union
select 'SP' state_code, 'OSVALDO CRUZ' city_code, '3534609' ibge_code from dual union
select 'SP' state_code, 'OURINHOS' city_code, '3534708' ibge_code from dual union
select 'SP' state_code, 'OURO VERDE' city_code, '3534807' ibge_code from dual union
select 'SP' state_code, 'OUROESTE' city_code, '3534757' ibge_code from dual union
select 'SP' state_code, 'PACAEMBU' city_code, '3534906' ibge_code from dual union
select 'SP' state_code, 'PALESTINA' city_code, '3535002' ibge_code from dual union
select 'SP' state_code, 'PALMARES PAULISTA' city_code, '3535101' ibge_code from dual union
select 'SP' state_code, 'PALMEIRA D''OESTE' city_code, '3535200' ibge_code from dual union
select 'SP' state_code, 'PALMITAL' city_code, '3535309' ibge_code from dual union
select 'SP' state_code, 'PANORAMA' city_code, '3535408' ibge_code from dual union
select 'SP' state_code, 'PARAGUACU PAULISTA' city_code, '3535507' ibge_code from dual union
select 'SP' state_code, 'PARAIBUNA' city_code, '3535606' ibge_code from dual union
select 'SP' state_code, 'PARAISO' city_code, '3535705' ibge_code from dual union
select 'SP' state_code, 'PARANAPANEMA' city_code, '3535804' ibge_code from dual union
select 'SP' state_code, 'PARANAPUA' city_code, '3535903' ibge_code from dual union
select 'SP' state_code, 'PARAPUA' city_code, '3536000' ibge_code from dual union
select 'SP' state_code, 'PARDINHO' city_code, '3536109' ibge_code from dual union
select 'SP' state_code, 'PARIQUERA-ACU' city_code, '3536208' ibge_code from dual union
select 'SP' state_code, 'PARISI' city_code, '3536257' ibge_code from dual union
select 'SP' state_code, 'PATROCINIO PAULISTA' city_code, '3536307' ibge_code from dual union
select 'SP' state_code, 'PAULICEIA' city_code, '3536406' ibge_code from dual union
select 'SP' state_code, 'PAULINIA' city_code, '3536505' ibge_code from dual union
select 'SP' state_code, 'PAULISTANIA' city_code, '3536570' ibge_code from dual union
select 'SP' state_code, 'PAULO DE FARIA' city_code, '3536604' ibge_code from dual union
select 'SP' state_code, 'PEDERNEIRAS' city_code, '3536703' ibge_code from dual union
select 'SP' state_code, 'PEDRA BELA' city_code, '3536802' ibge_code from dual union
select 'SP' state_code, 'PEDRANOPOLIS' city_code, '3536901' ibge_code from dual union
select 'SP' state_code, 'PEDREGULHO' city_code, '3537008' ibge_code from dual union
select 'SP' state_code, 'PEDREIRA' city_code, '3537107' ibge_code from dual union
select 'SP' state_code, 'PEDRINHAS PAULISTA' city_code, '3537156' ibge_code from dual union
select 'SP' state_code, 'PEDRO DE TOLEDO' city_code, '3537206' ibge_code from dual union
select 'SP' state_code, 'PENAPOLIS' city_code, '3537305' ibge_code from dual union
select 'SP' state_code, 'PEREIRA BARRETO' city_code, '3537404' ibge_code from dual union
select 'SP' state_code, 'PEREIRAS' city_code, '3537503' ibge_code from dual union
select 'SP' state_code, 'PERUIBE' city_code, '3537602' ibge_code from dual union
select 'SP' state_code, 'PIACATU' city_code, '3537701' ibge_code from dual union
select 'SP' state_code, 'PIEDADE' city_code, '3537800' ibge_code from dual union
select 'SP' state_code, 'PILAR DO SUL' city_code, '3537909' ibge_code from dual union
select 'SP' state_code, 'PINDAMONHANGABA' city_code, '3538006' ibge_code from dual union
select 'SP' state_code, 'PINDORAMA' city_code, '3538105' ibge_code from dual union
select 'SP' state_code, 'PINHALZINHO' city_code, '3538204' ibge_code from dual union
select 'SP' state_code, 'PIQUEROBI' city_code, '3538303' ibge_code from dual union
select 'SP' state_code, 'PIQUETE' city_code, '3538501' ibge_code from dual union
select 'SP' state_code, 'PIRACAIA' city_code, '3538600' ibge_code from dual union
select 'SP' state_code, 'PIRACICABA' city_code, '3538709' ibge_code from dual union
select 'SP' state_code, 'PIRAJU' city_code, '3538808' ibge_code from dual union
select 'SP' state_code, 'PIRAJUI' city_code, '3538907' ibge_code from dual union
select 'SP' state_code, 'PIRANGI' city_code, '3539004' ibge_code from dual union
select 'SP' state_code, 'PIRAPORA DO BOM JESUS' city_code, '3539103' ibge_code from dual union
select 'SP' state_code, 'PIRAPOZINHO' city_code, '3539202' ibge_code from dual union
select 'SP' state_code, 'PIRASSUNUNGA' city_code, '3539301' ibge_code from dual union
select 'SP' state_code, 'PIRATININGA' city_code, '3539400' ibge_code from dual union
select 'SP' state_code, 'PITANGUEIRAS' city_code, '3539509' ibge_code from dual union
select 'SP' state_code, 'PLANALTO' city_code, '3539608' ibge_code from dual union
select 'SP' state_code, 'PLATINA' city_code, '3539707' ibge_code from dual union
select 'SP' state_code, 'POA' city_code, '3539806' ibge_code from dual union
select 'SP' state_code, 'POLONI' city_code, '3539905' ibge_code from dual union
select 'SP' state_code, 'POMPEIA' city_code, '3540002' ibge_code from dual union
select 'SP' state_code, 'PONGAI' city_code, '3540101' ibge_code from dual union
select 'SP' state_code, 'PONTAL' city_code, '3540200' ibge_code from dual union
select 'SP' state_code, 'PONTALINDA' city_code, '3540259' ibge_code from dual union
select 'SP' state_code, 'PONTES GESTAL' city_code, '3540309' ibge_code from dual union
select 'SP' state_code, 'POPULINA' city_code, '3540408' ibge_code from dual union
select 'SP' state_code, 'PORANGABA' city_code, '3540507' ibge_code from dual union
select 'SP' state_code, 'PORTO FELIZ' city_code, '3540606' ibge_code from dual union
select 'SP' state_code, 'PORTO FERREIRA' city_code, '3540705' ibge_code from dual union
select 'SP' state_code, 'POTIM' city_code, '3540754' ibge_code from dual union
select 'SP' state_code, 'POTIRENDABA' city_code, '3540804' ibge_code from dual union
select 'SP' state_code, 'PRACINHA' city_code, '3540853' ibge_code from dual union
select 'SP' state_code, 'PRADOPOLIS' city_code, '3540903' ibge_code from dual union
select 'SP' state_code, 'PRAIA GRANDE' city_code, '3541000' ibge_code from dual union
select 'SP' state_code, 'PRATANIA' city_code, '3541059' ibge_code from dual union
select 'SP' state_code, 'PRESIDENTE ALVES' city_code, '3541109' ibge_code from dual union
select 'SP' state_code, 'PRESIDENTE BERNARDES' city_code, '3541208' ibge_code from dual union
select 'SP' state_code, 'PRESIDENTE EPITACIO' city_code, '3541307' ibge_code from dual union
select 'SP' state_code, 'PRESIDENTE PRUDENTE' city_code, '3541406' ibge_code from dual union
select 'SP' state_code, 'PRESIDENTE VENCESLAU' city_code, '3541505' ibge_code from dual union
select 'SP' state_code, 'PROMISSAO' city_code, '3541604' ibge_code from dual union
select 'SP' state_code, 'QUADRA' city_code, '3541653' ibge_code from dual union
select 'SP' state_code, 'QUATA' city_code, '3541703' ibge_code from dual union
select 'SP' state_code, 'QUEIROZ' city_code, '3541802' ibge_code from dual union
select 'SP' state_code, 'QUELUZ' city_code, '3541901' ibge_code from dual union
select 'SP' state_code, 'QUINTANA' city_code, '3542008' ibge_code from dual union
select 'SP' state_code, 'RAFARD' city_code, '3542107' ibge_code from dual union
select 'SP' state_code, 'RANCHARIA' city_code, '3542206' ibge_code from dual union
select 'SP' state_code, 'REDENCAO DA SERRA' city_code, '3542305' ibge_code from dual union
select 'SP' state_code, 'REGENTE FEIJO' city_code, '3542404' ibge_code from dual union
select 'SP' state_code, 'REGINOPOLIS' city_code, '3542503' ibge_code from dual union
select 'SP' state_code, 'REGISTRO' city_code, '3542602' ibge_code from dual union
select 'SP' state_code, 'RESTINGA' city_code, '3542701' ibge_code from dual union
select 'SP' state_code, 'RIBEIRA' city_code, '3542800' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO BONITO' city_code, '3542909' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO BRANCO' city_code, '3543006' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO CORRENTE' city_code, '3543105' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO DO SUL' city_code, '3543204' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO DOS INDIOS' city_code, '3543238' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO GRANDE' city_code, '3543253' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO PIRES' city_code, '3543303' ibge_code from dual union
select 'SP' state_code, 'RIBEIRAO PRETO' city_code, '3543402' ibge_code from dual union
select 'SP' state_code, 'RIFAINA' city_code, '3543600' ibge_code from dual union
select 'SP' state_code, 'RINCAO' city_code, '3543709' ibge_code from dual union
select 'SP' state_code, 'RINOPOLIS' city_code, '3543808' ibge_code from dual union
select 'SP' state_code, 'RIO CLARO' city_code, '3543907' ibge_code from dual union
select 'SP' state_code, 'RIO DAS PEDRAS' city_code, '3544004' ibge_code from dual union
select 'SP' state_code, 'RIO GRANDE DA SERRA' city_code, '3544103' ibge_code from dual union
select 'SP' state_code, 'RIOLANDIA' city_code, '3544202' ibge_code from dual union
select 'SP' state_code, 'RIVERSUL' city_code, '3543501' ibge_code from dual union
select 'SP' state_code, 'ROSANA' city_code, '3544251' ibge_code from dual union
select 'SP' state_code, 'ROSEIRA' city_code, '3544301' ibge_code from dual union
select 'SP' state_code, 'RUBIACEA' city_code, '3544400' ibge_code from dual union
select 'SP' state_code, 'RUBINEIA' city_code, '3544509' ibge_code from dual union
select 'SP' state_code, 'SABINO' city_code, '3544608' ibge_code from dual union
select 'SP' state_code, 'SAGRES' city_code, '3544707' ibge_code from dual union
select 'SP' state_code, 'SALES' city_code, '3544806' ibge_code from dual union
select 'SP' state_code, 'SALES OLIVEIRA' city_code, '3544905' ibge_code from dual union
select 'SP' state_code, 'SALESOPOLIS' city_code, '3545001' ibge_code from dual union
select 'SP' state_code, 'SALMOURAO' city_code, '3545100' ibge_code from dual union
select 'SP' state_code, 'SALTINHO' city_code, '3545159' ibge_code from dual union
select 'SP' state_code, 'SALTO' city_code, '3545209' ibge_code from dual union
select 'SP' state_code, 'SALTO DE PIRAPORA' city_code, '3545308' ibge_code from dual union
select 'SP' state_code, 'SALTO GRANDE' city_code, '3545407' ibge_code from dual union
select 'SP' state_code, 'SANDOVALINA' city_code, '3545506' ibge_code from dual union
select 'SP' state_code, 'SANTA ADELIA' city_code, '3545605' ibge_code from dual union
select 'SP' state_code, 'SANTA ALBERTINA' city_code, '3545704' ibge_code from dual union
select 'SP' state_code, 'SANTA BARBARA D''OESTE' city_code, '3545803' ibge_code from dual union
select 'SP' state_code, 'SANTA BRANCA' city_code, '3546009' ibge_code from dual union
select 'SP' state_code, 'SANTA CLARA D''OESTE' city_code, '3546108' ibge_code from dual union
select 'SP' state_code, 'SANTA CRUZ DA CONCEICAO' city_code, '3546207' ibge_code from dual union
select 'SP' state_code, 'SANTA CRUZ DA ESPERANCA' city_code, '3546256' ibge_code from dual union
select 'SP' state_code, 'SANTA CRUZ DAS PALMEIRAS' city_code, '3546306' ibge_code from dual union
select 'SP' state_code, 'SANTA CRUZ DO RIO PARDO' city_code, '3546405' ibge_code from dual union
select 'SP' state_code, 'SANTA ERNESTINA' city_code, '3546504' ibge_code from dual union
select 'SP' state_code, 'SANTA FE DO SUL' city_code, '3546603' ibge_code from dual union
select 'SP' state_code, 'SANTA GERTRUDES' city_code, '3546702' ibge_code from dual union
select 'SP' state_code, 'SANTA ISABEL' city_code, '3546801' ibge_code from dual union
select 'SP' state_code, 'SANTA LUCIA' city_code, '3546900' ibge_code from dual union
select 'SP' state_code, 'SANTA MARIA DA SERRA' city_code, '3547007' ibge_code from dual union
select 'SP' state_code, 'SANTA MERCEDES' city_code, '3547106' ibge_code from dual union
select 'SP' state_code, 'SANTA RITA DO PASSA QUATRO' city_code, '3547502' ibge_code from dual union
select 'SP' state_code, 'SANTA RITA D''OESTE' city_code, '3547403' ibge_code from dual union
select 'SP' state_code, 'SANTA ROSA DE VITERBO' city_code, '3547601' ibge_code from dual union
select 'SP' state_code, 'SANTA SALETE' city_code, '3547650' ibge_code from dual union
select 'SP' state_code, 'SANTANA DA PONTE PENSA' city_code, '3547205' ibge_code from dual union
select 'SP' state_code, 'SANTANA DE PARNAIBA' city_code, '3547304' ibge_code from dual union
select 'SP' state_code, 'SANTO ANASTACIO' city_code, '3547700' ibge_code from dual union
select 'SP' state_code, 'SANTO ANDRE' city_code, '3547809' ibge_code from dual union
select 'SP' state_code, 'SANTO ANTONIO DA ALEGRIA' city_code, '3547908' ibge_code from dual union
select 'SP' state_code, 'SANTO ANTONIO DE POSSE' city_code, '3548005' ibge_code from dual union
select 'SP' state_code, 'SANTO ANTONIO DO ARACANGUA' city_code, '3548054' ibge_code from dual union
select 'SP' state_code, 'SANTO ANTONIO DO JARDIM' city_code, '3548104' ibge_code from dual union
select 'SP' state_code, 'SANTO ANTONIO DO PINHAL' city_code, '3548203' ibge_code from dual union
select 'SP' state_code, 'SANTO EXPEDITO' city_code, '3548302' ibge_code from dual union
select 'SP' state_code, 'SANTOPOLIS DO AGUAPEI' city_code, '3548401' ibge_code from dual union
select 'SP' state_code, 'SANTOS' city_code, '3548500' ibge_code from dual union
select 'SP' state_code, 'SAO BENTO DO SAPUCAI' city_code, '3548609' ibge_code from dual union
select 'SP' state_code, 'SAO BERNARDO DO CAMPO' city_code, '3548708' ibge_code from dual union
select 'SP' state_code, 'SAO CAETANO DO SUL' city_code, '3548807' ibge_code from dual union
select 'SP' state_code, 'SAO CARLOS' city_code, '3548906' ibge_code from dual union
select 'SP' state_code, 'SAO FRANCISCO' city_code, '3549003' ibge_code from dual union
select 'SP' state_code, 'SAO JOAO DA BOA VISTA' city_code, '3549102' ibge_code from dual union
select 'SP' state_code, 'SAO JOAO DAS DUAS PONTES' city_code, '3549201' ibge_code from dual union
select 'SP' state_code, 'SAO JOAO DE IRACEMA' city_code, '3549250' ibge_code from dual union
select 'SP' state_code, 'SAO JOAO DO PAU D''ALHO' city_code, '3549300' ibge_code from dual union
select 'SP' state_code, 'SAO JOAQUIM DA BARRA' city_code, '3549409' ibge_code from dual union
select 'SP' state_code, 'SAO JOSE DA BELA VISTA' city_code, '3549508' ibge_code from dual union
select 'SP' state_code, 'SAO JOSE DO BARREIRO' city_code, '3549607' ibge_code from dual union
select 'SP' state_code, 'SAO JOSE DO RIO PARDO' city_code, '3549706' ibge_code from dual union
select 'SP' state_code, 'SAO JOSE DO RIO PRETO' city_code, '3549805' ibge_code from dual union
select 'SP' state_code, 'SAO JOSE DOS CAMPOS' city_code, '3549904' ibge_code from dual union
select 'SP' state_code, 'SAO LOURENCO DA SERRA' city_code, '3549953' ibge_code from dual union
select 'SP' state_code, 'SAO LUIZ DO PARAITINGA' city_code, '3550001' ibge_code from dual union
select 'SP' state_code, 'SAO MANUEL' city_code, '3550100' ibge_code from dual union
select 'SP' state_code, 'SAO MIGUEL ARCANJO' city_code, '3550209' ibge_code from dual union
select 'SP' state_code, 'SAO PAULO' city_code, '3550308' ibge_code from dual union
select 'SP' state_code, 'SAO PEDRO' city_code, '3550407' ibge_code from dual union
select 'SP' state_code, 'SAO PEDRO DO TURVO' city_code, '3550506' ibge_code from dual union
select 'SP' state_code, 'SAO ROQUE' city_code, '3550605' ibge_code from dual union
select 'SP' state_code, 'SAO SEBASTIAO' city_code, '3550704' ibge_code from dual union
select 'SP' state_code, 'SAO SEBASTIAO DA GRAMA' city_code, '3550803' ibge_code from dual union
select 'SP' state_code, 'SAO SIMAO' city_code, '3550902' ibge_code from dual union
select 'SP' state_code, 'SAO VICENTE' city_code, '3551009' ibge_code from dual union
select 'SP' state_code, 'SARAPUI' city_code, '3551108' ibge_code from dual union
select 'SP' state_code, 'SARUTAIA' city_code, '3551207' ibge_code from dual union
select 'SP' state_code, 'SEBASTIANOPOLIS DO SUL' city_code, '3551306' ibge_code from dual union
select 'SP' state_code, 'SERRA AZUL' city_code, '3551405' ibge_code from dual union
select 'SP' state_code, 'SERRA NEGRA' city_code, '3551603' ibge_code from dual union
select 'SP' state_code, 'SERRANA' city_code, '3551504' ibge_code from dual union
select 'SP' state_code, 'SERTAOZINHO' city_code, '3551702' ibge_code from dual union
select 'SP' state_code, 'SETE BARRAS' city_code, '3551801' ibge_code from dual union
select 'SP' state_code, 'SEVERINIA' city_code, '3551900' ibge_code from dual union
select 'SP' state_code, 'SILVEIRAS' city_code, '3552007' ibge_code from dual union
select 'SP' state_code, 'SOCORRO' city_code, '3552106' ibge_code from dual union
select 'SP' state_code, 'SOROCABA' city_code, '3552205' ibge_code from dual union
select 'SP' state_code, 'SUD MENNUCCI' city_code, '3552304' ibge_code from dual union
select 'SP' state_code, 'SUMARE' city_code, '3552403' ibge_code from dual union
select 'SP' state_code, 'SUZANAPOLIS' city_code, '3552551' ibge_code from dual union
select 'SP' state_code, 'SUZANO' city_code, '3552502' ibge_code from dual union
select 'SP' state_code, 'TABAPUA' city_code, '3552601' ibge_code from dual union
select 'SP' state_code, 'TABATINGA' city_code, '3552700' ibge_code from dual union
select 'SP' state_code, 'TABOAO DA SERRA' city_code, '3552809' ibge_code from dual union
select 'SP' state_code, 'TACIBA' city_code, '3552908' ibge_code from dual union
select 'SP' state_code, 'TAGUAI' city_code, '3553005' ibge_code from dual union
select 'SP' state_code, 'TAIACU' city_code, '3553104' ibge_code from dual union
select 'SP' state_code, 'TAIUVA' city_code, '3553203' ibge_code from dual union
select 'SP' state_code, 'TAMBAU' city_code, '3553302' ibge_code from dual union
select 'SP' state_code, 'TANABI' city_code, '3553401' ibge_code from dual union
select 'SP' state_code, 'TAPIRAI' city_code, '3553500' ibge_code from dual union
select 'SP' state_code, 'TAPIRATIBA' city_code, '3553609' ibge_code from dual union
select 'SP' state_code, 'TAQUARAL' city_code, '3553658' ibge_code from dual union
select 'SP' state_code, 'TAQUARITINGA' city_code, '3553708' ibge_code from dual union
select 'SP' state_code, 'TAQUARITUBA' city_code, '3553807' ibge_code from dual union
select 'SP' state_code, 'TAQUARIVAI' city_code, '3553856' ibge_code from dual union
select 'SP' state_code, 'TARABAI' city_code, '3553906' ibge_code from dual union
select 'SP' state_code, 'TARUMA' city_code, '3553955' ibge_code from dual union
select 'SP' state_code, 'TATUI' city_code, '3554003' ibge_code from dual union
select 'SP' state_code, 'TAUBATE' city_code, '3554102' ibge_code from dual union
select 'SP' state_code, 'TEJUPA' city_code, '3554201' ibge_code from dual union
select 'SP' state_code, 'TEODORO SAMPAIO' city_code, '3554300' ibge_code from dual union
select 'SP' state_code, 'TERRA ROXA' city_code, '3554409' ibge_code from dual union
select 'SP' state_code, 'TIETE' city_code, '3554508' ibge_code from dual union
select 'SP' state_code, 'TIMBURI' city_code, '3554607' ibge_code from dual union
select 'SP' state_code, 'TORRE DE PEDRA' city_code, '3554656' ibge_code from dual union
select 'SP' state_code, 'TORRINHA' city_code, '3554706' ibge_code from dual union
select 'SP' state_code, 'TRABIJU' city_code, '3554755' ibge_code from dual union
select 'SP' state_code, 'TREMEMBE' city_code, '3554805' ibge_code from dual union
select 'SP' state_code, 'TRES FRONTEIRAS' city_code, '3554904' ibge_code from dual union
select 'SP' state_code, 'TUIUTI' city_code, '3554953' ibge_code from dual union
select 'SP' state_code, 'TUPA' city_code, '3555000' ibge_code from dual union
select 'SP' state_code, 'TUPI PAULISTA' city_code, '3555109' ibge_code from dual union
select 'SP' state_code, 'TURIUBA' city_code, '3555208' ibge_code from dual union
select 'SP' state_code, 'TURMALINA' city_code, '3555307' ibge_code from dual union
select 'SP' state_code, 'UBARANA' city_code, '3555356' ibge_code from dual union
select 'SP' state_code, 'UBATUBA' city_code, '3555406' ibge_code from dual union
select 'SP' state_code, 'UBIRAJARA' city_code, '3555505' ibge_code from dual union
select 'SP' state_code, 'UCHOA' city_code, '3555604' ibge_code from dual union
select 'SP' state_code, 'UNIAO PAULISTA' city_code, '3555703' ibge_code from dual union
select 'SP' state_code, 'URANIA' city_code, '3555802' ibge_code from dual union
select 'SP' state_code, 'URU' city_code, '3555901' ibge_code from dual union
select 'SP' state_code, 'URUPES' city_code, '3556008' ibge_code from dual union
select 'SP' state_code, 'VALENTIM GENTIL' city_code, '3556107' ibge_code from dual union
select 'SP' state_code, 'VALINHOS' city_code, '3556206' ibge_code from dual union
select 'SP' state_code, 'VALPARAISO' city_code, '3556305' ibge_code from dual union
select 'SP' state_code, 'VARGEM' city_code, '3556354' ibge_code from dual union
select 'SP' state_code, 'VARGEM GRANDE DO SUL' city_code, '3556404' ibge_code from dual union
select 'SP' state_code, 'VARGEM GRANDE PAULISTA' city_code, '3556453' ibge_code from dual union
select 'SP' state_code, 'VARZEA PAULISTA' city_code, '3556503' ibge_code from dual union
select 'SP' state_code, 'VERA CRUZ' city_code, '3556602' ibge_code from dual union
select 'SP' state_code, 'VINHEDO' city_code, '3556701' ibge_code from dual union
select 'SP' state_code, 'VIRADOURO' city_code, '3556800' ibge_code from dual union
select 'SP' state_code, 'VISTA ALEGRE DO ALTO' city_code, '3556909' ibge_code from dual union
select 'SP' state_code, 'VITORIA BRASIL' city_code, '3556958' ibge_code from dual union
select 'SP' state_code, 'VOTORANTIM' city_code, '3557006' ibge_code from dual union
select 'SP' state_code, 'VOTUPORANGA' city_code, '3557105' ibge_code from dual union
select 'SP' state_code, 'ZACARIAS' city_code, '3557154' ibge_code from dual union
select 'PR' state_code, 'ABATIA' city_code, '4100103' ibge_code from dual union
select 'PR' state_code, 'ADRIANOPOLIS' city_code, '4100202' ibge_code from dual union
select 'PR' state_code, 'AGUDOS DO SUL' city_code, '4100301' ibge_code from dual union
select 'PR' state_code, 'ALMIRANTE TAMANDARE' city_code, '4100400' ibge_code from dual union
select 'PR' state_code, 'ALTAMIRA DO PARANA' city_code, '4100459' ibge_code from dual union
select 'PR' state_code, 'ALTO PARAISO' city_code, '4128625' ibge_code from dual union
select 'PR' state_code, 'ALTO PARANA' city_code, '4100608' ibge_code from dual union
select 'PR' state_code, 'ALTO PIQUIRI' city_code, '4100707' ibge_code from dual union
select 'PR' state_code, 'ALTONIA' city_code, '4100509' ibge_code from dual union
select 'PR' state_code, 'ALVORADA DO SUL' city_code, '4100806' ibge_code from dual union
select 'PR' state_code, 'AMAPORA' city_code, '4100905' ibge_code from dual union
select 'PR' state_code, 'AMPERE' city_code, '4101002' ibge_code from dual union
select 'PR' state_code, 'ANAHY' city_code, '4101051' ibge_code from dual union
select 'PR' state_code, 'ANDIRA' city_code, '4101101' ibge_code from dual union
select 'PR' state_code, 'ANGULO' city_code, '4101150' ibge_code from dual union
select 'PR' state_code, 'ANTONINA' city_code, '4101200' ibge_code from dual union
select 'PR' state_code, 'ANTONIO OLINTO' city_code, '4101309' ibge_code from dual union
select 'PR' state_code, 'APUCARANA' city_code, '4101408' ibge_code from dual union
select 'PR' state_code, 'ARAPONGAS' city_code, '4101507' ibge_code from dual union
select 'PR' state_code, 'ARAPOTI' city_code, '4101606' ibge_code from dual union
select 'PR' state_code, 'ARAPUA' city_code, '4101655' ibge_code from dual union
select 'PR' state_code, 'ARARUNA' city_code, '4101705' ibge_code from dual union
select 'PR' state_code, 'ARAUCARIA' city_code, '4101804' ibge_code from dual union
select 'PR' state_code, 'ARIRANHA DO IVAI' city_code, '4101853' ibge_code from dual union
select 'PR' state_code, 'ASSAI' city_code, '4101903' ibge_code from dual union
select 'PR' state_code, 'ASSIS CHATEAUBRIAND' city_code, '4102000' ibge_code from dual union
select 'PR' state_code, 'ASTORGA' city_code, '4102109' ibge_code from dual union
select 'PR' state_code, 'ATALAIA' city_code, '4102208' ibge_code from dual union
select 'PR' state_code, 'BALSA NOVA' city_code, '4102307' ibge_code from dual union
select 'PR' state_code, 'BANDEIRANTES' city_code, '4102406' ibge_code from dual union
select 'PR' state_code, 'BARBOSA FERRAZ' city_code, '4102505' ibge_code from dual union
select 'PR' state_code, 'BARRA DO JACARE' city_code, '4102703' ibge_code from dual union
select 'PR' state_code, 'BARRACAO' city_code, '4102604' ibge_code from dual union
select 'PR' state_code, 'BELA VISTA DA CAROBA' city_code, '4102752' ibge_code from dual union
select 'PR' state_code, 'BELA VISTA DO PARAISO' city_code, '4102802' ibge_code from dual union
select 'PR' state_code, 'BITURUNA' city_code, '4102901' ibge_code from dual union
select 'PR' state_code, 'BOA ESPERANCA' city_code, '4103008' ibge_code from dual union
select 'PR' state_code, 'BOA ESPERANCA DO IGUACU' city_code, '4103024' ibge_code from dual union
select 'PR' state_code, 'BOA VENTURA DE SAO ROQUE' city_code, '4103040' ibge_code from dual union
select 'PR' state_code, 'BOA VISTA DA APARECIDA' city_code, '4103057' ibge_code from dual union
select 'PR' state_code, 'BOCAIUVA DO SUL' city_code, '4103107' ibge_code from dual union
select 'PR' state_code, 'BOM JESUS DO SUL' city_code, '4103156' ibge_code from dual union
select 'PR' state_code, 'BOM SUCESSO' city_code, '4103206' ibge_code from dual union
select 'PR' state_code, 'BOM SUCESSO DO SUL' city_code, '4103222' ibge_code from dual union
select 'PR' state_code, 'BORRAZOPOLIS' city_code, '4103305' ibge_code from dual union
select 'PR' state_code, 'BRAGANEY' city_code, '4103354' ibge_code from dual union
select 'PR' state_code, 'BRASILANDIA DO SUL' city_code, '4103370' ibge_code from dual union
select 'PR' state_code, 'CAFEARA' city_code, '4103404' ibge_code from dual union
select 'PR' state_code, 'CAFELANDIA' city_code, '4103453' ibge_code from dual union
select 'PR' state_code, 'CAFEZAL DO SUL' city_code, '4103479' ibge_code from dual union
select 'PR' state_code, 'CALIFORNIA' city_code, '4103503' ibge_code from dual union
select 'PR' state_code, 'CAMBARA' city_code, '4103602' ibge_code from dual union
select 'PR' state_code, 'CAMBE' city_code, '4103701' ibge_code from dual union
select 'PR' state_code, 'CAMBIRA' city_code, '4103800' ibge_code from dual union
select 'PR' state_code, 'CAMPINA DA LAGOA' city_code, '4103909' ibge_code from dual union
select 'PR' state_code, 'CAMPINA DO SIMAO' city_code, '4103958' ibge_code from dual union
select 'PR' state_code, 'CAMPINA GRANDE DO SUL' city_code, '4104006' ibge_code from dual union
select 'PR' state_code, 'CAMPO BONITO' city_code, '4104055' ibge_code from dual union
select 'PR' state_code, 'CAMPO DO TENENTE' city_code, '4104105' ibge_code from dual union
select 'PR' state_code, 'CAMPO LARGO' city_code, '4104204' ibge_code from dual union
select 'PR' state_code, 'CAMPO MAGRO' city_code, '4104253' ibge_code from dual union
select 'PR' state_code, 'CAMPO MOURAO' city_code, '4104303' ibge_code from dual union
select 'PR' state_code, 'CANDIDO DE ABREU' city_code, '4104402' ibge_code from dual union
select 'PR' state_code, 'CANDOI' city_code, '4104428' ibge_code from dual union
select 'PR' state_code, 'CANTAGALO' city_code, '4104451' ibge_code from dual union
select 'PR' state_code, 'CAPANEMA' city_code, '4104501' ibge_code from dual union
select 'PR' state_code, 'CAPITAO LEONIDAS MARQUES' city_code, '4104600' ibge_code from dual union
select 'PR' state_code, 'CARAMBEI' city_code, '4104659' ibge_code from dual union
select 'PR' state_code, 'CARLOPOLIS' city_code, '4104709' ibge_code from dual union
select 'PR' state_code, 'CASCAVEL' city_code, '4104808' ibge_code from dual union
select 'PR' state_code, 'CASTRO' city_code, '4104907' ibge_code from dual union
select 'PR' state_code, 'CATANDUVAS' city_code, '4105003' ibge_code from dual union
select 'PR' state_code, 'CENTENARIO DO SUL' city_code, '4105102' ibge_code from dual union
select 'PR' state_code, 'CERRO AZUL' city_code, '4105201' ibge_code from dual union
select 'PR' state_code, 'CEU AZUL' city_code, '4105300' ibge_code from dual union
select 'PR' state_code, 'CHOPINZINHO' city_code, '4105409' ibge_code from dual union
select 'PR' state_code, 'CIANORTE' city_code, '4105508' ibge_code from dual union
select 'PR' state_code, 'CIDADE GAUCHA' city_code, '4105607' ibge_code from dual union
select 'PR' state_code, 'CLEVELANDIA' city_code, '4105706' ibge_code from dual union
select 'PR' state_code, 'COLOMBO' city_code, '4105805' ibge_code from dual union
select 'PR' state_code, 'COLORADO' city_code, '4105904' ibge_code from dual union
select 'PR' state_code, 'CONGONHINHAS' city_code, '4106001' ibge_code from dual union
select 'PR' state_code, 'CONSELHEIRO MAIRINCK' city_code, '4106100' ibge_code from dual union
select 'PR' state_code, 'CONTENDA' city_code, '4106209' ibge_code from dual union
select 'PR' state_code, 'CORBELIA' city_code, '4106308' ibge_code from dual union
select 'PR' state_code, 'CORNELIO PROCOPIO' city_code, '4106407' ibge_code from dual union
select 'PR' state_code, 'CORONEL DOMINGOS SOARES' city_code, '4106456' ibge_code from dual union
select 'PR' state_code, 'CORONEL VIVIDA' city_code, '4106506' ibge_code from dual union
select 'PR' state_code, 'CORUMBATAI DO SUL' city_code, '4106555' ibge_code from dual union
select 'PR' state_code, 'CRUZ MACHADO' city_code, '4106803' ibge_code from dual union
select 'PR' state_code, 'CRUZEIRO DO IGUACU' city_code, '4106571' ibge_code from dual union
select 'PR' state_code, 'CRUZEIRO DO OESTE' city_code, '4106605' ibge_code from dual union
select 'PR' state_code, 'CRUZEIRO DO SUL' city_code, '4106704' ibge_code from dual union
select 'PR' state_code, 'CRUZMALTINA' city_code, '4106852' ibge_code from dual union
select 'PR' state_code, 'CURITIBA' city_code, '4106902' ibge_code from dual union
select 'PR' state_code, 'CURIUVA' city_code, '4107009' ibge_code from dual union
select 'PR' state_code, 'DIAMANTE DO NORTE' city_code, '4107108' ibge_code from dual union
select 'PR' state_code, 'DIAMANTE DO SUL' city_code, '4107124' ibge_code from dual union
select 'PR' state_code, 'DIAMANTE D''OESTE' city_code, '4107157' ibge_code from dual union
select 'PR' state_code, 'DOIS VIZINHOS' city_code, '4107207' ibge_code from dual union
select 'PR' state_code, 'DOURADINA' city_code, '4107256' ibge_code from dual union
select 'PR' state_code, 'DOUTOR CAMARGO' city_code, '4107306' ibge_code from dual union
select 'PR' state_code, 'DOUTOR ULYSSES' city_code, '4128633' ibge_code from dual union
select 'PR' state_code, 'ENEAS MARQUES' city_code, '4107405' ibge_code from dual union
select 'PR' state_code, 'ENGENHEIRO BELTRAO' city_code, '4107504' ibge_code from dual union
select 'PR' state_code, 'ENTRE RIOS DO OESTE' city_code, '4107538' ibge_code from dual union
select 'PR' state_code, 'ESPERANCA NOVA' city_code, '4107520' ibge_code from dual union
select 'PR' state_code, 'ESPIGAO ALTO DO IGUACU' city_code, '4107546' ibge_code from dual union
select 'PR' state_code, 'FAROL' city_code, '4107553' ibge_code from dual union
select 'PR' state_code, 'FAXINAL' city_code, '4107603' ibge_code from dual union
select 'PR' state_code, 'FAZENDA RIO GRANDE' city_code, '4107652' ibge_code from dual union
select 'PR' state_code, 'FENIX' city_code, '4107702' ibge_code from dual union
select 'PR' state_code, 'FERNANDES PINHEIRO' city_code, '4107736' ibge_code from dual union
select 'PR' state_code, 'FIGUEIRA' city_code, '4107751' ibge_code from dual union
select 'PR' state_code, 'FLOR DA SERRA DO SUL' city_code, '4107850' ibge_code from dual union
select 'PR' state_code, 'FLORAI' city_code, '4107801' ibge_code from dual union
select 'PR' state_code, 'FLORESTA' city_code, '4107900' ibge_code from dual union
select 'PR' state_code, 'FLORESTOPOLIS' city_code, '4108007' ibge_code from dual union
select 'PR' state_code, 'FLORIDA' city_code, '4108106' ibge_code from dual union
select 'PR' state_code, 'FORMOSA DO OESTE' city_code, '4108205' ibge_code from dual union
select 'PR' state_code, 'FOZ DO IGUACU' city_code, '4108304' ibge_code from dual union
select 'PR' state_code, 'FOZ DO JORDAO' city_code, '4108452' ibge_code from dual union
select 'PR' state_code, 'FRANCISCO ALVES' city_code, '4108320' ibge_code from dual union
select 'PR' state_code, 'FRANCISCO BELTRAO' city_code, '4108403' ibge_code from dual union
select 'PR' state_code, 'GENERAL CARNEIRO' city_code, '4108502' ibge_code from dual union
select 'PR' state_code, 'GODOY MOREIRA' city_code, '4108551' ibge_code from dual union
select 'PR' state_code, 'GOIOERE' city_code, '4108601' ibge_code from dual union
select 'PR' state_code, 'GOIOXIM' city_code, '4108650' ibge_code from dual union
select 'PR' state_code, 'GRANDES RIOS' city_code, '4108700' ibge_code from dual union
select 'PR' state_code, 'GUAIRA' city_code, '4108809' ibge_code from dual union
select 'PR' state_code, 'GUAIRACA' city_code, '4108908' ibge_code from dual union
select 'PR' state_code, 'GUAMIRANGA' city_code, '4108957' ibge_code from dual union
select 'PR' state_code, 'GUAPIRAMA' city_code, '4109005' ibge_code from dual union
select 'PR' state_code, 'GUAPOREMA' city_code, '4109104' ibge_code from dual union
select 'PR' state_code, 'GUARACI' city_code, '4109203' ibge_code from dual union
select 'PR' state_code, 'GUARANIACU' city_code, '4109302' ibge_code from dual union
select 'PR' state_code, 'GUARAPUAVA' city_code, '4109401' ibge_code from dual union
select 'PR' state_code, 'GUARAQUECABA' city_code, '4109500' ibge_code from dual union
select 'PR' state_code, 'GUARATUBA' city_code, '4109609' ibge_code from dual union
select 'PR' state_code, 'HONORIO SERPA' city_code, '4109658' ibge_code from dual union
select 'PR' state_code, 'IBAITI' city_code, '4109708' ibge_code from dual union
select 'PR' state_code, 'IBEMA' city_code, '4109757' ibge_code from dual union
select 'PR' state_code, 'IBIPORA' city_code, '4109807' ibge_code from dual union
select 'PR' state_code, 'ICARAIMA' city_code, '4109906' ibge_code from dual union
select 'PR' state_code, 'IGUARACU' city_code, '4110003' ibge_code from dual union
select 'PR' state_code, 'IGUATU' city_code, '4110052' ibge_code from dual union
select 'PR' state_code, 'IMBAU' city_code, '4110078' ibge_code from dual union
select 'PR' state_code, 'IMBITUVA' city_code, '4110102' ibge_code from dual union
select 'PR' state_code, 'INACIO MARTINS' city_code, '4110201' ibge_code from dual union
select 'PR' state_code, 'INAJA' city_code, '4110300' ibge_code from dual union
select 'PR' state_code, 'INDIANOPOLIS' city_code, '4110409' ibge_code from dual union
select 'PR' state_code, 'IPIRANGA' city_code, '4110508' ibge_code from dual union
select 'PR' state_code, 'IPORA' city_code, '4110607' ibge_code from dual union
select 'PR' state_code, 'IRACEMA DO OESTE' city_code, '4110656' ibge_code from dual union
select 'PR' state_code, 'IRATI' city_code, '4110706' ibge_code from dual union
select 'PR' state_code, 'IRETAMA' city_code, '4110805' ibge_code from dual union
select 'PR' state_code, 'ITAGUAJE' city_code, '4110904' ibge_code from dual union
select 'PR' state_code, 'ITAIPULANDIA' city_code, '4110953' ibge_code from dual union
select 'PR' state_code, 'ITAMBARACA' city_code, '4111001' ibge_code from dual union
select 'PR' state_code, 'ITAMBE' city_code, '4111100' ibge_code from dual union
select 'PR' state_code, 'ITAPEJARA D''OESTE' city_code, '4111209' ibge_code from dual union
select 'PR' state_code, 'ITAPERUCU' city_code, '4111258' ibge_code from dual union
select 'PR' state_code, 'ITAUNA DO SUL' city_code, '4111308' ibge_code from dual union
select 'PR' state_code, 'IVAI' city_code, '4111407' ibge_code from dual union
select 'PR' state_code, 'IVAIPORA' city_code, '4111506' ibge_code from dual union
select 'PR' state_code, 'IVATE' city_code, '4111555' ibge_code from dual union
select 'PR' state_code, 'IVATUBA' city_code, '4111605' ibge_code from dual union
select 'PR' state_code, 'JABOTI' city_code, '4111704' ibge_code from dual union
select 'PR' state_code, 'JACAREZINHO' city_code, '4111803' ibge_code from dual union
select 'PR' state_code, 'JAGUAPITA' city_code, '4111902' ibge_code from dual union
select 'PR' state_code, 'JAGUARIAIVA' city_code, '4112009' ibge_code from dual union
select 'PR' state_code, 'JANDAIA DO SUL' city_code, '4112108' ibge_code from dual union
select 'PR' state_code, 'JANIOPOLIS' city_code, '4112207' ibge_code from dual union
select 'PR' state_code, 'JAPIRA' city_code, '4112306' ibge_code from dual union
select 'PR' state_code, 'JAPURA' city_code, '4112405' ibge_code from dual union
select 'PR' state_code, 'JARDIM ALEGRE' city_code, '4112504' ibge_code from dual union
select 'PR' state_code, 'JARDIM OLINDA' city_code, '4112603' ibge_code from dual union
select 'PR' state_code, 'JATAIZINHO' city_code, '4112702' ibge_code from dual union
select 'PR' state_code, 'JESUITAS' city_code, '4112751' ibge_code from dual union
select 'PR' state_code, 'JOAQUIM TAVORA' city_code, '4112801' ibge_code from dual union
select 'PR' state_code, 'JUNDIAI DO SUL' city_code, '4112900' ibge_code from dual union
select 'PR' state_code, 'JURANDA' city_code, '4112959' ibge_code from dual union
select 'PR' state_code, 'JUSSARA' city_code, '4113007' ibge_code from dual union
select 'PR' state_code, 'KALORE' city_code, '4113106' ibge_code from dual union
select 'PR' state_code, 'LAPA' city_code, '4113205' ibge_code from dual union
select 'PR' state_code, 'LARANJAL' city_code, '4113254' ibge_code from dual union
select 'PR' state_code, 'LARANJEIRAS DO SUL' city_code, '4113304' ibge_code from dual union
select 'PR' state_code, 'LEOPOLIS' city_code, '4113403' ibge_code from dual union
select 'PR' state_code, 'LIDIANOPOLIS' city_code, '4113429' ibge_code from dual union
select 'PR' state_code, 'LINDOESTE' city_code, '4113452' ibge_code from dual union
select 'PR' state_code, 'LOANDA' city_code, '4113502' ibge_code from dual union
select 'PR' state_code, 'LOBATO' city_code, '4113601' ibge_code from dual union
select 'PR' state_code, 'LONDRINA' city_code, '4113700' ibge_code from dual union
select 'PR' state_code, 'LUIZIANA' city_code, '4113734' ibge_code from dual union
select 'PR' state_code, 'LUNARDELLI' city_code, '4113759' ibge_code from dual union
select 'PR' state_code, 'LUPIONOPOLIS' city_code, '4113809' ibge_code from dual union
select 'PR' state_code, 'MALLET' city_code, '4113908' ibge_code from dual union
select 'PR' state_code, 'MAMBORE' city_code, '4114005' ibge_code from dual union
select 'PR' state_code, 'MANDAGUACU' city_code, '4114104' ibge_code from dual union
select 'PR' state_code, 'MANDAGUARI' city_code, '4114203' ibge_code from dual union
select 'PR' state_code, 'MANDIRITUBA' city_code, '4114302' ibge_code from dual union
select 'PR' state_code, 'MANFRINOPOLIS' city_code, '4114351' ibge_code from dual union
select 'PR' state_code, 'MANGUEIRINHA' city_code, '4114401' ibge_code from dual union
select 'PR' state_code, 'MANOEL RIBAS' city_code, '4114500' ibge_code from dual union
select 'PR' state_code, 'MARECHAL CANDIDO RONDON' city_code, '4114609' ibge_code from dual union
select 'PR' state_code, 'MARIA HELENA' city_code, '4114708' ibge_code from dual union
select 'PR' state_code, 'MARIALVA' city_code, '4114807' ibge_code from dual union
select 'PR' state_code, 'MARILANDIA DO SUL' city_code, '4114906' ibge_code from dual union
select 'PR' state_code, 'MARILENA' city_code, '4115002' ibge_code from dual union
select 'PR' state_code, 'MARILUZ' city_code, '4115101' ibge_code from dual union
select 'PR' state_code, 'MARINGA' city_code, '4115200' ibge_code from dual union
select 'PR' state_code, 'MARIOPOLIS' city_code, '4115309' ibge_code from dual union
select 'PR' state_code, 'MARIPA' city_code, '4115358' ibge_code from dual union
select 'PR' state_code, 'MARMELEIRO' city_code, '4115408' ibge_code from dual union
select 'PR' state_code, 'MARQUINHO' city_code, '4115457' ibge_code from dual union
select 'PR' state_code, 'MARUMBI' city_code, '4115507' ibge_code from dual union
select 'PR' state_code, 'MATELANDIA' city_code, '4115606' ibge_code from dual union
select 'PR' state_code, 'MATINHOS' city_code, '4115705' ibge_code from dual union
select 'PR' state_code, 'MATO RICO' city_code, '4115739' ibge_code from dual union
select 'PR' state_code, 'MAUA DA SERRA' city_code, '4115754' ibge_code from dual union
select 'PR' state_code, 'MEDIANEIRA' city_code, '4115804' ibge_code from dual union
select 'PR' state_code, 'MERCEDES' city_code, '4115853' ibge_code from dual union
select 'PR' state_code, 'MIRADOR' city_code, '4115903' ibge_code from dual union
select 'PR' state_code, 'MIRASELVA' city_code, '4116000' ibge_code from dual union
select 'PR' state_code, 'MISSAL' city_code, '4116059' ibge_code from dual union
select 'PR' state_code, 'MOREIRA SALES' city_code, '4116109' ibge_code from dual union
select 'PR' state_code, 'MORRETES' city_code, '4116208' ibge_code from dual union
select 'PR' state_code, 'MUNHOZ DE MELO' city_code, '4116307' ibge_code from dual union
select 'PR' state_code, 'NOSSA SENHORA DAS GRACAS' city_code, '4116406' ibge_code from dual union
select 'PR' state_code, 'NOVA ALIANCA DO IVAI' city_code, '4116505' ibge_code from dual union
select 'PR' state_code, 'NOVA AMERICA DA COLINA' city_code, '4116604' ibge_code from dual union
select 'PR' state_code, 'NOVA AURORA' city_code, '4116703' ibge_code from dual union
select 'PR' state_code, 'NOVA CANTU' city_code, '4116802' ibge_code from dual union
select 'PR' state_code, 'NOVA ESPERANCA' city_code, '4116901' ibge_code from dual union
select 'PR' state_code, 'NOVA ESPERANCA DO SUDOESTE' city_code, '4116950' ibge_code from dual union
select 'PR' state_code, 'NOVA FATIMA' city_code, '4117008' ibge_code from dual union
select 'PR' state_code, 'NOVA LARANJEIRAS' city_code, '4117057' ibge_code from dual union
select 'PR' state_code, 'NOVA LONDRINA' city_code, '4117107' ibge_code from dual union
select 'PR' state_code, 'NOVA OLIMPIA' city_code, '4117206' ibge_code from dual union
select 'PR' state_code, 'NOVA PRATA DO IGUACU' city_code, '4117255' ibge_code from dual union
select 'PR' state_code, 'NOVA SANTA BARBARA' city_code, '4117214' ibge_code from dual union
select 'PR' state_code, 'NOVA SANTA ROSA' city_code, '4117222' ibge_code from dual union
select 'PR' state_code, 'NOVA TEBAS' city_code, '4117271' ibge_code from dual union
select 'PR' state_code, 'NOVO ITACOLOMI' city_code, '4117297' ibge_code from dual union
select 'PR' state_code, 'ORTIGUEIRA' city_code, '4117305' ibge_code from dual union
select 'PR' state_code, 'OURIZONA' city_code, '4117404' ibge_code from dual union
select 'PR' state_code, 'OURO VERDE DO OESTE' city_code, '4117453' ibge_code from dual union
select 'PR' state_code, 'PAICANDU' city_code, '4117503' ibge_code from dual union
select 'PR' state_code, 'PALMAS' city_code, '4117602' ibge_code from dual union
select 'PR' state_code, 'PALMEIRA' city_code, '4117701' ibge_code from dual union
select 'PR' state_code, 'PALMITAL' city_code, '4117800' ibge_code from dual union
select 'PR' state_code, 'PALOTINA' city_code, '4117909' ibge_code from dual union
select 'PR' state_code, 'PARAISO DO NORTE' city_code, '4118006' ibge_code from dual union
select 'PR' state_code, 'PARANACITY' city_code, '4118105' ibge_code from dual union
select 'PR' state_code, 'PARANAGUA' city_code, '4118204' ibge_code from dual union
select 'PR' state_code, 'PARANAPOEMA' city_code, '4118303' ibge_code from dual union
select 'PR' state_code, 'PARANAVAI' city_code, '4118402' ibge_code from dual union
select 'PR' state_code, 'PATO BRAGADO' city_code, '4118451' ibge_code from dual union
select 'PR' state_code, 'PATO BRANCO' city_code, '4118501' ibge_code from dual union
select 'PR' state_code, 'PAULA FREITAS' city_code, '4118600' ibge_code from dual union
select 'PR' state_code, 'PAULO FRONTIN' city_code, '4118709' ibge_code from dual union
select 'PR' state_code, 'PEABIRU' city_code, '4118808' ibge_code from dual union
select 'PR' state_code, 'PEROBAL' city_code, '4118857' ibge_code from dual union
select 'PR' state_code, 'PEROLA' city_code, '4118907' ibge_code from dual union
select 'PR' state_code, 'PEROLA D''OESTE' city_code, '4119004' ibge_code from dual union
select 'PR' state_code, 'PIEN' city_code, '4119103' ibge_code from dual union
select 'PR' state_code, 'PINHAIS' city_code, '4119152' ibge_code from dual union
select 'PR' state_code, 'PINHAL DE SAO BENTO' city_code, '4119251' ibge_code from dual union
select 'PR' state_code, 'PINHALAO' city_code, '4119202' ibge_code from dual union
select 'PR' state_code, 'PINHAO' city_code, '4119301' ibge_code from dual union
select 'PR' state_code, 'PIRAI DO SUL' city_code, '4119400' ibge_code from dual union
select 'PR' state_code, 'PIRAQUARA' city_code, '4119509' ibge_code from dual union
select 'PR' state_code, 'PITANGA' city_code, '4119608' ibge_code from dual union
select 'PR' state_code, 'PITANGUEIRAS' city_code, '4119657' ibge_code from dual union
select 'PR' state_code, 'PLANALTINA DO PARANA' city_code, '4119707' ibge_code from dual union
select 'PR' state_code, 'PLANALTO' city_code, '4119806' ibge_code from dual union
select 'PR' state_code, 'PONTA GROSSA' city_code, '4119905' ibge_code from dual union
select 'PR' state_code, 'PONTAL DO PARANA' city_code, '4119954' ibge_code from dual union
select 'PR' state_code, 'PORECATU' city_code, '4120002' ibge_code from dual union
select 'PR' state_code, 'PORTO AMAZONAS' city_code, '4120101' ibge_code from dual union
select 'PR' state_code, 'PORTO BARREIRO' city_code, '4120150' ibge_code from dual union
select 'PR' state_code, 'PORTO RICO' city_code, '4120200' ibge_code from dual union
select 'PR' state_code, 'PORTO VITORIA' city_code, '4120309' ibge_code from dual union
select 'PR' state_code, 'PRADO FERREIRA' city_code, '4120333' ibge_code from dual union
select 'PR' state_code, 'PRANCHITA' city_code, '4120358' ibge_code from dual union
select 'PR' state_code, 'PRESIDENTE CASTELO BRANCO' city_code, '4120408' ibge_code from dual union
select 'PR' state_code, 'PRIMEIRO DE MAIO' city_code, '4120507' ibge_code from dual union
select 'PR' state_code, 'PRUDENTOPOLIS' city_code, '4120606' ibge_code from dual union
select 'PR' state_code, 'QUARTO CENTENARIO' city_code, '4120655' ibge_code from dual union
select 'PR' state_code, 'QUATIGUA' city_code, '4120705' ibge_code from dual union
select 'PR' state_code, 'QUATRO BARRAS' city_code, '4120804' ibge_code from dual union
select 'PR' state_code, 'QUATRO PONTES' city_code, '4120853' ibge_code from dual union
select 'PR' state_code, 'QUEDAS DO IGUACU' city_code, '4120903' ibge_code from dual union
select 'PR' state_code, 'QUERENCIA DO NORTE' city_code, '4121000' ibge_code from dual union
select 'PR' state_code, 'QUINTA DO SOL' city_code, '4121109' ibge_code from dual union
select 'PR' state_code, 'QUITANDINHA' city_code, '4121208' ibge_code from dual union
select 'PR' state_code, 'RAMILANDIA' city_code, '4121257' ibge_code from dual union
select 'PR' state_code, 'RANCHO ALEGRE' city_code, '4121307' ibge_code from dual union
select 'PR' state_code, 'RANCHO ALEGRE D''OESTE' city_code, '4121356' ibge_code from dual union
select 'PR' state_code, 'REALEZA' city_code, '4121406' ibge_code from dual union
select 'PR' state_code, 'REBOUCAS' city_code, '4121505' ibge_code from dual union
select 'PR' state_code, 'RENASCENCA' city_code, '4121604' ibge_code from dual union
select 'PR' state_code, 'RESERVA' city_code, '4121703' ibge_code from dual union
select 'PR' state_code, 'RESERVA DO IGUACU' city_code, '4121752' ibge_code from dual union
select 'PR' state_code, 'RIBEIRAO CLARO' city_code, '4121802' ibge_code from dual union
select 'PR' state_code, 'RIBEIRAO DO PINHAL' city_code, '4121901' ibge_code from dual union
select 'PR' state_code, 'RIO AZUL' city_code, '4122008' ibge_code from dual union
select 'PR' state_code, 'RIO BOM' city_code, '4122107' ibge_code from dual union
select 'PR' state_code, 'RIO BONITO DO IGUACU' city_code, '4122156' ibge_code from dual union
select 'PR' state_code, 'RIO BRANCO DO IVAI' city_code, '4122172' ibge_code from dual union
select 'PR' state_code, 'RIO BRANCO DO SUL' city_code, '4122206' ibge_code from dual union
select 'PR' state_code, 'RIO NEGRO' city_code, '4122305' ibge_code from dual union
select 'PR' state_code, 'ROLANDIA' city_code, '4122404' ibge_code from dual union
select 'PR' state_code, 'RONCADOR' city_code, '4122503' ibge_code from dual union
select 'PR' state_code, 'RONDON' city_code, '4122602' ibge_code from dual union
select 'PR' state_code, 'ROSARIO DO IVAI' city_code, '4122651' ibge_code from dual union
select 'PR' state_code, 'SABAUDIA' city_code, '4122701' ibge_code from dual union
select 'PR' state_code, 'SALGADO FILHO' city_code, '4122800' ibge_code from dual union
select 'PR' state_code, 'SALTO DO ITARARE' city_code, '4122909' ibge_code from dual union
select 'PR' state_code, 'SALTO DO LONTRA' city_code, '4123006' ibge_code from dual union
select 'PR' state_code, 'SANTA AMELIA' city_code, '4123105' ibge_code from dual union
select 'PR' state_code, 'SANTA CECILIA DO PAVAO' city_code, '4123204' ibge_code from dual union
select 'PR' state_code, 'SANTA CRUZ DE MONTE CASTELO' city_code, '4123303' ibge_code from dual union
select 'PR' state_code, 'SANTA FE' city_code, '4123402' ibge_code from dual union
select 'PR' state_code, 'SANTA HELENA' city_code, '4123501' ibge_code from dual union
select 'PR' state_code, 'SANTA INES' city_code, '4123600' ibge_code from dual union
select 'PR' state_code, 'SANTA ISABEL DO IVAI' city_code, '4123709' ibge_code from dual union
select 'PR' state_code, 'SANTA IZABEL DO OESTE' city_code, '4123808' ibge_code from dual union
select 'PR' state_code, 'SANTA LUCIA' city_code, '4123824' ibge_code from dual union
select 'PR' state_code, 'SANTA MARIA DO OESTE' city_code, '4123857' ibge_code from dual union
select 'PR' state_code, 'SANTA MARIANA' city_code, '4123907' ibge_code from dual union
select 'PR' state_code, 'SANTA MONICA' city_code, '4123956' ibge_code from dual union
select 'PR' state_code, 'SANTA TEREZA DO OESTE' city_code, '4124020' ibge_code from dual union
select 'PR' state_code, 'SANTA TEREZINHA DE ITAIPU' city_code, '4124053' ibge_code from dual union
select 'PR' state_code, 'SANTANA DO ITARARE' city_code, '4124004' ibge_code from dual union
select 'PR' state_code, 'SANTO ANTONIO DA PLATINA' city_code, '4124103' ibge_code from dual union
select 'PR' state_code, 'SANTO ANTONIO DO CAIUA' city_code, '4124202' ibge_code from dual union
select 'PR' state_code, 'SANTO ANTONIO DO PARAISO' city_code, '4124301' ibge_code from dual union
select 'PR' state_code, 'SANTO ANTONIO DO SUDOESTE' city_code, '4124400' ibge_code from dual union
select 'PR' state_code, 'SANTO INACIO' city_code, '4124509' ibge_code from dual union
select 'PR' state_code, 'SAO CARLOS DO IVAI' city_code, '4124608' ibge_code from dual union
select 'PR' state_code, 'SAO JERONIMO DA SERRA' city_code, '4124707' ibge_code from dual union
select 'PR' state_code, 'SAO JOAO' city_code, '4124806' ibge_code from dual union
select 'PR' state_code, 'SAO JOAO DO CAIUA' city_code, '4124905' ibge_code from dual union
select 'PR' state_code, 'SAO JOAO DO IVAI' city_code, '4125001' ibge_code from dual union
select 'PR' state_code, 'SAO JOAO DO TRIUNFO' city_code, '4125100' ibge_code from dual union
select 'PR' state_code, 'SAO JORGE DO IVAI' city_code, '4125308' ibge_code from dual union
select 'PR' state_code, 'SAO JORGE DO PATROCINIO' city_code, '4125357' ibge_code from dual union
select 'PR' state_code, 'SAO JORGE D''OESTE' city_code, '4125209' ibge_code from dual union
select 'PR' state_code, 'SAO JOSE DA BOA VISTA' city_code, '4125407' ibge_code from dual union
select 'PR' state_code, 'SAO JOSE DAS PALMEIRAS' city_code, '4125456' ibge_code from dual union
select 'PR' state_code, 'SAO JOSE DOS PINHAIS' city_code, '4125506' ibge_code from dual union
select 'PR' state_code, 'SAO MANOEL DO PARANA' city_code, '4125555' ibge_code from dual union
select 'PR' state_code, 'SAO MATEUS DO SUL' city_code, '4125605' ibge_code from dual union
select 'PR' state_code, 'SAO MIGUEL DO IGUACU' city_code, '4125704' ibge_code from dual union
select 'PR' state_code, 'SAO PEDRO DO IGUACU' city_code, '4125753' ibge_code from dual union
select 'PR' state_code, 'SAO PEDRO DO IVAI' city_code, '4125803' ibge_code from dual union
select 'PR' state_code, 'SAO PEDRO DO PARANA' city_code, '4125902' ibge_code from dual union
select 'PR' state_code, 'SAO SEBASTIAO DA AMOREIRA' city_code, '4126009' ibge_code from dual union
select 'PR' state_code, 'SAO TOME' city_code, '4126108' ibge_code from dual union
select 'PR' state_code, 'SAPOPEMA' city_code, '4126207' ibge_code from dual union
select 'PR' state_code, 'SARANDI' city_code, '4126256' ibge_code from dual union
select 'PR' state_code, 'SAUDADE DO IGUACU' city_code, '4126272' ibge_code from dual union
select 'PR' state_code, 'SENGES' city_code, '4126306' ibge_code from dual union
select 'PR' state_code, 'SERRANOPOLIS DO IGUACU' city_code, '4126355' ibge_code from dual union
select 'PR' state_code, 'SERTANEJA' city_code, '4126405' ibge_code from dual union
select 'PR' state_code, 'SERTANOPOLIS' city_code, '4126504' ibge_code from dual union
select 'PR' state_code, 'SIQUEIRA CAMPOS' city_code, '4126603' ibge_code from dual union
select 'PR' state_code, 'SULINA' city_code, '4126652' ibge_code from dual union
select 'PR' state_code, 'TAMARANA' city_code, '4126678' ibge_code from dual union
select 'PR' state_code, 'TAMBOARA' city_code, '4126702' ibge_code from dual union
select 'PR' state_code, 'TAPEJARA' city_code, '4126801' ibge_code from dual union
select 'PR' state_code, 'TAPIRA' city_code, '4126900' ibge_code from dual union
select 'PR' state_code, 'TEIXEIRA SOARES' city_code, '4127007' ibge_code from dual union
select 'PR' state_code, 'TELEMACO BORBA' city_code, '4127106' ibge_code from dual union
select 'PR' state_code, 'TERRA BOA' city_code, '4127205' ibge_code from dual union
select 'PR' state_code, 'TERRA RICA' city_code, '4127304' ibge_code from dual union
select 'PR' state_code, 'TERRA ROXA' city_code, '4127403' ibge_code from dual union
select 'PR' state_code, 'TIBAGI' city_code, '4127502' ibge_code from dual union
select 'PR' state_code, 'TIJUCAS DO SUL' city_code, '4127601' ibge_code from dual union
select 'PR' state_code, 'TOLEDO' city_code, '4127700' ibge_code from dual union
select 'PR' state_code, 'TOMAZINA' city_code, '4127809' ibge_code from dual union
select 'PR' state_code, 'TRES BARRAS DO PARANA' city_code, '4127858' ibge_code from dual union
select 'PR' state_code, 'TUNAS DO PARANA' city_code, '4127882' ibge_code from dual union
select 'PR' state_code, 'TUNEIRAS DO OESTE' city_code, '4127908' ibge_code from dual union
select 'PR' state_code, 'TUPASSI' city_code, '4127957' ibge_code from dual union
select 'PR' state_code, 'TURVO' city_code, '4127965' ibge_code from dual union
select 'PR' state_code, 'UBIRATA' city_code, '4128005' ibge_code from dual union
select 'PR' state_code, 'UMUARAMA' city_code, '4128104' ibge_code from dual union
select 'PR' state_code, 'UNIAO DA VITORIA' city_code, '4128203' ibge_code from dual union
select 'PR' state_code, 'UNIFLOR' city_code, '4128302' ibge_code from dual union
select 'PR' state_code, 'URAI' city_code, '4128401' ibge_code from dual union
select 'PR' state_code, 'VENTANIA' city_code, '4128534' ibge_code from dual union
select 'PR' state_code, 'VERA CRUZ DO OESTE' city_code, '4128559' ibge_code from dual union
select 'PR' state_code, 'VERE' city_code, '4128609' ibge_code from dual union
select 'PR' state_code, 'VIRMOND' city_code, '4128658' ibge_code from dual union
select 'PR' state_code, 'VITORINO' city_code, '4128708' ibge_code from dual union
select 'PR' state_code, 'WENCESLAU BRAZ' city_code, '4128500' ibge_code from dual union
select 'PR' state_code, 'XAMBRE' city_code, '4128807' ibge_code from dual union
select 'SC' state_code, 'ABDON BATISTA' city_code, '4200051' ibge_code from dual union
select 'SC' state_code, 'ABELARDO LUZ' city_code, '4200101' ibge_code from dual union
select 'SC' state_code, 'AGROLANDIA' city_code, '4200200' ibge_code from dual union
select 'SC' state_code, 'AGRONOMICA' city_code, '4200309' ibge_code from dual union
select 'SC' state_code, 'AGUA DOCE' city_code, '4200408' ibge_code from dual union
select 'SC' state_code, 'AGUAS DE CHAPECO' city_code, '4200507' ibge_code from dual union
select 'SC' state_code, 'AGUAS FRIAS' city_code, '4200556' ibge_code from dual union
select 'SC' state_code, 'AGUAS MORNAS' city_code, '4200606' ibge_code from dual union
select 'SC' state_code, 'ALFREDO WAGNER' city_code, '4200705' ibge_code from dual union
select 'SC' state_code, 'ALTO BELA VISTA' city_code, '4200754' ibge_code from dual union
select 'SC' state_code, 'ANCHIETA' city_code, '4200804' ibge_code from dual union
select 'SC' state_code, 'ANGELINA' city_code, '4200903' ibge_code from dual union
select 'SC' state_code, 'ANITA GARIBALDI' city_code, '4201000' ibge_code from dual union
select 'SC' state_code, 'ANITAPOLIS' city_code, '4201109' ibge_code from dual union
select 'SC' state_code, 'ANTONIO CARLOS' city_code, '4201208' ibge_code from dual union
select 'SC' state_code, 'APIUNA' city_code, '4201257' ibge_code from dual union
select 'SC' state_code, 'ARABUTA' city_code, '4201273' ibge_code from dual union
select 'SC' state_code, 'ARAQUARI' city_code, '4201307' ibge_code from dual union
select 'SC' state_code, 'ARARANGUA' city_code, '4201406' ibge_code from dual union
select 'SC' state_code, 'ARMAZEM' city_code, '4201505' ibge_code from dual union
select 'SC' state_code, 'ARROIO TRINTA' city_code, '4201604' ibge_code from dual union
select 'SC' state_code, 'ARVOREDO' city_code, '4201653' ibge_code from dual union
select 'SC' state_code, 'ASCURRA' city_code, '4201703' ibge_code from dual union
select 'SC' state_code, 'ATALANTA' city_code, '4201802' ibge_code from dual union
select 'SC' state_code, 'AURORA' city_code, '4201901' ibge_code from dual union
select 'SC' state_code, 'BALNEARIO ARROIO DO SILVA' city_code, '4201950' ibge_code from dual union
select 'SC' state_code, 'BALNEARIO BARRA DO SUL' city_code, '4202057' ibge_code from dual union
select 'SC' state_code, 'BALNEARIO CAMBORIU' city_code, '4202008' ibge_code from dual union
select 'SC' state_code, 'BALNEARIO GAIVOTA' city_code, '4202073' ibge_code from dual union
select 'SC' state_code, 'BALNEARIO PICARRAS' city_code, '4212809' ibge_code from dual union
select 'SC' state_code, 'BALNEARIO RINCAO' city_code, '4220000' ibge_code from dual union
select 'SC' state_code, 'BANDEIRANTE' city_code, '4202081' ibge_code from dual union
select 'SC' state_code, 'BARRA BONITA' city_code, '4202099' ibge_code from dual union
select 'SC' state_code, 'BARRA VELHA' city_code, '4202107' ibge_code from dual union
select 'SC' state_code, 'BELA VISTA DO TOLDO' city_code, '4202131' ibge_code from dual union
select 'SC' state_code, 'BELMONTE' city_code, '4202156' ibge_code from dual union
select 'SC' state_code, 'BENEDITO NOVO' city_code, '4202206' ibge_code from dual union
select 'SC' state_code, 'BIGUACU' city_code, '4202305' ibge_code from dual union
select 'SC' state_code, 'BLUMENAU' city_code, '4202404' ibge_code from dual union
select 'SC' state_code, 'BOCAINA DO SUL' city_code, '4202438' ibge_code from dual union
select 'SC' state_code, 'BOM JARDIM DA SERRA' city_code, '4202503' ibge_code from dual union
select 'SC' state_code, 'BOM JESUS' city_code, '4202537' ibge_code from dual union
select 'SC' state_code, 'BOM JESUS DO OESTE' city_code, '4202578' ibge_code from dual union
select 'SC' state_code, 'BOM RETIRO' city_code, '4202602' ibge_code from dual union
select 'SC' state_code, 'BOMBINHAS' city_code, '4202453' ibge_code from dual union
select 'SC' state_code, 'BOTUVERA' city_code, '4202701' ibge_code from dual union
select 'SC' state_code, 'BRACO DO NORTE' city_code, '4202800' ibge_code from dual union
select 'SC' state_code, 'BRACO DO TROMBUDO' city_code, '4202859' ibge_code from dual union
select 'SC' state_code, 'BRUNOPOLIS' city_code, '4202875' ibge_code from dual union
select 'SC' state_code, 'BRUSQUE' city_code, '4202909' ibge_code from dual union
select 'SC' state_code, 'CACADOR' city_code, '4203006' ibge_code from dual union
select 'SC' state_code, 'CAIBI' city_code, '4203105' ibge_code from dual union
select 'SC' state_code, 'CALMON' city_code, '4203154' ibge_code from dual union
select 'SC' state_code, 'CAMBORIU' city_code, '4203204' ibge_code from dual union
select 'SC' state_code, 'CAMPO ALEGRE' city_code, '4203303' ibge_code from dual union
select 'SC' state_code, 'CAMPO BELO DO SUL' city_code, '4203402' ibge_code from dual union
select 'SC' state_code, 'CAMPO ERE' city_code, '4203501' ibge_code from dual union
select 'SC' state_code, 'CAMPOS NOVOS' city_code, '4203600' ibge_code from dual union
select 'SC' state_code, 'CANELINHA' city_code, '4203709' ibge_code from dual union
select 'SC' state_code, 'CANOINHAS' city_code, '4203808' ibge_code from dual union
select 'SC' state_code, 'CAPAO ALTO' city_code, '4203253' ibge_code from dual union
select 'SC' state_code, 'CAPINZAL' city_code, '4203907' ibge_code from dual union
select 'SC' state_code, 'CAPIVARI DE BAIXO' city_code, '4203956' ibge_code from dual union
select 'SC' state_code, 'CATANDUVAS' city_code, '4204004' ibge_code from dual union
select 'SC' state_code, 'CAXAMBU DO SUL' city_code, '4204103' ibge_code from dual union
select 'SC' state_code, 'CELSO RAMOS' city_code, '4204152' ibge_code from dual union
select 'SC' state_code, 'CERRO NEGRO' city_code, '4204178' ibge_code from dual union
select 'SC' state_code, 'CHAPADAO DO LAGEADO' city_code, '4204194' ibge_code from dual union
select 'SC' state_code, 'CHAPECO' city_code, '4204202' ibge_code from dual union
select 'SC' state_code, 'COCAL DO SUL' city_code, '4204251' ibge_code from dual union
select 'SC' state_code, 'CONCORDIA' city_code, '4204301' ibge_code from dual union
select 'SC' state_code, 'CORDILHEIRA ALTA' city_code, '4204350' ibge_code from dual union
select 'SC' state_code, 'CORONEL FREITAS' city_code, '4204400' ibge_code from dual union
select 'SC' state_code, 'CORONEL MARTINS' city_code, '4204459' ibge_code from dual union
select 'SC' state_code, 'CORREIA PINTO' city_code, '4204558' ibge_code from dual union
select 'SC' state_code, 'CORUPA' city_code, '4204509' ibge_code from dual union
select 'SC' state_code, 'CRICIUMA' city_code, '4204608' ibge_code from dual union
select 'SC' state_code, 'CUNHA PORA' city_code, '4204707' ibge_code from dual union
select 'SC' state_code, 'CUNHATAI' city_code, '4204756' ibge_code from dual union
select 'SC' state_code, 'CURITIBANOS' city_code, '4204806' ibge_code from dual union
select 'SC' state_code, 'DESCANSO' city_code, '4204905' ibge_code from dual union
select 'SC' state_code, 'DIONISIO CERQUEIRA' city_code, '4205001' ibge_code from dual union
select 'SC' state_code, 'DONA EMMA' city_code, '4205100' ibge_code from dual union
select 'SC' state_code, 'DOUTOR PEDRINHO' city_code, '4205159' ibge_code from dual union
select 'SC' state_code, 'ENTRE RIOS' city_code, '4205175' ibge_code from dual union
select 'SC' state_code, 'ERMO' city_code, '4205191' ibge_code from dual union
select 'SC' state_code, 'ERVAL VELHO' city_code, '4205209' ibge_code from dual union
select 'SC' state_code, 'FAXINAL DOS GUEDES' city_code, '4205308' ibge_code from dual union
select 'SC' state_code, 'FLOR DO SERTAO' city_code, '4205357' ibge_code from dual union
select 'SC' state_code, 'FLORIANOPOLIS' city_code, '4205407' ibge_code from dual union
select 'SC' state_code, 'FORMOSA DO SUL' city_code, '4205431' ibge_code from dual union
select 'SC' state_code, 'FORQUILHINHA' city_code, '4205456' ibge_code from dual union
select 'SC' state_code, 'FRAIBURGO' city_code, '4205506' ibge_code from dual union
select 'SC' state_code, 'FREI ROGERIO' city_code, '4205555' ibge_code from dual union
select 'SC' state_code, 'GALVAO' city_code, '4205605' ibge_code from dual union
select 'SC' state_code, 'GAROPABA' city_code, '4205704' ibge_code from dual union
select 'SC' state_code, 'GARUVA' city_code, '4205803' ibge_code from dual union
select 'SC' state_code, 'GASPAR' city_code, '4205902' ibge_code from dual union
select 'SC' state_code, 'GOVERNADOR CELSO RAMOS' city_code, '4206009' ibge_code from dual union
select 'SC' state_code, 'GRAO PARA' city_code, '4206108' ibge_code from dual union
select 'SC' state_code, 'GRAVATAL' city_code, '4206207' ibge_code from dual union
select 'SC' state_code, 'GUABIRUBA' city_code, '4206306' ibge_code from dual union
select 'SC' state_code, 'GUARACIABA' city_code, '4206405' ibge_code from dual union
select 'SC' state_code, 'GUARAMIRIM' city_code, '4206504' ibge_code from dual union
select 'SC' state_code, 'GUARUJA DO SUL' city_code, '4206603' ibge_code from dual union
select 'SC' state_code, 'GUATAMBU' city_code, '4206652' ibge_code from dual union
select 'SC' state_code, 'HERVAL D''OESTE' city_code, '4206702' ibge_code from dual union
select 'SC' state_code, 'IBIAM' city_code, '4206751' ibge_code from dual union
select 'SC' state_code, 'IBICARE' city_code, '4206801' ibge_code from dual union
select 'SC' state_code, 'IBIRAMA' city_code, '4206900' ibge_code from dual union
select 'SC' state_code, 'ICARA' city_code, '4207007' ibge_code from dual union
select 'SC' state_code, 'ILHOTA' city_code, '4207106' ibge_code from dual union
select 'SC' state_code, 'IMARUI' city_code, '4207205' ibge_code from dual union
select 'SC' state_code, 'IMBITUBA' city_code, '4207304' ibge_code from dual union
select 'SC' state_code, 'IMBUIA' city_code, '4207403' ibge_code from dual union
select 'SC' state_code, 'INDAIAL' city_code, '4207502' ibge_code from dual union
select 'SC' state_code, 'IOMERE' city_code, '4207577' ibge_code from dual union
select 'SC' state_code, 'IPIRA' city_code, '4207601' ibge_code from dual union
select 'SC' state_code, 'IPORA DO OESTE' city_code, '4207650' ibge_code from dual union
select 'SC' state_code, 'IPUACU' city_code, '4207684' ibge_code from dual union
select 'SC' state_code, 'IPUMIRIM' city_code, '4207700' ibge_code from dual union
select 'SC' state_code, 'IRACEMINHA' city_code, '4207759' ibge_code from dual union
select 'SC' state_code, 'IRANI' city_code, '4207809' ibge_code from dual union
select 'SC' state_code, 'IRATI' city_code, '4207858' ibge_code from dual union
select 'SC' state_code, 'IRINEOPOLIS' city_code, '4207908' ibge_code from dual union
select 'SC' state_code, 'ITA' city_code, '4208005' ibge_code from dual union
select 'SC' state_code, 'ITAIOPOLIS' city_code, '4208104' ibge_code from dual union
select 'SC' state_code, 'ITAJAI' city_code, '4208203' ibge_code from dual union
select 'SC' state_code, 'ITAPEMA' city_code, '4208302' ibge_code from dual union
select 'SC' state_code, 'ITAPIRANGA' city_code, '4208401' ibge_code from dual union
select 'SC' state_code, 'ITAPOA' city_code, '4208450' ibge_code from dual union
select 'SC' state_code, 'ITUPORANGA' city_code, '4208500' ibge_code from dual union
select 'SC' state_code, 'JABORA' city_code, '4208609' ibge_code from dual union
select 'SC' state_code, 'JACINTO MACHADO' city_code, '4208708' ibge_code from dual union
select 'SC' state_code, 'JAGUARUNA' city_code, '4208807' ibge_code from dual union
select 'SC' state_code, 'JARAGUA DO SUL' city_code, '4208906' ibge_code from dual union
select 'SC' state_code, 'JARDINOPOLIS' city_code, '4208955' ibge_code from dual union
select 'SC' state_code, 'JOACABA' city_code, '4209003' ibge_code from dual union
select 'SC' state_code, 'JOINVILLE' city_code, '4209102' ibge_code from dual union
select 'SC' state_code, 'JOSE BOITEUX' city_code, '4209151' ibge_code from dual union
select 'SC' state_code, 'JUPIA' city_code, '4209177' ibge_code from dual union
select 'SC' state_code, 'LACERDOPOLIS' city_code, '4209201' ibge_code from dual union
select 'SC' state_code, 'LAGES' city_code, '4209300' ibge_code from dual union
select 'SC' state_code, 'LAGUNA' city_code, '4209409' ibge_code from dual union
select 'SC' state_code, 'LAJEADO GRANDE' city_code, '4209458' ibge_code from dual union
select 'SC' state_code, 'LAURENTINO' city_code, '4209508' ibge_code from dual union
select 'SC' state_code, 'LAURO MÜLLER' city_code, '4209607' ibge_code from dual union
select 'SC' state_code, 'LEBON REGIS' city_code, '4209706' ibge_code from dual union
select 'SC' state_code, 'LEOBERTO LEAL' city_code, '4209805' ibge_code from dual union
select 'SC' state_code, 'LINDOIA DO SUL' city_code, '4209854' ibge_code from dual union
select 'SC' state_code, 'LONTRAS' city_code, '4209904' ibge_code from dual union
select 'SC' state_code, 'LUIZ ALVES' city_code, '4210001' ibge_code from dual union
select 'SC' state_code, 'LUZERNA' city_code, '4210035' ibge_code from dual union
select 'SC' state_code, 'MACIEIRA' city_code, '4210050' ibge_code from dual union
select 'SC' state_code, 'MAFRA' city_code, '4210100' ibge_code from dual union
select 'SC' state_code, 'MAJOR GERCINO' city_code, '4210209' ibge_code from dual union
select 'SC' state_code, 'MAJOR VIEIRA' city_code, '4210308' ibge_code from dual union
select 'SC' state_code, 'MARACAJA' city_code, '4210407' ibge_code from dual union
select 'SC' state_code, 'MARAVILHA' city_code, '4210506' ibge_code from dual union
select 'SC' state_code, 'MAREMA' city_code, '4210555' ibge_code from dual union
select 'SC' state_code, 'MASSARANDUBA' city_code, '4210605' ibge_code from dual union
select 'SC' state_code, 'MATOS COSTA' city_code, '4210704' ibge_code from dual union
select 'SC' state_code, 'MELEIRO' city_code, '4210803' ibge_code from dual union
select 'SC' state_code, 'MIRIM DOCE' city_code, '4210852' ibge_code from dual union
select 'SC' state_code, 'MODELO' city_code, '4210902' ibge_code from dual union
select 'SC' state_code, 'MONDAI' city_code, '4211009' ibge_code from dual union
select 'SC' state_code, 'MONTE CARLO' city_code, '4211058' ibge_code from dual union
select 'SC' state_code, 'MONTE CASTELO' city_code, '4211108' ibge_code from dual union
select 'SC' state_code, 'MORRO DA FUMACA' city_code, '4211207' ibge_code from dual union
select 'SC' state_code, 'MORRO GRANDE' city_code, '4211256' ibge_code from dual union
select 'SC' state_code, 'NAVEGANTES' city_code, '4211306' ibge_code from dual union
select 'SC' state_code, 'NOVA ERECHIM' city_code, '4211405' ibge_code from dual union
select 'SC' state_code, 'NOVA ITABERABA' city_code, '4211454' ibge_code from dual union
select 'SC' state_code, 'NOVA TRENTO' city_code, '4211504' ibge_code from dual union
select 'SC' state_code, 'NOVA VENEZA' city_code, '4211603' ibge_code from dual union
select 'SC' state_code, 'NOVO HORIZONTE' city_code, '4211652' ibge_code from dual union
select 'SC' state_code, 'ORLEANS' city_code, '4211702' ibge_code from dual union
select 'SC' state_code, 'OTACILIO COSTA' city_code, '4211751' ibge_code from dual union
select 'SC' state_code, 'OURO' city_code, '4211801' ibge_code from dual union
select 'SC' state_code, 'OURO VERDE' city_code, '4211850' ibge_code from dual union
select 'SC' state_code, 'PAIAL' city_code, '4211876' ibge_code from dual union
select 'SC' state_code, 'PAINEL' city_code, '4211892' ibge_code from dual union
select 'SC' state_code, 'PALHOCA' city_code, '4211900' ibge_code from dual union
select 'SC' state_code, 'PALMA SOLA' city_code, '4212007' ibge_code from dual union
select 'SC' state_code, 'PALMEIRA' city_code, '4212056' ibge_code from dual union
select 'SC' state_code, 'PALMITOS' city_code, '4212106' ibge_code from dual union
select 'SC' state_code, 'PAPANDUVA' city_code, '4212205' ibge_code from dual union
select 'SC' state_code, 'PARAISO' city_code, '4212239' ibge_code from dual union
select 'SC' state_code, 'PASSO DE TORRES' city_code, '4212254' ibge_code from dual union
select 'SC' state_code, 'PASSOS MAIA' city_code, '4212270' ibge_code from dual union
select 'SC' state_code, 'PAULO LOPES' city_code, '4212304' ibge_code from dual union
select 'SC' state_code, 'PEDRAS GRANDES' city_code, '4212403' ibge_code from dual union
select 'SC' state_code, 'PENHA' city_code, '4212502' ibge_code from dual union
select 'SC' state_code, 'PERITIBA' city_code, '4212601' ibge_code from dual union
select 'SC' state_code, 'PESCARIA BRAVA' city_code, '4212650' ibge_code from dual union
select 'SC' state_code, 'PETROLANDIA' city_code, '4212700' ibge_code from dual union
select 'SC' state_code, 'PINHALZINHO' city_code, '4212908' ibge_code from dual union
select 'SC' state_code, 'PINHEIRO PRETO' city_code, '4213005' ibge_code from dual union
select 'SC' state_code, 'PIRATUBA' city_code, '4213104' ibge_code from dual union
select 'SC' state_code, 'PLANALTO ALEGRE' city_code, '4213153' ibge_code from dual union
select 'SC' state_code, 'POMERODE' city_code, '4213203' ibge_code from dual union
select 'SC' state_code, 'PONTE ALTA' city_code, '4213302' ibge_code from dual union
select 'SC' state_code, 'PONTE ALTA DO NORTE' city_code, '4213351' ibge_code from dual union
select 'SC' state_code, 'PONTE SERRADA' city_code, '4213401' ibge_code from dual union
select 'SC' state_code, 'PORTO BELO' city_code, '4213500' ibge_code from dual union
select 'SC' state_code, 'PORTO UNIAO' city_code, '4213609' ibge_code from dual union
select 'SC' state_code, 'POUSO REDONDO' city_code, '4213708' ibge_code from dual union
select 'SC' state_code, 'PRAIA GRANDE' city_code, '4213807' ibge_code from dual union
select 'SC' state_code, 'PRESIDENTE CASTELLO BRANCO' city_code, '4213906' ibge_code from dual union
select 'SC' state_code, 'PRESIDENTE GETULIO' city_code, '4214003' ibge_code from dual union
select 'SC' state_code, 'PRESIDENTE NEREU' city_code, '4214102' ibge_code from dual union
select 'SC' state_code, 'PRINCESA' city_code, '4214151' ibge_code from dual union
select 'SC' state_code, 'QUILOMBO' city_code, '4214201' ibge_code from dual union
select 'SC' state_code, 'RANCHO QUEIMADO' city_code, '4214300' ibge_code from dual union
select 'SC' state_code, 'RIO DAS ANTAS' city_code, '4214409' ibge_code from dual union
select 'SC' state_code, 'RIO DO CAMPO' city_code, '4214508' ibge_code from dual union
select 'SC' state_code, 'RIO DO OESTE' city_code, '4214607' ibge_code from dual union
select 'SC' state_code, 'RIO DO SUL' city_code, '4214805' ibge_code from dual union
select 'SC' state_code, 'RIO DOS CEDROS' city_code, '4214706' ibge_code from dual union
select 'SC' state_code, 'RIO FORTUNA' city_code, '4214904' ibge_code from dual union
select 'SC' state_code, 'RIO NEGRINHO' city_code, '4215000' ibge_code from dual union
select 'SC' state_code, 'RIO RUFINO' city_code, '4215059' ibge_code from dual union
select 'SC' state_code, 'RIQUEZA' city_code, '4215075' ibge_code from dual union
select 'SC' state_code, 'RODEIO' city_code, '4215109' ibge_code from dual union
select 'SC' state_code, 'ROMELANDIA' city_code, '4215208' ibge_code from dual union
select 'SC' state_code, 'SALETE' city_code, '4215307' ibge_code from dual union
select 'SC' state_code, 'SALTINHO' city_code, '4215356' ibge_code from dual union
select 'SC' state_code, 'SALTO VELOSO' city_code, '4215406' ibge_code from dual union
select 'SC' state_code, 'SANGAO' city_code, '4215455' ibge_code from dual union
select 'SC' state_code, 'SANTA CECILIA' city_code, '4215505' ibge_code from dual union
select 'SC' state_code, 'SANTA HELENA' city_code, '4215554' ibge_code from dual union
select 'SC' state_code, 'SANTA ROSA DE LIMA' city_code, '4215604' ibge_code from dual union
select 'SC' state_code, 'SANTA ROSA DO SUL' city_code, '4215653' ibge_code from dual union
select 'SC' state_code, 'SANTA TEREZINHA' city_code, '4215679' ibge_code from dual union
select 'SC' state_code, 'SANTA TEREZINHA DO PROGRESSO' city_code, '4215687' ibge_code from dual union
select 'SC' state_code, 'SANTIAGO DO SUL' city_code, '4215695' ibge_code from dual union
select 'SC' state_code, 'SANTO AMARO DA IMPERATRIZ' city_code, '4215703' ibge_code from dual union
select 'SC' state_code, 'SAO BENTO DO SUL' city_code, '4215802' ibge_code from dual union
select 'SC' state_code, 'SAO BERNARDINO' city_code, '4215752' ibge_code from dual union
select 'SC' state_code, 'SAO BONIFACIO' city_code, '4215901' ibge_code from dual union
select 'SC' state_code, 'SAO CARLOS' city_code, '4216008' ibge_code from dual union
select 'SC' state_code, 'SAO CRISTOVAO DO SUL' city_code, '4216057' ibge_code from dual union
select 'SC' state_code, 'SAO DOMINGOS' city_code, '4216107' ibge_code from dual union
select 'SC' state_code, 'SAO FRANCISCO DO SUL' city_code, '4216206' ibge_code from dual union
select 'SC' state_code, 'SAO JOAO BATISTA' city_code, '4216305' ibge_code from dual union
select 'SC' state_code, 'SAO JOAO DO ITAPERIU' city_code, '4216354' ibge_code from dual union
select 'SC' state_code, 'SAO JOAO DO OESTE' city_code, '4216255' ibge_code from dual union
select 'SC' state_code, 'SAO JOAO DO SUL' city_code, '4216404' ibge_code from dual union
select 'SC' state_code, 'SAO JOAQUIM' city_code, '4216503' ibge_code from dual union
select 'SC' state_code, 'SAO JOSE' city_code, '4216602' ibge_code from dual union
select 'SC' state_code, 'SAO JOSE DO CEDRO' city_code, '4216701' ibge_code from dual union
select 'SC' state_code, 'SAO JOSE DO CERRITO' city_code, '4216800' ibge_code from dual union
select 'SC' state_code, 'SAO LOURENCO DO OESTE' city_code, '4216909' ibge_code from dual union
select 'SC' state_code, 'SAO LUDGERO' city_code, '4217006' ibge_code from dual union
select 'SC' state_code, 'SAO MARTINHO' city_code, '4217105' ibge_code from dual union
select 'SC' state_code, 'SAO MIGUEL DA BOA VISTA' city_code, '4217154' ibge_code from dual union
select 'SC' state_code, 'SAO MIGUEL DO OESTE' city_code, '4217204' ibge_code from dual union
select 'SC' state_code, 'SAO PEDRO DE ALCANTARA' city_code, '4217253' ibge_code from dual union
select 'SC' state_code, 'SAUDADES' city_code, '4217303' ibge_code from dual union
select 'SC' state_code, 'SCHROEDER' city_code, '4217402' ibge_code from dual union
select 'SC' state_code, 'SEARA' city_code, '4217501' ibge_code from dual union
select 'SC' state_code, 'SERRA ALTA' city_code, '4217550' ibge_code from dual union
select 'SC' state_code, 'SIDEROPOLIS' city_code, '4217600' ibge_code from dual union
select 'SC' state_code, 'SOMBRIO' city_code, '4217709' ibge_code from dual union
select 'SC' state_code, 'SUL BRASIL' city_code, '4217758' ibge_code from dual union
select 'SC' state_code, 'TAIO' city_code, '4217808' ibge_code from dual union
select 'SC' state_code, 'TANGARA' city_code, '4217907' ibge_code from dual union
select 'SC' state_code, 'TIGRINHOS' city_code, '4217956' ibge_code from dual union
select 'SC' state_code, 'TIJUCAS' city_code, '4218004' ibge_code from dual union
select 'SC' state_code, 'TIMBE DO SUL' city_code, '4218103' ibge_code from dual union
select 'SC' state_code, 'TIMBO' city_code, '4218202' ibge_code from dual union
select 'SC' state_code, 'TIMBO GRANDE' city_code, '4218251' ibge_code from dual union
select 'SC' state_code, 'TRES BARRAS' city_code, '4218301' ibge_code from dual union
select 'SC' state_code, 'TREVISO' city_code, '4218350' ibge_code from dual union
select 'SC' state_code, 'TREZE DE MAIO' city_code, '4218400' ibge_code from dual union
select 'SC' state_code, 'TREZE TILIAS' city_code, '4218509' ibge_code from dual union
select 'SC' state_code, 'TROMBUDO CENTRAL' city_code, '4218608' ibge_code from dual union
select 'SC' state_code, 'TUBARAO' city_code, '4218707' ibge_code from dual union
select 'SC' state_code, 'TUNAPOLIS' city_code, '4218756' ibge_code from dual union
select 'SC' state_code, 'TURVO' city_code, '4218806' ibge_code from dual union
select 'SC' state_code, 'UNIAO DO OESTE' city_code, '4218855' ibge_code from dual union
select 'SC' state_code, 'URUBICI' city_code, '4218905' ibge_code from dual union
select 'SC' state_code, 'URUPEMA' city_code, '4218954' ibge_code from dual union
select 'SC' state_code, 'URUSSANGA' city_code, '4219002' ibge_code from dual union
select 'SC' state_code, 'VARGEAO' city_code, '4219101' ibge_code from dual union
select 'SC' state_code, 'VARGEM' city_code, '4219150' ibge_code from dual union
select 'SC' state_code, 'VARGEM BONITA' city_code, '4219176' ibge_code from dual union
select 'SC' state_code, 'VIDAL RAMOS' city_code, '4219200' ibge_code from dual union
select 'SC' state_code, 'VIDEIRA' city_code, '4219309' ibge_code from dual union
select 'SC' state_code, 'VITOR MEIRELES' city_code, '4219358' ibge_code from dual union
select 'SC' state_code, 'WITMARSUM' city_code, '4219408' ibge_code from dual union
select 'SC' state_code, 'XANXERE' city_code, '4219507' ibge_code from dual union
select 'SC' state_code, 'XAVANTINA' city_code, '4219606' ibge_code from dual union
select 'SC' state_code, 'XAXIM' city_code, '4219705' ibge_code from dual union
select 'SC' state_code, 'ZORTEA' city_code, '4219853' ibge_code from dual union
select 'RS' state_code, 'ACEGUA' city_code, '4300034' ibge_code from dual union
select 'RS' state_code, 'AGUA SANTA' city_code, '4300059' ibge_code from dual union
select 'RS' state_code, 'AGUDO' city_code, '4300109' ibge_code from dual union
select 'RS' state_code, 'AJURICABA' city_code, '4300208' ibge_code from dual union
select 'RS' state_code, 'ALECRIM' city_code, '4300307' ibge_code from dual union
select 'RS' state_code, 'ALEGRETE' city_code, '4300406' ibge_code from dual union
select 'RS' state_code, 'ALEGRIA' city_code, '4300455' ibge_code from dual union
select 'RS' state_code, 'ALMIRANTE TAMANDARE DO SUL' city_code, '4300471' ibge_code from dual union
select 'RS' state_code, 'ALPESTRE' city_code, '4300505' ibge_code from dual union
select 'RS' state_code, 'ALTO ALEGRE' city_code, '4300554' ibge_code from dual union
select 'RS' state_code, 'ALTO FELIZ' city_code, '4300570' ibge_code from dual union
select 'RS' state_code, 'ALVORADA' city_code, '4300604' ibge_code from dual union
select 'RS' state_code, 'AMARAL FERRADOR' city_code, '4300638' ibge_code from dual union
select 'RS' state_code, 'AMETISTA DO SUL' city_code, '4300646' ibge_code from dual union
select 'RS' state_code, 'ANDRE DA ROCHA' city_code, '4300661' ibge_code from dual union
select 'RS' state_code, 'ANTA GORDA' city_code, '4300703' ibge_code from dual union
select 'RS' state_code, 'ANTONIO PRADO' city_code, '4300802' ibge_code from dual union
select 'RS' state_code, 'ARAMBARE' city_code, '4300851' ibge_code from dual union
select 'RS' state_code, 'ARARICA' city_code, '4300877' ibge_code from dual union
select 'RS' state_code, 'ARATIBA' city_code, '4300901' ibge_code from dual union
select 'RS' state_code, 'ARROIO DO MEIO' city_code, '4301008' ibge_code from dual union
select 'RS' state_code, 'ARROIO DO PADRE' city_code, '4301073' ibge_code from dual union
select 'RS' state_code, 'ARROIO DO SAL' city_code, '4301057' ibge_code from dual union
select 'RS' state_code, 'ARROIO DO TIGRE' city_code, '4301206' ibge_code from dual union
select 'RS' state_code, 'ARROIO DOS RATOS' city_code, '4301107' ibge_code from dual union
select 'RS' state_code, 'ARROIO GRANDE' city_code, '4301305' ibge_code from dual union
select 'RS' state_code, 'ARVOREZINHA' city_code, '4301404' ibge_code from dual union
select 'RS' state_code, 'AUGUSTO PESTANA' city_code, '4301503' ibge_code from dual union
select 'RS' state_code, 'AUREA' city_code, '4301552' ibge_code from dual union
select 'RS' state_code, 'BAGE' city_code, '4301602' ibge_code from dual union
select 'RS' state_code, 'BALNEARIO PINHAL' city_code, '4301636' ibge_code from dual union
select 'RS' state_code, 'BARAO' city_code, '4301651' ibge_code from dual union
select 'RS' state_code, 'BARAO DE COTEGIPE' city_code, '4301701' ibge_code from dual union
select 'RS' state_code, 'BARAO DO TRIUNFO' city_code, '4301750' ibge_code from dual union
select 'RS' state_code, 'BARRA DO GUARITA' city_code, '4301859' ibge_code from dual union
select 'RS' state_code, 'BARRA DO QUARAI' city_code, '4301875' ibge_code from dual union
select 'RS' state_code, 'BARRA DO RIBEIRO' city_code, '4301909' ibge_code from dual union
select 'RS' state_code, 'BARRA DO RIO AZUL' city_code, '4301925' ibge_code from dual union
select 'RS' state_code, 'BARRA FUNDA' city_code, '4301958' ibge_code from dual union
select 'RS' state_code, 'BARRACAO' city_code, '4301800' ibge_code from dual union
select 'RS' state_code, 'BARROS CASSAL' city_code, '4302006' ibge_code from dual union
select 'RS' state_code, 'BENJAMIN CONSTANT DO SUL' city_code, '4302055' ibge_code from dual union
select 'RS' state_code, 'BENTO GONCALVES' city_code, '4302105' ibge_code from dual union
select 'RS' state_code, 'BOA VISTA DAS MISSÕES' city_code, '4302154' ibge_code from dual union
select 'RS' state_code, 'BOA VISTA DO BURICA' city_code, '4302204' ibge_code from dual union
select 'RS' state_code, 'BOA VISTA DO CADEADO' city_code, '4302220' ibge_code from dual union
select 'RS' state_code, 'BOA VISTA DO INCRA' city_code, '4302238' ibge_code from dual union
select 'RS' state_code, 'BOA VISTA DO SUL' city_code, '4302253' ibge_code from dual union
select 'RS' state_code, 'BOM JESUS' city_code, '4302303' ibge_code from dual union
select 'RS' state_code, 'BOM PRINCIPIO' city_code, '4302352' ibge_code from dual union
select 'RS' state_code, 'BOM PROGRESSO' city_code, '4302378' ibge_code from dual union
select 'RS' state_code, 'BOM RETIRO DO SUL' city_code, '4302402' ibge_code from dual union
select 'RS' state_code, 'BOQUEIRAO DO LEAO' city_code, '4302451' ibge_code from dual union
select 'RS' state_code, 'BOSSOROCA' city_code, '4302501' ibge_code from dual union
select 'RS' state_code, 'BOZANO' city_code, '4302584' ibge_code from dual union
select 'RS' state_code, 'BRAGA' city_code, '4302600' ibge_code from dual union
select 'RS' state_code, 'BROCHIER' city_code, '4302659' ibge_code from dual union
select 'RS' state_code, 'BUTIA' city_code, '4302709' ibge_code from dual union
select 'RS' state_code, 'CACAPAVA DO SUL' city_code, '4302808' ibge_code from dual union
select 'RS' state_code, 'CACEQUI' city_code, '4302907' ibge_code from dual union
select 'RS' state_code, 'CACHOEIRA DO SUL' city_code, '4303004' ibge_code from dual union
select 'RS' state_code, 'CACHOEIRINHA' city_code, '4303103' ibge_code from dual union
select 'RS' state_code, 'CACIQUE DOBLE' city_code, '4303202' ibge_code from dual union
select 'RS' state_code, 'CAIBATE' city_code, '4303301' ibge_code from dual union
select 'RS' state_code, 'CAICARA' city_code, '4303400' ibge_code from dual union
select 'RS' state_code, 'CAMAQUA' city_code, '4303509' ibge_code from dual union
select 'RS' state_code, 'CAMARGO' city_code, '4303558' ibge_code from dual union
select 'RS' state_code, 'CAMBARA DO SUL' city_code, '4303608' ibge_code from dual union
select 'RS' state_code, 'CAMPESTRE DA SERRA' city_code, '4303673' ibge_code from dual union
select 'RS' state_code, 'CAMPINA DAS MISSÕES' city_code, '4303707' ibge_code from dual union
select 'RS' state_code, 'CAMPINAS DO SUL' city_code, '4303806' ibge_code from dual union
select 'RS' state_code, 'CAMPO BOM' city_code, '4303905' ibge_code from dual union
select 'RS' state_code, 'CAMPO NOVO' city_code, '4304002' ibge_code from dual union
select 'RS' state_code, 'CAMPOS BORGES' city_code, '4304101' ibge_code from dual union
select 'RS' state_code, 'CANDELARIA' city_code, '4304200' ibge_code from dual union
select 'RS' state_code, 'CANDIDO GODOI' city_code, '4304309' ibge_code from dual union
select 'RS' state_code, 'CANDIOTA' city_code, '4304358' ibge_code from dual union
select 'RS' state_code, 'CANELA' city_code, '4304408' ibge_code from dual union
select 'RS' state_code, 'CANGUCU' city_code, '4304507' ibge_code from dual union
select 'RS' state_code, 'CANOAS' city_code, '4304606' ibge_code from dual union
select 'RS' state_code, 'CANUDOS DO VALE' city_code, '4304614' ibge_code from dual union
select 'RS' state_code, 'CAPAO BONITO DO SUL' city_code, '4304622' ibge_code from dual union
select 'RS' state_code, 'CAPAO DA CANOA' city_code, '4304630' ibge_code from dual union
select 'RS' state_code, 'CAPAO DO CIPO' city_code, '4304655' ibge_code from dual union
select 'RS' state_code, 'CAPAO DO LEAO' city_code, '4304663' ibge_code from dual union
select 'RS' state_code, 'CAPELA DE SANTANA' city_code, '4304689' ibge_code from dual union
select 'RS' state_code, 'CAPITAO' city_code, '4304697' ibge_code from dual union
select 'RS' state_code, 'CAPIVARI DO SUL' city_code, '4304671' ibge_code from dual union
select 'RS' state_code, 'CARAA' city_code, '4304713' ibge_code from dual union
select 'RS' state_code, 'CARAZINHO' city_code, '4304705' ibge_code from dual union
select 'RS' state_code, 'CARLOS BARBOSA' city_code, '4304804' ibge_code from dual union
select 'RS' state_code, 'CARLOS GOMES' city_code, '4304853' ibge_code from dual union
select 'RS' state_code, 'CASCA' city_code, '4304903' ibge_code from dual union
select 'RS' state_code, 'CASEIROS' city_code, '4304952' ibge_code from dual union
select 'RS' state_code, 'CATUIPE' city_code, '4305009' ibge_code from dual union
select 'RS' state_code, 'CAXIAS DO SUL' city_code, '4305108' ibge_code from dual union
select 'RS' state_code, 'CENTENARIO' city_code, '4305116' ibge_code from dual union
select 'RS' state_code, 'CERRITO' city_code, '4305124' ibge_code from dual union
select 'RS' state_code, 'CERRO BRANCO' city_code, '4305132' ibge_code from dual union
select 'RS' state_code, 'CERRO GRANDE' city_code, '4305157' ibge_code from dual union
select 'RS' state_code, 'CERRO GRANDE DO SUL' city_code, '4305173' ibge_code from dual union
select 'RS' state_code, 'CERRO LARGO' city_code, '4305207' ibge_code from dual union
select 'RS' state_code, 'CHAPADA' city_code, '4305306' ibge_code from dual union
select 'RS' state_code, 'CHARQUEADAS' city_code, '4305355' ibge_code from dual union
select 'RS' state_code, 'CHARRUA' city_code, '4305371' ibge_code from dual union
select 'RS' state_code, 'CHIAPETTA' city_code, '4305405' ibge_code from dual union
select 'RS' state_code, 'CHUI' city_code, '4305439' ibge_code from dual union
select 'RS' state_code, 'CHUVISCA' city_code, '4305447' ibge_code from dual union
select 'RS' state_code, 'CIDREIRA' city_code, '4305454' ibge_code from dual union
select 'RS' state_code, 'CIRIACO' city_code, '4305504' ibge_code from dual union
select 'RS' state_code, 'COLINAS' city_code, '4305587' ibge_code from dual union
select 'RS' state_code, 'COLORADO' city_code, '4305603' ibge_code from dual union
select 'RS' state_code, 'CONDOR' city_code, '4305702' ibge_code from dual union
select 'RS' state_code, 'CONSTANTINA' city_code, '4305801' ibge_code from dual union
select 'RS' state_code, 'COQUEIRO BAIXO' city_code, '4305835' ibge_code from dual union
select 'RS' state_code, 'COQUEIROS DO SUL' city_code, '4305850' ibge_code from dual union
select 'RS' state_code, 'CORONEL BARROS' city_code, '4305871' ibge_code from dual union
select 'RS' state_code, 'CORONEL BICACO' city_code, '4305900' ibge_code from dual union
select 'RS' state_code, 'CORONEL PILAR' city_code, '4305934' ibge_code from dual union
select 'RS' state_code, 'COTIPORA' city_code, '4305959' ibge_code from dual union
select 'RS' state_code, 'COXILHA' city_code, '4305975' ibge_code from dual union
select 'RS' state_code, 'CRISSIUMAL' city_code, '4306007' ibge_code from dual union
select 'RS' state_code, 'CRISTAL' city_code, '4306056' ibge_code from dual union
select 'RS' state_code, 'CRISTAL DO SUL' city_code, '4306072' ibge_code from dual union
select 'RS' state_code, 'CRUZ ALTA' city_code, '4306106' ibge_code from dual union
select 'RS' state_code, 'CRUZALTENSE' city_code, '4306130' ibge_code from dual union
select 'RS' state_code, 'CRUZEIRO DO SUL' city_code, '4306205' ibge_code from dual union
select 'RS' state_code, 'DAVID CANABARRO' city_code, '4306304' ibge_code from dual union
select 'RS' state_code, 'DERRUBADAS' city_code, '4306320' ibge_code from dual union
select 'RS' state_code, 'DEZESSEIS DE NOVEMBRO' city_code, '4306353' ibge_code from dual union
select 'RS' state_code, 'DILERMANDO DE AGUIAR' city_code, '4306379' ibge_code from dual union
select 'RS' state_code, 'DOIS IRMAOS' city_code, '4306403' ibge_code from dual union
select 'RS' state_code, 'DOIS IRMAOS DAS MISSÕES' city_code, '4306429' ibge_code from dual union
select 'RS' state_code, 'DOIS LAJEADOS' city_code, '4306452' ibge_code from dual union
select 'RS' state_code, 'DOM FELICIANO' city_code, '4306502' ibge_code from dual union
select 'RS' state_code, 'DOM PEDRITO' city_code, '4306601' ibge_code from dual union
select 'RS' state_code, 'DOM PEDRO DE ALCANTARA' city_code, '4306551' ibge_code from dual union
select 'RS' state_code, 'DONA FRANCISCA' city_code, '4306700' ibge_code from dual union
select 'RS' state_code, 'DOUTOR MAURICIO CARDOSO' city_code, '4306734' ibge_code from dual union
select 'RS' state_code, 'DOUTOR RICARDO' city_code, '4306759' ibge_code from dual union
select 'RS' state_code, 'ELDORADO DO SUL' city_code, '4306767' ibge_code from dual union
select 'RS' state_code, 'ENCANTADO' city_code, '4306809' ibge_code from dual union
select 'RS' state_code, 'ENCRUZILHADA DO SUL' city_code, '4306908' ibge_code from dual union
select 'RS' state_code, 'ENGENHO VELHO' city_code, '4306924' ibge_code from dual union
select 'RS' state_code, 'ENTRE RIOS DO SUL' city_code, '4306957' ibge_code from dual union
select 'RS' state_code, 'ENTRE-IJUIS' city_code, '4306932' ibge_code from dual union
select 'RS' state_code, 'EREBANGO' city_code, '4306973' ibge_code from dual union
select 'RS' state_code, 'ERECHIM' city_code, '4307005' ibge_code from dual union
select 'RS' state_code, 'ERNESTINA' city_code, '4307054' ibge_code from dual union
select 'RS' state_code, 'ERVAL GRANDE' city_code, '4307203' ibge_code from dual union
select 'RS' state_code, 'ERVAL SECO' city_code, '4307302' ibge_code from dual union
select 'RS' state_code, 'ESMERALDA' city_code, '4307401' ibge_code from dual union
select 'RS' state_code, 'ESPERANCA DO SUL' city_code, '4307450' ibge_code from dual union
select 'RS' state_code, 'ESPUMOSO' city_code, '4307500' ibge_code from dual union
select 'RS' state_code, 'ESTACAO' city_code, '4307559' ibge_code from dual union
select 'RS' state_code, 'ESTANCIA VELHA' city_code, '4307609' ibge_code from dual union
select 'RS' state_code, 'ESTEIO' city_code, '4307708' ibge_code from dual union
select 'RS' state_code, 'ESTRELA' city_code, '4307807' ibge_code from dual union
select 'RS' state_code, 'ESTRELA VELHA' city_code, '4307815' ibge_code from dual union
select 'RS' state_code, 'EUGENIO DE CASTRO' city_code, '4307831' ibge_code from dual union
select 'RS' state_code, 'FAGUNDES VARELA' city_code, '4307864' ibge_code from dual union
select 'RS' state_code, 'FARROUPILHA' city_code, '4307906' ibge_code from dual union
select 'RS' state_code, 'FAXINAL DO SOTURNO' city_code, '4308003' ibge_code from dual union
select 'RS' state_code, 'FAXINALZINHO' city_code, '4308052' ibge_code from dual union
select 'RS' state_code, 'FAZENDA VILANOVA' city_code, '4308078' ibge_code from dual union
select 'RS' state_code, 'FELIZ' city_code, '4308102' ibge_code from dual union
select 'RS' state_code, 'FLORES DA CUNHA' city_code, '4308201' ibge_code from dual union
select 'RS' state_code, 'FLORIANO PEIXOTO' city_code, '4308250' ibge_code from dual union
select 'RS' state_code, 'FONTOURA XAVIER' city_code, '4308300' ibge_code from dual union
select 'RS' state_code, 'FORMIGUEIRO' city_code, '4308409' ibge_code from dual union
select 'RS' state_code, 'FORQUETINHA' city_code, '4308433' ibge_code from dual union
select 'RS' state_code, 'FORTALEZA DOS VALOS' city_code, '4308458' ibge_code from dual union
select 'RS' state_code, 'FREDERICO WESTPHALEN' city_code, '4308508' ibge_code from dual union
select 'RS' state_code, 'GARIBALDI' city_code, '4308607' ibge_code from dual union
select 'RS' state_code, 'GARRUCHOS' city_code, '4308656' ibge_code from dual union
select 'RS' state_code, 'GAURAMA' city_code, '4308706' ibge_code from dual union
select 'RS' state_code, 'GENERAL CAMARA' city_code, '4308805' ibge_code from dual union
select 'RS' state_code, 'GENTIL' city_code, '4308854' ibge_code from dual union
select 'RS' state_code, 'GETULIO VARGAS' city_code, '4308904' ibge_code from dual union
select 'RS' state_code, 'GIRUA' city_code, '4309001' ibge_code from dual union
select 'RS' state_code, 'GLORINHA' city_code, '4309050' ibge_code from dual union
select 'RS' state_code, 'GRAMADO' city_code, '4309100' ibge_code from dual union
select 'RS' state_code, 'GRAMADO DOS LOUREIROS' city_code, '4309126' ibge_code from dual union
select 'RS' state_code, 'GRAMADO XAVIER' city_code, '4309159' ibge_code from dual union
select 'RS' state_code, 'GRAVATAI' city_code, '4309209' ibge_code from dual union
select 'RS' state_code, 'GUABIJU' city_code, '4309258' ibge_code from dual union
select 'RS' state_code, 'GUAIBA' city_code, '4309308' ibge_code from dual union
select 'RS' state_code, 'GUAPORE' city_code, '4309407' ibge_code from dual union
select 'RS' state_code, 'GUARANI DAS MISSÕES' city_code, '4309506' ibge_code from dual union
select 'RS' state_code, 'HARMONIA' city_code, '4309555' ibge_code from dual union
select 'RS' state_code, 'HERVAL' city_code, '4307104' ibge_code from dual union
select 'RS' state_code, 'HERVEIRAS' city_code, '4309571' ibge_code from dual union
select 'RS' state_code, 'HORIZONTINA' city_code, '4309605' ibge_code from dual union
select 'RS' state_code, 'HULHA NEGRA' city_code, '4309654' ibge_code from dual union
select 'RS' state_code, 'HUMAITA' city_code, '4309704' ibge_code from dual union
select 'RS' state_code, 'IBARAMA' city_code, '4309753' ibge_code from dual union
select 'RS' state_code, 'IBIACA' city_code, '4309803' ibge_code from dual union
select 'RS' state_code, 'IBIRAIARAS' city_code, '4309902' ibge_code from dual union
select 'RS' state_code, 'IBIRAPUITA' city_code, '4309951' ibge_code from dual union
select 'RS' state_code, 'IBIRUBA' city_code, '4310009' ibge_code from dual union
select 'RS' state_code, 'IGREJINHA' city_code, '4310108' ibge_code from dual union
select 'RS' state_code, 'IJUI' city_code, '4310207' ibge_code from dual union
select 'RS' state_code, 'ILOPOLIS' city_code, '4310306' ibge_code from dual union
select 'RS' state_code, 'IMBE' city_code, '4310330' ibge_code from dual union
select 'RS' state_code, 'IMIGRANTE' city_code, '4310363' ibge_code from dual union
select 'RS' state_code, 'INDEPENDENCIA' city_code, '4310405' ibge_code from dual union
select 'RS' state_code, 'INHACORA' city_code, '4310413' ibge_code from dual union
select 'RS' state_code, 'IPE' city_code, '4310439' ibge_code from dual union
select 'RS' state_code, 'IPIRANGA DO SUL' city_code, '4310462' ibge_code from dual union
select 'RS' state_code, 'IRAI' city_code, '4310504' ibge_code from dual union
select 'RS' state_code, 'ITAARA' city_code, '4310538' ibge_code from dual union
select 'RS' state_code, 'ITACURUBI' city_code, '4310553' ibge_code from dual union
select 'RS' state_code, 'ITAPUCA' city_code, '4310579' ibge_code from dual union
select 'RS' state_code, 'ITAQUI' city_code, '4310603' ibge_code from dual union
select 'RS' state_code, 'ITATI' city_code, '4310652' ibge_code from dual union
select 'RS' state_code, 'ITATIBA DO SUL' city_code, '4310702' ibge_code from dual union
select 'RS' state_code, 'IVORA' city_code, '4310751' ibge_code from dual union
select 'RS' state_code, 'IVOTI' city_code, '4310801' ibge_code from dual union
select 'RS' state_code, 'JABOTICABA' city_code, '4310850' ibge_code from dual union
select 'RS' state_code, 'JACUIZINHO' city_code, '4310876' ibge_code from dual union
select 'RS' state_code, 'JACUTINGA' city_code, '4310900' ibge_code from dual union
select 'RS' state_code, 'JAGUARAO' city_code, '4311007' ibge_code from dual union
select 'RS' state_code, 'JAGUARI' city_code, '4311106' ibge_code from dual union
select 'RS' state_code, 'JAQUIRANA' city_code, '4311122' ibge_code from dual union
select 'RS' state_code, 'JARI' city_code, '4311130' ibge_code from dual union
select 'RS' state_code, 'JOIA' city_code, '4311155' ibge_code from dual union
select 'RS' state_code, 'JULIO DE CASTILHOS' city_code, '4311205' ibge_code from dual union
select 'RS' state_code, 'LAGOA BONITA DO SUL' city_code, '4311239' ibge_code from dual union
select 'RS' state_code, 'LAGOA DOS TRES CANTOS' city_code, '4311270' ibge_code from dual union
select 'RS' state_code, 'LAGOA VERMELHA' city_code, '4311304' ibge_code from dual union
select 'RS' state_code, 'LAGOAO' city_code, '4311254' ibge_code from dual union
select 'RS' state_code, 'LAJEADO' city_code, '4311403' ibge_code from dual union
select 'RS' state_code, 'LAJEADO DO BUGRE' city_code, '4311429' ibge_code from dual union
select 'RS' state_code, 'LAVRAS DO SUL' city_code, '4311502' ibge_code from dual union
select 'RS' state_code, 'LIBERATO SALZANO' city_code, '4311601' ibge_code from dual union
select 'RS' state_code, 'LINDOLFO COLLOR' city_code, '4311627' ibge_code from dual union
select 'RS' state_code, 'LINHA NOVA' city_code, '4311643' ibge_code from dual union
select 'RS' state_code, 'MACAMBARA' city_code, '4311718' ibge_code from dual union
select 'RS' state_code, 'MACHADINHO' city_code, '4311700' ibge_code from dual union
select 'RS' state_code, 'MAMPITUBA' city_code, '4311734' ibge_code from dual union
select 'RS' state_code, 'MANOEL VIANA' city_code, '4311759' ibge_code from dual union
select 'RS' state_code, 'MAQUINE' city_code, '4311775' ibge_code from dual union
select 'RS' state_code, 'MARATA' city_code, '4311791' ibge_code from dual union
select 'RS' state_code, 'MARAU' city_code, '4311809' ibge_code from dual union
select 'RS' state_code, 'MARCELINO RAMOS' city_code, '4311908' ibge_code from dual union
select 'RS' state_code, 'MARIANA PIMENTEL' city_code, '4311981' ibge_code from dual union
select 'RS' state_code, 'MARIANO MORO' city_code, '4312005' ibge_code from dual union
select 'RS' state_code, 'MARQUES DE SOUZA' city_code, '4312054' ibge_code from dual union
select 'RS' state_code, 'MATA' city_code, '4312104' ibge_code from dual union
select 'RS' state_code, 'MATO CASTELHANO' city_code, '4312138' ibge_code from dual union
select 'RS' state_code, 'MATO LEITAO' city_code, '4312153' ibge_code from dual union
select 'RS' state_code, 'MATO QUEIMADO' city_code, '4312179' ibge_code from dual union
select 'RS' state_code, 'MAXIMILIANO DE ALMEIDA' city_code, '4312203' ibge_code from dual union
select 'RS' state_code, 'MINAS DO LEAO' city_code, '4312252' ibge_code from dual union
select 'RS' state_code, 'MIRAGUAI' city_code, '4312302' ibge_code from dual union
select 'RS' state_code, 'MONTAURI' city_code, '4312351' ibge_code from dual union
select 'RS' state_code, 'MONTE ALEGRE DOS CAMPOS' city_code, '4312377' ibge_code from dual union
select 'RS' state_code, 'MONTE BELO DO SUL' city_code, '4312385' ibge_code from dual union
select 'RS' state_code, 'MONTENEGRO' city_code, '4312401' ibge_code from dual union
select 'RS' state_code, 'MORMACO' city_code, '4312427' ibge_code from dual union
select 'RS' state_code, 'MORRINHOS DO SUL' city_code, '4312443' ibge_code from dual union
select 'RS' state_code, 'MORRO REDONDO' city_code, '4312450' ibge_code from dual union
select 'RS' state_code, 'MORRO REUTER' city_code, '4312476' ibge_code from dual union
select 'RS' state_code, 'MOSTARDAS' city_code, '4312500' ibge_code from dual union
select 'RS' state_code, 'MUCUM' city_code, '4312609' ibge_code from dual union
select 'RS' state_code, 'MUITOS CAPÕES' city_code, '4312617' ibge_code from dual union
select 'RS' state_code, 'MULITERNO' city_code, '4312625' ibge_code from dual union
select 'RS' state_code, 'NAO-ME-TOQUE' city_code, '4312658' ibge_code from dual union
select 'RS' state_code, 'NICOLAU VERGUEIRO' city_code, '4312674' ibge_code from dual union
select 'RS' state_code, 'NONOAI' city_code, '4312708' ibge_code from dual union
select 'RS' state_code, 'NOVA ALVORADA' city_code, '4312757' ibge_code from dual union
select 'RS' state_code, 'NOVA ARACA' city_code, '4312807' ibge_code from dual union
select 'RS' state_code, 'NOVA BASSANO' city_code, '4312906' ibge_code from dual union
select 'RS' state_code, 'NOVA BOA VISTA' city_code, '4312955' ibge_code from dual union
select 'RS' state_code, 'NOVA BRESCIA' city_code, '4313003' ibge_code from dual union
select 'RS' state_code, 'NOVA CANDELARIA' city_code, '4313011' ibge_code from dual union
select 'RS' state_code, 'NOVA ESPERANCA DO SUL' city_code, '4313037' ibge_code from dual union
select 'RS' state_code, 'NOVA HARTZ' city_code, '4313060' ibge_code from dual union
select 'RS' state_code, 'NOVA PADUA' city_code, '4313086' ibge_code from dual union
select 'RS' state_code, 'NOVA PALMA' city_code, '4313102' ibge_code from dual union
select 'RS' state_code, 'NOVA PETROPOLIS' city_code, '4313201' ibge_code from dual union
select 'RS' state_code, 'NOVA PRATA' city_code, '4313300' ibge_code from dual union
select 'RS' state_code, 'NOVA RAMADA' city_code, '4313334' ibge_code from dual union
select 'RS' state_code, 'NOVA ROMA DO SUL' city_code, '4313359' ibge_code from dual union
select 'RS' state_code, 'NOVA SANTA RITA' city_code, '4313375' ibge_code from dual union
select 'RS' state_code, 'NOVO BARREIRO' city_code, '4313490' ibge_code from dual union
select 'RS' state_code, 'NOVO CABRAIS' city_code, '4313391' ibge_code from dual union
select 'RS' state_code, 'NOVO HAMBURGO' city_code, '4313409' ibge_code from dual union
select 'RS' state_code, 'NOVO MACHADO' city_code, '4313425' ibge_code from dual union
select 'RS' state_code, 'NOVO TIRADENTES' city_code, '4313441' ibge_code from dual union
select 'RS' state_code, 'NOVO XINGU' city_code, '4313466' ibge_code from dual union
select 'RS' state_code, 'OSORIO' city_code, '4313508' ibge_code from dual union
select 'RS' state_code, 'PAIM FILHO' city_code, '4313607' ibge_code from dual union
select 'RS' state_code, 'PALMARES DO SUL' city_code, '4313656' ibge_code from dual union
select 'RS' state_code, 'PALMEIRA DAS MISSÕES' city_code, '4313706' ibge_code from dual union
select 'RS' state_code, 'PALMITINHO' city_code, '4313805' ibge_code from dual union
select 'RS' state_code, 'PANAMBI' city_code, '4313904' ibge_code from dual union
select 'RS' state_code, 'PANTANO GRANDE' city_code, '4313953' ibge_code from dual union
select 'RS' state_code, 'PARAI' city_code, '4314001' ibge_code from dual union
select 'RS' state_code, 'PARAISO DO SUL' city_code, '4314027' ibge_code from dual union
select 'RS' state_code, 'PARECI NOVO' city_code, '4314035' ibge_code from dual union
select 'RS' state_code, 'PAROBE' city_code, '4314050' ibge_code from dual union
select 'RS' state_code, 'PASSA SETE' city_code, '4314068' ibge_code from dual union
select 'RS' state_code, 'PASSO DO SOBRADO' city_code, '4314076' ibge_code from dual union
select 'RS' state_code, 'PASSO FUNDO' city_code, '4314100' ibge_code from dual union
select 'RS' state_code, 'PAULO BENTO' city_code, '4314134' ibge_code from dual union
select 'RS' state_code, 'PAVERAMA' city_code, '4314159' ibge_code from dual union
select 'RS' state_code, 'PEDRAS ALTAS' city_code, '4314175' ibge_code from dual union
select 'RS' state_code, 'PEDRO OSORIO' city_code, '4314209' ibge_code from dual union
select 'RS' state_code, 'PEJUCARA' city_code, '4314308' ibge_code from dual union
select 'RS' state_code, 'PELOTAS' city_code, '4314407' ibge_code from dual union
select 'RS' state_code, 'PICADA CAFE' city_code, '4314423' ibge_code from dual union
select 'RS' state_code, 'PINHAL' city_code, '4314456' ibge_code from dual union
select 'RS' state_code, 'PINHAL DA SERRA' city_code, '4314464' ibge_code from dual union
select 'RS' state_code, 'PINHAL GRANDE' city_code, '4314472' ibge_code from dual union
select 'RS' state_code, 'PINHEIRINHO DO VALE' city_code, '4314498' ibge_code from dual union
select 'RS' state_code, 'PINHEIRO MACHADO' city_code, '4314506' ibge_code from dual union
select 'RS' state_code, 'PINTO BANDEIRA' city_code, '4314548' ibge_code from dual union
select 'RS' state_code, 'PIRAPO' city_code, '4314555' ibge_code from dual union
select 'RS' state_code, 'PIRATINI' city_code, '4314605' ibge_code from dual union
select 'RS' state_code, 'PLANALTO' city_code, '4314704' ibge_code from dual union
select 'RS' state_code, 'POCO DAS ANTAS' city_code, '4314753' ibge_code from dual union
select 'RS' state_code, 'PONTAO' city_code, '4314779' ibge_code from dual union
select 'RS' state_code, 'PONTE PRETA' city_code, '4314787' ibge_code from dual union
select 'RS' state_code, 'PORTAO' city_code, '4314803' ibge_code from dual union
select 'RS' state_code, 'PORTO ALEGRE' city_code, '4314902' ibge_code from dual union
select 'RS' state_code, 'PORTO LUCENA' city_code, '4315008' ibge_code from dual union
select 'RS' state_code, 'PORTO MAUA' city_code, '4315057' ibge_code from dual union
select 'RS' state_code, 'PORTO VERA CRUZ' city_code, '4315073' ibge_code from dual union
select 'RS' state_code, 'PORTO XAVIER' city_code, '4315107' ibge_code from dual union
select 'RS' state_code, 'POUSO NOVO' city_code, '4315131' ibge_code from dual union
select 'RS' state_code, 'PRESIDENTE LUCENA' city_code, '4315149' ibge_code from dual union
select 'RS' state_code, 'PROGRESSO' city_code, '4315156' ibge_code from dual union
select 'RS' state_code, 'PROTASIO ALVES' city_code, '4315172' ibge_code from dual union
select 'RS' state_code, 'PUTINGA' city_code, '4315206' ibge_code from dual union
select 'RS' state_code, 'QUARAI' city_code, '4315305' ibge_code from dual union
select 'RS' state_code, 'QUATRO IRMAOS' city_code, '4315313' ibge_code from dual union
select 'RS' state_code, 'QUEVEDOS' city_code, '4315321' ibge_code from dual union
select 'RS' state_code, 'QUINZE DE NOVEMBRO' city_code, '4315354' ibge_code from dual union
select 'RS' state_code, 'REDENTORA' city_code, '4315404' ibge_code from dual union
select 'RS' state_code, 'RELVADO' city_code, '4315453' ibge_code from dual union
select 'RS' state_code, 'RESTINGA SECA' city_code, '4315503' ibge_code from dual union
select 'RS' state_code, 'RIO DOS INDIOS' city_code, '4315552' ibge_code from dual union
select 'RS' state_code, 'RIO GRANDE' city_code, '4315602' ibge_code from dual union
select 'RS' state_code, 'RIO PARDO' city_code, '4315701' ibge_code from dual union
select 'RS' state_code, 'RIOZINHO' city_code, '4315750' ibge_code from dual union
select 'RS' state_code, 'ROCA SALES' city_code, '4315800' ibge_code from dual union
select 'RS' state_code, 'RODEIO BONITO' city_code, '4315909' ibge_code from dual union
select 'RS' state_code, 'ROLADOR' city_code, '4315958' ibge_code from dual union
select 'RS' state_code, 'ROLANTE' city_code, '4316006' ibge_code from dual union
select 'RS' state_code, 'RONDA ALTA' city_code, '4316105' ibge_code from dual union
select 'RS' state_code, 'RONDINHA' city_code, '4316204' ibge_code from dual union
select 'RS' state_code, 'ROQUE GONZALES' city_code, '4316303' ibge_code from dual union
select 'RS' state_code, 'ROSARIO DO SUL' city_code, '4316402' ibge_code from dual union
select 'RS' state_code, 'SAGRADA FAMILIA' city_code, '4316428' ibge_code from dual union
select 'RS' state_code, 'SALDANHA MARINHO' city_code, '4316436' ibge_code from dual union
select 'RS' state_code, 'SALTO DO JACUI' city_code, '4316451' ibge_code from dual union
select 'RS' state_code, 'SALVADOR DAS MISSÕES' city_code, '4316477' ibge_code from dual union
select 'RS' state_code, 'SALVADOR DO SUL' city_code, '4316501' ibge_code from dual union
select 'RS' state_code, 'SANANDUVA' city_code, '4316600' ibge_code from dual union
select 'RS' state_code, 'SANTA BARBARA DO SUL' city_code, '4316709' ibge_code from dual union
select 'RS' state_code, 'SANTA CECILIA DO SUL' city_code, '4316733' ibge_code from dual union
select 'RS' state_code, 'SANTA CLARA DO SUL' city_code, '4316758' ibge_code from dual union
select 'RS' state_code, 'SANTA CRUZ DO SUL' city_code, '4316808' ibge_code from dual union
select 'RS' state_code, 'SANTA MARGARIDA DO SUL' city_code, '4316972' ibge_code from dual union
select 'RS' state_code, 'SANTA MARIA' city_code, '4316907' ibge_code from dual union
select 'RS' state_code, 'SANTA MARIA DO HERVAL' city_code, '4316956' ibge_code from dual union
select 'RS' state_code, 'SANTA ROSA' city_code, '4317202' ibge_code from dual union
select 'RS' state_code, 'SANTA TEREZA' city_code, '4317251' ibge_code from dual union
select 'RS' state_code, 'SANTA VITORIA DO PALMAR' city_code, '4317301' ibge_code from dual union
select 'RS' state_code, 'SANTANA DA BOA VISTA' city_code, '4317004' ibge_code from dual union
select 'RS' state_code, 'SANT''ANA DO LIVRAMENTO' city_code, '4317103' ibge_code from dual union
select 'RS' state_code, 'SANTIAGO' city_code, '4317400' ibge_code from dual union
select 'RS' state_code, 'SANTO ANGELO' city_code, '4317509' ibge_code from dual union
select 'RS' state_code, 'SANTO ANTONIO DA PATRULHA' city_code, '4317608' ibge_code from dual union
select 'RS' state_code, 'SANTO ANTONIO DAS MISSÕES' city_code, '4317707' ibge_code from dual union
select 'RS' state_code, 'SANTO ANTONIO DO PALMA' city_code, '4317558' ibge_code from dual union
select 'RS' state_code, 'SANTO ANTONIO DO PLANALTO' city_code, '4317756' ibge_code from dual union
select 'RS' state_code, 'SANTO AUGUSTO' city_code, '4317806' ibge_code from dual union
select 'RS' state_code, 'SANTO CRISTO' city_code, '4317905' ibge_code from dual union
select 'RS' state_code, 'SANTO EXPEDITO DO SUL' city_code, '4317954' ibge_code from dual union
select 'RS' state_code, 'SAO BORJA' city_code, '4318002' ibge_code from dual union
select 'RS' state_code, 'SAO DOMINGOS DO SUL' city_code, '4318051' ibge_code from dual union
select 'RS' state_code, 'SAO FRANCISCO DE ASSIS' city_code, '4318101' ibge_code from dual union
select 'RS' state_code, 'SAO FRANCISCO DE PAULA' city_code, '4318200' ibge_code from dual union
select 'RS' state_code, 'SAO GABRIEL' city_code, '4318309' ibge_code from dual union
select 'RS' state_code, 'SAO JERONIMO' city_code, '4318408' ibge_code from dual union
select 'RS' state_code, 'SAO JOAO DA URTIGA' city_code, '4318424' ibge_code from dual union
select 'RS' state_code, 'SAO JOAO DO POLESINE' city_code, '4318432' ibge_code from dual union
select 'RS' state_code, 'SAO JORGE' city_code, '4318440' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DAS MISSÕES' city_code, '4318457' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DO HERVAL' city_code, '4318465' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DO HORTENCIO' city_code, '4318481' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DO INHACORA' city_code, '4318499' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DO NORTE' city_code, '4318507' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DO OURO' city_code, '4318606' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DO SUL' city_code, '4318614' ibge_code from dual union
select 'RS' state_code, 'SAO JOSE DOS AUSENTES' city_code, '4318622' ibge_code from dual union
select 'RS' state_code, 'SAO LEOPOLDO' city_code, '4318705' ibge_code from dual union
select 'RS' state_code, 'SAO LOURENCO DO SUL' city_code, '4318804' ibge_code from dual union
select 'RS' state_code, 'SAO LUIZ GONZAGA' city_code, '4318903' ibge_code from dual union
select 'RS' state_code, 'SAO MARCOS' city_code, '4319000' ibge_code from dual union
select 'RS' state_code, 'SAO MARTINHO' city_code, '4319109' ibge_code from dual union
select 'RS' state_code, 'SAO MARTINHO DA SERRA' city_code, '4319125' ibge_code from dual union
select 'RS' state_code, 'SAO MIGUEL DAS MISSÕES' city_code, '4319158' ibge_code from dual union
select 'RS' state_code, 'SAO NICOLAU' city_code, '4319208' ibge_code from dual union
select 'RS' state_code, 'SAO PAULO DAS MISSÕES' city_code, '4319307' ibge_code from dual union
select 'RS' state_code, 'SAO PEDRO DA SERRA' city_code, '4319356' ibge_code from dual union
select 'RS' state_code, 'SAO PEDRO DAS MISSÕES' city_code, '4319364' ibge_code from dual union
select 'RS' state_code, 'SAO PEDRO DO BUTIA' city_code, '4319372' ibge_code from dual union
select 'RS' state_code, 'SAO PEDRO DO SUL' city_code, '4319406' ibge_code from dual union
select 'RS' state_code, 'SAO SEBASTIAO DO CAI' city_code, '4319505' ibge_code from dual union
select 'RS' state_code, 'SAO SEPE' city_code, '4319604' ibge_code from dual union
select 'RS' state_code, 'SAO VALENTIM' city_code, '4319703' ibge_code from dual union
select 'RS' state_code, 'SAO VALENTIM DO SUL' city_code, '4319711' ibge_code from dual union
select 'RS' state_code, 'SAO VALERIO DO SUL' city_code, '4319737' ibge_code from dual union
select 'RS' state_code, 'SAO VENDELINO' city_code, '4319752' ibge_code from dual union
select 'RS' state_code, 'SAO VICENTE DO SUL' city_code, '4319802' ibge_code from dual union
select 'RS' state_code, 'SAPIRANGA' city_code, '4319901' ibge_code from dual union
select 'RS' state_code, 'SAPUCAIA DO SUL' city_code, '4320008' ibge_code from dual union
select 'RS' state_code, 'SARANDI' city_code, '4320107' ibge_code from dual union
select 'RS' state_code, 'SEBERI' city_code, '4320206' ibge_code from dual union
select 'RS' state_code, 'SEDE NOVA' city_code, '4320230' ibge_code from dual union
select 'RS' state_code, 'SEGREDO' city_code, '4320263' ibge_code from dual union
select 'RS' state_code, 'SELBACH' city_code, '4320305' ibge_code from dual union
select 'RS' state_code, 'SENADOR SALGADO FILHO' city_code, '4320321' ibge_code from dual union
select 'RS' state_code, 'SENTINELA DO SUL' city_code, '4320354' ibge_code from dual union
select 'RS' state_code, 'SERAFINA CORREA' city_code, '4320404' ibge_code from dual union
select 'RS' state_code, 'SERIO' city_code, '4320453' ibge_code from dual union
select 'RS' state_code, 'SERTAO' city_code, '4320503' ibge_code from dual union
select 'RS' state_code, 'SERTAO SANTANA' city_code, '4320552' ibge_code from dual union
select 'RS' state_code, 'SETE DE SETEMBRO' city_code, '4320578' ibge_code from dual union
select 'RS' state_code, 'SEVERIANO DE ALMEIDA' city_code, '4320602' ibge_code from dual union
select 'RS' state_code, 'SILVEIRA MARTINS' city_code, '4320651' ibge_code from dual union
select 'RS' state_code, 'SINIMBU' city_code, '4320677' ibge_code from dual union
select 'RS' state_code, 'SOBRADINHO' city_code, '4320701' ibge_code from dual union
select 'RS' state_code, 'SOLEDADE' city_code, '4320800' ibge_code from dual union
select 'RS' state_code, 'TABAI' city_code, '4320859' ibge_code from dual union
select 'RS' state_code, 'TAPEJARA' city_code, '4320909' ibge_code from dual union
select 'RS' state_code, 'TAPERA' city_code, '4321006' ibge_code from dual union
select 'RS' state_code, 'TAPES' city_code, '4321105' ibge_code from dual union
select 'RS' state_code, 'TAQUARA' city_code, '4321204' ibge_code from dual union
select 'RS' state_code, 'TAQUARI' city_code, '4321303' ibge_code from dual union
select 'RS' state_code, 'TAQUARUCU DO SUL' city_code, '4321329' ibge_code from dual union
select 'RS' state_code, 'TAVARES' city_code, '4321352' ibge_code from dual union
select 'RS' state_code, 'TENENTE PORTELA' city_code, '4321402' ibge_code from dual union
select 'RS' state_code, 'TERRA DE AREIA' city_code, '4321436' ibge_code from dual union
select 'RS' state_code, 'TEUTONIA' city_code, '4321451' ibge_code from dual union
select 'RS' state_code, 'TIO HUGO' city_code, '4321469' ibge_code from dual union
select 'RS' state_code, 'TIRADENTES DO SUL' city_code, '4321477' ibge_code from dual union
select 'RS' state_code, 'TOROPI' city_code, '4321493' ibge_code from dual union
select 'RS' state_code, 'TORRES' city_code, '4321501' ibge_code from dual union
select 'RS' state_code, 'TRAMANDAI' city_code, '4321600' ibge_code from dual union
select 'RS' state_code, 'TRAVESSEIRO' city_code, '4321626' ibge_code from dual union
select 'RS' state_code, 'TRES ARROIOS' city_code, '4321634' ibge_code from dual union
select 'RS' state_code, 'TRES CACHOEIRAS' city_code, '4321667' ibge_code from dual union
select 'RS' state_code, 'TRES COROAS' city_code, '4321709' ibge_code from dual union
select 'RS' state_code, 'TRES DE MAIO' city_code, '4321808' ibge_code from dual union
select 'RS' state_code, 'TRES FORQUILHAS' city_code, '4321832' ibge_code from dual union
select 'RS' state_code, 'TRES PALMEIRAS' city_code, '4321857' ibge_code from dual union
select 'RS' state_code, 'TRES PASSOS' city_code, '4321907' ibge_code from dual union
select 'RS' state_code, 'TRINDADE DO SUL' city_code, '4321956' ibge_code from dual union
select 'RS' state_code, 'TRIUNFO' city_code, '4322004' ibge_code from dual union
select 'RS' state_code, 'TUCUNDUVA' city_code, '4322103' ibge_code from dual union
select 'RS' state_code, 'TUNAS' city_code, '4322152' ibge_code from dual union
select 'RS' state_code, 'TUPANCI DO SUL' city_code, '4322186' ibge_code from dual union
select 'RS' state_code, 'TUPANCIRETA' city_code, '4322202' ibge_code from dual union
select 'RS' state_code, 'TUPANDI' city_code, '4322251' ibge_code from dual union
select 'RS' state_code, 'TUPARENDI' city_code, '4322301' ibge_code from dual union
select 'RS' state_code, 'TURUCU' city_code, '4322327' ibge_code from dual union
select 'RS' state_code, 'UBIRETAMA' city_code, '4322343' ibge_code from dual union
select 'RS' state_code, 'UNIAO DA SERRA' city_code, '4322350' ibge_code from dual union
select 'RS' state_code, 'UNISTALDA' city_code, '4322376' ibge_code from dual union
select 'RS' state_code, 'URUGUAIANA' city_code, '4322400' ibge_code from dual union
select 'RS' state_code, 'VACARIA' city_code, '4322509' ibge_code from dual union
select 'RS' state_code, 'VALE DO SOL' city_code, '4322533' ibge_code from dual union
select 'RS' state_code, 'VALE REAL' city_code, '4322541' ibge_code from dual union
select 'RS' state_code, 'VALE VERDE' city_code, '4322525' ibge_code from dual union
select 'RS' state_code, 'VANINI' city_code, '4322558' ibge_code from dual union
select 'RS' state_code, 'VENANCIO AIRES' city_code, '4322608' ibge_code from dual union
select 'RS' state_code, 'VERA CRUZ' city_code, '4322707' ibge_code from dual union
select 'RS' state_code, 'VERANOPOLIS' city_code, '4322806' ibge_code from dual union
select 'RS' state_code, 'VESPASIANO CORREA' city_code, '4322855' ibge_code from dual union
select 'RS' state_code, 'VIADUTOS' city_code, '4322905' ibge_code from dual union
select 'RS' state_code, 'VIAMAO' city_code, '4323002' ibge_code from dual union
select 'RS' state_code, 'VICENTE DUTRA' city_code, '4323101' ibge_code from dual union
select 'RS' state_code, 'VICTOR GRAEFF' city_code, '4323200' ibge_code from dual union
select 'RS' state_code, 'VILA FLORES' city_code, '4323309' ibge_code from dual union
select 'RS' state_code, 'VILA LANGARO' city_code, '4323358' ibge_code from dual union
select 'RS' state_code, 'VILA MARIA' city_code, '4323408' ibge_code from dual union
select 'RS' state_code, 'VILA NOVA DO SUL' city_code, '4323457' ibge_code from dual union
select 'RS' state_code, 'VISTA ALEGRE' city_code, '4323507' ibge_code from dual union
select 'RS' state_code, 'VISTA ALEGRE DO PRATA' city_code, '4323606' ibge_code from dual union
select 'RS' state_code, 'VISTA GAUCHA' city_code, '4323705' ibge_code from dual union
select 'RS' state_code, 'VITORIA DAS MISSÕES' city_code, '4323754' ibge_code from dual union
select 'RS' state_code, 'WESTFALIA' city_code, '4323770' ibge_code from dual union
select 'RS' state_code, 'XANGRI-LA' city_code, '4323804' ibge_code from dual union
select 'MS' state_code, 'AGUA CLARA' city_code, '5000203' ibge_code from dual union
select 'MS' state_code, 'ALCINOPOLIS' city_code, '5000252' ibge_code from dual union
select 'MS' state_code, 'AMAMBAI' city_code, '5000609' ibge_code from dual union
select 'MS' state_code, 'ANASTACIO' city_code, '5000708' ibge_code from dual union
select 'MS' state_code, 'ANAURILANDIA' city_code, '5000807' ibge_code from dual union
select 'MS' state_code, 'ANGELICA' city_code, '5000856' ibge_code from dual union
select 'MS' state_code, 'ANTONIO JOAO' city_code, '5000906' ibge_code from dual union
select 'MS' state_code, 'APARECIDA DO TABOADO' city_code, '5001003' ibge_code from dual union
select 'MS' state_code, 'AQUIDAUANA' city_code, '5001102' ibge_code from dual union
select 'MS' state_code, 'ARAL MOREIRA' city_code, '5001243' ibge_code from dual union
select 'MS' state_code, 'BANDEIRANTES' city_code, '5001508' ibge_code from dual union
select 'MS' state_code, 'BATAGUASSU' city_code, '5001904' ibge_code from dual union
select 'MS' state_code, 'BATAYPORA' city_code, '5002001' ibge_code from dual union
select 'MS' state_code, 'BELA VISTA' city_code, '5002100' ibge_code from dual union
select 'MS' state_code, 'BODOQUENA' city_code, '5002159' ibge_code from dual union
select 'MS' state_code, 'BONITO' city_code, '5002209' ibge_code from dual union
select 'MS' state_code, 'BRASILANDIA' city_code, '5002308' ibge_code from dual union
select 'MS' state_code, 'CAARAPO' city_code, '5002407' ibge_code from dual union
select 'MS' state_code, 'CAMAPUA' city_code, '5002605' ibge_code from dual union
select 'MS' state_code, 'CAMPO GRANDE' city_code, '5002704' ibge_code from dual union
select 'MS' state_code, 'CARACOL' city_code, '5002803' ibge_code from dual union
select 'MS' state_code, 'CASSILANDIA' city_code, '5002902' ibge_code from dual union
select 'MS' state_code, 'CHAPADAO DO SUL' city_code, '5002951' ibge_code from dual union
select 'MS' state_code, 'CORGUINHO' city_code, '5003108' ibge_code from dual union
select 'MS' state_code, 'CORONEL SAPUCAIA' city_code, '5003157' ibge_code from dual union
select 'MS' state_code, 'CORUMBA' city_code, '5003207' ibge_code from dual union
select 'MS' state_code, 'COSTA RICA' city_code, '5003256' ibge_code from dual union
select 'MS' state_code, 'COXIM' city_code, '5003306' ibge_code from dual union
select 'MS' state_code, 'DEODAPOLIS' city_code, '5003454' ibge_code from dual union
select 'MS' state_code, 'DOIS IRMAOS DO BURITI' city_code, '5003488' ibge_code from dual union
select 'MS' state_code, 'DOURADINA' city_code, '5003504' ibge_code from dual union
select 'MS' state_code, 'DOURADOS' city_code, '5003702' ibge_code from dual union
select 'MS' state_code, 'ELDORADO' city_code, '5003751' ibge_code from dual union
select 'MS' state_code, 'FATIMA DO SUL' city_code, '5003801' ibge_code from dual union
select 'MS' state_code, 'FIGUEIRAO' city_code, '5003900' ibge_code from dual union
select 'MS' state_code, 'GLORIA DE DOURADOS' city_code, '5004007' ibge_code from dual union
select 'MS' state_code, 'GUIA LOPES DA LAGUNA' city_code, '5004106' ibge_code from dual union
select 'MS' state_code, 'IGUATEMI' city_code, '5004304' ibge_code from dual union
select 'MS' state_code, 'INOCENCIA' city_code, '5004403' ibge_code from dual union
select 'MS' state_code, 'ITAPORA' city_code, '5004502' ibge_code from dual union
select 'MS' state_code, 'ITAQUIRAI' city_code, '5004601' ibge_code from dual union
select 'MS' state_code, 'IVINHEMA' city_code, '5004700' ibge_code from dual union
select 'MS' state_code, 'JAPORA' city_code, '5004809' ibge_code from dual union
select 'MS' state_code, 'JARAGUARI' city_code, '5004908' ibge_code from dual union
select 'MS' state_code, 'JARDIM' city_code, '5005004' ibge_code from dual union
select 'MS' state_code, 'JATEI' city_code, '5005103' ibge_code from dual union
select 'MS' state_code, 'JUTI' city_code, '5005152' ibge_code from dual union
select 'MS' state_code, 'LADARIO' city_code, '5005202' ibge_code from dual union
select 'MS' state_code, 'LAGUNA CARAPA' city_code, '5005251' ibge_code from dual union
select 'MS' state_code, 'MARACAJU' city_code, '5005400' ibge_code from dual union
select 'MS' state_code, 'MIRANDA' city_code, '5005608' ibge_code from dual union
select 'MS' state_code, 'MUNDO NOVO' city_code, '5005681' ibge_code from dual union
select 'MS' state_code, 'NAVIRAI' city_code, '5005707' ibge_code from dual union
select 'MS' state_code, 'NIOAQUE' city_code, '5005806' ibge_code from dual union
select 'MS' state_code, 'NOVA ALVORADA DO SUL' city_code, '5006002' ibge_code from dual union
select 'MS' state_code, 'NOVA ANDRADINA' city_code, '5006200' ibge_code from dual union
select 'MS' state_code, 'NOVO HORIZONTE DO SUL' city_code, '5006259' ibge_code from dual union
select 'MS' state_code, 'PARAISO DAS AGUAS' city_code, '5006275' ibge_code from dual union
select 'MS' state_code, 'PARANAIBA' city_code, '5006309' ibge_code from dual union
select 'MS' state_code, 'PARANHOS' city_code, '5006358' ibge_code from dual union
select 'MS' state_code, 'PEDRO GOMES' city_code, '5006408' ibge_code from dual union
select 'MS' state_code, 'PONTA PORA' city_code, '5006606' ibge_code from dual union
select 'MS' state_code, 'PORTO MURTINHO' city_code, '5006903' ibge_code from dual union
select 'MS' state_code, 'RIBAS DO RIO PARDO' city_code, '5007109' ibge_code from dual union
select 'MS' state_code, 'RIO BRILHANTE' city_code, '5007208' ibge_code from dual union
select 'MS' state_code, 'RIO NEGRO' city_code, '5007307' ibge_code from dual union
select 'MS' state_code, 'RIO VERDE DE MATO GROSSO' city_code, '5007406' ibge_code from dual union
select 'MS' state_code, 'ROCHEDO' city_code, '5007505' ibge_code from dual union
select 'MS' state_code, 'SANTA RITA DO PARDO' city_code, '5007554' ibge_code from dual union
select 'MS' state_code, 'SAO GABRIEL DO OESTE' city_code, '5007695' ibge_code from dual union
select 'MS' state_code, 'SELVIRIA' city_code, '5007802' ibge_code from dual union
select 'MS' state_code, 'SETE QUEDAS' city_code, '5007703' ibge_code from dual union
select 'MS' state_code, 'SIDROLANDIA' city_code, '5007901' ibge_code from dual union
select 'MS' state_code, 'SONORA' city_code, '5007935' ibge_code from dual union
select 'MS' state_code, 'TACURU' city_code, '5007950' ibge_code from dual union
select 'MS' state_code, 'TAQUARUSSU' city_code, '5007976' ibge_code from dual union
select 'MS' state_code, 'TERENOS' city_code, '5008008' ibge_code from dual union
select 'MS' state_code, 'TRES LAGOAS' city_code, '5008305' ibge_code from dual union
select 'MS' state_code, 'VICENTINA' city_code, '5008404' ibge_code from dual union
select 'MT' state_code, 'ACORIZAL' city_code, '5100102' ibge_code from dual union
select 'MT' state_code, 'AGUA BOA' city_code, '5100201' ibge_code from dual union
select 'MT' state_code, 'ALTA FLORESTA' city_code, '5100250' ibge_code from dual union
select 'MT' state_code, 'ALTO ARAGUAIA' city_code, '5100300' ibge_code from dual union
select 'MT' state_code, 'ALTO BOA VISTA' city_code, '5100359' ibge_code from dual union
select 'MT' state_code, 'ALTO GARCAS' city_code, '5100409' ibge_code from dual union
select 'MT' state_code, 'ALTO PARAGUAI' city_code, '5100508' ibge_code from dual union
select 'MT' state_code, 'ALTO TAQUARI' city_code, '5100607' ibge_code from dual union
select 'MT' state_code, 'APIACAS' city_code, '5100805' ibge_code from dual union
select 'MT' state_code, 'ARAGUAIANA' city_code, '5101001' ibge_code from dual union
select 'MT' state_code, 'ARAGUAINHA' city_code, '5101209' ibge_code from dual union
select 'MT' state_code, 'ARAPUTANGA' city_code, '5101258' ibge_code from dual union
select 'MT' state_code, 'ARENAPOLIS' city_code, '5101308' ibge_code from dual union
select 'MT' state_code, 'ARIPUANA' city_code, '5101407' ibge_code from dual union
select 'MT' state_code, 'BARAO DE MELGACO' city_code, '5101605' ibge_code from dual union
select 'MT' state_code, 'BARRA DO BUGRES' city_code, '5101704' ibge_code from dual union
select 'MT' state_code, 'BARRA DO GARCAS' city_code, '5101803' ibge_code from dual union
select 'MT' state_code, 'BOM JESUS DO ARAGUAIA' city_code, '5101852' ibge_code from dual union
select 'MT' state_code, 'BRASNORTE' city_code, '5101902' ibge_code from dual union
select 'MT' state_code, 'CACERES' city_code, '5102504' ibge_code from dual union
select 'MT' state_code, 'CAMPINAPOLIS' city_code, '5102603' ibge_code from dual union
select 'MT' state_code, 'CAMPO NOVO DO PARECIS' city_code, '5102637' ibge_code from dual union
select 'MT' state_code, 'CAMPO VERDE' city_code, '5102678' ibge_code from dual union
select 'MT' state_code, 'CAMPOS DE JULIO' city_code, '5102686' ibge_code from dual union
select 'MT' state_code, 'CANABRAVA DO NORTE' city_code, '5102694' ibge_code from dual union
select 'MT' state_code, 'CANARANA' city_code, '5102702' ibge_code from dual union
select 'MT' state_code, 'CARLINDA' city_code, '5102793' ibge_code from dual union
select 'MT' state_code, 'CASTANHEIRA' city_code, '5102850' ibge_code from dual union
select 'MT' state_code, 'CHAPADA DOS GUIMARAES' city_code, '5103007' ibge_code from dual union
select 'MT' state_code, 'CLAUDIA' city_code, '5103056' ibge_code from dual union
select 'MT' state_code, 'COCALINHO' city_code, '5103106' ibge_code from dual union
select 'MT' state_code, 'COLIDER' city_code, '5103205' ibge_code from dual union
select 'MT' state_code, 'COLNIZA' city_code, '5103254' ibge_code from dual union
select 'MT' state_code, 'COMODORO' city_code, '5103304' ibge_code from dual union
select 'MT' state_code, 'CONFRESA' city_code, '5103353' ibge_code from dual union
select 'MT' state_code, 'CONQUISTA D''OESTE' city_code, '5103361' ibge_code from dual union
select 'MT' state_code, 'COTRIGUACU' city_code, '5103379' ibge_code from dual union
select 'MT' state_code, 'CUIABA' city_code, '5103403' ibge_code from dual union
select 'MT' state_code, 'CURVELANDIA' city_code, '5103437' ibge_code from dual union
select 'MT' state_code, 'DENISE' city_code, '5103452' ibge_code from dual union
select 'MT' state_code, 'DIAMANTINO' city_code, '5103502' ibge_code from dual union
select 'MT' state_code, 'DOM AQUINO' city_code, '5103601' ibge_code from dual union
select 'MT' state_code, 'FELIZ NATAL' city_code, '5103700' ibge_code from dual union
select 'MT' state_code, 'FIGUEIROPOLIS D''OESTE' city_code, '5103809' ibge_code from dual union
select 'MT' state_code, 'GAUCHA DO NORTE' city_code, '5103858' ibge_code from dual union
select 'MT' state_code, 'GENERAL CARNEIRO' city_code, '5103908' ibge_code from dual union
select 'MT' state_code, 'GLORIA D''OESTE' city_code, '5103957' ibge_code from dual union
select 'MT' state_code, 'GUARANTA DO NORTE' city_code, '5104104' ibge_code from dual union
select 'MT' state_code, 'GUIRATINGA' city_code, '5104203' ibge_code from dual union
select 'MT' state_code, 'INDIAVAI' city_code, '5104500' ibge_code from dual union
select 'MT' state_code, 'IPIRANGA DO NORTE' city_code, '5104526' ibge_code from dual union
select 'MT' state_code, 'ITANHANGA' city_code, '5104542' ibge_code from dual union
select 'MT' state_code, 'ITAUBA' city_code, '5104559' ibge_code from dual union
select 'MT' state_code, 'ITIQUIRA' city_code, '5104609' ibge_code from dual union
select 'MT' state_code, 'JACIARA' city_code, '5104807' ibge_code from dual union
select 'MT' state_code, 'JANGADA' city_code, '5104906' ibge_code from dual union
select 'MT' state_code, 'JAURU' city_code, '5105002' ibge_code from dual union
select 'MT' state_code, 'JUARA' city_code, '5105101' ibge_code from dual union
select 'MT' state_code, 'JUINA' city_code, '5105150' ibge_code from dual union
select 'MT' state_code, 'JURUENA' city_code, '5105176' ibge_code from dual union
select 'MT' state_code, 'JUSCIMEIRA' city_code, '5105200' ibge_code from dual union
select 'MT' state_code, 'LAMBARI D''OESTE' city_code, '5105234' ibge_code from dual union
select 'MT' state_code, 'LUCAS DO RIO VERDE' city_code, '5105259' ibge_code from dual union
select 'MT' state_code, 'LUCIARA' city_code, '5105309' ibge_code from dual union
select 'MT' state_code, 'MARCELANDIA' city_code, '5105580' ibge_code from dual union
select 'MT' state_code, 'MATUPA' city_code, '5105606' ibge_code from dual union
select 'MT' state_code, 'MIRASSOL D''OESTE' city_code, '5105622' ibge_code from dual union
select 'MT' state_code, 'NOBRES' city_code, '5105903' ibge_code from dual union
select 'MT' state_code, 'NORTELANDIA' city_code, '5106000' ibge_code from dual union
select 'MT' state_code, 'NOSSA SENHORA DO LIVRAMENTO' city_code, '5106109' ibge_code from dual union
select 'MT' state_code, 'NOVA BANDEIRANTES' city_code, '5106158' ibge_code from dual union
select 'MT' state_code, 'NOVA BRASILANDIA' city_code, '5106208' ibge_code from dual union
select 'MT' state_code, 'NOVA CANAA DO NORTE' city_code, '5106216' ibge_code from dual union
select 'MT' state_code, 'NOVA GUARITA' city_code, '5108808' ibge_code from dual union
select 'MT' state_code, 'NOVA LACERDA' city_code, '5106182' ibge_code from dual union
select 'MT' state_code, 'NOVA MARILANDIA' city_code, '5108857' ibge_code from dual union
select 'MT' state_code, 'NOVA MARINGA' city_code, '5108907' ibge_code from dual union
select 'MT' state_code, 'NOVA MONTE VERDE' city_code, '5108956' ibge_code from dual union
select 'MT' state_code, 'NOVA MUTUM' city_code, '5106224' ibge_code from dual union
select 'MT' state_code, 'NOVA NAZARE' city_code, '5106174' ibge_code from dual union
select 'MT' state_code, 'NOVA OLIMPIA' city_code, '5106232' ibge_code from dual union
select 'MT' state_code, 'NOVA SANTA HELENA' city_code, '5106190' ibge_code from dual union
select 'MT' state_code, 'NOVA UBIRATA' city_code, '5106240' ibge_code from dual union
select 'MT' state_code, 'NOVA XAVANTINA' city_code, '5106257' ibge_code from dual union
select 'MT' state_code, 'NOVO HORIZONTE DO NORTE' city_code, '5106273' ibge_code from dual union
select 'MT' state_code, 'NOVO MUNDO' city_code, '5106265' ibge_code from dual union
select 'MT' state_code, 'NOVO SANTO ANTONIO' city_code, '5106315' ibge_code from dual union
select 'MT' state_code, 'NOVO SAO JOAQUIM' city_code, '5106281' ibge_code from dual union
select 'MT' state_code, 'PARANAITA' city_code, '5106299' ibge_code from dual union
select 'MT' state_code, 'PARANATINGA' city_code, '5106307' ibge_code from dual union
select 'MT' state_code, 'PEDRA PRETA' city_code, '5106372' ibge_code from dual union
select 'MT' state_code, 'PEIXOTO DE AZEVEDO' city_code, '5106422' ibge_code from dual union
select 'MT' state_code, 'PLANALTO DA SERRA' city_code, '5106455' ibge_code from dual union
select 'MT' state_code, 'POCONE' city_code, '5106505' ibge_code from dual union
select 'MT' state_code, 'PONTAL DO ARAGUAIA' city_code, '5106653' ibge_code from dual union
select 'MT' state_code, 'PONTE BRANCA' city_code, '5106703' ibge_code from dual union
select 'MT' state_code, 'PONTES E LACERDA' city_code, '5106752' ibge_code from dual union
select 'MT' state_code, 'PORTO ALEGRE DO NORTE' city_code, '5106778' ibge_code from dual union
select 'MT' state_code, 'PORTO DOS GAUCHOS' city_code, '5106802' ibge_code from dual union
select 'MT' state_code, 'PORTO ESPERIDIAO' city_code, '5106828' ibge_code from dual union
select 'MT' state_code, 'PORTO ESTRELA' city_code, '5106851' ibge_code from dual union
select 'MT' state_code, 'POXOREU' city_code, '5107008' ibge_code from dual union
select 'MT' state_code, 'PRIMAVERA DO LESTE' city_code, '5107040' ibge_code from dual union
select 'MT' state_code, 'QUERENCIA' city_code, '5107065' ibge_code from dual union
select 'MT' state_code, 'RESERVA DO CABACAL' city_code, '5107156' ibge_code from dual union
select 'MT' state_code, 'RIBEIRAO CASCALHEIRA' city_code, '5107180' ibge_code from dual union
select 'MT' state_code, 'RIBEIRAOZINHO' city_code, '5107198' ibge_code from dual union
select 'MT' state_code, 'RIO BRANCO' city_code, '5107206' ibge_code from dual union
select 'MT' state_code, 'RONDOLANDIA' city_code, '5107578' ibge_code from dual union
select 'MT' state_code, 'RONDONOPOLIS' city_code, '5107602' ibge_code from dual union
select 'MT' state_code, 'ROSARIO OESTE' city_code, '5107701' ibge_code from dual union
select 'MT' state_code, 'SALTO DO CEU' city_code, '5107750' ibge_code from dual union
select 'MT' state_code, 'SANTA CARMEM' city_code, '5107248' ibge_code from dual union
select 'MT' state_code, 'SANTA CRUZ DO XINGU' city_code, '5107743' ibge_code from dual union
select 'MT' state_code, 'SANTA RITA DO TRIVELATO' city_code, '5107768' ibge_code from dual union
select 'MT' state_code, 'SANTA TEREZINHA' city_code, '5107776' ibge_code from dual union
select 'MT' state_code, 'SANTO AFONSO' city_code, '5107263' ibge_code from dual union
select 'MT' state_code, 'SANTO ANTONIO DO LESTE' city_code, '5107792' ibge_code from dual union
select 'MT' state_code, 'SANTO ANTONIO DO LEVERGER' city_code, '5107800' ibge_code from dual union
select 'MT' state_code, 'SAO FELIX DO ARAGUAIA' city_code, '5107859' ibge_code from dual union
select 'MT' state_code, 'SAO JOSE DO POVO' city_code, '5107297' ibge_code from dual union
select 'MT' state_code, 'SAO JOSE DO RIO CLARO' city_code, '5107305' ibge_code from dual union
select 'MT' state_code, 'SAO JOSE DO XINGU' city_code, '5107354' ibge_code from dual union
select 'MT' state_code, 'SAO JOSE DOS QUATRO MARCOS' city_code, '5107107' ibge_code from dual union
select 'MT' state_code, 'SAO PEDRO DA CIPA' city_code, '5107404' ibge_code from dual union
select 'MT' state_code, 'SAPEZAL' city_code, '5107875' ibge_code from dual union
select 'MT' state_code, 'SERRA NOVA DOURADA' city_code, '5107883' ibge_code from dual union
select 'MT' state_code, 'SINOP' city_code, '5107909' ibge_code from dual union
select 'MT' state_code, 'SORRISO' city_code, '5107925' ibge_code from dual union
select 'MT' state_code, 'TABAPORA' city_code, '5107941' ibge_code from dual union
select 'MT' state_code, 'TANGARA DA SERRA' city_code, '5107958' ibge_code from dual union
select 'MT' state_code, 'TAPURAH' city_code, '5108006' ibge_code from dual union
select 'MT' state_code, 'TERRA NOVA DO NORTE' city_code, '5108055' ibge_code from dual union
select 'MT' state_code, 'TESOURO' city_code, '5108105' ibge_code from dual union
select 'MT' state_code, 'TORIXOREU' city_code, '5108204' ibge_code from dual union
select 'MT' state_code, 'UNIAO DO SUL' city_code, '5108303' ibge_code from dual union
select 'MT' state_code, 'VALE DE SAO DOMINGOS' city_code, '5108352' ibge_code from dual union
select 'MT' state_code, 'VARZEA GRANDE' city_code, '5108402' ibge_code from dual union
select 'MT' state_code, 'VERA' city_code, '5108501' ibge_code from dual union
select 'MT' state_code, 'VILA BELA DA SANTISSIMA TRINDADE' city_code, '5105507' ibge_code from dual union
select 'MT' state_code, 'VILA RICA' city_code, '5108600' ibge_code from dual union
select 'GO' state_code, 'ABADIA DE GOIAS' city_code, '5200050' ibge_code from dual union
select 'GO' state_code, 'ABADIANIA' city_code, '5200100' ibge_code from dual union
select 'GO' state_code, 'ACREUNA' city_code, '5200134' ibge_code from dual union
select 'GO' state_code, 'ADELANDIA' city_code, '5200159' ibge_code from dual union
select 'GO' state_code, 'AGUA FRIA DE GOIAS' city_code, '5200175' ibge_code from dual union
select 'GO' state_code, 'AGUA LIMPA' city_code, '5200209' ibge_code from dual union
select 'GO' state_code, 'AGUAS LINDAS DE GOIAS' city_code, '5200258' ibge_code from dual union
select 'GO' state_code, 'ALEXANIA' city_code, '5200308' ibge_code from dual union
select 'GO' state_code, 'ALOANDIA' city_code, '5200506' ibge_code from dual union
select 'GO' state_code, 'ALTO HORIZONTE' city_code, '5200555' ibge_code from dual union
select 'GO' state_code, 'ALTO PARAISO DE GOIAS' city_code, '5200605' ibge_code from dual union
select 'GO' state_code, 'ALVORADA DO NORTE' city_code, '5200803' ibge_code from dual union
select 'GO' state_code, 'AMARALINA' city_code, '5200829' ibge_code from dual union
select 'GO' state_code, 'AMERICANO DO BRASIL' city_code, '5200852' ibge_code from dual union
select 'GO' state_code, 'AMORINOPOLIS' city_code, '5200902' ibge_code from dual union
select 'GO' state_code, 'ANAPOLIS' city_code, '5201108' ibge_code from dual union
select 'GO' state_code, 'ANHANGUERA' city_code, '5201207' ibge_code from dual union
select 'GO' state_code, 'ANICUNS' city_code, '5201306' ibge_code from dual union
select 'GO' state_code, 'APARECIDA DE GOIANIA' city_code, '5201405' ibge_code from dual union
select 'GO' state_code, 'APARECIDA DO RIO DOCE' city_code, '5201454' ibge_code from dual union
select 'GO' state_code, 'APORE' city_code, '5201504' ibge_code from dual union
select 'GO' state_code, 'ARACU' city_code, '5201603' ibge_code from dual union
select 'GO' state_code, 'ARAGARCAS' city_code, '5201702' ibge_code from dual union
select 'GO' state_code, 'ARAGOIANIA' city_code, '5201801' ibge_code from dual union
select 'GO' state_code, 'ARAGUAPAZ' city_code, '5202155' ibge_code from dual union
select 'GO' state_code, 'ARENOPOLIS' city_code, '5202353' ibge_code from dual union
select 'GO' state_code, 'ARUANA' city_code, '5202502' ibge_code from dual union
select 'GO' state_code, 'AURILANDIA' city_code, '5202601' ibge_code from dual union
select 'GO' state_code, 'AVELINOPOLIS' city_code, '5202809' ibge_code from dual union
select 'GO' state_code, 'BALIZA' city_code, '5203104' ibge_code from dual union
select 'GO' state_code, 'BARRO ALTO' city_code, '5203203' ibge_code from dual union
select 'GO' state_code, 'BELA VISTA DE GOIAS' city_code, '5203302' ibge_code from dual union
select 'GO' state_code, 'BOM JARDIM DE GOIAS' city_code, '5203401' ibge_code from dual union
select 'GO' state_code, 'BOM JESUS DE GOIAS' city_code, '5203500' ibge_code from dual union
select 'GO' state_code, 'BONFINOPOLIS' city_code, '5203559' ibge_code from dual union
select 'GO' state_code, 'BONOPOLIS' city_code, '5203575' ibge_code from dual union
select 'GO' state_code, 'BRAZABRANTES' city_code, '5203609' ibge_code from dual union
select 'GO' state_code, 'BRITANIA' city_code, '5203807' ibge_code from dual union
select 'GO' state_code, 'BURITI ALEGRE' city_code, '5203906' ibge_code from dual union
select 'GO' state_code, 'BURITI DE GOIAS' city_code, '5203939' ibge_code from dual union
select 'GO' state_code, 'BURITINOPOLIS' city_code, '5203962' ibge_code from dual union
select 'GO' state_code, 'CABECEIRAS' city_code, '5204003' ibge_code from dual union
select 'GO' state_code, 'CACHOEIRA ALTA' city_code, '5204102' ibge_code from dual union
select 'GO' state_code, 'CACHOEIRA DE GOIAS' city_code, '5204201' ibge_code from dual union
select 'GO' state_code, 'CACHOEIRA DOURADA' city_code, '5204250' ibge_code from dual union
select 'GO' state_code, 'CACU' city_code, '5204300' ibge_code from dual union
select 'GO' state_code, 'CAIAPONIA' city_code, '5204409' ibge_code from dual union
select 'GO' state_code, 'CALDAS NOVAS' city_code, '5204508' ibge_code from dual union
select 'GO' state_code, 'CALDAZINHA' city_code, '5204557' ibge_code from dual union
select 'GO' state_code, 'CAMPESTRE DE GOIAS' city_code, '5204607' ibge_code from dual union
select 'GO' state_code, 'CAMPINACU' city_code, '5204656' ibge_code from dual union
select 'GO' state_code, 'CAMPINORTE' city_code, '5204706' ibge_code from dual union
select 'GO' state_code, 'CAMPO ALEGRE DE GOIAS' city_code, '5204805' ibge_code from dual union
select 'GO' state_code, 'CAMPO LIMPO DE GOIAS' city_code, '5204854' ibge_code from dual union
select 'GO' state_code, 'CAMPOS BELOS' city_code, '5204904' ibge_code from dual union
select 'GO' state_code, 'CAMPOS VERDES' city_code, '5204953' ibge_code from dual union
select 'GO' state_code, 'CARMO DO RIO VERDE' city_code, '5205000' ibge_code from dual union
select 'GO' state_code, 'CASTELANDIA' city_code, '5205059' ibge_code from dual union
select 'GO' state_code, 'CATALAO' city_code, '5205109' ibge_code from dual union
select 'GO' state_code, 'CATURAI' city_code, '5205208' ibge_code from dual union
select 'GO' state_code, 'CAVALCANTE' city_code, '5205307' ibge_code from dual union
select 'GO' state_code, 'CERES' city_code, '5205406' ibge_code from dual union
select 'GO' state_code, 'CEZARINA' city_code, '5205455' ibge_code from dual union
select 'GO' state_code, 'CHAPADAO DO CEU' city_code, '5205471' ibge_code from dual union
select 'GO' state_code, 'CIDADE OCIDENTAL' city_code, '5205497' ibge_code from dual union
select 'GO' state_code, 'COCALZINHO DE GOIAS' city_code, '5205513' ibge_code from dual union
select 'GO' state_code, 'COLINAS DO SUL' city_code, '5205521' ibge_code from dual union
select 'GO' state_code, 'CORREGO DO OURO' city_code, '5205703' ibge_code from dual union
select 'GO' state_code, 'CORUMBA DE GOIAS' city_code, '5205802' ibge_code from dual union
select 'GO' state_code, 'CORUMBAIBA' city_code, '5205901' ibge_code from dual union
select 'GO' state_code, 'CRISTALINA' city_code, '5206206' ibge_code from dual union
select 'GO' state_code, 'CRISTIANOPOLIS' city_code, '5206305' ibge_code from dual union
select 'GO' state_code, 'CRIXAS' city_code, '5206404' ibge_code from dual union
select 'GO' state_code, 'CROMINIA' city_code, '5206503' ibge_code from dual union
select 'GO' state_code, 'CUMARI' city_code, '5206602' ibge_code from dual union
select 'GO' state_code, 'DAMIANOPOLIS' city_code, '5206701' ibge_code from dual union
select 'GO' state_code, 'DAMOLANDIA' city_code, '5206800' ibge_code from dual union
select 'GO' state_code, 'DAVINOPOLIS' city_code, '5206909' ibge_code from dual union
select 'GO' state_code, 'DIORAMA' city_code, '5207105' ibge_code from dual union
select 'GO' state_code, 'DIVINOPOLIS DE GOIAS' city_code, '5208301' ibge_code from dual union
select 'GO' state_code, 'DOVERLANDIA' city_code, '5207253' ibge_code from dual union
select 'GO' state_code, 'EDEALINA' city_code, '5207352' ibge_code from dual union
select 'GO' state_code, 'EDEIA' city_code, '5207402' ibge_code from dual union
select 'GO' state_code, 'ESTRELA DO NORTE' city_code, '5207501' ibge_code from dual union
select 'GO' state_code, 'FAINA' city_code, '5207535' ibge_code from dual union
select 'GO' state_code, 'FAZENDA NOVA' city_code, '5207600' ibge_code from dual union
select 'GO' state_code, 'FIRMINOPOLIS' city_code, '5207808' ibge_code from dual union
select 'GO' state_code, 'FLORES DE GOIAS' city_code, '5207907' ibge_code from dual union
select 'GO' state_code, 'FORMOSA' city_code, '5208004' ibge_code from dual union
select 'GO' state_code, 'FORMOSO' city_code, '5208103' ibge_code from dual union
select 'GO' state_code, 'GAMELEIRA DE GOIAS' city_code, '5208152' ibge_code from dual union
select 'GO' state_code, 'GOIANAPOLIS' city_code, '5208400' ibge_code from dual union
select 'GO' state_code, 'GOIANDIRA' city_code, '5208509' ibge_code from dual union
select 'GO' state_code, 'GOIANESIA' city_code, '5208608' ibge_code from dual union
select 'GO' state_code, 'GOIANIA' city_code, '5208707' ibge_code from dual union
select 'GO' state_code, 'GOIANIRA' city_code, '5208806' ibge_code from dual union
select 'GO' state_code, 'GOIAS' city_code, '5208905' ibge_code from dual union
select 'GO' state_code, 'GOIATUBA' city_code, '5209101' ibge_code from dual union
select 'GO' state_code, 'GOUVELANDIA' city_code, '5209150' ibge_code from dual union
select 'GO' state_code, 'GUAPO' city_code, '5209200' ibge_code from dual union
select 'GO' state_code, 'GUARAITA' city_code, '5209291' ibge_code from dual union
select 'GO' state_code, 'GUARANI DE GOIAS' city_code, '5209408' ibge_code from dual union
select 'GO' state_code, 'GUARINOS' city_code, '5209457' ibge_code from dual union
select 'GO' state_code, 'HEITORAI' city_code, '5209606' ibge_code from dual union
select 'GO' state_code, 'HIDROLANDIA' city_code, '5209705' ibge_code from dual union
select 'GO' state_code, 'HIDROLINA' city_code, '5209804' ibge_code from dual union
select 'GO' state_code, 'IACIARA' city_code, '5209903' ibge_code from dual union
select 'GO' state_code, 'INACIOLANDIA' city_code, '5209937' ibge_code from dual union
select 'GO' state_code, 'INDIARA' city_code, '5209952' ibge_code from dual union
select 'GO' state_code, 'INHUMAS' city_code, '5210000' ibge_code from dual union
select 'GO' state_code, 'IPAMERI' city_code, '5210109' ibge_code from dual union
select 'GO' state_code, 'IPIRANGA DE GOIAS' city_code, '5210158' ibge_code from dual union
select 'GO' state_code, 'IPORA' city_code, '5210208' ibge_code from dual union
select 'GO' state_code, 'ISRAELANDIA' city_code, '5210307' ibge_code from dual union
select 'GO' state_code, 'ITABERAI' city_code, '5210406' ibge_code from dual union
select 'GO' state_code, 'ITAGUARI' city_code, '5210562' ibge_code from dual union
select 'GO' state_code, 'ITAGUARU' city_code, '5210604' ibge_code from dual union
select 'GO' state_code, 'ITAJA' city_code, '5210802' ibge_code from dual union
select 'GO' state_code, 'ITAPACI' city_code, '5210901' ibge_code from dual union
select 'GO' state_code, 'ITAPIRAPUA' city_code, '5211008' ibge_code from dual union
select 'GO' state_code, 'ITAPURANGA' city_code, '5211206' ibge_code from dual union
select 'GO' state_code, 'ITARUMA' city_code, '5211305' ibge_code from dual union
select 'GO' state_code, 'ITAUCU' city_code, '5211404' ibge_code from dual union
select 'GO' state_code, 'ITUMBIARA' city_code, '5211503' ibge_code from dual union
select 'GO' state_code, 'IVOLANDIA' city_code, '5211602' ibge_code from dual union
select 'GO' state_code, 'JANDAIA' city_code, '5211701' ibge_code from dual union
select 'GO' state_code, 'JARAGUA' city_code, '5211800' ibge_code from dual union
select 'GO' state_code, 'JATAI' city_code, '5211909' ibge_code from dual union
select 'GO' state_code, 'JAUPACI' city_code, '5212006' ibge_code from dual union
select 'GO' state_code, 'JESUPOLIS' city_code, '5212055' ibge_code from dual union
select 'GO' state_code, 'JOVIANIA' city_code, '5212105' ibge_code from dual union
select 'GO' state_code, 'JUSSARA' city_code, '5212204' ibge_code from dual union
select 'GO' state_code, 'LAGOA SANTA' city_code, '5212253' ibge_code from dual union
select 'GO' state_code, 'LEOPOLDO DE BULHÕES' city_code, '5212303' ibge_code from dual union
select 'GO' state_code, 'LUZIANIA' city_code, '5212501' ibge_code from dual union
select 'GO' state_code, 'MAIRIPOTABA' city_code, '5212600' ibge_code from dual union
select 'GO' state_code, 'MAMBAI' city_code, '5212709' ibge_code from dual union
select 'GO' state_code, 'MARA ROSA' city_code, '5212808' ibge_code from dual union
select 'GO' state_code, 'MARZAGAO' city_code, '5212907' ibge_code from dual union
select 'GO' state_code, 'MATRINCHA' city_code, '5212956' ibge_code from dual union
select 'GO' state_code, 'MAURILANDIA' city_code, '5213004' ibge_code from dual union
select 'GO' state_code, 'MIMOSO DE GOIAS' city_code, '5213053' ibge_code from dual union
select 'GO' state_code, 'MINACU' city_code, '5213087' ibge_code from dual union
select 'GO' state_code, 'MINEIROS' city_code, '5213103' ibge_code from dual union
select 'GO' state_code, 'MOIPORA' city_code, '5213400' ibge_code from dual union
select 'GO' state_code, 'MONTE ALEGRE DE GOIAS' city_code, '5213509' ibge_code from dual union
select 'GO' state_code, 'MONTES CLAROS DE GOIAS' city_code, '5213707' ibge_code from dual union
select 'GO' state_code, 'MONTIVIDIU' city_code, '5213756' ibge_code from dual union
select 'GO' state_code, 'MONTIVIDIU DO NORTE' city_code, '5213772' ibge_code from dual union
select 'GO' state_code, 'MORRINHOS' city_code, '5213806' ibge_code from dual union
select 'GO' state_code, 'MORRO AGUDO DE GOIAS' city_code, '5213855' ibge_code from dual union
select 'GO' state_code, 'MOSSAMEDES' city_code, '5213905' ibge_code from dual union
select 'GO' state_code, 'MOZARLANDIA' city_code, '5214002' ibge_code from dual union
select 'GO' state_code, 'MUNDO NOVO' city_code, '5214051' ibge_code from dual union
select 'GO' state_code, 'MUTUNOPOLIS' city_code, '5214101' ibge_code from dual union
select 'GO' state_code, 'NAZARIO' city_code, '5214408' ibge_code from dual union
select 'GO' state_code, 'NEROPOLIS' city_code, '5214507' ibge_code from dual union
select 'GO' state_code, 'NIQUELANDIA' city_code, '5214606' ibge_code from dual union
select 'GO' state_code, 'NOVA AMERICA' city_code, '5214705' ibge_code from dual union
select 'GO' state_code, 'NOVA AURORA' city_code, '5214804' ibge_code from dual union
select 'GO' state_code, 'NOVA CRIXAS' city_code, '5214838' ibge_code from dual union
select 'GO' state_code, 'NOVA GLORIA' city_code, '5214861' ibge_code from dual union
select 'GO' state_code, 'NOVA IGUACU DE GOIAS' city_code, '5214879' ibge_code from dual union
select 'GO' state_code, 'NOVA ROMA' city_code, '5214903' ibge_code from dual union
select 'GO' state_code, 'NOVA VENEZA' city_code, '5215009' ibge_code from dual union
select 'GO' state_code, 'NOVO BRASIL' city_code, '5215207' ibge_code from dual union
select 'GO' state_code, 'NOVO GAMA' city_code, '5215231' ibge_code from dual union
select 'GO' state_code, 'NOVO PLANALTO' city_code, '5215256' ibge_code from dual union
select 'GO' state_code, 'ORIZONA' city_code, '5215306' ibge_code from dual union
select 'GO' state_code, 'OURO VERDE DE GOIAS' city_code, '5215405' ibge_code from dual union
select 'GO' state_code, 'OUVIDOR' city_code, '5215504' ibge_code from dual union
select 'GO' state_code, 'PADRE BERNARDO' city_code, '5215603' ibge_code from dual union
select 'GO' state_code, 'PALESTINA DE GOIAS' city_code, '5215652' ibge_code from dual union
select 'GO' state_code, 'PALMEIRAS DE GOIAS' city_code, '5215702' ibge_code from dual union
select 'GO' state_code, 'PALMELO' city_code, '5215801' ibge_code from dual union
select 'GO' state_code, 'PALMINOPOLIS' city_code, '5215900' ibge_code from dual union
select 'GO' state_code, 'PANAMA' city_code, '5216007' ibge_code from dual union
select 'GO' state_code, 'PARANAIGUARA' city_code, '5216304' ibge_code from dual union
select 'GO' state_code, 'PARAUNA' city_code, '5216403' ibge_code from dual union
select 'GO' state_code, 'PEROLANDIA' city_code, '5216452' ibge_code from dual union
select 'GO' state_code, 'PETROLINA DE GOIAS' city_code, '5216809' ibge_code from dual union
select 'GO' state_code, 'PILAR DE GOIAS' city_code, '5216908' ibge_code from dual union
select 'GO' state_code, 'PIRACANJUBA' city_code, '5217104' ibge_code from dual union
select 'GO' state_code, 'PIRANHAS' city_code, '5217203' ibge_code from dual union
select 'GO' state_code, 'PIRENOPOLIS' city_code, '5217302' ibge_code from dual union
select 'GO' state_code, 'PIRES DO RIO' city_code, '5217401' ibge_code from dual union
select 'GO' state_code, 'PLANALTINA' city_code, '5217609' ibge_code from dual union
select 'GO' state_code, 'PONTALINA' city_code, '5217708' ibge_code from dual union
select 'GO' state_code, 'PORANGATU' city_code, '5218003' ibge_code from dual union
select 'GO' state_code, 'PORTEIRAO' city_code, '5218052' ibge_code from dual union
select 'GO' state_code, 'PORTELANDIA' city_code, '5218102' ibge_code from dual union
select 'GO' state_code, 'POSSE' city_code, '5218300' ibge_code from dual union
select 'GO' state_code, 'PROFESSOR JAMIL' city_code, '5218391' ibge_code from dual union
select 'GO' state_code, 'QUIRINOPOLIS' city_code, '5218508' ibge_code from dual union
select 'GO' state_code, 'RIALMA' city_code, '5218607' ibge_code from dual union
select 'GO' state_code, 'RIANAPOLIS' city_code, '5218706' ibge_code from dual union
select 'GO' state_code, 'RIO QUENTE' city_code, '5218789' ibge_code from dual union
select 'GO' state_code, 'RIO VERDE' city_code, '5218805' ibge_code from dual union
select 'GO' state_code, 'RUBIATABA' city_code, '5218904' ibge_code from dual union
select 'GO' state_code, 'SANCLERLANDIA' city_code, '5219001' ibge_code from dual union
select 'GO' state_code, 'SANTA BARBARA DE GOIAS' city_code, '5219100' ibge_code from dual union
select 'GO' state_code, 'SANTA CRUZ DE GOIAS' city_code, '5219209' ibge_code from dual union
select 'GO' state_code, 'SANTA FE DE GOIAS' city_code, '5219258' ibge_code from dual union
select 'GO' state_code, 'SANTA HELENA DE GOIAS' city_code, '5219308' ibge_code from dual union
select 'GO' state_code, 'SANTA ISABEL' city_code, '5219357' ibge_code from dual union
select 'GO' state_code, 'SANTA RITA DO ARAGUAIA' city_code, '5219407' ibge_code from dual union
select 'GO' state_code, 'SANTA RITA DO NOVO DESTINO' city_code, '5219456' ibge_code from dual union
select 'GO' state_code, 'SANTA ROSA DE GOIAS' city_code, '5219506' ibge_code from dual union
select 'GO' state_code, 'SANTA TEREZA DE GOIAS' city_code, '5219605' ibge_code from dual union
select 'GO' state_code, 'SANTA TEREZINHA DE GOIAS' city_code, '5219704' ibge_code from dual union
select 'GO' state_code, 'SANTO ANTONIO DA BARRA' city_code, '5219712' ibge_code from dual union
select 'GO' state_code, 'SANTO ANTONIO DE GOIAS' city_code, '5219738' ibge_code from dual union
select 'GO' state_code, 'SANTO ANTONIO DO DESCOBERTO' city_code, '5219753' ibge_code from dual union
select 'GO' state_code, 'SAO DOMINGOS' city_code, '5219803' ibge_code from dual union
select 'GO' state_code, 'SAO FRANCISCO DE GOIAS' city_code, '5219902' ibge_code from dual union
select 'GO' state_code, 'SAO JOAO DA PARAUNA' city_code, '5220058' ibge_code from dual union
select 'GO' state_code, 'SAO JOAO D''ALIANCA' city_code, '5220009' ibge_code from dual union
select 'GO' state_code, 'SAO LUIS DE MONTES BELOS' city_code, '5220108' ibge_code from dual union
select 'GO' state_code, 'SAO LUIZ DO NORTE' city_code, '5220157' ibge_code from dual union
select 'GO' state_code, 'SAO MIGUEL DO ARAGUAIA' city_code, '5220207' ibge_code from dual union
select 'GO' state_code, 'SAO MIGUEL DO PASSA QUATRO' city_code, '5220264' ibge_code from dual union
select 'GO' state_code, 'SAO PATRICIO' city_code, '5220280' ibge_code from dual union
select 'GO' state_code, 'SAO SIMAO' city_code, '5220405' ibge_code from dual union
select 'GO' state_code, 'SENADOR CANEDO' city_code, '5220454' ibge_code from dual union
select 'GO' state_code, 'SERRANOPOLIS' city_code, '5220504' ibge_code from dual union
select 'GO' state_code, 'SILVANIA' city_code, '5220603' ibge_code from dual union
select 'GO' state_code, 'SIMOLANDIA' city_code, '5220686' ibge_code from dual union
select 'GO' state_code, 'SITIO D''ABADIA' city_code, '5220702' ibge_code from dual union
select 'GO' state_code, 'TAQUARAL DE GOIAS' city_code, '5221007' ibge_code from dual union
select 'GO' state_code, 'TERESINA DE GOIAS' city_code, '5221080' ibge_code from dual union
select 'GO' state_code, 'TEREZOPOLIS DE GOIAS' city_code, '5221197' ibge_code from dual union
select 'GO' state_code, 'TRES RANCHOS' city_code, '5221304' ibge_code from dual union
select 'GO' state_code, 'TRINDADE' city_code, '5221403' ibge_code from dual union
select 'GO' state_code, 'TROMBAS' city_code, '5221452' ibge_code from dual union
select 'GO' state_code, 'TURVANIA' city_code, '5221502' ibge_code from dual union
select 'GO' state_code, 'TURVELANDIA' city_code, '5221551' ibge_code from dual union
select 'GO' state_code, 'UIRAPURU' city_code, '5221577' ibge_code from dual union
select 'GO' state_code, 'URUACU' city_code, '5221601' ibge_code from dual union
select 'GO' state_code, 'URUANA' city_code, '5221700' ibge_code from dual union
select 'GO' state_code, 'URUTAI' city_code, '5221809' ibge_code from dual union
select 'GO' state_code, 'VALPARAISO DE GOIAS' city_code, '5221858' ibge_code from dual union
select 'GO' state_code, 'VARJAO' city_code, '5221908' ibge_code from dual union
select 'GO' state_code, 'VIANOPOLIS' city_code, '5222005' ibge_code from dual union
select 'GO' state_code, 'VICENTINOPOLIS' city_code, '5222054' ibge_code from dual union
select 'GO' state_code, 'VILA BOA' city_code, '5222203' ibge_code from dual union
select 'GO' state_code, 'VILA PROPICIO' city_code, '5222302' ibge_code from dual
; 

l_state_id number;
begin
   --
   for i in cidades loop
      --
      begin
         select state_id
         into l_state_id
         from apps.cll_f189_states
         where 1 = 1
           and state_code = i.state_code;
      exception
         when others then
            raise_application_error(-200001,'Erro ao pesquisar state_id '||i.state_code);
      end;
      --
      begin
         insert into apps.cll_f189_cities(city_id,    --1
                                state_id,             --2
                                city_code,            --3
                                iss_tax_type,         --4
                                iss_validation_type,  --5
                                iss_tax,              --6
                                creation_date,        --7
                                created_by,           --8
                                last_update_date,     --9
                                last_updated_by,      --10
                                last_update_login,    --11
                                ibge_code,            --12
                                fiscal_obligation_iss, --13
                                attribute20            --14
                                )
                                values (cll_f189_cities_s.nextval, --1
                                        l_state_id,                --2
                                        i.city_code,               --3
                                        'NORMAL',                  --4
                                        'ROUND',                   --5
                                        5,                         --6
                                        sysdate,                   --7
                                        -1,                        --8
                                        sysdate,                   --9
                                        -1,                        --10
                                        -1,                        --11
                                        i.ibge_code,               --12
                                        'N',                       --13
                                        '323419'                   --14
                                        );
      exception
         when dup_val_on_index then
            null;
         when others then
            raise_application_error(-20001,'Erro ao inserir cidade '||i.city_code||' - '||sqlerrm);
      end;
      --
   end loop;
   --
end;