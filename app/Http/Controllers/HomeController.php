<?php

namespace App\Http\Controllers;

use App\Log;
use App\Captura;
use App\Cronometro;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Testing\MimeType;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\ReportsController;
use Redmine\Client as Client;
use function MongoDB\BSON\fromJSON;


class HomeController extends Controller
{


    /**
     * Create a new controller instanNece.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Http\Response
     */
   
    public function index(){

        $conn = $this->connectApi();
        $user_id = \Session::get('user')['id'];


        $activities = [];
        if (isset($activity['time_entry_activities']))
            $activities = $activity['time_entry_activities'];

        $contador = Cronometro::listarContadorEmAberto();

        $myprojects = array();
        //projetos em que estou associado
        $html = '<ul class="list-group" id="myList" style="list-style-type: none;">';
       
    
        //query

        $estrutura = 'SELECT gpj.id id_group, gpj.name name_group, pj.id id_project, pj.name name_project
        FROM members mb
        inner join projects pj on pj.id = mb.project_id and pj.status = 1
        left join (select id, name from projects where parent_id in(select distinct parent_id from projects where parent_id is not null)) gpj
        on gpj.id = pj.parent_id
        WHERE mb.user_id = '.$user_id.' and pj.name not like "%*%" and pj.id not in(16,22) order by id_group,pj.name  asc' ;
        $estrutura = \DB::connection('mysql_redmine')->select($estrutura);
        $project_pai = array_column($estrutura, 'id_group');
        

        $ver = '';    
        $result = array_unique($project_pai);

        foreach($estrutura as $e){
        if($ver != $e->id_group){

            //Verificar se o projeto tem permissão de abrir um chamado
            $abrir_task = 'SELECT distinct 1 abre_chamado from projects_trackers pt
            inner join enabled_modules em on em.name = "issue_tracking" and em.project_id = pt.project_id
            where pt.project_id = '.$e->id_group.'';
            $abrir_task = \DB::connection('mysql_redmine')->select($abrir_task);
            $class='';
            $link = '';
            if($abrir_task == true){
            $link = 'href="' . \URL::to('/projects') . '/' . $e->name_group .  '/' .$e->id_group.'"';
            }
            else{
                $class = 'class="open"';
            }

            $html .= '<p><li><a  '.$class.'id="pagina_pai"
            '.$link.'>'.$e->name_group.'</a></li></p>';
            $ver = $e->id_group;

        }
        
            foreach($result as $r){
            if($e->id_group == $r){
                $html .= '<li><a href="' . \URL::to('/projects') . '/' . $e->name_project .  '/' . $e->id_project .'">'.$e->name_project.'</a></li>';
            }
        }
        }
        $html.='</ul>';

        // return $html;
        return view('paginainicial', [
            'contador' => $contador,
            'activities' => $activities,
            'menu' => $html,
        ])->render();
       
    }
    //tabela de projetos 
  

    //tabela de chamados
    public function project($project_name, $project_id){

        $conn = $this->connectApi();
        $project_name = $project_name;
        $project_id =  $project_id;
        $user_id = \Session::get('user')['id'];
        $situacao =  array(new ReportsController, "listarSituacao");
        $situacao = $situacao();

        $activities = [];
        if (isset($activity['time_entry_activities']))
            $activities = $activity['time_entry_activities'];

        $contador = Cronometro::listarContadorEmAberto();
        //verifica se tem permissão para abrir um chamado 
        $add = 'SELECT *  FROM members mb
        INNER JOIN member_roles mr ON mb.id = mr.member_id
        INNER JOIN roles r ON mr.role_id = r.id 
        WHERE mb.user_id = ".$user_id." and mb.project_id = ".$projectid." and r.permissions like "%- :add_issues%"';
        $add = \DB::connection('mysql_redmine')->select($add);


        return view('projetos', [
            'contador' => $contador,
            'activities' => $activities,
            'situacao' => $situacao,
            'project_name' => $project_name,
            'project_id' => $project_id,
            'add' => $add,
        ])->render();
        
    }
    //função tabela chamados
    public function issuesList(Request $request){
        if ($request) {
        $conn = $this->connectApi();
        $project_id = $request->project_id;

                $issues = $conn->issue->all([
                    'project_id' => $project_id,
                    'status_id'  => $request->situacao.$request->status,
                    'created_on' => $request->filterdata.$request->inicio.$request->fim.$request->dias,
                    'limit' => 100,
                ]);
                
                $list_issues = $issues;

                $rowid = 0;
                $dados = array();    
                if (isset($list_issues['issues'])) {
                    foreach ($list_issues['issues'] as $task) {
                        $atribuido = '';
                        $taskid = $task['id'];
                        $project_name = $task['project']['name'];
                        $statusname = $task['status']['name'];
                        $priority = $task['priority']['name'];
                        if (isset($task['assigned_to'])) $atribuido = $task['assigned_to']['name'];
                        $titulo = $task['subject'];
                        $autor = $task['author']['name'];
                        $criacao = \Carbon\Carbon::parse($task['created_on'])->format('d/m/Y H:i:s');
                        $tipo = $task['tracker']['name'];

                        $dados[] = [
                            'id' =>  '<a target="_blank" class="btn btn-default btn-xs" href=" ' . \URL::to('/taskreport') . '/' . $taskid . '">' . $taskid . '</a>',
                            'status' => $statusname,
                            'project' => $project_id,
                            'prioridade' => $priority,
                            'titulo' => $titulo,
                            'autor' =>$autor,
                            'criacao' => $criacao,
                            'atribuido' => $atribuido,
                            'tipo' => $tipo,
                            'projeto'=> $project_name,
                        ];
                        $rowid++;

                    }
                }

                return $dados;
            }
        
    }
    public function tempo_gasto($id){
        $conn = $this->connectApi();
        $times = $conn->time_entry->show($id);
        $horas = '';
        if (isset($times['time_entries'])) {
            foreach ($times['time_entries'] as $time) {
                if (isset($time['hour'])) $horas = $time['hour'];
           
            }
            return $horas;
        }

    }
    public function home()
    {
        $conn = $this->connectApi();
        $activity = $conn->time_entry_activity->all();
        $user_id = \Session::get('user')['id'];
        $grupos = $this->myGroupsMysql();
        $preferencial = $this->myFila();

        $activities = [];
        if (isset($activity['time_entry_activities']))
            $activities = $activity['time_entry_activities'];

        $sql = "SELECT t.responsavel,
      	SUM(IF(t.situacao='New', t.qtde, 0)) AS 'New',
      	SUM(IF(t.situacao='In Progress', t.qtde, 0)) AS 'InProgress',
      	SUM(IF(t.situacao='Paused', t.qtde, 0)) AS 'Paused',
      	SUM(IF(t.situacao='Feedback', t.qtde, 0)) AS 'Feedback',
      	SUM(IF(t.situacao='Projeto', t.qtde, 0)) AS 'Projeto'
      FROM
      (SELECT concat(u.firstname,' ',u.lastname) responsavel,
      		IF((SELECT value FROM custom_values WHERE custom_field_id = 14 AND customized_id = a.project_id) = 'Suporte e Monitoramento',
      		IF((SELECT LEFT(name,3) FROM trackers strk WHERE strk.id = a.tracker_id) = 'RDM','RDM',s.name), 'Projeto') situacao,
      		COUNT(a.id) qtde
      	FROM issues a INNER JOIN users u ON a.assigned_to_id = u.id
      		INNER JOIN issue_statuses s ON a.status_id = s.id
      	WHERE  a.status_id NOT IN (3,5,12)
      		AND  u.id IN (SELECT user_id FROM groups_users WHERE group_id IN (
            SELECT grp.id FROM users grp INNER JOIN groups_users gpu ON grp.id = gpu.group_id WHERE grp.status = 1 AND grp.type='group' AND gpu.user_id = " . $user_id . "
          ))
      	GROUP BY responsavel, 2
      ) AS t
      GROUP BY t.responsavel WITH ROLLUP";
        $chart = \DB::connection('mysql_redmine')->select($sql);
        $contador = Cronometro::listarContadorEmAberto();
        $status = $conn->issue_status->all();

        return view('home', [
            'contador' => $contador,
            'activities' => $activities,
            'grupos' => $grupos,
            'preferencial'=>$preferencial,
            'chart' => $chart,
            'status' =>$status['issue_statuses'],
        ]);
    }

    /*
    ** Visualiza os Gráficos dos Chamados
    */
    

 public static function verificar_integracao($taskid) {
       
        $sql = 'SELECT * FROM sd_sistemas sd_s inner join sd_interfaces sd_i on sd_s.id = sd_i.id_sistema WHERE sd_s.url_app_cliente IS NOT NULL AND sd_i.id_servicedesk = ' . $taskid . ' AND sd_i.identificador_chamado IS NOT NULL ';
              
        $dados = \DB::connection('mysql_webservice')->select($sql);
       
        return $dados;
}       

    public function tasksChart(Request $request)
    {
        $conn = $this->connectApi();

        $user_id = \Session::get('user')['id'];
        $group = "SELECT grp.id FROM users grp INNER JOIN groups_users gpu ON grp.id = gpu.group_id WHERE grp.status = 1 AND grp.type='group' AND gpu.user_id = " . $user_id;
        if (isset($request->group)) {
            $group = $request->group;
        }

        $sql = " SELECT IFNULL(t.responsavel,'Total') responsavel,
      	SUM(IF(t.situacao='New', t.qtde, 0)) AS 'New',
      	SUM(IF(t.situacao='In Progress', t.qtde, 0)) AS 'InProgress',
      	SUM(IF(t.situacao='Paused', t.qtde, 0)) AS 'Paused',
      	SUM(IF(t.situacao='Feedback', t.qtde, 0)) AS 'Feedback',
      	SUM(IF(t.situacao='Projeto', t.qtde, 0)) AS 'Projeto'
      FROM
      (SELECT concat(u.firstname,' ',u.lastname) responsavel,
      		IF((SELECT value FROM custom_values WHERE custom_field_id = 14 AND customized_id = a.project_id) = 'Suporte e Monitoramento',
      		IF((SELECT LEFT(name,3) FROM trackers strk WHERE strk.id = a.tracker_id) = 'RDM','RDM',s.name), 'Projeto') situacao,
      		COUNT(a.id) qtde
      	FROM issues a INNER JOIN users u ON a.assigned_to_id = u.id
      		INNER JOIN issue_statuses s ON a.status_id = s.id
      	WHERE  a.status_id NOT IN (3,5,12)
      		AND  u.id IN (SELECT user_id FROM groups_users WHERE group_id IN (" . $group . "))
      	GROUP BY responsavel, 2
      ) AS t
      GROUP BY t.responsavel WITH ROLLUP";
        //dd($sql);
        $chart = \DB::connection('mysql_redmine')->select($sql);

        return view('taskschart', [
            'chart' => $chart,
            'total' => end($chart),
        ])->render();
    }

    /*
    ** Visualiza a Tela de Mudança de Status
    */
    public function changeViewTask(Request $request)
    {
        $conn = $this->connectApi();

        $projectid = $request->projectid;
        $task = $conn->issue->show($request->taskid)['issue'];
        $activities = $conn->time_entry_activity->all();
        $times = $conn->time_entry->all(
            [
                'project_id' => $projectid,
            ]
        );

        $dados = [];
        if (isset($times['time_entries'])) {
            foreach ($times['time_entries'] as $time) {
                if (isset($time['issue'])) {
                    $issue_id = $time['issue']['id'];
                    if ($issue_id == $request->taskid) $dados[] = $time;
                }
            }
        }

        return view('changeviewtask', [
            'task' => $task,
            'statusid' => $request->statusid,
            'status' => $request->status,
            'times' => $dados,
            'activities' => $activities['time_entry_activities'],
        ])->render();
    }

    /*
    ** Visualiza a Tela de Edição do Chamado, Apontamentos e Histórico
    */
    public function taskDetail(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $task = $conn->issue->show($request->taskid, [
                'include' => [
                    'attachments'
                ]
            ])['issue'];

            $projectid = $task['project']['id'];
            if ($request->projectid != '') $projectid = $request->projectid;

            $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = ' . $projectid . '  ORDER BY tra.name';
            $trackers = \DB::connection('mysql_redmine')->select($sql);

            $status = $conn->issue_status->all();
            $priorities = $conn->issue_priority->all();
            $custom_fields = $conn->custom_fields->all();

            $times = $conn->time_entry->all(
                [
                    'project_id' => $projectid,
                ]
            );

            $dados = [];
            if (isset($times['time_entries'])) {
                foreach ($times['time_entries'] as $time) {
                    if (isset($time['issue'])) {
                        $issue_id = $time['issue']['id'];
                        if ($issue_id == $request->taskid) $dados[] = $time;
                    }
                }
            }

            $files = [];
            if (isset($task['attachments'])) {
                $files = $task['attachments'];
            }

            $activities = $conn->time_entry_activity->all();
            $journals = $this->journalsTaskMysql($request->taskid);

            return view('taskdetail', [
                'task' => $task,
                'times' => $dados,
                'trackers' => $trackers,
                'status' => $status['issue_statuses'],
                'activities' => $activities['time_entry_activities'],
                'priorities' => $priorities['issue_priorities'],
                'custom_fields' => $custom_fields['custom_fields'],
                'journals' => $journals,
                'files' => $files,
            ])->render();
        }
    }


    /*
    ** Visualiza a Tela de Edição do Chamado, Apontamentos e Histórico em uma Nova janela
    */
    public function taskReport(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();
            $user_id = \Session::get('user')['id'];
            $taskid = $request->taskid;

            $task = $conn->issue->show($taskid, [
                'include' => [
                    'attachments'
                ]
            ])['issue'];
            // dd($task);
            $projectid = 0;
            if (isset($task['project']['id'])) $projectid = $task['project']['id'];
            if ($request->projectid != '') $projectid = $request->projectid;

            $autor = 0;
            if (isset($task['author']['id'])) $autor = $task['author']['id'];
            $contato = [];
            $sql = 'SELECT aut.id, aut.login, concat(aut.firstname, " ", aut.lastname) nome_contato, mail.address email, cv.value telefone FROM users aut
                  LEFT OUTER JOIN email_addresses mail ON mail.user_id = aut.id
                  LEFT OUTER JOIN custom_values cv ON cv.customized_id = aut.id
                    AND cv.customized_type = "Principal"
                    AND custom_field_id = 16
                WHERE aut.id = ' . $autor;
            $contato = \DB::connection('mysql_redmine')->select($sql);

            $trackers = [];
            $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = ' . $projectid . '  ORDER BY tra.name';
            $trackers = \DB::connection('mysql_redmine')->select($sql);

            //seleciona as novas situações de acordo com a situação atual do chamado e pela permissão do usuário
            $sql = "SELECT DISTINCT inew.id, inew.name
                FROM workflows w
                INNER JOIN issues i ON w.tracker_id = i.tracker_id
                INNER JOIN issue_statuses inew ON inew.id = w.new_status_id
                INNER JOIN (
                SELECT mr.role_id FROM members mb
                INNER JOIN member_roles mr ON mb.id = mr.member_id
                WHERE mb.user_id = " . $user_id . "
                ) grp ON w.role_id = grp.role_id
                WHERE w.type = 'WorkflowTransition'
                	AND w.old_status_id=i.status_id
                	AND i.id=" . $taskid;
            $novasituacao = \DB::connection('mysql_redmine')->select($sql);

            $status = $conn->issue_status->all();
            $priorities = $conn->issue_priority->all();
            //$custom_fields = $conn->custom_fields->all();
            $sql = "SELECT * FROM custom_fields cf";
            $custom_fields = \DB::connection('mysql_redmine')->select($sql);

            $times = $conn->time_entry->all(
                [
                    'project_id' => $projectid,
                ]
            );

            $dados = [];
            if (isset($times['time_entries'])) {
                foreach ($times['time_entries'] as $time) {
                    if (isset($time['issue'])) {
                        $issue_id = $time['issue']['id'];
                        if ($issue_id == $request->taskid) $dados[] = $time;
                    }
                }
            }

            $files = [];
            if (isset($task['attachments'])) {
                $files = $task['attachments'];
            }

            $activities = $conn->time_entry_activity->all();
            $journals = $this->journalsTaskMysql($request->taskid);

            
            $usuarios = 'SELECT * FROM (SELECT DISTINCT u.id, CONCAT(u.firstname," ",u.lastname) nome
            FROM users u
            inner join members m on m.user_id = u.id
            inner join projects pj on pj.id = m.project_id
            inner join member_roles mr on mr.member_id = m.id
            inner join roles r on r.id = mr.role_id
            where pj.id = '.$projectid.' and u.status <> 3 and r.assignable = true and u.type <> "Group" order by nome asc) analistas';
            $usuarios = \DB::connection('mysql_redmine')->select($usuarios);     
    
    
            $grupos = 'SELECT * FROM (SELECT DISTINCT u.id, concat(u.firstname,"",u.lastname) nome 
            FROM users u
            inner join members m on m.user_id = u.id
            inner join projects pj on pj.id = m.project_id
            inner join member_roles mr on mr.member_id = m.id
            inner join roles r on r.id = mr.role_id
            where pj.id = '.$projectid.' and u.status <> 3 and r.assignable = true and u.type = "Group" order by nome asc) grupos';
            $grupos = \DB::connection('mysql_redmine')->select($grupos);
            
            $option = '<option value=""></option>';
            $option_group = '';
            $assignedtoid = 0;
    
                if (isset($task['assigned_to'])) $assignedtoid = (int)$task['assigned_to']['id'];
                foreach ($usuarios as $users) {
                    $optionselected = '';
                    if ($assignedtoid == $users->id) $optionselected = ' selected="selected"';
                    $option .= '<option value="' . $users->id . '"' . $optionselected . '>' . $users->nome . '</option>';
                }
           
    
                foreach ($grupos as $groups) {
                    $optionselected = '';
                     if ($assignedtoid == $groups->id) $optionselected = ' selected="selected"';
                    $option_group .= '<option value="' . $groups->id . '"' . $optionselected . '>' . $groups->nome . '</option>';
                }
    
                $option .= '<optgroup label="Grupos">' . $option_group . '</optgroup>';
    
                $transferirpara = '<select name="" id="transferir_para" class="form-control input-sm" data-projectid="' . $projectid . '"  placeholder="" style="width: 100%
                ;">' . $option . '</select>';

    

            $contador = Cronometro::listarContadorEmAberto();
            $sla_p = '';
            $sla_s = '';
            $dt_primeiro = '';
            $dt_solucao = '';
            $created = '';
            $closed = '';
            $resposta = '';



            $statusid = $task['status']['id'];
            //informações da tabela espiration_sla
            $sql = 'SELECT nome_calendario, DATE_FORMAT(i.created_on,"%d/%m/%y %H:%i") created, s.resultado_sla_resposta,
            s.resultado_sla_solucao,
            s.sla_resposta as s_resposta,
            s.sla_solucao as s_solucao,
            s.dt_vencimento_resposta as resposta,
            if(s.dt_vencimento_resposta < dt_atendimento_resposta,"", TIMEDIFF(s.dt_vencimento_resposta,NOW())) horas_p,
            DATE_FORMAT(s.dt_vencimento_resposta,"%d/%m/%y %H:%i") dt_primeiro, 
            if(i.status_id in (SELECT id FROM redmine_sla.aux_status WHERE is_sla = 0 AND is_closed = 0), IFNULL((SELECT redmine_sla.fct_simular_vencimento(i.id)),s.dt_vencimento_solucao),s.dt_vencimento_solucao) as solucao,
             if((select solucao) < dt_atendimento_solucao,"", TIMEDIFF((select solucao),NOW())) horas_s, 
             DATE_FORMAT((select solucao),"%d/%m/%y %H:%i") dt_solucao,
             DATE_FORMAT(s.dt_atendimento_resposta, "%d/%m/%y %H:%i") rt_resposta,
             DATE_FORMAT(s.dt_atendimento_solucao, "%d/%m/%y %H:%i") rt_solucao
            FROM redmine_sla.expiration_sla s 
            inner join redmine.issues i ON s.issue_id = i.id 
            INNER JOIN redmine_sla.calendars c ON s.calendar_solucao = c.id_calendario
            AND i.id =  '.$taskid.'';
            
            
            $registro = \DB::connection('mysql_redmine_sla')->select($sql);
            
            $dt_expirado = '<div class="sla" style="display:none">01/01/5100 00:00:00</div>';
            
            if($registro != null) {   
            foreach ($registro as $registros) {
            
            
            $sla_p = $registros->s_resposta.' '.'h/'.$registros->nome_calendario;
            $sla_s = $registros->s_solucao.' '.'h/'.$registros->nome_calendario;
            $resposta = $registros->rt_resposta;
            $closed = $registros->rt_solucao;
            $created = $registros->created;
            $now = Carbon::now();

            
            if($registros->resultado_sla_resposta == 1 && $resposta) {
                $dt_primeiro =  '<spa class="text-light-blue">'.$registros->dt_primeiro.'</span> <span class = "label label-danger">Vencido</span>';
            }
            elseif(!$resposta && $registros->resposta <= $now){
                $dt_primeiro =  '<spa class="text-light-blue">'.$registros->dt_primeiro.'</span> <span class = "label label-danger">Vencido</span>';
            }
            elseif((!$resposta) && ($registros->horas_p <='01:01:00') && ($registros->horas_p != '')){
                $dt_primeiro =  '<spa class="text-light-blue">'.$registros->dt_primeiro.'</span> <span class = "label label-warning">Perto de vencer</span>';
            }
            else{
                $dt_primeiro ='<spa class="text-light-blue">'.$registros->dt_primeiro.'</span> <span class = "label label-success">No prazo</span>';
            }

            if($registros->resultado_sla_solucao == 1 && $closed){
                $dt_solucao =  '<spa class="text-light-blue">'.$registros->dt_solucao.'</span> <span class = "label label-danger">Vencido</span>';
            }
            elseif(!$closed && $registros->solucao <= $now){
                $dt_solucao =  '<spa class="text-light-blue">'.$registros->dt_solucao.'</span> <span class = "label label-danger">Vencido</span>';

            }
            elseif((!$closed) && ($registros->horas_s <='01:01:00') && ($registros->horas_s != '')){
                $dt_solucao =  '<spa class="text-light-blue">'.$registros->dt_solucao.'</span> <span class = "label label-warning">Perto de vencer</span>';
            }
            else{
                $dt_solucao ='<spa class="text-light-blue">'.$registros->dt_solucao.'</span> <span class = "label label-success">No prazo</span>';
            }
        }
        }
        //pegar o inicio do atendimento quando não tiver SLA
            $atendimento_resposta = 'SELECT DATE_FORMAT(created_on,"%d/%m/%y %H:%i") created_on from redmine.journals j inner join redmine.journal_details jd on j.id = jd.journal_id 
            where jd.prop_key = "status_id" and j.journalized_id = '.$taskid.' order by j.id asc limit 1';
            
            $atendimento_resposta = \DB::connection('mysql_redmine')->select($atendimento_resposta);

            foreach($atendimento_resposta as $atendimento){
                if(!$resposta){
                    $resposta = $atendimento->created_on;
                }
            }

        
            //capturar chamado no chamado
            $fila = '';
             $capturar_chamado = $this->ordernarfila($taskid);
             if(!$capturar_chamado){
                if(isset($task['assigned_to'])) $fila = $task['assigned_to']['id'];    
                $capturar_chamado = '<button type="button" id="capturar-nochamado" data-rowid="" data-taskid="' . $taskid. '" data-fila="'.$fila.'" class="btn btn-sm btn-success"><i class="fa fa-share-square-o"></i> Capturar Chamado</button>';
                    
            }
            //verificar se o chamado foi reaberto

            $sql ='SELECT sum(fechado) reaberto
            FROM (select if(jd.old_value in (select id from issue_statuses where is_closed = true),1,0) fechado
            from journal_details jd
            WHERE jd.prop_key = "status_id"
            and jd.journal_id in (select id from journals where journalized_id = '.$taskid.')) r';
            
            $reopen = \DB::connection('mysql_redmine')->select($sql);

            $open = '';
            foreach($reopen as $r){
            if($r->reaberto != null && $r->reaberto != 0){
                $open = '<label style="color:red;">ATENÇÃO: Chamado REABERTO!</label>';
            }
             }

             //verificar grupo do projeto

             $sql = 'SELECT grupo FROM redmine_cliente.aux_projects WHERE project_id = '.$projectid.'';
             $grupoP = \DB::connection('mysql_redmine')->select($sql);

             $grupo = '';
             if($grupoP){
                 foreach($grupoP as $g){
                     $grupo = ' - Grupo '.$g->grupo;
                 }
             }
        
            return view('taskreport', [
                'dt_p' => $dt_primeiro,
                'dt_s' => $dt_solucao,
                'sla_p' => $sla_p,
                'sla_s' => $sla_s,
                'task' => $task,
                'times' => $dados,
                'trackers' => $trackers,
                'status' => $status['issue_statuses'],
                'activities' => $activities['time_entry_activities'],
                'priorities' => $priorities['issue_priorities'],
                'custom_fields' => $custom_fields,
                'journals' => $journals,
                'files' => $files,
                'capturar' => $capturar_chamado,
                'novasituacao' => $novasituacao,
                'transferirpara' => $transferirpara,
                'contato' => $contato,
                'contador' => $contador,
                'open' => $open,
                'grupo' => $grupo,
                'created' =>$created,
                'solucao' => $closed,
                'resposta' => $resposta,
            ])->render();
        }
    }

    public function anexosbrk(Request $request){
        if($request){
            
            $html = '<p><label><span class="text-red">Anexos BRK</span></label></p>';

            $identificador = $this->verificar_integracao($request->taskid);

            if($identificador){
            foreach($identificador as $ident){}

            $curl = curl_init();

            curl_setopt_array($curl, array(
            CURLOPT_URL => env('WEB_SERVICE') . 'web_interfaces/anexos/' .  $ident->identificador_chamado,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30000,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "GET",
            CURLOPT_HTTPHEADER => array(
            // Set here requred headers
            "accept: */*",
            "accept-language: en-US,en;q=0.8",
            "content-type: application/json",
            ),
            ));
            
            $responses = curl_exec($curl);
            $err = curl_error($curl);
            
            curl_close($curl);

            $rowid = 0;
          
            $objs = json_decode($responses);
            
           $i = 0;
           if($objs){
           foreach ($objs as $obj){
               do{
                   $html .= ' 
                   <div class="col-md-2">
                   <div class="form-group"> 
                   <label>Autor: </label> '.$obj[$i]->sys_created_by.'
                   </div>
                   </div>
                   <div class="col-md-2">
                   <div class="form-group"> 
                   <label>Data: </label>'.date_format(date_create($obj[$i]->sys_created_on), 'd/m/Y H:i').'                 
                   </div>
                   </div>
                   <div class="col-md-8">
                   <div class="form-group"> 
                   <label>Download: <span> <a data-timeid = "'.$i.'"id="brk-anexo" href="'.$obj[$i]->download_link.'">'. $obj[$i]->file_name.'</a></span></label>
                   </div>
                   </div>';
               $i++;
               } while (isset($obj[$i]->download_link));
           }
           }
           else{
               $html = 'Nenhum anexo encontrado!';
           }
           }
           else{
               $html = 'Chamado não faz parte da Integração BRK!';
           }

           return $html;
        }
    }
//
    public function ordernarfila($taskid){

        $user_id = \Session::get('user')['id'];

        $sql = 'SELECT CONCAT(if(se.value in (1,2,3,4,5), se.value,6),
            if(a.status_id = 1,isla.dt_vencimento_resposta, isla.dt_vencimento_solucao)) dtnumber,
            if(a.status_id = 1,isla.dt_vencimento_resposta, isla.dt_vencimento_solucao) venc,
            if((select venc) < NOW(),"", TIMEDIFF((select venc),NOW()))horas,
            DATE_FORMAT((select venc),"%d/%m/%Y %H:%i:%s") dt,
              DATE_FORMAT(a.created_on,"%d/%m/%Y %H:%i:%s") dtchamado,
                  a.id cdchamado,
                  b.id cdprojeto,
              SUBSTRING(a.subject,1,300) dschamado,
                  LEFT(b.name,4) cliente,
              s.name situacao,
              IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM EQUIPE") equipe,
              u.id idequipe
          FROM redmine.issues a
          LEFT JOIN redmine_sla.expiration_sla isla ON isla.issue_id = a.id 
              INNER JOIN redmine.projects b ON a.project_id = b.id
                  INNER JOIN redmine.issue_statuses s ON a.status_id = s.id
                left JOIN redmine.users u ON a.assigned_to_id = u.id
              INNER JOIN redmine.custom_values cv ON cv.customized_id = b.id AND cv.customized_type = "Project" AND cv.custom_field_id = 14
              LEFT JOIN  (select convert(value, int) value, customized_id id from redmine.custom_values where custom_field_id = 28 and customized_type = "Issue")se 
              on se.id = a.id
          WHERE a.status_id NOT IN (3,5,15,16,18)
              AND cv.value in ("Suporte e Monitoramento", "Projeto aberto - Com fila") 
              AND (u.id IN(SELECT group_id FROM redmine.groups_users WHERE user_id = ' . $user_id . ')) 
               order by case when dtnumber is null then 1 else 0 end, dtnumber';

               $fila = \DB::connection('mysql_redmine')->select($sql);

               $rowid = 1;
                $html = '';
               foreach($fila as $fila){

                if($taskid == $fila->cdchamado){
                    $html =  '<button type="button" " id="capturar-nochamado" data-rowid="' . $rowid . '" data-taskid="' . $fila->cdchamado . '" data-fila="'.$fila->idequipe.'" class="btn btn-sm btn-success"><i class="fa fa-share-square-o"></i> Capturar Chamado</button>';
                }
               
                $rowid++;

               }

               return $html;

    }
    /*
    ** Funções que Retorna os Custom Fields Obrigatórios para o Novo Status
    */
    public function customFields(Request $request)
    {
        $user_id = \Session::get('user')['id'];
        //\Session::set('user')['id'] = 476;
        //$user_id = 476;
        $taskid = $request->taskid;
        $statusid = $request->statusid;
        // if($request->newstatus==1)
        //   $statusid = $request->newstatus;

        $conn = $this->connectApi();
        $task = $conn->issue->show($taskid)['issue'];
        $cf = [];
        if (isset($task['custom_fields'])) $cf = $task['custom_fields'];
        $cf_ids = implode(',', array_column($cf, 'id'));
        $projectid = $task['project']['id'];

        $sql = "SELECT cf.id, cf.name, cf.field_format, cf.is_required, cf.possible_values, cv.value valor
          from custom_values cv
          inner join issues i on cv.customized_id = i.id
          inner join custom_fields cf on cf.id=cv.custom_field_id
          left join custom_fields_projects cfp ON cf.id=cfp.custom_field_id and cfp.project_id = i.project_id
          left join custom_fields_roles cfr on cfr.custom_field_id = cf.id
          where cv.customized_id = " . $taskid . "  and cf.type = 'IssueCustomField' and (cfr.role_id in (SELECT role_id FROM member_roles
          WHERE member_id IN (SELECT id FROM members WHERE user_id = " . $user_id . ")) or cfr.role_id is null)";
        $campos = \DB::connection('mysql_redmine')->select($sql);


        $regras = [];
        $sql_regras = "SELECT cf.id, w.rule
          FROM workflows w
          	INNER JOIN issues i ON w.tracker_id = i.tracker_id
          	LEFT JOIN custom_fields cf ON cf.id = w.field_name
          WHERE w.type = 'WorkflowPermission' AND i.id = " . $taskid . "
          	AND w.old_status_id = " . $statusid . "
          	AND w.role_id IN (SELECT role_id FROM member_roles
          WHERE member_id IN (SELECT id FROM members WHERE user_id = " . $user_id . "))
          GROUP BY id, rule";
        $regras = \DB::connection('mysql_redmine')->select($sql_regras);
        $regras = array_column($regras, 'rule', 'id');
        //dd($regras);

        $html = '';
        $apontamento = '';
        $conteudo = '';
        foreach ($campos as $key => $value) {
            $required = '';
            $readonly = '';
            $is_required = '';

            if ($value->is_required == 1) {
                $required = 'issue_required';
                $is_required = ' <span class="text-red">*</span>';
            }

            //var_dump($regras, $value->id, array_key_exists($value->id, $regras));
            if (array_key_exists($value->id, $regras)) {
                if ($regras[$value->id] == "readonly") {
                    $readonly = 'readonly';
                }
                if ($regras[$value->id] == "required") {
                    $readonly = '';
                    $required = 'issue_required';
                    $is_required = ' <span class="text-red">*</span>';
                }
            }
            $conteudo = $value->valor;

            $tam = 3;
            if ($value->field_format == "text") $tam = 12;
            $html .= '<div class="col-md-' . $tam . '">' .
                '<div class="form-group" id="help_cf_' . $value->id . '_' . $taskid . '" >' .
                '<label for="title">' . $value->name . ' [' . $value->id . ']' . $is_required . '</label>';

            switch ($value->field_format) {
                case 'string':
             
                    if($value->id == 30 || $value->id == 31){
                    $html .= '<input type="text" class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->id . '_' . $taskid . '" id="cf_' . $value->id . '_' . $taskid . '" value="' . $conteudo . '" placeholder="AAAA-MM-DD HH:mm">';
                    }
                    else if($value->id == 21 || $value->id == 22){
                        $html .= '<input type="text" class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->id . '_' . $taskid . '" id="cf_' . $value->id . '_' . $taskid . '" value="' . $conteudo . '" placeholder="AAAA-MM-DD">';
                    }
                    else{
                        $html .= '<input type="text" class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->id . '_' . $taskid . '" id="cf_' . $value->id . '_' . $taskid . '" value="' . $conteudo . '">';
                    }
                    break;
                    $html .= '<input type="hidden" class="form-control input-sm" value="'.$conteudo.'" id="input_cf_' . $value->id . '_' . $taskid . '">';

                case 'attachment':

                   $customV = 'SELECT at.id id, at.filename name, at.content_type type FROM attachments at 
                   INNER JOIN custom_values cv ON cv.value = at.id AND cv.customized_id = ' . $taskid . '
                   AND cv.custom_field_id = 29 AND cv.customized_type = "Issue"';
                    $customizados = \DB::connection('mysql_redmine')->select($customV);

                    foreach ($customizados as $customizado) {
                        

                    $html .= '</br><a href="/viewanexo/'. $customizado->id .'" target="_blank"> <i class="fa fa-paperclip"></i>' . $customizado->name . '</a>
                    <a class="btn btn-xs btn-primary btn-flat" href="/downanexo/' . $customizado->id .'" target="_blank" style="border-radius: 3px;" download="' . $customizado->name . '"><i class="fa fa-download"></i> Download</a>';
                    // $html .= '<input class="form-control input-sm" multiple="multiple" enctype= "multipart/form-data" type="file" name="customUpload[]" id="customUpload" />
                    // <button class="btn btn-primary btn-sm btnEnviar" enctype= "multipart/form-data" type="button" name="btnEnviarCustom" id="btnEnviarCustom"><i class="fa fa-paper-plane" aria-hidden="true"></i> Enviar </button>
                    // ';
                    }
                break;
                case 'bool':
                    if ($conteudo == 1) {
                        $opt = '<option value="0">Não</option>';
                        $opt .= '<option value="1" selected>Sim</option>';
                    } else {
                        $opt = '<option value="0" selected>Não</option>';
                        $opt .= '<option value="1">Sim</option>';
                    }
                    $html .= '<select class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->id . '_' . $taskid . '" id="cf_' . $value->id . '_' . $taskid . '">' . $opt . '</select>';
                    break;
                case 'text':
                   
                    $html .= '<textarea rows="4" class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->id . '_' . $taskid . '" id="cf_' . $value->id . '_' . $taskid . '">' . $conteudo . '</textarea>';
                    $html .= '<input type="hidden" class="form-control input-sm" value="'.$conteudo.'" id="input_cf_' . $value->id . '_' . $taskid . '">';
                  
                break;
                case 'list':
                    $html .= '<select class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->id . '_' . $taskid . '" id="cf_' . $value->id . '_' . $taskid . '">';
                    if ($value->possible_values) {
                        $possible_values = preg_replace("/\r|\n/", "|", $value->possible_values);
                        $opt = explode('|', $possible_values);
                        $options = '';
                        foreach ($opt as $op) {
                            $selected = '';
                            $op = str_replace('- ', '', $op);
                            $op = str_replace("'", "", $op);
                            if (str_replace("'", "", $conteudo) == $op) $selected = 'selected="selected"';
                            $options .= '<option value="' . $op . '" ' . $selected . '>' . $op . '</option>';
                        }
                        $html .= $options;
                    } else {
                        $html .= '<option value=""></option>';
                    }
                    $html .= '</select>';
                    break;
            }
            $html .= '</div>' .
                '</div>';
        }

        //apontamento obrigatório [26]
        if (array_key_exists(26, $regras)) {
            $apontamento = '<div class="row">' .
                '<div class="col-md-12">' .
                '<h4 class="h4">Apontamentos</h4>' .
                '<input type="hidden" class="form-control input-sm" name="cf_26_' . $taskid . '" id="cf_26_' . $taskid . '" value="1">' .
                '</div>' .
                '</div>';
        }

        return $html . $apontamento;

    }


    /*
    status
    id = 1 - name: New
    id = 2 - name: In Progress
    id = 3 - name: Resolved
    id = 5 - name: Closed
    id = 7 - name: Feedback
    id = 8 - name: Paused
    */

    /*
    ** Função que Conecta no Redmine REST API
    ** Passa o API_KEY do usuário logado
    */
    public static function connectApi()
    {
        $url = env('SD_URL');
        $apiKey = \Session::get('user')['api_key'];
        $conn = new Client($url, $apiKey);

        return $conn;
    }

    

    /*
    ** SLAs
    */
    public function listSla()
    {
        $sla = [
            ['priority_id' => 1, 'priority_name' => 'Low', 'issue_sla' => 60.0],
            ['priority_id' => 2, 'priority_name' => 'Normal', 'issue_sla' => 32.0],
            ['priority_id' => 3, 'priority_name' => 'High', 'issue_sla' => 4.0],
            ['priority_id' => 4, 'priority_name' => 'Urgent', 'issue_sla' => 2.0],
            ['priority_id' => 5, 'priority_name' => 'Immediate', 'issue_sla' => 1.0]
        ];
        return $sla;
    }

    /*
    ** Funções do Painel Meus Grupos
    */
    public static function myGroupsMysql()
    {
        $user_id = \Session::get('user')['id'];
        //$user_id = 476;
        $sql = 'SELECT grp.id, grp.lastname descricao FROM users grp INNER JOIN groups_users gpu ON grp.id = gpu.group_id WHERE grp.status = 1 AND grp.type="group" AND  grp.lastname like "%Fila%" AND gpu.user_id = ' . $user_id . ' ORDER BY grp.lastname';
        $grupos = \DB::connection('mysql_redmine')->select($sql);

        return $grupos;

    }
    public function myFila()
    {
        $user_id = \Session::get('user')['id'];
        //$user_id = 476;
        $sql = 'SELECT u.id,u.lastname descricao FROM custom_values cv INNER JOIN users u ON  u.lastname = cv.value
        WHERE cv.customized_type = "Principal" AND cv.custom_field_id=31 AND cv.customized_id = '. $user_id.'';
        $preferencial = \DB::connection('mysql_redmine')->select($sql);

        return $preferencial;

    }

    /*
    ** Funções do Painel Meus Grupos
    */
    public function pesquisar(Request $request)
    {
        $param = '';
        if (isset($request->param)){
         $param = $request->param;

        $sql = ' SELECT isu.id, isu.subject, isu.description ' .
            ' FROM issues isu ' .
            ' WHERE isu.id LIKE "' . $param . '%" OR isu.subject LIKE "%' . $param . '%" OR description LIKE "%' . $param . '%" ' .
            ' ORDER BY isu.id DESC LIMIT 10 ';
        $pesquisa = \DB::connection('mysql_redmine')->select($sql);

        return $pesquisa;
        }
    }

    /*
    ** Função para checar mesmo horário
    */
    public function checarHorario(Request $request)
    {
        $usuario = \Session::get('user')['id'];
        $data = $request->data;
        $entrada = $request->hora_entrada;
        $saida = $request->hora_saida;

        $sql = ' SELECT tim.id, tim.issue_id, DATE_FORMAT(tim.spent_on,"%d/%m/%Y") spent_on, tim.hours, ' .
            ' STR_TO_DATE(entrada.value,"%H:%i") hora_entrada, ' .
            ' STR_TO_DATE(saida.value,"%H:%i") hora_saida ' .
            ' FROM time_entries tim  ' .
            ' INNER JOIN ( ' .
            ' SELECT customized_id, value FROM custom_values ' .
            ' WHERE custom_field_id = 1 ' .
            ' ) entrada ON tim.id = entrada.customized_id ' .
            ' INNER JOIN ( ' .
            ' SELECT customized_id, value FROM custom_values ' .
            ' WHERE custom_field_id = 4 ' .
            ' ) saida ON tim.id = saida.customized_id ' .
            ' WHERE tim.user_id = ' . $usuario . ' AND DATE_FORMAT(tim.spent_on,"%d/%m/%Y") = "' . $data . '" AND ' .
            ' (STR_TO_DATE("' . $entrada . '","%H:%i:%s")  BETWEEN STR_TO_DATE(entrada.value,"%H:%i:%s") AND DATE_ADD(STR_TO_DATE(saida.value,"%H:%i:%s"), INTERVAL -1 MINUTE) OR ' .
            ' STR_TO_DATE(entrada.value,"%H:%i:%s")  BETWEEN STR_TO_DATE("' . $entrada . '","%H:%i:%s") AND STR_TO_DATE("' . $saida . '","%H:%i:%s") OR ' .
            ' STR_TO_DATE(saida.value,"%H:%i:%s")  BETWEEN DATE_ADD(STR_TO_DATE("' . $entrada . '","%H:%i:%s"), INTERVAL 1 MINUTE) AND STR_TO_DATE("' . $saida . '","%H:%i:%s") OR ' .
            ' STR_TO_DATE("' . $saida . '","%H:%i:%s")  BETWEEN STR_TO_DATE(entrada.value,"%H:%i:%s") AND STR_TO_DATE(saida.value,"%H:%i:%s"))';
        //var_dump($sql);
        $dados = \DB::connection('mysql_redmine')->select($sql);

        return $dados;

    }


    /*
    ** Funções do Painel Meus Grupos
    */
    public function journalsTaskMysql($taskid)
    {
        $user_id = \Session::get('user')['id'];
        ////$user_id = 476;
        $sql = 'SELECT jou.id,
        	CONCAT("Atualizado por <strong>", usr.firstname, " ",usr.lastname, "</strong> há <strong>", DATE_FORMAT(jou.created_on, "%d/%m/%Y %H:%i:%s"), "</strong>") atualizado_por,
        	(CASE jdt.property
        		WHEN "attr" THEN
        			CASE jdt.prop_key
        			WHEN "due_date" THEN CONCAT("<strong>Data prevista</strong> ajustado para <strong>", DATE_FORMAT(jdt.value, "%d/%m/%Y"),"</strong>")
        			WHEN "status_id" THEN
        				IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)=0,
        					CONCAT("<strong>Situação</strong> alterado para <strong>", (SELECT name FROM issue_statuses WHERE id = jdt.value), "</strong>"),
        					IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)>0,
        						CONCAT("<strong>Situação</strong> alterado de <strong>", (SELECT name FROM issue_statuses WHERE id = jdt.old_value), "</strong> para <strong>", (SELECT name FROM issue_statuses WHERE id = jdt.value), "</strong>"),
        						CONCAT("<strong>Situação</strong> alterado para <strong>", (SELECT name FROM issue_statuses WHERE id = jdt.value), "</strong>")
        					)
        				)
        			WHEN "assigned_to_id" THEN
        				IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)=0,
        					CONCAT("<strong>Atribuído para</strong> excluído (<strong>", IFNULL((SELECT CONCAT(firstname, " ", lastname) FROM users WHERE id = jdt.old_value),""), "</strong>)"),
        					IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)>0,
        						CONCAT("<strong>Atribuído para</strong> alterado de <strong>", IFNULL((SELECT CONCAT(firstname, " ", lastname) FROM users WHERE id = jdt.old_value),""), "</strong> para <strong>", IFNULL((SELECT CONCAT(firstname, " ", lastname) FROM users WHERE id = jdt.value), ""), "</strong>"),
        						CONCAT("<strong>Atribuído para</strong> ajustado para <strong>", IFNULL((SELECT CONCAT(firstname, " ", lastname) FROM users WHERE id = jdt.value),""), "</strong>")
        					)
        				)
        			WHEN "done_ratio" THEN CONCAT("<strong>% Terminado</strong> alterado de ", jdt.old_value, " para ", jdt.value)
        			WHEN "subject" THEN CONCAT("<strong>Assunto</strong> atualizado(a) para <strong>", jdt.value, "</strong>")
        			WHEN "description" THEN CONCAT("<strong>Descrição</strong> atualizado(a) para <strong>", jdt.value, "</strong>")
        			WHEN "estimated_hours" THEN CONCAT("<strong>Tempo estimado</strong> ajustado para <strong>", jdt.value, "</strong>")
        			END
        	WHEN "attachment" THEN
        		IF(ISNULL(jdt.value),
      CONCAT("<strong>Arquivo ", jdt.old_value, "</strong> excluido"), CONCAT("<strong> Arquivo ", jdt.value, "</strong> adicionado")
        )
        	ELSE
        		IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)=0,
        			CONCAT("<strong>", (SELECT cf.name FROM custom_fields cf WHERE cf.id = jdt.prop_key), "</strong> excluído (<strong>", jdt.old_value, "</strong>)"),
                	IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)>0,
        			    CONCAT("<strong>", (SELECT cf.name FROM custom_fields cf WHERE cf.id = jdt.prop_key), "</strong> alterado de <strong>", jdt.old_value, "</strong> para <strong>", jdt.value, "</strong>"),
                   		CONCAT("<strong>", (SELECT cf.name FROM custom_fields cf WHERE cf.id = jdt.prop_key), "</strong> ajustado para <strong>", jdt.value, "</strong>")
                	)
        		)
        	END
        	) historico, IF (property = "attachment" AND ISNULL(jdt.old_value), (SELECT 1 FROM attachments WHERE container_id = jou.journalized_id AND container_type = "Issue" AND id = jdt.prop_key ), NULL ) AS btdowload,

        	jou.notes, jdt.property, jdt.prop_key, jdt.old_value, jdt.value
            FROM journals jou
        	LEFT OUTER JOIN journal_details jdt ON jou.id = jdt.journal_id
        	INNER JOIN users usr ON jou.user_id = usr.id
        WHERE jou.journalized_id = ' . $taskid . '
        ORDER BY jou.id, jou.created_on';

        $journals = \DB::connection('mysql_redmine')->select($sql);
        return $journals;

    }

    /*
    ** Funções do Painel Novos Chamados
    */
    public function newTasksMysql(Request $request)
    {
        if ($request) {
            $user_id = \Session::get('user')['id'];
            // $user_id = 476;
            $group = 'AND (u.id IN(SELECT group_id FROM redmine.groups_users WHERE user_id = ' . $user_id . '))';
            if (isset($request->group)) {
                if($request->group == "null"){
                    $group = 'AND ((a.assigned_to_id is null and a.status_id not in(7,8)) OR (a.status_id = 1 AND u.lastname like "%Fila%"))'; 
                }
                else{
                    $group = ' AND u.id=' . $request->group;
                }
            }

            $sql = 'SELECT CONCAT(if(se.value in (1,2,3,4,5), se.value,6),
            if(a.status_id = 1,isla.dt_vencimento_resposta, isla.dt_vencimento_solucao)) dtnumber,
            if(a.status_id = 1,isla.dt_vencimento_resposta, isla.dt_vencimento_solucao) venc,
            if((select venc) < NOW(),"", TIMEDIFF((select venc),NOW()))horas,
            DATE_FORMAT((select venc),"%d/%m/%Y %H:%i:%s") dt,
              DATE_FORMAT(a.created_on,"%d/%m/%Y %H:%i:%s") dtchamado,
                  a.id cdchamado,
                  b.id cdprojeto,
              SUBSTRING(a.subject,1,300) dschamado,
                  LEFT(b.name,4) cliente,
              s.name situacao,
              IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM EQUIPE") equipe,
              u.id idequipe
          FROM redmine.issues a
          LEFT JOIN redmine_sla.expiration_sla isla ON isla.issue_id = a.id 
              INNER JOIN redmine.projects b ON a.project_id = b.id
                  INNER JOIN redmine.issue_statuses s ON a.status_id = s.id
                left JOIN redmine.users u ON a.assigned_to_id = u.id
              INNER JOIN redmine.custom_values cv ON cv.customized_id = b.id AND cv.customized_type = "Project" AND cv.custom_field_id = 14
              LEFT JOIN  (select convert(value, int) value, customized_id id from redmine.custom_values where custom_field_id = 28 and customized_type = "Issue")se 
              on se.id = a.id
          WHERE a.status_id NOT IN (select id from redmine.issue_statuses where is_closed = true)
              AND cv.value in ("Suporte e Monitoramento", "Projeto aberto - Com fila") 
                ' . $group . ' 
               order by case when dtnumber is null then 1 else 0 end, dtnumber';
            $registros = \DB::connection('mysql_redmine')->select($sql);
            
            

            $rowid = 1;
            $dados = [];
            foreach ($registros as $registro) {
                $desc = '';

                $len = (int)strlen($registro->dschamado);
                $intervals = array(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300);
                foreach ($intervals as $i) {
                    $s = mb_substr($registro->dschamado, $i, 30);
                    if ($s) {
                        if ($desc) $desc .= ' ';
                        $desc .= $s;
                    }
                }
               
                $mytime = Carbon::now();
                if($registro->venc <= $mytime){
                    $registro->dt =  '<div class="sla" style= "color:#dd4b39;font-weight:bold"> '. $registro->dt .' </div>';
                }
                elseif(($registro->horas <='01:01:00') && ($registro->horas != '')){
                    $registro->dt =  '<div class="sla" style= "color:#ffd700;font-weight:bold"> '. $registro->dt .' </div>';
                }
                
                

                $dados[] = [
                    'id' => $rowid,
                    'number' => '<a target="_blank" href="' . \URL::to('/taskreport') . '/' . $registro->cdchamado . '" class="btn btn-default btn-xs" data-taskid="' . $registro->cdchamado . '" data-task="' . $registro->dschamado . '" data-projectid="' . $registro->cdprojeto . '">' . $registro->cdchamado . '</a>',
                    'description' => $desc . '<br /><b>' . $registro->equipe . '</b>',
                    'assigned' => $registro->equipe,
                    'client' => $registro->cliente . '<br /><b>' . $registro->situacao . '</b>',
                    'date' => $registro->dtchamado,
                    'expire'=> $registro->dt,
                    //'capturado' => $registro->equipe,
                    'button' => '<button type="button" "id="capturar' . $rowid . '" data-rowid="' . $rowid . '" data-taskid="' . $registro->cdchamado . '" class="btn btn-xs btn-success capturar"><i class="fa fa-share-square-o"></i> capturar</button>'
                    ];

                $rowid++;
                //$registro->equipe = "";
            }
            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }
    }
    //
    public function captureTask(Request $request) {
        if ($request) {
            $conn = $this->connectApi();
            $userid = \Session::get('user')['id'];
            $taskid = $request->taskid;
            $rowid = $request->rowid;
            $contador = $request->contador;
            $statusid = $request->statusid;
	        $confirm = $request->confirm;
            
            $chamado = $conn->issue->show($taskid)['issue'];
            $projectid = $chamado['project']['id'];
            
            $c_integracao = $this->verificar_integracao($taskid);
            
            if ($c_integracao) {
                
                $token_web = WebServiceController::webService_login();
            
                if ($token_web) {
            
                $resp = WebServiceController::webService_update($token_web, $request, $userid);

                $obj = json_decode($resp);
                
                if (isset($obj->{'result'}) || isset($obj->{'ArticleID'}) || isset($obj->{'TicketID'})) {
                    $resultado = $obj;
            
                    $conn->issue->update($taskid,
                    [
                        'status_id' => $statusid,
                        'assigned_to_id' => $userid
                    ]
                    );
            
                    $conn->issue->setIssueStatus($taskid, 'In Progress');

                    $updateTasks = $conn->issue->show($taskid);

                        if ($contador == 1) {
                        //iniciar o cronometro
                         $contador = new Cronometro;
                         $contador->user_id = $userid;
                         $contador->task_id = $taskid;
                         $contador->started_at = Carbon::now();
                         $contador->save();
                        }
                    $retorno = $taskid;
                    } else {
                        //else resultado cliente
                        $resultado = $resp;
                        $retorno = 1;
                    }
                    
                }else {
                    //else token
                    
                }
                
            }else{
                //else c_integracao
                $conn->issue->update($taskid,
                    [
                        'status_id' => $statusid,
                        'assigned_to_id' => $userid
                    ]
                    );
                $conn->issue->setIssueStatus($taskid, 'In Progress');

                    $updateTasks = $conn->issue->show($taskid);
                    if ($contador == 1) {
                    //iniciar o cronometro
                     $contador = new Cronometro;
                     $contador->user_id = $userid;
                     $contador->task_id = $taskid;
                     $contador->started_at = Carbon::now();
                     $contador->save();
                    }
                    $retorno = $taskid;
                $resultado = "Cliente não possui integração com a EBS-IT!";
            }
            
            $updateTasks = $conn->issue->show($taskid);        
            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->valor = $rowid;

	     if($confirm){
            	$log->acao = 'Captura Dentro do Chamado';
            }
            else{
                $log->acao = 'Captura de Chamado';
            }

            $log->status_integracao = json_encode($resultado, JSON_UNESCAPED_UNICODE);
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();
            $log_id = Log::select('id')
            ->where('analista',\Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'])
            ->orderBy('id', 'DESC')
            ->limit(1)
            ->get();
            
            if($confirm){
                $log = $log_id[0];
                $captura = new Captura;
                $captura->log_id = $log['id'];
                $captura->datahora = Carbon::now();
                $captura->analista = $userid;
                $captura->anterior = $request->fila;
                $captura->justificativa = $request->text;
                $captura->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);  
                $captura->save();
                }

            $return_result = $conn->issue->show($retorno);

            return $return_result;
        }
    }
    /*
    ** Funções do Painel Meus Chamados que lista todos os Chamados para o Analista
    */
    
    public function myTasks(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();
            $userid = \Session::get('user')['id'];
            $newtasksinProgress = $conn->issue->all(
                [
                    'assigned_to_id' => $userid
                ]
            );
            $newtasks = $newtasksinProgress;


            $rowid = 1;
            $dados = array();
            if (isset($newtasks['issues'])) {
                foreach ($newtasks['issues'] as $task) {
                    $taskid = $task['id'];
                    $projectid = $task['project']['id'];
                    $statusid = $task['status']['id'];
                    $statusname = $task['status']['name'];
                    $button = '';
                    switch ($statusid) {
                        case 1: 
                            $status = ' <label class="label label-success">' . $statusname . '</label>';
                            break;
                        case 2:
                            $status = ' <label class="label label-warning">' . $statusname . '</label>';
                            break;
                        case 7: 
                            $status = ' <label class="label label-info">' . $statusname . '</label>';
                            break;
                        case 8: 
                            $status = ' <label class="label label-default">' . $statusname . '</label>';
                            break;
                        case 19: 
                            $status = ' <label class="label label-primary">' . $statusname . '</label>';
                            break;
                        default:
                            $status = ' <label class="label label-success">' . $statusname . '</label>';
                            break;
                    }


                    {
                        $projectname = $task['project']['name'];


                        $data = strtotime($task['created_on']);
                        $hoje = strtotime(date('Y-m-d H:i:s'));
                        $dias = round(floor($hoje - $data) / 3600 / 24, 0);
                        
                        $alerta = ' <span class="label label-warning">' . $dias . '</span>';
                        if ($dias > 3) $alerta = ' <span class="label label-danger">' . $dias . '</span>';


                        $select = '';
                        $desc = '';


                        $len = (int)strlen($task['subject']);
                        $intervals = array(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300);
                        foreach ($intervals as $i) {
                            $s = mb_substr($task['subject'], $i, 30);
                            if ($s) {
                                if ($desc) $desc .= '<br />';
                                $desc .= $s;
                            }
                        }
                        
                        /*$d_atualizacao = DB::table('logs')->where('id_chamado', $taskid)
                        ->orderByDesc('id_chamado')
                        ->limit(1)
                        ->value('datahora');*/
                        
                        $d_at_tempo = strtotime($task['updated_on']);
                        $d_atualizacao = date_format(date_create($task['updated_on']), 'd/m/Y H:i:s');
                        $dias_atualizacao = round(floor($hoje - $d_at_tempo) / 3600 / 24, 0);
                        
                        $data_at = ' <span class="label label-warning">' . $dias_atualizacao . '</span>';
                        if ($dias_atualizacao > 3) $data_at = ' <span class="label label-danger">' . $dias_atualizacao . '</span>';
                        
                        if($statusid == 1){
                            $sql = 'select dt_vencimento_resposta as expira, if(dt_vencimento_resposta < NOW(),"", TIMEDIFF(dt_vencimento_resposta,NOW()))horas, DATE_FORMAT(dt_vencimento_resposta,"%d/%m/%Y %H:%i:%s") dt
                            from redmine_sla.expiration_sla where issue_id = ' . $taskid;
                        }
                        else{
                            $sql = 'select if(i.status_id in (SELECT id FROM redmine_sla.aux_status WHERE is_sla = 0 AND is_closed = 0), IFNULL((SELECT redmine_sla.fct_simular_vencimento(i.id)),s.dt_vencimento_solucao),s.dt_vencimento_solucao) as expira, if((select expira) < NOW(),"", TIMEDIFF((select expira),NOW()))horas, DATE_FORMAT((select expira),"%d/%m/%Y %H:%i:%s") dt from redmine_sla.expiration_sla s inner join redmine.issues i ON s.issue_id = i.id AND s.issue_id = ' . $taskid;
                        }
                        $registro = \DB::connection('mysql_redmine')->select($sql);
                        
                        $dt_expirado = '<div class="sla" style="display:none">01/01/5100 00:00:00</div>';
                        
                        if($registro != null) {   
                        foreach ($registro as $registros) {}
                        $mytime = Carbon::now();
                        
                        $dt_expirado = $registros->expira;
                        
                        if($dt_expirado == ''){
                            $dt_expirado =  '<div class="sla" style="display:none">01/01/5100 00:00:00</div>';
                        }
                        elseif($dt_expirado <= $mytime){
                            $dt_expirado =  '<div class="sla"style= "color:#dd4b39;font-weight:bold;">'.$registros->dt.'</div>';
                        }
                        elseif(($registros->horas <='01:01:00') && ($registros->horas != '')){
                            $dt_expirado =  '<div class="sla" style= "color:#ffd700;font-weight:bold">'.$registros->dt.'</div>';
                        }
                        else{
                            $dt_expirado = $registros->dt;
                        }
                        }


                        $data = date_format(date_create($task['created_on']), 'd/m/Y H:i:s');
                        $dados[] = [
                            'id' => $d_atualizacao . "<br> Dias: " . $data_at,
                            'number' => '<a target="_blank" href="' . \URL::to('/taskreport') . '/' . $taskid . '" class="btn btn-default btn-xs" data-taskid="' . $taskid . '" data-task="' . $task['subject'] . '" data-projectid="' . $task['project']['id'] . '">' . $taskid . '</a>',
                            'description' => $desc . '<br />' . $status,
                            'client' => $projectname . '<br />' . $select,
                            'expire' => $dt_expirado,
                            'status' => $statusid,
                            'button' => $button
                        ];
                        $rowid++;
                    
                    }
                }
            }


            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }
    }

    
    /*
    ** Funções que Edita os campos do Chamado já cadastrado
    */
    public function editTask(Request $request) {
        if ($request) {
            $conn = $this->connectApi();

            $userid = \Session::get('user')['id'];
            $taskid = $request->taskid;

            $tracker = $request->tracker; //required
            $projectid = $request->projectid; //required
            $title = $request->title; //required
            $title = $this->convert_encoding($title, 'UTF-8');
            $description = $request->description;
            $description = $this->convert_encoding($description, 'UTF-8');
            $issue_notes = $request->notes;
            $issue_notes = $this->convert_encoding($issue_notes, 'UTF-8');
            $due_date = $request->due_date;
            $statusid = $request->statusid; //required
            $assignedid = $request->assignedid;
            $priority = $request->priority; //required
            $author_id = $request->author; //required
            $start_date = $request->created_on;
            $done_ratio = $request->done_ratio; //required
            $spent_hours = $request->spent_hours;
            $novasituacao = $request->novasituacao;
            $contador = $request->contador;

            $custom_fields = [];
            for ($i = 1; $i < 55; $i++) {
                $campo = $request['cf_' . $i . '_' . $taskid];
                    if ($campo != 'undefined' && $campo != NULL){
                        // if($campo){
                        // if($i == 21 || $i == 22 ){
                        //     $campo = date_format(date_create_from_format('d/m/Y', $campo),'Y-m-d');      
           
                        // }
                        // if($i == 30 || $i == 31){
                        //     $campo = date_format(date_create_from_format('d/m/Y H:i', $campo),'Y-m-d H:i');      
                        // }
                        //  }
                        $custom_fields[] = ['id' => $i, 'value' => $campo];
                    }
                    }    
            
        
    

            // try {
            $issue_data = [];
            $issue_data['tracker_id'] = $tracker; //required
            $issue_data['project_id'] = $projectid; //required
            $issue_data['subject'] = $title; //required
            $issue_data['description'] = urldecode($description);
            $issue_data['due_date'] = $due_date;
            $issue_data['status_id'] = $statusid; //required
            $issue_data['assigned_to_id'] = $assignedid;
            $issue_data['priority_id'] = $priority; //required
            $issue_data['author_id'] = $author_id; //required
            $issue_data['start_date'] = $start_date;
            $issue_data['done_ratio'] = $done_ratio; //required
            $issue_data['estimated_hours'] = $spent_hours;
            $issue_data['custom_fields'] = $custom_fields;

            if ($issue_notes)
                $issue_data['notes'] = urldecode($issue_notes);

                $c_integracao = $this->verificar_integracao($taskid);

            if ($c_integracao) {

                $token_web = WebServiceController::webService_login();

                if ($token_web) {

                    $resp = WebServiceController::webService_update($token_web, $request);

                    $obj = json_decode($resp);

                    if (isset($obj->{'result'}) || isset($obj->{'ArticleID'}) || isset($obj->{'TicketID'})) {
                        $resultado = $obj;

                        $conn->issue->update($taskid, $issue_data);

                        //somente edição do chamado
                        if ($novasituacao != 0) {

                            //se existir obrigatoriedade de apontamento executar o metodo
                            if ($request->apont == 1) {

                                $dt = $request->spent_on;
                                $dt = explode('/', $dt);
                                $spent_on = $dt[2] . '-' . $dt[1] . '-' . $dt[0];

                                $hours = $request->hours;
                                $atividades = $request->atividades;
                                $activity = $request->activity;
                                $entrada_trabalho = $request->hora_entrada_trabalho;
                                $saida_almoco = $request->hora_saida_almoco;
                                $retorno_almoco = $request->hora_retorno_almoco;
                                $saida_trabalho = $request->hora_saida_trabalho;
                                $tipo_hora = $request->tipo_hora;

                                $custom_fields = [];
                                if ($entrada_trabalho)
                                    $custom_fields[] = ['id' => 1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
                                if ($saida_almoco)
                                    $custom_fields[] = ['id' => 2, 'name' => 'Hora Saída Almoço', 'value' => $saida_almoco];
                                if ($retorno_almoco)
                                    $custom_fields[] = ['id' => 3, 'name' => 'Hora Retorno Almoço', 'value' => $retorno_almoco];
                                if ($saida_trabalho)
                                    $custom_fields[] = ['id' => 4, 'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
                                if ($atividades)
                                    $custom_fields[] = ['id' => 13, 'name' => 'Atividades', 'value' => $atividades];
                                if ($tipo_hora)
                                    $custom_fields[] = ['id' => 17, 'name' => 'Tipo de hora', 'value' => $tipo_hora];

                                $conn->time_entry->create([
                                    'project_id' => $projectid,
                                    'issue_id' => $taskid,
                                    'activity_id' => $activity,
                                    'hours' => $hours,
                                    'spent_on' => $spent_on,
                                    'comments' => $atividades,
                                    'custom_fields' => $custom_fields,
                                ]);

                                $conn->issue->addNoteToIssue($taskid, $atividades);

                                $updateTime = $conn->time_entry->all([
                                    'issue_id' => $taskid,
                                    'project_id' => $projectid,
                                ]);
                            }
                        }

                        if ($contador == 1) {
                            //iniciar o cronometro
                            $contador = new Cronometro;
                            $contador->user_id = $userid;
                            $contador->task_id = $taskid;
                            $contador->started_at = Carbon::now();
                            $contador->save();
                        }
                        $retorno = $taskid;
                    } else {
                        $resultado = $resp;
                        $retorno = 1;
                    }
                } else {
                    
                }
            }else{
                
                $conn->issue->update($taskid, $issue_data);

                        //somente edição do chamado
                        if ($novasituacao != 0) {

                            //se existir obrigatoriedade de apontamento executar o metodo
                            if ($request->apont == 1) {

                                $dt = $request->spent_on;
                                $dt = explode('/', $dt);
                                $spent_on = $dt[2] . '-' . $dt[1] . '-' . $dt[0];

                                $hours = $request->hours;
                                $atividades = $request->atividades;
                                $activity = $request->activity;
                                $entrada_trabalho = $request->hora_entrada_trabalho;
                                $saida_almoco = $request->hora_saida_almoco;
                                $retorno_almoco = $request->hora_retorno_almoco;
                                $saida_trabalho = $request->hora_saida_trabalho;
                                $tipo_hora = $request->tipo_hora;

                                $custom_fields = [];
                                if ($entrada_trabalho)
                                    $custom_fields[] = ['id' => 1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
                                if ($saida_almoco)
                                    $custom_fields[] = ['id' => 2, 'name' => 'Hora Saída Almoço', 'value' => $saida_almoco];
                                if ($retorno_almoco)
                                    $custom_fields[] = ['id' => 3, 'name' => 'Hora Retorno Almoço', 'value' => $retorno_almoco];
                                if ($saida_trabalho)
                                    $custom_fields[] = ['id' => 4, 'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
                                if ($atividades)
                                    $custom_fields[] = ['id' => 13, 'name' => 'Atividades', 'value' => $atividades];
                                if ($tipo_hora)
                                    $custom_fields[] = ['id' => 17, 'name' => 'Tipo de hora', 'value' => $tipo_hora];

                                $conn->time_entry->create([
                                    'project_id' => $projectid,
                                    'issue_id' => $taskid,
                                    'activity_id' => $activity,
                                    'hours' => $hours,
                                    'spent_on' => $spent_on,
                                    'comments' => $atividades,
                                    'custom_fields' => $custom_fields,
                                ]);

                                $conn->issue->addNoteToIssue($taskid, $atividades);

                                $updateTime = $conn->time_entry->all([
                                    'issue_id' => $taskid,
                                    'project_id' => $projectid,
                                ]);
                            }
                        }

                        if ($contador == 1) {
                            //iniciar o cronometro
                            $contador = new Cronometro;
                            $contador->user_id = $userid;
                            $contador->task_id = $taskid;
                            $contador->started_at = Carbon::now();
                            $contador->save();
                        }
                        $retorno = $taskid;
                $resultado = "Cliente não possui integração com a EBS-IT!";
            }

            $updateTasks = $conn->issue->show($taskid);

            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = "Alteração do Chamado";
            $log->status_integracao = json_encode($resultado, JSON_UNESCAPED_UNICODE);
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();
            
            $return_result = $conn->issue->show($retorno);

            return $return_result;

            // } catch (\Exception $e) {
            //   echo 'Erro ao tentar salvar!' , $e->getMessage();
            // }
        }
    }
    //função para tratar caracteres especiais
    public function detect_encoding($string)
    {
        if (preg_match('%^(?: [\x09\x0A\x0D\x20-\x7E] | [\xC2-\xDF][\x80-\xBF] | \xE0[\xA0-\xBF][\x80-\xBF] | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2} | \xED[\x80-\x9F][\x80-\xBF] | \xF0[\x90-\xBF][\x80-\xBF]{2} | [\xF1-\xF3][\x80-\xBF]{3} | \xF4[\x80-\x8F][\x80-\xBF]{2} )*$%xs', $string))
            return 'UTF-8';
    
        return mb_detect_encoding($string, array('UTF-8', 'ASCII', 'ISO-8859-1', 'JIS', 'EUC-JP', 'SJIS'));
    }
    
    public function convert_encoding($string, $to_encoding, $from_encoding = '')
    {
        if ($from_encoding == '')
            $from_encoding = $this->detect_encoding($string);
    
        if ($from_encoding == $to_encoding)
            return $string;
    
        return mb_convert_encoding($string, $to_encoding, $from_encoding);
    }
    /*
    ** Funções que permite Alterar o Status do Chamado e Inserir Apontamentos
    */
    public function changeTask(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $userid = \Session::get('user')['id'];
            $taskid = $request->taskid;
            $task = $conn->issue->show($taskid)['issue'];

            $statusatual = $task['status']['id'];
            $statusid = $request->statusid;
            $status = $request->status;

            //8 paused para  2 in progress
            if ($statusatual != 8 && $statusid != 2) {
                $projectid = $request->projectid;
                $dt = $request->spent_on;
                $dt = explode('/', $dt);
                $spent_on = $dt[2] . '-' . $dt[1] . '-' . $dt[0];

                $hours = $request->hours;
                $atividades = $request->atividades;
                $activity = $request->activity;
                $entrada_trabalho = $request->hora_entrada_trabalho;
                $saida_almoco = $request->hora_saida_almoco;
                $retorno_almoco = $request->hora_retorno_almoco;
                $saida_trabalho = $request->hora_saida_trabalho;
                $notes = $request->notes;
                $notes = $this->convert_encoding($notes, 'UTF-8');

                $custom_fields = [];
                if ($entrada_trabalho) $custom_fields[] = ['id' => 1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
                if ($saida_almoco) $custom_fields[] = ['id' => 2, 'name' => 'Hora Saída Almoço', 'value' => $saida_almoco];
                if ($retorno_almoco) $custom_fields[] = ['id' => 3, 'name' => 'Hora Retorno Almoço', 'value' => $retorno_almoco];
                if ($saida_trabalho) $custom_fields[] = ['id' => 4, 'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
                if ($atividades) $custom_fields[] = ['id' => 13, 'name' => 'Atividades', 'value' => $atividades];

                $conn->time_entry->create([
                    'project_id' => $projectid,
                    'issue_id' => $taskid,
                    'activity_id' => $activity,
                    'hours' => $hours,
                    'spent_on' => $spent_on,
                    'comments' => $atividades,
                    'custom_fields' => $custom_fields,
                ]);

                $conn->issue->update($taskid,
                    [
                        'notes' => $notes,
                        'status_id' => $statusid,
                        'due_date' => date('Y-m-d')
                    ]
                );
            }

            $conn->issue->setIssueStatus($taskid, $status);

            $updateTasks = $conn->issue->show($taskid);

            $descstatus = [
                1 => 'New',
                2 => 'In Progress',
                3 => 'Resolved',
                5 => 'Closed',
                7 => 'Feedback',
                8 => 'Paused',
                14 => 'RDM-Validar PROD',
                16 => 'RDM-Congelar Mudança'
            ];

            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Mudança do Status';
            $log->valor = $descstatus[$statusatual] . ' - ' . $status;
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();


            return $updateTasks;

        }
    }

    /*
    ** Funções que Transfere o Chamado para outro Analista ou Group/Fila
    */
    public function transferTask(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();
            $userid = $request->userid;
            $taskid = $request->taskid;

            $conn->issue->update($taskid,
                [
                    //'status_id' => 2,
                    'assigned_to_id' => $userid
                    //'due_date' => date('Y-m-d')
                ]
            );

            $updateTasks = $conn->issue->show($taskid);

            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Trasferido para';
            $log->valor = $updateTasks['author']['name'];
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();

            return $updateTasks;

        }
    }


    /*
    ** Funções do Painel Meus Apontamentos
    */
    
    public function myGmuds(Request $request)
    {
        if ($request) {
            $user_id = \Session::get('user')['id'];
            // $user_id = 476;
            

            $sql = 'SELECT DATE_FORMAT(a.due_date,"%d/%m/%Y") dtchamado,
          		a.id cdchamado,
				b.id cdprojeto,
              SUBSTRING(a.subject,1,300) dschamado,
          		LEFT(b.name,4) cliente,
				s.name situacao,
				IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM EQUIPE") equipe,
              f.value fila
          FROM issues a
              INNER JOIN projects b ON a.project_id = b.id
              INNER JOIN issue_statuses s ON a.status_id = s.id
              INNER JOIN users u ON a.assigned_to_id = u.id
          	  INNER JOIN (select customized_id, value from custom_values where custom_field_id = 24 and customized_type = "Issue") f ON f.customized_id = a.id
          WHERE a.status_id NOT IN (3,5,12)
              AND a.assigned_to_id = 635 
              AND f.value IN (SELECT g.lastname FROM groups_users gu INNER JOIN users g ON g.id = gu.group_id WHERE gu.user_id =' . $user_id . ')
          	  AND date_format(a.due_date, "%Y-%m-%d") <= CURDATE() AND a.due_date IS not null 
			 ORDER BY a.due_date asc';
            
            $registros = \DB::connection('mysql_redmine')->select($sql);
            
            

            $rowid = 1;
            $dados = [];
            foreach ($registros as $registro) {
                $desc = '';

                $len = (int)strlen($registro->dschamado);
                $intervals = array(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300);
                foreach ($intervals as $i) {
                    $s = mb_substr($registro->dschamado, $i, 30);
                    if ($s) {
                        if ($desc) $desc .= ' ';
                        $desc .= $s;
                    }
                }
            
            
                $dados[] = [
                    'id' => $rowid,
                    'number' => '<a target="_blank" href="' . \URL::to('/taskreport') . '/' . $registro->cdchamado . '" class="btn btn-default btn-xs" data-taskid="' . $registro->cdchamado . '" data-task="' . $registro->dschamado . '" data-projectid="' . $registro->cdprojeto . '">' . $registro->cdchamado . '</a>',
                    'description' => $desc . '<br />',
                    'client' => $registro->cliente . '<br /><b>' . $registro->situacao . '</b>',
                    'previsao' => $registro->dtchamado,
                    'fila' => '<b>' . $registro->fila . '</b>',
                    'button' => '<button type="button" id="capturar' . $rowid . '" data-rowid="' . $rowid . '" data-taskid="' . $registro->cdchamado . '" class="btn btn-xs btn-success capturar"><i class="fa fa-share-square-o"></i> capturar</button>'
                    ];
                $rowid++;
                //$registro->equipe = "";
               
            }
            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }
    }
    
    public function myRcas(Request $request)
    {
        if ($request) {
            $user_id = \Session::get('user')['id'];
            $sql = 'SELECT a.id cdchamado,
				b.id cdprojeto,
              SUBSTRING(a.subject,1,300) dschamado,
          		LEFT(b.name,4) cliente,
          		s.name situacao,
				IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM EQUIPE") analista,
              f.value status_rca,
              cv.value fila
          FROM issues a
              INNER JOIN projects b ON a.project_id = b.id
              INNER JOIN issue_statuses s ON a.status_id = s.id
              INNER JOIN users u ON a.assigned_to_id = u.id
          	  INNER JOIN (select customized_id, VALUE from custom_values where custom_field_id = 27 AND customized_type = "Issue" and VALUE = "Pendente") f ON f.customized_id = a.id
				  INNER JOIN (select customized_id, VALUE from custom_values where custom_field_id = 24 AND customized_type = "Issue") cv ON cv.customized_id = f.customized_id
				  WHERE a.assigned_to_id =' . $user_id;
            
            $registros = \DB::connection('mysql_redmine')->select($sql);
            
            $rowid = 1;
            $dados = [];
            foreach ($registros as $registro) {
                $desc = '';

                $len = (int)strlen($registro->dschamado);
                $intervals = array(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300);
                foreach ($intervals as $i) {
                    $s = mb_substr($registro->dschamado, $i, 30);
                    if ($s) {
                        if ($desc) $desc .= ' ';
                        $desc .= $s;
                    }
                }
            
            
                $dados[] = [
                    'id' => $rowid,
                    'number' => '<a target="_blank" href="' . \URL::to('/taskreport') . '/' . $registro->cdchamado . '" class="btn btn-default btn-xs" data-taskid="' . $registro->cdchamado . '" data-task="' . $registro->dschamado . '" data-projectid="' . $registro->cdprojeto . '">' . $registro->cdchamado . '</a>',
                    'description' => $desc . '<br />',
                    'client' => $registro->cliente . '<br /><b>' . $registro->situacao . '</b>',
                    'status' => $registro->status_rca,
                    'fila' => '<b>' . $registro->fila . '</b>'
                    ];
                $rowid++;
               
            }
            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }
    }
    
    public function myTime(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();
            $userid = \Session::get('user')['id'];
            $rowid = 1;

            $mytimes = $conn->time_entry->all(
                [
                    'user_id' => $userid
                ]
            );

            $dados = array();
            if (isset($mytimes['time_entries'])) {
                foreach ($mytimes['time_entries'] as $mytime) {
                    $issueid = $mytime['issue']['id'];
                    $task = $conn->issue->show($issueid);
                    $statusid = $task['issue']['status']['id'];

                    $data = date_format(date_create($mytime['spent_on']), 'd/m/Y H:i:s');
                    if ($statusid == 5) {
                        $dados[] = [
                            'id' => $rowid,
                            'number' => '<a target="_blank" href="' . url('/taskreport') . '/' . $issueid . '" class="btn btn-default btn-xs taskdetail" data-taskid="' . $issueid . '" data-task="' . $task['issue']['subject'] . '" data-projectid="' . $task['issue']['project']['id'] . '">' . $issueid . '</a>',
                            'date' => $data,
                            'task' => $task['issue']['subject'],
                            'project' => $task['issue']['project']['name'],
                            'amount' => $mytime['hours']
                        ];
                        $rowid++;
                    }
                }
            }

            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }
    }

    /*
    ** Funções do Painel Meus Apontamentos
    */
    public function timeEntries(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $rowid = 1;
            $dados = array();
            $taskid = (int)$request->taskid;
            $times = $conn->time_entry->all(
                [
                    //'issue_id' => $request->taskid,
                    'project_id' => $request->projectid,
                ]
            );
            $atividade = $conn->time_entry_activity->all()['time_entry_activities'];

            foreach ($times['time_entries'] as $time) {
                $issue_id = $time['issue']['id'];
                $custom = $time['custom_fields'];

                $owner_id = $time['user']['id'];
                $user_id = \Session::get('user')['id'];

                $edit = false;
                if ($user_id == $owner_id) $edit = true;

                if ($issue_id == $request->taskid) {
                    $data = date_format(date_create($time['spent_on']), 'd/m/Y');
                    $dados[] = [
                        'id' => $rowid,
                        'timeid' => $time['id'],
                        'issueid' => $issue_id,
                        'atividade' => $atividade,
                        'activityid' => $time['activity']['id'],
                        'activityname' => $time['activity']['name'],
                        'hours' => $time['hours'],
                        'spent_on' => $data,
                        'edit' => $edit,
                        'entrada_trabalho' => $time['custom_fields'][0]['value'],
                        'saida_almoco' => $time['custom_fields'][1]['value'],
                        'retorno_almoco' => $time['custom_fields'][2]['value'],
                        'saida_trabalho' => $time['custom_fields'][3]['value'],
                        'atividades' => $time['custom_fields'][4]['value'],
                    ];
                }
                $rowid++;

            }

            return json_encode($dados, JSON_UNESCAPED_UNICODE);
        }
    }

    /*
    ** Funções que permite Inserir Novo Apontamento
    */
    public function saveNewTime(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $taskid = $request->taskid;
            $task = $conn->issue->show($taskid)['issue'];
            $projectid = $task['project']['id'];
            $contador = $request->contador;
            $contadorid = $request->contadorid;
            $dt = $request->spent_on;
            $dt = explode('/', $dt);
            $spent_on = $dt[2] . '-' . $dt[1] . '-' . $dt[0];

            $hours = $request->hours;
            // $atividades = $request->atividades;
            // $atividades = $this->convert_encoding($atividades, 'UTF-8');
            $activity = $request->activity;
            $entrada_trabalho = $request->hora_entrada_trabalho;
            $saida_almoco = $request->hora_saida_almoco;
            $retorno_almoco = $request->hora_retorno_almoco;
            $saida_trabalho = $request->hora_saida_trabalho;
            $tipo_hora = $request->tipo_hora;
            $notes = $request->notes;
            $notes = $this->convert_encoding($notes, 'UTF-8');

            $custom_fields = [];
            if ($entrada_trabalho) $custom_fields[] = ['id' => 1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
            if ($saida_almoco) $custom_fields[] = ['id' => 2, 'name' => 'Hora Saída Almoço', 'value' => $saida_almoco];
            if ($retorno_almoco) $custom_fields[] = ['id' => 3, 'name' => 'Hora Retorno Almoço', 'value' => $retorno_almoco];
            if ($saida_trabalho) $custom_fields[] = ['id' => 4, 'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
            if ($notes) $custom_fields[] = ['id' => 13, 'name' => 'Atividades', 'value' => $notes];
            if ($tipo_hora) $custom_fields[] = ['id' => 17, 'name' => 'Tipo de hora', 'value' => $tipo_hora];

            $conn->time_entry->create([
                'project_id' => $projectid,
                'issue_id' => $taskid,
                'activity_id' => $activity,
                'hours' => $hours,
                'spent_on' => $spent_on,
                'comments' => $notes,
                'custom_fields' => $custom_fields,
            ]);
            $conn->issue->addNoteToIssue($taskid, $notes);

            $updateTime = $conn->time_entry->all([
                'issue_id' => $taskid,
                'project_id' => $projectid,
            ]);

            $updateTasks = $conn->issue->show($taskid);

            if ($contador == 2) {
                //finalizar o cronometro
                $contador = Cronometro::find($contadorid);
                $contador->finished_at = Carbon::now();
                $contador->save();
            }


            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Apontamento de Horas';
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();


            return $updateTime;

            // var vetor = ["teste10","teste11", "teste12"];


        }
    }

    /*
    ** Funções que permite Atulizar um Apontamento existente
    */
    public function saveTime(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $timeid = $request->timeid;
            $taskid = $request->taskid;

            $dt = $request->spent_on;
            $dt = explode('/', $dt);
            $spent_on = $dt[2] . '-' . $dt[1] . '-' . $dt[0];

            $hours = $request->hours;
            $atividades = $request->atividades;
            $atividades = $this->convert_encoding($atividades, 'UTF-8');
            $activity = $request->activity;
            $entrada_trabalho = $request->hora_entrada_trabalho;
            $saida_almoco = $request->hora_saida_almoco;
            $retorno_almoco = $request->hora_retorno_almoco;
            $saida_trabalho = $request->hora_saida_trabalho;
            $tipo_hora = $request->tipo_hora;
            $notes = $request->notes;
            $notes = $this->convert_encoding($notes, 'UTF-8');

            $custom_fields = [];
            if ($entrada_trabalho) $custom_fields[] = ['id' => 1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
            if ($saida_almoco) $custom_fields[] = ['id' => 2, 'name' => 'Hora Saída Almoço', 'value' => $saida_almoco];
            if ($retorno_almoco) $custom_fields[] = ['id' => 3, 'name' => 'Hora Retorno Almoço', 'value' => $retorno_almoco];
            if ($saida_trabalho) $custom_fields[] = ['id' => 4, 'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
            if ($atividades) $custom_fields[] = ['id' => 13, 'name' => 'Atividades', 'value' => $atividades];
            if ($tipo_hora) $custom_fields[] = ['id' => 17, 'name' => 'Tipo de hora', 'value' => $tipo_hora];

            $conn->time_entry->update($timeid, [
                'activity_id' => $activity,
                'hours' => $hours,
                'spent_on' => $spent_on,
                'comments' => $notes,
                'custom_fields' => $custom_fields,
            ]);

            $updateTime = $conn->time_entry->show($timeid);
            $updateTasks = $conn->issue->show($taskid);

            $log = new Log;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Alteração do Apontamento de Horas';
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();

            return $updateTime;
        }
    }

    /*
    ** Funções que permite Apagar um Apontamento existente
    */
    public function deleteTime(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $timeid = $request->timeid;
            $conn->time_entry->show($timeid);
            $conn->time_entry->remove($timeid);
            $taskid = $request->taskid;
            $deleteTime = $conn->issue->show($taskid);

            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Exclusão do Apontamento de Horas';
            $log->json = json_encode($deleteTime, JSON_UNESCAPED_UNICODE);
            $log->save();

        }
    }

    /*
    ** Funções que permite Inserir Notas ao Chamado
    */
    public function saveNotes(Request $request) {
        if ($request) {
            $conn = $this->connectApi();

            $userid = \Session::get('user')['id'];
            $taskid = $request->taskid;
            $notes = urldecode($request->notes);
            $notes = $this->convert_encoding($notes, 'UTF-8');
            urldecode($notes);

            $chamado = $conn->issue->show($taskid)['issue'];
            $projectid = $chamado['project']['id'];

            $c_integracao = $this->verificar_integracao($taskid);

            if ($c_integracao) {

                $token_web = WebServiceController::webService_login();

                if ($token_web) {

                    $resp = WebServiceController::webService_update($token_web, $request);

                    $obj = json_decode($resp);

                    if (isset($obj->{'result'})) {
                        $resultado = $obj->{'result'};
                        $conn->issue->addNoteToIssue($taskid, $notes);
                        $retorno = $taskid;
                    } else {
                        $resultado = $resp;
                        $retorno = 1;
                    }
                } else {
                    
                }
            } else {
                $conn->issue->addNoteToIssue($taskid, $notes);
                $retorno = $taskid;
                $resultado = "Cliente não possui integração com a EBS-IT!";
            }


            $updateTasks = $conn->issue->show($taskid);
            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Inclusão de Notas';
            $log->status_integracao = json_encode($resultado, JSON_UNESCAPED_UNICODE);
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();

            $return_result = $conn->issue->show($retorno);

            return $return_result;
        }
    }

    /*
    ** anexar arquivo do campo customizado 29
    */
    
    
    // public function anexarcf(Request $request)
    // {
    //     if ($request) {

    //         $conn = $this->connectApi();
    //         $taskid = $request->taskid;
    //         $custom_fields = [];
    //         $custom_fields[] = ['id' => 32, 'value' => 18093];
    //     }
            
    // }
    

    public function anexar(Request $request)
    {
        if ($request) {

            $conn = $this->connectApi();
            $token_web = WebServiceController::webService_login();
            $projectid = $request->projectid;
            $taskid = $request->taskid;


            $c_integracao = HomeController::verificar_integracao($taskid);
        
            if($c_integracao){
            foreach($c_integracao as $integracao){
                $id_sistema = $integracao->id_sistema;
            }
            $resp = WebServiceController::anexar($token_web, $request,$id_sistema);
            }

            $files = $request->file('fileUpload');
            foreach ($files as $file) {
                $filecontent = file_get_contents($file->getPathName());
                $filename = $file->getClientOriginalName();
                $contenttype = $file->getMimeType();

              $upload = json_decode($conn->attachment->upload($filecontent));

                $conn->issue->attach($taskid, [
                    'token' => $upload->upload->token,
                    'filename' => $filename,
                    'description' => $filename,
                    'content_type' => $contenttype,
                ]);
            }
            $updateTasks = $conn->issue->show($taskid);

            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Inclusão de Anexo';
            $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
            $log->save();

            return $updateTasks;

        }
    }


    /*
    ** Visualiza o Histórico do Chamado
    */
    public function historico(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $task = $conn->issue->show($request->taskid, [
                'include' => [
                    'attachments'
                ]
            ])['issue'];

            $projectid = $task['project']['id'];
            if ($request->projectid != '') $projectid = $request->projectid;

            $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = ' . $projectid . '  ORDER BY tra.name';
            $trackers = \DB::connection('mysql_redmine')->select($sql);

            $journals = $this->journalsTaskMysql($request->taskid);

            $attachments = [];
            if (isset($task['attachments'])) {
                $attachments = $task['attachments'];
            }

            return view('historico', [
                'attachments' => $attachments,
                'trackers' => $trackers,
                'journals' => $journals,
            ])->render();
        }
    }



    /*
   ** Visualiza o arquivo em anexo do chamado
   */


    public function visualizarAnexo(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $attachmentId = $request->attachmentId;

            $file = $conn->attachment->show($attachmentId)['attachment'];
            // dd($file);
            $filename = $file['filename'];
            $content_type = $file['content_type'];
            $filesize = $file['filesize'];

            $file_content = $conn->attachment->download($attachmentId);
            file_put_contents(public_path($filename), $file_content);
            return response($file_content)
                ->header('Content-type', $content_type);


        }
    }
 /*
   ** Faz dowload do anexo
   */

    public function downanexo(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $attachmentId = $request->attachmentId;
            $file_content = $conn->attachment->download($attachmentId);
            
            return $file_content;


        }
    }
    public function deleteArquivos(Request $request){
        if($request){
            $conn = $this->connectApi();

            $attachmentId = $request->attachmentId;
            $conn->attachment->remove($attachmentId);

            $taskid = $request->taskid;
            $delete = $conn->issue->show($taskid);

            $log = new Log;
            $log->id_chamado = $taskid;
            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Exclusão de Anexo';
            $log->json = json_encode($delete, JSON_UNESCAPED_UNICODE);
            $log->save();

            return $delete;
        }
    }

    /*
    ** Visualiza o arquivo em anexo do chamado
    */
    public function downloadAnexo(Request $request)
    {

        if ($request) {
            $conn = $this->connectApi();

            $attachmentId = $request->attachmentId;

            $file = $conn->attachment->show($attachmentId)['attachment'];
            $filename = $file['filename'];
            $content_type = $file['content_type'];
            $filesize = $file['filesize'];

            $file_content = $conn->attachment->download($attachmentId);
            file_put_contents($filename, $file_content);

            header('Expires: 0');
            header('Content-length:' . $filesize);
            header('Content-type:' . $content_type . '');
            header('Content-Disposition: attachment; filename=' . $filename);
            readfile($filename);
        }

    }

    /*
    ** Visualiza e Edita os Apontamentos do Chamado
    */
    public function editHours(Request $request)
    {
        if ($request) {
            $conn = $this->connectApi();

            $task = $conn->issue->show($request->taskid, [
                'include' => [
                    'attachments'
                ]
            ])['issue'];

            $projectid = 0;
            if ($task['project']['id']) $projectid = $task['project']['id'];
            if ($request->projectid != '') $projectid = $request->projectid;

            $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = ' . $projectid . '  ORDER BY tra.name';
            $trackers = \DB::connection('mysql_redmine')->select($sql);

            $status = $conn->issue_status->all();
            $priorities = $conn->issue_priority->all();
            // $custom_fields = $conn->custom_fields->all();

            $dados = $conn->time_entry->all(
                [
                    'issue_id' => $request->taskid,
                ]
            )['time_entries'];

            $activities = $conn->time_entry_activity->all();
//
            return view('edithours', [
                'task' => $task,
                'times' => $dados,
                'trackers' => $trackers,
                'status' => $status['issue_statuses'],
                'activities' => $activities['time_entry_activities'],
                'priorities' => $priorities['issue_priorities'],
                // 'custom_fields' => $custom_fields['custom_fields'],
            ])->render();
        }
    }
}
