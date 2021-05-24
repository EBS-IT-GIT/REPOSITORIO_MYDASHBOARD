  set define off;

  CREATE OR REPLACE PACKAGE "APPS"."XX_UTIL_PK" AUTHID CURRENT_USER AS
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


  CREATE OR REPLACE PACKAGE BODY "APPS"."XX_UTIL_PK" AS
/* $Header: %M% %I% %G% %U% porting ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT CONSTANT NUMBER := Fnd_Log.LEVEL_STATEMENT;
  G_MODULE_NAME CONSTANT VARCHAR2(50) := 'XX.PLSQL.XX_UTIL_PK.';

  /*=========================================================================+
  |                                                                          |
  | Private Procedure                                                        |
  |    debug                                                                 |
  |                                                                          |
  | Description                                                              |
  |    Procedimiento que escribe en log un determinado mensaje.              |
  |                                                                          |
  | Parameters                                                               |
  |    p_log_msg IN VARCHAR2 Mensaje a ser escrito por el log.               |
  |                                                                          |
  +=========================================================================*/
  PROCEDURE debug ( p_log_msg IN VARCHAR2)
  IS
  BEGIN

    -- Logging Infra: Procedure level
    IF (G_LEVEL_STATEMENT  >=  G_CURRENT_RUNTIME_LEVEL)
    THEN

      Fnd_Log.String(G_LEVEL_STATEMENT, G_MODULE_NAME, p_log_msg);

    END IF;

  END debug;

/*=========================================================================+
|                                                                          |
| Private Procedure                                                        |
|    display_message_split                                                 |
|                                                                          |
| Description                                                              |
|    Procedimiento que despliega un mensaje en varias lineas, de acuerdo   |
|    al largo a la linea.                                                  |
|                                                                          |
| Parameters                                                               |
|    p_length_line IN     NUMBER   Largo de Linea.                         |
|    p_output      IN     VARCHAR2 Tipo de salida para desplegar.          |
|    p_message     IN     VARCHAR2 Mensaje.                                |
|                                                                          |
+=========================================================================*/
PROCEDURE display_message_split(p_length_line IN     NUMBER   DEFAULT 100
                               ,p_output      IN     VARCHAR2
                               ,p_message     IN     VARCHAR2
                               )
IS
  v_cnt             NUMBER(15);
  v_message_length  NUMBER(15);
  v_message         VARCHAR2(4000);
  v_other_statement VARCHAR2(4000);
BEGIN
  -- ---------------------------------------------------------------------------
  -- Obtengo la longitud del mensaje.
  -- ---------------------------------------------------------------------------
  v_message_length := p_length_line;
  IF p_output         = 'DBMS' AND
     v_message_length > 255    THEN
     v_message_length := 255;
  END IF;
  -- ---------------------------------------------------------------------------
  -- Despliego el mensaje.
  -- ---------------------------------------------------------------------------
  FOR v_cnt IN 1..4000/v_message_length LOOP
      v_message := NULL;
      IF v_cnt = 1 THEN
         IF LENGTH(p_message) >= v_cnt * v_message_length THEN
            v_message := SUBSTR(p_message
                               ,1
                               ,v_cnt * v_message_length
                               );
         ELSE
            IF LENGTH(p_message) >= 1                        AND
               LENGTH(p_message) <  v_cnt * v_message_length THEN
               v_message := SUBSTR(p_message
                                  ,1
                                  );
            END IF;
         END IF;
      ELSE
         IF LENGTH(p_message) >= v_cnt * v_message_length THEN
            v_message := SUBSTR(p_message
                               ,((v_cnt-1
                                 ) * v_message_length
                                ) + 1
                               ,v_message_length
                               );
         ELSE
            IF LENGTH(p_message) >= ((v_cnt-1) * v_message_length) AND
               LENGTH(p_message) <    v_cnt    * v_message_length  THEN
               v_message := SUBSTR(p_message
                                  ,((v_cnt-1
                                    ) * v_message_length
                                   ) + 1
                                  );
            END IF;
         END IF;
      END IF;
      v_message := LTRIM(RTRIM(v_message));
      IF v_message IS NOT NULL THEN
         IF p_output = 'DBMS' THEN
            DBMS_OUTPUT.PUT_LINE(v_message);
         ELSIF p_output = 'CONC_OUT' THEN
            fnd_file.put(fnd_file.output
                        ,v_message
                        );
            fnd_file.new_line(fnd_file.output
                             ,1
                             );
         ELSIF p_output = 'CONC_LOG' THEN
            fnd_file.put(fnd_file.LOG
                        ,v_message
                        );
            fnd_file.new_line(fnd_file.LOG
                             ,1
                             );
         END IF;
      END IF;
  END LOOP;
END display_message_split;
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
FUNCTION get_country_code RETURN VARCHAR2
IS
  v_country_code VARCHAR2(30);
BEGIN

  RETURN Xx_Jg_Zz_Shared_Pkg.Get_Country(p_org_id => Mo_Global.Get_Current_Org_Id,
                                      p_ledger_id => NULL,
                                      p_inv_org_id => NULL);

END get_country_code;

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
                       ) RETURN BOOLEAN
IS
  v_found1            VARCHAR2(1);
  v_found2            VARCHAR2(1);
  v_found3            VARCHAR2(1);
  v_application_id    NUMBER(15);
  v_desc_flex_context VARCHAR2(30);
  CURSOR fdf IS
    SELECT fdfv.application_id
          ,fdfv.application_table_name
          ,fdfv.title
          ,fdfv.context_column_name
      FROM fnd_descriptive_flexs_vl        fdfv
          ,fnd_application                 fa
     WHERE fa.application_short_name       = p_appl_short_name
       AND fa.application_id               = fdfv.application_id
       AND fdfv.descriptive_flexfield_name = p_desc_flex_name;
  CURSOR fdfc IS
    SELECT fdfcv.descriptive_flex_context_code
          ,fdfcv.description
          ,fdfcv.global_flag
      FROM fnd_descr_flex_contexts_vl       fdfcv
     WHERE fdfcv.application_id             = v_application_id
       AND fdfcv.descriptive_flexfield_name = p_desc_flex_name
       AND fdfcv.enabled_flag               = 'Y'
       AND ((p_desc_flex_context            IS NULL
       AND   fdfcv.global_flag              = 'Y'
            )
       OR   (p_desc_flex_context           IS NOT NULL
       AND   p_desc_flex_context           = fdfcv.descriptive_flex_context_code
            )
           );
  CURSOR fdfcu IS
    SELECT fdfcuv.end_user_column_name
          ,fdfcuv.application_column_name
          ,fdfcuv.form_left_prompt
          ,fdfcuv.description
      FROM fnd_descr_flex_col_usage_vl          fdfcuv
     WHERE fdfcuv.application_id                = v_application_id
       AND fdfcuv.descriptive_flexfield_name    = p_desc_flex_name
       AND fdfcuv.descriptive_flex_context_code = v_desc_flex_context
       AND fdfcuv.end_user_column_name          = p_desc_flex_column
       AND fdfcuv.enabled_flag                  = 'Y';
BEGIN
  v_found1 := 'N';
  v_found2 := 'N';
  v_found3 := 'N';
  FOR cfdf IN fdf LOOP
      v_found1         := 'Y';
      v_application_id := cfdf.application_id;
      FOR cfdfc IN fdfc LOOP
          v_found2            := 'Y';
          v_desc_flex_context := cfdfc.descriptive_flex_context_code;
          FOR cfdfcu IN fdfcu LOOP
              v_found3           := 'Y';
              p_appl_column_name := cfdfcu.application_column_name;
              EXIT;
          END LOOP;
          IF v_found3 = 'N' THEN
             p_mesg_error := 'XX_UTIL_PK.DFF_GET_COLUMN. '  ||
                             'No se encontro la Columna: '  ||
                             p_desc_flex_column             ||
                             ' del Contexto: '              ||
                             p_desc_flex_context            ||
                             ' del Flexfield Descriptivo: ' ||
                             p_desc_flex_name               ||
                             ' para la Aplicacion: '        ||
                             p_appl_short_name;
             RETURN (FALSE);
          END IF;
          EXIT;
      END LOOP;
      IF v_found2 = 'N' THEN
         p_mesg_error := 'XX_UTIL_PK.DFF_GET_COLUMN. '  ||
                         'No se encontro el Contexto: ' ||
                         p_desc_flex_context            ||
                         ' del Flexfield Descriptivo: ' ||
                         p_desc_flex_name               ||
                         ' para la Aplicacion: '        ||
                         p_appl_short_name;
         RETURN (FALSE);
      END IF;
      EXIT;
  END LOOP;
  IF v_found1 = 'N' THEN
     p_mesg_error := 'XX_UTIL_PK.DFF_GET_COLUMN. '               ||
                     'No se encontro el Flexfield Descriptivo: ' ||
                     p_desc_flex_name                            ||
                     ' para la Aplicacion: '                     ||
                     p_appl_short_name;
     RETURN (FALSE);
  END IF;
  RETURN (TRUE);
END dff_get_column;
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
                    ) RETURN BOOLEAN
IS
  v_found1            VARCHAR2(1);
  v_found2            VARCHAR2(1);
  v_found3            VARCHAR2(1);
  v_application_id    NUMBER(15);
  v_desc_flex_context VARCHAR2(30);
  v_statment          VARCHAR2(250);
  v_ret               INTEGER;
  v_cur               INTEGER;
  v_desc_flex_value   VARCHAR2(150);
  CURSOR fdf IS
    SELECT fdfv.application_id
          ,fdfv.application_table_name
          ,fdfv.title
          ,fdfv.context_column_name
      FROM fnd_descriptive_flexs_vl fdfv
          ,fnd_application          fa
     WHERE fa.application_short_name       = p_appl_short_name
       AND fa.application_id               = fdfv.application_id
       AND fdfv.descriptive_flexfield_name = p_desc_flex_name;
  CURSOR fdfc IS
    SELECT fdfcv.descriptive_flex_context_code
          ,fdfcv.description
          ,fdfcv.global_flag
      FROM fnd_descr_flex_contexts_vl fdfcv
     WHERE fdfcv.application_id             = v_application_id
       AND fdfcv.descriptive_flexfield_name = p_desc_flex_name
       AND fdfcv.enabled_flag               = 'Y'
       AND ((p_desc_flex_context            IS NULL
       AND   fdfcv.global_flag              = 'Y'
            )
       OR   (p_desc_flex_context           IS NOT NULL
       AND   p_desc_flex_context           = fdfcv.descriptive_flex_context_code
            )
           );
  CURSOR fdfcu IS
    SELECT fdfcuv.end_user_column_name
          ,fdfcuv.application_column_name
          ,fdfcuv.form_left_prompt
          ,fdfcuv.description
      FROM fnd_descr_flex_col_usage_vl fdfcuv
     WHERE fdfcuv.application_id                = v_application_id
       AND fdfcuv.descriptive_flexfield_name    = p_desc_flex_name
       AND fdfcuv.descriptive_flex_context_code = v_desc_flex_context
       AND fdfcuv.end_user_column_name          = p_desc_flex_column
       AND fdfcuv.enabled_flag                  = 'Y';
BEGIN
  v_found1 := 'N';
  v_found2 := 'N';
  v_found3 := 'N';
  FOR cfdf IN fdf LOOP
      v_found1         := 'Y';
      v_application_id := cfdf.application_id;
      FOR cfdfc IN fdfc LOOP
          v_found2            := 'Y';
          v_desc_flex_context := cfdfc.descriptive_flex_context_code;
          FOR cfdfcu IN fdfcu LOOP
              v_found3 := 'Y';
              v_statment := 'SELECT '                      ||
                            cfdfcu.application_column_name ||
                            ' FROM '                       ||
                            cfdf.application_table_name    ||
                            ' WHERE ROWID = '''            ||
                            ROWIDTOCHAR(p_rowid)           ||
                            '''';
              BEGIN
                v_cur := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(v_cur
                              ,v_statment
                              ,dbms_sql.v7
                              );
                DBMS_SQL.DEFINE_COLUMN_CHAR(v_cur
                                           ,1
                                           ,v_desc_flex_value
                                           ,30
                                           );
                v_ret := DBMS_SQL.EXECUTE(v_cur);
                IF DBMS_SQL.FETCH_ROWS(v_cur) > 0 THEN
                   DBMS_SQL.COLUMN_VALUE_CHAR(v_cur
                                             ,1
                                             ,v_desc_flex_value
                                             );
                   IF v_desc_flex_value IS NOT NULL THEN
                      p_desc_flex_value := v_desc_flex_value;
                   END IF;
                END IF;
                DBMS_SQL.CLOSE_CURSOR(v_cur);
              EXCEPTION
                WHEN others THEN
                  p_mesg_error := 'XX_UTIL_PK.DFF_GET_VAL. '         ||
                                  'Error ejecutando la sentencia: "' ||
                                  v_statment                         ||
                                  '". '                              ||
                                  SQLERRM;
                  RETURN (FALSE);
              END;
              EXIT;
          END LOOP;
          IF v_found3 = 'N' THEN
             p_mesg_error := 'XX_UTIL_PK.DFF_GET_VAL. '     ||
                             'No se encontro la Columna: '  ||
                             p_desc_flex_column             ||
                             ' del Contexto: '              ||
                             p_desc_flex_context            ||
                             ' del Flexfield Descriptivo: ' ||
                             p_desc_flex_name               ||
                             ' para la Aplicacion: '        ||
                             p_appl_short_name;
             RETURN (FALSE);
          END IF;
          EXIT;
      END LOOP;
      IF v_found2 = 'N' THEN
         p_mesg_error := 'XX_UTIL_PK.DFF_GET_VAL. '     ||
                         'No se encontro el Contexto: ' ||
                         p_desc_flex_context            ||
                         ' del Flexfield Descriptivo: ' ||
                         p_desc_flex_name               ||
                         ' para la Aplicacion: '        ||
                         p_appl_short_name;
         RETURN (FALSE);
      END IF;
      EXIT;
  END LOOP;
  IF v_found1 = 'N' THEN
     p_mesg_error := 'XX_UTIL_PK.DFF_GET_VAL. '                  ||
                     'No se encontro el Flexfield Descriptivo: ' ||
                     p_desc_flex_name                            ||
                     ' para la Aplicacion: '                     ||
                     p_appl_short_name;
     RETURN (FALSE);
  END IF;
  RETURN (TRUE);
END dff_get_val;
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
|    p_desc_flex_validate IN     VARCHAR2 Valida flexfield desc. Y/N).     |
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
                       ) RETURN BOOLEAN
IS
  v_found1                VARCHAR2(1);
  v_found2                VARCHAR2(1);
  v_found3                VARCHAR2(1);
  v_application_id        NUMBER(15);
  v_desc_flex_context     VARCHAR2(30);
  v_statment              VARCHAR2(250);
  v_ret                   INTEGER;
  v_cur                   INTEGER;
  v_view_name             VARCHAR2(30);
  v_concatenated_segments VARCHAR2(30);
  CURSOR fdf IS
    SELECT fdfv.application_id
          ,fdfv.application_table_name
          ,fdfv.title
          ,fdfv.context_column_name
      FROM fnd_descriptive_flexs_vl fdfv
          ,fnd_application          fa
     WHERE fa.application_short_name       = p_appl_short_name
       AND fa.application_id               = fdfv.application_id
       AND fdfv.descriptive_flexfield_name = p_desc_flex_name;
  CURSOR fdfc IS
    SELECT fdfcv.descriptive_flex_context_code
          ,fdfcv.description
          ,fdfcv.global_flag
      FROM fnd_descr_flex_contexts_vl fdfcv
     WHERE fdfcv.application_id             = v_application_id
       AND fdfcv.descriptive_flexfield_name = p_desc_flex_name
       AND fdfcv.enabled_flag               = 'Y'
       AND ((p_desc_flex_context            IS NULL
       AND   fdfcv.global_flag              = 'Y'
            )
       OR   (p_desc_flex_context           IS NOT NULL
       AND   p_desc_flex_context           = fdfcv.descriptive_flex_context_code
            )
           );
  CURSOR fdfcu IS
    SELECT fdfcuv.end_user_column_name
          ,fdfcuv.application_column_name
          ,fdfcuv.form_left_prompt
          ,fdfcuv.description
      FROM fnd_descr_flex_col_usage_vl fdfcuv
     WHERE fdfcuv.application_id                = v_application_id
       AND fdfcuv.descriptive_flexfield_name    = p_desc_flex_name
       AND fdfcuv.descriptive_flex_context_code = v_desc_flex_context
       AND fdfcuv.end_user_column_name          = p_desc_flex_column
       AND fdfcuv.enabled_flag                  = 'Y';
BEGIN
  p_count_upd := 0;
  v_found1    := 'N';
  v_found2    := 'N';
  v_found3    := 'N';
  FOR cfdf IN fdf LOOP
      v_found1         := 'Y';
      v_application_id := cfdf.application_id;
      FOR cfdfc IN fdfc LOOP
          v_found2            := 'Y';
          v_desc_flex_context := cfdfc.descriptive_flex_context_code;
          FOR cfdfcu IN fdfcu LOOP
              v_found3 := 'Y';
              v_statment := 'UPDATE '                      ||
                            cfdf.application_table_name    ||
                            ' SET '                        ||
                            cfdfcu.application_column_name ||
                            ' = ';
              IF p_desc_flex_value IS NULL THEN
                 v_statment := v_statment ||
                               'NULL';
              ELSE
                 v_statment := v_statment        ||
                               ''''              ||
                               p_desc_flex_value ||
                               '''';
              END IF;
              IF NVL(cfdfc.global_flag,'N') != 'Y' THEN
                 v_statment := v_statment               ||
                               ' ,'                     ||
                               cfdf.context_column_name ||
                               ' = '''                  ||
                               p_desc_flex_context      ||
                               '''';
              END IF;
              v_statment := v_statment            ||
                            ' WHERE rowid = '''   ||
                            ROWIDTOCHAR(p_rowid)  ||
                            '''';
              BEGIN
                v_cur := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(v_cur
                              ,v_statment
                              ,dbms_sql.v7
                              );
                v_ret := DBMS_SQL.EXECUTE(v_cur);
                DBMS_SQL.CLOSE_CURSOR(v_cur);
              EXCEPTION
                WHEN others THEN
                  p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '      ||
                                  'Error ejecutando la sentencia: "' ||
                                  v_statment                         ||
                                  '". '                              ||
                                  SQLERRM;
                  RETURN (FALSE);
              END;
              p_count_upd := v_ret;
              IF p_desc_flex_validate = 'Y' THEN
                 v_view_name := SUBSTR(cfdf.application_table_name
                                      ,1
                                      ,26
                                      ) ||
                                '_DFV';
                 v_statment := 'SELECT CONCATENATED_SEGMENTS' ||
                               ' FROM '                       ||
                               v_view_name                    ||
                               ' WHERE row_id = '''           ||
                               ROWIDTOCHAR(p_rowid)           ||
                               '''';
                 BEGIN
                   v_cur := DBMS_SQL.OPEN_CURSOR;
                   DBMS_SQL.PARSE(v_cur
                                 ,v_statment
                                 ,dbms_sql.v7
                                 );
                   DBMS_SQL.DEFINE_COLUMN_CHAR(v_cur
                                              ,1
                                              ,v_concatenated_segments
                                              ,30
                                              );
                   v_ret := DBMS_SQL.EXECUTE(v_cur);
                   IF DBMS_SQL.FETCH_ROWS(v_cur) > 0 THEN
                      DBMS_SQL.COLUMN_VALUE_CHAR(v_cur
                                                ,1
                                                ,v_concatenated_segments
                                                );
                   END IF;
                   DBMS_SQL.CLOSE_CURSOR(v_cur);
                   p_mesg_error := v_concatenated_segments;
                 EXCEPTION
                   WHEN others THEN
                     p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '      ||
                                     'Error ejecutando la sentencia: "' ||
                                     v_statment                         ||
                                     '". '                              ||
                                     SQLERRM;
                     RETURN (FALSE);
                 END;
                 IF NOT fnd_flex_descval.val_desc(p_appl_short_name
                                                 ,p_desc_flex_name
                                                 ,v_concatenated_segments
                                                 ,'I'
                                                 ,SYSDATE
                                                 ,TRUE
                                                 ,NULL
                                                 ,NULL
                                                 ) THEN
                    BEGIN
                      p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '           ||
                                      'Error validando '                      ||
                                      'Flexfield Descriptivo '                ||
                                      p_desc_flex_name                        ||
                                      ' de la Aplicacion '                    ||
                                      p_appl_short_name                       ||
                                      ': '                                    ||
                                      v_concatenated_segments                 ||
                                      '. Segmento '                           ||
                                      TO_CHAR(fnd_flex_descval.error_segment) ||
                                      '. '                                    ||
                                      fnd_flex_descval.error_message;
                      RETURN (FALSE);
                    EXCEPTION
                      WHEN others THEN
                        p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '    ||
                                        'Error buscando el error de la ' ||
                                        'validacion del '                ||
                                        'Flexfield Descriptivo '         ||
                                        p_desc_flex_name                 ||
                                        ' de la Aplicacion '             ||
                                        p_appl_short_name                ||
                                        ': '                             ||
                                        v_concatenated_segments          ||
                                        '. '                             ||
                                        SQLERRM;
                        RETURN (FALSE);
                    END;
                 END IF;
              END IF;
              IF p_commit = 'Y' THEN
                 COMMIT;
              END IF;
              EXIT;
          END LOOP;
          IF v_found3 = 'N' THEN
             p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '   ||
                             'No se encontro la Columna: '   ||
                             p_desc_flex_column              ||
                             ' del Contexto: '               ||
                             p_desc_flex_context             ||
                             ' del Flexfield Descriptivo: '  ||
                             p_desc_flex_name                ||
                             ' para la Aplicacion: '         ||
                             p_appl_short_name;
             RETURN (FALSE);
          END IF;
          EXIT;
      END LOOP;
      IF v_found2 = 'N' THEN
         p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '   ||
                         'No se encontro el Contexto: '  ||
                         p_desc_flex_context             ||
                         ' del Flexfield Descriptivo: '  ||
                         p_desc_flex_name                ||
                         ' para la Aplicacion: '         ||
                         p_appl_short_name;
         RETURN (FALSE);
      END IF;
      EXIT;
  END LOOP;
  IF v_found1 = 'N' THEN
     p_mesg_error := 'XX_UTIL_PK.DFF_UPDATE_VAL. '               ||
                     'No se encontro el Flexfield Descriptivo: ' ||
                     p_desc_flex_name                            ||
                     ' para la Aplicacion: '                     ||
                     p_appl_short_name;
     RETURN (FALSE);
  END IF;
  RETURN (TRUE);
END dff_update_val;
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
                                     ) RETURN BOOLEAN
IS
  v_idx                        NUMBER(15);
  v_length_line                NUMBER(15)  := 80;
  v_output                     VARCHAR2(10):= 'OUT';
  v_desc_flex_name             VARCHAR2(40);
  v_desc_appl_id               NUMBER(15);
  v_request_id                 NUMBER(15);
  v_conc_appl_short_name       VARCHAR2(50) := 'FND';
  v_conc_program_name          VARCHAR2(30) := 'FDFVGN';
  v_conc_user_program_name     VARCHAR2(240);
  v_conc_program_name_complete VARCHAR2(240);
  v_conc_application_id        NUMBER(15);
  v_conc_argument1             VARCHAR2(240) := '3';
  v_conc_phase                 VARCHAR2(30);
  v_conc_status                VARCHAR2(30);
  v_conc_dev_phase             VARCHAR2(30);
  v_conc_dev_status            VARCHAR2(30);
  v_conc_message               VARCHAR2(2000);
  v_mesg_error                 VARCHAR2(2000) := NULL;
  v_status_error               VARCHAR2(1):= 'N';
BEGIN
  -- ---------------------------------------------------------------------------
  -- Obtengo el Id de la Aplicacion del Concurrente Flexfield View Generator.
  -- ---------------------------------------------------------------------------
  IF v_mesg_error IS NULL THEN
     BEGIN
       SELECT fa.application_id
         INTO v_conc_application_id
         FROM fnd_application fa
        WHERE fa.application_short_name = v_conc_appl_short_name;
     EXCEPTION
        WHEN no_data_found THEN
          v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                          'No se encontro la Aplicacion: '            ||
                          v_conc_appl_short_name;
        WHEN others THEN
          v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                          'Error buscando la Aplicacion: '            ||
                          v_conc_appl_short_name                      ||
                          '. '                                        ||
                          SQLERRM;
     END;
  END IF;
  -- ---------------------------------------------------------------------------
  -- Obtengo el Nombre del Concurrente Flexfield View Generator.
  -- ---------------------------------------------------------------------------
  IF v_mesg_error IS NULL THEN
     IF NOT xx_util_pk.conc_get_program_name
              (p_appl_short_name       => v_conc_appl_short_name
              ,p_program_name          => v_conc_program_name
              ,p_user_program_name     => v_conc_user_program_name
              ,p_program_name_complete => v_conc_program_name_complete
              ,p_mesg_error            => v_mesg_error
              ) THEN
        v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                        v_mesg_error;
     END IF;
  END IF;
  -- ---------------------------------------------------------------------------
  -- Recorro los Flexfields Descriptivos de la tabla, pasados como parametros.
  -- ---------------------------------------------------------------------------
  IF v_mesg_error IS NULL THEN
     FOR v_idx IN p_dff_vg.first .. p_dff_vg.last LOOP
         v_desc_flex_name  := p_dff_vg(v_idx).desc_flex_name;
         v_desc_appl_id    := NULL;
         v_request_id      := NULL;
         v_conc_phase      := NULL;
         v_conc_status     := NULL;
         v_conc_dev_phase  := NULL;
         v_conc_dev_status := NULL;
         -- --------------------------------------------------------------------
         -- Obtengo el Id de la Aplicacion del Flexfield Descriptivo.
         -- --------------------------------------------------------------------
         BEGIN
           SELECT fa.application_id
             INTO v_desc_appl_id
             FROM fnd_application fa
            WHERE fa.application_short_name = p_dff_vg(v_idx).desc_appl_name;
         EXCEPTION
           WHEN no_data_found THEN
              v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                              'No se encontro el Id de la Aplicacion: '   ||
                              p_dff_vg(v_idx).desc_appl_name;
              EXIT;
           WHEN others THEN
              v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                              'Error buscando el Id de la Aplicacion: '   ||
                              p_dff_vg(v_idx).desc_appl_name              ||
                              '. '                                        ||
                              SQLERRM;
              EXIT;
         END;
         -- --------------------------------------------------------------------
         -- Obtengo el Id Maximo del Concurrente de Flexfield View Generator
         -- del Flexfield Descriptivo.
         -- --------------------------------------------------------------------
         BEGIN
           SELECT MAX(fcr.request_id)
             INTO v_request_id
             FROM fnd_concurrent_requests      fcr
                 ,fnd_concurrent_programs      fcp
            WHERE fcp.application_id           = v_conc_application_id
              AND fcp.concurrent_program_name  = v_conc_program_name
              AND fcp.application_id           = fcr.program_application_id
              AND fcp.concurrent_program_id    = fcr.concurrent_program_id
              AND fcr.argument1                = v_conc_argument1
              AND fcr.argument2                = TO_CHAR(v_desc_appl_id)
              AND fcr.argument3                = v_desc_flex_name;
         EXCEPTION
           WHEN others THEN
             v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. '     ||
                             'Error buscando el Id Maximo del Concurrente: ' ||
                             v_conc_program_name_complete                    ||
                             ' para el Flexfield Descriptivo: '              ||
                             v_desc_flex_name                                ||
                             '. '                                            ||
                             SQLERRM;
             EXIT;
         END;
         IF v_request_id IS NOT NULL THEN
            v_mesg_error := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. '     ||
                            'No se encontro el Id Maximo del Concurrente: ' ||
                            v_conc_program_name_complete                    ||
                            ' para el Flexfield Descriptivo: '              ||
                            v_desc_flex_name;
             EXIT;
         END IF;
         -- --------------------------------------------------------------------
         -- Espero a que finalice el Concurrente Flexfield View Generator.
         -- --------------------------------------------------------------------
         WHILE NVL(v_conc_dev_phase, 'X') != 'COMPLETE' LOOP
             IF fnd_concurrent.wait_for_request
                              (request_id => v_request_id
                              ,interval   => 60
                              ,max_wait   => 0
                              ,phase      => v_conc_phase
                              ,status     => v_conc_status
                              ,dev_phase  => v_conc_dev_phase
                              ,dev_status => v_conc_dev_status
                              ,message    => v_conc_message
                              ) THEN
                NULL;
             END IF;
         END LOOP;
         IF NVL(v_conc_dev_status,'E') != 'NORMAL'   OR
            NVL(v_conc_dev_phase, 'E') != 'COMPLETE' THEN
            v_mesg_error:= 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                           'El Concurrente '                           ||
                           v_conc_program_name_complete                ||
                           ' del Flexfield Descriptivo '               ||
                           v_desc_flex_name                            ||
                           ' Id '                                      ||
                           TO_CHAR(v_request_id)                       ||
                           ' finalizo con el Estado: '                 ||
                           v_conc_status                               ||
                           ' ('                                        ||
                           v_conc_dev_status                           ||
                           '). '                                       ||
                           v_conc_message;
            EXIT;
         END IF;
     END LOOP;
     IF v_mesg_error IS NOT NULL THEN
        p_message := v_mesg_error;
        RETURN (FALSE);
     END IF;
  END IF;
  RETURN (TRUE);
EXCEPTION
  WHEN others THEN
    p_message := 'XX_UTIL_PK.VALIDATE_DFF_VIEW_GENERATION. ' ||
                 'Error General. '                           ||
                 SQLERRM;
    RETURN (FALSE);
END validate_dff_view_generation;
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
                             ) RETURN BOOLEAN
IS
  v_pos_from   NUMBER(15);
  v_pos_to     NUMBER(15);
  v_seg_value  VARCHAR2(30);
  v_seg_length NUMBER(15);
BEGIN
  v_pos_from := 1;
  -- ---------------------------------------------------------------------------
  -- Recorro los segmentos de la estructura contable.
  -- ---------------------------------------------------------------------------
  FOR cseg IN 1..p_seg_count LOOP
      v_seg_value  := NULL;
      v_pos_to     := NULL;
      v_seg_length := NULL;
      -- -----------------------------------------------------------------------
      -- Obtengo la posicion proxima del delimitador.
      -- -----------------------------------------------------------------------
      v_pos_to := INSTR(p_concat_segments
                       ,p_delimiter
                       ,v_pos_from
                       );
      -- -----------------------------------------------------------------------
      -- Obtengo el largo del segmento.
      -- -----------------------------------------------------------------------
      v_seg_length := v_pos_to - v_pos_from;
      -- -----------------------------------------------------------------------
      -- Obtengo el valor del segmento.
      -- -----------------------------------------------------------------------
      IF NVL(v_pos_to,0) = 0 THEN
         v_seg_value := SUBSTR(p_concat_segments
                              ,v_pos_from
                              );
      ELSE
         v_seg_value := SUBSTR(p_concat_segments
                              ,v_pos_from
                              ,v_seg_length
                              );
      END IF;
      v_pos_from := v_pos_to + 1;
      -- -----------------------------------------------------------------------
      -- Verifico si es el numero de segmento que buscaba.
      -- -----------------------------------------------------------------------
      IF cseg = p_seg_num THEN
         EXIT;
      END IF;
  END LOOP;
  p_seg_value := LTRIM(RTRIM(v_seg_value));
  RETURN (TRUE);
EXCEPTION
  WHEN others THEN
    p_mesg_error := 'XX_UTIL_PK.FF_GET_SEGMENT_VALUE. '             ||
                    'Error obteniendo el Valor del Segmento Nro.: ' ||
                    TO_CHAR(p_seg_num)                              ||
                    ' de la Combinacion: '                          ||
                    p_concat_segments                               ||
                    '. '                                            ||
                    SQLERRM;
    RETURN (FALSE);
END ff_get_segment_value;
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
                               ) RETURN BOOLEAN
IS
   v_flex_value_set_id NUMBER(15);
   v_rec_vset          fnd_vset.valueset_r;
   v_rec_vset_fmt      fnd_vset.valueset_dr;
   v_rec_vset_value    fnd_vset.value_dr;
   v_value_column_type VARCHAR2(1);
   v_where_clause      VARCHAR2(32767);
   v_found             BOOLEAN;
   v_row               NUMBER;
BEGIN
  IF p_flex_value_set_id IS NULL THEN
     BEGIN
       SELECT ffvs.flex_value_set_id
         INTO v_flex_value_set_id
         FROM fnd_flex_value_sets ffvs
        WHERE ffvs.flex_value_set_name = p_flex_value_set_name;
     EXCEPTION
       WHEN no_data_found THEN
         p_mesg_error := 'XX_UTIL_PK.VSET_GET_ID_FROM_TABLE. '  ||
                         'No se encontro el Juego de Valores: ' ||
                         p_flex_value_set_name;
         RETURN (FALSE);
       WHEN others THEN
         p_mesg_error := 'XX_UTIL_PK.VSET_GET_ID_FROM_TABLE. '  ||
                         'Error buscando el Juego de Valores: ' ||
                         p_flex_value_set_name                  ||
                         '. '                                   ||
                         SQLERRM;
         RETURN (FALSE);
     END;
  ELSE
     v_flex_value_set_id := p_flex_value_set_id;
  END IF;
  fnd_vset.get_valueset(valueset_id => v_flex_value_set_id
                       ,valueset    => v_rec_vset
                       ,format      => v_rec_vset_fmt
                       );
  IF v_rec_vset.validation_type = 'F' AND
     v_rec_vset_fmt.has_id            THEN
     SELECT ffvt.value_column_type
       INTO v_value_column_type
       FROM fnd_flex_validation_tables ffvt
      WHERE ffvt.flex_value_set_id = v_flex_value_set_id;
     IF v_rec_vset.table_info.where_clause IS NOT NULL THEN
        v_where_clause := ' AND ';
     ELSE
        v_where_clause := 'WHERE ';
     END IF;
     v_where_clause := v_where_clause                          ||
                       v_rec_vset.table_info.value_column_name ||
                       ' = ';
     IF v_value_column_type = 'N' THEN
        v_where_clause := v_where_clause ||
                          p_value;
     ELSIF v_value_column_type IN ('C','D','V') THEN
        v_where_clause := v_where_clause ||
                          ''''           ||
                          p_value        ||
                          '''';
     END IF;
     v_rec_vset.table_info.where_clause := v_rec_vset.table_info.where_clause ||
                                           v_where_clause;
     fnd_vset.get_value_init(valueset     => v_rec_vset
                            ,enabled_only => TRUE
                            );
     fnd_vset.get_value(valueset => v_rec_vset
                       ,rowcount => v_row
                       ,FOUND    => v_found
                       ,value    => v_rec_vset_value
                       );
     p_id := v_rec_vset_value.id;
  ELSE
     p_id := p_value;
  END IF;
  fnd_vset.get_value_end(valueset => v_rec_vset
                        );
  RETURN (TRUE);
EXCEPTION
  WHEN others THEN
    p_mesg_error := 'XX_UTIL_PK.VSET_GET_ID_FROM_TABLE. '  ||
                    'Error obteniendo el id del valor: '   ||
                    p_value                                ||
                    ' del Juego de Valores: '              ||
                    p_flex_value_set_name                  ||
                    ' Id: '                                ||
                    TO_CHAR(p_flex_value_set_id)           ||
                    '. '                                   ||
                    SQLERRM;
    RETURN (FALSE);
END vset_get_id_from_table;
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
                              ) RETURN BOOLEAN
IS
BEGIN

  debug('XX_UTIL_PK.CONC_GET_PROGRAM_NAME');

  debug('XX_UTIL_PK.CONC_GET_PROGRAM_NAME. '            ||
        'Buscando el nombre del Programa Concurrente: ' ||
        p_program_name                                  ||
        ' para la Aplicacion: '                         ||
        p_appl_short_name);

  BEGIN
    SELECT fcp.user_concurrent_program_name
      INTO p_user_program_name
      FROM fnd_application            fa
          ,fnd_concurrent_programs_vl fcp
     WHERE fcp.concurrent_program_name = p_program_name
       AND fcp.application_id          = fa.application_id
       AND fa.application_short_name   = p_appl_short_name;
  EXCEPTION
    WHEN no_data_found THEN
      p_mesg_error := 'XX_UTIL_PK.CONC_GET_PROGRAM_NAME. '       ||
                      'No se encontro el Programa Concurrente: ' ||
                      p_program_name                             ||
                      ' para la Aplicacion: '                    ||
                      p_appl_short_name;
      RETURN (FALSE);
    WHEN others THEN
      p_mesg_error := 'XX_UTIL_PK.CONC_GET_PROGRAM_NAME. '       ||
                      'Error buscando el Programa Concurrente: ' ||
                      p_program_name                             ||
                      ' para la Aplicacion: '                    ||
                      p_appl_short_name                          ||
                      '. '                                       ||
                      SQLERRM;
      RETURN (FALSE);
  END;

  debug('XX_UTIL_PK.CONC_GET_PROGRAM_NAME. '   ||
        'El nombre del Programa Concurrente: ' ||
        p_program_name                         ||
        ' es '                                 ||
        p_user_program_name);

  p_program_name_complete := p_user_program_name       ||
                             ' ('                      ||
                             p_program_name            ||
                             ')';
  RETURN (TRUE);
END conc_get_program_name;
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
                            ) RETURN BOOLEAN
IS
  v_user_program_name     VARCHAR2(240);
  v_program_name_complete VARCHAR2(240);
  v_request_id            NUMBER(15);
  v_conc_phase            VARCHAR2(30);
  v_conc_status           VARCHAR2(30);
  v_conc_dev_phase        VARCHAR2(30);
  v_conc_dev_status       VARCHAR2(30);
  v_conc_message          VARCHAR2(2000);
  v_stmt                  VARCHAR2(2000);
BEGIN

  debug('XX_UTIL_PK.CONC_SUBMIT_REQUEST');

  IF NOT conc_get_program_name(p_appl_short_name       => p_appl_short_name
                              ,p_program_name          => p_program_name
                              ,p_user_program_name     => v_user_program_name
                              ,p_program_name_complete =>
                               v_program_name_complete
                              ,p_mesg_error            => p_mesg_error
                              ) THEN
     RETURN (FALSE);
  END IF;
  v_request_id := fnd_request.submit_request
     (p_appl_short_name
     ,p_program_name
     ,p_description
     ,p_start_time
     ,p_sub_request
     ,p_argument1  , p_argument2  , p_argument3  , p_argument4  , p_argument5
     ,p_argument6  , p_argument7  , p_argument8  , p_argument9  , p_argument10
     ,p_argument11 , p_argument12 , p_argument13 , p_argument14 , p_argument15
     ,p_argument16 , p_argument17 , p_argument18 , p_argument19 , p_argument20
     ,p_argument21 , p_argument22 , p_argument23 , p_argument24 , p_argument25
     ,p_argument26 , p_argument27 , p_argument28 , p_argument29 , p_argument30
     ,p_argument31 , p_argument32 , p_argument33 , p_argument34 , p_argument35
     ,p_argument36 , p_argument37 , p_argument38 , p_argument39 , p_argument40
     ,p_argument41 , p_argument42 , p_argument43 , p_argument44 , p_argument45
     ,p_argument46 , p_argument47 , p_argument48 , p_argument49 , p_argument50
     ,p_argument51 , p_argument52 , p_argument53 , p_argument54 , p_argument55
     ,p_argument56 , p_argument57 , p_argument58 , p_argument59 , p_argument60
     ,p_argument61 , p_argument62 , p_argument63 , p_argument64 , p_argument65
     ,p_argument66 , p_argument67 , p_argument68 , p_argument69 , p_argument70
     ,p_argument71 , p_argument72 , p_argument73 , p_argument74 , p_argument75
     ,p_argument76 , p_argument77 , p_argument78 , p_argument79 , p_argument80
     ,p_argument81 , p_argument82 , p_argument83 , p_argument84 , p_argument85
     ,p_argument86 , p_argument87 , p_argument88 , p_argument89 , p_argument90
     ,p_argument91 , p_argument92 , p_argument93 , p_argument94 , p_argument95
     ,p_argument96 , p_argument97 , p_argument98 , p_argument99 , p_argument100
     );
  IF NVL(v_request_id,0) = 0 THEN
     v_conc_message := fnd_message.get;
     p_mesg_error   := 'XX_UTIL_PK.CONC_SUBMIT_REQUEST. '              ||
                       'No se pudo ejecutar el Programa Concurrente: ' ||
                       v_program_name_complete                         ||
                       '. '                                            ||
                       v_conc_message;
     RETURN (FALSE);
  ELSE
     COMMIT;
     p_request_id := v_request_id;
     p_mesg_error := 'El Programa Concurrente: '  ||
                     v_program_name_complete      ||
                     ' se ejecuto el con el Id: ' ||
                     TO_CHAR(v_request_id);
  END IF;
  IF p_parent_request_id IS NOT NULL THEN
     BEGIN

       v_stmt :=
              ' UPDATE fnd_concurrent_requests '
              || ' SET parent_request_id   = :p_parent_request_id '
                 || ' ,priority_request_id = :p_parent_request_id '
            || ' WHERE request_id          = :p_request_id ';

       EXECUTE IMMEDIATE v_stmt USING  p_parent_request_id,
                                       p_parent_request_id,
                                       v_request_id;

     EXCEPTION
       WHEN others THEN
         p_mesg_error := 'XX_UTIL_PK.CONC_SUBMIT_REQUEST. '  ||
                         p_mesg_error                        ||
                         '. Error actualizando el Id del '   ||
                         'Concurrente Padre al Concurrente ' ||
                         v_program_name_complete             ||
                         ' Id: '                             ||
                         TO_CHAR(v_request_id)               ||
                         '. '                                ||
                         SQLERRM;
         RETURN (FALSE);
     END;
     COMMIT;
  END IF;
  IF p_wait = 'Y' THEN
     v_conc_phase      := NULL;
     v_conc_status     := NULL;
     v_conc_dev_phase  := NULL;
     v_conc_dev_status := NULL;
     v_conc_message    := NULL;
     WHILE NVL(v_conc_dev_phase, 'X') != 'COMPLETE' LOOP
         IF fnd_concurrent.wait_for_request
                          (request_id => v_request_id
                          ,interval   => p_wait_interval
                          ,max_wait   => p_wait_max
                          ,phase      => v_conc_phase
                          ,status     => v_conc_status
                          ,dev_phase  => v_conc_dev_phase
                          ,dev_status => v_conc_dev_status
                          ,message    => v_conc_message
                          ) THEN
            NULL;
         END IF;
     END LOOP;
     p_conc_status     := v_conc_status;
     p_conc_dev_status := v_conc_dev_status;
     p_mesg_error      := p_mesg_error                  ||
                          ' y finalizo con el Estado: ' ||
                          v_conc_status                 ||
                          ' ('                          ||
                          v_conc_dev_status             ||
                          ')';
  END IF;

  debug('XX_UTIL_PK.CONC_SUBMIT_REQUEST. ' || p_mesg_error);

  IF NVL(p_output,'N') != 'N' THEN
     display_message_split(p_length_line => p_length_line
                          ,p_output      => p_output
                          ,p_message     => p_mesg_error
                          );
  END IF;
  RETURN (TRUE);
END conc_submit_request;
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
                         ) RETURN BOOLEAN
IS
BEGIN

  debug('XX_UTIL_PK.CONC_FATAL_ERROR');

  debug(p_mesg_error);

  IF NOT fnd_concurrent.set_completion_status(status  => 'ERROR'
                                             ,message => p_mesg_error
                                             ) THEN
     p_mesg_error := 'XX_UTIL_PK.CONC_FATAL_ERROR. '            ||
                     'Error intentando completar la Solicitud ' ||
                     'con Estado Error (ERROR). '               ||
                     p_mesg_error;

     debug(p_mesg_error);

     RETURN (FALSE);
  END IF;
  RETURN (TRUE);
END conc_fatal_error;
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
                              ) RETURN BOOLEAN
IS
  v_oracle_process_id VARCHAR2(30);
  v_oracle_session_id NUMBER(15);
  v_os_process_id     VARCHAR2(240);
  v_message           VARCHAR2(32767);
  v_chr_newline       VARCHAR2(1) := CHR(10);

  v_stmt              VARCHAR2(32767) :=
       ' SELECT s.username '
          || ' ,s.osuser '
          || ' ,s.status '
          || ' ,s.lockwait '
          || ' ,s.program '
          || ' ,s.machine '
          || ' ,s.logon_time '
          || ' ,p.program               pprogram '
          || ' ,si.physical_reads '
          || ' ,si.block_gets '
          || ' ,si.consistent_gets '
          || ' ,si.block_changes '
          || ' ,si.consistent_changes '
          || ' ,s.process '
          || ' ,p.spid '
          || ' ,p.pid '
          || ' ,s.serial# '
          || ' ,si.sid '
          || ' ,s.sql_address '
          || ' ,s.sql_hash_value '
          || ' ,sw.event '
          || ' ,sw.seconds_in_wait '
      || ' FROM v$session_wait sw '
          || ' ,v$process      p '
          || ' ,v$sess_io      si '
          || ' ,v$session      s '
     || ' WHERE s.process  = :v_os_process_id '
       || ' AND s.sid      = si.sid(+) '
       || ' AND s.paddr    = p.addr(+) '
       || ' AND s.sid      = sw.sid(+) ';


   TYPE CT_SESSION   IS REF CURSOR;
   TYPE RT_SESSION   IS RECORD (
            username           VARCHAR2(30)
           ,osuser             VARCHAR2(30)
           ,status             VARCHAR2(10)
           ,lockwait           VARCHAR2(8)
           ,program            VARCHAR2(48)
           ,machine            VARCHAR2(64)
           ,logon_time         DATE
           ,pprogram           VARCHAR2(48)
           ,physical_reads     NUMBER
           ,block_gets         NUMBER
           ,consistent_gets    NUMBER
           ,block_changes      NUMBER
           ,consistent_changes NUMBER
           ,process            VARCHAR2(12)
           ,spid               VARCHAR2(12)
           ,pid                NUMBER
           ,serial#            NUMBER
           ,sid                NUMBER
           ,sql_address        RAW(4)
           ,sql_hash_value     NUMBER
           ,event              VARCHAR2(64)
           ,seconds_in_wait    NUMBER
   );

   c_session    CT_SESSION;
   cs           RT_SESSION;

BEGIN
  BEGIN
    SELECT oracle_process_id
          ,oracle_session_id
          ,os_process_id
      INTO v_oracle_process_id
          ,v_oracle_session_id
          ,v_os_process_id
      FROM fnd_concurrent_requests
     WHERE request_id = p_request_id;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN others THEN
      p_mesg_error := 'XX_UTIL_PK.CONC_GET_SESSION_DATA. '                ||
                      'Error buscando datos del Concurrente en la '       ||
                      'tabla de Concurrentes (FND_CONCURRENT_REQUESTS). ' ||
                      SQLERRM;
      RETURN (FALSE);
  END;
  v_message := 'Session Data: '                                      ||
               v_chr_newline                                         ||
               '* Database process identifier (ORACLE_PROCESS_ID): ' ||
               v_oracle_process_id                                   ||
               v_chr_newline                                         ||
               '* Database session identifier (ORACLE_SESSION_ID): ' ||
               TO_CHAR(v_oracle_session_id)                          ||
               v_chr_newline;

  OPEN c_session FOR v_stmt USING v_os_process_id;

  LOOP
     FETCH c_session INTO cs ;
     EXIT WHEN c_session%NOTFOUND;

      p_address    := cs.sql_address;
      p_hash_value := cs.sql_hash_value;
      v_message := v_message                                     ||
                   '* Session Id (SID): '                        ||
                   TO_CHAR(cs.sid)                               ||
                   v_chr_newline                                 ||
                   '* User Name (USERNAME): '                    ||
                   cs.username                                   ||
                   v_chr_newline                                 ||
                   '* OS User (OSUSER): '                        ||
                   cs.osuser                                     ||
                   v_chr_newline                                 ||
                   '* Status (STATUS): '                         ||
                   cs.status                                     ||
                   v_chr_newline                                 ||
                   '* Lock Wait (LOCKWAIT): '                    ||
                   cs.lockwait                                   ||
                   v_chr_newline                                 ||
                   '* Program (PROGRAM): '                       ||
                   cs.program                                    ||
                   v_chr_newline                                 ||
                   '* Machine (MACHINE): '                       ||
                   cs.machine                                    ||
                   v_chr_newline                                 ||
                   '* Connect Time (LOGON_TIME): '               ||
                   TO_CHAR(cs.logon_time
                          ,'DD-MON-YYYY HH24:MI:SS'
                          )                                      ||
                   v_chr_newline                                 ||
                   '* P Program (PROGRAM): '                     ||
                   cs.pprogram                                   ||
                   v_chr_newline                                 ||
                   '* Physical Reads (PHYSICAL_READS): '         ||
                   TO_CHAR(cs.physical_reads)                    ||
                   v_chr_newline                                 ||
                   '* Block Gets (BLOCK_GETS): '                 ||
                   TO_CHAR(cs.block_gets)                        ||
                   v_chr_newline                                 ||
                   '* Consistent Gets (CONSISTENT_GETS): '       ||
                   TO_CHAR(cs.consistent_gets)                   ||
                   v_chr_newline                                 ||
                   '* Block Changes (BLOCK_CHANGES): '           ||
                   TO_CHAR(cs.block_changes)                     ||
                   v_chr_newline                                 ||
                   '* Consistent Changes (CONSISTENT_CHANGES): ' ||
                   TO_CHAR(cs.consistent_changes)                ||
                   v_chr_newline                                 ||
                   '* Session Wait (EVENT): '                    ||
                   cs.event                                      ||
                   v_chr_newline                                 ||
                   '* Seconds Wait (SECONDS_IN_WAIT): '          ||
                   TO_CHAR(cs.seconds_in_wait)                   ||
                   v_chr_newline;
      EXIT;
  END LOOP;
  p_message := v_message;
  RETURN (TRUE);
EXCEPTION
  WHEN others THEN
    p_mesg_error := 'XX_UTIL_PK.CONC_GET_SESSION_DATA. ' ||
                    'Error general. '                    ||
                    SQLERRM;
    RETURN (FALSE);
END conc_get_session_data;
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
                             ) RETURN BOOLEAN
IS
  v_message     VARCHAR2(32767);
  v_chr_newline VARCHAR2(1) := CHR(10);
  c_stmt        VARCHAR2(32767):=
      ' SELECT sql_text '
    || '  FROM v$sqltext '
    || ' WHERE address    = :p_address '
     || '  AND hash_value = :p_hash_value '
    || ' ORDER BY piece ';

   TYPE CT_SQLTEXT IS REF CURSOR;
   TYPE RT_SQLTEXT IS RECORD
   (
       sql_text    v$sqltext.sql_text%TYPE -- VARCHAR2(32767)
   );

   c_sqltext      CT_SQLTEXT;
   cs             RT_SQLTEXT;

BEGIN
  v_message := 'Statement: '  ||
               v_chr_newline;

  OPEN c_sqltext FOR c_stmt
                 USING p_address
                     , p_hash_value;
  LOOP
     FETCH c_sqltext INTO cs;
     EXIT WHEN c_sqltext%NOTFOUND;

      v_message := v_message              ||
                   LTRIM(RTRIM(cs.sql_text)) ||
                   v_chr_newline;
  END LOOP;

  v_message := SUBSTR(LTRIM(RTRIM(v_message))
                     ,1
                     ,LENGTH(LTRIM(RTRIM(v_message)))-2
                     ) ||
               v_chr_newline;
  p_message := v_message;
  RETURN (TRUE);
EXCEPTION
  WHEN others THEN
    p_mesg_error := 'XX_UTIL_PK.CONC_GET_SESSION_SQL. ' ||
                    'Error general. '                   ||
                    SQLERRM;
    RETURN (FALSE);
END conc_get_session_sql;
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
                                  ) RETURN BOOLEAN
IS
  v_message     VARCHAR2(32767);
  v_chr_newline VARCHAR2(1) := CHR(10);

  v_stmt        VARCHAR2(32767):=
      ' SELECT sharable_mem '
          || ' ,persistent_mem '
          || ' ,runtime_mem '
          || ' ,sorts '
          || ' ,executions '
          || ' ,parse_calls '
          || ' ,buffer_gets '
          || ' ,disk_reads '
          || ' ,users_opening '
          || ' ,loads '
          || ' ,TO_CHAR(TO_DATE(first_load_time '
                          || ' ,''YYYY-MM-DD/HH24:MI:SS'' '
                          || ' ) '
                  || ' ,''MM/DD  HH24:MI:SS'' '
                  || ' )       first_load_time '
          || ' ,rows_processed    '
          || ' ,command_type    '
          || ' ,optimizer_mode '
      || ' FROM v$sql '
     || ' WHERE address    = :p_address '
       || ' AND hash_value = :p_hash_value ' ;

   TYPE CT_SQL IS REF CURSOR;
   TYPE RT_SQL IS RECORD
   (
           sharable_mem       NUMBER
          ,persistent_mem     NUMBER
          ,runtime_mem        NUMBER
          ,sorts              NUMBER
          ,executions         NUMBER
          ,parse_calls        NUMBER
          ,buffer_gets        NUMBER
          ,disk_reads         NUMBER
          ,users_opening      NUMBER
          ,loads              NUMBER
          ,first_load_time    VARCHAR2(20)
          ,rows_processed     NUMBER
          ,command_type       NUMBER
          ,optimizer_mode     VARCHAR2(10)

   );

   c_sql      CT_SQL;
   cs         RT_SQL;

BEGIN
  OPEN c_sql FOR v_stmt
             USING p_address
                 , p_hash_value;


  LOOP
     FETCH c_sql INTO cs;
     EXIT WHEN c_sql%NOTFOUND;

      v_message := 'STATEMENT Data: '                       ||
                   v_chr_newline                            ||
                   '* Sharable Memory (SHARABLE_MEM): '     ||
                   TO_CHAR(cs.sharable_mem)                 ||
                   v_chr_newline                            ||
                   '* Persistent Memory (PERSISTENT_MEM): ' ||
                   TO_CHAR(cs.persistent_mem)               ||
                   v_chr_newline                            ||
                   '* Runtime Memory (RUNTIME_MEM): '       ||
                   TO_CHAR(cs.runtime_mem)                  ||
                   v_chr_newline                            ||
                   '* Sorts (SORTS): '                      ||
                   TO_CHAR(cs.sorts)                        ||
                   v_chr_newline                            ||
                   '* Executions (EXECUTIONS): '            ||
                   TO_CHAR(cs.executions)                   ||
                   v_chr_newline                            ||
                   '* Parse Calls (PARSE_CALLS): '          ||
                   TO_CHAR(cs.parse_calls)                  ||
                   v_chr_newline                            ||
                   '* Buffer Gets (BUFFER_GETS): '          ||
                   TO_CHAR(cs.buffer_gets)                  ||
                   v_chr_newline                            ||
                   '* Sharable Disk Reads (DISK_READS): '   ||
                   TO_CHAR(cs.disk_reads)                   ||
                   v_chr_newline                            ||
                   '* Users Opening (USERS_OPENING): '      ||
                   TO_CHAR(cs.users_opening)                ||
                   v_chr_newline                            ||
                   '* Loads (LOADS): '                      ||
                   TO_CHAR(cs.loads)                        ||
                   v_chr_newline                            ||
                   '* First Load TIME (FIRST_LOAD_TIME): '  ||
                   cs.first_load_time                       ||
                   v_chr_newline                            ||
                   '* ROWS Processed (ROWS_PROCESSED): '    ||
                   TO_CHAR(cs.rows_processed)               ||
                   v_chr_newline                            ||
                   '* Command TYPE (COMMAND_TYPE): '        ||
                   cs.command_type                          ||
                   v_chr_newline                            ||
                   '* Optimizer MODE (OPTIMIZER_MODE): '    ||
                   cs.optimizer_mode                        ||
                   v_chr_newline;
      EXIT;
  END LOOP;
  p_message := v_message;
  RETURN (TRUE);
EXCEPTION
  WHEN others THEN
    p_mesg_error := 'XX_UTIL_PK.CONC_GET_SESSION_SQL_DATA. ' ||
                    'Error general. '                        ||
                    SQLERRM;
    RETURN (FALSE);
END conc_get_session_sql_data;
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
                     ) RETURN BOOLEAN
IS
  v_statment VARCHAR2(250);
  v_ret      INTEGER;
  v_cur      INTEGER;
BEGIN
  IF NVL(p_del_type,'D') = 'D' THEN
     v_statment := 'DELETE FROM ' ||
                   p_table_name;
  ELSE
     v_statment := 'TRUNCATE TABLE ' ||
                   p_owner_table     ||
                   '.'               ||
                   p_table_name;
  END IF;
  BEGIN
    v_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cur
                  ,v_statment
                  ,dbms_sql.v7
                  );
    v_ret := DBMS_SQL.EXECUTE(v_cur);
    DBMS_SQL.CLOSE_CURSOR(v_cur);
  EXCEPTION
    WHEN others THEN
      p_mesg_error := 'XX_UTIL_PK.DELETE_TABLE. '        ||
                      'Error ejecutando la sentencia: "' ||
                      v_statment                         ||
                      '". '                              ||
                      SQLERRM;
      RETURN (FALSE);
  END;
  p_rowcount := v_ret;
  RETURN (TRUE);
END delete_table;
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
               ) RETURN NUMBER
IS
  v_string   VARCHAR2(2000);
  v_decimal  VARCHAR2(1);
  v_negative VARCHAR2(1);
  v_number   NUMBER;
BEGIN
  v_string   := '';
  v_decimal  := 'N';
  v_negative := 'N';
  IF p_string IS NULL THEN
     RETURN TO_NUMBER(v_string);
  END IF;
  FOR cnt IN 1..LENGTH(p_string) LOOP
      IF SUBSTR(p_string
               ,cnt
               ,1
               ) = '.' THEN
         IF v_decimal = 'N' THEN
            v_string := v_string        ||
                        SUBSTR(p_string
                              ,cnt
                              ,1
                              );
            v_decimal := 'Y';
         END IF;
      ELSIF SUBSTR(p_string
                  ,cnt
                  ,1
                  ) = '-' THEN
         IF v_negative = 'N' THEN
            v_string := v_string        ||
                        SUBSTR(p_string
                              ,cnt
                              ,1
                              );
            v_negative := 'Y';
         END IF;
      ELSE
         BEGIN
           v_number := TO_NUMBER(SUBSTR(p_string
                                       ,cnt
                                       ,1
                                       )
                                );
           v_string := v_string        ||
                       SUBSTR(p_string
                             ,cnt
                             ,1
                             );
         EXCEPTION
           WHEN value_error THEN
             NULL;
         END;
      END IF;
  END LOOP;
  IF LENGTH(v_string) = 1          AND
     v_string         IN ('.','-') THEN
     v_string := NULL;
  END IF;
  RETURN TO_NUMBER(v_string);
END to_num;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    get_org_id                                                            |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el Id de la Otganizacion a partir del Nombre.     |
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
                   ) RETURN BOOLEAN
IS
  v_org_id NUMBER(15);
BEGIN
  BEGIN
    SELECT hou.organization_id
      INTO v_org_id
      FROM hr_organization_units hou
     WHERE hou.name = p_org_name;
  EXCEPTION
    WHEN no_data_found THEN
      p_errmsg := 'XX_UTIL_PK.GET_ORG_ID. '                   ||
                  'No se encontro el Id de la Organizacion: ' ||
                  p_org_name;
      RETURN (FALSE);
    WHEN others THEN
      p_errmsg := 'XX_UTIL_PK.GET_ORG_ID. '                   ||
                  'Error buscando el Id de la Organizacion: ' ||
                  p_org_name                                  ||
                  '. '                                        ||
                  SQLERRM;
      RETURN (FALSE);
  END;
  p_org_id  := v_org_id;
  RETURN (TRUE);
END get_org_id;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    get_org_name                                                          |
|                                                                          |
| Description                                                              |
|    Funcion que obtiene el Nombre de la Organizacion a partir del Id.     |
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
                     ) RETURN BOOLEAN
IS
  v_org_name VARCHAR2(240);
BEGIN
  BEGIN
    SELECT hou.name
      INTO v_org_name
      FROM hr_organization_units hou
     WHERE hou.organization_id = p_org_id;
  EXCEPTION
    WHEN no_data_found THEN
      p_errmsg := 'XX_UTIL_PK.GET_ORG_NAME. '           ||
                  'No se encontro la Organizacion Id: ' ||
                  TO_CHAR(p_org_id);
      RETURN (FALSE);
    WHEN others THEN
      p_errmsg := 'XX_UTIL_PK.GET_ORG_NAME. '           ||
                  'Error buscando la Organizacion Id: ' ||
                  TO_CHAR(p_org_id)                     ||
                  '. '                                  ||
                  SQLERRM;
      RETURN (FALSE);
  END;
  p_org_name := v_org_name;
  RETURN (TRUE);
END get_org_name;
/*=========================================================================+
|                                                                          |
| Public Function                                                          |
|    init_responsibility                                                   |
|                                                                          |
| Description                                                              |
|    Initialize the user and responsibility for a give user/resp in Oracle |
|    Financials. Derive all the profiles options associated with this.     |
|    The function return TRUE: If the initialization was succesfull and    |
|    FALSE: it it was wrong.                                               |
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
                            ) RETURN BOOLEAN
IS
  v_user_id      NUMBER(15);
  v_resp_id      NUMBER(15);
  v_appl_resp_id NUMBER(15);
BEGIN
  BEGIN
    SELECT fu.user_id
      INTO v_user_id
      FROM fnd_user fu
     WHERE fu.user_name = p_user_name;
  EXCEPTION
    WHEN no_data_found THEN
      p_errmsg := 'XX_UTIL_PK.INIT_RESPONSIBILITY. ' ||
                  'No se encontro el Usuario: '      ||
                  p_user_name;
      RETURN (FALSE);
    WHEN others THEN
      p_errmsg := 'XX_UTIL_PK.INIT_RESPONSIBILITY. ' ||
                  'Error buscando el Usuario: '      ||
                  p_user_name                        ||
                  '. '                               ||
                  SQLERRM;
      RETURN (FALSE);
  END;
  BEGIN
    SELECT fr.application_id
          ,fr.responsibility_id
      INTO v_appl_resp_id
          ,v_resp_id
      FROM fnd_responsibility_tl fr
     WHERE ROWNUM              < 2
       AND fr.responsibility_name = p_responsibility_name;
  EXCEPTION
    WHEN no_data_found THEN
      p_errmsg := 'XX_UTIL_PK.INIT_RESPONSIBILITY. '    ||
                  'No se encontro la Responsabilidad: ' ||
                  p_responsibility_name;
      RETURN (FALSE);
    WHEN others THEN
      p_errmsg := 'XX_UTIL_PK.INIT_RESPONSIBILITY. '    ||
                  'Error buscando la Responsabilidad: ' ||
                  p_responsibility_name                 ||
                  '. '                                  ||
                  SQLERRM;
      RETURN (FALSE);
  END;
  BEGIN
    fnd_global.apps_initialize(v_user_id
                              ,v_resp_id
                              ,v_appl_resp_id
                              );
  EXCEPTION
    WHEN others THEN
      p_errmsg := 'XX_UTIL_PK.INIT_RESPONSIBILITY. '             ||
                  'Error conectandose a la aplicacion a travez ' ||
                  'de la Api FND_GLOBAL.APPS_INITIALIZE. '       ||
                  SQLERRM;
      RETURN (FALSE);
  END;
  RETURN (TRUE);
END init_responsibility;

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
                           ) RETURN BOOLEAN
IS
BEGIN
  BEGIN
    IF p_in_param1 IS NOT NULL AND
       p_in_param2 IS NOT NULL AND
       p_in_param3 IS NOT NULL AND
       p_in_param4 IS NOT NULL AND
       p_in_param5 IS NOT NULL THEN

     EXECUTE IMMEDIATE p_sql_statement USING p_in_param1
                                           , p_in_param2
                                           , p_in_param3
                                           , p_in_param4
                                           , p_in_param5 ;

   ELSIF p_in_param1 IS NOT NULL AND
       p_in_param2 IS NOT NULL AND
       p_in_param3 IS NOT NULL AND
       p_in_param4 IS NOT NULL AND
       p_in_param5 IS NULL THEN

     EXECUTE IMMEDIATE p_sql_statement USING p_in_param1
                                           , p_in_param2
                                           , p_in_param3
                                           , p_in_param4
                                           ;
   ELSIF p_in_param1 IS NOT NULL AND
       p_in_param2 IS NOT NULL AND
       p_in_param3 IS NOT NULL AND
       p_in_param4 IS NULL AND
       p_in_param5 IS NULL THEN

     EXECUTE IMMEDIATE p_sql_statement USING p_in_param1
                                           , p_in_param2
                                           , p_in_param3
                                           ;
   ELSIF p_in_param1 IS NOT NULL AND
       p_in_param2 IS NOT NULL AND
       p_in_param3 IS NULL AND
       p_in_param4 IS NULL AND
       p_in_param5 IS NULL THEN

     EXECUTE IMMEDIATE p_sql_statement USING p_in_param1
                                           , p_in_param2
                                           ;
   ELSIF p_in_param1 IS NOT NULL AND
       p_in_param2 IS NULL AND
       p_in_param3 IS NULL AND
       p_in_param4 IS NULL AND
       p_in_param5 IS NULL THEN

     EXECUTE IMMEDIATE p_sql_statement USING p_in_param1
                                           ;

   ELSE
     EXECUTE IMMEDIATE p_sql_statement
                                           ;
   END IF;

  EXCEPTION
    WHEN others THEN
      p_mesg_error := 'Error: ' ||
                      substr(SQLERRM, 1, 2000) || ' ejecutando la setencia: ' ||
                      p_sql_statement                   ||
                      '. '  ;
      RETURN (FALSE);
  END;
  RETURN (TRUE);
END exec_sql_statement;


/* CR1220 */
FUNCTION Set_Profile_Value ( p_profile_name    VARCHAR2
                           , p_new_value       VARCHAR2
                           , p_level           VARCHAR2
                           , p_level_value     VARCHAR2 DEFAULT NULL
                           , p_app_id          VARCHAR2 DEFAULT NULL
                           , p_level_value2    VARCHAR2 DEFAULT NULL
                           ) RETURN BOOLEAN IS
  --PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF FND_PROFILE.SAVE ( X_NAME               => p_profile_name
                      , X_VALUE              => p_new_value
                      , X_LEVEL_NAME         => p_level
                      , X_LEVEL_VALUE        => p_level_value
                      , X_LEVEL_VALUE_APP_ID => p_app_id
                      , X_LEVEL_VALUE2       => p_level_value2
                      ) THEN
    --COMMIT;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     RETURN FALSE;
END Set_Profile_Value;


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
  FUNCTION getElapsedTime (p_init DATE, p_end DATE) RETURN VARCHAR2 IS
    l_elapsed_time  NUMBER;
  BEGIN
    l_elapsed_time := p_end - p_init + 0.000001;

    RETURN LTRIM(TO_CHAR( TRUNC(l_elapsed_time * 24), '99900'))||':'
        || LTRIM(TO_CHAR(MOD(TRUNC(l_elapsed_time * 1440),60), '00'))||':'
        || LTRIM(TO_CHAR(MOD(TRUNC(l_elapsed_time * 86400),60) ,'00'));
  END;



  FUNCTION xml_escape_chars ( p_data VARCHAR2 ) RETURN VARCHAR2 IS
    l_data VARCHAR2(32767);
  BEGIN
    l_data := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p_data, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'),'"','&quot;'),'''', '&apos;'),CHR(13),' '),chr(10),' ');
    --l_data := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_data, 'Á', '&Aacute;'), 'É', '&Eacute;'), 'Í', '&Iacute;'), 'Ó', '&Oacute;'), 'Ú', '&Uacute;');
    --l_data := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_data, 'á', '&aacute;'), 'é', '&eacute;'), 'í', '&iacute;'), 'ó', '&oacute;'), 'ú', '&uacute;');

    RETURN l_data;
  END xml_escape_chars;


  FUNCTION xml_num_display ( p_data         NUMBER
                           , p_nls_num_char VARCHAR2 DEFAULT NULL
                           , p_thousands    VARCHAR2 DEFAULT 'Y'
                           ) RETURN VARCHAR2 IS
    l_nls_req    VARCHAR2(10);
    l_num_disp   VARCHAR2(50);
  BEGIN
    BEGIN
      SELECT nls_numeric_characters
      INTO l_nls_req
      FROM fnd_concurrent_requests
      WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF p_nls_num_char IS NOT NULL THEN
          l_nls_req := p_nls_num_char;
        ELSE
          RETURN p_data;
        END IF;
    END;

    IF p_nls_num_char IS NOT NULL THEN
      l_nls_req := p_nls_num_char;
    END IF;

    IF SUBSTR(l_nls_req,1,1) = ',' THEN
      l_num_disp := TO_CHAR(p_data, 'FM999G999G999G999D9999999999999999999999999999999999999999', 'NLS_NUMERIC_CHARACTERS=,.');
    ELSIF SUBSTR(l_nls_req,1,1) = '.' THEN
      l_num_disp := TO_CHAR(p_data, 'FM999G999G999G999D9999999999999999999999999999999999999999', 'NLS_NUMERIC_CHARACTERS=.,');
    ELSE
      l_num_disp := p_data;
    END IF;

    IF p_thousands = 'N' THEN
      l_num_disp := REPLACE(l_num_disp, SUBSTR(l_nls_req,2,1), '');
    END IF;

    RETURN l_num_disp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN p_data;
    WHEN OTHERS THEN
      RETURN -1;
  END xml_num_display;


  -- CR2253 Modificado IRosas Ago 2020
  FUNCTION xml_accepted_chars ( p_data VARCHAR2 )
  RETURN VARCHAR2
  IS

    l_data VARCHAR2(32767) := NULL;
    l_caresp varchar2(100) := '[^0-9A-Za-zÁÉÍÓÚáéíóúÜüÑñøØµ'||chr(13)||chr(10)||'[:space:]&;.,:!"#$%/()=?¡¿*+-_|'']';--'[^ÁÉÍÓÚáéíóúÜüÑñøØµ'||chr(13)||chr(10)||'[:alpha:][:digit:][:blank:][:punct:]]'

  BEGIN

    l_data := TRANSLATE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p_data, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'),'"','&quot;'),'''', '&apos;'),'àèìòùÀÈÌÒÙÛ','áéíóúÁÉÍÓÚÜ');


    SELECT REGEXP_REPLACE(l_data,l_caresp,'#')
      INTO l_data
      FROM DUAL;

    RETURN l_data;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_data;

  END xml_accepted_chars;



  FUNCTION get_perfil_cliente ( p_cust_acct_id  NUMBER
                              , p_site_use_id   NUMBER
                              ) RETURN VARCHAR2 IS
    l_class_name  VARCHAR2(250);
  BEGIN
    BEGIN
      SELECT cpc.name class_name
      INTO l_class_name
      FROM hz_customer_profiles    cp
         , hz_cust_profile_classes cpc
      WHERE 1=1
      AND cpc.profile_class_id = cp.profile_class_id
      AND cp.status            = 'A'
      AND cp.cust_account_id   = p_cust_acct_id
      AND cp.site_use_id       = p_site_use_id
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT cpc.name class_name
        INTO l_class_name
        FROM hz_customer_profiles    cp
           , hz_cust_profile_classes cpc
        WHERE 1=1
        AND cpc.profile_class_id = cp.profile_class_id
        AND cp.status            = 'A'
        AND cp.cust_account_id   = p_cust_acct_id
        AND cp.site_use_id       IS NULL
        ;
    END;

    RETURN l_class_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_perfil_cliente;


END XX_UTIL_PK;
/

exit
