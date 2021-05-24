spool xx_wms_int_out_trips_pkb.log

PROMPT Creando package body xx_wms_int_out_trips_pk

create or replace package body xx_wms_int_out_trips_pk as
/* $Header: xx_wms_int_out_trips_pkb.pls 1.1    29-NOV-2019   */
-- --------------------------------------------------------------------------
--  1.0  09-10-2019  MLaudati   Version Original
--  1.1  28-11-2019  MLaudati   Modificado Eliminación Control de Fechas.
--  1.2  12-12-2019  MLaudati	Validacion de delivery_detail_id
--	1.3	 30-12-2019  MLaudati	Cambio en las secuancia de parada del viaje.

    g_pkg_name			constant varchar2(30) := 'XX_WMS_INT_OUT_TRIPS_PK';
	g_do_debug			constant boolean := case when(nvl(fnd_profile.value('XX_DEBUG_ENABLED'), 'N') = 'Y')then true else false end;
	g_status_error		constant varchar2(1) := 'E';
    g_status_success	constant varchar2(1) := 'S';
	g_status_no_data	constant varchar2(1) := 'X';
	g_days				constant number := 7;
	g_date_from			constant date := (sysdate - g_days);

	function get_date_from return date
	is
		l_date date;
	begin
		select nvl(to_date(max(request_id), 'YYYYMMDDHH24MI'), g_date_from) into l_date from xx_wms_int_trips;
		return l_date;
	end get_date_from;

    --//-----------------------------------------------------------
	--// PROCEDURE DEBUG
	--//-----------------------------------------------------------
	--// @PARAM: I_MESSAGE	VARCHAR2
	--//-----------------------------------------------------------
	procedure debug(
		i_message	in varchar2
	)
	is			
		pragma autonomous_transaction;
	begin	
		if(g_do_debug)then
			insert into xx_debug_messages(
				session_id, debug_sequence, debug_level, created_by, creation_date, last_updated_by, last_update_date, module, message  
			) values (
				dbms_session.unique_session_id,
				xx_debug_messages_s.nextval, 1,	fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
				g_pkg_name, i_message
			);

			commit;	
		end if;	
	exception
		when others then
			rollback;
	end debug;	

    --//-----------------------------------------------------------
	--// PROCEDURE UPDATE_ERRORS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
    procedure update_errors(
        i_request_id    IN  NUMBER,
        x_error         OUT VARCHAR2
    )
    is
        l_proc constant  varchar2(50) := 'update_errors: ';
    begin

        x_error := NULL;

        update xx_wms_int_trips
        set status = 'NEW', error_mesg = null, request_id = i_request_id, last_update_date = SYSDATE
        --where status = 'ERROR'
		where status != 'OK'
        and request_id != i_request_id
        ;

		debug(l_proc || 'Update Xx_Wms_Int_Trips => ' || sql%rowcount);

        update xx_wms_int_trip_deliveries
        set status = 'NEW', error_mesg = null, request_id = i_request_id, last_update_date = SYSDATE
        --where status = 'ERROR'
		where status != 'OK'
        and request_id != i_request_id
        ;

		debug(l_proc || 'Update Xx_Wms_Int_Trip_Deliveries => ' || sql%rowcount);

    exception
        when others then
            x_error := l_proc || sqlerrm;
			debug(x_error);
    end update_errors;

    --//-----------------------------------------------------------
	--// PROCEDURE SET_ERRORS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: I_ERROR		VARCHAR2
	--//-----------------------------------------------------------
	procedure set_errors(
        i_request_id    IN  NUMBER,
        i_error         IN	VARCHAR2
    )
	is
		l_proc constant  varchar2(50) := 'set_errors: ';
	begin

		update xx_wms_int_trips
        set status = 'ERROR', last_update_date = SYSDATE,
		error_mesg = case when(error_mesg is null)then '' else error_mesg || '. ' end || i_error
        where 1=1
        and request_id = i_request_id
        ;

		debug(l_proc || 'Update Xx_Wms_Int_Trips => ' || sql%rowcount);

        update xx_wms_int_trip_deliveries
        set status = 'ERROR', last_update_date = SYSDATE,
		error_mesg = case when(error_mesg is null)then '' else error_mesg || '. ' end || i_error
        where 1=1
        and request_id = i_request_id
        ;

		debug(l_proc || 'Update Xx_Wms_Int_Trips => ' || sql%rowcount);

	exception
		when others then
			debug(l_proc || sqlerrm);
	end set_errors;

    --//-----------------------------------------------------------
	--// PROCEDURE INSERT_HEADERS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
    procedure insert_headers(
        i_request_id    IN  NUMBER,
		i_date_from		IN	DATE,
        x_error         OUT VARCHAR2    
    )
    is
        l_proc constant  varchar2(50) := 'insert_headers: ';
    begin

        x_error := NULL;

        insert into xx_wms_int_trips (
            organization_id,
            facility_code,
            trip_id,
            trip_name,
            req_ship_date,
            request_id,
            status,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
        select
            distinct
             wtd.organization_id
            ,mapp_qry.xx_org_origen_viajes facility_code
            ,wts.trip_id
            ,wts.trip_name
            ,greatest(max(wts.planned_arrival_date), sysdate) req_ship_date
            ,i_request_id
            ,'NEW'
            ,sysdate
            ,fnd_global.user_id
            ,sysdate
            ,fnd_global.user_id    
        from 
         wsh_trip_stops_v wts
        ,wsh_trip_deliverables_v wtd
        ,mtl_parameters mp_ebs
        ,(
            select
            flv.lookup_code, flv_dfv.xx_org_origen_viajes
            from
             fnd_lookup_values_vl flv
            ,fnd_lookup_values_dfv flv_dfv
            where 1=1
            and flv.rowid = flv_dfv.row_id
            and flv.lookup_type = 'XX_MAPEO_EBS_WMS'
        ) mapp_qry
        where 1=1
        and wts.trip_id = wtd.trip_id
        and wtd.organization_id = mp_ebs.organization_id
        and mapp_qry.lookup_code(+) = mp_ebs.organization_code
        and wts.status_code = 'OP'
--		and (
--			wtd.creation_date > i_date_from OR 
--			wtd.last_update_date > i_date_from
--		)
        and exists(
            select 1 from wsh_trip_stops_v where trip_id = wts.trip_id and status_code = 'AR'
        )
		and not exists(
			select 1
			from xx_wms_int_trips xwit
			where 1=1
			and xwit.organization_id = wtd.organization_id
            and xwit.trip_id = wtd.trip_id
		)
        group by
         wtd.organization_id
        ,mapp_qry.xx_org_origen_viajes
        ,wts.trip_id
        ,wts.trip_name
        ,i_request_id
        ,'NEW'
        ,sysdate
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.user_id
        ;

		debug(l_proc || 'Insert Into Xx_Wms_Int_Trips => ' || sql%rowcount);

    exception
        when others then
            x_error := l_proc || sqlerrm;
			debug(x_error);
    end insert_headers;

    --//-----------------------------------------------------------
	--// PROCEDURE UPDATE_HEADERS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
    procedure update_headers(
        i_request_id    IN  NUMBER,
        x_error         OUT VARCHAR2    
    )
    is
        l_proc constant  varchar2(50) := 'update_headers: ';    
    begin

        x_error := NULL;

        update xx_wms_int_trips xwit
        set (xwit.customer_number, xwit.customer_name, xwit.customer_address) = (
			select 
				(	
					select
						substr(listagg(account_number, ', ') within group(order by account_number), 1, 2000) account_number
					from (
						select distinct 
						 hca.account_number
						,hp.party_name
						,wtd.trip_id
						from 
						 wsh_trip_deliverables_v wtd
						,hz_cust_accounts hca
						,hz_parties hp
						where 1=1
						and wtd.customer_id = hca.cust_account_id
						and hca.party_id = hp.party_id
						and wtd.trip_id = xwit.trip_id
						and xwit.request_id = i_request_id
						and xwit.status = 'NEW'
					)					
				) cust_number
				,(	
					select
						substr(listagg(party_name, ', ') within group(order by party_name), 1, 2000) customer_name
					from (
						select distinct 
						 hca.account_number
						,hp.party_name
						,wtd.trip_id
						from 
						 wsh_trip_deliverables_v wtd
						,hz_cust_accounts hca
						,hz_parties hp
						where 1=1
						and wtd.customer_id = hca.cust_account_id
						and hca.party_id = hp.party_id
						and wtd.trip_id = xwit.trip_id
						and xwit.request_id = i_request_id
						and xwit.status = 'NEW'
					)					
				) cust_name
				,(	
					select
						substr(listagg(customer_address, ', ') within group(order by customer_address), 1, 2000) customer_address
					from (
						select distinct 
						 hps.party_site_number || ' : ' || 
						 hl.address1 || '-' || 
						 hl.address2 || '-' || 
						 hl.address3 || '-' || 
						 hl.address4 || '-' || 
						 hl.postal_code || '-' || 
						 hl.country customer_address
						,wtd.trip_id
						from 
						 wsh_trip_deliverables_v wtd
						,hz_cust_accounts hca
						,hz_parties hp
						,hz_locations hl
						,hz_party_sites hps
						,oe_order_headers_all ooh
						,hz_cust_acct_sites_all hcas
						where 1=1
						and wtd.customer_id = hca.cust_account_id
						and wtd.ship_to_location_id = hl.location_id
						and hca.party_id = hp.party_id
						and hl.location_id = hps.location_id
						and hp.party_id = hps.party_id
						and wtd.source_header_id = ooh.header_id
						and hps.party_site_id = hcas.party_site_id
						and hcas.org_id = ooh.org_id
						and wtd.trip_id = xwit.trip_id
						and xwit.request_id = i_request_id
						and xwit.status = 'NEW'
					)
				) cust_address
			from dual
        )
		where xwit.request_id = i_request_id
        ;

		debug(l_proc || 'Update Xx_Wms_Int_Trips => ' || sql%rowcount);

    exception
        when others then
            x_error := l_proc || sqlerrm;
			debug(x_error);
    end update_headers;

    --//-----------------------------------------------------------
	--// PROCEDURE VALIDATE_HEADERS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
    procedure validate_headers(
        i_request_id    IN  NUMBER,
        x_error         OUT VARCHAR2    
    )
    is
        l_proc constant  varchar2(50) := 'validate_headers: ';    
    begin

        x_error := NULL;

        update xx_wms_int_trips xwit
        set xwit.status = 'ERROR', xwit.last_update_date = SYSDATE,
		xwit.error_mesg = case when(xwit.error_mesg is null)then '' else xwit.error_mesg || '. ' end || 'No existe mapeo EBS -> WMS para la organización: ' || 
		(
			select organization_code
			from org_organization_definitions
			where organization_id = xwit.organization_id
		)
        where 1=1
        and xwit.facility_code is null
		and xwit.request_id = i_request_id
        ;

		debug(l_proc || 'Update Xx_Wms_Int_Trips => ' || sql%rowcount);

    exception
        when others then
            x_error := l_proc || sqlerrm;
			debug(x_error);
    end validate_headers;

	--//-----------------------------------------------------------
	--// PROCEDURE INSERT_LINES
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
	procedure insert_lines(
		i_request_id	IN	NUMBER,
		x_error			OUT	VARCHAR2
	)
	is
		l_proc constant  varchar2(50) := 'insert_lines: ';
	begin

		x_error := NULL;

		insert into xx_wms_int_trip_deliveries(
			trip_id,
			organization_id,
			inventory_item_id,
			item_number,
			delivery_id,
			delivery_name,
			delivery_detail_id,
			released_status,
			parada,
			request_id,
			status,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by
		)
		select
		 xwit.trip_id
		,xwit.organization_id 
		,wtd.inventory_item_id
		,msi.segment1
		,wtd.delivery_id
		,wnd.name delivery_name
		,wtd.delivery_detail_id
		,wtd.released_status
		,stop.seq
		,xwit.request_id
		,'NEW' status
		,sysdate
		,fnd_global.user_id
		,sysdate
		,fnd_global.user_id
		from
		 wsh_trip_deliverables_v wtd
		,wsh_new_deliveries wnd
		,mtl_system_items_b msi
		,xx_wms_int_trips xwit
		,(
			--// MODIFICACION MOSTRAR STOP_SEQUENCE_NUMBER IGUAL QUE LO MUESTRA EBS Y NO INVERTIDO
			--select ((max(wts.stop_sequence_number) over (partition by wts.trip_id) - wts.stop_sequence_number) + 20) seq, wdl.delivery_id, wts.trip_id
			select wts.stop_sequence_number seq, wdl.delivery_id, wts.trip_id
			from 
			 wsh_trip_stops wts
			,wsh_delivery_legs wdl 
			where 1=1
			and wts.stop_id = wdl.drop_off_stop_id
		) stop		
		where 1=1
		and wtd.trip_id = xwit.trip_id
		and wtd.delivery_id = wnd.delivery_id
		and wtd.inventory_item_id = msi.inventory_item_id
		and wtd.organization_id = msi.organization_id
		and stop.delivery_id = wtd.delivery_id
		and stop.trip_id = xwit.trip_id		
		and xwit.status = 'NEW'
		and wtd.released_status != 'D'
		and xwit.request_id = i_request_id
		and not exists(
			select 1
			from xx_wms_int_trip_deliveries xwitd
			where 1=1
			and xwitd.organization_id = xwit.organization_id
            and xwitd.trip_id = xwit.trip_id
			and xwitd.delivery_detail_id = wtd.delivery_detail_id
		)
		;

		debug(l_proc || 'Insert Into Xx_Wms_Int_Trip_Deliveries => ' || sql%rowcount);

	exception
		when others then
			x_error := l_proc || sqlerrm;
			debug(x_error);
	end insert_lines;

	--//-----------------------------------------------------------
	--// PROCEDURE UPDATE_LINES
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
	procedure update_lines(
		i_request_id	IN	NUMBER,
		x_error			OUT	VARCHAR2
	)
	is
		l_proc constant  varchar2(50) := 'update_lines: ';
	begin

		x_error := NULL;

		update xx_wms_int_trip_deliveries xwitd
		set (xwitd.numero_pedido, xwitd.tipo_pedido, xwitd.quantity, xwitd.customer_name, xwitd.customer_address) = (
			select 
				(
					select 
					 substr(listagg(order_number, ', ') within group(order by order_number), 1, 2000)
					from 
					(
						select distinct
						 wtd.source_header_number order_number    
						from
						 wsh_trip_deliverables_v wtd
						where 1=1
						and wtd.trip_id = xwitd.trip_id
						and wtd.delivery_id = xwitd.delivery_id
						and wtd.inventory_item_id = xwitd.inventory_item_id
						and wtd.organization_id = xwitd.organization_id
						and xwitd.status = 'NEW'
						and xwitd.request_id = i_request_id
					)
				) order_number
				,(
					select 
					 substr(listagg(order_type, ', ') within group(order by order_type), 1, 2000)
					from
					(
						select distinct
						 wtd.source_header_type_name order_type
						from
						 wsh_trip_deliverables_v wtd
						where 1=1
						and wtd.trip_id =  xwitd.trip_id
						and wtd.delivery_id = xwitd.delivery_id
						and wtd.inventory_item_id = xwitd.inventory_item_id
						and wtd.organization_id = xwitd.organization_id
						and xwitd.status = 'NEW'
						and xwitd.request_id = i_request_id
					)
				) order_type
				,(
					select 
					case when(mapp.xx_uom_wms is null)then null
					else
						inv_convert.inv_um_convert(
							msi.inventory_item_id,
							NULL,
							wtd.requested_quantity,
							wtd.requested_quantity_uom,
							mapp.xx_uom_wms,
							NULL,
							NULL
						)
					end
					from 
					 mtl_system_items_b msi
					,wsh_trip_deliverables_v wtd
					,(
						select
						mcr_dfv.xx_uom_wms, mcr.inventory_item_id, mcr.organization_id
						from
						 mtl_cross_references mcr
						,mtl_cross_references_dfv mcr_dfv
						where 1=1		
						and mcr.cross_reference_type = 'DUN14'
						and mcr.rowid = mcr_dfv.row_id		
					) mapp
					where 1=1
					and wtd.inventory_item_id = msi.inventory_item_id
					and wtd.organization_id = msi.organization_id
					and mapp.inventory_item_id(+) = msi.inventory_item_id
					and nvl(mapp.organization_id(+), msi.organization_id) = msi.organization_id
					and wtd.trip_id = xwitd.trip_id
					and wtd.delivery_id = xwitd.delivery_id
					and wtd.inventory_item_id = xwitd.inventory_item_id
					and wtd.organization_id = xwitd.organization_id
					and wtd.delivery_detail_id = xwitd.delivery_detail_id
					and xwitd.status = 'NEW'
					and xwitd.request_id = i_request_id
				) quantity
				,(
					select
						substr(listagg(party_name, ', ') within group(order by party_name), 1, 2000)
					from (
						select distinct 
						 hp.party_name
						from 
						 wsh_trip_deliverables_v wtd
						,hz_cust_accounts hca
						,hz_parties hp
						where 1=1
						and wtd.customer_id = hca.cust_account_id
						and hca.party_id = hp.party_id
						and wtd.trip_id = xwitd.trip_id
						and wtd.delivery_id = xwitd.delivery_id
						and wtd.inventory_item_id = xwitd.inventory_item_id
						and wtd.organization_id = xwitd.organization_id
						and xwitd.status = 'NEW'
						and xwitd.request_id = i_request_id
					)				
				) customer_name
				,(
					select
						substr(listagg(customer_address, ', ') within group(order by customer_address), 1, 2000)
					from (
						select distinct 
						 hps.party_site_number || ' : ' || 
						 hl.address1 || '-' || 
						 hl.address2 || '-' || 
						 hl.address3 || '-' || 
						 hl.address4 || '-' || 
						 hl.postal_code || '-' || 
						 hl.country customer_address
						from 
						 wsh_trip_deliverables_v wtd
						,hz_cust_accounts hca
						,hz_parties hp
						,hz_locations hl
						,hz_party_sites hps
						,oe_order_headers_all ooh
						,hz_cust_acct_sites_all hcas						
						where 1=1
						and wtd.source_header_id = ooh.header_id
						and wtd.customer_id = hca.cust_account_id
						and wtd.ship_to_location_id = hl.location_id
						and hca.party_id = hp.party_id
						and hl.location_id = hps.location_id
						and hp.party_id = hps.party_id
						and hps.party_site_id = hcas.party_site_id
						and hcas.org_id = ooh.org_id						
						and wtd.trip_id = xwitd.trip_id
						and wtd.delivery_id = xwitd.delivery_id
						and wtd.inventory_item_id = xwitd.inventory_item_id
						and wtd.organization_id = xwitd.organization_id
						and xwitd.status = 'NEW'
						and xwitd.request_id = i_request_id
					)				
				) customer_address
			from dual
		)
		where xwitd.request_id = i_request_id
		;

		debug(l_proc || 'Update Xx_Wms_Int_Trip_Deliveries => ' || sql%rowcount);

	exception
		when others then
			x_error := l_proc || sqlerrm;
			debug(x_error);
	end update_lines;

    --//-----------------------------------------------------------
	--// PROCEDURE VALIDATE_LINES
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------
	procedure validate_lines(
        i_request_id    IN  NUMBER,
        x_error         OUT VARCHAR2
	)
	is
		l_proc constant  varchar2(50) := 'validate_lines: ';
	begin

		x_error := NULL;

        update xx_wms_int_trip_deliveries
        set status = 'ERROR',
		error_mesg = case when(error_mesg is null)then '' else error_mesg || '. ' end || 'Item sin cross references configurada: ' || item_number,
		last_update_date = SYSDATE
        where 1=1
		and quantity is null
        and request_id = i_request_id
        ;

		debug(l_proc || 'Item Sin Cross References Configurada => ' || sql%rowcount);

		update xx_wms_int_trip_deliveries xwitd
		set status = 'ERROR', last_update_date = SYSDATE,
		xwitd.error_mesg = 
		case when(xwitd.error_mesg is null) then '' else xwitd.error_mesg || '. ' end || 'No existe conversion de: ' || 
		(
			select distinct 
			wtd.requested_quantity_uom uom
			from
			 wsh_trip_deliverables_v wtd
			where 1=1
			and wtd.trip_id = xwitd.trip_id
			and wtd.delivery_id = xwitd.delivery_id
			and wtd.inventory_item_id = xwitd.inventory_item_id
			and wtd.organization_id = xwitd.organization_id
			and wtd.delivery_detail_id = xwitd.delivery_detail_id
		) || ' para el item: ' || xwitd.item_number
		where 1=1
		and quantity = -99999 
		and xwitd.request_id = i_request_id
		;

		debug(l_proc || 'No Existe Conversion De UOM => ' || sql%rowcount);

        update xx_wms_int_trip_deliveries xwitd
        set xwitd.status = 'ERROR', xwitd.last_update_date = SYSDATE,
		xwitd.error_mesg = case when(xwitd.error_mesg is null) then '' else xwitd.error_mesg || '. ' end || 'Item sin enviar a WMS: ' || xwitd.item_number
        where not exists(
            select 1
              from 
               xx_wms_int_items xii
             where 1 = 1
               and xii.inventory_item_id = xwitd.inventory_item_id
			   and xii.organization_id = xwitd.organization_id
               and xii.status = 'OK'
			   and nvl(xii.item_complete_flag, 'N') = 'Y'
        )				   
        and xwitd.request_id = i_request_id
        ;

		debug(l_proc || 'Item Sin Enviar A WMS => ' || sql%rowcount);

        update xx_wms_int_trip_deliveries xwitd
        set xwitd.status = 'ERROR', xwitd.last_update_date = SYSDATE,
		xwitd.error_mesg = case when(xwitd.error_mesg is null) then '' else xwitd.error_mesg || '. ' end || 'Pick Release Status Incorrecto: ' || xwitd.released_status
        where 1=1
		and xwitd.released_status not in('B', 'R')
        and xwitd.request_id = i_request_id
        ;

		debug(l_proc || 'Pick Release Status Incorrecto => ' || sql%rowcount);		

	exception
		when others then
			x_error := l_proc || sqlerrm;
			debug(x_error);
	end validate_lines;

	--//-----------------------------------------------------------
	--// PROCEDURE REJECT_TRIPS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--//-----------------------------------------------------------	
	procedure reject_trips(
        i_request_id    IN  NUMBER,
        x_error         OUT VARCHAR2
	)
	is
		l_proc constant  varchar2(50) := 'reject_trips: ';
	begin

		x_error := NULL;

        update xx_wms_int_trips xwit
        set xwit.status = 'ERROR', xwit.last_update_date = SYSDATE,
		xwit.error_mesg = 'Existe alguna línea con error para este viaje.'
		where exists(
			select 1 
			from xx_wms_int_trip_deliveries xwitd
			where 1=1
			and xwit.trip_id = xwitd.trip_id
			and xwit.organization_id = xwitd.organization_id
			and xwitd.request_id = i_request_id
			and xwitd.status = 'ERROR'
		)
		and xwit.request_id = i_request_id
		and xwit.status = 'NEW'
		;

		debug(l_proc || 'Existe Alguna Línea Con Error Para Este Viaje(Cabecera) => ' || sql%rowcount);

        update xx_wms_int_trip_deliveries xwitd
        set xwitd.status = 'ERROR', xwitd.last_update_date = SYSDATE,
		xwitd.error_mesg = 'Existe alguna línea con error para este viaje.'
		where exists(
			select 1
			from xx_wms_int_trip_deliveries
			where 1=1
			and trip_id = xwitd.trip_id
			and organization_id = xwitd.organization_id
			and request_id = i_request_id
			and status = 'ERROR'			
		)
		and xwitd.request_id = i_request_id
		and xwitd.status = 'NEW'
		;

		debug(l_proc || 'Existe Alguna Línea Con Error Para Este Viaje(Lineas) => ' || sql%rowcount);

	exception
		when others then
			x_error := l_proc || sqlerrm;
			debug(x_error);
	end reject_trips;

	--//-----------------------------------------------------------
	--// PROCEDURE GET_XML
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @PARAM: X_ERROR		VARCHAR2
	--// @PARAM: X_XML			VARCHAR2
	--//-----------------------------------------------------------
	procedure get_xml(
		i_request_id    IN  NUMBER,
		x_error         OUT VARCHAR2,
		x_xml			OUT NOCOPY CLOB
	)
	is
		l_proc constant  varchar2(50) := 'get_xml: ';
		l_xml	XMLTYPE;
	begin

		x_error := NULL;

		select 
			XMLELEMENT("LgfData",
				XMLELEMENT("Header",
					XMLELEMENT("DocumentVersion", '9.0.1'),
					XMLELEMENT("OriginSystem", 'Host'),
					XMLELEMENT("ClientEnvCode", i_request_id),
					XMLELEMENT("ParentCompanyCode", 'ADECO'),
					XMLELEMENT("Entity", 'order'),
					XMLELEMENT("TimeStamp", to_char(sysdate,'YYYY-mm-dd hh24:mi:ss')),
					XMLELEMENT("MessageId", i_request_id)
				)
				,
				XMLELEMENT("ListOfOrders",
					(
						select XMLAGG(
							XMLELEMENT("order",
								XMLELEMENT("order_hdr",
									XMLFOREST(
										 hdr.facility_code "facility_code"
										,'ADECO' "company_code"
										,hdr.trip_id "order_nbr"
										,'Venta' "order_type"
										,sysdate "ord_date"
										,hdr.req_ship_date "req_ship_date"
										,'*' "dest_company_code"
										,hdr.customer_number "cust_nbr"
										,hdr.customer_name "cust_name"
										,hdr.customer_address "cust_addr"
										,'CREATE' "action_code"
										,hdr.trip_id "route_nbr"
										,hdr.trip_id "cust_field_1"								
									)
								)
								,
								--//DETALE
								(
									select XMLAGG(
										XMLELEMENT("order_dtl",
											XMLFOREST(
												 dtl.seq_nbr "seq_nbr"
												,dtl.item_number "item_alternate_code"
												,dtl.quantity "ord_qty"
												,'CREATE' "action_code"
												,dtl.delivery_id "cust_field_2"
												,dtl.numero_pedido "cust_field_3"
												,dtl.tipo_pedido "cust_field_4"
												,dtl.parada "cust_field_5"
												,dtl.customer_name_dtl "cust_field_1"
												,dtl.customer_address_dtl "cust_long_text_1"
											)
										)
									)
									from (
										select 
											rownum seq_nbr, 
											item_number,
											quantity,
											delivery_id,
											numero_pedido,
											tipo_pedido,
											parada,
											customer_name_dtl,
											customer_address_dtl
										from (
											select
												xwitd.item_number,
												sum(xwitd.quantity) quantity,
												xwitd.delivery_id,
												xwitd.numero_pedido,
												xwitd.tipo_pedido,
												xwitd.parada,
												xwitd.customer_name customer_name_dtl,
												xwitd.customer_address customer_address_dtl
											from 
												xx_wms_int_trip_deliveries xwitd
											where 1=1
											and xwitd.request_id = hdr.request_id
											and xwitd.organization_id = hdr.organization_id
											and xwitd.trip_id = hdr.trip_id
											and xwitd.status != 'ERROR'
											group by
												xwitd.item_number,
												xwitd.delivery_id,
												xwitd.numero_pedido,
												xwitd.tipo_pedido,
												xwitd.parada,
												xwitd.customer_name,
												xwitd.customer_address
										)
									) dtl
								)
								--//FIN DETALLE							
							)
						)
						from (
							select 
								xwit.facility_code,
								xwit.trip_id,
								xwit.req_ship_date,
								substr(xwit.customer_number, 1, 25) customer_number,
								substr(xwit.customer_name, 1, 50) customer_name,
								substr(xwit.customer_address, 1, 70) customer_address,
								xwit.organization_id,
								xwit.status,
								xwit.request_id
							from xx_wms_int_trips xwit
							where xwit.request_id = i_request_id
							and xwit.status != 'ERROR'
							and not exists(
								select 1
								from xx_wms_int_trip_deliveries
								where 1=1
								and trip_id = xwit.trip_id
								and organization_id = xwit.organization_id
								and request_id = xwit.request_id
								and status = 'ERROR'
							)
						) hdr
					)
				)			
			)
		into l_xml
		from dual
		;

		x_xml := l_xml.getClobVal();

		debug(l_proc || 'X_Xml Length => ' || DBMS_LOB.GETLENGTH(x_xml));

	exception
		when others then
			x_error := l_proc || sqlerrm;
			debug(x_error);
	end get_xml;

	--//-----------------------------------------------------------
	--// FUNCTION INTERFACE_ROWS
	--//-----------------------------------------------------------
	--// @PARAM: I_REQUEST_ID	NUMBER
	--// @RETURN:				NUMBER
	--//-----------------------------------------------------------	
	function interface_rows(
		i_request_id	IN	NUMBER
	) return boolean
	is
		l_proc constant  varchar2(50) := 'interface_rows: ';
		l_rows	number;
	begin

		select count(1) into l_rows
		from xx_wms_int_trips xwit
		where 1=1
		and xwit.status != 'ERROR'
		and xwit.request_id = i_request_id
		and not exists(
			select 1
			from xx_wms_int_trip_deliveries xwitd
			where 1=1
			and xwitd.status = 'ERROR'
			and xwitd.request_id = xwit.request_id
			and xwitd.organization_id = xwit.organization_id
			and xwitd.trip_id = xwit.trip_id					
		);

		debug(l_proc || 'Registros A Procesar => ' || l_rows);

		return case when(l_rows != 0)then true else false end;

	exception
		when others then
			debug(l_proc || sqlerrm);		
	end interface_rows;


	--//-----------------------------------------------------------
	--// PROCEDURE GET_INTEGRATION_DATA
	--//-----------------------------------------------------------
	--// @PARAM: I_INT_TYPE			VARCHAR2
	--// @PARAM: X_XML_TRIP			VARCHAR2
	--// @PARAM: X_REQUEST_ID		NUMBER
	--// @PARAM: X_RETURN_STATUS	VARCHAR2
	--// @PARAM: X_MSG_DATA			VARCHAR2
	--//-----------------------------------------------------------
    procedure get_integration_data(
         i_int_type         IN  VARCHAR2
        ,x_xml_trip         OUT NOCOPY CLOB
        ,x_request_id       OUT NUMBER
        ,x_return_status    OUT VARCHAR2
        ,x_msg_data         OUT VARCHAR2
    )
    is
		l_proc  		constant varchar2(50) := 'get_integration_data: ';
        l_request_id    number := to_char(sysdate,'yyyymmddhh24mi');
        l_error         varchar2(32767);
		l_xml			CLOB;        
        l_exception     exception;
		l_date_from date := get_date_from;

    begin

		debug(l_proc || 'Init => ' || i_int_type || ' RequestId => ' || l_request_id || ' L_Date_From => ' || to_char(l_date_from, 'DD/MM/YYYY HH24:MI:SS'));

		x_request_id := l_request_id;

        update_errors(
            i_request_id => l_request_id,
            x_error => l_error
        );

        if(l_error is not null)then
            RAISE l_exception;
        end if;

		insert_headers(
			i_request_id => l_request_id,
			i_date_from => l_date_from,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;            
		end if;

		update_headers(
			i_request_id => l_request_id,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;            
		end if;

		validate_headers(
			i_request_id => l_request_id,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;            
		end if;

		insert_lines(
			i_request_id => l_request_id,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;
		end if;

		update_lines(
			i_request_id => l_request_id,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;
		end if;

		validate_lines(
			i_request_id => l_request_id,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;
		end if;

		reject_trips(
			i_request_id => l_request_id,
			x_error => l_error
		);

		if(l_error is not null)then
			RAISE l_exception;
		end if;		

		if(interface_rows(i_request_id => l_request_id))then

			get_xml(
				i_request_id => l_request_id,
				x_error => l_error,
				x_xml => l_xml
			);

			if(l_error is not null)then
				RAISE l_exception;
			end if;

			x_xml_trip := l_xml;
			x_return_status := g_status_success;

		else
			x_return_status := g_status_no_data;
		end if;

		debug(l_proc || 'End => ' || i_int_type || ' => ' || x_return_status);

	exception

		when l_exception then

			x_msg_data := l_error;
            x_return_status := g_status_error;
			set_errors(
				i_request_id => l_request_id,
				i_error => l_error
			);
			debug(l_proc || x_msg_data);

        when others then

			x_msg_data := l_proc || sqlerrm;
            x_return_status := g_status_error;
			set_errors(
				i_request_id => l_request_id,
				i_error => l_error
			);
			debug(x_msg_data);

    end get_integration_data;

    --//-----------------------------------------------------------
	--// PROCEDURE UPDATE_RESPONSE_INTEGRATION
	--//-----------------------------------------------------------
	--// @PARAM: I_INT_TYPE			VARCHAR2
	--// @PARAM: I_REQUEST_ID		NUMBER
	--// @PARAM: I_RETURN_STATUS	VARCHAR2
	--// @PARAM: I_MSG_DATA			VARCHAR2
	--//-----------------------------------------------------------
    procedure update_response_integration(
         i_int_type         IN  VARCHAR2
        ,i_request_id       IN  NUMBER
        ,i_return_status    IN  VARCHAR2
        ,i_msg_data         IN  VARCHAR2
    )
    is
		l_proc constant varchar2(50) := 'update_response_integration: ';	
    begin

		update xx_wms_int_trips
		set 
		 status = case when(i_return_status = 'True')then 'OK' else 'ERROR' end
		,error_mesg = case when(i_return_status = 'True')then null else i_msg_data end
		,last_update_date = sysdate
		,last_updated_by = fnd_global.user_id
		where request_id = i_request_id
		and status != 'ERROR'
		;

		update xx_wms_int_trip_deliveries
		set 
		 status = case when(i_return_status = 'True')then 'OK' else 'ERROR' end
		,error_mesg = case when(i_return_status = 'True')then null else i_msg_data end
		,last_update_date = sysdate
		,last_updated_by = fnd_global.user_id
		where request_id = i_request_id
		and status != 'ERROR'
		;

    exception
        when others then
            debug(l_proc || sqlerrm);
    end update_response_integration;            

end xx_wms_int_out_trips_pk;
/

show error
spool off;
exit;
