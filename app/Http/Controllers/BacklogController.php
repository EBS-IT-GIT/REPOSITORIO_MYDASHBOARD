<?php

namespace App\Http\Controllers;

use App\Http\Controllers\HomeController;
use App\Log;
use App\Cronometro;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Testing\MimeType;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\ReportsController;
use Redmine\Client as Client;
use function MongoDB\BSON\fromJSON;

class BacklogController extends Controller
{
    public function backlog(){
        $conn = HomeController::connectApi();
        $activities = [];
        if (isset($activity['time_entry_activities']))
            $activities = $activity['time_entry_activities'];

        $contador = Cronometro::listarContadorEmAberto();

        $grupos = 'select id,lastname name from users where lastname like "%Fila%"';
        $grupos = \DB::connection('mysql_redmine')->select($grupos);

        return view('backlog',[
            'grupos' => $grupos,
            'contador' => $contador,
            'activities' => $activities,
            // 'status' => json_encode($status['issue_statuses'])
        ]);
    }
    public function backloglist(Request $request){
       
        if ($request) {
            $user_id = \Session::get('user')['id'];
            $equipe = $request->equipe;
            $conn = HomeController::connectApi();

            $sql = 'SELECT CONCAT(if(se.value in (1,2,3,4,5), se.value,6),
            if(a.status_id = 1,a.dt_vencimento_resposta, a.novo_dt_vencimento_solucao)) dtnumber,
            if(a.status_id = 1,a.dt_vencimento_resposta, a.novo_dt_vencimento_solucao) venc,
            if((select venc) < NOW(),"", TIMEDIFF((select venc),NOW()))horas,
            DATE_FORMAT((select venc),"%d/%m/%Y %H:%i:%s") dt,
              DATE_FORMAT(a.created_on,"%d/%m/%Y %H:%i:%s") dtchamado,
                  a.id cdchamado,
                  b.id cdprojeto,
              SUBSTRING(a.subject,1,300) dschamado,
                  LEFT(b.name,4) cliente,
                  s.name estado,
                  s.id id_estado,
              s.name situacao,
              IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM RESPONSAVEL") responsavel,
              u.id idresponsavel,
              fl.value fila
              FROM (select if((SELECT 1 from redmine_sla.aux_status ax where ax.is_sla = 0 and ax.is_closed = 0 AND ax.id = i.status_id),IFNULL((select redmine_sla.fct_simular_vencimento(i.id)), isla.dt_vencimento_solucao),isla.dt_vencimento_solucao) novo_dt_vencimento_solucao, i.*, isla.dt_vencimento_solucao, isla.dt_vencimento_resposta,isla.sla_solucao,isla.sla_resposta,isla.calendar_solucao,isla.calendar_resposta,isla.dt_atendimento_solucao,isla.dt_atendimento_resposta,isla.resultado_sla_solucao,isla.resultado_sla_resposta from redmine.issues i
              left join redmine_sla.expiration_sla isla on isla.issue_id = i.id
              where i.status_id in (select id from redmine.issue_statuses where is_closed=FALSE)) a  
              INNER JOIN redmine.projects b ON a.project_id = b.id
                  INNER JOIN redmine.issue_statuses s ON a.status_id = s.id
                left JOIN redmine.users u ON a.assigned_to_id = u.id
              INNER JOIN redmine.custom_values cv ON cv.customized_id = b.id AND cv.customized_type = "Project" AND cv.custom_field_id = 14
              LEFT JOIN  (select convert(value, int) value, customized_id id from redmine.custom_values where custom_field_id = 28 and customized_type = "Issue")se on se.id = a.id
              left JOIN redmine.custom_values fl ON fl.customized_id = a.id AND fl.custom_field_id=24 and fl.customized_type = "Issue"  
          WHERE cv.value in ("Suporte e Monitoramento", "Projeto aberto - Com fila") and fl.value ="'.$equipe.'" order by case when dtnumber is null then 1 else 0 end, dtnumber';
            $registros = \DB::connection('mysql_redmine')->select($sql);
            

            $rowid = 1;
            $dados = [];
            $html = '';
            $estadolist = array_column($registros, 'estado');
            sort($estadolist);
            $qtd = array_count_values($estadolist);            
            
            foreach($qtd as $key => $val) {

                $html .=  '<label class="label label-success">'. $key .' : '. $val. '</label> ';
               
            }
            foreach ($registros as $registro) {
              
                $mytime = Carbon::now();
                if($registro->venc <= $mytime){
                    $registro->dt =  '<div class="sla" style= "color:#dd4b39;font-weight:bold"> '. $registro->dt .' </div>';
                }
                elseif(($registro->horas <='01:01:00') && ($registro->horas != '')){
                    $registro->dt =  '<div class="sla" style= "color:#ffd700;font-weight:bold"> '. $registro->dt .' </div>';
                }
                
                $dados[] = [
                    'cdchamado' =>  '<a target="_blank" class="btn btn-default btn-xs" href=" ' . \URL::to('/taskreport') . '/' . $registro->cdchamado . '">' . $registro->cdchamado . '</a>',
                    'dschamado' => $registro->dschamado,
                    'responsavel' => $registro->responsavel,
                    'cliente' => $registro->cliente . '</br><strong>' .$registro->estado. '</strong>',
                    'fila' => $registro->fila,
                    'dtchamado'=> $registro->dtchamado,
                    'dt' =>  $registro->dt,
                    'html' => $html
                    ];

                $rowid++;
            }
            // $dados['html'] = $html;
            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }

    }
  
}
