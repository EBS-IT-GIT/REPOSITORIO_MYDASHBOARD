<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WebServiceController extends Controller {

    //

    public static function webService_login() {

        $data_wb = [
            'email' => 'ebs-it@ebs-it.services',
            'password' => 'e1b2s3i4n5t6e7g8r9a0c1a2o3',
        ];

        $curl = curl_init();

        curl_setopt_array($curl, array(
	    CURLOPT_URL => env('WEB_SERVICE') . 'api/auth/login',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30000,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "POST",
            CURLOPT_POSTFIELDS => json_encode($data_wb),
            CURLOPT_HTTPHEADER => array(
                // Set here requred headers
                "accept: */*",
                "accept-language: en-US,en;q=0.8",
                "content-type: application/json",
            ),
        ));

        $response = curl_exec($curl);
        $err = curl_error($curl);

        curl_close($curl);

        if ($err) {
            echo "cURL Error #:" . $err;
            $token_wb = "";
        } else {
            $obj = json_decode($response);
            $token_wb = $obj->{'token'};
        }

        return $token_wb;
    }

    public static function webService_update($token, Request $request, $userid = 0) {

        $data_wb_create = [
            //'id_sistema' => '1',
            //certo 'id_integracao' => $request['cf_15_' . $request->taskid],
            'id_servicedesk' => $request->taskid,
        ];

        if (isset($request['cf_15_' . $request->taskid]) and ($request['cf_15_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['id_integracao' => $request['cf_15_' . $request->taskid],];
        } else {
            $sql = 'SELECT id_integracao from sd_interfaces WHERE id_servicedesk = ' . $request->taskid;
            $id_int = \DB::connection('mysql_webservice')->select($sql);
            
            if($id_int){
            foreach ($id_int as $id_inte){}    
            
            $data_wb_create += ['id_integracao' => $id_inte->id_integracao];
            }
        }
        
        //>>>campo custom close_code BRK

	 $cod_encerramento = '';

        //>>>campo custom close_code BRK
        //GMUD

	if ($request['cf_38_' . $request->taskid] && $request['cf_38_' . $request->taskid] !== "undefined") {
        $cod_encerramento = $request['cf_38_' . $request->taskid];
        }
        //PROBLEMA
        if ($request['cf_44_' . $request->taskid] && $request['cf_44_' . $request->taskid] !== "undefined") {
        $cod_encerramento = $request['cf_44_' . $request->taskid];
        }
        //INCIDENTE
        if ($request['cf_42_' . $request->taskid] && $request['cf_42_' . $request->taskid] !== "undefined") {
        $cod_encerramento = $request['cf_42_' . $request->taskid];
        }

        $data_wb_create += ['codigo_encerramento' => $cod_encerramento,];

        
        //<<<campo custom close_code BRK

        //campo custom BRK CODIGO CANCELAMENTO
        if (isset($request['cf_39_' . $request->taskid]) and ($request['cf_39_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom1' => $request['cf_39_' . $request->taskid],];
        }

        //campo custom INC-RITM CODIGO CANCELAMENTO
        if (isset($request['cf_40_' . $request->taskid]) and ($request['cf_40_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom1' => $request['cf_40_' . $request->taskid],];
        }

        //campo custom BRK MOTIVO FEEDBACK
        if (isset($request['cf_41_' . $request->taskid]) and ($request['cf_41_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom2' => $request['cf_41_' . $request->taskid],];
        }


        //campo custom BRK CAUSA RAIZ
        if (isset($request['cf_43_' . $request->taskid]) and ($request['cf_43_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom3' => $request['cf_43_' . $request->taskid],];
        }


	// campo custom BRK CAUSE NOTES PROBLEMA
        if (isset($request['cf_46_' . $request->taskid]) and ($request['cf_46_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom4' => $request['cf_46_' . $request->taskid],];
        }

         //campo custom BRK workaround
        if (isset($request['cf_47_' . $request->taskid]) and ($request['cf_47_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom6' => $request['cf_47_' . $request->taskid],];
        }
	//cause_code
        if (isset($request['cf_45_' . $request->taskid]) and ($request['cf_45_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['campo_custom7' => $request['cf_45_' . $request->taskid],];
        }
	
        
        if (isset($request->title)) {
            $data_wb_create += ['titulo' => $request->title];
        }
        if (isset($request->tracker)) {
            $data_wb_create += ['tipo' => $request->tracker];
        }
        if (isset($request->priority)) {
            $data_wb_create += ['id_prioridade' => $request->priority,];
        }
        if (isset($request->assignedid)) {
            $data_wb_create += ['id_atribuido_para' => $request->assignedid,];
        }
        if($userid <> 0){
            $data_wb_create += ['id_atribuido_para' => $userid,];
        }
        if (isset($request->due_date)) {
            $data_wb_create += ['data_prevista' => $request->due_date,];
        }
        if (isset($request->notes)) {
            $data_wb_create += ['notas' => $request->notes,];
        }
        
            $atribuido_para = $request->assignedid;
            $f = '';
            if(!$atribuido_para){
                $atribuido_para = $userid;

            }
            //verificar se é uma fila
            $iffila = 'SELECT lastname FROM users WHERE id = '.$atribuido_para.' AND lastname like "%Fila%"';
            $iffila = \DB::connection('mysql_redmine')->select($iffila);

            if(!$iffila){
                //verificar as filas que a pessoa está
                $sql = 'SELECT g.lastname lastname FROM users u INNER JOIN groups_users gu ON u.id = gu.user_id INNER JOIN users g ON
                g.id = gu.group_id WHERE u.id = '.$atribuido_para.' and g.lastname like "%Fila%"';
                $filas = \DB::connection('mysql_redmine')->select($sql);

                foreach($filas as $fila){

                    $fila_atual = 'SELECT value FROM custom_values WHERE customized_id = '.$request->taskid.' AND custom_field_id = 24';
                    $fila_atual = \DB::connection('mysql_redmine')->select($fila_atual);

                    foreach($fila_atual as $fila_atual){
                        if($fila_atual->value == $fila->lastname){
                            $f = $fila->lastname;

                        }
                    }
                } 
                if($f == ''){
                    $sql = 'SELECT g.lastname lastname FROM users u INNER JOIN groups_users gu ON u.id = gu.user_id INNER JOIN users g ON
                    g.id = gu.group_id WHERE u.id = '.$atribuido_para.' and g.lastname like "%Fila%" LIMIT 1';

                    $prefe = \DB::connection('mysql_redmine')->select($sql);
                    foreach($prefe as $prefe){
                        $f = $prefe->lastname;
                    } 
                }
            }
            else{
                foreach($iffila as $iffila){
                    $f = $iffila->lastname;
                }
            }

            if (isset($f) and ($f !== "undefined") and ($f !== $request['cf_24_' . $request->taskid])) {
                $data_wb_create += ['fila' => $f,];
            } else {
                $data_wb_create += ['fila' => ''];
            }
        
        // else{
        //     if (isset($request['cf_24_' . $request->taskid]) and ($request['cf_24_' . $request->taskid] !== "undefined")) {
        //         $data_wb_create += ['fila' => $request['cf_24_' . $request->taskid],];
        //     } else {
        //         $data_wb_create += ['fila' => ' '];
        //     }
        // }
        
        if (isset($request['cf_30_' . $request->taskid]) and ($request['cf_30_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['dt_real_de_inicio' => $request['cf_30_' . $request->taskid],];
        } else {
            $data_wb_create += ['dt_real_de_inicio' => ' '];
        }
        if (isset($request['cf_31_' . $request->taskid]) and ($request['cf_31_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['dt_real_de_fim' => $request['cf_31_' . $request->taskid],];
        } else {
            $data_wb_create += ['dt_real_de_fim' => ' '];
        }
        if (isset($request->description)) {
            $data_wb_create += ['descricao' => $request->description,];
        }
        if (isset($request->statusid) and $request->statusid <> 0) {
            $data_wb_create += ['id_situacao' => $request->statusid,];
        }
        //Custom fields OTRS
        if (isset($request['cf_10_' . $request->taskid]) and ($request['cf_10_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['pendencia' => $request['cf_10_' . $request->taskid],];
        } else {
            $data_wb_create += ['pendencia' => ' '];
        }
        if (isset($request['cf_11_' . $request->taskid]) and ($request['cf_11_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['solucao' => $request['cf_11_' . $request->taskid],];
        } else {
            $data_wb_create += ['solucao' => ' '];
        }
        if (isset($request['cf_22_' . $request->taskid]) and ($request['cf_22_' . $request->taskid] !== "undefined")) {
            $data_wb_create += ['dt_previsao_termino_orig' => $request['cf_22_' . $request->taskid],];
        } else {
            $data_wb_create += ['dt_previsao_termino_orig' => ' '];
        }        
        $curl = curl_init();
        curl_setopt_array($curl, array(
	    CURLOPT_URL => env('WEB_SERVICE') . 'api/web_interfaces/' . $request->taskid,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30000,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "PUT",
            CURLOPT_POSTFIELDS => json_encode($data_wb_create),
            CURLOPT_HTTPHEADER => array(
                // Set here requred headers
                "accept: */*",
                "accept-language: en-US,en;q=0.8",
                "content-type: application/json",
                "Authorization: Bearer $token",
            ),
        ));

        $response = curl_exec($curl);
        
        curl_close($curl);
        
        return $response;
    }
    //Anexo
    public static function anexar($token, Request $request,$id_sistema,$userid = 0) {

        $file = $request->file('fileUpload');
       
        $taskid = $request->taskid;
        $response = '';
        
        foreach($file as $file){
            $filecontent = $file->getPathName();
            $filename = $file->getClientOriginalName();
            $contenttype = $file->getMimeType();
           
           
        
        $data_wb_create = array(            
            'id_servicedesk' => $taskid,
            'id_sistema' => $id_sistema,
            'anexos[]' => curl_file_create($filecontent,$contenttype,$filename),
        );
   
        $curl = curl_init();
        curl_setopt_array($curl, array(
	    CURLOPT_URL => env('WEB_SERVICE') . 'api/anx_interfaces',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30000,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "POST",
            CURLOPT_POSTFIELDS => $data_wb_create,
            CURLOPT_HTTPHEADER => array(
                // Set here requred headers
                "accept: */*",
                "accept-language: en-US,en;q=0.8",
                "content-type: multipart/form-data", // change Content-Type
                "Authorization: Bearer $token",
            ),
        ));

        $response = curl_exec($curl);
        
        curl_close($curl);

    }
    return $response;

    }
    
}

