CREATE OR REPLACE PACKAGE BODY APPS."XX_EXTRACTOR_CONTROL" as

 procedure periodos (errbuf OUT varchar2,
                     retcode OUT number,
                     p_periodo_desde IN varchar2,
                     p_periodo_hasta IN varchar2,
                     p_status IN varchar2) IS

  l_period_num_from number;
  l_period_num_to number;
  l_period_year_from number;
  l_period_year_to number;



 begin


    SELECT period_num, period_year
    INTO l_period_num_from, l_period_year_from
    FROM gl_periods
    WHERE period_name = p_periodo_desde;


    SELECT period_num, period_year
    INTO l_period_num_to, l_period_year_to
    FROM gl_periods
    WHERE period_name = p_periodo_hasta;

    UPDATE xx_hyp_periodos
       SET status = p_status
     where period_num between l_period_num_from and l_period_num_to
       and period_year between l_period_year_from and l_period_year_to;

    insert into xx_hyp_periodos_log values (fnd_global.user_id, p_periodo_desde,p_periodo_hasta, p_status, sysdate);


    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,'Se abrieron/cerraron los periodos de Hyperion exitosamente.');
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------');

 exception
   when others THEN
     fnd_file.put_line(fnd_file.log,'Error, no fue posible abrir/cerrar periodos. Error:'||sqlerrm);

 end;

 procedure consulta_periodo (errbuf OUT varchar2,
                     retcode OUT number,
                     p_periodo varchar2,
                     p_criterio IN varchar2) is
  -- se mantiene para la consulta de periodos anteriores al nuevo extractor

  TYPE outype IS REF CURSOR;
  l_out outype;
  l_reg varchar2(20000);
  l_periodo varchar2(10);

 begin


    --Generando Salida OPERFULL Y IFRSFA
    IF p_criterio IS NOT NULL THEN
        OPEN l_out FOR 'select ''!Data'' from dual registro
                        UNION
                        select escenario||'';''||ano||'';''||mes||'';''||v||'';''||cia||'';''||moneda||'';''||cuenta||'';''||cia_interco||'';''||ctro_costo||'';''||
                        unidad_producto||'';''||proyecto||'';''||unidad_productiva||'';''|| sum(importe) registro
                        from bolinf.xx_extractor_'||replace(p_periodo,'-','_')
                        ||' where sob in (select ledger_id from gl_ledgers where attribute2 = '''||p_criterio||''')
                        group by escenario,ano,mes,v,cia,moneda,cuenta,cia_interco,ctro_costo,unidad_producto,proyecto,unidad_productiva';
    ELSE
        OPEN l_out FOR 'select ''!Data'' from dual registro
                        UNION
                        select escenario||'';''||ano||'';''||mes||'';''||v||'';''||cia||'';''||moneda||'';''||cuenta||'';''||cia_interco||'';''||ctro_costo||'';''||
                        unidad_producto||'';''||proyecto||'';''||unidad_productiva||'';''|| sum(importe) registro
                        from bolinf.xx_extractor_'||replace(p_periodo,'-','_')|| '
                        group by escenario,ano,mes,v,cia,moneda,cuenta,cia_interco,ctro_costo,unidad_producto,proyecto,unidad_productiva';
    END IF;


    LOOP
       FETCH l_out INTO l_reg;
       EXIT WHEN l_out%NOTFOUND;
       fnd_file.put_line(fnd_file.output,l_Reg);
    END LOOP;


 exception
   when others THEN
     fnd_file.put_line(fnd_file.log,'Error, no fue posible realizar la consulta. Error:'||sqlerrm);
 end;

procedure refundicion(errbuf    OUT varchar2,
                      retcode   OUT number,
                      p_periodo IN varchar2) IS

l_per_dic     varchar2(10);
periodo_erroneo     exception;
begin
   fnd_file.put_line(fnd_file.log,'  ');
    fnd_file.put_line(fnd_file.log,'  ');
    fnd_file.put_line(fnd_file.log,'-----PROCESO DE REFUNDICION DE EXTRACTOR --------------------');

   IF p_periodo not like 'AJU%' THEN
               RAISE periodo_erroneo;
   end if;

   l_per_dic := 'DIC-' || to_char(to_number(substr(p_periodo,6,2)) - 1);

   --Borro datos de la tabla auxiliar
    execute immediate 'TRUNCATE TABLE BOLINF.XX_EXTRACTOR_BAL_WT';
    --Insert las lineas reversadas de cuentas patrimoniales y resultado
   --para cuentas patrimoniales se multiplica el importe por -1

      insert into BOLINF.XX_EXTRACTOR_BAL_WT  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                              SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
               select 'PAT1', escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))*-1
                from bolinf.XX_EXTRACTOR_BAL_HIS
                 where period_name =  l_per_dic
                    and escenario= 'Real'
                    and to_number(segment2) between 100000 and 399999
                    and to_number(segment1) not between 150 and 199
                    and to_number(segment1) not between 250 and 299
                    and to_number(segment1) not between 350 and 399
                    group by segment1, escenario, contexto;
      fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT Ctas patrimoniales unificadas por cia: '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

      insert into BOLINF.XX_EXTRACTOR_BAL_WT  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                  select 'RDO', escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))
                  from bolinf.XX_EXTRACTOR_BAL_HIS
                  where period_name = l_per_dic
                     and escenario='Real'
                     and  to_number(segment2) between 400000 and 899999
                     and segment2  not in ('519001','519198','519199','543451','543452','543456','543998','543999','575001','575002','575003','575006','575998','575999','790002','790005' )
                     and (to_number(segment1) between 150 and 199
                              or to_number(segment1) between 250 and 299
                               or to_number(segment1) between 350 and 399)
                    group by segment1, escenario,contexto;
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT Resultado unificadas por cia : '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

 

     --Inserto los saldos de las cuentas patrimoniales
        insert into BOLINF.XX_EXTRACTOR_BAL_WT  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                 select 'PAT2', escenario,contexto, p_periodo, segment1, segment2, SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,SEGMENT6 ,  SEGMENT7,  SEGMENT8, nvl(saldo,0)
                 from bolinf.XX_EXTRACTOR_BAL_HIS
                 where period_name = l_per_dic
                    and  segment2 between  '100000' and '399999';
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT patrimoniales: '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

     -- Cambio SD #cambio 1926 #tkt 11520       
     insert into BOLINF.XX_EXTRACTOR_BAL_WT  (origen, escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
SELECT tipo,
       escenario,
       contexto,
       periodo,
       cia_ajuste,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       SUM (saldo)
  FROM (SELECT 'HYP' tipo,
               'Real' escenario,
               contexto,
               p_periodo  periodo, segment1 cia_ajuste
             , '330003' segment2, '00' segment3,'000' segment4,'00000' segment5,'0000' segment6,'000000' segment7,'0' segment8, SUM(NVL(saldo,0)) saldo
                  from bolinf.XX_EXTRACTOR_BAL_HIS bal
                  where period_name  = l_per_dic
                     and escenario='Real_IFRS'
                     --and contexto = 'UR'
                     and  TO_NUMBER(segment2) between 400000 and 899999
                     and segment2  in ('519001','519198','519199','543451','543452','543456','543998','543999','575001','575002','575003','575006','575998','575999','790002','790005' )
                     and (TO_NUMBER (segment1) between 150 and 199
                              or TO_NUMBER(segment1) between 250 and 299
                               or TO_NUMBER(segment1) between 350 and 399)
                    group by segment1, escenario,contexto
UNION
                  select 'HYP', 'Real',contexto, p_periodo , NVL(  (SELECT a.attribute2
                  FROM fnd_flex_values a, fnd_flex_value_Sets b
                 WHERE     flex_value_Set_name = 'XX_GL_COMPANIA'
                       AND a.flex_Value_Set_id = b.flex_Value_Set_id
                       AND a.flex_value = bal.segment1) , segment1) cia_ajuste , '330003', '00','000','00000','0000','000000','0', SUM(NVL(saldo,0)) * (-1)
                  from bolinf.XX_EXTRACTOR_BAL_HIS bal
                  where period_name = l_per_dic
                     and escenario='Real'
                   --  and contexto = 'UR'
                    -- and  to_number(segment2) between 400000 and 899999
                     and segment2  in ('519001','519198','519199','543451','543452','543456','543998','543999','575001','575002','575003','575006','575998','575999','790002','790005' )
                     and (TO_NUMBER (segment1) NOT between 150 and 199
                              or TO_NUMBER(segment1) NOT between 250 and 299
                               or TO_NUMBER(segment1) NOT between 350 and 399)
                    group by segment1, escenario,contexto)
group by tipo, escenario, contexto, periodo, cia_ajuste, segment2,segment3, segment4, segment5, segment6, segment7, segment8;

--Inserto los saldos finales
       insert into BOLINF.XX_EXTRACTOR_BAL_WT  (origen, escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                select  'TOT', escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                                SEGMENT6 ,  SEGMENT7,  SEGMENT8, sum(saldo)
                            from BOLINF.XX_EXTRACTOR_BAL_WT
                group by escenario, contexto,  period_name, SEGMENT1,SEGMENT2,SEGMENT3,SEGMENT4,SEGMENT5,SEGMENT6,SEGMENT7,SEGMENT8
                having sum(saldo) <> 0    ;
                
                

--insert into XX_EXTRACTOR_BAL_WT_TMP select * from XX_EXTRACTOR_BAL_WT;

--select * from XX_EXTRACTOR_BAL_WT_TMP
--where segment1='351'

  fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT reg.Totales:  '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
  COMMIT;
  xx_extractor_bal.actualiza_historica (p_periodo, null, sysdate); -- actualiza todos los criterios
COMMIT;
  fnd_file.put_line(fnd_file.log,'----------------------');
  fnd_file.put_line(fnd_file.log,'Refundicion OK  ------');
  fnd_file.put_line(fnd_file.log,'----------------------');

exception

   when periodo_erroneo then
     fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------------');
     fnd_file.put_line(fnd_file.log,'Error: la refundicion debe hacerse solo sobre el periodo AJU1');
     fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------------');
 when others then
   fnd_file.put_line(fnd_file.log,'Error en proceso de refundicion, err:'||sqlerrm);
   dbms_output.put_line('Error en proceso de refundicion, err:'||sqlerrm);
end;

procedure refundicion_AXI_IFRS(errbuf    OUT varchar2,
                      retcode   OUT number,
                      p_periodo IN varchar2) IS

l_per_dic     varchar2(10);
periodo_erroneo     exception;
begin
   fnd_file.put_line(fnd_file.log,'  ');
    fnd_file.put_line(fnd_file.log,'  ');
    fnd_file.put_line(fnd_file.log,'-----PROCESO DE REFUNDICION DE EXTRACTOR AXI IFRS --------------------');

   IF p_periodo not like 'AJU%' THEN
               RAISE periodo_erroneo;
   end if;

   l_per_dic := 'DIC-' || to_char(to_number(substr(p_periodo,6,2)) - 1);

   --Borro datos de la tabla auxiliar
    execute immediate 'TRUNCATE TABLE BOLINF.XX_EXTRACTOR_BAL_WT_AXI';
    --Insert las lineas reversadas de cuentas patrimoniales y resultado
   --para cuentas patrimoniales se multiplica el importe por -1

--      insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
--                                                                              SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
--               select 'PAT1', escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))*-1
--                from bolinf.XX_EXTRACTOR_BAL_HIS_AXI
--                 where period_name =  l_per_dic
--                    and escenario= 'Real_AxI'
--                    and to_number(segment2) between 100000 and 399999
--                    group by segment1, escenario, contexto;
      fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI Ctas patrimoniales unificadas por cia: '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

      insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                  select 'RDO', escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))
                  from bolinf.XX_EXTRACTOR_BAL_HIS_AXI
                  where period_name = l_per_dic
                     and escenario='Real_AxI'
                     and  to_number(segment2) between 400000 and 899999
                     and segment2  not in ('519001','519198','519199','543451','543452','543456','543998','543999','575001','575002','575003','575006','575998','575999','790002','790005' )
                    group by segment1, escenario,contexto;
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI Resultado unificadas por cia : '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

     --Inserto los saldos de las cuentas patrimoniales
        insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                 select 'PAT2', escenario,contexto, p_periodo, segment1, segment2, SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,SEGMENT6 ,  SEGMENT7,  SEGMENT8, nvl(saldo,0)
                 from bolinf.XX_EXTRACTOR_BAL_HIS_AXI
                 where period_name = l_per_dic
                    and  segment2 between  '100000' and '399999';
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI patrimoniales: '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

      insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                  select 'HYP', 'Real_AxI' escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))
                  from bolinf.XX_EXTRACTOR_BAL_HIS_AXI
                  where period_name = l_per_dic
                     and escenario='Real_AxI_IFRS'
                     and  to_number(segment2) between 400000 and 899999
                     and segment2   in ('519001','519198','519199','543451','543452','543456','543998','543999','575001','575002','575003','575006','575998','575999','790002' )
                    group by segment1, escenario,contexto;
                    
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI Resultado unificadas por cia : '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));


  --Inserto los saldos finales
       insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI  (origen, escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                select  'TOT', escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                                SEGMENT6 ,  SEGMENT7,  SEGMENT8, sum(saldo)
                            from BOLINF.XX_EXTRACTOR_BAL_WT_AXI
                group by escenario, contexto,  period_name, SEGMENT1,SEGMENT2,SEGMENT3,SEGMENT4,SEGMENT5,SEGMENT6,SEGMENT7,SEGMENT8
                having sum(saldo) <> 0    ;
  fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI reg.Totales:  '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

  COMMIT;
  xx_extractor_bal_axi.actualiza_historica (p_periodo, null, sysdate); -- actualiza todos los criterios

COMMIT;
  fnd_file.put_line(fnd_file.log,'----------------------');
  fnd_file.put_line(fnd_file.log,'Refundicion OK AXI IFRS ------');
  fnd_file.put_line(fnd_file.log,'----------------------');

exception

   when periodo_erroneo then
     fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------------');
     fnd_file.put_line(fnd_file.log,'Error: la refundicion debe hacerse solo sobre el periodo AJU1');
     fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------------');
 when others then
   fnd_file.put_line(fnd_file.log,'Error en proceso de refundicion, err:'||sqlerrm);
   dbms_output.put_line('Error en proceso de refundicion, err:'||sqlerrm);
end;

procedure refundicion_AXI_LOCAL (errbuf    OUT varchar2,
                      retcode   OUT number,
                      p_periodo IN varchar2) IS

l_per_dic     varchar2(10);
periodo_erroneo     exception;
begin
   fnd_file.put_line(fnd_file.log,'  ');
    fnd_file.put_line(fnd_file.log,'  ');
    fnd_file.put_line(fnd_file.log,'-----PROCESO DE REFUNDICION DE EXTRACTOR AXI LOCAL--------------------');

   IF p_periodo not like 'AJU%' THEN
               RAISE periodo_erroneo;
   end if;

   l_per_dic := 'DIC-' || to_char(to_number(substr(p_periodo,6,2)) - 1);

   --Borro datos de la tabla auxiliar
    execute immediate 'TRUNCATE TABLE BOLINF.XX_EXTRACTOR_BAL_WT_AXI_LOC';
    --Insert las lineas reversadas de cuentas patrimoniales y resultado
   --para cuentas patrimoniales se multiplica el importe por -1

--      insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI_LOC  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
--                                                                              SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
--               select 'PAT1', escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))*-1
--                from bolinf.XX_EXTRACTOR_BAL_HIS_AXI_LOC
--                 where period_name =  l_per_dic
--                    and escenario= 'Real_AxI'
--                    and to_number(segment2) between 100000 and 399999
--                    group by segment1, escenario, contexto;
--      fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI_LOC Ctas patrimoniales unificadas por cia: '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

      insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI_LOC  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                  select 'RDO', escenario,contexto, p_periodo, segment1, '330003', '00','000','00000','0000','000000','0', sum(nvl(saldo,0))
                  from bolinf.XX_EXTRACTOR_BAL_HIS_AXI_LOC
                  where period_name = l_per_dic
                     and escenario='Real_AxI'
                     and  to_number(segment2) between 400000 and 899999
      --               and segment2  not in ('519001','519198','519199','543451','543452','543456','543998','543999','575001','575002','575003','575006','575998','575999','790002' )
                     group by segment1, escenario,contexto;
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI_LOC Resultado unificadas por cia : '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

     --Inserto los saldos de las cuentas patrimoniales
        insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI_LOC  (origen, escenario,contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                 select 'PAT2', escenario,contexto, p_periodo, segment1, segment2, SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,SEGMENT6 ,  SEGMENT7,  SEGMENT8, nvl(saldo,0)
                 from bolinf.XX_EXTRACTOR_BAL_HIS_AXI_LOC
                 where period_name = l_per_dic
                    and  segment2 between  '100000' and '399999';
     fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI_LOC patrimoniales: '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

  --Inserto los saldos finales
       insert into BOLINF.XX_EXTRACTOR_BAL_WT_AXI_LOC  (origen, escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                    SEGMENT6 ,  SEGMENT7,  SEGMENT8, saldo)
                select  'TOT', escenario, contexto, period_name, SEGMENT1,  SEGMENT2 ,  SEGMENT3 ,  SEGMENT4 ,  SEGMENT5,
                                                                                                                SEGMENT6 ,  SEGMENT7,  SEGMENT8, sum(saldo)
                            from BOLINF.XX_EXTRACTOR_BAL_WT_AXI_LOC
                group by escenario, contexto,  period_name, SEGMENT1,SEGMENT2,SEGMENT3,SEGMENT4,SEGMENT5,SEGMENT6,SEGMENT7,SEGMENT8
                having sum(saldo) <> 0    ;
  fnd_file.put_line(fnd_file.log,'Poblado de bolinf.XX_EXTRACTOR_BAL_WT_AXI_LOC reg.Totales:  '|| sql%rowcount || ' - ' || To_Char (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
  COMMIT;
  xx_extractor_bal_axi_local.actualiza_historica (p_periodo, null, sysdate); -- actualiza todos los criterios
COMMIT;
  fnd_file.put_line(fnd_file.log,'----------------------');
  fnd_file.put_line(fnd_file.log,'Refundicion OK AXI LOCAL  ------');
  fnd_file.put_line(fnd_file.log,'----------------------');

exception

   when periodo_erroneo then
     fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------------');
     fnd_file.put_line(fnd_file.log,'Error: la refundicion debe hacerse solo sobre el periodo AJU1');
     fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------------');
 when others then
   fnd_file.put_line(fnd_file.log,'Error en proceso de refundicion, err:'||sqlerrm);
   dbms_output.put_line('Error en proceso de refundicion, err:'||sqlerrm);
end;



end;
/
