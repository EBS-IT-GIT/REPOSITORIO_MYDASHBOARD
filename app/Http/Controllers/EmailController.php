<?php

namespace App\Http\Controllers;

use App\Log;
use App\Cronometro;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Testing\MimeType;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Redmine\Client as Client;
use function MongoDB\BSON\fromJSON;


class EmailController extends Controller
{


    /**
     * Create a new controller instance.
     *
     * @return void
     */
   
//enviar email sla

   
     public function email(){
        $i = '';
        $user_ativo = 'select u.id usuario from users u
        inner join groups_users gu on u.id = gu.user_id
        inner join users g on gu.group_id = g.id and g.lastname like "%Fila%"
        where u.status = 1
        union
        select g.id from users g where g.lastname like "%Fila%" and g.status = 1
        ';
        $user_ativo = \DB::connection('mysql_redmine')->select($user_ativo);
        foreach($user_ativo as $user_ativos){
            $id = $user_ativos->usuario;

            $email = $this->email_body($id);
            $json = json_encode($email); 
            $json = json_decode($json, true); 
            if($json){
            $json = $json[0];
        
            //  $user = (object)[
            //      'emails' => $email,
            //      'name' =>  $json['equipe_analista'],
            //      'email' => 'camila.martins@ebs-it.services',
            //      'cc' =>   'camila.martins@ebs-it.services',
            // 'bcc'=> 'camila.martins@ebs-it.services',

            //  ];
             $user = (object)[
                'emails' => $email,
                'name' =>  $json['equipe_analista'],
                'email' =>   $json['email'],
                'cc' =>   'gestores@ebs-it.services',
                'bcc'=> 'camila.martins@ebs-it.services',
            ];
            // 'email' => 'camila.martins@ebs-it.services',
            // 'cc' => 'camila.martins@ebs-it.services',
           
       //return new \App\Mail\emailLaravel((object) $user);
        \Illuminate\Support\Facades\Mail::send(new \App\Mail\emailLaravel((object) $user));
            }
    }

}
public static function email_body($id){
      
    $sql='SELECT status_name, email , equipe_analista, 
    dtnumber, cliente, cdchamado,dschamado 
   from(
   select datediff( str_to_date(dtnumber,"%d/%m/%Y %H:%i:%s"),now()) diferenca,chamados.*
   from (
   SELECT DATE_FORMAT(if(a.status_id = 1,if( isla.dt_vencimento_resposta is null, a.created_on, isla.dt_vencimento_resposta)
               ,if( isla.dt_vencimento_solucao is null, a.created_on, isla.dt_vencimento_solucao)),"%d/%m/%Y %H:%i:%s") dtnumber,
                     a.id cdchamado,
                     a.status_id status,
                     s.name status_name,
                   SUBSTRING(a.subject,1,300) dschamado,
                     LEFT(b.name,4) cliente,
                 IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM EQUIPE") equipe_analista,
                 if(em.address is null,(select els.email from redmine_sla.emails_extras els where els.user_id = u.id), em.address) email
                 FROM redmine.issues a
             LEFT JOIN redmine_sla.expiration_sla isla ON isla.issue_id = a.id
                 INNER JOIN redmine.projects b ON a.project_id = b.id
                 INNER JOIN redmine.users u ON a.assigned_to_id = u.id
                 INNER JOIN issue_statuses s ON a.status_id = s.id
                 INNER JOIN redmine.custom_values cv ON cv.customized_id = b.id AND cv.customized_type = "Project" AND cv.custom_field_id = 14
                 LEFT JOIN email_addresses em on em.user_id = a.assigned_to_id
             WHERE a.status_id NOT IN (3,5,18,15,16)
                 AND cv.value = "Suporte e Monitoramento" and u.id = '.$id.'
                 AND s.name not in ("Feedback","RDM-Validar QA","RDM-Validar PROD","RDM-Congelar Mudança","RDM-Aplicar PROD","Aguardando aprovação")
                 ) chamados
   where datediff( str_to_date(dtnumber,"%d/%m/%Y %H:%i:%s"),now()) < 1
   order by 1 asc) sub ';

    $email = \DB::connection('mysql_redmine')->select($sql);
   
    return $email;
}
    


}

?>
