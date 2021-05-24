DECLARE

  l_cant   NUMBER;
  l_estado VARCHAR2(30);
  p_horas  NUMBER := 48 ;
  l_viaje_aux NUMBER;
  l_estado_aux VARCHAR2(30);
  l_cancela BOOLEAN;
  l_carta_porte_id NUMBER;
  l_ticket_balanza_id NUMBER;

    
  CURSOR c_viajes IS    
     SELECT xcv.*,  (SYSDATE - NVL(fecha_maxima_retorno, SYSDATE))*24 dif_tiempo
      FROM apps.XX_TCG_CONTROL_VIAJES xcv       
      WHERE campania         = 'CA1920';



/****************************************************************************
  *                                                                          *
  * Nombre      : Get_Orden_por_Estado                                       *
  * Descripción : Función que informa el orden de un Estado                  *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Get_Orden_por_Estado(p_estado   VARCHAR2) RETURN NUMBER
  IS

    CURSOR c_estados IS
      SELECT TO_NUMBER(xx_aco_orden)  orden
        FROM apps.FND_LOOKUP_VALUES       flv
           , apps.FND_LOOKUP_VALUES_DFV   flvd
       WHERE 1=1
         AND flv.rowid               = flvd.row_id
         AND flv.attribute_category  = flvd.context
         AND flv.lookup_type         = 'XX_ACO_CV_ESTADOS'
         AND flv.language            = 'ESA'
         AND flv.attribute_category  = 'XX_ACO_CV_ESTADOS'
         AND flv.view_application_id = 3
         AND flv.security_group_id   = 0
         AND flv.lookup_code         = p_estado;

    l_orden       NUMBER;

  BEGIN

    OPEN c_estados;
    FETCH c_estados INTO l_orden;
    CLOSE c_estados;

    RETURN NVL(l_orden,0);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Orden_por_Estado;


  


  PROCEDURE Set_Estado_Viaje ( p_viaje_id             IN NUMBER
                             , x_estado              OUT VARCHAR
                             , x_fecha_estado        OUT DATE
                             , x_carta_porte_id      OUT NUMBER
                             , x_llegada_estimada    OUT DATE)
  IS


    l_existe_cp         BOOLEAN:= FALSE;
    l_existe_tb         BOOLEAN:= FALSE;
    l_tipo_ticket       VARCHAR2(20);
    l_origen_id         NUMBER;
    l_destino_id        NUMBER;
    l_pes_bruto         DATE;
    l_pes_tara          DATE;
    l_cp_id             NUMBER;
    l_tck_rec_id        NUMBER;
    l_fecha_recep       DATE;
    l_impr_cp           DATE;
    l_rec_flag          VARCHAR2(2);
    l_estado_base       VARCHAR2(30);
    l_fecha_base        DATE;
    l_orden_base        NUMBER;
    l_estado            VARCHAR2(30);
    l_fecha             DATE;
    l_orden             NUMBER;
    l_llegada_est       DATE := NULL;
    l_anulados          NUMBER;
    l_tmax              NUMBER;


    CURSOR c_estados IS
      SELECT flv.lookup_code
           , xv.fecha
           , TO_NUMBER(flvd.xx_aco_orden) xx_aco_orden
        FROM apps.XX_TCG_CONTROL_VIAJES_STATUS  xv
           , apps.FND_LOOKUP_VALUES             flv
           , apps.FND_LOOKUP_VALUES_DFV         flvd
       WHERE xv.estado_transporte    = flv.lookup_code
         AND flv.rowid               = flvd.row_id
         AND flv.attribute_category  = flvd.context
         AND xv.viaje_status_id      = (SELECT MAX(xs.viaje_status_id)
                                          FROM bolinf.XX_TCG_CONTROL_VIAJES_STATUS xs
                                         WHERE xs.viaje_id = p_viaje_id )
         AND flv.lookup_type         = 'XX_ACO_CV_ESTADOS'
         AND flv.language            = 'ESA'
         AND flv.attribute_category  = 'XX_ACO_CV_ESTADOS'
         AND flv.view_application_id = 3
         AND flv.security_group_id   = 0;



    CURSOR c_tb_cp IS
      SELECT xttb.tipo_ticket
           , xtcp.carta_porte_id
           , TO_DATE(xttb.peso_bruto_fecha,'DD-MM-RRRR HH24:MI:SS')   fecha_pesaje_peso_bruto
           , TO_DATE(xttb.tara_fecha,'DD-MM-RRRR HH24:MI:SS')         fecha_pesaje_tara
           , xtcp.titular_cp_estab_id  origen_estab_id
           , xtcp.destino_estab_id
           , xtcp.fecha_recepcion
           , xtcp.fecha_impresion
           , xtcp.ticket_recepcion_id
           , xtcp.recibido_flag
           , xatd.tiempo_maximo
        FROM apps.XX_TCG_TICKETS_BALANZA   xttb
           , apps.XX_TCG_CARTAS_PORTE_ALL  xtcp
           , apps.XX_TCG_CONTROL_VIAJES    xtcv
           , apps.XX_ACO_TARIFA_DISTANCIA  xatd
       WHERE xttb.tipo_ticket             = 'SALIDA'
         AND xttb.ticket_id               = xtcp.ticket_envio_id
         AND xttb.viaje_id                = xtcv.viaje_id
         AND xtcp.distancia_id            = xatd.distancia_id (+)
         AND NVL(xttb.cancelado_flag,'N') = 'N'
         AND NVL(xtcp.anulado_flag,'N')   = 'N'
         AND xtcp.carta_porte_id          > 0
         AND xttb.viaje_id                = p_viaje_id
       ORDER BY xtcp.carta_porte_id DESC;



    CURSOR c_ticket IS
      SELECT TO_DATE(peso_bruto_fecha,'DD-MM-RRRR HH24:MI:SS')   fecha_pesaje_peso_bruto,
             TO_DATE(tara_fecha,'DD-MM-RRRR HH24:MI:SS')         fecha_pesaje_tara
        FROM apps.XX_TCG_TICKETS_BALANZA xttb
           , apps.XX_TCG_CONTROL_VIAJES  xtcv
       WHERE xttb.viaje_id                = xtcv.viaje_id
         AND NVL(xttb.cancelado_flag,'N') = 'N'
         AND xttb.viaje_id                = p_viaje_id;


  BEGIN


    execute immediate('ALTER SESSION SET NLS_LANGUAGE=''AMERICAN''');

    --Se determina el úlimo estado guardado en BD
    OPEN c_estados;
    FETCH c_estados INTO l_estado_base
                       , l_fecha_base
                       , l_orden_base;
    CLOSE c_estados;


    -- Se consulta si existen tickets de envío asociados al viaje
    FOR r_tbal IN c_tb_cp LOOP

      l_existe_cp    := TRUE;
      l_tipo_ticket  := r_tbal.tipo_ticket;
      l_cp_id        := r_tbal.carta_porte_id;
      l_pes_bruto    := r_tbal.fecha_pesaje_peso_bruto;
      l_pes_tara     := r_tbal.fecha_pesaje_tara;
      l_origen_id    := r_tbal.origen_estab_id;
      l_destino_id   := r_tbal.destino_estab_id;
      l_fecha_recep  := r_tbal.fecha_recepcion;
      l_impr_cp      := r_tbal.fecha_impresion;
      l_tck_rec_id   := r_tbal.ticket_recepcion_id;
      l_rec_flag     := r_tbal.recibido_flag;
      l_tmax         := r_tbal.tiempo_maximo;

    END LOOP;


    SELECT count(*)
      INTO l_anulados
      FROM apps.XX_TCG_CONTROL_VIAJES_STATUS
     WHERE viaje_id = -1 * p_viaje_id;

    IF (l_anulados = 0) THEN

      IF (l_existe_cp) THEN

        IF (l_impr_cp IS NOT NULL) THEN
          l_llegada_est := l_impr_cp + (1/24*NVL(l_tmax,0));
        END IF;

        IF (l_tck_rec_id IS NULL) AND (NVL(l_rec_flag,'N')='Y') THEN

          l_estado := 'DESCARGADO';
          l_fecha  := l_fecha_recep;
          l_orden  := Get_Orden_por_Estado(l_estado);

        ELSIF (l_tck_rec_id IS NOT NULL) THEN

          BEGIN

            SELECT TO_DATE(xt.peso_bruto_fecha,'DD-MM-RRRR HH24:MI:SS')   fecha_pesaje_peso_bruto
                 , TO_DATE(xt.tara_fecha,'DD-MM-RRRR HH24:MI:SS')         fecha_pesaje_tara
              INTO l_pes_bruto
                 , l_pes_tara
              FROM apps.XX_TCG_TICKETS_BALANZA xt
             WHERE xt.ticket_id = l_tck_rec_id;

          EXCEPTION
            WHEN others THEN
              l_pes_bruto := NULL;
              l_pes_tara  := NULL;
          END;

          IF (l_pes_tara IS NULL) THEN

            l_estado  := 'EN_DESCARGA';
            l_fecha   := l_pes_bruto;

            l_orden := Get_Orden_por_Estado(l_estado);

          ELSE

            l_estado  := 'DESCARGADO';
            l_fecha   := l_pes_tara;

            l_orden := Get_Orden_por_Estado(l_estado);

          END IF;

        ELSE

          IF (l_impr_cp IS NULL) THEN -- No se imprimión la CP, todavía no están viaje

            IF (l_pes_bruto IS NULL) THEN

              l_estado  := 'TARADO';
              l_fecha   := l_pes_tara;

              l_orden := Get_Orden_por_Estado(l_estado);

            ELSE

              l_estado  := 'CARGADO';
              l_fecha   := l_pes_bruto;

              l_orden := Get_Orden_por_Estado(l_estado);

            END IF;

          ELSE -- CP impresa

            IF (l_llegada_est<SYSDATE) THEN

              l_estado  := 'DEMORADO';

              l_orden := Get_Orden_por_Estado(l_estado);

            ELSE

              l_estado  := 'EN_VIAJE';
              l_fecha   := l_impr_cp;

              l_orden := Get_Orden_por_Estado(l_estado);

            END IF;

          END IF;

        END IF;

      ELSE

        FOR r_tb IN c_ticket LOOP
          l_existe_tb    := TRUE;
          l_pes_bruto    := r_tb.fecha_pesaje_peso_bruto;
          l_pes_tara     := r_tb.fecha_pesaje_tara;
        END LOOP;

        IF (l_existe_tb) THEN

          IF (l_pes_bruto IS NULL) THEN

            l_estado  := 'TARADO';
            l_fecha   := l_pes_tara;

            l_orden := Get_Orden_por_Estado(l_estado);

          ELSE
            l_estado  := 'CARGADO';
            l_fecha   := l_pes_bruto;

            l_orden := Get_Orden_por_Estado(l_estado);

          END IF;

        END IF;

      END IF;

    ELSE
      l_existe_cp    := FALSE;  --Se realiza este cambio para aquellos viajes que fueron pasados a Rechazado por DF
    END IF;

    --Se comparan los estados manuales con los obtenidos por relación de CP
    IF ((l_existe_cp) AND
        (l_orden >= l_orden_base)) OR
       ((l_existe_tb) AND
        (l_orden >= l_orden_base))  THEN

      x_estado        := l_estado;
      x_fecha_estado  := l_fecha;

    ELSE

      x_estado         := l_estado_base;
      x_fecha_estado   := l_fecha_base;

    END IF;

    x_carta_porte_id    := l_cp_id;
    x_llegada_estimada  := l_llegada_est;


  END Set_Estado_Viaje;


 /****************************************************************************
  *                                                                          *
  * Nombre       : Set_Estado_Viaje                                          *
  * Descripción :  Función que determina el estado del viaje                 *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Set_Estado_Viaje (p_viaje_id  IN NUMBER) RETURN VARCHAR2 IS

    l_estado       VARCHAR2(30);
    l_fecha        DATE;
    l_cp_id        NUMBER;
    l_llegada      DATE;

  BEGIN

    Set_Estado_Viaje ( p_viaje_id          => p_viaje_id
                     , x_estado            => l_estado
                     , x_fecha_estado      => l_fecha
                     , x_carta_porte_id    => l_cp_id
                     , x_llegada_estimada  => l_llegada) ;

    RETURN  l_estado;

  END Set_Estado_Viaje;


BEGIN


 DBMS_OUTPUT.PUT_LINE(' Inicio: ');

  FOR r_viajes IN c_viajes LOOP
   
      l_cancela := FALSE;   
      l_estado := set_estado_viaje(r_viajes.viaje_id);
      l_ticket_balanza_id := NULL;
      l_carta_porte_id := NULL;            
      
      IF l_estado = 'PENDIENTE_RETORNO' THEN
                       
          BEGIN
          
             SELECT MAX(viaje_id)
               INTO l_viaje_aux
               FROM xx_tcg_control_viajes               
              WHERE qr_id         = r_viajes.qr_id
                AND campania      = r_viajes.campania
                AND viaje_id     <> r_viajes.viaje_id
                AND creation_date <= r_viajes.creation_date;

          l_estado_aux := set_estado_viaje(l_viaje_aux);                   
                      
          EXCEPTION
            WHEN others THEN
              l_viaje_aux := NULL;
              l_estado_aux := NULL;   
          END;
       
          
          IF l_estado_aux NOT IN ('EN_VIAJE', 'DEMORADO', 'EN_DESCARGA') OR l_viaje_aux IS NULL
          THEN
             l_cancela := TRUE;
          END IF;

      END IF;

        
   
      IF l_cancela THEN
            
    

         BEGIN 
           INSERT INTO bolinf.XX_TCG_CONTROL_VIAJES_STATUS
            ( viaje_status_id
            , viaje_id
            , estado_transporte
            , fecha
            , created_by
            , creation_date
            , last_updated_by
            , last_update_date
            , last_update_login
            ) VALUES
            ( xx_aco_cv_status_s.nextval
            , r_viajes.viaje_id
            , 'CANCELADO'
            , SYSDATE
            , 2070
            , SYSDATE
            , 2070
            , SYSDATE
            , -1
            );

          EXCEPTION
                WHEN others THEN
                    DBMS_OUTPUT.PUT_LINE('Error haciendo insert'||'|'||'Turno: '||'|'||r_viajes.turno||'|'||'Error: ' ||'|'||sqlerrm);
          END;           
        
       DBMS_OUTPUT.PUT_LINE('Se canceló el viaje: '||'|'||r_viajes.viaje_id||'|'||'Turno: '||'|'||r_viajes.turno||'|'||'QR: '||'|'||r_viajes.qr_id ||
                                  ' l_estado: ' || '|' || l_estado );
   
      END IF;

     COMMIT;

  END LOOP;
 
   
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error: '||sqlerrm);
   
END;
/