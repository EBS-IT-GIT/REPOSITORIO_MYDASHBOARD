ALTER SESSION SET NLS_LANGUAGE='LATIN AMERICAN SPANISH';
  set define off;
  
  begin
update mtl_system_items_b set description = 'TRANSIO Q340 X D560' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 22631688 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TRANSIO Q340XD320XH200' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 22631690 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CODO KQL16-04S R1/2-16 ORIENTA BLE 360° SMC' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343664 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:30MM Z13 MASA 20MM PASO 5/8 CHAV. 8MM CON PRIS.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343679 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:25MM Z20 MASA 25MM PASO 5/8 CHAV. 8MM C/PRISONERO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343680 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:25MM Z:20 MASA 25MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343681 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:30MM Z20 MASA 25MM PASO 5/8 CHAV. 8MM C/PRISIONER' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343682 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:25MM Z:15 MASA 20MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343683 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:35MM Z20 MASA 20MM PASO 5/8 CHAV. 8MM C/PRISION.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343684 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:25MM Z20 MASA 20MM PASO 5/8 CHAV. 8MM CON PRISIO.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343685 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:30MM Z:27 MASA 20MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343686 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:25MM Z22 MASA 20MM PASO 5/8 CHAV. 8MM C/PRISION.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343687 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:30MM Z:20 MASA 20MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343688 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:30MM Z30 MASA 20MM PASO 5/8 CHAV. 8MM C/PRISION.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343689 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:28MM Z:23 MASA 20MM PASO 5/8 CHAV. 8' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343690 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ESLABON VF320 CADENA 0 FRIC- CI PARA CINTAS CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343691 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:30MM Z15 MASA 20MM PASO 5/8 CHAVETERO 8MM C/PRISI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343692 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:28MM Z:38 MASA 20MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343693 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONVERSOR RTD PT100 4 A 20mA (0C-150C) P/MONTAJE RIEL DIM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343696 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CEPILLO CIRCULAR MOD. S02-04 DIAM. 200MM. ANCHO 200MM.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343708 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REDUCTOR LENTAX RELACION 33/1 PARA ENCAJONADOR AS2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343784 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REDUCTOR LENTAX RELACION 10/1 PARA CINTA TRANSPORTADORA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343785 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REDUCTOR LENTAX RELACION 20/1 PARA CINTA DE PALETIZADOR N3' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343786 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REDUCTOR LENTAX RELACION 50/1 PARA ENCAJONADOR AS2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343787 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'JUEGO 65004671 CORONA Y PIÑÓN PARA AGITADOR TIPO LP25' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343808 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MODULO TIPO MONEDA, CONVERSOR RTD-PT100 (0-100C)SALIDA 4-20' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25343828 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153048 QSL-1/8-8 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344020 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MÓDULO BLANK 90459-6330 PARA CARBOARD PACKER TETRA PAK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344068 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN MR 12.5 154125 (GEL) PARA CINTAS CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344096 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ANILLO GUARNICIÓN 6-164637101 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344106 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ANILLO GUARNICIÓN 6-164817203 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344107 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'BOMBA HIDRÁULICA 6-4722654102 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344112 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REGULADOR 9100200 NORGEN 11808 /980 1"" PRENSA PK 1300 GADAN' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344160 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REGULADOR 9100203 NORGEN 11400 /2 3/8"" PRENSA PK 1300 GADAN' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344161 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONEXION 90115-0106 PARA FRACCIONADORA TBA 8 TETRA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344173 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONEXION 90115-0107 PARA FRACCIONADORA TBA 8 TETRA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344174 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN ASA 35-Z=9 PARA MESA DE ARMADO CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344215 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN ASA 35-Z=15 P/MESA ARMA- DO DOBLE (MOTRIZ) CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344216 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN ASA 35-Z=15 P/MESA ARMA- DO DOBLE (REENVIO) CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344217 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE CARRO ELEVADOR DE PALETIZADOR' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344231 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 90242-0117 P/FRACCIO- NADORA TBA/8 TETRA PAK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344259 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 315202-0316 PARA FRACCIONADORA TBA/8 TETRA PAK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344261 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CUBETAS ADVANCE N CAT.1280139 EQUIPO ADVANCE Y ADVANCE COUPE' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344472 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153046 TIPO QSL-1/8-6 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344533 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153047 TIPO QSL-1/4-6 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344534 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153049 TIPO QSL-1/4-8 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344535 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153050 TIPO QSL-3/8-8 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344536 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153054 TIPO QSL-1/2-12 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344537 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153055 TIPO QSL-1/2-16 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344538 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONECTOR PISTOLA 9090459-6350 P/CARBOARD PACKER TETRA PACK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344599 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ESTATOR <E236> 103, NBR+A.C. BORNEMANN PARTE 0100110313500' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344642 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'SENSOR PRESIÖN 90274-0044 PARA FRACCIONADORA TBA 8 TETRA PAK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344686 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'KIT REPARACION 90450-0634 PARA FRACCIONADORA TBA 8 TETRA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344697 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN MOTRIZ ASA 40 -Z14 SEGUN PLANO CP0193003 PARA CINTAS' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344722 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'WIPER RA72 (GEL) PARA CINTAS CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344725 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'GUIA LINEAL 903606 A3080X2000 (GEL)PARA CINTAS CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344726 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CREMALLERA 903600 A3080X2000 (GEL)PARA CINTAS CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344727 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 315202-0309 PARA FRACCIONADORA TBA/8 TETRA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344778 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'HOJA LIJA AL AGUA Nro. 100' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344792 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'HOJA TELA ESMERIL Nro. 60 TIPO JX-91 MARCA DOBLE ""A"".-' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344793 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'HOJA LIJA AL AGUA Nro. 320' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344794 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ADHESIVO LOCTITE 640 PARA FIJACION DE RODAMIENTOS.-' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344801 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 315202-0731 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344806 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 6-4723137008 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344807 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 90512-3845 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344808 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 6-4723137006 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344809 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 6-4723137015 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344810 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING 6-4723137034 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344811 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING INDICADOR 6-4723010201 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344812 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'SEPARADOR METAL. 6-4722708901 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344818 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TRANSMISOR TMT181-A31BA / 0...150C ENDRESS HAUSER' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344850 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MANOVACUOMETRO DE BAJA 12 KG. 0-76LBS D.100MM BA GLICERINA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344903 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN 32-AS21497 PARA SACHETA- DORA PREPAC AS2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344923 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RODAMIENTO UC FL 204 E DE BRI- DA FUNDICI ACERO PAG. 10-113' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344959 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TRANSMISOR TEMP. 90510-5632 0 /150 P/HOMOGENIZADOR TKA A3' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344978 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MOTORREDUCTOR STM MOD. RMI 150 FL RELACION 1/100, EJE HUECO,' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345150 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REDUCTOR STM MOD. RI 150 FL RELACION 1/100, EJE HUECO,' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345152 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'VÁLVULA BSA1T DN80 3"" PN16 MARCA SPIRAX SARCO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345194 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'VÁLVULA BSA1T DN32 1.1/4"" PN16 MARCA SPIRAX SARCO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345197 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIEZA FIJACIÓN 26760-0000 PARA FRACCIONADORA TBA 8 TETRA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345224 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONEXION 342980-0114 PARA FRA- CIONADORA TBA 8 TETRA PAK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345228 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PATIN 162219420 SNS TAMA 15 BOSCH PARA ROBOT KUKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345255 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'O''RING SILICONA 1.6MM X DIAM. 14.5MM PARA PREPAC AS2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345285 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN 32/AS20601 PLASTICO MA- QUINA SACHETADORA PREPAC AS2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345289 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MANCH 90459-2318 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345351 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MANCH METÁLICO 6-4722755001 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345352 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MANGUERA 23830110 FLEXIBLE LG CAÑERIA IGNICION DE GAS' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345395 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'FLEX SISAFLEX 23830140 1/2"" M L=700 MM CAÑERIA DE GAS' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345396 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONVERSOR TIPO MONEDA ENT. RTD PT100 (0-100C) SAL.4-20mA CCG' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345446 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 190659 QSL-1/4-4 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345601 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN 224513 HELICOIDAL TINA QUESERA DAMROW' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345692 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'FRECUENCIOMETRO 0005-3582-700 MODELO FR4D DESN.WESTFALIA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345707 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TAPONES SILICONADOS P/TOMAMUES TRA SEGUN PLANO N000' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345711 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MANOMETRO 19050410 DIAM. 63 MM O-40BAR 6LYC 1/4"" P/CAÑERIA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345743 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153053 QSL-3/8-12 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345772 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 164981 QSL-1/4-12 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345780 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'INTERRUPTOR DE POSICION COD ZCK D 54 TELEMECANIQUE' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345799 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'SELLO TRI-CLOVER 6-298456 BUNA 40MP-U N4 PARA TINA TETRAPACK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345837 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'MANOMETRO 19050390 ETRIER D=63 MM 0-16 BAR P/CAÑERIA ACEITE' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345903 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REGULADOR 19760450 DUNGS FRS50 5BLEU 1/2"" 10-30 MB CARIA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345905 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'REGULADOR 19780640 DN70 CARRE 128 HI 90 P/CARIA DE GAS' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345907 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN CINTA ESPACIADORA EJE D: 30MM Z:17 MASA 22MM PASO 1/2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345939 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN 5390310682 P/ENVOLVEDOR ROBOPACK  CONSTANTINI' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345942 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN 5390310681 PARA ENVOLVED OR ROBOPACK CONSTANTIN' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345947 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:28MM Z:28 MASA 20MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345950 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN EJE D:30MM Z22 MASA 20MM PASO 5/8 CHAV. 8MM C/PRISION.' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345951 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'PIÑÓN REDUCTOR EJE D:28MM Z:22 MASA 20MM PASO 5/8 CHAV. 8MM' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345952 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TRANSMISOR DE SEÑAL 1M 0-150G ENT. PT100 A 4-20MA MARCA CCG' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345953 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TRANSMISOR DE SEÑAL 1M 0-100G ENT.PT100 A 4-20MA  MARCA CCG' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25345967 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'CONVERTIDOR 90510-5622 PT100 MA 0-160 P/TETRA THERN FLEX' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346024 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RELE DEK-REL INTERFASE 24V. 1A PHIX' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346075 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ACEITE KLUBER HYSYN FG 32 HIDRAÚLICO P/ENVASADORA A3' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346123 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR RAPIDO EN L ROSCADO N 153045 TIPO QSL-1/8-4 FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346271 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR RAPIDO ROSCADO N153001 TIPO QS-1/8-4 FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346272 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ESTRANGULADOR N10352 TIPO GRE 1/4 MARCA FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346274 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'TAPON CIEGO N3568 TIPO B-1/8 PARA FRACCIONADORA AS-2' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346276 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR RAPIDO ROSCADO N164980 TIPO QS-1/4-12 FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346281 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'RACOR 153051 QSL-1/4-10 EN L ORIENTABLE 360° FESTO' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346282 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'JUNTA TICA 6-99032241 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346348 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'JUNTA TICA 6-99035344 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346349 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'JUNTA TICA 6-99035338 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346350 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'JUNTA TICA 6-99035373 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346351 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ESTRELLA MANCH 6-4722755101 PARA HOMOGENIZADOR TKA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346359 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'VALVULA 13161000 ESFERICA SIRA L V1000 1/2"" P/CAÑERIA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346391 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'VALVULA 13161300 PN10 432564 AR68 1/2"" P/CAÑERIA DE GAS' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346392 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'ELECTROVALVULA 13561340 SHH210 NVS CAÑERIA GAS PRECALENT.AIRE' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346396 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'UNION 753404 GIRATORIA CARIA CENTRAL HIDRAULICA PARA PRENSA' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25346405 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'Crochet Para Cosedora YAO HAN F920A- Cód. 9000616' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 26451669 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);
update mtl_system_items_b set description = 'SENSOR PRESIÓN 90274-0044 PARA FRACCIONADORA TBA 8 TETRA PAK' ,last_update_date = sysdate
   , last_updated_by = 2070  where inventory_item_id = 25344686 and organization_id in (select organization_id from org_organization_definitions where organization_name like '% AR %' union select 135 from dual);


END;                                    
/


exit
