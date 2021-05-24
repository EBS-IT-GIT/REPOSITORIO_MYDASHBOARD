CREATE OR REPLACE PACKAGE APPS."XX_UTIL_PK" AUTHID CURRENT_USER AS
/* $Header: %M% %I% %G% %U% porting ship $ */
-- -----------------------------------------------------------------------------
-- Tipo de Registros y Tablas Globales.
-- -----------------------------------------------------------------------------
  -- Flexfields Descriptivos que se estan re-generando las vistas.
  TYPE dff_vg_rec_type IS RECORD(desc_appl_name            VARCHAR2(10)
                                ,desc_flex_name            VARCHAR2(40)
                                );
  TYPE dff_vg_tbl_type IS TABLE OF dff_vg_rec_type INDEX BY BINARY_INTEGER;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    get_country_code                                                      |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el codigo de pais de la funcion                   |
|    Xx_Jg_Zz_Shared_Pkg.Get_Country.                                      |
|                                                                          |
| Parameters                                                               |
|                                                                          |
+=========================================================================*/
FUNCTION get_country_code RETURN VARCHAR2;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    dff_get_column                                                        |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el nombre de columna de un flexfield descriptivo. |
|                                                                          |
| Parameters                                                               |
|    p_appl_short_name   IN     VARCHAR2 Codigo de Aplicacion.             |
|    p_desc_flex_name    IN     VARCHAR2 Nombre de flexfield descriptivo.  |
|    p_desc_flex_context IN     VARCHAR2 Contexto del flexfield desc.      |
|    p_desc_flex_column  IN     VARCHAR2 Columna del flexfield desc.       |
|    p_appl_column_name  OUT    VARCHAR2 Columna del flexfield desc.       |
|                                        obtenida.                         |
|    p_mesg_error        OUT    VARCHAR2 Mensaje de error.                 |
|                                                                          |
+=========================================================================*/
FUNCTION dff_get_column(p_appl_short_name   IN     VARCHAR2
                       ,p_desc_flex_name    IN     VARCHAR2
                       ,p_desc_flex_context IN     VARCHAR2 DEFAULT NULL
                       ,p_desc_flex_column  IN     VARCHAR2
                       ,p_appl_column_name  OUT    VARCHAR2
                       ,p_mesg_error        OUT    VARCHAR2
                       ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    dff_get_val                                                           |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene los valores de un flexfield descriptivo.          |
|                                                                          |
| Parameters                                                               |
|    p_appl_short_name   IN     VARCHAR2 Codigo de Aplicacion.             |
|    p_desc_flex_name    IN     VARCHAR2 Nombre de flexfield descriptivo.  |
|    p_rowid             IN     ROWID    Id del registro.                  |
|    p_desc_flex_context IN     VARCHAR2 Contexto del flexfield desc.      |
|    p_desc_flex_column  IN     VARCHAR2 Columna del flexfield desc.       |
|    p_desc_flex_value   OUT    VARCHAR2 Valor del flexfield descriptivo.  |
|    p_mesg_error        OUT    VARCHAR2 Mensaje de error.                 |
|                                                                          |
+=========================================================================*/
FUNCTION dff_get_val(p_appl_short_name   IN     VARCHAR2
                    ,p_desc_flex_name    IN     VARCHAR2
                    ,p_rowid             IN     ROWID
                    ,p_desc_flex_context IN     VARCHAR2 DEFAULT NULL
                    ,p_desc_flex_column  IN     VARCHAR2
                    ,p_desc_flex_value   OUT    VARCHAR2
                    ,p_mesg_error        OUT    VARCHAR2
                    ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    dff_update_val                                                        |
|                                                                          |
| Description                                                              |
|    Funcion que actualiza los valores de un flexfield descriptivo.        |
|                                                                          |
| Parameters                                                               |
|    p_appl_short_name    IN     VARCHAR2 Codigo de Aplicacion.            |
|    p_desc_flex_name     IN     VARCHAR2 Nombre de flexfield descriptivo. |
|    p_rowid              IN     ROWID    Id del registro.                 |
|    p_desc_flex_context  IN     VARCHAR2 Contexto del flexfield desc.     |
|    p_desc_flex_column   IN     VARCHAR2 Columna del flexfield desc.      |
|    p_desc_flex_value    IN     VARCHAR2 Valor del flexfield descriptivo. |
|    p_desc_flex_validate IN     VARCHAR2 Valida flexfield desc (Y/N).     |
|    p_commit             IN     VARCHAR2 Flag para realizar COMMIT (Y/N). |
|    p_count_upd          OUT    NUMBER   Cantidad de filas actualizadas.  |
|    p_mesg_error         OUT    VARCHAR2 Mensaje de error.                |
|                                                                          |
+=========================================================================*/
FUNCTION dff_update_val(p_appl_short_name    IN     VARCHAR2
                       ,p_desc_flex_name     IN     VARCHAR2
                       ,p_rowid              IN     ROWID
                       ,p_desc_flex_context  IN     VARCHAR2 DEFAULT NULL
                       ,p_desc_flex_column   IN     VARCHAR2
                       ,p_desc_flex_value    IN     VARCHAR2 DEFAULT NULL
                       ,p_desc_flex_validate IN     VARCHAR2 DEFAULT 'Y'
                       ,p_commit             IN     VARCHAR2
                       ,p_count_upd          OUT    NUMBER
                       ,p_mesg_error         OUT    VARCHAR2
                       ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    validate_dff_view_generation                                          |
|                                                                          |
| Description                                                              |
|    Funcion que controla que todos los Flexfields Descriptivos que se     |
|    estan re-generando las vistas, finalicen correctamente.               |
|    Se definio un tipo de registro para que se puedan validar multiples   |
|    Flexfields Descriptivos a la vez.                                     |
|                                                                          |
| Parameters                                                               |
|    p_appl_short_name    IN     dff_vg_tbl_type Tabla de Flexfields       |
|                                                Descriptivos.             |
|    p_message            OUT    VARCHAR2        Mensaje de error.         |
|                                                                          |
+=========================================================================*/
FUNCTION validate_dff_view_generation(p_dff_vg  IN     dff_vg_tbl_type
                                     ,p_message OUT    VARCHAR2
                                     ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    ff_get_segment_value                                                  |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el valor de un segmento de un Flexfield.          |
|                                                                          |
| Parameters                                                               |
|    p_concat_segments IN     VARCHAR2 Segmentos concatenados.             |
|    p_delimiter       IN     VARCHAR2 Delimitador de los segmentos.       |
|    p_seg_count       IN     NUMBER   Cantidad de segmentos.              |
|    p_seg_num         IN     NUMBER   Nro. de segmento a obtener.         |
|    p_seg_value       OUT    VARCHAR2 Valor del segmento obtenido.        |
|    p_mesg_error      OUT    VARCHAR2 Mensaje de error.                   |
|                                                                          |
+=========================================================================*/
FUNCTION ff_get_segment_value(p_concat_segments IN     VARCHAR2
                             ,p_delimiter       IN     VARCHAR2
                             ,p_seg_count       IN     NUMBER
                             ,p_seg_num         IN     NUMBER
                             ,p_seg_value       OUT    VARCHAR2
                             ,p_mesg_error      OUT    VARCHAR2
                             ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    vset_get_id_from_table                                                |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el id de un valor de un Juego de Valores de tipo  |
|    tabla.                                                                |
|                                                                          |
| Parameters                                                               |
|    p_flex_value_set_id   IN     NUMBER   Id de Juego de Valores.         |
|    p_flex_value_set_name IN     VARCHAR2 Nombre de Juego de Valores.     |
|    p_value               IN     VARCHAR2 Valor a buscar del Juego de     |
|                                          Valores.                        |
|    p_id                  OUT    VARCHAR2 Id del Valor que se obtuvo del  |
|                                          Juego de Valores.               |
|    p_mesg_error          OUT    VARCHAR2 Mensaje de error.               |
|                                                                          |
+=========================================================================*/
FUNCTION vset_get_id_from_table(p_flex_value_set_id   IN     NUMBER
                               ,p_flex_value_set_name IN     VARCHAR2
                               ,p_value               IN     VARCHAR2
                               ,p_id                  OUT    VARCHAR2
                               ,p_mesg_error          OUT    VARCHAR2
                               ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    conc_get_program_name                                                 |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el nombre de un programa concurrente.             |
|                                                                          |
| Parameters                                                               |
|    p_appl_short_name       IN     VARCHAR2 Codigo de Aplicacion.         |
|    p_program_name          IN     VARCHAR2 Nombre Corto del Programa     |
|                                            Concurrente.                  |
|    p_user_program_name     OUT    VARCHAR2 Nombre del Programa           |
|                                            Concurrente obtenido.         |
|    p_program_name_complete OUT    VARCHAR2 Nombre del Programa           |
|                                            Concurrente mas Nombre Corto  |
|                                            obtenido.                     |
|    p_mesg_error            OUT    VARCHAR2 Mensaje de error.             |
|                                                                          |
+=========================================================================*/
FUNCTION conc_get_program_name(p_appl_short_name       IN     VARCHAR2
                              ,p_program_name          IN     VARCHAR2
                              ,p_user_program_name     OUT    VARCHAR2
                              ,p_program_name_complete OUT    VARCHAR2
                              ,p_mesg_error            OUT    VARCHAR2
                              ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    conc_submit_request                                                   |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el nombre de un programa concurrente.             |
|                                                                          |
| Parameters                                                               |
|    p_appl_short_name   IN     VARCHAR2 Codigo de Aplicacion.             |
|    p_program_name      IN     VARCHAR2 Nombre Corto del Programa         |
|                                        Concurrente.                      |
|    p_description       IN     VARCHAR2 Descripcion del Programa          |
|                                        Concurrente obtenido.             |
|    p_start_time        IN     VARCHAR2 Fecha y hora de ejecucion.        |
|    p_sub_request       IN     BOOLEAN  Sub Concurrente.                  |
|    p_argument1..100    IN     VARCHAR2 Parametro1..100.                  |
|    p_parent_request_id IN     NUMBER   Request Id Padre.                 |
|    p_wait              IN     VARCHAR2 Espera a que finalice.            |
|    p_wait_interval     IN     NUMBER   Intervalo de espera.              |
|    p_wait_max          IN     NUMBER   Cantidad maxima de esperas.       |
|    p_length_line       IN     NUMBER   Largo de Linea.                   |
|    p_output            IN     VARCHAR2 Tipo de salida para desplegar:    |
|                                        - N:    No despliega.             |
|                                        - DBMS: Utiliza DBMS_OUTPUT.      |
|                                        - OUT:  Utiliza FND_FILE.OUT.     |
|                                        - LOG:  Utiliza FND_FILE.LOG.     |
|    p_request_id        OUT    NUMBER   Id de concurrente ejecutado.      |
|    p_conc_status       OUT    VARCHAR2 Estado de finalizacion del        |
|                                        concurrente.                      |
|    p_conc_dev_status   OUT    VARCHAR2 Codigo de estado de finalizacion  |
|                                        del concurrente.                  |
|    p_mesg_error        OUT    VARCHAR2 Mensaje de error.                 |
|                                                                          |
+=========================================================================*/
FUNCTION conc_submit_request(p_appl_short_name   IN     VARCHAR2
                            ,p_program_name      IN     VARCHAR2
                            ,p_description       IN     VARCHAR2 DEFAULT NULL
                            ,p_start_time        IN     VARCHAR2 DEFAULT NULL
                            ,p_sub_request       IN     BOOLEAN  DEFAULT FALSE
                            ,p_argument1         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument2         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument3         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument4         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument5         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument6         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument7         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument8         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument9         IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument10        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument11        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument12        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument13        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument14        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument15        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument16        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument17        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument18        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument19        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument20        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument21        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument22        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument23        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument24        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument25        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument26        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument27        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument28        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument29        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument30        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument31        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument32        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument33        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument34        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument35        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument36        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument37        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument38        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument39        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument40        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument41        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument42        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument43        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument44        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument45        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument46        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument47        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument48        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument49        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument50        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument51        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument52        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument53        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument54        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument55        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument56        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument57        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument58        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument59        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument60        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument61        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument62        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument63        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument64        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument65        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument66        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument67        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument68        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument69        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument70        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument71        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument72        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument73        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument74        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument75        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument76        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument77        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument78        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument79        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument80        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument81        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument82        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument83        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument84        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument85        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument86        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument87        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument88        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument89        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument90        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument91        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument92        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument93        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument94        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument95        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument96        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument97        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument98        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument99        IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_argument100       IN     VARCHAR2 DEFAULT CHR(0)
                            ,p_parent_request_id IN     NUMBER   DEFAULT NULL
                            ,p_wait              IN     VARCHAR2 DEFAULT 'N'
                            ,p_wait_interval     IN     NUMBER   DEFAULT 60
                            ,p_wait_max          IN     NUMBER   DEFAULT 0
                            ,p_length_line       IN     NUMBER   DEFAULT 100
                            ,p_output            IN     VARCHAR2 DEFAULT 'N'
                            ,p_request_id        OUT    NUMBER
                            ,p_conc_status       OUT    VARCHAR2
                            ,p_conc_dev_status   OUT    VARCHAR2
                            ,p_mesg_error        OUT    VARCHAR2
                            ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    conc_fatal_error                                                      |
|                                                                          |
| Description                                                              |
|    Funcion que despliega en el Log del programa concurrente un mensaje y |
|    lo completa con estado de Error.                                      |
|                                                                          |
| Parameters                                                               |
|    p_mesg_error IN OUT VARCHAR2 Mensaje de error.                        |
|                                                                          |
+=========================================================================*/
FUNCTION conc_fatal_error(p_mesg_error IN OUT VARCHAR2
                         ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    conc_get_session_data                                                 |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene los datos de la session de un concurrente.        |
|                                                                          |
| Parameters                                                               |
|    p_request_id IN      NUMBER   Id de Solicitud.                        |
|    p_address    OUT     RAW      Address obtenida.                       |
|    p_hash_value OUT     NUMBER   Valor hash obtenido.                    |
|    p_message    OUT     VARCHAR2 Mensaje.                                |
|    p_mesg_error OUT     VARCHAR2 Mensaje de error.                       |
|                                                                          |
+=========================================================================*/
FUNCTION conc_get_session_data(p_request_id IN      NUMBER
                              ,p_address    OUT     RAW
                              ,p_hash_value OUT     NUMBER
                              ,p_message    OUT     VARCHAR2
                              ,p_mesg_error OUT     VARCHAR2
                              ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    conc_get_session_sql                                                  |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene la sentencia sql de una session.                  |
|                                                                          |
| Parameters                                                               |
|    p_address    IN      RAW      Address.                                |
|    p_hash_value IN      NUMBER   Valor hash.                             |
|    p_message    OUT     VARCHAR2 Mensaje.                                |
|    p_mesg_error OUT     VARCHAR2 Mensaje de error.                       |
|                                                                          |
+=========================================================================*/
FUNCTION conc_get_session_sql(p_address    IN      RAW
                             ,p_hash_value IN      NUMBER
                             ,p_message    OUT     VARCHAR2
                             ,p_mesg_error OUT     VARCHAR2
                             ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    conc_get_session_sql_data                                             |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene los datos de la sentencia sql de una session.     |
|                                                                          |
| Parameters                                                               |
|    p_address    IN      RAW      Address.                                |
|    p_hash_value IN      NUMBER   Valor hash.                             |
|    p_message    OUT     VARCHAR2 Mensaje.                                |
|    p_mesg_error OUT     VARCHAR2 Mensaje de error.                       |
|                                                                          |
+=========================================================================*/
FUNCTION conc_get_session_sql_data(p_address    IN      RAW
                                  ,p_hash_value IN      NUMBER
                                  ,p_message    OUT     VARCHAR2
                                  ,p_mesg_error OUT     VARCHAR2
                                  ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    delete_table                                                          |
|                                                                          |
| Description                                                              |
|    Funcion que elimina registros de una tabla por medio de DELETE        |
|    o TRUNCATE.                                                           |
|                                                                          |
| Parameters                                                               |
|    p_del_type    IN     VARCHAR2 Tipo de Eliminacion                     |
|                                  (D=Delete,T=Truncate).                  |
|    p_owner_table IN     VARCHAR2 Owner de la Tabla.                      |
|    p_table_name  IN     VARCHAR2 Nombre de la Tabla.                     |
|    p_rowcount    OUT    NUMBER   Cantidad de registros eliminados.       |
|    p_mesg_error  OUT    VARCHAR2 Mensaje de Error.                       |
|                                                                          |
+=========================================================================*/
FUNCTION delete_table(p_del_type    IN     VARCHAR2 DEFAULT 'D'
                     ,p_owner_table IN     VARCHAR2
                     ,p_table_name  IN     VARCHAR2
                     ,p_rowcount    OUT    NUMBER
                     ,p_mesg_error  OUT    VARCHAR2
                     ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    to_num                                                                |
|                                                                          |
| Description                                                              |
|    Funcion que convierte un string a numero, independientemente si el    |
|    string tiene letras.                                                  |
|                                                                          |
| Parameters                                                               |
|    p_string IN     VARCHAR2 String a convertir.                          |
|                                                                          |
+=========================================================================*/
FUNCTION to_num(p_string IN     VARCHAR2
               ) RETURN NUMBER;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    get_org_id                                                            |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el Id de la Organizacion a partir del Nombre.     |
|                                                                          |
| Parameters                                                               |
|    p_org_name IN     VARCHAR2 Nombre de la Organizacion.                 |
|    p_org_id   OUT    NUMBER   Id de la Organizacion que se obtuvo.       |
|    p_errmsg   OUT    VARCHAR2 Mensaje de Error.                          |
|                                                                          |
+=========================================================================*/
FUNCTION get_org_id(p_org_name IN     VARCHAR2
                   ,p_org_id   OUT    NUMBER
                   ,p_errmsg   OUT    VARCHAR2
                   ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    get_org_name                                                          |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el Id de la Otganizacion a partir del Nombre.     |
|                                                                          |
| Parameters                                                               |
|    p_org_id   IN     NUMBER   Id de la Organizacion.                     |
|    p_org_name OUT    VARCHAR2 Nombre de la Organizacion que se obtuvo.   |
|    p_errmsg   OUT    VARCHAR2 Mensaje de Error.                          |
|                                                                          |
+=========================================================================*/
FUNCTION get_org_name(p_org_id   IN     NUMBER
                     ,p_org_name OUT    VARCHAR2
                     ,p_errmsg   OUT    VARCHAR2
                     ) RETURN BOOLEAN;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    init_responsibility                                                   |
|                                                                          |
| Description                                                              |
|    Initialize the user and responsibility for a give user/resp in Oracle |
|    Financials. Derive all the profiles options associated with this.     |
|    The function returns TRUE if the initialization was succesfull and    |
|    FALSE it it was wrong.                                                |
|                                                                          |
| Parameters                                                               |
|    p_user_name           IN     VARCHAR2 Nombre de Usuario.              |
|    p_responsibility_name IN     VARCHAR2 Nombre de Responsabilidad.      |
|    p_errmsg              OUT    VARCHAR2 Mensaje de error.               |
|                                                                          |
+=========================================================================*/
FUNCTION init_responsibility(p_user_name           IN     VARCHAR2
                            ,p_responsibility_name IN     VARCHAR2
                            ,p_errmsg              OUT    VARCHAR2
                            ) RETURN BOOLEAN;


/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    exec_sql_statement                                                    |
|                                                                          |
| Description                                                              |
|    Ejecuta una sentencia sql.                                            |
|                                                                          |
| Parameters                                                               |
|    p_sql_statement IN     VARCHAR2 Sentencia sql.                        |
|    p_mesg_error    OUT    VARCHAR2 Mensaje de Error.                     |
|                                                                          |
+=========================================================================*/
FUNCTION exec_sql_statement(p_sql_statement IN     VARCHAR2
                           ,p_in_param1     IN     VARCHAR2 DEFAULT NULL
                           ,p_in_param2     IN     VARCHAR2 DEFAULT NULL
                           ,p_in_param3     IN     VARCHAR2 DEFAULT NULL
                           ,p_in_param4     IN     VARCHAR2 DEFAULT NULL
                           ,p_in_param5     IN     VARCHAR2 DEFAULT NULL
                           ,p_mesg_error    OUT    VARCHAR2
                           ) RETURN BOOLEAN;


/* CR1220 */
FUNCTION Set_Profile_Value ( p_profile_name    VARCHAR2
                           , p_new_value       VARCHAR2
                           , p_level           VARCHAR2
                           , p_level_value     VARCHAR2 DEFAULT NULL
                           , p_app_id          VARCHAR2 DEFAULT NULL
                           , p_level_value2    VARCHAR2 DEFAULT NULL
                           ) RETURN BOOLEAN;


/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    getElapsedTime                                                        |
|                                                                          |
| Description                                                              |
|    Devuelve el tiempo transcurrido entre 2 fechas en el formato          |
|    Horas:Minutos:Segundos.                                               |
|    CR2218  APetrocelli                                                   |
|                                                                          |
| Parameters                                                               |
|    p_init          IN     DATE     Fechas Desde                          |
|    p_end           IN     DATE     Fechas Desde                          |
|                                                                          |
+=========================================================================*/
  FUNCTION getElapsedTime (p_init DATE, p_end DATE) RETURN VARCHAR2;



  FUNCTION xml_escape_chars ( p_data VARCHAR2 ) RETURN VARCHAR2;


  FUNCTION xml_num_display ( p_data         NUMBER
                           , p_nls_num_char VARCHAR2 DEFAULT NULL
                           , p_thousands    VARCHAR2 DEFAULT 'Y'
                           ) RETURN VARCHAR2;


  -- CR2475 - ASilva - Mayo 2020
  FUNCTION xml_accepted_chars ( p_data VARCHAR2 ) RETURN VARCHAR2;
   

  FUNCTION get_perfil_cliente ( p_cust_acct_id  NUMBER
                              , p_site_use_id   NUMBER
                              ) RETURN VARCHAR2;

END xx_util_pk;
/

