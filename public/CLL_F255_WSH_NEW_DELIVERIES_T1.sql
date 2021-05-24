CREATE OR REPLACE TRIGGER APPS."CLL_F255_WSH_NEW_DELIVERIES_T1"
AFTER INSERT OR UPDATE OR DELETE ON "WSH"."WSH_NEW_DELIVERIES#"
FOR EACH ROW
WHEN (
new.status_code = 'CL'
      )
DECLARE
  --
  l_module_name      CONSTANT VARCHAR2(100) := 'CLL_F255_WSH_NEW_DELIVERIES_T1';
  l_key              VARCHAR2(240);
  l_transaction_type VARCHAR2(10);
  l_profile          VARCHAR2(1):=  NVL(FND_PROFILE.VALUE('CLL_F255_ENABLE_BES'),'N');
  l_event_name       VARCHAR2(240) := 'oracle.apps.cll.wsh_new_deliveries';
  l_count            NUMBER;
  l_retcode          NUMBER;
  l_errbuf           VARCHAR2(4000);

BEGIN
    -- actualizacion de xx_inv_remitos_impresos
    -- CR2164  Actualiza el carrier_service_id en xx_inv_remitos_impresos,  se incorporo el frieght_code ago-2020
           update xx_inv_remitos_impresos xiri set (xiri.carrier_service_id, xiri.freight_code) = (
                          SELECT carrier_service_id, wca.freight_code
                            FROM wsh_carrier_services wcs,    wsh_carriers wca
                          WHERE wcs.carrier_id = :NEW.carrier_id
                              AND wcs.mode_of_transport = :NEW.mode_of_transport
                              AND wcs.service_level = :NEW.service_level
                               and wca.carrier_id = wcs.carrier_id)
              where xiri.group_id = :NEW.delivery_id
              and  xiri.source_table = 'WSH_NEW_DELIVERIES' ;

            -- Fin CR2164
/* $Header: CLLBETWN.sql 120.5 2015/08/05 18:36:45 cacasant noship $ */
  IF l_profile = 'Y' THEN
    --
    IF cll_f255_business_events_pkg.exist_subscription( l_event_name ) = 'N' THEN
      RETURN;
    END IF;
    --
    IF INSERTING THEN
      l_transaction_type := 'INSERT';
    ELSIF UPDATING THEN
      l_transaction_type := 'UPDATE';
    ELSIF DELETING THEN
      l_transaction_type := 'DELETE';
    END IF;
    --
    l_key := TO_CHAR(NVL(:new.delivery_id,:old.delivery_id))||'-'||TO_CHAR(SYSTIMESTAMP, 'DD-MM-YYYY HH24:MM:SS:FF');
    --
    cll_f255_business_events_pkg.raise( p_event_name => l_event_name,
                                        p_event_key => l_key,
                                        p_parameter_name1  => 'TABLE_NAME',
                                        p_parameter_value1 => 'WSH_NEW_DELIVERIES',
                                        p_parameter_name2  => 'TRANSACTION_TYPE',
                                        p_parameter_value2 => l_transaction_type,
                                        p_parameter_name3  => 'DELIVERY_ID',
                                        p_parameter_value3 => NVL(:new.delivery_id, :old.delivery_id),
                                        p_parameter_name4  => 'NAME',
                                        p_parameter_value4 => NVL(:new.name, :old.name),
                                        p_parameter_name5  => 'STATUS_CODE', --BUG 9278993
                                        p_parameter_value5 => NVL(:new.status_code, :old.status_code), --BUG 9278993
                                        p_parameter_name6  => 'ORGANIZATION_ID', --BUG 9315891
                                        p_parameter_value6 => NVL(:new.organization_id, :old.organization_id) --BUG 9315891
                                      );
  --
  END IF;
EXCEPTION
  WHEN others THEN
    --ENH 20950943
    cll_logging_pub.create_log_entry
      ( p_cll_function_code => 'F255'
      , p_program_type      => 'PL/SQL'
      , p_program_name      => l_module_name
      , p_execution_id      => NVL(:new.delivery_id, :old.delivery_id)
      , p_message_code      => SQLCODE
      , p_message_text      => SQLERRM
      , p_log_level         => 1
      , p_return_code       => l_retcode
      , p_return_message    => l_errbuf
      ) ;
    --
END;
/