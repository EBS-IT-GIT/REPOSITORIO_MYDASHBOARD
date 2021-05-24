DECLARE 

CURSOR c_ordens IS 

    SELECT haou.NAME             org_name
      ,    haou.organization_id  
      ,    pha.po_header_id
      ,    pha.segment1          order_num 
      ,    pha.type_lookup_code 
      ,    pha.authorization_status  
      ,    pha.closed_date
      ,    pha.closed_code 
      ,    tab.ticket
      FROM apps.hr_all_organization_units                haou
      ,    apps.po_headers_all                           pha
      ,   (  SELECT 'UO_0102057_OOG OPERACAO'        ORG,'33871'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103015_OOG NORBE VI'        ORG,'35232'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103020_ODN II MACAE'        ORG,'30222'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103020_ODN II MACAE'        ORG,'30467'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29600'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29601'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29777'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29778'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29809'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29826'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29858'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'29953'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30001'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30130'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30138'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1407'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1408'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1409'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1410'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1411'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1419'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1420'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1421'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1422'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1423'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1424'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1425'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1435'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1436'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1437'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1438'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1439'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1440'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1441'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1442'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1459'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1460'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1472'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1473'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1516'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1520'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1529'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1530'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1531'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1532'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1533'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1534'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1541'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1581'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1582'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1583'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1584'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1585'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1586'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1587'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1588'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1589'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1595'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1596'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1597'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1598'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_2803010_ODN VI'        ORG,'1687'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103015_OOG NORBE VI'        ORG,'36901'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103015_OOG NORBE VI'        ORG,'37066'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103015_OOG NORBE VI'        ORG,'37068'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103015_OOG NORBE VI'        ORG,'37205'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30236'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30237'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30238'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30260'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103026_OOG DELBA III'        ORG,'30287'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0102081_DS HB'        ORG,'307'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35221'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35222'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35223'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35224'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35226'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35227'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35228'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35229'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35258'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'35316'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'33467'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'33499'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'33500'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'33501'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103019_ODN I MACAE'        ORG,'33502'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37373'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37375'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37377'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37380'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'36571'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37033'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37038'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37039'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37044'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37059'        ORDEM,182158        TICKET        FROM DUAL UNION ALL
SELECT 'UO_0103017_OOG NORBE IX'        ORG,'37138'        ORDEM,182158        TICKET        FROM DUAL  )TAB
     WHERE haou.NAME                          = tab.org
           AND haou.organization_id           = pha.org_id
           AND pha.segment1                   = tab.ordem
           AND nvl(pha.cancel_flag, 'N')     != 'Y'
    ORDER BY pha.authorization_status;
               
CURSOR c_lines (p_po_header_id NUMBER)IS 

        SELECT phl.po_line_id  
          ,    phl.closed_code close_line
          ,    phl.closed_date close_date_line
          ,    phl.closed_reason closed_reason_line
          ,    phl.closed_by      close_by_line
          FROM apps.po_lines_all    phl
         WHERE phl.po_header_id             = p_po_header_id
           AND nvl(phl.cancel_flag, 'N')   != 'Y'; 
            
CURSOR c_locations (p_po_line_id NUMBER) IS 
        
        SELECT pll.line_location_id
          ,    pll.closed_code    close_code_location
          ,    pll.closed_reason  close_reason_location
          ,    pll.closed_date    close_date_location
          ,    pll.closed_by      close_by_location
          ,    pll.shipment_closed_date
          ,    pll.closed_for_receiving_date
          ,    pll.closed_for_invoice_date
          FROM apps.po_line_locations_all pll
         WHERE po_line_id = p_po_line_id;


    v_user_id NUMBER; 
    v_application_id NUMBER;
    v_responsibility_id NUMBER;
    v_reason varchar2(40);
    
BEGIN 
    
    BEGIN 
        SELECT user_id
          INTO v_user_id
          FROM fnd_user
         WHERE 1 = 1
           AND user_name = 'TM_RODRIGOCAMARGO'
           AND end_date IS NULL; 
        EXCEPTION 
           WHEN NO_DATA_FOUND THEN 
                RAISE_APPLICATION_ERROR(-20001, 'LOGIN NAO LOCALIZADO');           
    END;
    --
     BEGIN 
        SELECT frl.application_id
            ,  frl.responsibility_id 
          INTO v_application_id
           ,   v_responsibility_id
          FROM fnd_responsibility_tl        frl
          ,    fnd_responsibility           fr
         WHERE 1 = 1
           AND frl.responsibility_id = fr.responsibility_id
           AND responsibility_name   = 'EBS_SUP_CONFIG_PO'
           AND LANGUAGE = 'PTB'
           AND trunc(SYSDATE) BETWEEN start_date
                                  AND nvl(end_date, trunc(SYSDATE));  
        EXCEPTION 
           WHEN NO_DATA_FOUND THEN 
                RAISE_APPLICATION_ERROR(-20010, 'RESP NAO LOCALIZADO');           
    END;
    --     
    fnd_global.apps_initialize(user_id => v_user_id 
                                         ,resp_id => v_responsibility_id
                                         ,resp_appl_id => v_application_id);
                                         
    v_reason := 'TICKET - 0182158';       
    --                              
    FOR l_ordens IN c_ordens LOOP         
        --dbms_output.put_line ('Organization -> '||l_ordens.org_name ||' Ordem -> '|| l_ordens.order_num);
        IF nvl(l_ordens.closed_code, 'OPEN') != 'CLOSED' THEN
        
            FOR l_lines IN c_lines (l_ordens.po_header_id) LOOP  
                --
                IF nvl(l_lines.close_line, 'OPEN') != 'CLOSED' THEN 
                 
                    FOR l_locations IN c_locations (l_lines.po_line_id) LOOP 
                    
                        IF nvl(l_locations.close_code_location, 'OPEN') != 'CLOSED' THEN 
                        
                            UPDATE apps.po_line_locations_all
                               SET closed_code = 'CLOSED'
                               ,   closed_reason = v_reason||l_ordens.chamado
                               ,   closed_date   = SYSDATE 
                               ,   closed_by     = v_user_id
                               ,   shipment_closed_date      = SYSDATE 
                               ,   closed_for_receiving_date = SYSDATE 
                               ,   closed_for_invoice_date   = SYSDATE 
                             WHERE line_location_id = l_locations.line_location_id;
                        COMMIT;         
                        END IF; --locations
                      --COMMIT;
                    END LOOP l_locations; 
                    --
                    UPDATE apps.po_lines_all
                       SET closed_code = 'CLOSED'
                        ,  closed_date = SYSDATE 
                        ,  closed_reason = v_reason||l_ordens.chamado
                        ,  closed_by     = v_user_id  
                     WHERE po_line_id = l_lines.po_line_id;  
                COMMIT;
                END IF; --lines  
              --COMMIT;            
            END LOOP l_lines; 
            --
            UPDATE apps.po_headers_all
                  SET closed_code = 'CLOSED'
                 ,    closed_date = SYSDATE 
                WHERE po_header_id = l_ordens.po_header_id;
        COMMIT;     
        END IF; --headers
       
    END LOOP l_ordens; 
    --COMMIT; 
END;

