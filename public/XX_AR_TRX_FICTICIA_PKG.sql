  CREATE OR REPLACE PACKAGE "APPS"."XX_AR_TRX_FICTICIA_PKG" IS

   --Variables globales para errores internos del proceso
   e_retcode        NUMBER;
   e_exception      EXCEPTION;
   e_message        VARCHAR2(10000);

   --Variables globales
   g_monto_lineas_0 NUMBER:=0.01; --Variable global para determinar con que monto se ingresan las lineas generadas por este proceso
   g_user_id_ar     NUMBER:=-1;   --Variable global para determinar a nombre de que usuario se ingresan los comprobantes para AR
   g_login_id_ar    NUMBER:=-1;   --Variable global para determinar a nombre de que login se ingresan los comprobantes para AR
   g_debug          VARCHAR2(1):= NVL(fnd_profile.value('XX_DEBUG_ENABLED'),'N');   --Variable global para determinar si se debuguea
   g_cae_reint      NUMBER:= 3;   --Variable global para determinar cantidad de reintentos para obtener CAE

   --frozados added
   TYPE request_type is record
    (request_id varchar2(100)
    ,modo_ejecucion VARCHAR2(100)
    ,estado VARCHAR2(20)
    );

   TYPE list_of_requests_t IS TABLE OF request_type INDEX BY VARCHAR2(20);


/*----------------------------FUNCTION fecha_doc------------------------------------
--Funcion creada para analizar la fecha limite que se deberia considerar para los --
--documentos que son generados automaticamente en Cuentas por Cobrar              --
--                                                                                --
--Parametros                                                                      --
--l_trx_date: Fecha de la transaccion que se utilizara para los calculos          --
--p_batch_source_id: Origen en el que se consulta la ultima trx generada          --
--p_fecha_override: Fecha utilizada para manipular la fecha de corte              --
----------------------------------------------------------------------------------*/
   FUNCTION fecha_doc(l_trx_date            IN OUT DATE
                    , p_batch_source_id     IN     NUMBER
                    , p_fecha_override      IN     DATE)
      RETURN BOOLEAN;

/*----------------------------FUNCTION obtener_warehouse_id-------------------------
--Funcion creada para obtener el warehouse_id configurado en las opciones de OM   --
--en el perfil "Organizaci¿n de Validaci¿n de Art¿lo"                           --
--                                                                                --
--Parametros                                                                      --
--p_org_id: Org_id para la cual se desea obtener el warehouse configurado en el   --
--perfil "Organizaci¿n de Validaci¿n de Art¿lo" de OM                           --
----------------------------------------------------------------------------------*/
   FUNCTION obtener_warehouse_id(p_org_id           IN     NUMBER
                                ,p_warehouse_id     IN OUT NUMBER)
      RETURN BOOLEAN;

/*-------------------FUNCTION habilitar_metodo_cobro -------------------------------
--Funcion creada para habilitar metodos de cobro en productores para la carga de  --
--la FC                                                                           --
--p_customer_id: Cliente para el que se desea habilitar el metodo de cobro        --
--p_site_use_id: Sucursal para la que se desea habilitar el metodo de cobro       --
--p_receipt_method_id: Metodo de cobro que se desea habilitar                     --
--p_trx_date: Fecha de la transaccion que se desea crear                          --
----------------------------------------------------------------------------------*/
   FUNCTION habilitar_metodo_cobro(p_customer_id       IN NUMBER
                                  ,p_site_use_id       IN NUMBER
                                  ,p_receipt_method_id IN NUMBER
                                  ,p_trx_date          IN DATE)
      RETURN BOOLEAN;

/*-------------------FUNCTION habilitar_relacion------------------------------------
--Funcion creada para habilitar relaciones entre corredor y productor             --
--automaticamente                                                                 --
--p_corredor: customer_id del corredor para el que se desea crear la relacion     --
--p_productor: customer_id del productor para el que se desea crear la relacion   --
--p_reciproca: variable para determinar si la recion sera reciproca               --
--p_org_id: empresa en la que se quiere crear la relacion                         --
----------------------------------------------------------------------------------*/
   FUNCTION habilitar_relacion(p_corredor        IN NUMBER
                              ,p_productor       IN NUMBER
                              ,p_reciproca       IN VARCHAR2
                              ,p_org_id          IN NUMBER)
      RETURN BOOLEAN;

/*-------------------FUNCTION actualizar_corredor ----------------------------------
--Funcion creada para actualizar facturas entre corredor y productor              --
--p_org_id: empresa en la que se quiere crear la relacion                         --
--p_conc_id: id de concurrente que se desea actualizar                            --
--p_batch_source_id: origen de facturas que se desea actualizar                   --
----------------------------------------------------------------------------------*/
   FUNCTION actualizar_corredor(p_org_id          IN NUMBER
                               ,p_conc_id         IN VARCHAR2
                               ,p_batch_source_id IN NUMBER)
      RETURN BOOLEAN;

/*----------------------------FUNCTION crear_doc------------------------------------
--Funcion creada para crear documentos en base a una transaccion original         --
--pero con un nuevo tipo y origen de transaccion.                                 --
--                                                                                --
--Parametros                                                                      --
--p_customer_trx_id: Id de la transaccion que se desea copiar                     --
--p_batch_source_id: Nuevo origen para la transaccion. Se valida que sea valido   --
--p_cust_trx_type_id: Nuevo tipo para la transaccion. Se valida que sea valido    --
--p_tax_id_ar: Define el impuesto de tasa 0% que se asignara a las lineas de AR   --
--p_memo_line_id: Line nota para la creacion de lineas de monto 0                 --
--p_term_id_ar: Define el termino de pago que se utilizara en la inteface de AR   --
--p_proceso: Define si se va a crear un documento real o uno interno              --
--l_cant_lineas: Devuelve la cant de lineas insertadas en la interface            --
--p_conc_id: Parametro utilizado para agrupar transacciones con el id del         --
--concurrente que se esta ejecutando                                              --
--p_fecha_override: Fecha utilizada para manipular la fecha de corte              --
----------------------------------------------------------------------------------*/
   FUNCTION crear_doc (p_customer_trx_id  IN     ra_customer_trx_all.customer_trx_id%TYPE
                      ,p_batch_source_id  IN     ra_customer_trx_all.batch_source_id%TYPE
                      ,p_cust_trx_type_id IN     ra_interface_lines_all.cust_trx_type_id%TYPE
                      ,p_tax_id_ar        IN     ra_interface_lines_all.vat_tax_id%TYPE
                      ,p_memo_line_id     IN     ar_memo_lines_all_b.memo_line_id%TYPE
                      ,p_term_id_ar       IN     ra_customer_trx_all.term_id%TYPE
                      ,p_proceso          IN     VARCHAR2
                      ,l_cant_lineas      IN OUT NUMBER
                      ,p_conc_id          IN     NUMBER
                      ,p_fecha_override   IN     DATE)
      RETURN BOOLEAN;

/*----------------------------PROCEDURE main----------------------------------------
--Procedimiento creado para crear documentos de percepcion en base a liquidaciones--
--intercompany o de terceros.                                                     --
--                                                                                --
--Parametros                                                                      --
--p_fecha_desde: Fecha desde la que se quieren copiar transacciones               --
--p_fecha_hasta: Fecha hasta la que se quieren copiar transaccioes                --
--p_modo_ejecucion: define que documentos seran importados a las interfaces       --
--en caso de estar en blanco ejecuta todos los procesos                           --
--p_tipo_trx: Define el tipo de transaccion que sera usado por defecto en AP      --
--p_source: Define el origen de los documentos en la interface de AP              --
--p_pay_group: Define el grupo de los documentos en la interface de AP            --
--p_terms_id: Define el termino de pago que se utilizara en la interface de AP    --
--p_payment_method_lookup_code: Define el metodo de pago que se utilizara en la   --
--interface de AP                                                                 --
--p_tax_id_ar: Define el impuesto de tasa 0% que se asignara a las lineas de AR   --
--p_memo_line_id: Line nota para la creacion de lineas de monto 0                 --
--p_term_id_ar: Define el termino de pago que se utilizara en la inteface de AR   --
--p_importar: Define si se ejecuta la interface de AR o no cuando finaliza la     --
--ejecucion                                                                       --
--p_fecha_override: Fecha utilizada para manipular la fecha de corte              --
----------------------------------------------------------------------------------*/
   PROCEDURE main(errbuf                          OUT VARCHAR2
                 ,retcode                         OUT NUMBER
                 ,p_fecha_desde                IN     VARCHAR2
                 ,p_fecha_hasta                IN     VARCHAR2
                 ,p_modo_ejecucion             IN     VARCHAR2
                 ,p_tipo_trx                   IN     VARCHAR2
                 ,p_source                     IN     VARCHAR2
                 ,p_pay_group                  IN     VARCHAR2
                 ,p_terms_id                   IN     NUMBER
                 ,p_payment_method_lookup_code IN     VARCHAR2
                 ,p_tax_id_ar                  IN     NUMBER
                 ,p_memo_line_id               IN     NUMBER
                 /*Modificado KHRONUS/E.Sly 20191021 El termino de pago debe tomarse de la liquidacion*/
                 --,p_term_id_ar                 IN     NUMBER
                 /*Fin Modificado KHRONUS/E.Sly 20191021 El termino de pago debe tomarse de la liquidacion*/
                 ,p_importar                   IN     VARCHAR2
                 ,p_fecha_override             IN     VARCHAR2
                 );

END XX_AR_TRX_FICTICIA_PKG;
/


  CREATE OR REPLACE PACKAGE BODY "APPS"."XX_AR_TRX_FICTICIA_PKG" 
IS
    FUNCTION fecha_doc (l_trx_date         IN OUT DATE
                       ,p_batch_source_id  IN     NUMBER
                       ,p_fecha_override   IN     DATE)
       RETURN BOOLEAN IS

       l_fecha_resultado  DATE;
       l_fecha_corte      DATE;
       l_fecha_ultima_trx DATE;
       l_fecha_interface  DATE;

       BEGIN

             IF g_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'Inicio XX_AR_TRX_FICTICIA_PKG.fecha_doc '||to_char(sysdate,'HH24:MI:SS'));
             END IF;

             IF to_char(nvl(p_fecha_override,sysdate),'DD') <= 16 THEN
                l_fecha_corte:= to_date('01-'||to_char(nvl(p_fecha_override,sysdate),'MM-RRRR'),'DD-MM-RRRR');
             ELSE
                l_fecha_corte:= to_date('16-'||to_char(nvl(p_fecha_override,sysdate),'MM-RRRR'),'DD-MM-RRRR');
             END IF;

             BEGIN
                SELECT max(trx_date)
                  INTO l_fecha_interface
                  FROM ra_interface_lines_all rii
                     , ra_batch_sources_all   rbs
                 WHERE rbs.name            = rii.batch_source_name
                   AND rbs.batch_source_id = p_batch_source_id;

             EXCEPTION
                WHEN NO_DATA_FOUND  THEN
                   l_fecha_interface := l_trx_date;

                WHEN OTHERS THEN
                   e_message:='Error en fecha_doc interace para l_trx_date: '||l_trx_date||', p_batch_source_id: '||p_batch_source_id||', sqlerrm: '||sqlerrm;
                   fnd_message.retrieve(e_message);
                   e_retcode:=1;
                   RETURN FALSE;
             END;

             SELECT nvl(max(to_date(rbs.global_attribute4,'RRRR-MM-DD HH24:MI:SS')),max(trx_date))
               INTO l_fecha_ultima_trx
               FROM ra_customer_trx_all rct
                  , ra_batch_sources_all rbs
              WHERE rbs.batch_source_id = rct.batch_source_id (+)
                AND rbs.batch_source_id = p_batch_source_id;

             SELECT max(fecha_trx)
               INTO l_fecha_resultado
               FROM (SELECT trunc(sysdate - 4) fecha_trx FROM DUAL UNION
                     SELECT l_fecha_corte                FROM DUAL UNION
                     SELECT l_trx_date                   FROM DUAL UNION
                     SELECT l_fecha_interface            FROM DUAL UNION
                     SELECT l_fecha_ultima_trx           FROM DUAL);

             IF g_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log, 'l_fecha_corte: '     ||l_fecha_corte
                                             ||' l_fecha_cae: '       ||trunc(sysdate - 4)
                                             ||' l_fecha_trx: '       ||l_trx_date
                                             ||' l_fecha_ultima_trx: '||l_fecha_ultima_trx
                                             ||' l_fecha_interface: ' ||l_fecha_interface
                                             ||' l_fecha_resultado: ' ||l_fecha_resultado);
             END IF;

             l_trx_date :=l_fecha_resultado;

             IF g_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'Fin XX_AR_TRX_FICTICIA_PKG.fecha_doc '||to_char(sysdate,'HH24:MI:SS'));
             END IF;

             RETURN TRUE;

       EXCEPTION
       WHEN NO_DATA_FOUND  THEN
          e_message:='No se encontraron datos en fecha_doc para l_trx_date: '||l_trx_date||', p_batch_source_id: '||p_batch_source_id;
          fnd_file.put_line(fnd_file.log,e_message);
          e_retcode:=1;
          RETURN FALSE;

       WHEN OTHERS THEN
          e_message:='Error en fecha_doc para l_trx_date: '||l_trx_date||', p_batch_source_id: '||p_batch_source_id||', sqlerrm: '||sqlerrm;
          fnd_file.put_line(fnd_file.log,e_message);
          e_retcode:=1;
          RETURN FALSE;

       END fecha_doc;

    FUNCTION obtener_warehouse_id(p_org_id           IN     NUMBER
                                 ,p_warehouse_id     IN OUT NUMBER)
       RETURN BOOLEAN IS

       BEGIN

          If g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Inicio XX_AR_TRX_FICTICIA_PKG.obtener_warehouse_id '||to_char(sysdate,'HH24:MI:SS'));
          END IF;

          SELECT parameter_value
            INTO p_warehouse_id
            FROM oe_sys_parameters_all
           WHERE parameter_code = 'MASTER_ORGANIZATION_ID'
             AND org_id = p_org_id;

          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Warehouse_id OM: '||p_warehouse_id);
             fnd_file.put_line(fnd_file.log,'Fin XX_AR_TRX_FICTICIA_PKG.obtener_warehouse_id '||to_char(sysdate,'HH24:MI:SS'));
          END IF;

          RETURN TRUE;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             e_message:= 'Error: No se encontro warehouse_id para: '||p_org_id;
             fnd_message.retrieve(e_message);
             e_retcode:=1;
             RETURN FALSE;

          WHEN OTHERS THEN
             e_message:= 'Error general buscando warehouse_id: '||p_org_id||' Error sql:'||sqlerrm;
             fnd_message.retrieve(e_message);
             e_retcode:=1;
             RETURN FALSE;

       END obtener_warehouse_id;

    FUNCTION habilitar_metodo_cobro(p_customer_id       IN NUMBER
                                   ,p_site_use_id       IN NUMBER
                                   ,p_receipt_method_id IN NUMBER
                                   ,p_trx_date          IN DATE)
    RETURN BOOLEAN IS

    l_existe    VARCHAR2(1);
    l_api_error VARCHAR2(1000);
    l_rowid     ROWID;
    l_cust_receipt_method_id ra_cust_receipt_methods.cust_receipt_method_id%TYPE;

    int_crm ra_cust_receipt_methods%ROWTYPE:= null;

       BEGIN

          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Inicio XX_AR_TRX_FICTICIA_PKG.habilitar_metodo_cobro '||to_char(sysdate,'HH24:MI:SS'));
             fnd_file.put_line(fnd_file.log,'p_receipt_method_id: '||p_receipt_method_id||' p_customer_id: '||p_customer_id||' p_site_use_id: '||p_site_use_id||' p_trx_date: '||p_trx_date);
          END IF;

          BEGIN
             SELECT 'Y'
             INTO  l_existe
             FROM ra_cust_receipt_methods
             WHERE customer_id          = p_customer_id
             AND site_use_id            = p_site_use_id
             AND receipt_method_id      = p_receipt_method_id
             AND PRIMARY_FLAG='Y'
             AND p_trx_date       BETWEEN nvl(start_date,p_trx_date)
                                      AND nvl(end_date,p_trx_date);

             IF g_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'Existe un metodo de pago activo para la fecha de la transaccion');
             END IF;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                BEGIN
                    SELECT 'Y'
                         INTO  l_existe
                         FROM ra_cust_receipt_methods
                         WHERE customer_id          = p_customer_id
                         AND site_use_id            = p_site_use_id
                         AND receipt_method_id      = p_receipt_method_id
                         AND p_trx_date       BETWEEN nvl(start_date,p_trx_date)
                                                  AND nvl(end_date,p_trx_date);
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                           l_existe:='N';
                            END;
             WHEN OTHERS THEN
                     e_message :='Error general buscando si existe un metodo de recibo para p_customer_id: '||p_customer_id||
                                                                                    ', p_site_use_id: '||p_site_use_id||
                                                                                    ', p_receipt_method_id: '||p_receipt_method_id||
                                                                                    ', p_trx_date: '||p_trx_date;
                fnd_file.put_line(fnd_file.log,e_message);
                e_retcode :=1;
          END;

          BEGIN
             IF l_existe = 'N' THEN
                --Analiza si existe un metodo de pago futuro
                BEGIN
                   SELECT rowid
                   INTO   l_rowid
                   FROM   ra_cust_receipt_methods
                   WHERE  customer_id       = p_customer_id
                   AND    site_use_id       = p_site_use_id
                   AND    receipt_method_id = p_receipt_method_id
                   AND    start_date        = (SELECT min(start_date)
                                               FROM   ra_cust_receipt_methods
                                               WHERE  customer_id       = p_customer_id
                                               AND    site_use_id       = p_site_use_id
                                               AND    receipt_method_id = p_receipt_method_id
                                               AND    p_trx_date        < start_date);

                   SELECT *
                   INTO   int_crm
                   FROM   ra_cust_receipt_methods rcrm
                   WHERE  rowid = l_rowid;

                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      int_crm := null;

                   WHEN OTHERS THEN
                      e_message :='Error general buscando si existe un metodo futuro de recibo para p_customer_id: '||p_customer_id||
                                                                                          ', p_site_use_id: '||p_site_use_id||
                                                                                          ', p_receipt_method_id: '||p_receipt_method_id||
                                                                                          ', p_trx_date: '||p_trx_date;
                                      fnd_file.put_line(fnd_file.log,e_message);
                                        e_retcode :=1;
                END;

                IF int_crm.cust_receipt_method_id IS NOT NULL THEN

                   IF g_debug = 'Y' THEN
                      fnd_file.put_line(fnd_file.log,'Se actualiza la fecha de inicio del metodo de pago cust_receipt_method_id:'||int_crm.cust_receipt_method_id);
                   END IF;

                  --Actualizo la fecha de Inicio
                   arp_CRM_PKG.update_row( X_Rowid                   => l_rowid,
                                           X_Cust_Receipt_Method_Id  => int_crm.cust_receipt_method_id,
                                           X_Customer_Id             => int_crm.customer_id,
                                           X_Last_Updated_By         => g_user_id_ar,
                                           X_Last_Update_Date        => sysdate,
                                           X_Primary_Flag            => int_crm.primary_flag,
                                           X_Receipt_Method_Id       => int_crm.receipt_method_id,
                                           X_Start_Date              => p_trx_date,
                                           X_End_Date                => int_crm.end_date,
                                           X_Last_Update_Login       => g_login_id_ar,
                                           X_Site_Use_Id             => int_crm.site_use_id,
                                           X_Attribute_Category      => int_crm.attribute_category,
                                           X_Attribute1              => int_crm.attribute1,
                                           X_Attribute2              => int_crm.attribute2,
                                           X_Attribute3              => int_crm.attribute3,
                                           X_Attribute4              => int_crm.attribute4,
                                           X_Attribute5              => int_crm.attribute5,
                                           X_Attribute6              => int_crm.attribute6,
                                           X_Attribute7              => int_crm.attribute7,
                                           X_Attribute8              => int_crm.attribute8,
                                           X_Attribute9              => int_crm.attribute9,
                                           X_Attribute10             => int_crm.attribute10,
                                           X_Attribute11             => int_crm.attribute11,
                                           X_Attribute12             => int_crm.attribute12,
                                           X_Attribute13             => int_crm.attribute13,
                                           X_Attribute14             => int_crm.attribute14,
                                           X_Attribute15             => int_crm.attribute15);

                ELSE

                   --Analiza si existe un metodo de pago pasado
                   BEGIN
                      SELECT rowid
                      INTO   l_rowid
                      FROM   ra_cust_receipt_methods rcrm
                      WHERE  customer_id       = p_customer_id
                      AND    site_use_id       = p_site_use_id
                      AND    receipt_method_id = p_receipt_method_id
                      AND    end_date          = (SELECT max(end_date)
                                                    FROM   ra_cust_receipt_methods
                                                   WHERE  customer_id       = p_customer_id
                                                     AND    site_use_id       = p_site_use_id
                                                     AND    receipt_method_id = p_receipt_method_id
                                                     AND    p_trx_date        > end_date);

                      SELECT *
                      INTO   int_crm
                      FROM   ra_cust_receipt_methods rcrm
                      WHERE  rowid = l_rowid;

                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                         int_crm := null;

                      WHEN OTHERS THEN
                         e_message :='Error general buscando si existe un metodo futuro de recibo para p_customer_id: '||p_customer_id||
                                                                                             ', p_site_use_id: '||p_site_use_id||
                                                                                             ', p_receipt_method_id: '||p_receipt_method_id||
                                                                                             ', p_trx_date: '||p_trx_date;
                                             fnd_file.put_line(fnd_file.log,e_message);
                                             e_retcode :=1;
                   END;

                   IF int_crm.cust_receipt_method_id IS NOT NULL THEN

                      IF g_debug = 'Y' THEN
                         fnd_file.put_line(fnd_file.log,'Se actualiza la fecha de fin del metodo de pago cust_receipt_method_id:'||int_crm.cust_receipt_method_id);
                      END IF;

                      --Actualizo la fecha de Fin
                      arp_CRM_PKG.update_row( X_Rowid                   => l_rowid,
                                              X_Cust_Receipt_Method_Id=> int_crm.cust_receipt_method_id,
                                              X_Customer_Id             => int_crm.customer_id,
                                              X_Last_Updated_By         => g_user_id_ar,
                                              X_Last_Update_Date        => sysdate,
                                              X_Primary_Flag            => int_crm.primary_flag,
                                              X_Receipt_Method_Id       => int_crm.receipt_method_id,
                                              X_Start_Date              => int_crm.start_date,
                                              X_End_Date                => p_trx_date,
                                              X_Last_Update_Login       => g_login_id_ar,
                                              X_Site_Use_Id             => int_crm.site_use_id,
                                              X_Attribute_Category      => int_crm.attribute_category,
                                              X_Attribute1              => int_crm.attribute1,
                                              X_Attribute2              => int_crm.attribute2,
                                              X_Attribute3              => int_crm.attribute3,
                                              X_Attribute4              => int_crm.attribute4,
                                              X_Attribute5             => int_crm.attribute5,
                                              X_Attribute6             => int_crm.attribute6,
                                              X_Attribute7              => int_crm.attribute7,
                                              X_Attribute8              => int_crm.attribute8,
                                              X_Attribute9              => int_crm.attribute9,
                                              X_Attribute10             => int_crm.attribute10,
                                              X_Attribute11             => int_crm.attribute11,
                                              X_Attribute12             => int_crm.attribute12,
                                              X_Attribute13             => int_crm.attribute13,
                                              X_Attribute14             => int_crm.attribute14,
                                              X_Attribute15             => int_crm.attribute15);


                   ELSE
                      IF g_debug = 'Y' THEN
                         fnd_file.put_line(fnd_file.log,'Se inserta un nuevo metodo de pago para el cliente');
                      END IF;

                   --Si no existe ni un metodo pasado ni futuro se inserta un nuevo metodo sin fecha de finalizacion
                      arp_CRM_PKG.Insert_Row( X_Rowid                   => l_rowid,
                                              X_Cust_Receipt_Method_Id  => l_Cust_Receipt_Method_Id,
                                              X_Created_By              =>  g_user_id_ar,
                                              X_Creation_Date           => sysdate,
                                              X_Customer_Id             => p_customer_id,
                                              X_Last_Updated_By         => g_user_id_ar,
                                              X_Last_Update_Date        => sysdate,
                                              X_Primary_Flag            => 'N',
                                              X_Receipt_Method_Id       => p_receipt_method_id,
                                              X_Start_Date              => p_trx_date,
                                              X_End_Date                => null,
                                              X_Last_Update_Login       => g_login_id_ar,
                                              X_Site_Use_Id             => p_site_use_id,
                                              X_Attribute_Category      => null,
                                              X_Attribute1              => null,
                                              X_Attribute2              => null,
                                              X_Attribute3              => null,
                                              X_Attribute4              => null,
                                              X_Attribute5              => null,
                                              X_Attribute6              => null,
                                              X_Attribute7              => null,
                                              X_Attribute8              => null,
                                              X_Attribute9              => null,
                                              X_Attribute10             => null,
                                              X_Attribute11             => null,
                                              X_Attribute12             => null,
                                              X_Attribute13             => null,
                                              X_Attribute14             => null,
                                              X_Attribute15             => null);


                   END IF;

                END IF;

             END IF;

          EXCEPTION
             WHEN OTHERS THEN
                e_message := 'Error en la API metodo de cobro. Error API: '||e_message;
                fnd_message.retrieve(e_message);
                e_retcode := 1;
                RETURN FALSE;
           END;

          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Creacion correcta del metodo de cobro');
             fnd_file.put_line(fnd_file.log,'Fin XX_AR_TRX_FICTICIA_PKG.habilitar_metodo_cobro '||to_char(sysdate,'HH24:MI:SS'));
          END IF;

          RETURN TRUE;

       EXCEPTION
          WHEN e_exception THEN
             RETURN FALSE;

          WHEN OTHERS THEN
             e_message:= 'Error general al crear metodo cobro. p_customer_id: '||p_customer_id
                                                          ||', p_site_use_id: '||p_site_use_id
                                                          ||', p_receipt_method_id: '||p_receipt_method_id
                                                          ||', p_trx_date: '||p_trx_date
                                                          ||', sqlerrm: '||sqlerrm;
             fnd_message.retrieve(e_message);
             e_retcode:=1;
             RETURN FALSE;

       END habilitar_metodo_cobro;

    FUNCTION habilitar_relacion(p_corredor        IN NUMBER
                               ,p_productor       IN NUMBER
                               ,p_reciproca       IN VARCHAR2
                               ,p_org_id          IN NUMBER)
       RETURN BOOLEAN IS

    l_existe VARCHAR(1);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

       BEGIN
          IF g_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'Inicio XX_AR_TRX_FICTICIA_PKG.habilitar_relacion '||to_char(sysdate,'HH24:MI:SS'));
                fnd_file.put_line(fnd_file.log,'p_productor: '||p_productor||', p_corredor: '||p_corredor||', p_org_id: '||p_org_id);
          END IF;

          BEGIN
             SELECT 'Y'
             INTO   l_existe
             FROM   hz_cust_acct_relate_all
             WHERE  cust_account_id         = p_productor
             AND    related_cust_account_id = p_corredor
             AND    org_id                  = p_org_id
             AND    status = 'A';

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 IF g_debug = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,'No existe relacion entre productor/corredor. Se crea una nueva relacion');
                END IF;

                BEGIN

                arh_crel_pkg.Insert_Row(X_Created_By               => g_user_id_ar,
                                        X_Creation_Date            => sysdate,
                                        X_Customer_Id              => p_productor,
                                        X_Customer_Reciprocal_Flag => p_reciproca,
                                        X_relationship_type        => 'ALL',
                                        X_Last_Updated_By          => g_user_id_ar,
                                        X_Last_Update_Date         => sysdate,
                                        X_Related_Customer_Id      => p_corredor,
                                        X_Status                   => 'A',
                                        X_Comments                 => null,
                                        X_Last_Update_Login        => g_login_id_ar,
                                        X_Attribute_Category       => null,
                                        X_Attribute1               => null,
                                        X_Attribute2               => null,
                                        X_Attribute3               => null,
                                        X_Attribute4               => null,
                                        X_Attribute5               => null,
                                        X_Attribute6               => null,
                                        X_Attribute7               => null,
                                        X_Attribute8               => null,
                                        X_Attribute9               => null,
                                        X_Attribute10              => null,
                                        X_Attribute11              => null,
                                        X_Attribute12              => null,
                                        X_Attribute13              => null,
                                        X_Attribute14              => null,
                                        X_Attribute15              => null,
                                        X_BILL_TO_FLAG             => 'Y',
                                        X_SHIP_TO_FLAG             => 'Y',
                                        x_return_status            => l_return_status,
                                        x_msg_count                => l_msg_count,
                                        x_msg_data                 => l_msg_data);


                   IF l_return_status != FND_API.G_RET_STS_SUCCESS THEN
                        e_message := 'Error api habilitar relacion. l_return_status: '||l_return_status;
                        fnd_message.retrieve(e_message);
                        e_retcode := 1;
                        RETURN FALSE;

                   END IF;

                EXCEPTION WHEN OTHERS THEN
                   e_message := 'Error al llamar a api habilitar relacion. sqlerrm: '||sqlerrm;
                   fnd_message.retrieve(e_message);
                   e_retcode := 1;
                   RETURN FALSE;
                END;

             WHEN OTHERS THEN
                e_message := 'Error al analizar si existe relacion productor/corredor. sqlerrm: '||sqlerrm;
                fnd_message.retrieve(e_message);
                e_retcode := 1;
                RETURN FALSE;
          END;

          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Creacion correcta de la relacion productor/corredor');
             fnd_file.put_line(fnd_file.log,'Fin XX_AR_TRX_FICTICIA_PKG.habilitar_relacion '||to_char(sysdate,'HH24:MI:SS'));
          END IF;

          RETURN TRUE;

       END habilitar_relacion;

    FUNCTION actualizar_corredor(p_org_id          IN NUMBER
                                ,p_conc_id         IN VARCHAR2
                                ,p_batch_source_id IN NUMBER)
       RETURN BOOLEAN IS

    CURSOR c_facturas (p_org_id          IN NUMBER
                      ,p_conc_id         IN VARCHAR2
                      ,p_batch_source_id IN NUMBER) IS
    SELECT rct1.bill_to_customer_id
         , rct1.bill_to_site_use_id
         , rct.customer_trx_id
    FROM   ra_customer_trx_all rct
          ,ra_customer_trx_all rct1
    WHERE  rct.bill_to_customer_id        != rct1.bill_to_customer_id
    AND    rct.interface_header_attribute5 = rct1.customer_trx_id
    AND    rct.org_id                      = p_org_id
    AND    rct.interface_header_attribute4 = p_conc_id
    AND    rct.batch_source_id             = p_batch_source_id;


       BEGIN
          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Inicio XX_AR_TRX_FICTICIA_PKG.actualizar_corredor '||to_char(sysdate,'HH24:MI:SS'));
             fnd_file.put_line(fnd_file.log,'p_org_id: '||p_org_id
                                          ||' p_conc_id: '||p_conc_id
                                          ||' p_batch_source_id: '||p_batch_source_id);
          END IF;

          FOR c_update IN c_facturas(p_org_id,p_conc_id,p_batch_source_id) LOOP

             UPDATE ra_customer_trx_all
             SET    paying_customer_id = c_update.bill_to_customer_id
                   ,paying_site_use_id = c_update.bill_to_site_use_id
             WHERE  customer_trx_id    = c_update.customer_trx_id;

          END LOOP;

          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Actualizacion pagador correcta');
             fnd_file.put_line(fnd_file.log,'Fin XX_AR_TRX_FICTICIA_PKG.actualizar_corredor '||to_char(sysdate,'HH24:MI:SS'));
          END IF;

          RETURN TRUE;

       EXCEPTION WHEN OTHERS THEN
          e_message:='Error al actualizar el corredor. p_org_id: '||p_org_id
                                                   ||' p_conc_id: '||p_conc_id
                                                   ||' p_batch_source_id: '||p_batch_source_id
                                                   ||' sqlerrm: '||sqlerrm;
          fnd_message.retrieve(e_message);
          e_retcode:= 1;
          RETURN FALSE;

       END actualizar_corredor;

       PROCEDURE XX_PROCESA(p_customer_trx_id IN NUMBER
                                                ,x_contrato                 OUT VARCHAR2
                                                ,x_procesa                 OUT VARCHAR2
                                                )
       IS
           l_procesa                               VARCHAR2(1) := 'Y';
            l_contrato                     VARCHAR2(250);
       BEGIN
           BEGIN
              SELECT 'N'
                           ,acc.contrato_compra
              INTO x_procesa
                      ,x_contrato
                        FROM  ra_customer_trx_all      ct
                             --,ra_cust_trx_types_all    rc
                             ,ra_cust_trx_types_all    rct  -- ITC
                             ,ra_batch_sources_all     bs
                             ,ra_batch_sources_all_dfv bs_dfv
                             ,(SELECT hca.cust_account_id
                                   ,hp.party_id
                              FROM hz_parties hp,
                                   hz_cust_accounts hca
                             WHERE 1=1
                               AND hp.Party_Id = hca.Party_Id) c -- ITC
                             --,ra_customers             c
                             ,xx_ar_asocia_contrato_compra acc
                             ,hr_operating_units       ou
                             ,oe_order_headers_all     oh
                             ,hz_cust_accounts_all         hca
                             ,(SELECT hca.cust_account_id
                                   ,hp.party_id
                              FROM hz_parties hp,
                                   hz_cust_accounts hca
                             WHERE 1=1
                               AND hp.Party_Id = hca.Party_Id) rc  -- ITC
                             --,ra_customers             rc
                             ,oe_transaction_types_tl  ott_tl
                        WHERE 1=1
                            -- AND c.customer_id         != rc.customer_id
                            AND c.cust_account_id         != rc.cust_account_id  -- ITC
                            AND hca.party_id           = rc.party_id
                            AND oh.sold_to_org_id      = hca.cust_account_id
                            --AND rc.cust_trx_type_id    = ct.cust_trx_type_id
                            AND rct.cust_trx_type_id    = ct.cust_trx_type_id  -- ITC
                            AND bs.batch_source_id     = ct.batch_source_id
                            AND bs_dfv.row_id          = bs.ROWID
                            --AND c.customer_id          = ct.bill_to_customer_id
                            AND c.cust_account_id          = ct.bill_to_customer_id  -- ITC
                            AND acc.customer_trx_id(+) = ct.customer_trx_id
                            AND ou.organization_id     = ct.org_id
                            AND bs_dfv.xx_ar_numera_trx_liq ='Y'
                            AND oh.order_number         = ct.attribute6
                            AND oh.order_type_id        = ott_tl.transaction_type_id
                            AND ott_tl.language         = 'ESA'
                            AND ott_tl.name             = ct.attribute5
                            AND bs_dfv.xxw_fac_elec IS NULL
                            AND (acc.customer_trx_id IS NULL OR acc.contrato_compra IS NULL )
                            and oh.ATTRIBUTE1 is not null
                            AND ct.complete_flag = 'Y'
                            --AND rc.post_to_gl    = 'Y'
                            AND rct.post_to_gl    = 'Y'  -- ITC
                            AND ct.attribute5 IS NOT NULL
                            AND ct.attribute6 IS NOT NULL
                            AND ou.NAME LIKE '%AR%UO'
                            AND ou.name != 'AR CHS UO'
                            AND ct.customer_trx_id=p_customer_trx_id
                            AND EXISTS (SELECT 1
                                        FROM   ra_customer_trx_lines_all ctl
                                        WHERE  ctl.customer_trx_id = ct.customer_trx_id
                                        AND    ctl.inventory_item_id is not null
                                       );
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  x_procesa := 'Y';
              WHEN OTHERS THEN
                  x_procesa := 'N';
          END;
       END XX_PROCESA;

    FUNCTION crear_doc (p_customer_trx_id  IN     ra_customer_trx_all.customer_trx_id%TYPE
                       ,p_batch_source_id  IN     ra_customer_trx_all.batch_source_id%TYPE
                       ,p_cust_trx_type_id IN     ra_interface_lines_all.cust_trx_type_id%TYPE
                       ,p_tax_id_ar        IN     ra_interface_lines_all.vat_tax_id%TYPE
                       ,p_memo_line_id     IN     ar_memo_lines_all_b.memo_line_id%TYPE
                       ,p_term_id_ar       IN     ra_customer_trx_all.term_id%TYPE
                       ,p_proceso          IN     VARCHAR2
                       ,l_cant_lineas      IN OUT NUMBER
                       ,p_conc_id          IN     NUMBER
                       ,p_fecha_override   IN     DATE
                       ) RETURN BOOLEAN IS

    l_return BOOLEAN;

    --CONTEXTOS INTERFACE
    l_interface_line_context    ra_interface_lines_all.interface_line_context%TYPE;
    l_interface_line_attribute1 ra_interface_lines_all.interface_line_attribute1%TYPE;
    l_interface_line_attribute2 ra_interface_lines_all.interface_line_attribute2%TYPE;
    l_interface_line_attribute5 ra_interface_lines_all.interface_line_attribute5%TYPE;

    --DATOS CABECERA
    l_set_of_books_id              ra_interface_lines_all.set_of_books_id%TYPE;
    l_cust_trx_type_id             ra_interface_lines_all.cust_trx_type_id%TYPE;
    l_orig_system_bill_customer_id ra_interface_lines_all.orig_system_bill_customer_id%TYPE;
    l_orig_system_bill_address_id  ra_interface_lines_all.orig_system_bill_address_id%TYPE;
    l_orig_system_ship_customer_id ra_interface_lines_all.orig_system_ship_customer_id%TYPE;
    l_orig_system_ship_address_id  ra_interface_lines_all.orig_system_ship_address_id%TYPE;
    l_orig_system_sold_customer_id ra_interface_lines_all.orig_system_sold_customer_id%TYPE;
    l_trx_date                     ra_interface_lines_all.trx_date%TYPE;
    l_gl_date                      ra_interface_lines_all.gl_date%TYPE;
    l_org_id                       ra_interface_lines_all.org_id%TYPE;
    l_bill_to_site_use_id          ra_customer_trx_all.bill_to_site_use_id%TYPE;
    l_ship_to_site_use_id          ra_customer_trx_all.ship_to_site_use_id%TYPE;

    l_bill_contact_id                   ra_customer_trx_all.bill_to_contact_id%TYPE;
    l_ship_contact_id                   ra_customer_trx_all.ship_to_contact_id%TYPE;

    l_post_to_gl                   ra_cust_trx_types_all.post_to_gl%TYPE;
    l_currency_code                ra_interface_lines_all.currency_code%TYPE;
    l_conversion_type              ra_interface_lines_all.conversion_type%TYPE;
    l_conversion_date              ra_interface_lines_all.conversion_date%TYPE;
    l_conversion_rate              ra_interface_lines_all.conversion_rate%TYPE;
    l_tax_code                     ra_interface_lines_all.tax_code%TYPE;
    l_tax_rate_code                ra_interface_lines_all.tax_rate_code%TYPE; --R12
    l_tax_regime_code              ra_interface_lines_all.tax_regime_code%TYPE; --R12
    l_tax                          ra_interface_lines_all.tax%TYPE; --R12
    l_tax_status_code              ra_interface_lines_all.tax_status_code%TYPE; --R12
    l_batch_source_name            ra_interface_lines_all.batch_source_name%TYPE;
    l_cust_trx_type_name           ra_interface_lines_all.cust_trx_type_name%TYPE;
    l_receipt_method_id            ra_interface_lines_all.receipt_method_id%TYPE;
    l_warehouse_id                 ra_interface_lines_all.warehouse_id%TYPE;
    l_trx_number                   ra_interface_lines_all.trx_number%TYPE;
    l_comments                     ra_interface_lines_all.comments%TYPE;
    l_tax_rate                     ra_interface_lines_all.tax_rate%TYPE;
    l_paying_customer_id           ra_interface_lines_all.paying_customer_id%TYPE;
    l_paying_site_use_id           ra_interface_lines_all.paying_site_use_id%TYPE;
    l_tax_account_id               ra_interface_distributions_all.code_combination_id%TYPE;

    l_code_combination_id          ra_interface_distributions_all.code_combination_id%TYPE;
    l_description                  ra_interface_lines_all.description%TYPE;
    l_description_tax              ra_interface_lines_all.description%TYPE;
    l_uom_code                     ra_interface_lines_all.uom_code%TYPE;
    l_global_attribute1            ra_customer_trx_lines_all.global_attribute1%TYPE;
    l_global_attribute2            ra_customer_trx_lines_all.global_attribute2%TYPE;

    l_type                         ra_cust_trx_types_all.type%TYPE;
    l_term_id_ar                   ra_cust_trx_types_all.cust_trx_type_id%TYPE;

    l_rec_code_combination         ra_interface_distributions_all.code_combination_id%TYPE;

    l_nombre_empresa               hr_locations.global_attribute8%TYPE;

    l_order_type                   oe_transaction_types_tl.name%TYPE;
    l_order_number                 oe_order_headers_all.order_number%TYPE;

    l_invoice_amount               NUMBER;

    v_rct_date   DATE;
    v_rctta_type RA_CUST_TRX_TYPES_ALL.TYPE%TYPE;
    v_void_level VARCHAR2(10);
    v_void_term  VARCHAR2(10);

    l_procesa                               VARCHAR2(1);
    l_contrato                     VARCHAR2(250);
    l_bill_contact_id_c               ra_customer_trx_all.bill_to_contact_id%TYPE;
    l_ship_contact_id_c              ra_customer_trx_all.ship_to_contact_id%TYPE;

    --CURSOR DATOS LINEAS
    CURSOR c_datos_linea (c_customer_trx_id ra_customer_trx_lines_all.customer_trx_id%TYPE
                         ,c_solo_imp        VARCHAR2
                         ,c_warehouse_id    ra_interface_lines_all.warehouse_id%TYPE) IS
       SELECT line_type
            , description
            , extended_amount
            , quantity_ordered
            , nvl(quantity_invoiced, quantity_credited) quantity_invoiced
            , unit_selling_price
            , unit_standard_price
            , memo_line_id
            , inventory_item_id
            , uom_code
            , tax_exempt_flag
            , amount_includes_tax_flag
            , global_attribute_category
            , global_attribute2
            , global_attribute3
            , nvl(warehouse_id, c_warehouse_id) warehouse_id
            , null vat_tax_id
            , customer_trx_line_id
            , DECODE(interface_line_context, 'ORDER_ENTRY', interface_line_attribute2, l_order_type)   order_type
            , DECODE(interface_line_context, 'ORDER_ENTRY', interface_line_attribute1, l_order_number) order_number
         FROM ra_customer_trx_lines_all rctl
        WHERE line_type = 'LINE'
          AND customer_trx_id = c_customer_trx_id
          --Verifico que el item sea un cereal, de hacienda o leche
          AND EXISTS (SELECT 1
                        FROM mtl_item_categories mic
                           , mtl_categories_b    mcb
                       WHERE nvl(mcb.attribute12,'VACIO') IN ('CEREAL','OTROS')
                         AND mic.category_id               = mcb.category_id
                         AND structure_id                  = 101
                         AND mic.inventory_item_id         = rctl.inventory_item_id
                         AND mic.organization_id           = nvl(rctl.warehouse_id, c_warehouse_id))
          --Analisis para copiar solo lineas que tengan impuestos diferentes de IVA a la transaccion real
          AND (c_solo_imp = 'N'
               OR (EXISTS (SELECT 1
                            FROM ra_customer_trx_lines_all rctl_tax
                           WHERE rctl_tax.link_to_cust_trx_line_id = rctl.customer_trx_line_id
                             AND rctl_tax.line_type = 'TAX'
                             AND rctl_tax.extended_amount <> 0
                             --Verifica que los impuestos que se van a copiar no sean del grupo IVA
                             AND NOT EXISTS (SELECT 1
                                               FROM ar_vat_tax_all_b avt
                                                  , jl_zz_ar_tx_categ_all jzatc
                                              WHERE avt.vat_tax_id           = rctl_tax.vat_tax_id
                                                AND jzatc.tax_category_id    = avt.global_attribute1
                                                AND jzatc.tax_category       = 'VAT'
                                                AND rctl_tax.org_id          = jzatc.org_id )
                                                AND rctl_tax.customer_trx_id = rctl.customer_trx_id)));

    CURSOR c_datos_imp(c_customer_trx_id ra_customer_trx_lines_all.customer_trx_id%TYPE
                      ,c_warehouse_id    ra_interface_lines_all.warehouse_id%TYPE
                      )
    IS
       SELECT line_type
            , description
            , extended_amount
            , quantity_ordered
            , unit_selling_price
            , unit_standard_price
            , memo_line_id
            , inventory_item_id
            , uom_code
            , tax_exempt_flag
            , amount_includes_tax_flag
            , global_attribute_category
            , global_attribute2
            , global_attribute3
            , nvl(warehouse_id,c_warehouse_id) warehouse_id
            , vat_tax_id
            , customer_trx_line_id
            , tax_rate
            , link_to_cust_trx_line_id
         FROM apps.ra_customer_trx_lines_all rctl
        WHERE line_type = 'TAX'
          AND extended_amount <>0
          --Verifica que los impuestos que se van a copiar no sean del grupo IVA
          AND NOT EXISTS (SELECT 1
                            FROM ar_vat_tax_all_b avt
                               , jl_zz_ar_tx_categ_all jzatc
                           WHERE avt.vat_tax_id        = rctl.vat_tax_id
                             AND jzatc.tax_category_id = avt.global_attribute1
                             AND jzatc.tax_category    = 'VAT'
                             AND rctl.org_id           = jzatc.org_id )
          AND customer_trx_id = c_customer_trx_id;

    --CURSOR DATOS DISTRIBUCIONES
    CURSOR c_datos_dist (c_customer_trx_line_id ra_customer_trx_lines_all.customer_trx_id%TYPE)
    IS
       SELECT account_class
            , amount
            , percent
            , code_combination_id
            , org_id
         FROM ra_cust_trx_line_gl_dist_all
        WHERE customer_trx_line_id = c_customer_trx_line_id;

       BEGIN

          e_message:= null;
          l_invoice_amount := 0;

          SAVEPOINT inicio_crear_doc;

          IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'Inicio XX_AR_TRX_FICTICIA_PKG.crear_doc '||to_char(sysdate,'HH24:MI:SS'));
             fnd_file.put_line(fnd_file.log,'Parametros:');
             fnd_file.put_line(fnd_file.log,'p_customer_trx_id: '||p_customer_trx_id);
             fnd_file.put_line(fnd_file.log,'p_batch_source_id: '||p_batch_source_id);
             fnd_file.put_line(fnd_file.log,'p_cust_trx_type_id: '||p_cust_trx_type_id);
             fnd_file.put_line(fnd_file.log,'p_proceso: '||p_proceso);
          END IF;

          --------------------------------DATOS INTERFAZ-------------------------------
          l_interface_line_context    := 'XX_AR_FC_PERCEP';
          --l_interface_line_attribute1 Se obtiene en los datos de cabecera el trx_number para este campo
          l_interface_line_attribute2 := p_customer_trx_id;
          --l_interface_line_attribute3 Se utilizara para dividir lineas de una misma factura
          --l_interface_line_attribute4 Se utilizara para guardar el concurrente de ejecucion
          --l_interface_line_attribute5 Se utilizara para guardar el customer_trx_id original

         --------------------------------DATOS CABECERA--------------------------------
          BEGIN
             SELECT rct.set_of_books_id
                  , rct.bill_to_customer_id
                  , rct.bill_to_site_use_id
                  , rct.ship_to_customer_id
                  , rct.ship_to_site_use_id
                  , rct.sold_to_customer_id
                  , rct.paying_customer_id
                  , rct.paying_site_use_id
                  , rct.org_id
                  , nvl(rct.exchange_rate_type,'User')
                  , nvl(rct.exchange_date,sysdate)
                  , nvl(rct.exchange_rate,1)
                  , rct.invoice_currency_code
                  , rct.trx_number
                  , rct.trx_date
                  , rct.receipt_method_id
                  , rct.trx_number
                  , rct_dfv.xx_ar_tipo_pedido_om
                  , rct_dfv.xx_ar_nro_pedido_om
                  , DECODE(p_proceso,'F','',rct.comments)
                  , nvl(rct.interface_header_attribute5,p_customer_trx_id)
                  , rct.ship_to_contact_id
                  , rct.bill_to_contact_id
               INTO l_set_of_books_id
                  , l_orig_system_bill_customer_id
                  , l_bill_to_site_use_id
                  , l_orig_system_ship_customer_id
                  , l_ship_to_site_use_id
                  , l_orig_system_sold_customer_id
                  , l_paying_customer_id
                  , l_paying_site_use_id
                  , l_org_id
                  , l_conversion_type
                  , l_conversion_date
                  , l_conversion_rate
                  , l_currency_code
                  , l_interface_line_attribute1 --DATO PARA LA REFERENCIA CON EL DOCUMENTO ORIGINAL
                  , l_trx_date
                  , l_receipt_method_id
                  , l_trx_number
                  , l_order_type
                  , l_order_number
                  , l_comments
                  , l_interface_line_attribute5
                  , l_ship_contact_id
                  , l_bill_contact_id
               FROM ra_customer_trx_all rct
                  , ra_customer_trx_all_dfv rct_dfv
              WHERE rct.rowid           = rct_dfv.row_id
                AND rct.customer_trx_id = p_customer_trx_id;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                e_message:= 'Error: No se encontro la transaccion que se quiere copiar para customer_trx_id: '||p_customer_trx_id;
                fnd_file.put_line(fnd_file.log,e_message);
                e_retcode:=1;
                ROLLBACK TO inicio_crear_doc;
                RETURN FALSE;

             WHEN OTHERS THEN
                e_message:= 'Error general buscando trx para copiar para p_customer_trx_id: '||p_customer_trx_id||' Error Sql: '||sqlerrm;
                fnd_file.put_line(fnd_file.log,e_message);
                e_retcode:=1;
                ROLLBACK TO inicio_crear_doc;
                RETURN FALSE;
          END;


          ------VERIFICAR SI ASOCIA CONTRATO-------------
          XX_PROCESA(p_customer_trx_id => p_customer_trx_id
                                   ,x_contrato                 => l_contrato
                                   ,x_procesa                 => l_procesa
                                   );
               IF l_procesa = 'N'
          THEN
              ROLLBACK TO inicio_crear_doc;
            RETURN FALSE;
          ELSE
              -------------------VERIFICAR l_orig_system_bill_addres_id-----------------
              BEGIN
                 SELECT cust_acct_site_id
                 INTO   l_orig_system_bill_address_id
                 FROM   hz_cust_site_uses_all
                 WHERE  site_use_id = l_bill_to_site_use_id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    e_message:= 'Error: No se encontro cust_acct_site_id para: '||l_bill_to_site_use_id;
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;

                  WHEN OTHERS THEN
                    e_message:= 'Error general buscando cust_acct_site_id para : '||l_bill_to_site_use_id||' Error Sql: '||sqlerrm;
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;
              END;

              -------------------VERIFICAR l_orig_system_ship_addres_id-----------------
              BEGIN
                 SELECT cust_acct_site_id
                 INTO   l_orig_system_ship_address_id
                 FROM   hz_cust_site_uses_all
                 WHERE  site_use_id = l_ship_to_site_use_id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    e_message:= 'Error: No se encontro cust_acct_site_id para: '||l_ship_to_site_use_id;
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;
                 WHEN OTHERS THEN
                    e_message:= 'Error general buscando cust_acct_site_id para : '||l_ship_to_site_use_id||' Error Sql: '||sqlerrm;
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;
              END;
                    --obtengo el contact de la direccion del cliente.Sino tiene busco el del cliente
              /*sino tiene contacto la transaccion original, entonces no pone nada
                    IF l_bill_contact_id IS NULL
                    THEN
                BEGIN
                            SELECT CUST_ACCOUNT_ROLE_ID
                            INTO l_bill_contact_id
                            FROM HZ_CUST_ACCOUNT_ROLES
                            WHERE CUST_ACCT_SITE_ID=l_orig_system_bill_address_id
                                AND CUST_ACCOUNT_ID=l_orig_system_bill_customer_id
                                AND CURRENT_ROLE_STATE='A'
                                AND ROWNUM=1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                BEGIN
                                    SELECT CUST_ACCOUNT_ROLE_ID
                                    INTO l_bill_contact_id
                                    FROM HZ_CUST_ACCOUNT_ROLES
                                    WHERE CUST_ACCOUNT_ID=l_orig_system_bill_customer_id
                                        AND CURRENT_ROLE_STATE='A'
                                        AND ROWNUM=1;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        l_bill_contact_id:=null;
                                END;
                            WHEN OTHERS THEN
                                    l_bill_contact_id:=null;
                        END;
                    END IF;
              IF l_ship_contact_id IS NULL
                    THEN
                BEGIN
                            SELECT CUST_ACCOUNT_ROLE_ID
                            INTO l_ship_contact_id
                            FROM HZ_CUST_ACCOUNT_ROLES
                            WHERE CUST_ACCT_SITE_ID=l_orig_system_ship_address_id
                                AND CUST_ACCOUNT_ID=l_orig_system_ship_customer_id
                                AND CURRENT_ROLE_STATE='A'
                                AND ROWNUM=1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                BEGIN
                                    SELECT CUST_ACCOUNT_ROLE_ID
                                    INTO l_ship_contact_id
                                    FROM HZ_CUST_ACCOUNT_ROLES
                                    WHERE CUST_ACCOUNT_ID=l_orig_system_ship_customer_id
                                        AND CURRENT_ROLE_STATE='A'
                                        AND ROWNUM=1;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        l_ship_contact_id:=null;
                                END;
                            WHEN OTHERS THEN
                                    l_ship_contact_id:=null;
                        END
                    END IF;
              */
              --frozados obtengo el contacto del cliente cuando es circuito corredor/productor
              IF p_proceso = 'F'
              THEN
                  IF l_bill_contact_id IS NOT NULL
                  THEN
                      BEGIN
                          SELECT RCC.CONTACT_ID
                          INTO l_bill_contact_id_c
                          FROM OE_ORDER_HEADERS_ALL OOH
                                  ,OE_TRANSACTION_TYPES_ALL OOT
                        ,OE_TRANSACTION_TYPES_TL OTTL
                        ,/*RA_CUSTOMERS*/OE_RA_CUSTOMERS_V RC --R12
                        ,/*RA_CONTACTS*/ OE_RA_CONTACTS_V RCC --R12
                          WHERE ORDER_NUMBER=l_order_number
                              AND OTTL.NAME=l_order_type
                      AND OOH.ORDER_TYPE_ID=OOT.TRANSACTION_TYPE_ID
                      AND OOT.TRANSACTION_TYPE_ID=OTTL.TRANSACTION_TYPE_ID
                      AND OTTL.LANGUAGE='ESA'
                      AND RC.CUSTOMER_ID=OOH.SOLD_TO_ORG_ID
                      AND RCC.CUSTOMER_ID=RC.CUSTOMER_ID
                      AND OOH.SOLD_TO_ORG_ID!=l_orig_system_bill_customer_id
                      AND RCC.STATUS='A'
                      AND RCC.ADDRESS_ID IS NULL
                      AND ROWNUM=1;
                      EXCEPTION
                          WHEN OTHERS THEN
                              l_bill_contact_id_c:=null;
                      END;
                  END IF;
                  IF l_ship_contact_id IS NOT NULL
                  THEN
                      BEGIN
                          SELECT RCC.CONTACT_ID
                          INTO l_ship_contact_id_c
                          FROM OE_ORDER_HEADERS_ALL OOH
                                  ,OE_TRANSACTION_TYPES_ALL OOT
                        ,OE_TRANSACTION_TYPES_TL OTTL
                        ,/*RA_CUSTOMERS*/OE_RA_CUSTOMERS_V RC --R12
                        ,/*RA_CONTACTS*/ OE_RA_CONTACTS_V RCC --R12
                          WHERE ORDER_NUMBER=l_order_number
                              AND OTTL.NAME=l_order_type
                      AND OOH.ORDER_TYPE_ID=OOT.TRANSACTION_TYPE_ID
                      AND OOT.TRANSACTION_TYPE_ID=OTTL.TRANSACTION_TYPE_ID
                      AND OTTL.LANGUAGE='ESA'
                      AND RC.CUSTOMER_ID=OOH.SOLD_TO_ORG_ID
                      AND RCC.CUSTOMER_ID=RC.CUSTOMER_ID
                      AND OOH.SOLD_TO_ORG_ID!=l_orig_system_ship_customer_id
                      AND RCC.STATUS='A'
                      AND RCC.ADDRESS_ID IS NULL
                      AND ROWNUM=1;
                      EXCEPTION
                          WHEN OTHERS THEN
                              l_ship_contact_id_c:=null;
                      END;
                  END IF;
              END IF;

                    IF l_bill_contact_id_c IS NOT NULL
                    THEN
                        l_bill_contact_id:=l_bill_contact_id_c;
                    END IF;
                    IF l_ship_contact_id_c IS NOT NULL
                    THEN
                        l_ship_contact_id:=l_ship_contact_id_c;
                    END IF;

              BEGIN
                 SELECT nvl(rctt.type,'INV')
                      , rctt_dfv.tax_code
                 INTO   l_type
                      , l_tax_code
                 FROM   ra_cust_trx_types_all      rctt
                      , ra_cust_trx_types_all1_dfv rctt_dfv
                  WHERE rctt.rowid            = rctt_dfv.row_id
                  AND   rctt.cust_trx_type_id = p_cust_trx_type_id;

                 -------------------------Terminos de pago en Nulo para NCs----------------
                 IF l_type = 'CM' THEN
                    l_term_id_ar := null;
                 ELSE
                    l_term_id_ar := p_term_id_ar;
                 END IF;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    e_message:= 'Error: No se encontro type para p_cust_trx_type_id: '||p_cust_trx_type_id;
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;

                 WHEN OTHERS THEN
                    e_message:= 'Error general buscando type para p_cust_trx_type_id: '||p_cust_trx_type_id;
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;
              END;

              -------------------------Obtengo Warehouse_id-----------------------------
              IF NOT obtener_warehouse_id (l_org_id, l_warehouse_id) THEN
                 ROLLBACK TO inicio_crear_doc;
                 RETURN FALSE;
              END IF;

              -----------------------VERIFICAR p_batch_source_id-------------------------
              BEGIN
                 SELECT name
                   INTO l_batch_source_name
                   FROM ra_batch_sources_all
                  WHERE batch_source_id        = p_batch_source_id
                    AND nvl(end_date,sysdate) >= sysdate
                    AND org_id                 = l_org_id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     e_message:= 'Error: No se encontro batch_source_name para: '||p_batch_source_id;
                     fnd_file.put_line(fnd_file.log,e_message);
                     e_retcode:=1;
                     ROLLBACK TO inicio_crear_doc;
                     RETURN FALSE;

                 WHEN OTHERS THEN
                     e_message:= 'Error general buscando p_batch_source_name: '||p_batch_source_id||'Error sql:'||sqlerrm;
                     fnd_file.put_line(fnd_file.log,e_message);
                     e_retcode:=1;
                     ROLLBACK TO inicio_crear_doc;
                     RETURN FALSE;
              END;

              -----------------------VERIFICAR p_cust_trx_type_id------------------------
              BEGIN
                 SELECT name
                      , nvl(post_to_gl,'N')
                   INTO l_cust_trx_type_name
                      , l_post_to_gl
                   FROM ra_cust_trx_types_all
                  WHERE cust_trx_type_id       = p_cust_trx_type_id
                    AND nvl(end_date,sysdate) >= sysdate
                    AND org_id                 = l_org_id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     e_message:= 'Error: No se encontro cust_trx_type_name para: '||p_cust_trx_type_id;
                     fnd_file.put_line(fnd_file.log,e_message);
                     e_retcode:=1;
                     ROLLBACK TO inicio_crear_doc;
                     RETURN FALSE;

                 WHEN OTHERS THEN
                     e_message:= 'Error general buscando p_cust_trx_type_name: '||p_cust_trx_type_id||' Error sql:'||sqlerrm;
                     fnd_file.put_line(fnd_file.log,e_message);
                     e_retcode:=1;
                     ROLLBACK TO inicio_crear_doc;
                     RETURN FALSE;
              END;

              -----------------------------------ANALISIS Fechas---------------------------
              IF NOT fecha_doc(l_trx_date
                              ,p_batch_source_id
                              ,p_fecha_override)
              THEN
                  fnd_file.put_line(fnd_file.log,'not fecha doc');
                 ROLLBACK TO inicio_crear_doc;
                 RETURN FALSE;
              END IF;

              --Si la transaccion no contabiliza en GL entonces la fecha de GL se debe pasar en blanco
              IF l_post_to_gl = 'N' THEN
                 l_gl_date := NULL;
                  ELSE
                 l_gl_date := l_trx_date;
                  END IF;

              ---------------------ANALISIS Cuenta Cliente---------------------------------
              BEGIN
                 SELECT code_combination_id
                 INTO   l_code_combination_id
                 FROM   ra_cust_trx_line_gl_dist_all
                 WHERE  account_class = 'REC'
                 AND customer_trx_id = p_customer_trx_id;

              EXCEPTION
                 WHEN OTHERS THEN
                     e_message:= 'Error general buscando contabilidad para p_cust_trx_type_name: '||p_cust_trx_type_id||' Error sql:'||sqlerrm;
                     fnd_file.put_line(fnd_file.log,e_message);
                     e_retcode:=1;
                     ROLLBACK TO inicio_crear_doc;
                     RETURN FALSE;
              END;


              ----------------------ANALISIS Nombre Empresa--------------------------------
              BEGIN
                 SELECT nvl(hl.global_attribute8, hl.description)
                 INTO   l_nombre_empresa
                 FROM   hr_all_organization_units haou
                       ,hr_locations hl
                 WHERE  haou.location_id = hl.location_id
                 AND    haou.organization_id = l_org_id;

              EXCEPTION
                 WHEN OTHERS THEN
                     e_message:= 'Error general buscando nombre empresa para l_org_id: '||l_org_id||' Error sql:'||sqlerrm;
                     fnd_file.put_line(fnd_file.log,e_message);
                     e_retcode:=1;
                     ROLLBACK TO inicio_crear_doc;
                     RETURN FALSE;
              END;

              --Proceso creacion transacciones Ficticias
              IF p_proceso = 'F' THEN

                 l_invoice_amount := 0;

                 FOR c_line IN c_datos_linea(p_customer_trx_id ,'N' ,l_warehouse_id) LOOP

                    l_comments:= null;

                    l_cant_lineas := l_cant_lineas + 1;

                    -------------------------DATOS PRODUCTOR-------------------------------
                    IF c_line.order_type IS NOT NULL AND c_line.order_number IS NOT NULL THEN

                       BEGIN
                          SELECT --rc.customer_id
                               rc.cust_account_id -- ITC
                               , ooh.invoice_to_org_id
                               --, rc.customer_id
                               , rc.cust_account_id -- ITC
                               , ooh.ship_to_org_id
                               --, rc.customer_id
                               , rc.cust_account_id -- ITC
                               --Solo se despliega en caso de que el cliente de la factura original sea diferente al del pedido
                               , CASE WHEN l_orig_system_bill_customer_id != rc.cust_account_id -- ITC --rc.customer_id
                                                                                           THEN 'Contrato:'||substr((SELECT xaacc.contrato_compra
                                                                                                                      FROM   xx_ar_asocia_contrato_compra xaacc
                                                                                                                      WHERE  p_customer_trx_id = xaacc.customer_trx_id),1,30)
                                                                                                            ||' - '
                                                                                                          --||substr(rc1.customer_name,1,50)||chr(10)
                                                                                                            ||substr(rc1.party_name,1,50)||chr(10)  -- ITC
                                 ELSE null
                                 END
                               , l_orig_system_bill_customer_id
                               , l_bill_to_site_use_id
                            INTO l_orig_system_bill_customer_id
                               , l_bill_to_site_use_id
                               , l_orig_system_ship_customer_id
                               , l_ship_to_site_use_id
                               , l_orig_system_sold_customer_id
                               , l_comments
                               , l_paying_customer_id
                               , l_paying_site_use_id
                            FROM oe_order_headers_all ooh
                               , oe_transaction_types_tl ottt
                               , hz_cust_accounts hca
                               , hz_parties       hp
                               --, ra_customers     rc
                             ,(SELECT hca.cust_account_id
                                       ,hp.party_id
                                  FROM hz_parties hp,
                                       hz_cust_accounts hca
                                 WHERE 1=1
                                   AND hp.Party_Id = hca.Party_Id) rc -- ITC
                               --, ra_customers     rc1
                             ,(SELECT hca.cust_account_id
                                      ,substrb(hp.party_name,1,50) party_name
                                 FROM hz_parties hp,
                                      hz_cust_accounts hca
                                WHERE 1=1
                                  AND hp.Party_Id = hca.Party_Id) rc1
                           WHERE 1=1
                           --AND rc1.customer_id          = l_orig_system_bill_customer_id
                           AND rc1.cust_account_id      = l_orig_system_bill_customer_id
                             AND hp.party_id              = rc.party_id
                             AND hca.party_id             = hp.party_id
                             AND ooh.sold_to_org_id       = hca.cust_account_id
                             AND ottt.transaction_type_id = ooh.order_type_id
                             AND ottt.language            = userenv('LANG')
                             AND ottt.name                = c_line.order_type
                             AND ooh.order_number         = c_line.order_number
                             AND ooh.org_id               = l_org_id;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             e_message:= 'Error: No se encontraron datos de productor para  p_customer_trx_id: '||p_customer_trx_id||
                                                                                         ', l_order_type: '||c_line.order_type||
                                                                                         ', l_order_number: '||c_line.order_number||
                                                                                         ', l_org_id: '||l_org_id||
                                                                                         ', l_orig_system_bill_customer_id: '||l_orig_system_bill_customer_id;
                             fnd_file.put_line(fnd_file.log,e_message);
                             e_retcode:=1;
                             ROLLBACK TO inicio_crear_doc;
                             RETURN FALSE;

                          WHEN OTHERS THEN
                             e_message:= 'Error general buscando datos de productor para  p_customer_trx_id: '||p_customer_trx_id||
                                                                                       ', l_order_type: '||c_line.order_type||
                                                                                       ', l_order_number: '||c_line.order_number||
                                                                                       ', l_org_id: '||l_org_id||
                                                                                       ', l_orig_system_bill_customer_id: '||l_orig_system_bill_customer_id;
                             fnd_file.put_line(fnd_file.log,e_message);
                             e_retcode:=1;
                             ROLLBACK TO inicio_crear_doc;
                             RETURN FALSE;
                       END;

                       -------------------VERIFICAR l_orig_system_bill_addres_id-----------------
                       BEGIN
                          SELECT cust_acct_site_id
                          INTO   l_orig_system_bill_address_id
                          FROM   hz_cust_site_uses_all
                          WHERE  site_use_id = l_bill_to_site_use_id;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             e_message:= 'Error: No se encontro cust_acct_site_id para: '||l_bill_to_site_use_id;
                             fnd_file.put_line(fnd_file.log,e_message);
                             e_retcode:=1;
                             ROLLBACK TO incio;
                             RETURN FALSE;

                          WHEN OTHERS THEN
                             e_message:= 'Error general buscando cust_acct_site_id para : '||l_bill_to_site_use_id||' Error Sql: '||sqlerrm;
                             fnd_file.put_line(fnd_file.log,e_message);
                             e_retcode:=1;
                             ROLLBACK TO inicio_crear_doc;
                             RETURN FALSE;
                       END;

                       -------------------VERIFICAR l_orig_system_ship_addres_id-----------------
                       BEGIN
                          SELECT cust_acct_site_id
                          INTO   l_orig_system_ship_address_id
                          FROM   hz_cust_site_uses_all
                          WHERE  site_use_id = l_ship_to_site_use_id;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             e_message:= 'Error: No se encontro cust_acct_site_id para: '||l_ship_to_site_use_id;
                             fnd_file.put_line(fnd_file.log,e_message);
                             e_retcode:=1;
                             ROLLBACK TO inicio_crear_doc;
                             RETURN FALSE;

                          WHEN OTHERS THEN
                                e_message:= 'Error general buscando cust_acct_site_id para : '||l_ship_to_site_use_id||' Error Sql: '||sqlerrm;
                                fnd_file.put_line(fnd_file.log,e_message);
                                e_retcode:=1;
                                ROLLBACK TO inicio_crear_doc;
                                RETURN FALSE;
                       END;

                       -------------------------Analisis Receipt_method_id--------------------------
                       IF l_receipt_method_id IS NOT NULL THEN

                          IF NOT habilitar_metodo_cobro(l_orig_system_bill_customer_id
                                                       ,l_bill_to_site_use_id
                                                       ,l_receipt_method_id
                                                       ,l_trx_date) THEN
                             ROLLBACK TO inicio_crear_doc;
                             RETURN FALSE;
                          END IF;

                       END IF;

                       -----------------Analisis Relacion productor / corredor---------------------
                       IF NOT habilitar_relacion(l_orig_system_bill_customer_id --p_corredor       IN NUMBER
                                                ,l_paying_customer_id           --p_productor      IN NUMBER
                                                ,'Y'                            --p_reciproca      IN VARCHAR2
                                                ,l_org_id)THEN
                             ROLLBACK TO inicio_crear_doc;
                             RETURN FALSE;
                       END IF;

                    END IF;

                    BEGIN
                       l_comments:= l_comments||'Documento ficticio s/liq '||l_trx_number||chr(10)
                                              ||'Documentos emitidos por '||l_nombre_empresa||' en cumplimiento de sus obligaciones como Agente de Percepcion de IIBB';
                    EXCEPTION
                      WHEN OTHERS THEN
                          e_message:= l_comments||'Documento ficticio s/liq '||l_trx_number||chr(10)
                                                ||'Documentos emitidos por '||l_nombre_empresa||' en cumplimiento de sus obligaciones como Agente de Percepcion de IIBB'||chr(10)
                                                ||'Largo Comentarios: '||length(l_comments||'Documento ficticio s/liq '||l_trx_number||chr(10)
                                                ||'Documentos emitidos por '||l_nombre_empresa||' en cumplimiento de sus obligaciones como Agente de Percepcion de IIBB');
                          fnd_message.retrieve(e_message);
                          e_retcode:=1;
                          ROLLBACK TO inicio_crear_doc;
                          RETURN FALSE;
                    END;
                     --FROZADOS Se agrega validacion de tamano del comentario
                    IF length(l_comments) >= 240
                    THEN
                        SELECT substr(l_comments,1,240) INTO l_comments FROM dual;
                      END IF;

                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'Linea customer_trx_line_id: '||c_line.customer_trx_line_id);
                    END IF;

                    INSERT INTO ra_interface_lines_all (created_by ,creation_date ,last_updated_by ,last_update_date,last_update_login,interface_line_context,interface_line_attribute1,interface_line_attribute2
                                                       ,batch_source_name ,set_of_books_id ,cust_trx_type_name ,orig_system_bill_customer_id ,orig_system_bill_address_id
                                                       ,orig_system_ship_customer_id ,orig_system_ship_address_id ,orig_system_sold_customer_id ,trx_date ,gl_date ,org_id ,line_type
                                                       ,description ,currency_code ,amount ,conversion_type ,conversion_date ,conversion_rate ,quantity ,quantity_ordered ,unit_selling_price
                                                       ,unit_standard_price ,memo_line_id ,inventory_item_id ,uom_code ,tax_exempt_flag ,amount_includes_tax_flag ,line_gdf_attr_category
                                                       ,line_gdf_attribute2 ,line_gdf_attribute3 ,warehouse_id ,vat_tax_id ,cust_trx_type_id ,term_id ,tax_code ,interface_line_attribute3
                                                       ,receipt_method_id ,trx_number ,comments ,interface_line_attribute4 ,paying_customer_id ,paying_site_use_id, interface_line_attribute5,
                                                       ORIG_SYSTEM_BILL_CONTACT_ID,ORIG_SYSTEM_SHIP_CONTACT_ID)
                                                VALUES (g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_interface_line_context ,l_interface_line_attribute1,l_interface_line_attribute2
                                                       ,l_batch_source_name ,l_set_of_books_id ,l_cust_trx_type_name ,l_orig_system_bill_customer_id ,l_orig_system_bill_address_id
                                                       ,l_orig_system_ship_customer_id ,l_orig_system_ship_address_id ,l_orig_system_sold_customer_id ,l_trx_date ,l_gl_date,l_org_id ,c_line.line_type
                                                       ,c_line.description ,l_currency_code ,c_line.extended_amount ,l_conversion_type ,l_conversion_date ,l_conversion_rate ,c_line.quantity_invoiced ,c_line.quantity_ordered,c_line.unit_selling_price
                                                       ,c_line.unit_standard_price ,c_line.memo_line_id ,c_line.inventory_item_id ,c_line.uom_code ,c_line.tax_exempt_flag ,c_line.amount_includes_tax_flag,c_line.global_attribute_category
                                                       ,c_line.global_attribute2 ,c_line.global_attribute3 ,c_line.warehouse_id, c_line.vat_tax_id, p_cust_trx_type_id, l_term_id_ar, l_tax_code,c_line.customer_trx_line_id
                                                       ,l_receipt_method_id ,l_trx_number ,l_comments ,p_conc_id ,l_paying_customer_id ,l_paying_site_use_id, l_interface_line_attribute5
                                                       ,l_BILL_CONTACT_ID,l_ship_CONTACT_ID);

                    l_invoice_amount := l_invoice_amount + c_line.extended_amount;

                    FOR c_dist IN c_datos_dist(c_line.customer_trx_line_id) LOOP

                       IF g_debug = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,'Impuesto customer_trx_line_id: '||c_line.customer_trx_line_id);
                       END IF;

                       INSERT INTO ra_interface_distributions_all (interface_line_context ,interface_line_attribute1 ,interface_line_attribute2 ,account_class ,amount ,percent
                                                                  ,code_combination_id ,created_by ,creation_date ,last_updated_by ,last_update_date ,last_update_login ,org_id, interface_line_attribute3 ,interface_line_attribute4
                                                                  ,interface_line_attribute5)
                                                          VALUES  (l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,c_dist.account_class,c_dist.amount ,c_dist.percent
                                                                  ,c_dist.code_combination_id ,g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,c_dist.org_id, c_line.customer_trx_line_id ,p_conc_id
                                                                  ,l_interface_line_attribute5);

                    END LOOP;

                 END LOOP;

                 IF l_cant_lineas = 0 THEN
                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'No se crearon lineas en la interface');
                    END IF;

                 ELSIF l_cant_lineas = 1 THEN
                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'Se creo '||l_cant_lineas||' linea item en la interface');
                    END IF;

                 ELSIF l_cant_lineas > 1 THEN
                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'Se crearon '||l_cant_lineas||' lineas item en la interface');
                    END IF;

                 END IF;

                 IF l_cant_lineas >= 1 THEN
                    INSERT INTO ra_interface_distributions_all (interface_line_context ,interface_line_attribute1 ,interface_line_attribute2 ,account_class ,amount ,percent
                                                                     ,code_combination_id ,created_by ,creation_date ,last_updated_by ,last_update_date ,last_update_login ,org_id, interface_line_attribute3 ,interface_line_attribute4
                                                                     ,interface_line_attribute5)
                                                             VALUES  (l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,'REC' ,l_invoice_amount ,100
                                                                     ,l_code_combination_id ,g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_org_id, null ,p_conc_id
                                                                     ,l_interface_line_attribute5);
                  END IF;

              --Proceso creacion transacciones Reales
              ELSIF p_proceso = 'R' THEN

                 BEGIN
                    SELECT decode(nvl(rctt.type,'INV')
                                 ,'CM' , abs(g_monto_lineas_0)*-1
                                 ,abs(g_monto_lineas_0))
                         , rctt_dfv.tax_code
                         /*Agregado KHRONUS/E.Sly 20190610 Las NC Calculan Percepcion segun Lookup XX_AR_CM_TAX_JURISDICTION*/
                         , rctt.type
                         /*Fin Agregado KHRONUS/E.Sly 20190610 Las NC Calculan Percepcion segun Lookup XX_AR_CM_TAX_JURISDICTION*/
                    INTO  g_monto_lineas_0
                        , l_tax_code
                          /*Agregado KHRONUS/E.Sly 20190610 Las NC Calculan Percepcion segun Lookup XX_AR_CM_TAX_JURISDICTION*/
                        , v_rctta_type
                          /*Fin Agregado KHRONUS/E.Sly 20190610 Las NC Calculan Percepcion segun Lookup XX_AR_CM_TAX_JURISDICTION*/
                    FROM  ra_cust_trx_types_all rctt
                        , ra_cust_trx_types_all1_dfv rctt_dfv
                    WHERE rctt.rowid            = rctt_dfv.row_id
                    AND   rctt.cust_trx_type_id = p_cust_trx_type_id;

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       e_message:= 'Error: No se encontro signo para: '||p_cust_trx_type_id;
                       fnd_file.put_line(fnd_file.log,e_message);
                       e_retcode:=1;
                       ROLLBACK TO inicio_crear_doc;
                       RETURN FALSE;

                    WHEN OTHERS THEN
                       e_message:= 'Error general buscando signo para: '||p_cust_trx_type_id||' Error sql:'||sqlerrm;
                       fnd_file.put_line(fnd_file.log,e_message);
                       e_retcode:=1;
                       ROLLBACK TO inicio_crear_doc;
                       RETURN FALSE;
                 END;

                 BEGIN
                    SELECT uom_code
                      INTO l_uom_code
                      FROM ar_memo_lines_all_b
                     WHERE memo_line_id = p_memo_line_id;

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       e_message:= 'Error: No se encontro udm para memo_line_id: '||p_memo_line_id;
                       fnd_file.put_line(fnd_file.log,e_message);
                       e_retcode:=1;
                       ROLLBACK TO inicio_crear_doc;
                       RETURN FALSE;

                    WHEN OTHERS THEN
                       e_message:= 'Error general buscando udm para memo_line_id: '||p_memo_line_id||' Error sql:'||sqlerrm;
                       fnd_file.put_line(fnd_file.log,e_message);
                       e_retcode:=1;
                       ROLLBACK TO inicio_crear_doc;
                       RETURN FALSE;
                 END;

                 BEGIN

                    l_comments:= replace(l_comments, 'ficticio','pura percepcion');

                 EXCEPTION
                 WHEN OTHERS THEN
                    e_message:= replace(l_comments, 'ficticio','pura percepcion')||chr(10)||'Largo Comentario: '||length(replace(l_comments, 'ficticio','pura percepcion'));
                    fnd_file.put_line(fnd_file.log,e_message);
                    e_retcode:=1;
                    ROLLBACK TO inicio_crear_doc;
                    RETURN FALSE;
                 END;

                 --CREACION DE LINEAS CON MONTO 0
                 FOR c_line IN c_datos_linea(p_customer_trx_id ,'Y' ,l_warehouse_id) LOOP

                    l_cant_lineas := l_cant_lineas + 1;

                    INSERT INTO ra_interface_lines_all (created_by ,creation_date ,last_updated_by ,last_update_date,last_update_login,interface_line_context,interface_line_attribute1,interface_line_attribute2
                                                       ,batch_source_name ,set_of_books_id ,cust_trx_type_name ,orig_system_bill_customer_id ,orig_system_bill_address_id
                                                       ,orig_system_ship_customer_id ,orig_system_ship_address_id ,orig_system_sold_customer_id ,trx_date ,gl_date ,org_id ,line_type
                                                       ,description ,currency_code ,amount ,conversion_type ,conversion_date ,conversion_rate ,quantity ,quantity_ordered ,unit_selling_price
                                                       ,unit_standard_price ,memo_line_id ,inventory_item_id ,uom_code ,tax_exempt_flag ,amount_includes_tax_flag ,line_gdf_attr_category
                                                       ,line_gdf_attribute2 ,line_gdf_attribute3 ,warehouse_id, vat_tax_id, cust_trx_type_id, term_id, tax_code,interface_line_attribute3
                                                       ,receipt_method_id ,comments ,interface_line_attribute4 ,paying_customer_id ,paying_site_use_id, interface_line_attribute5
                                                       ,ORIG_SYSTEM_BILL_CONTACT_ID,ORIG_SYSTEM_SHIP_CONTACT_ID)
                                                VALUES (g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_interface_line_context ,l_interface_line_attribute1,l_interface_line_attribute2
                                                       ,l_batch_source_name ,l_set_of_books_id ,l_cust_trx_type_name ,l_orig_system_bill_customer_id ,l_orig_system_bill_address_id
                                                       ,l_orig_system_ship_customer_id ,l_orig_system_ship_address_id ,l_orig_system_sold_customer_id ,l_trx_date ,l_gl_date,l_org_id ,c_line.line_type
                                                       ,'Percepcion - '||c_line.description ,l_currency_code ,g_monto_lineas_0,l_conversion_type ,l_conversion_date ,l_conversion_rate ,1 ,1 ,g_monto_lineas_0
                                                       ,g_monto_lineas_0 ,p_memo_line_id ,null ,l_uom_code ,c_line.tax_exempt_flag ,c_line.amount_includes_tax_flag,c_line.global_attribute_category
                                                       ,c_line.global_attribute2 ,c_line.global_attribute3 ,c_line.warehouse_id, c_line.vat_tax_id, p_cust_trx_type_id, l_term_id_ar, null,c_line.customer_trx_line_id
                                                       ,l_receipt_method_id ,l_comments ,p_conc_id ,l_paying_customer_id ,l_paying_site_use_id, l_interface_line_attribute5
                                                       ,l_BILL_CONTACT_ID,l_SHIP_CONTACT_ID);

                    l_invoice_amount:= l_invoice_amount + g_monto_lineas_0;

                    FOR c_dist IN c_datos_dist(c_line.customer_trx_line_id) LOOP

                       IF g_debug = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,'customer_trx_line_id: '||c_line.customer_trx_line_id);
                       END IF;

                       INSERT INTO ra_interface_distributions_all (interface_line_context ,interface_line_attribute1 ,interface_line_attribute2 ,account_class ,amount ,percent
                                                                  ,code_combination_id ,created_by ,creation_date ,last_updated_by ,last_update_date ,last_update_login ,org_id, interface_line_attribute3 ,interface_line_attribute4
                                                                  ,interface_line_attribute5)
                                                          VALUES  (l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,c_dist.account_class,g_monto_lineas_0 * c_dist.percent / 100 ,c_dist.percent
                                                                  ,c_dist.code_combination_id ,g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,c_dist.org_id, c_line.customer_trx_line_id  ,p_conc_id
                                                                  ,l_interface_line_attribute5);

                    END LOOP;

                    --ANALISIS IMPUESTO PARA LINEAS CON MONTO 0
                    BEGIN
                       SELECT tax_code
                             ,nvl(description,tax_code)
                             ,tax_rate
                             ,tax_account_id
                             ,tax_regime_code
                             ,tax
                             ,tax_status_code
                             ,tax_code tax_rate_code
                         INTO l_tax_code
                             ,l_description_tax
                             ,l_tax_rate
                             ,l_tax_account_id
                             ,l_tax_regime_code    --- ITC
                             ,l_tax                --- ITC
                             ,l_tax_status_code    --- ITC
                             ,l_tax_rate_code      --- ITC
                         FROM ar_vat_tax_all_b
                        WHERE vat_tax_id = p_tax_id_ar;

                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          e_message:= 'Error: No se encontro datos de impuesto para: '||p_tax_id_ar;
                          fnd_file.put_line(fnd_file.log,e_message);
                          e_retcode:=1;
                          ROLLBACK TO inicio_crear_doc;
                          RETURN FALSE;

                      WHEN OTHERS THEN
                          e_message:= 'Error general buscando datos de impuesto para: '||p_tax_id_ar||' Error sql:'||sqlerrm;
                          fnd_file.put_line(fnd_file.log,e_message);
                          e_retcode:=1;
                          ROLLBACK TO inicio_crear_doc;
                          RETURN FALSE;
                    END;

                    --IMPUESTO PARA LAS LINEAS EN 0
                    INSERT INTO ra_interface_lines_all (created_by ,creation_date ,last_updated_by ,last_update_date,last_update_login,interface_line_context,interface_line_attribute1,interface_line_attribute2
                                                       ,batch_source_name ,set_of_books_id ,cust_trx_type_name ,orig_system_bill_customer_id ,orig_system_bill_address_id
                                                       ,orig_system_ship_customer_id ,orig_system_ship_address_id ,orig_system_sold_customer_id ,trx_date ,gl_date ,org_id ,line_type
                                                       ,description ,currency_code ,amount ,conversion_type ,conversion_date ,conversion_rate ,quantity ,quantity_ordered ,unit_selling_price
                                                       ,unit_standard_price ,memo_line_id ,inventory_item_id ,uom_code ,tax_exempt_flag ,amount_includes_tax_flag ,line_gdf_attr_category
                                                       ,line_gdf_attribute2 ,line_gdf_attribute3 ,warehouse_id, vat_tax_id, cust_trx_type_id, term_id, tax_code ,interface_line_attribute3
                                                       ,link_to_line_context ,link_to_line_attribute1 ,link_to_line_attribute2 ,link_to_line_attribute3 ,tax_rate ,interface_line_attribute4 ,receipt_method_id
                                                       ,link_to_line_attribute4 ,paying_customer_id ,paying_site_use_id, interface_line_attribute5, link_to_line_attribute5
                                                       ,tax_regime_code, tax_rate_code) --R12
                                                VALUES (g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_interface_line_context ,l_interface_line_attribute1,l_interface_line_attribute2
                                                       ,l_batch_source_name ,l_set_of_books_id ,l_cust_trx_type_name ,l_orig_system_bill_customer_id ,l_orig_system_bill_address_id
                                                       ,l_orig_system_ship_customer_id ,l_orig_system_ship_address_id ,l_orig_system_sold_customer_id ,l_trx_date ,l_gl_date,l_org_id ,'TAX'
                                                       ,l_description_tax ,l_currency_code ,0 ,l_conversion_type ,l_conversion_date ,l_conversion_rate ,1 ,1 ,0
                                                       ,0 ,null ,null ,null ,c_line.tax_exempt_flag ,c_line.amount_includes_tax_flag,c_line.global_attribute_category
                                                       ,c_line.global_attribute2 ,c_line.global_attribute3 ,c_line.warehouse_id, p_tax_id_ar, p_cust_trx_type_id, l_term_id_ar, l_tax_code, p_tax_id_ar||c_line.customer_trx_line_id
                                                       ,l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,c_line.customer_trx_line_id ,l_tax_rate ,p_conc_id ,l_receipt_method_id
                                                       ,p_conc_id ,l_paying_customer_id ,l_paying_site_use_id, l_interface_line_attribute5, l_interface_line_attribute5
                                                       ,l_tax_regime_code, l_tax_rate_code); --R12

                    INSERT INTO ra_interface_distributions_all (interface_line_context ,interface_line_attribute1 ,interface_line_attribute2 ,account_class ,amount ,percent
                                                                ,code_combination_id ,created_by ,creation_date ,last_updated_by ,last_update_date ,last_update_login ,org_id ,interface_line_attribute3 ,interface_line_attribute4
                                                                ,interface_line_attribute5)
                                                        VALUES  (l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,'TAX','0' ,'100'
                                                                ,l_tax_account_id ,g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_org_id ,p_tax_id_ar||c_line.customer_trx_line_id ,p_conc_id
                                                                ,l_interface_line_attribute5);

                 END LOOP;

                  FOR c_imp IN c_datos_imp(p_customer_trx_id, l_warehouse_id) LOOP

                     BEGIN
                       SELECT tax_code
                             ,nvl(description,tax_code)
                             ,tax_rate
                             ,tax_account_id
                             ,tax_regime_code
                             ,tax
                             ,tax_status_code
                             ,tax_code tax_rate_code
                         INTO l_tax_code
                             ,l_description_tax
                             ,l_tax_rate
                             ,l_tax_account_id
                             ,l_tax_regime_code    --- ITC
                             ,l_tax                --- ITC
                             ,l_tax_status_code    --- ITC
                             ,l_tax_rate_code      --- ITC
                          FROM ar_vat_tax_all_b
                         WHERE vat_tax_id = c_imp.vat_tax_id;

                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        e_message:= 'Error: No se encontro tax_code para: '||c_imp.vat_tax_id;
                        fnd_file.put_line(fnd_file.log,e_message);
                        e_retcode:=1;
                        ROLLBACK TO inicio_crear_doc;
                        RETURN FALSE;

                     WHEN OTHERS THEN
                        e_message:= 'Error general buscando tax_code para: '||c_imp.vat_tax_id||' Error sql:'||sqlerrm;
                        fnd_file.put_line(fnd_file.log,e_message);
                        e_retcode:=1;
                        ROLLBACK TO inicio_crear_doc;
                        RETURN FALSE;
                     END;

                     /*Agregado Khronus/E.Sly 20190610*/
                     IF v_rctta_type = 'CM' THEN

                         BEGIN

                            SELECT xx_ar_void_level,xx_ar_void_term
                              INTO v_void_level,v_void_term
                              FROM fnd_lookup_values_vl flv
                                  ,fnd_lookup_values_dfv flv_dfv
                             WHERE flv.lookup_type = 'XX_AR_CM_TAX_JURISDICTION'
                               AND flv.rowid = flv_dfv.row_id
                               AND lookup_code = l_tax;

                         EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              e_message:= 'No se encontro jurisdiccion: '||l_tax||'en Lookup XX_AR_CM_TAX_JURISDICTION.';
                              fnd_file.put_line(fnd_file.log,e_message);
                              e_retcode:=1;
                              ROLLBACK TO inicio_crear_doc;
                        RETURN FALSE;
                           WHEN OTHERS THEN
                              e_message:= 'Error al obtener datos de Lookup XX_AR_CM_TAX_JURISDICTION para: '|| l_tax||' Error sql:'||sqlerrm;
                              fnd_file.put_line(fnd_file.log,e_message);
                              e_retcode:=1;
                              ROLLBACK TO inicio_crear_doc;
                         END;

                         IF v_void_level = 'N' THEN
                           CONTINUE;
                         END IF;

                         IF NVL(v_void_term,'*')  = 'E' THEN


                                fnd_file.put_line(fnd_file.log,'Obtengo la fecha de la FC, para comparar periodo');

                                BEGIN

                                    SELECT rct.trx_date
                                      INTO v_rct_date
                                      FROM ra_customer_trx_all rct
                                          ,ra_cust_trx_types_all rctt
                                     WHERE rct.ct_reference = (select ct_reference
                                                                 from ra_customer_trx_all rct1
                                                                 where rct1.customer_trx_id = p_customer_trx_id)
                                       AND rct.cust_trx_type_id = rctt.cust_trx_type_id
                                       AND rctt.type = 'INV';

                                EXCEPTION
                                 WHEN NO_DATA_FOUND THEN

                                   fnd_file.put_line(fnd_file.log,'No se encontro Liquidacion FC. Buscando Liquidacion NC');

                                   BEGIN

                                    SELECT MIN(rct.trx_date)
                                      INTO v_rct_date
                                      FROM ra_customer_trx_all rct
                                          ,ra_cust_trx_types_all rctt
                                          ,ra_batch_sources_all rbs
                                     WHERE rct.ct_reference = (select ct_reference
                                                                 from ra_customer_trx_all rct1
                                                                 where rct1.customer_trx_id = p_customer_trx_id)
                                       AND rct.customer_trx_id != p_customer_trx_id
                                       AND rct.cust_trx_type_id = rctt.cust_trx_type_id
                                       AND rctt.type = 'CM'
                                       AND rbs.batch_source_id = rct.batch_source_id
                                       AND UPPER(rbs.name) not like '%FICT%';
                                   EXCEPTION
                                     WHEN OTHERS THEN
                                        e_message := 'Error al obtener la fecha de la Liquidacion NC para verificar periodos. Error: '||SQLERRM;
                                        fnd_file.put_line(fnd_file.log,e_message);
                                        e_retcode:=1;
                                        ROLLBACK TO inicio_crear_doc;
                                   END;

                                 WHEN OTHERS THEN
                                     e_message := 'Error al obtener la fecha de la Liquidacion FC para verificar periodos. Error: '||SQLERRM;
                                     fnd_file.put_line(fnd_file.log,e_message);
                                     e_retcode:=1;
                                     ROLLBACK TO inicio_crear_doc;
                                END;

                                IF '01/'||TO_CHAR(TRUNC(v_rct_date),'MM/YYYY') < '01/'||TO_CHAR(TRUNC(SYSDATE),'MM/YYYY') THEN
                                 CONTINUE;
                                END IF;

                         END IF;

                     END IF;

                     INSERT INTO ra_interface_lines_all (created_by ,creation_date ,last_updated_by ,last_update_date,last_update_login,interface_line_context,interface_line_attribute1,interface_line_attribute2
                                                        ,batch_source_name ,set_of_books_id ,cust_trx_type_name ,orig_system_bill_customer_id ,orig_system_bill_address_id
                                                        ,orig_system_ship_customer_id ,orig_system_ship_address_id ,orig_system_sold_customer_id ,trx_date ,gl_date ,org_id ,line_type
                                                        ,description ,currency_code ,amount ,conversion_type ,conversion_date ,conversion_rate ,quantity ,quantity_ordered ,unit_selling_price
                                                        ,unit_standard_price ,memo_line_id ,inventory_item_id ,uom_code ,tax_exempt_flag ,amount_includes_tax_flag ,line_gdf_attr_category
                                                        ,line_gdf_attribute2 ,line_gdf_attribute3 ,warehouse_id, vat_tax_id, cust_trx_type_id, term_id, tax_code, interface_line_attribute3
                                                        ,link_to_line_context ,link_to_line_attribute1 ,link_to_line_attribute2 ,link_to_line_attribute3 ,tax_rate ,interface_line_attribute4 ,receipt_method_id
                                                        ,link_to_line_attribute4 ,paying_customer_id ,paying_site_use_id ,interface_line_attribute5 ,link_to_line_attribute5
                                                        ,tax_regime_code, tax_rate_code) --R12
                                                 VALUES (g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_interface_line_context ,l_interface_line_attribute1,l_interface_line_attribute2
                                                        ,l_batch_source_name ,l_set_of_books_id ,l_cust_trx_type_name ,l_orig_system_bill_customer_id ,l_orig_system_bill_address_id
                                                        ,l_orig_system_ship_customer_id ,l_orig_system_ship_address_id ,l_orig_system_sold_customer_id ,l_trx_date ,l_gl_date,l_org_id ,c_imp.line_type
                                                        ,l_description_tax ,l_currency_code ,c_imp.extended_amount ,l_conversion_type ,l_conversion_date ,l_conversion_rate ,c_imp.quantity_ordered ,c_imp.quantity_ordered,c_imp.unit_selling_price
                                                        ,c_imp.unit_standard_price ,c_imp.memo_line_id ,c_imp.inventory_item_id ,c_imp.uom_code ,c_imp.tax_exempt_flag ,c_imp.amount_includes_tax_flag,c_imp.global_attribute_category
                                                        ,c_imp.global_attribute2 ,c_imp.global_attribute3 ,c_imp.warehouse_id, c_imp.vat_tax_id, p_cust_trx_type_id, l_term_id_ar, l_tax_code, c_imp.customer_trx_line_id
                                                        ,l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,c_imp.link_to_cust_trx_line_id ,c_imp.tax_rate ,p_conc_id ,l_receipt_method_id
                                                        ,p_conc_id ,l_paying_customer_id ,l_paying_site_use_id ,l_interface_line_attribute5 ,l_interface_line_attribute5
                                                        ,l_tax_regime_code, l_tax_rate_code); --R12

                     l_invoice_amount:= l_invoice_amount + c_imp.extended_amount;

                     FOR c_dist IN c_datos_dist(c_imp.customer_trx_line_id) LOOP

                        IF g_debug = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,'Dist customer_trx_line_id: '||c_imp.customer_trx_line_id);
                        END IF;

                        INSERT INTO ra_interface_distributions_all (interface_line_context ,interface_line_attribute1 ,interface_line_attribute2 ,account_class ,amount ,percent
                                                                ,code_combination_id ,created_by ,creation_date ,last_updated_by ,last_update_date ,last_update_login ,org_id ,interface_line_attribute3 ,interface_line_attribute4
                                                                ,interface_line_attribute5)
                                                        VALUES  (l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,c_dist.account_class,c_dist.amount ,c_dist.percent
                                                                ,c_dist.code_combination_id ,g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,c_dist.org_id, c_imp.customer_trx_line_id ,p_conc_id
                                                                ,l_interface_line_attribute5);

                     END LOOP;

                  END LOOP;

                 IF l_cant_lineas = 0 THEN
                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'No se crearon lineas en la interface');
                    END IF;

                 ELSIF l_cant_lineas = 1 THEN
                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'Se creo '||l_cant_lineas||' linea item en la interface');
                    END IF;

                 ELSIF l_cant_lineas > 1 THEN
                    IF g_debug = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,'Se crearon '||l_cant_lineas||' lineas item en la interface');
                    END IF;

                 END IF;


                 IF l_cant_lineas >= 1 THEN
                    INSERT INTO ra_interface_distributions_all (interface_line_context ,interface_line_attribute1 ,interface_line_attribute2 ,account_class ,amount ,percent
                                                            ,code_combination_id ,created_by ,creation_date ,last_updated_by ,last_update_date ,last_update_login ,org_id, interface_line_attribute3 ,interface_line_attribute4
                                                            ,interface_line_attribute5)
                                                    VALUES  (l_interface_line_context ,l_interface_line_attribute1 ,l_interface_line_attribute2 ,'REC' ,l_invoice_amount ,100
                                                            ,l_code_combination_id ,g_user_id_ar ,sysdate ,g_user_id_ar ,sysdate ,g_login_id_ar ,l_org_id, null ,p_conc_id
                                                            ,l_interface_line_attribute5);
                 END IF;

              END IF;
          END IF;
              IF g_debug = 'Y' THEN
                 fnd_file.put_line(fnd_file.log,'Fin XX_AR_TRX_FICTICIA_PKG.crear_doc '||to_char(sysdate, 'HH24:MI:SS')||chr(10));
              END IF;

              RETURN TRUE;

               EXCEPTION
               WHEN OTHERS THEN
                  e_message :='Error general XX_AR_TRX_FICTICIA_PKG.crear_doc p_customer_trx_id: '||p_customer_trx_id||'sqlerrm: '||sqlerrm;
                  fnd_message.retrieve(e_message);
                  e_retcode := 2;
                  ROLLBACK TO inicio_crear_doc;
                  RETURN FALSE;
       END crear_doc;

       PROCEDURE PRINT_TOTAL(p_list_of_requests_t IN list_of_requests_t)
       IS
           l_request_id NUMBER;
           l_parent_request_id    NUMBER;
           l_name    VARCHAR2(100);
           l_count    number;
           i varchar2(20);
       BEGIN
               FND_FILE.new_line(FND_FILE.OUTPUT);
               FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Totales por Origen');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-----------------------------');

               i := p_list_of_requests_t.FIRST;

               WHILE i IS NOT NULL
               LOOP
                   IF p_list_of_requests_t(i).ESTADO='ARF'
                   THEN
                       l_request_id := p_list_of_requests_t(i).request_id;
                        BEGIN
                            SELECT COUNT(*)
                                        ,rbs.name
                            INTO l_count
                                   ,l_name
                          FROM fnd_concurrent_requests fcr
                              ,ra_customer_trx_all     rct
                              ,ra_batch_sources_all    rbs
                             WHERE rct.batch_source_id     = rbs.batch_source_id
                               AND fcr.request_id          = rct.request_id
                               AND fcr.priority_request_id = l_request_id
                           GROUP BY NAME;
                       EXCEPTION WHEN OTHERS THEN
                               l_count := 0;
                       END;
                       IF l_count > 0
                       THEN
                           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||p_list_of_requests_t(i).modo_ejecucion||' '||l_name||' '||l_count);
                       END IF;
                   ELSIF p_list_of_requests_t(i).ESTADO='ARR'
                   THEN
                       l_request_id := p_list_of_requests_t(i).request_id;

                       BEGIN
                            SELECT COUNT(*)
                                        ,rbs.name
                            INTO l_count
                                   ,l_name
                          FROM fnd_concurrent_requests fcr
                              ,ra_customer_trx_all     rct
                              ,ra_batch_sources_all    rbs
                             WHERE rct.batch_source_id     = rbs.batch_source_id
                               AND fcr.request_id          = rct.request_id
                               AND fcr.priority_request_id = l_request_id
                           GROUP BY NAME;
                       EXCEPTION WHEN OTHERS THEN
                               l_count := 0;
                       END;
                       IF l_count > 0
                       THEN
                           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||p_list_of_requests_t(i).modo_ejecucion||' '||l_name||' '||l_count);
                       END IF;
                   ELSIF p_list_of_requests_t(i).ESTADO='ERROR'
                   THEN
                       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||p_list_of_requests_t(i).modo_ejecucion||' '||'Cantidad de Errores:'||p_list_of_requests_t(i).request_id);
                   ELSIF p_list_of_requests_t(i).ESTADO='SINCAE'
                   THEN
                       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||p_list_of_requests_t(i).modo_ejecucion||' '||'Comprobantes Sin Cae:'||p_list_of_requests_t(i).request_id);
                   ELSIF p_list_of_requests_t(i).ESTADO='IERROR'
                   THEN
                       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||'Cantidad de Errores Interco:'||p_list_of_requests_t(i).request_id);
                   ELSIF p_list_of_requests_t(i).ESTADO='SIN_CONTRATO'
                   THEN
                       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||'Cantidad Sin Contrato:'||p_list_of_requests_t(i).request_id);
                   ELSIF p_list_of_requests_t(i).ESTADO='INTERCO'
                   THEN
                       BEGIN
                           SELECT COUNT(*)
                           INTO l_count
                           FROM ap_invoices_interface
                           WHERE GROUP_ID=p_list_of_requests_t(i).request_id;
                       END;
                       IF l_count > 0
                       THEN
                           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' '||'Cantidad Interco:'||l_count);
                       END IF;
                   END IF;
                   i := p_list_of_requests_t.NEXT(i);
               END LOOP;
      END PRINT_TOTAL;

  PROCEDURE main (errbuf                          OUT VARCHAR2
                 ,retcode                         OUT NUMBER
                 ,p_fecha_desde                IN     VARCHAR2
                 ,p_fecha_hasta                IN     VARCHAR2
                 ,p_modo_ejecucion             IN     VARCHAR2
                 ,p_tipo_trx                   IN     VARCHAR2
                 ,p_source                     IN     VARCHAR2
                 ,p_pay_group                  IN     VARCHAR2
                 ,p_terms_id                   IN     NUMBER
                 ,p_payment_method_lookup_code IN     VARCHAR2
                 ,p_tax_id_ar                  IN     NUMBER
                 ,p_memo_line_id               IN     NUMBER
                 /*Modificado KHRONUS/E.Sly 20191021 El termino de pago debe tomarse de la liquidacion*/
                 --,p_term_id_ar                 IN     NUMBER
                 /*Fin Modificado KHRONUS/E.Sly 20191021 El termino de pago debe tomarse de la liquidacion*/
                 ,p_importar                   IN     VARCHAR2
                 ,p_fecha_override             IN     VARCHAR2) IS

    l_fecha_desde            DATE;
    l_fecha_hasta            DATE;
    l_fecha_override         DATE;
    l_sep                    VARCHAR2(1):=';';
    l_cant_errors            NUMBER;
    l_cant_insert            NUMBER;
    l_cant_lineas            NUMBER;
    l_req_id                 NUMBER;

    --Variables para xx_util_pk.conc_submit_request
    l_conc_status            VARCHAR2(100);
    l_conc_dev_status        VARCHAR2(100);
    l_mesg_error             VARCHAR2(1000);

    l_procesa                VARCHAR2(1);
    l_contrato               VARCHAR2(250);

    l_batch_source_name_aux  VARCHAR2(100);

    l_cae_incomplete         NUMBER;
    l_incomplete             NUMBER;
    l_cae_reint              NUMBER;

    l_conc_original          NUMBER;
    l_org_id_original        NUMBER;

    c_list_requests          list_of_requests_t;-- := list_of_requests_t ();
    i                        NUMBER := 0;

    /*Agregado KHRONUS/E.Sly 20191024 Debe tomar el termino de pago de AP desde AR, Sino tomar el del parametro*/
    v_ap_term_id             NUMBER;
    /*Fin Agregado KHRONUS/E.Sly 20191024 Debe tomar el termino de pago de AP desde AR, Sino tomar el del parametro*/

    CURSOR c_facturas_sel(c_fecha_desde    IN DATE
                         ,c_fecha_hasta    IN DATE
                         ,c_modo_ejecucion IN VARCHAR2
                         ,c_conc_id        IN NUMBER) IS
      SELECT rct.customer_trx_id
           , rbs1.batch_source_id
           , rctt1.cust_trx_type_id
           , rct.trx_number
           , rct.trx_date
           , rc.customer_name         ship_to_cust_name
           , rc1.customer_name        bill_to_cust_name
           , rctt.name                cust_trx_type_name
           , rbs.name                 batch_source_name
           , DECODE(nvl(rctt1.post_to_gl,'N'),'N','F','R') tipo_trx
           , rct.creation_date
           /*Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
           , rct.term_id
           /*FIn Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
        FROM ra_customer_trx       rct
           , ra_cust_trx_types_all rctt
           , ra_cust_trx_types_all rctt1
           , ra_batch_sources_all  rbs
           , ra_batch_sources_all  rbs1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers          rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
           --, ra_customers          rc1
       WHERE rct.complete_flag                    = 'Y'
         AND rct.bill_to_customer_id              = rc1.customer_id
         AND rct.ship_to_customer_id              = rc.customer_id
         AND rbs1.batch_source_type               = 'FOREIGN'
         AND rctt1.cust_trx_type_id               = rbs1.default_inv_trx_type
         AND rctt.attribute14                     = rctt1.cust_trx_type_id
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         --Verifica que el documento no se haya importado previamente
         AND NOT EXISTS (SELECT 1
                           FROM ra_customer_trx_all
                          WHERE interface_header_attribute2 = to_char(rct.customer_trx_id))
         --Verifica que el documento no se encuentra en la interface
         AND NOT EXISTS (SELECT 1
                           FROM ra_interface_lines_all ril
                          WHERE ril.interface_line_attribute2 = to_char(rct.customer_trx_id))
         --frozados Se excluyen las memolines de tipo percepciones
         AND NOT EXISTS (SELECT 1
                           FROM ra_customer_trx_lines_all rctla
                              , ar_memo_lines             aml
                              , ar_vat_tax_all            avta
                              , ar_vat_tax_all_b_dfv      avtabd
                          WHERE rctla.customer_trx_id=rct.customer_trx_id
                            AND rctla.memo_line_id=aml.memo_line_id
                            AND aml.tax_code=avta.tax_code
                            AND avtabd.row_id=avta.ROWID
                            AND avtabd.XXW_COD_TRIB IS NOT NULL
                            )
         AND ( /*Modificado KHRONUS/E.Sly 03/2020*/
               --(rct.creation_date  BETWEEN c_fecha_desde AND c_fecha_hasta)
                        (TRUNC(rct.creation_date)  >=  TRUNC(c_fecha_desde)
                     AND TRUNC(rct.creation_date) <= TRUNC(c_fecha_hasta))
               /*Modificado KHRONUS/E.Sly 03/2020*/
                 OR (rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                     AND rct.interface_header_attribute4 = c_conc_id
                    )
             )
         AND DECODE(nvl(rctt1.post_to_gl,'N'),'N','F','R') = nvl(c_modo_ejecucion, DECODE(nvl(rctt1.post_to_gl,'N'),'N','F','R'))
       ORDER BY rct.trx_date desc
           , rc1.customer_name
           , rct.trx_number;


    CURSOR c_facturas_inter_sel (c_fecha_desde IN DATE
                                ,c_fecha_hasta IN DATE
                                ,c_source      IN VARCHAR2
                                ,c_conc_id     IN NUMBER
                                ,c_cae_err     IN VARCHAR2) IS
      SELECT rct.customer_trx_id
           , rct.trx_number
           , rct.trx_date
           , rc.customer_name         ship_to_cust_name
           , rc1.customer_name        bill_to_cust_name
           , rctt.name                cust_trx_type_name
           , rbs.name                 batch_source_name
           , rct.creation_date
           /*Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
           , rct.term_id ar_term_id
           /*FIn Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           --, ra_customers                 rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                   , hca.attribute6
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers                 rc1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
           , po_vendors                   pv
           , xx_aco_parametros_compania xapc
           , xxw_fac_tmp                xft
       WHERE rct.complete_flag                    = 'Y'
         AND rct.bill_to_customer_id              = rc1.customer_id
         AND rct.ship_to_customer_id              = rc.customer_id
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND (/*Modificado KHRONUS/E.Sly 03/2020
               (rct.creation_date              BETWEEN c_fecha_desde
                                                  AND c_fecha_hasta)*/
              (TRUNC(rct.creation_date)  >=  TRUNC(c_fecha_desde)
                 AND TRUNC(rct.creation_date) <= TRUNC(c_fecha_hasta))
             /*Modificado KHRONUS/E.Sly 03/2020 */
             OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                 AND rct.interface_header_attribute4 = c_conc_id))
        --Verifica que las facturas tengan CAE
         AND (   ( c_cae_err = 'Y'
                  AND xft.cae                             IS NOT NULL)
              OR ( c_cae_err = 'N'
                  AND xft.cae                             IS NULL)
             )
         AND rct.customer_trx_id                  = xft.id
         --Verifica que el cliente sea una compania del grupo
         AND pv.segment1                         = rc.attribute6
         AND pv.vendor_type_lookup_code          = 'INTERCOMPANY'
         AND xapc.vendor_id                      = pv.vendor_id
         AND xapc.customer_id                    = rct.ship_to_customer_id
         --Verifica que no se haya migrado la factura a AP previamente
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_all              ai
                              , xx_aco_parametros_compania xapc
                          WHERE ai.vendor_id   = xapc.vendor_id
                            AND xapc.org_id    = rct.org_id
                            AND substr(ai.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND substr(ai.global_attribute11,1,2) = decode(rctt.type
                                                                          ,'DM' ,'ND'
                                                                          ,'CM' ,'NC'
                                                                          ,'FC'))
         --Verifica que la factura no exista en la interface de AP
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_interface        aii
                              , ap_invoice_lines_interface   ail
                              , xx_aco_parametros_compania xapc
                          WHERE aii.vendor_id   = xapc.vendor_id
                            AND xapc.org_id     = rct.org_id
                            AND aii.invoice_id  = ail.invoice_id (+)
                            AND substr(aii.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND aii.group_id  IS NOT NULL
                            AND aii.source      = c_source
                            AND substr(aii.global_attribute11,1,2) = decode(rctt.type
                                                                           ,'DM' ,'ND'
                                                                           ,'CM' ,'NC'
                                                                           ,'FC'))
       ORDER BY rct.trx_date desc
           , rc1.customer_name
           , rct.trx_number;


    CURSOR c_facturas_real_sel (c_fecha_desde IN DATE
                               ,c_fecha_hasta IN DATE
                               ,c_source      IN VARCHAR2
                               ,c_conc_id     IN NUMBER) IS
      SELECT rct.customer_trx_id
           , rct.trx_number
           , rct.trx_date
           , rc.customer_name         ship_to_cust_name
           , rc1.customer_name        bill_to_cust_name
           , rctt.name                cust_trx_type_name
           , rbs.name                 batch_source_name
           , rct.creation_date
           /*Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
           , rct.term_id ar_term_id
           /*FIn Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           --, ra_customers                 rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                   , hca.attribute6
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers                 rc1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
           , xxw_fac_tmp                xft
       WHERE rct.customer_trx_id                  = xft.id
         AND xft.cae                             IS NULL
         AND rct.complete_flag                    = 'Y'
         AND rct.bill_to_customer_id              = rc1.customer_id
         AND rct.ship_to_customer_id              = rc.customer_id
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND (/*Modificado KHRONUS/E.Sly 03/2020
              (rct.creation_date              BETWEEN c_fecha_desde
                                                  AND c_fecha_hasta) */
              (TRUNC(rct.creation_date)  >=  TRUNC(c_fecha_desde)
                 AND TRUNC(rct.creation_date) <= TRUNC(c_fecha_hasta))
             /*Modificado KHRONUS/E.Sly 03/2020 */
              OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                  AND rct.interface_header_attribute4 = c_conc_id))
       ORDER BY 3 desc, 5, 2;
       
    CURSOR c_facturas_interco_inc (c_fecha_desde IN DATE
                                  ,c_fecha_hasta IN DATE
                                  ,c_source      IN VARCHAR2
                                  ,c_conc_id     IN NUMBER) IS
      SELECT rct.customer_trx_id
           , rct.trx_number
           , rct.trx_date
           , rc.customer_name         ship_to_cust_name
           , rc1.customer_name        bill_to_cust_name
           , rctt.name                cust_trx_type_name
           , rbs.name                 batch_source_name
           , rct.creation_date
           /*Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
           , rct.term_id ar_term_id
           /*FIn Agregado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           --, ra_customers                 rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                   , hca.attribute6
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers                 rc1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
       , po_vendors                   pv
           , xx_aco_parametros_compania xapc
           , xxw_fac_tmp                xft
       WHERE NVL(rct.complete_flag,'N')                    = 'N'
         AND rct.bill_to_customer_id              = rc1.customer_id
         AND rct.ship_to_customer_id              = rc.customer_id
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND (/*Modificado KHRONUS/E.Sly 03/2020
              (rct.creation_date              BETWEEN c_fecha_desde
                                                  AND c_fecha_hasta) */
                (TRUNC(rct.creation_date)  >=  TRUNC(c_fecha_desde)
                     AND TRUNC(rct.creation_date) <= TRUNC(c_fecha_hasta))
             /*Modificado KHRONUS/E.Sly 03/2020*/
               OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                  AND rct.interface_header_attribute4 = c_conc_id))
        --Verifica que las facturas tengan CAE
         AND xft.cae                             IS NULL
         AND rct.customer_trx_id                  = xft.id(+)
         --Verifica que el cliente sea una compania del grupo
         AND pv.segment1                         = rc.attribute6
         AND pv.vendor_type_lookup_code          = 'INTERCOMPANY'
         AND xapc.vendor_id                      = pv.vendor_id
         AND xapc.customer_id                    = rct.ship_to_customer_id
         --Verifica que no se haya migrado la factura a AP previamente
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_all              ai
                              , xx_aco_parametros_compania xapc
                          WHERE ai.vendor_id   = xapc.vendor_id
                            AND xapc.org_id    = rct.org_id
                            AND substr(ai.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND substr(ai.global_attribute11,1,2) = decode(rctt.type
                                                                          ,'DM' ,'ND'
                                                                          ,'CM' ,'NC'
                                                                          ,'FC'))
         --Verifica que la factura no exista en la interface de AP
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_interface        aii
                              , ap_invoice_lines_interface   ail
                              , xx_aco_parametros_compania xapc
                          WHERE aii.vendor_id   = xapc.vendor_id
                            AND xapc.org_id     = rct.org_id
                            AND aii.invoice_id  = ail.invoice_id (+)
                            AND substr(aii.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND aii.group_id  IS NOT NULL
                            AND aii.source      = c_source
                            AND substr(aii.global_attribute11,1,2) = decode(rctt.type
                                                                           ,'DM' ,'ND'
                                                                           ,'CM' ,'NC'
                                                                           ,'FC'))
       ORDER BY rct.trx_date desc
           , rc1.customer_name
           , rct.trx_number;



    CURSOR c_fact_interface(c_org_id  IN NUMBER
                           ,c_conc_id IN NUMBER)IS
      SELECT distinct batch_source_name
           , batch_source_id, interface_line_context
        FROM ra_interface_lines_all ril
           , ra_batch_sources_all   rbs
       WHERE ril.batch_source_name         = rbs.name
         AND ril.org_id                    = rbs.org_id
         AND ril.interface_line_attribute4 = c_conc_id
         AND ril.org_id                    = c_org_id
         AND ril.interface_line_context    = 'XX_AR_FC_PERCEP';


    CURSOR c_fact_interface_ap(c_source   IN VARCHAR2
                              ,c_group_id IN NUMBER) IS
      SELECT distinct aii.org_id org_id
           , hou.name
        FROM ap_invoices_interface aii
           , hr_operating_units hou
       WHERE aii.org_id   = hou.organization_id
         AND aii.source   = c_source
         AND aii.group_id = to_char(c_group_id)
         AND aii.status  IS NULL;


    CURSOR c_ejecucion(c_modo_ejecucion IN VARCHAR2) IS
      SELECT ffv.flex_value modo_ejecucion
           , ffv.description nombre_ejecucion
           , DECODE (flex_value,'F',1,'R',2,'I',3) orden_ejecucion
        FROM fnd_flex_values_vl ffv
           , fnd_flex_value_sets ffvs
       WHERE ffv.flex_value_set_id    = ffvs.flex_value_set_id
         AND ffvs.flex_value_set_name = 'XX_MODO_EJEC_DOC_PERC'
         AND ffv.enabled_flag         = 'Y'
         AND ffv.flex_value          IN ('F','R','I')
         AND (    ffv.flex_value   = c_modo_ejecucion
               OR c_modo_ejecucion = 'C')
       ORDER BY orden_ejecucion;


    CURSOR c_ingresadas(c_request_id IN NUMBER) IS
      SELECT rct.trx_number
           , rct.trx_date
           , rct.creation_date
           , rctt.name         cust_trx_type_name
           , rbs.name          batch_source_name
           , rc.customer_name   bill_to_cust_name
           , rc1.customer_name  ship_to_cust_name  -- ITC
        FROM fnd_concurrent_requests fcr
           , ra_customer_trx_all     rct
           , ra_cust_trx_types_all   rctt
           , ra_batch_sources_all    rbs
           --, ra_customers            rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers            rc1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , substrb(hp.party_name,1,50) customer_name
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
       WHERE rct.ship_to_customer_id = rc1.customer_id
         AND rct.bill_to_customer_id = rc.customer_id
         AND rct.batch_source_id     = rbs.batch_source_id
         AND rct.cust_trx_type_id    = rctt.cust_trx_type_id
         AND fcr.request_id          = rct.request_id
         AND fcr.priority_request_id = c_request_id;


    CURSOR c_batch (p_modo_ejecucion VARCHAR2
                   ,p_fecha_desde   IN     DATE
                   ,p_fecha_hasta   IN     DATE
                   ,p_source        IN     VARCHAR2
                   ,p_conc_original IN     NUMBER) IS
      SELECT rbs.name
           , rbs.batch_source_id
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           , xxw_fac_tmp                xft
       WHERE xft.cae                             IS NULL
         AND rct.customer_trx_id                  = xft.id (+)
         AND rct.complete_flag                    = 'Y'
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND (/*Modificado KHRONUS/E.Sly 03/2020
              (rct.creation_date              BETWEEN p_fecha_desde
                                                  AND p_fecha_hasta)*/
               (TRUNC(rct.creation_date)  >=  TRUNC(p_fecha_desde)
                AND TRUNC(rct.creation_date) <= TRUNC(p_fecha_hasta))
              /*Modificado KHRONUS/E.Sly 03/2020*/
               OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                   AND rct.interface_header_attribute4 = p_conc_original))
         AND p_modo_ejecucion = 'R'
       GROUP BY rbs.name,rbs.batch_source_id
       UNION ALL
      SELECT rbs.name
           , rbs.batch_source_id
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , hca.attribute6
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           , po_vendors                   pv
           , xx_aco_parametros_compania xapc
           , xxw_fac_tmp                xft
       WHERE xft.cae                             IS NULL
         AND rct.customer_trx_id                  = xft.id
         AND rct.complete_flag                    = 'Y'
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND (/*Modificado KHRONUS/E.Sly 03/2020
              (rct.creation_date              BETWEEN p_fecha_desde
                                                  AND p_fecha_hasta) */
              (TRUNC(rct.creation_date)  >=  TRUNC(p_fecha_desde)
               AND TRUNC(rct.creation_date) <= TRUNC(p_fecha_hasta))
              /*Modificado KHRONUS/E.Sly 03/2020*/
              OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                 AND rct.interface_header_attribute4 = p_conc_original))
         --Verifica que el cliente sea una compania del grupo
         AND pv.segment1                         = rc.attribute6
         AND pv.vendor_type_lookup_code          = 'INTERCOMPANY'
         AND xapc.vendor_id                      = pv.vendor_id
         AND xapc.customer_id                    = rct.ship_to_customer_id
         --Verifica que no se haya migrado la factura a AP previamente
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_all              ai
                              , xx_aco_parametros_compania xapc
                          WHERE ai.vendor_id   = xapc.vendor_id
                            AND xapc.org_id    = rct.org_id
                            AND substr(ai.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND substr(ai.global_attribute11,1,2) = decode(rctt.type
                                                                          ,'DM' ,'ND'
                                                                          ,'CM' ,'NC'
                                                                          ,'FC'))
         --Verifica que la factura no exista en la interface de AP
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_interface        aii
                              , ap_invoice_lines_interface   ail
                              , xx_aco_parametros_compania xapc
                          WHERE aii.vendor_id   = xapc.vendor_id
                            AND xapc.org_id     = rct.org_id
                            AND aii.invoice_id  = ail.invoice_id (+)
                            AND substr(aii.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND aii.group_id  IS NOT NULL
                            AND aii.source      = p_source
                            AND substr(aii.global_attribute11,1,2) = decode(rctt.type
                                                                           ,'DM' ,'ND'
                                                                           ,'CM' ,'NC'
                                                                           ,'FC'))
         AND p_modo_ejecucion = 'I'
       GROUP BY rbs.name
           , rbs.batch_source_id;



    FUNCTION cbtes_sin_cae_reales(p_fecha_desde   IN  DATE
                                 ,p_fecha_hasta   IN  DATE
                                 ,p_conc_original IN  NUMBER
                                 ,x_result        OUT NUMBER   )
      RETURN BOOLEAN IS

    BEGIN

      SELECT COUNT(rct.customer_trx_id)
        INTO x_result
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           --, ra_customers                 rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , hca.attribute6
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers                 rc1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
           , xxw_fac_tmp                xft
       WHERE xft.cae                             IS NULL
         AND rct.customer_trx_id                  = xft.id(+)
         AND rct.complete_flag                    = 'Y'
         AND rct.bill_to_customer_id              = rc1.customer_id
         AND rct.ship_to_customer_id              = rc.customer_id
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND (/*Modificado KHRONUS/E.Sly 03/2020
              (rct.creation_date              BETWEEN p_fecha_desde
                                                  AND p_fecha_hasta)*/
             (TRUNC(rct.creation_date)  >=  TRUNC(p_fecha_desde)
               AND TRUNC(rct.creation_date) <= TRUNC(p_fecha_hasta))
             /*Modificado KHRONUS/E.Sly 03/2020*/
              OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                  AND rct.interface_header_attribute4 = p_conc_original));

      RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result :=0;
        RETURN TRUE;

      WHEN OTHERS THEN
        e_message:= 'Error analizando comprobantes sin CAE'||l_mesg_error;
        fnd_message.retrieve(e_message);
        e_retcode:= 1;
        RETURN FALSE;

    END cbtes_sin_cae_reales;


    FUNCTION cbtes_inc_reales(p_fecha_desde   IN     DATE
                             ,p_fecha_hasta   IN     DATE
                             ,p_conc_original IN     NUMBER
                             ,x_result           OUT NUMBER   )
      RETURN BOOLEAN IS

    BEGIN

      SELECT count(1)
        INTO x_result
        FROM ra_customer_trx  rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
       WHERE 1 = 1
         AND rct.complete_flag                    = 'N'
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND ( /*Modificado KHRONUS/E.Sly 03/2020
             (rct.creation_date              BETWEEN p_fecha_desde
                                               AND p_fecha_hasta)*/
              (TRUNC(rct.creation_date)  >=  TRUNC(p_fecha_desde)
                 AND TRUNC(rct.creation_date) <= TRUNC(p_fecha_hasta))
              /*Modificado KHRONUS/E.Sly 03/2020*/
               OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                   AND rct.interface_header_attribute4 = p_conc_original));

      RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result :=0;
        RETURN TRUE;

      WHEN OTHERS THEN
        e_message:= 'Error analizando comprobantes Incompletos'||l_mesg_error;
        fnd_message.retrieve(e_message);
        e_retcode:= 1;
        RETURN FALSE;

    END cbtes_inc_reales;


    FUNCTION cbtes_sin_cae(p_fecha_desde   IN     DATE
                          ,p_fecha_hasta   IN     DATE
                          ,p_source        IN     VARCHAR2
                          ,p_conc_original IN     NUMBER
                          ,x_result           OUT NUMBER   )
      RETURN BOOLEAN IS

    BEGIN

      SELECT count(rct.customer_trx_id)
        INTO x_result
        FROM ra_customer_trx              rct
           , ra_cust_trx_types_all        rctt
           , ra_batch_sources_all         rbs
           --, ra_customers                 rc
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                   , hca.attribute6
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc -- ITC
           --, ra_customers                 rc1
           , (SELECT hca.cust_account_id customer_id
                   , hp.party_id
                FROM hz_parties hp,
                     hz_cust_accounts hca
               WHERE 1=1
                 AND hp.Party_Id = hca.Party_Id) rc1 -- ITC
           , po_vendors                   pv
           , xx_aco_parametros_compania xapc
           , xxw_fac_tmp                xft
       WHERE xft.cae                             IS NULL
         AND rct.customer_trx_id                  = xft.id(+)
         AND rct.complete_flag                    = 'Y'
         AND rct.bill_to_customer_id              = rc1.customer_id
         AND rct.ship_to_customer_id              = rc.customer_id
         AND rct.batch_source_id                  = rbs.batch_source_id
         AND rctt.post_to_gl                      = 'Y'
         AND rct.cust_trx_type_id                 = rctt.cust_trx_type_id
         AND rct.interface_header_context         = 'XX_AR_FC_PERCEP'
         AND ( /*Modificado KHRONUS/E.Sly 03/2020
              (rct.creation_date              BETWEEN p_fecha_desde
                                                  AND p_fecha_hasta) */
              (TRUNC(rct.creation_date)  >=  TRUNC(p_fecha_desde)
                AND TRUNC(rct.creation_date) <= TRUNC(p_fecha_hasta))
               /*Modificado KHRONUS/E.Sly 03/2020 */
              OR (    rct.interface_header_context    = 'XX_AR_FC_PERCEP'
                  AND rct.interface_header_attribute4 = p_conc_original))
         --Verifica que el cliente sea una compania del grupo
         AND pv.segment1                         = rc.attribute6
         AND pv.vendor_type_lookup_code          = 'INTERCOMPANY'
         AND xapc.vendor_id                      = pv.vendor_id
         AND xapc.customer_id                    = rct.ship_to_customer_id
         --Verifica que no se haya migrado la factura a AP previamente
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_all              ai
                              , xx_aco_parametros_compania xapc
                          WHERE ai.vendor_id   = xapc.vendor_id
                            AND xapc.org_id    = rct.org_id
                            AND substr(ai.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND substr(ai.global_attribute11,1,2) = decode(rctt.type
                                                                          ,'DM' ,'ND'
                                                                          ,'CM' ,'NC'
                                                                          ,'FC'))
         --Verifica que la factura no exista en la interface de AP
         AND NOT EXISTS (SELECT 1
                           FROM ap_invoices_interface        aii
                              , ap_invoice_lines_interface   ail
                              , xx_aco_parametros_compania xapc
                          WHERE aii.vendor_id   = xapc.vendor_id
                            AND xapc.org_id     = rct.org_id
                            AND aii.invoice_id  = ail.invoice_id (+)
                            AND substr(aii.invoice_num,1,13) = substr(rct.trx_number,3)
                            AND aii.group_id  IS NOT NULL
                            AND aii.source      = p_source
                            AND substr(aii.global_attribute11,1,2) = decode(rctt.type
                                                                           ,'DM' ,'ND'
                                                                           ,'CM' ,'NC'
                                                                           ,'FC'));

      RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result :=0;
        RETURN TRUE;

      WHEN OTHERS THEN
        e_message:= 'Error analizando comprobantes sin CAE'||l_mesg_error;
        fnd_message.retrieve(e_message);
        e_retcode:= 1;
        RETURN FALSE;

    END cbtes_sin_cae;

  BEGIN

    e_retcode     :=0;
    retcode       :=0;

    l_conc_original := fnd_global.conc_request_id;
    l_fecha_override:= to_date(p_fecha_override,'RRRR/MM/DD HH24:MI:SS');
    l_fecha_desde:= to_date(p_fecha_desde,'RRRR/MM/DD HH24:MI:SS');
    l_fecha_hasta:= to_date(p_fecha_hasta,'RRRR/MM/DD HH24:MI:SS') + 1;

    fnd_file.put_line(fnd_file.log,'Main Parametros');
    fnd_file.put_line(fnd_file.log,'p_modo_ejecucion: '                    ||p_modo_ejecucion);
    fnd_file.put_line(fnd_file.log,'l_fecha_desde: '                       ||l_fecha_desde);
    fnd_file.put_line(fnd_file.log,'l_fecha_hasta: '                       ||l_fecha_hasta);
    fnd_file.put_line(fnd_file.log,'p_fecha_override: '                    ||l_fecha_override);
    fnd_file.put_line(fnd_file.log,'p_importar: '                          ||p_importar);
    fnd_file.put_line(fnd_file.log,'l_conc_original: '                     ||l_conc_original);
    fnd_file.put_line(fnd_file.log,'p_source: '                            ||p_source);
    fnd_file.put_line(fnd_file.log,'p_pay_group: '                         ||p_pay_group);
    fnd_file.put_line(fnd_file.log,'p_terms_id: '                          ||p_terms_id);
    fnd_file.put_line(fnd_file.log,'p_payment_method_lookup_code: '        ||p_payment_method_lookup_code);
    fnd_file.put_line(fnd_file.log,'p_tipo_trx: '                          ||p_tipo_trx);
    fnd_file.put_line(fnd_file.log,'p_memo_line_id: '                      ||p_memo_line_id);
    /*Modificado KHRONUS/E.Sly 20191021 El termino de pago debe tomarse de la liquidacion*/
    --fnd_file.put_line(fnd_file.log,'p_term_id_ar: '                        ||p_term_id_ar);
    /*Fin Modificado KHRONUS/E.Sly 20191021 El termino de pago debe tomarse de la liquidacion*/
    fnd_file.put_line(fnd_file.log,'p_tax_id_ar: '                         ||p_tax_id_ar);
    fnd_file.put_line(fnd_file.log,'--------------------------------------');

    fnd_file.put_line(fnd_file.output,'Iniciando Creacion de Documentos');

    IF g_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log,chr(10)||'Iniciando Creacion de Documentos '||to_char(sysdate,'HH24:MI:SS'));
    END IF;

    FOR c_ejecutar IN c_ejecucion(to_char(p_modo_ejecucion)) LOOP

      IF (c_ejecutar.modo_ejecucion = 'R') OR (c_ejecutar.modo_ejecucion = 'F') THEN

        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,chr(10)||'Modo ejecucion: '||c_ejecutar.nombre_ejecucion);
        END IF;

        l_cant_insert :=0;
        l_cant_errors :=0;

        fnd_file.put_line(fnd_file.output,chr(10)||'Insertando nuevas transacciones '||c_ejecutar.nombre_ejecucion||' en la interfaz de Cuentas por Cobrar');
        fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                          'Tipo Trx'            ||l_sep||
                                          'Nro. Trx'            ||l_sep||
                                          'Fecha Trx'           ||l_sep||
                                          'Cliente Envio'       ||l_sep||
                                          'Cliente Facturacion' ||l_sep||
                                          'Fecha Creacion');

        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Pre c_facturas_sel - l_conc_original: '||l_conc_original);
        END IF;

        FOR c_fact IN c_facturas_sel(l_fecha_desde, l_fecha_hasta, c_ejecutar.modo_ejecucion, l_conc_original) LOOP

          l_cant_lineas:=0;

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,'Pre crear_doc - customer_trx_id: '||c_fact.customer_trx_id);
          END IF;

          IF NOT crear_doc(c_fact.customer_trx_id
                          ,c_fact.batch_source_id
                          ,c_fact.cust_trx_type_id
                          ,p_tax_id_ar
                          ,p_memo_line_id
                          /*Modificado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
                          --,p_term_id_ar
                          ,c_fact.term_id
                          /*Fin Modificado KHRONUS/E.Sly 20191017 Debe Tomar el Termino de Pago de la trx original*/
                          ,c_fact.tipo_trx
                          ,l_cant_lineas
                          ,l_conc_original
                          ,l_fecha_override
                          ) THEN

            IF e_retcode = 2 THEN
              fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
              RAISE e_exception;
            END IF;

            fnd_file.put_line(fnd_file.log,e_message||chr(10));
            XX_PROCESA(p_customer_trx_id => c_fact.customer_trx_id
                      ,x_contrato        => l_contrato
                      ,x_procesa         => l_procesa
                      );

            IF l_procesa = 'Y' THEN
              l_cant_errors:=l_cant_errors + 1;
            END IF;

          ELSE

            IF l_cant_lineas > 0 THEN
              fnd_file.put_line(fnd_file.output, c_fact.batch_source_name  ||l_sep||
                                                 c_fact.cust_trx_type_name ||l_sep||
                                                 c_fact.trx_number         ||l_sep||
                                                 c_fact.trx_date           ||l_sep||
                                                 c_fact.ship_to_cust_name  ||l_sep||
                                                 c_fact.bill_to_cust_name  ||l_sep||
                                                 c_fact.creation_date);
              l_cant_insert :=l_cant_insert + 1;
            END IF;

          END IF;

        END LOOP;

        --FROZADOS IMPRIMO AQUELLOS COMPROBANTES QUE NO TIENEN CONTRATO
        fnd_file.put_line(fnd_file.output,chr(10)||'Transacciones Sin Contrato');
        fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                          'Tipo Trx'            ||l_sep||
                                          'Nro. Trx'            ||l_sep||
                                          'Fecha Trx'           ||l_sep||
                                          'Cliente Envio'       ||l_sep||
                                          'Cliente Facturacion' ||l_sep||
                                          'Fecha Creacion');

        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Pre c_facturas_sel 2 - l_conc_original: '||l_conc_original);
        END IF;

        FOR c_fact IN c_facturas_sel(l_fecha_desde, l_fecha_hasta, c_ejecutar.modo_ejecucion, l_conc_original) LOOP

          XX_PROCESA(p_customer_trx_id => c_fact.customer_trx_id
                    ,x_contrato                 => l_contrato
                    ,x_procesa                 => l_procesa);


          IF l_procesa = 'N' AND l_contrato IS NULL THEN
            i := i+1;

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,'Trx_number: '||c_fact.trx_number);
            END IF;

            fnd_file.put_line(fnd_file.output,c_fact.batch_source_name  ||l_sep||
                                              c_fact.cust_trx_type_name ||l_sep||
                                              c_fact.trx_number         ||l_sep||
                                              c_fact.trx_date           ||l_sep||
                                              c_fact.ship_to_cust_name  ||l_sep||
                                              c_fact.bill_to_cust_name  ||l_sep||
                                              c_fact.creation_date);

            --c_list_requests.extend();
            c_list_requests('SIN_CONTRATO').request_id:=i;
            c_list_requests('SIN_CONTRATO').modo_ejecucion:=c_ejecutar.nombre_ejecucion;
            c_list_requests('SIN_CONTRATO').estado:='SIN_CONTRATO';

          END IF;

        END LOOP;


        IF l_cant_errors >= 1 THEN

          fnd_file.put_line(fnd_file.output,chr(10)||'Se ha encontrado '||l_cant_errors||' registro con error. Consulte el log para mayor informacion.');
          --FROZADOS ADDDED
          --i := i+1;
          --c_list_requests.extend();
          c_list_requests('ERROR').request_id:=l_cant_errors;
          c_list_requests('ERROR').modo_ejecucion:=c_ejecutar.nombre_ejecucion;
          c_list_requests('ERROR').estado:='ERROR';

        END IF;

        IF (l_cant_insert > 0 AND nvl(p_importar,'N') = 'Y') THEN

          --Ejecucion de la interface de AR por cada uno de los origenes existentes en la tabla de interface
          FOR c1 IN c_fact_interface(fnd_global.org_id ,l_conc_original) LOOP

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,'Inicio interface de AR para '||c1.batch_source_name||' - '||to_char(sysdate,'HH24:MI:SS'));
            END IF;

            IF NOT xx_util_pk.conc_submit_request(p_appl_short_name   => 'AR'
                                                 ,p_program_name      =>'RAXMTR'                                                        --Programa Principal de Factura Automatica
                                                 ,p_start_time        => to_char(sysdate,'RRRR/MM/DD HH24:MI:SS')
                                                 ,p_argument1         => '1'                                                            --Number of Instances
                                                 ,p_argument2         => '-99'                                                          --Organization (R12:New)
                                                 ,p_argument3         => to_char(c1.batch_source_id)                                    --Batch Source Id
                                                 ,p_argument4         => to_char(c1.batch_source_name)                                  --Batch Source Name
                                                 ,p_argument5         => to_char(nvl(l_fecha_override,sysdate),'RRRR/MM/DD HH24:MI:SS') --Default Date
                                                 ,p_argument6         => c1.interface_line_context||'....'||l_conc_original             --Transaction Flexfield
                                                 ,p_argument7         => ''                                                             --Transaction Type
                                                 ,p_argument8         => ''                                                             --(Low) Bill To Customer Number
                                                 ,p_argument9         => ''                                                             --(High) Bill To Customer Number
                                                 ,p_argument10        => ''                                                             --(Low) Bill To Customer Name
                                                 ,p_argument11        => ''                                                             --(High) Bill To Customer Name
                                                 ,p_argument12        => ''                                                             --(Low) GL Date
                                                 ,p_argument13        => ''                                                             --(High) GL Date
                                                 ,p_argument14        => ''                                                             --(Low) Ship Date
                                                 ,p_argument15        => ''                                                             --(High) Ship Date
                                                 ,p_argument16        => ''                                                             --(Low) Transaction Number
                                                 ,p_argument17        => ''                                                             --(High) Transaction Number
                                                 ,p_argument18        => ''                                                             --(Low) Sales Order Number
                                                 ,p_argument19        => ''                                                             --(High) Sales Order Number
                                                 ,p_argument20        => ''                                                             --(Low) Invoice Date
                                                 ,p_argument21        => ''                                                             --(High) Invoice Date
                                                 ,p_argument22        => ''                                                             --(Low) Ship To Customer Number
                                                 ,p_argument23        => ''                                                             --(High) Ship To Customer Number
                                                 ,p_argument24        => ''                                                             --(Low) Ship To Customer Name
                                                 ,p_argument25        => ''                                                             --(High) Ship To Customer Name
                                                 ,p_argument26        => 'Y'                                                            --Base Due Date on Trx Date
                                                 ,p_argument27        => ''                                                             --Due Date Adjustment Days
                                                 --,p_argument28        => ''                                                           --Ord Id (R12:Disabled)
                                                 ,p_wait              => 'Y'
                                                 ,p_wait_interval     => 10
                                                 ,p_request_id        => l_req_id
                                                 ,p_conc_status       => l_conc_status
                                                 ,p_conc_dev_status   => l_conc_dev_status
                                                 ,p_mesg_error        => l_mesg_error) THEN
              e_retcode:= 1;
              e_message:= 'Error ejecutando concurrente de importacion'||l_mesg_error;
              fnd_file.put_line(fnd_file.output,chr(10)||'Error ejecutando concurrente de importacion consulte el registro para mas informacion');
              RAISE e_exception;

            END IF;

            --frozados guardo en memoria los request ejecutados
            --i := i+1;
            --c_list_requests.extend();

            fnd_file.put_line(fnd_file.output,chr(10)||'Se ejecuto el concurrente numero '||l_req_id||' para importar las facturas del origen '||c1.batch_source_name);

            fnd_file.put_line(fnd_file.output,chr(10)||'Transacciones '||c_ejecutar.nombre_ejecucion||' ingresadas en Cuentas por Cobrar');

            fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                              'Tipo Trx'            ||l_sep||
                                              'Nro. Trx'            ||l_sep||
                                              'Fecha Trx'           ||l_sep||
                                              'Cliente Envio'       ||l_sep||
                                              'Cliente Facturacion' ||l_sep||
                                              'Fecha Creacion');

            IF c_ejecutar.modo_ejecucion ='F' THEN

              c_list_requests('ARF-'||l_req_id).request_id:=l_req_id;
              c_list_requests('ARF-'||l_req_id).modo_ejecucion:=c_ejecutar.nombre_ejecucion;
              c_list_requests('ARF-'||l_req_id).estado:='ARF';

            ELSIF c_ejecutar.modo_ejecucion = 'R' THEN

              c_list_requests('ARR-'||l_req_id).request_id:=l_req_id;
              c_list_requests('ARR-'||l_req_id).modo_ejecucion:=c_ejecutar.nombre_ejecucion;
              c_list_requests('ARR-'||l_req_id).estado:='ARR';

            END IF;


            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,'Pre c_ingresadas');
            END IF;

            FOR c_ing IN c_ingresadas(l_req_id) LOOP

              fnd_file.put_line(fnd_file.output, c_ing.batch_source_name  ||l_sep||
                                                 c_ing.cust_trx_type_name ||l_sep||
                                                 c_ing.trx_number         ||l_sep||
                                                 c_ing.trx_date           ||l_sep||
                                                 c_ing.ship_to_cust_name  ||l_sep||
                                                 c_ing.bill_to_cust_name  ||l_sep||
                                                 c_ing.creation_date);
            END LOOP;

            IF NOT actualizar_corredor(fnd_global.org_id --p_org_id          IN NUMBER
                                      ,l_conc_original --p_conc_id         IN VARCHAR2
                                      ,c1.batch_source_id ) THEN
              RAISE e_exception;

            END IF;

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,'Fin interface de AR para '||c1.batch_source_name||' - '||to_char(sysdate,'HH24:MI:SS')||chr(10));
            END IF;

          END LOOP;

        END IF;

      END IF;

      /*Modificado KHRONUS/E.Sly 20191017 Se debe solicitar CAE en Reales tambien*/
      --IF c_ejecutar.modo_ejecucion = 'I'
      IF c_ejecutar.modo_ejecucion = 'I' or c_ejecutar.modo_ejecucion = 'R' THEN
        /*Fin Modificado KHRONUS/E.Sly 20191017 Se debe solicitar CAE en Reales tambien*/

        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,chr(10)||'Modo ejecucion: '||c_ejecutar.nombre_ejecucion);
        END IF;

        IF c_ejecutar.modo_ejecucion = 'R' THEN

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Cbtes_inc_reales (+)');
          END IF;

          IF NOT cbtes_inc_reales(l_fecha_desde
                                 ,l_fecha_hasta
                                 ,l_conc_original
                                 ,l_incomplete) THEN
            fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
            RAISE e_exception;
          END IF;

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Cbtes_inc_reales (-)');
          END IF;

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Cbtes_sin_cae_reales (+)');
          END IF;

          IF NOT cbtes_sin_cae_reales(l_fecha_desde
                                     ,l_fecha_hasta
                                     ,l_conc_original
                                     ,l_cae_incomplete) THEN
            fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
            RAISE e_exception;
          END IF;

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Cbtes_sin_cae_reales (-)');
          END IF;

        ELSE

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Cbtes_sin_cae (+)');
          END IF;

          IF NOT cbtes_sin_cae(l_fecha_desde
                              ,l_fecha_hasta
                              ,p_source
                              ,l_conc_original
                              ,l_cae_incomplete) THEN
            fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
            RAISE e_exception;
          END IF;

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Cbtes_sin_cae (-)');
          END IF;

        END IF;

        l_cae_reint      := 0;

        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'l_cae_incomplete: '||l_cae_incomplete);
          fnd_file.put_line(fnd_file.log,'l_incomplete: '||l_incomplete);
          fnd_file.put_line(fnd_file.log,'Inicio reproceso - '||to_char(sysdate,'HH24:MI:SS'));
          fnd_file.put_line(fnd_file.log,'g_cae_reint: '||g_cae_reint);
        END IF;

        /*Agregado KHRONUS/E.Sly 03/2020 */
        IF c_ejecutar.modo_ejecucion = 'R' THEN
        /*Fin Agregado KHRONUS/E.Sly 03/2020 */
          WHILE ((l_cae_incomplete > 0 AND l_cae_reint < g_cae_reint) OR (l_incomplete > 0 AND l_cae_reint < g_cae_reint)) LOOP

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,chr(10)||'Pre c_batch');
            END IF;

            FOR r_batch in c_batch(c_ejecutar.modo_ejecucion
                                  ,l_fecha_desde
                                  ,l_fecha_hasta
                                  ,p_source
                                  ,l_conc_original) LOOP

              IF NOT XX_UTIL_PK.conc_submit_request(p_appl_short_name   => 'XBOL'
                                                   --,p_program_name      =>'XXWARTRXREPR'                            --XXW AR TRX Reproceso
                                                   ,p_program_name      => 'XXARFECI'
                                                   ,p_start_time        => to_char(sysdate,'RRRR/MM/DD HH24:MI:SS')
                                                   ,p_argument1         => r_batch.batch_source_id
                                                   ,p_argument2         => null
                                                   ,p_argument3         => 'N'
                                                   ,p_argument4         => null
                                                   ,p_wait              => 'Y'
                                                   ,p_wait_interval     => 10
                                                   ,p_request_id        => l_req_id
                                                   ,p_conc_status       => l_conc_status
                                                   ,p_conc_dev_status   => l_conc_dev_status
                                                   ,p_mesg_error        => l_mesg_error) THEN
                e_retcode:= 1;
                e_message:= 'Error ejecutando reproceso de facturas de AR - '||l_mesg_error;
                fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado ejecutando reproceso de facturas de AR consulte el registro para mas informacion');
                RAISE e_exception;
              END IF;

            END LOOP;

            l_cae_reint:= l_cae_reint + 1;

            IF c_ejecutar.modo_ejecucion = 'R' THEN

              IF NOT cbtes_inc_reales(l_fecha_desde
                                     ,l_fecha_hasta
                                     ,l_conc_original
                                     ,l_incomplete) THEN

                fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
                RAISE e_exception;

              END IF;

              IF NOT cbtes_sin_cae_reales(l_fecha_desde
                                         ,l_fecha_hasta
                                         ,l_conc_original
                                         ,l_cae_incomplete) THEN
                fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
                RAISE e_exception;
              END IF;

            ELSE

              IF NOT cbtes_sin_cae(l_fecha_desde
                                  ,l_fecha_hasta
                                  ,p_source
                                  ,l_conc_original
                                  ,l_cae_incomplete) THEN
                fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
                RAISE e_exception;
              END IF;

            END IF;

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,'Nro ejecucion reproceso: '||l_cae_reint||'. Cantidad cbtes sin CAE: '||l_cae_incomplete);
            END IF;

          END LOOP;

        END IF;

        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Fin reproceso - '||to_char(sysdate,'HH24:MI:SS'));
        END IF;

        IF l_cae_incomplete > 0 THEN

          --i := i+1;
          --c_list_requests.extend();
          c_list_requests('SINCAE').request_id:=l_cae_incomplete;
          c_list_requests('SINCAE').modo_ejecucion:=c_ejecutar.nombre_ejecucion;
          c_list_requests('SINCAE').estado:='SINCAE';

          /*Modificado KHRONUS/E.Sly 03/2020 */
          IF c_ejecutar.modo_ejecucion = 'I' THEN
          /*Modificado KHRONUS/E.Sly 03/2020 */
            fnd_file.put_line(fnd_file.output,chr(10)||'Se encontraron las siguientes transacciones sin CAE que no seran insertadas en la interfaz de Cuentas por Pagar');
            fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                              'Tipo Trx'            ||l_sep||
                                              'Nro. Trx'            ||l_sep||
                                              'Fecha Trx'           ||l_sep||
                                              'Cliente Envio'       ||l_sep||
                                              'Cliente Facturacion' ||l_sep||
                                              'Fecha Creacion');

            --IF c_ejecutar.modo_ejecucion = 'I' THEN    /*Modificado KHRONUS/E.Sly 03/2020 Se escribe la condición antes de los titulos */

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,chr(10)||'Pre c_facturas_inter_sel ');
            END IF;

            FOR c_cae_err IN c_facturas_inter_sel(l_fecha_desde, l_fecha_hasta, p_source, l_conc_original,'N') LOOP

              fnd_file.put_line(fnd_file.output, c_cae_err.batch_source_name  ||l_sep||
                                                 c_cae_err.cust_trx_type_name ||l_sep||
                                                 c_cae_err.trx_number         ||l_sep||
                                                 c_cae_err.trx_date           ||l_sep||
                                                 c_cae_err.ship_to_cust_name  ||l_sep||
                                                 c_cae_err.bill_to_cust_name  ||l_sep||
                                                 c_cae_err.creation_date);
            END LOOP;

          ELSE

            /*Agregado KHRONUS/E.Sly 03/2020 */
            fnd_file.put_line(fnd_file.output,chr(10)||'Se encontraron las siguientes transacciones sin CAE que no seran insertadas en la interfaz de Cuentas por Pagar');
            fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                              'Tipo Trx'            ||l_sep||
                                              'Nro. Trx'            ||l_sep||
                                              'Fecha Trx'           ||l_sep||
                                              'Cliente Envio'       ||l_sep||
                                              'Cliente Facturacion' ||l_sep||
                                              'Fecha Creacion');
            /*Agregado KHRONUS/E.Sly 03/2020 */

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,chr(10)||'Pre c_facturas_real_sel ');
            END IF;

            FOR c_cae_err IN c_facturas_real_sel(l_fecha_desde, l_fecha_hasta, p_source, l_conc_original) LOOP

              fnd_file.put_line(fnd_file.output, c_cae_err.batch_source_name  ||l_sep||
                                                 c_cae_err.cust_trx_type_name ||l_sep||
                                                 c_cae_err.trx_number         ||l_sep||
                                                 c_cae_err.trx_date           ||l_sep||
                                                 c_cae_err.ship_to_cust_name  ||l_sep||
                                                 c_cae_err.bill_to_cust_name  ||l_sep||
                                                 c_cae_err.creation_date);
            END LOOP;

          END IF;

          fnd_file.put_line(fnd_file.log,chr(10)||'Error existen '||l_cae_incomplete||' transacciones sin CAE que no seran insertadas en la interfaz de Cuentas por Pagar.');
          e_retcode:= 1;

        END IF;


        IF l_incomplete > 0 THEN

          --i := i+1;
          --c_list_requests.extend();
          c_list_requests('INCOMP').request_id:=l_incomplete;
          c_list_requests('INCOMP').modo_ejecucion:=c_ejecutar.nombre_ejecucion;
          c_list_requests('INCOMP').estado:='INCOMP';

          fnd_file.put_line(fnd_file.output,chr(10)||'Se encontraron las siguientes transacciones incompletas que no seran insertadas en la interfaz de Cuentas por Pagar');
          fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                            'Tipo Trx'            ||l_sep||
                                            'Nro. Trx'            ||l_sep||
                                            'Fecha Trx'           ||l_sep||
                                            'Cliente Envio'       ||l_sep||
                                            'Cliente Facturacion' ||l_sep||
                                            'Fecha Creacion');

          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'Pre c_facturas_interco_inc');
          END IF;

          FOR c_cae_err IN c_facturas_interco_inc(l_fecha_desde, l_fecha_hasta, p_source, l_conc_original) LOOP

            fnd_file.put_line(fnd_file.output, c_cae_err.batch_source_name  ||l_sep||
                                               c_cae_err.cust_trx_type_name ||l_sep||
                                               c_cae_err.trx_number         ||l_sep||
                                               c_cae_err.trx_date           ||l_sep||
                                               c_cae_err.ship_to_cust_name  ||l_sep||
                                               c_cae_err.bill_to_cust_name  ||l_sep||
                                               c_cae_err.creation_date);
          END LOOP;

          fnd_file.put_line(fnd_file.log,chr(10)||'Error existen '||l_incomplete||' transacciones incompletas que no seran insertadas en la interfaz de Cuentas por Pagar.');
          e_retcode:= 1;

        END IF;


        l_cant_insert :=0;
        l_cant_errors :=0;
        fnd_file.put_line(fnd_file.output,chr(10)||'Insertando nuevas transacciones '||c_ejecutar.nombre_ejecucion||' en la interfaz de Cuentas por Pagar');
        fnd_file.put_line(fnd_file.output,'Origen Trx'          ||l_sep||
                                          'Tipo Trx'            ||l_sep||
                                          'Nro. Trx'            ||l_sep||
                                          'Fecha Trx'           ||l_sep||
                                          'Cliente Envio'       ||l_sep||
                                          'Cliente Facturacion' ||l_sep||
                                          'Fecha Creacion');


        IF g_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,chr(10)||'Pre c_facturas_inter_sel 2');
        END IF;

        FOR c_fact_inter in c_facturas_inter_sel(l_fecha_desde, l_fecha_hasta, p_source, l_conc_original,'Y') LOOP

          /*Agregado KHRONUS/E.Sly 20191024 Debe tomar el termino de pago de AP desde AR, Sino tomar el del parametro*/
          BEGIN

            SELECT term_id
              INTO v_ap_term_id
              FROM ap_terms
             WHERE attribute_category = 'AR'
               AND attribute2 = to_char(c_fact_inter.ar_term_id);

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_ap_term_id := p_terms_id;

            WHEN TOO_MANY_ROWS THEN
              fnd_file.put_line(fnd_file.output,'El termino de pago de AR tiene mas de un termino de Pago en AP');
              RAISE e_exception;

            WHEN OTHERS THEN
              fnd_file.put_line(fnd_file.output,'Error inesperado al obtener el termino de pago (AP) asociado a la transaccion de AR');
              RAISE e_exception;
          END;

          /*Fin Agregado KHRONUS/E.Sly 20191024 Debe tomar el termino de pago de AP desde AR, Sino tomar el del parametro*/
          IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,chr(10)||'XX_AR_AP_INTERCO_PKG.crear_doc_inter: ');
            fnd_file.put_line(fnd_file.log,'Customer_trx_id: '||c_fact_inter.customer_trx_id);
            fnd_file.put_line(fnd_file.log,'Tipo trx: '||p_tipo_trx);
            fnd_file.put_line(fnd_file.log,'Source: '||p_source);
            fnd_file.put_line(fnd_file.log,'Pay Group: '||p_pay_group);
            fnd_file.put_line(fnd_file.log,'v_ap_term_id: '||v_ap_term_id);
            fnd_file.put_line(fnd_file.log,'p_payment_method_lookup_code: '||p_payment_method_lookup_code);
            fnd_file.put_line(fnd_file.log,'l_conc_original: '||l_conc_original);
          END IF;

          IF NOT XX_AR_AP_INTERCO_PKG.crear_doc_inter(c_fact_inter.customer_trx_id
                                                     ,p_tipo_trx
                                                     ,p_source
                                                     ,p_pay_group
                                                     /*Modificado KHRONUS/E.Sly 20191024 Debe tomar el termino de pago de AP desde AR, Sino tomar el del parametro*/
                                                     --,p_terms_id
                                                     ,v_ap_term_id
                                                     /*Fin Modificado KHRONUS/E.Sly 20191024 Debe tomar el termino de pago de AP desde AR, Sino tomar el del parametro*/
                                                     ,p_payment_method_lookup_code
                                                     ,l_conc_original) THEN

            e_retcode:= XX_AR_AP_INTERCO_PKG.e_retcode;
            e_message:= XX_AR_AP_INTERCO_PKG.e_message;

            IF e_retcode = 2 THEN
              fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
              RAISE e_exception;
            END IF;

            fnd_file.put_line(fnd_file.log,e_message||chr(10));
            l_cant_errors := l_cant_errors + 1;

          ELSE

            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,chr(10)||'XX_AR_AP_INTERCO_PKG.crear_doc_inter OK');
            END IF;

            fnd_file.put_line(fnd_file.output, c_fact_inter.batch_source_name  ||l_sep||
                                               c_fact_inter.cust_trx_type_name ||l_sep||
                                               c_fact_inter.trx_number         ||l_sep||
                                               c_fact_inter.trx_date           ||l_sep||
                                               c_fact_inter.ship_to_cust_name  ||l_sep||
                                               c_fact_inter.bill_to_cust_name  ||l_sep||
                                               c_fact_inter.creation_date);
            l_cant_insert :=l_cant_insert + 1;

            --FROZADOS
            --i := i+1;
            --c_list_requests.extend();
            c_list_requests('INTERCO').request_id:=l_conc_original;
            c_list_requests('INTERCO').modo_ejecucion:=c_ejecutar.nombre_ejecucion;
            c_list_requests('INTERCO').estado:='INTERCO';

          END IF;

        END LOOP;

        IF l_cant_errors >= 1 THEN
          fnd_file.put_line(fnd_file.output,chr(10)||'Se ha encontrado '||l_cant_errors||' registro con error. Consulte el log para mayor informacion.');
          --FROZADOS
          --i := i+1;
          --c_list_requests.extend();
          c_list_requests('IERROR').request_id:=l_cant_errors;
          c_list_requests('IERROR').modo_ejecucion:=c_ejecutar.nombre_ejecucion;
          c_list_requests('IERROR').estado:='IERROR';
        END IF;

        IF (l_cant_insert > 0 AND nvl(p_importar,'N') = 'Y') THEN

          BEGIN

            SELECT MO_GLOBAL.GET_CURRENT_ORG_ID  -- ITC
                   --fnd_profile.value('ORG_ID')
              INTO l_org_id_original
              FROM dual;

          EXCEPTION
            WHEN OTHERS THEN
              e_retcode :=2;
              e_message :='Error obteniendo valor para el perfil ORG_ID';
              fnd_file.put_line(fnd_file.output,chr(10)||'Error inesperado durante la ejecucion consulte el registro para mas informacion');
              RAISE e_exception;

          END;

          fnd_file.put_line(fnd_file.output,chr(10)||'Se debera ejecutar la interfaz de Cuentas por Pagar para las siguientes unidades operativas:');

          FOR c1 IN c_fact_interface_ap(p_source, l_conc_original) LOOP

            fnd_file.put_line(fnd_file.output,'   - '||c1.name);

          END LOOP;

        END IF;

      END IF;

    END LOOP;

    --FROZADOS ADDED
    IF c_list_requests.Count > 0 THEN
      PRINT_TOTAL(p_list_of_requests_t => c_list_requests);
    END IF;

    IF e_retcode = 2 THEN
      ROLLBACK;
    END IF;

    IF g_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log,chr(10)||'Fin Creacion de Documentos '||to_char(sysdate,'HH24:MI:SS'));
    END IF;

    retcode := e_retcode;

  EXCEPTION
    WHEN e_exception THEN
      retcode := e_retcode;
      errbuf  := e_message;
      fnd_file.put_line(fnd_file.log,e_message);
      fnd_file.put_line(fnd_file.output,chr(10)||'Se encontro un error en la ejecucion del programa de copia consulte el log para mayor informacion');

    WHEN OTHERS THEN
      retcode :=2;
      errbuf  :='Error main: '||sqlerrm;
      fnd_file.put_line(fnd_file.log,'Error main: '||sqlerrm);
      fnd_file.put_line(fnd_file.output,chr(10)||'Se encontro un error en la ejecucion del programa de copia consulte el log para mayor informacion');
  END main;

END XX_AR_TRX_FICTICIA_PKG; 
/

exit
