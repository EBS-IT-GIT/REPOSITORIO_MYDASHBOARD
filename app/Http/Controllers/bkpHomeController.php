<?php

namespace App\Http\Controllers;

use App\Log;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Redmine\Client as Client;

class HomeController extends Controller
{

    /**
     * Create a new controller instance.
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
    public function index()
    {
      $conn = $this->connectApi();
      $activities = $conn->time_entry_activity->all();
      $grupos = $this->myGroupsMysql();

      $activities = [];
      if(isset($activities['time_entry_activities']))
        $activities = $activities['time_entry_activities'];

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
      		AND  u.id IN (SELECT user_id FROM groups_users WHERE group_id = 408)
      	GROUP BY responsavel, 2
      ) AS t
      GROUP BY t.responsavel WITH ROLLUP";
      $chart = \DB::connection('mysql_redmine')->select($sql);

      return view('home',[
        'activities' => $activities,
        'grupos' => $grupos,
        'chart' => $chart,
      ]);
    }

    /*
    ** Visualiza os Gráficos dos Chamados
    */
    public function tasksChart(Request $request)
    {
      $conn = $this->connectApi();

      $group = 408;
      if(isset($request->group)){
        $group = $request->group;//' AND u.id='.$request->group;
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
      		AND  u.id IN (SELECT user_id FROM groups_users WHERE group_id = $group)
      	GROUP BY responsavel, 2
      ) AS t
      GROUP BY t.responsavel WITH ROLLUP";
      //dd($sql);
      $chart = \DB::connection('mysql_redmine')->select($sql);

      return view('taskschart',[
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
      if(isset($times['time_entries'])){
        foreach ($times['time_entries'] as $time)
        {
          if(isset($time['issue'])){
            $issue_id = $time['issue']['id'];
            if($issue_id==$request->taskid) $dados[] = $time;
          }
        }
      }

      return view('changeviewtask',[
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
      if($request){
        $conn = $this->connectApi();

        $task = $conn->issue->show($request->taskid,[
          'include' => [
            'attachments'
          ]
          ])['issue'];

        $projectid = $task['project']['id'];
        if($request->projectid!='') $projectid = $request->projectid;

        $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = '.$projectid.'  ORDER BY tra.name';
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
        if(isset($times['time_entries'])){
          foreach ($times['time_entries'] as $time)
          {
            if(isset($time['issue'])){
              $issue_id = $time['issue']['id'];
              if($issue_id==$request->taskid) $dados[] = $time;
            }
          }
        }

        $files = [];
        if(isset($task['attachments'])){
          $files = $task['attachments'];
        }

        $activities = $conn->time_entry_activity->all();
        $journals = $this->journalsTaskMysql($request->taskid);

        return view('taskdetail',[
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
      if($request){
        $conn = $this->connectApi();
        $user_id = \Session::get('user')['id'];
        $taskid = $request->taskid;

        $task = $conn->issue->show($taskid,[
          'include' => [
            'attachments'
          ]
          ])['issue'];
        // dd($task);
        $projectid = 0;
        if(isset($task['project']['id'])) $projectid = $task['project']['id'];
        if($request->projectid!='') $projectid = $request->projectid;

        $autor = $task['author']['id'];
        $contato = [];
        $sql = 'SELECT aut.id, aut.login, concat(aut.firstname, " ", aut.lastname) nome_contato, mail.address email, cv.value telefone FROM users aut
                  LEFT OUTER JOIN email_addresses mail ON mail.user_id = aut.id
                  LEFT OUTER JOIN custom_values cv ON cv.customized_id = aut.id
                    AND cv.customized_type = "Principal"
                    AND custom_field_id = 16
                WHERE aut.id = ' . $autor;
        $contato = \DB::connection('mysql_redmine')->select($sql);

        $trackers = [];
        $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = '.$projectid.'  ORDER BY tra.name';
        $trackers = \DB::connection('mysql_redmine')->select($sql);

        //seleciona as novas situações de acordo com a situação atual do chamado e pela permissão do usuário
        $sql = "SELECT DISTINCT inew.id, inew.name
                FROM workflows w
                INNER JOIN issues i ON w.tracker_id = i.tracker_id
                INNER JOIN issue_statuses inew ON inew.id = w.new_status_id
                INNER JOIN (
                	SELECT mr.role_id
                	FROM members mb
                		INNER JOIN member_roles mr ON mb.id = mr.member_id
                	WHERE mb.user_id = ".$user_id."
                ) grp ON w.role_id = grp.role_id
                WHERE w.type = 'WorkflowTransition'
                	AND w.old_status_id=i.status_id
                	AND i.id=".$taskid;
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
        if(isset($times['time_entries'])){
          foreach ($times['time_entries'] as $time)
          {
            if(isset($time['issue'])){
              $issue_id = $time['issue']['id'];
              if($issue_id==$request->taskid) $dados[] = $time;
            }
          }
        }

        $files = [];
        if(isset($task['attachments'])){
          $files = $task['attachments'];
        }

        $activities = $conn->time_entry_activity->all();
        $journals = $this->journalsTaskMysql($request->taskid);

        $option = '<option value="">Transferir para</option>';
        $members = [];
        if($projectid!=0){
          $members = $conn->membership->all($projectid,[
            'limit'=>100,
          ])['memberships'];
        }
        $option_group = '';

        $usuarios = array_column($members,'user');
        $usuarios_id = array_column($usuarios,'id');
        $usuarios_name = array_column($usuarios,'name');
        $usuarios = array_combine($usuarios_id, $usuarios_name);
        asort($usuarios);
        $assignedtoid = (int)$task['assigned_to']['id'];
        foreach ($usuarios as $key => $usuario) {
            $optionselected = '';
            if($assignedtoid==$key) $optionselected = ' selected="selected"';
            $option .= '<option value="' . $key . '" '.$optionselected.'>' . $usuario . '</option>';
        }

        $grupos = array_column($members,'group');
        $grupos_id = array_column($grupos,'id');
        $grupos_name = array_column($grupos,'name');
        $grupos = array_combine($grupos_id, $grupos_name);
        asort($grupos);
        //dd($task);
        foreach ($grupos as $key => $grupo) {
          $optionselected = '';
          if($assignedtoid==$key) $optionselected = ' selected="selected"';
          $option_group .= '<option value="' . $key . '" '.$optionselected.'>' . $grupo . '</option>';
        }

        $option .= '<optgroup label="Grupos">'.$option_group.'</optgroup>';

        $transferirpara = '<select name="transferir_para" id="transferir_para" class="form-control input-sm" data-projectid="' . $projectid . '" data-taskid="' . $taskid . '" placeholder="transferir para" style="width: 250px;">' . $option . '</select>';

        return view('taskreport',[
          'task' => $task,
          'times' => $dados,
          'trackers' => $trackers,
          'status' => $status['issue_statuses'],
          'activities' => $activities['time_entry_activities'],
          'priorities' => $priorities['issue_priorities'],
          'custom_fields' => $custom_fields,
          'journals' => $journals,
          'files' => $files,
          'novasituacao' => $novasituacao,
          'transferirpara' => $transferirpara,
          'contato' => $contato,
        ])->render();
      }
    }

    /*
    ** Funções que Retorna os Custom Fields Obrigadtórios para o Novo Status
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
        $cf = $task['custom_fields'];
        $cf_ids = implode(',',array_column($cf,'id'));
        $projectid=$task['project']['id'];

        $sql = "SELECT cf.id, cf.name, cf.field_format, cf.is_required, cf.possible_values, cv.value valor
          from custom_values cv
          inner join issues i on cv.customized_id = i.id
          inner join custom_fields cf on cf.id=cv.custom_field_id
          left join custom_fields_projects cfp ON cf.id=cfp.custom_field_id and cfp.project_id = i.project_id
          left join custom_fields_roles cfr on cfr.custom_field_id = cf.id
          where cv.customized_id = ".$taskid."  and cf.type = 'IssueCustomField' and (cfr.role_id in (SELECT role_id FROM member_roles
          WHERE member_id IN (SELECT id FROM members WHERE user_id = ".$user_id.")) or cfr.role_id is null)";
        $campos = \DB::connection('mysql_redmine')->select($sql);


        $regras = [];
        $sql_regras = "SELECT cf.id, w.rule
          FROM workflows w
          	INNER JOIN issues i ON w.tracker_id = i.tracker_id
          	LEFT JOIN custom_fields cf ON cf.id = w.field_name
          WHERE w.type = 'WorkflowPermission' AND i.id = ".$taskid."
          	AND w.old_status_id = ".$statusid."
          	AND w.role_id IN (SELECT role_id FROM member_roles
          WHERE member_id IN (SELECT id FROM members WHERE user_id = ".$user_id."))
          GROUP BY id, rule";
        $regras = \DB::connection('mysql_redmine')->select($sql_regras);
        $regras = array_column($regras,'rule','id');
        //dd($regras);

        $html = '';
        $apontamento = '';
        $conteudo = '';
        foreach($campos as $key => $value){
          $required = '';
          $readonly = '';
          $is_required = '';

          if($value->is_required==1) {
            $required='issue_required';
            $is_required=' <span class="text-red">*</span>';
          }

          //var_dump($regras, $value->id, array_key_exists($value->id, $regras));
          if(array_key_exists($value->id, $regras)){
            if($regras[$value->id]=="readonly"){
              $readonly = 'readonly';
            }
            if($regras[$value->id]=="required") {
              $readonly='';
              $required='issue_required';
              $is_required=' <span class="text-red">*</span>';
            }
          }
          $conteudo = $value->valor;

            $tam=3;
            if($value->field_format=="text") $tam=12;
            $html .= '<div class="col-md-'.$tam.'">'.
              '<div class="form-group" id="help_cf_'.$value->id.'_'.$taskid.'" >'.
                '<label for="title">'.$value->name.' ['.$value->id.']'.$is_required.'</label>';

                switch ($value->field_format){
                  case 'string':
                    $html .= '<input type="text" class="form-control input-sm '.$required.'" '.$readonly.' name="cf_'.$value->id.'_'.$taskid.'" id="cf_'.$value->id.'_'.$taskid.'" value="'.$conteudo.'">';
                    break;
                  case 'bool':
                    if($conteudo==1) {
                      $opt = '<option value="0">Não</option>';
                      $opt .= '<option value="1" selected>Sim</option>';
                    }else{
                      $opt = '<option value="0" selected>Não</option>';
                      $opt .= '<option value="1">Sim</option>';
                    }
                    $html .= '<select class="form-control input-sm '.$required.'" '.$readonly.' name="cf_'.$value->id.'_'.$taskid.'" id="cf_'.$value->id.'_'.$taskid.'">'.$opt.'</select>';
                    break;
                  case 'text':
                    $html .= '<textarea rows="4" class="form-control input-sm '.$required.'" '.$readonly.' name="cf_'.$value->id.'_'.$taskid.'" id="cf_'.$value->id.'_'.$taskid.'">'.$conteudo.'</textarea>';
                    break;
                  case 'list':
                    $html .= '<select class="form-control input-sm '.$required.'" '.$readonly.' name="cf_'.$value->id.'_'.$taskid.'" id="cf_'.$value->id.'_'.$taskid.'">';
                    if($value->possible_values){
                      $possible_values = preg_replace( "/\r|\n/", "|", $value->possible_values);
                      $opt = explode('|',$possible_values);
                      $options = '';
                      foreach ($opt as $op) {
                        $selected = '';
                        $op = str_replace('- ','',$op);
                        if($conteudo==$op) $selected = 'selected="selected"';
                        $options .= '<option value="'.$op.'" '.$selected.'>'.$op.'</option>';
                      }
                      $html .= $options;
                    }else{
                      $html .= '<option value=""></option>';
                    }
                    $html .= '</select>';
                    break;
                }
              $html .= '</div>'.
            '</div>';
        }

        //apontamento obrigatório [26]
        if(array_key_exists(26, $regras)){
          $apontamento = '<div class="row">'.
              '<div class="col-md-12">'.
              '<h4 class="h4">Apontamentos</h4>'.
              '<input type="hidden" class="form-control input-sm" name="cf_26_'.$taskid.'" id="cf_26_'.$taskid.'" value="1">'.
              '</div>'.
            '</div>';
        }

        return $html.$apontamento;

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
    public function connectApi()
    {
      $url = env('SD_URL');
      $apiKey = \Session::get('user')['api_key'];
      $conn = new Client($url, $apiKey);

      return $conn;
    }

    /*
    ** Função que Lista os Projetos do Usuário
    */
    public function myProjects()
    {

      $conn = $this->connectApi();

      $myprojects = array();
      //projetos em que estou associado
      $projects = $conn->user->getCurrentUser()['user']['memberships'];
      foreach ($projects as $project) {
        $roleid = (int)$project['roles'][0]['id'];
        if($roleid!=25){
          $projectid = (int)$project['project']['id'];
          $myprojects[] = $projectid;
        }
      }
      return $myprojects;
    }

    /*
    ** SLAs
    */
    public function listSla()
    {
      $sla = [
        ['priority_id' => 1, 'priority_name'=>'Low', 'issue_sla'=>60.0],
        ['priority_id' => 2, 'priority_name'=>'Normal', 'issue_sla'=>32.0],
        ['priority_id' => 3, 'priority_name'=>'High', 'issue_sla'=>4.0],
        ['priority_id' => 4, 'priority_name'=>'Urgent', 'issue_sla'=>2.0],
        ['priority_id' => 5, 'priority_name'=>'Immediate', 'issue_sla'=>1.0]
      ];
      return $sla;
    }

    /*
    ** Funções do Painel Meus Grupos
    */
    public function myGroupsMysql()
    {
        $user_id = \Session::get('user')['id'];
        //$user_id = 476;
        $sql = 'SELECT grp.id, grp.lastname descricao FROM users grp INNER JOIN groups_users gpu ON grp.id = gpu.group_id WHERE grp.status = 1 AND grp.type="group" AND gpu.user_id = '.$user_id.' ORDER BY grp.lastname';
        $grupos = \DB::connection('mysql_redmine')->select($sql);

        return $grupos;

    }

    /*
    ** Funções do Painel Meus Grupos
    */
    public function pesquisar(Request $request)
    {
        $param = '';
        if(isset($request->param)) $param = $request->param;

        $sql = ' SELECT isu.id, isu.subject, isu.description '.
              ' FROM issues isu '.
              ' WHERE isu.id LIKE "'.$param.'%" OR isu.subject LIKE "%'.$param.'%" OR description LIKE "%'.$param.'%" '.
              ' ORDER BY isu.id DESC LIMIT 10';
        $pesquisa = \DB::connection('mysql_redmine')->select($sql);

        return $pesquisa;

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

        $sql = ' SELECT tim.id, tim.issue_id, tim.spent_on, tim.hours, '.
              ' STR_TO_DATE(entrada.value,"%H:%i") hora_entrada, '.
              ' STR_TO_DATE(saida.value,"%H:%i") hora_saida '.
              ' FROM time_entries tim  '.
	            ' INNER JOIN ( '.
            	' SELECT customized_id, value FROM custom_values '.
            	' WHERE custom_field_id = 1 '.
            	' ) entrada ON tim.id = entrada.customized_id '.
            	' INNER JOIN ( '.
            	' SELECT customized_id, value FROM custom_values '.
            	' WHERE custom_field_id = 4 '.
            	' ) saida ON tim.id = saida.customized_id '.
              ' WHERE tim.user_id = '.$usuario.' AND DATE_FORMAT(tim.spent_on,"%d/%m/%Y") = "'.$data.'" AND '.
            	' (STR_TO_DATE("'.$entrada.'","%H:%i:%s")  BETWEEN STR_TO_DATE(entrada.value,"%H:%i:%s") AND DATE_ADD(STR_TO_DATE(saida.value,"%H:%i:%s"), INTERVAL -1 MINUTE) OR '.
              ' STR_TO_DATE(entrada.value,"%H:%i:%s")  BETWEEN STR_TO_DATE("'.$entrada.'","%H:%i:%s") AND STR_TO_DATE("'.$saida.'","%H:%i:%s") OR '.
              ' STR_TO_DATE(saida.value,"%H:%i:%s")  BETWEEN DATE_ADD(STR_TO_DATE("'.$entrada.'","%H:%i:%s"), INTERVAL 1 MINUTE) AND STR_TO_DATE("'.$saida.'","%H:%i:%s") OR '.
            	' STR_TO_DATE("'.$saida.'","%H:%i:%s")  BETWEEN STR_TO_DATE(entrada.value,"%H:%i:%s") AND STR_TO_DATE(saida.value,"%H:%i:%s"))';
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
        	CONCAT("Atualizado por <strong>", usr.firstname, " ",usr.lastname, "</strong> há <strong>", DATE_FORMAT(jou.created_on, "%d/%m/%Y %H:%m:%s"), "</strong>") atualizado_por,
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
        		CONCAT("<strong>Arquivo ", jdt.value, "</strong> adicionado")
        	ELSE
        		IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)=0,
        			CONCAT("<strong>", (SELECT cf.name FROM custom_fields cf WHERE cf.id = jdt.prop_key), "</strong> excluído (<strong>", jdt.old_value, "</strong>)"),
                	IF(IFNULL(jdt.old_value,0)>0 AND IFNULL(jdt.value,0)>0,
        			    CONCAT("<strong>", (SELECT cf.name FROM custom_fields cf WHERE cf.id = jdt.prop_key), "</strong> alterado de <strong>", jdt.old_value, "</strong> para <strong>", jdt.value, "</strong>"),
                   		CONCAT("<strong>", (SELECT cf.name FROM custom_fields cf WHERE cf.id = jdt.prop_key), "</strong> ajustado para <strong>", jdt.value, "</strong>")
                	)
        		)
        	END
        	) historico,
        	jou.notes, jdt.property, jdt.prop_key, jdt.old_value, jdt.value
        FROM journals jou
        	LEFT OUTER JOIN journal_details jdt ON jou.id = jdt.journal_id
        	INNER JOIN users usr ON jou.user_id = usr.id
        WHERE jou.journalized_id = '.$taskid.'
        ORDER BY jou.id, jou.created_on';

        $journals = \DB::connection('mysql_redmine')->select($sql);
        return $journals;

    }

    /*
    ** Funções do Painel Novos Chamados
    */
    public function newTasksMysql(Request $request)
    {
      if($request)
      {
        $user_id = \Session::get('user')['id'];
        // $user_id = 476;
        $group = '';
        if(isset($request->group)){
          $group = ' AND u.id='.$request->group;
        }

        $sql = 'SELECT CONCAT("a4",
            CASE when due_date is null then
               convert(DATE_ADD(if(a.status_id > 8,a.updated_on,a.created_on),INTERVAL isla.allowed_delay HOUR),datetime)
            ELSE convert(a.due_date,DATETIME)
            END
             ) dtnumber,
              DATE_FORMAT(a.created_on,"%d/%m/%Y %H:%i:%s") dtchamado,
          		a.id cdchamado,
          		b.id cdprojeto,
              SUBSTRING(a.subject,1,300) dschamado,
          		LEFT(b.name,4) cliente,
              IF (DATE(a.start_date) > CURDATE(),"<span class=\"label label-default\">prioridade 6",
               CASE a.priority_id
              	 WHEN 5 THEN "<span class=\"label label-danger\">prioridade 1"
                 WHEN 4 THEN "<span class=\"label label-warning\">prioridade 2"
                 WHEN 3 THEN "<span class=\"label label-info\">prioridade 3"
                 WHEN 2 THEN "<span class=\"label label-success\">prioridade 4"
               ELSE "<span class=\"label label-primary\">prioridade 5" END) prioridade,
              "SD" sistema,
              s.name situacao,
              IFNULL(CONCAT(u.firstname," ",u.lastname),"SEM EQUIPE") equipe,
              u.id idequipe
          FROM issues a
              LEFT JOIN issue_slas isla ON a.project_id = isla.project_id
                AND a.priority_id = isla.priority_id
              INNER JOIN projects b ON a.project_id = b.id
          		INNER JOIN issue_statuses s ON a.status_id = s.id
          	  INNER JOIN users u ON a.assigned_to_id = u.id
              INNER JOIN custom_values cv ON cv.customized_id = b.id AND cv.customized_type = "Project" AND cv.custom_field_id = 14
          WHERE a.status_id NOT IN (3,5,12)
              AND cv.value = "Suporte e Monitoramento"
              AND (a.assigned_to_id IN (SELECT group_id FROM groups_users WHERE user_id = '.$user_id.'))
          		AND a.subject NOT LIKE "%GMUD em PRD%" '.$group.'
          ORDER BY 1, 7, 2 DESC';
        $registros = \DB::connection('mysql_redmine')->select($sql);

        $rowid=1;
        $dados = [];
        foreach ($registros as $registro) {
          $desc = '';

          $len = (int) strlen($registro->dschamado);
          $intervals = array(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300);
          foreach ($intervals as $i) {
            $s = mb_substr($registro->dschamado,$i, 30);
            if($s){
              if($desc) $desc .= ' ';
              $desc .= $s;
            }
          }

          $dados[] = [
            'id'      => $rowid,
            'number'  => '<a target="_blank" href="' . \URL::to('/taskreport') . '/' .$registro->cdchamado.'" class="btn btn-default btn-xs" data-taskid="' . $registro->cdchamado . '" data-task="'.$registro->dschamado.'" data-projectid="' . $registro->cdprojeto . '">' . $registro->cdchamado . '</a>',
            'description' => $desc . '<br /><b>' . $registro->equipe.'</b>',
            'assigned' => $registro->equipe,
            'client'  => $registro->cliente . '<br /><b>' . $registro->situacao . '</b>',
            'date'    => $registro->dtchamado,
            'button'  => '<button type="button" id="capturar'.$rowid.'" data-rowid="'.$rowid.'" data-taskid="'.$registro->cdchamado.'" class="btn btn-xs btn-success capturar"><i class="fa fa-share-square-o"></i> capturar</button>'
          ];
          $rowid++;
        }
        return json_encode($dados, JSON_UNESCAPED_UNICODE);
      }
    }

    /*
    ** Funções do para capturar um novo chamado e Altera o Status para In Progress
    */
    public function captureTask(Request $request)
    {
      if($request)
      {
        $conn = $this->connectApi();
        $userid = \Session::get('user')['id'];
        $taskid = $request->taskid;
        $rowid = $request->rowid;

        $conn->issue->update($taskid,
          [
            'status_id' => 2,
            'assigned_to_id' => $userid,
            'due_date' => date('Y-m-d')
          ]
        );
        $conn->issue->setIssueStatus($taskid, 'In Progress');

        $updateTasks = $conn->issue->show($taskid);

        $log = new Log;
        $log->datahora = Carbon::now();
        $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
        $log->acao = 'Captura Novo Chamado No. ' . $rowid;
        $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
        $log->save();

        return $updateTasks;

      }
    }

    /*
    ** Funções do Painel Meus Chamados que lista todos os Chamados para o Analista
    */
    public function myTasks(Request $request)
    {
      if($request)
      {
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
        if(isset($newtasks['issues'])){
        foreach ($newtasks['issues'] as $task) {
          $taskid = $task['id'];
          $projectid = $task['project']['id'];
          $statusid = $task['status']['id'];
          $statusname = $task['status']['name'];
          $button = '';
          switch ($statusid) {
            case 1: //Status New - Botao Capturar(In Progress)
              $status = ' <label class="label label-success">'.$statusname.'</label>';
              break;
            case 2: // Status In Progress -> Botao Pausar(Paused), FeedBack e Encerrar(Closed)
              $status = ' <label class="label label-warning">'.$statusname.'</label>';
              break;
            case 7: //Status Feedback -> Botao Capturar(In Progress) e Encerrar
              $status = ' <label class="label label-info">'.$statusname.'</label>';
              break;
            case 8: //Status Paused -> Botao Capturar(In Progress)
              $status = ' <label class="label label-default">'.$statusname.'</label>';

              $button = '<button type="button" id="inprogress'.$rowid.'" data-taskid="'.$taskid.'" data-task="'.$task['subject'].'" data-projectid="'.$projectid.'"  data-statusid="2" data-status="In Progress" class="btn btn-xs btn-warning retomar"><i class="fa fa-play-circle-o"></i> retomar</button>';
              break;
            default:
              $status = ' <label class="label label-success">'.$statusname.'</label>';
              break;
          }

          {
            $projectname = $task['project']['name'];

            $data = strtotime($task['created_on']);
            $hoje = strtotime(date('Y-m-d H:i:s'));
            $dias = round(floor($hoje - $data)/3600/24,0);
            $alerta = ' <span class="label label-warning">'.$dias.'</span>';
            if($dias>3) $alerta = ' <span class="label label-danger">'.$dias.'</span>';

            $select = '';
            $desc = '';

            $len = (int) strlen($task['subject']);
            $intervals = array(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300);
            foreach ($intervals as $i) {
              $s = mb_substr($task['subject'],$i, 30);
              if($s){
                if($desc) $desc .= '<br />';
                $desc .= $s;
              }
            }

            $data = date_format(date_create($task['created_on']),'d/m/Y H:i:s');
            $dados[] = [
              'id'      => $rowid,
              'number'  => '<a target="_blank" href="' . \URL::to('/taskreport') . '/' .$taskid.'" class="btn btn-default btn-xs" data-taskid="' . $taskid . '" data-task="'.$task['subject'].'" data-projectid="' . $task['project']['id'] . '">' . $taskid . '</a>',
              'description' => $desc. '<br />' .$status,
              'client'  => $projectname . '<br />' . $select,
              'expire'  => $data . $alerta,
              'status'  => $statusid,
              'button'  => $button
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
    public function editTask(Request $request)
    {
      if($request)
      {
        $conn = $this->connectApi();

        $userid = \Session::get('user')['id'];
        $taskid = $request->taskid;

        $tracker = $request->tracker; //required
        $projectid = $request->projectid; //required
        $title = $request->title; //required
        $description = $request->description;
        $due_date = $request->due_date;
        //$category_id = $request->category_id;
        $statusid = $request->statusid; //required
        $assignedid = $request->assignedid;
        $priority = $request->priority; //required
        //$fixed_version_id = $request->fixed_version_id;
        $author_id = $request->author; //required
        //$lock_version = $request->lock_version; //required
        //$created_on = $request->created_on;
        //$updated_on = $request->updated_on;
        $start_date = $request->created_on;
        $done_ratio = $request->done_ratio; //required
        $spent_hours = $request->spent_hours;
        //$parent_id = $request->parent_id;
        //$root_id = $request->root_id;
        //$lft = $request->lft;
        //$rgt = $request->rgt;
        // $is_private = $request->is_private; //required
        //$closed_on = $request->closed_on;
        //$expriration_date = $request->expriration_date;
        //$first_response_date = $request->first_response_date;
        //$issue_sla = $request->issue_sla;
        $novasituacao = $request->novasituacao;

        $custom_fields =[];
        for ($i=1; $i < 50; $i++) {
          $campo = $request['cf_'.$i.'_'.$taskid];
          if($campo!='undefined' && $campo!=NULL) $custom_fields[] = ['id' => $i, 'value' => $campo];
        }

        // try {

          $conn->issue->update($taskid,
            [
              'tracker_id' => $tracker, //required
              'project_id' => $projectid, //required
              'subject' => $title, //required
              'description' => urldecode($description),
              'due_date' => $due_date,
              'status_id' => $statusid, //required
              'assigned_to_id' => $assignedid,
              'priority_id' => $priority, //required
              'author_id' => $author_id, //required
              'start_date' => $start_date,
              'done_ratio' => $done_ratio, //required
              'estimated_hours' => $spent_hours,
              'custom_fields' => $custom_fields
            ]
          );
          // $data = array();
          // $data['issue'] = [
          //     'tracker_id' => $tracker, //required
          //     'project_id' => $projectid, //required
          //     'subject' => $title, //required
          //     'description' => urldecode($description),
          //     'due_date' => '111'.$due_date,
          //     'status_id' => $statusid, //required
          //     'assigned_to_id' => $assignedid,
          //     'priority_id' => $priority, //required
          //     'author_id' => $author_id, //required
          //     'start_date' => $start_date,
          //     'estimated_hours' => $spent_hours,
          //     'custom_fields' => $custom_fields
          //   ];
          // $data_string = json_encode($data);
          //
          // $apiKey = \Session::get('user')['api_key'];
          // $url = env('SD_URL') . '/issues/' . $taskid . '.json?key=' . $apiKey;
          //
          // $ch = curl_init($url);
          // curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
          // curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
          // curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
          // curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
          // curl_setopt($ch, CURLOPT_HTTPHEADER, array(
          //   'Content-Type: application/json',
          //   'Content-Length: ' . strlen($data_string))
          // );
          //
          // $result = curl_exec($ch);
          // curl_close($ch);
          //
          // // if($result){
          // //   $json = (array)json_decode($result);
          // //   $messages = implode('<br />', $json['errors']);
          // //   throw new \Exception($messages);
          // // }

          //somente edição do chamado
          if($novasituacao!=0){

            //se existir obrigatoriedade de apontamento executar o metodo
            if($request->apont==1){

              $dt = $request->spent_on;
              $dt = explode('/',$dt);
              $spent_on = $dt[2].'-'.$dt[1].'-'.$dt[0];

              $hours = $request->hours;
              $atividades = $request->atividades;
              $activity = $request->activity;
              $entrada_trabalho = $request->hora_entrada_trabalho;
              $saida_almoco = $request->hora_saida_almoco;
              $retorno_almoco = $request->hora_retorno_almoco;
              $saida_trabalho = $request->hora_saida_trabalho;
              $tipo_hora = $request->tipo_hora;
              $notes = $request->notes;

              $custom_fields = [];
              if($entrada_trabalho) $custom_fields[] = ['id'=>1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
              if($saida_almoco) $custom_fields[] = ['id'=>2, 'name' => 'Hora Saída Almoço','value' => $saida_almoco];
              if($retorno_almoco) $custom_fields[] = ['id'=>3, 'name' => 'Hora Retorno Almoço','value' => $retorno_almoco];
              if($saida_trabalho) $custom_fields[] = ['id'=>4,'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
              if($atividades) $custom_fields[] = ['id'=>13, 'name' => 'Atividades', 'value' => $atividades];
              if($tipo_hora) $custom_fields[] = ['id'=>17, 'name' => 'Tipo de hora', 'value' => $tipo_hora];

              $conn->time_entry->create([
                'project_id' => $projectid,
                'issue_id' => $taskid,
                'activity_id' => $activity,
                'hours' => $hours,
                'spent_on' => $spent_on,
                'comments' => $atividades,
                'custom_fields' => $custom_fields,
              ]);

              $conn->issue->addNoteToIssue($taskid, $notes);

              $updateTime = $conn->time_entry->all([
                  'issue_id' => $taskid,
                  'project_id' => $projectid,
                ]);

            }
          }

          $updateTasks = $conn->issue->show($taskid);

          $log = new Log;
          $log->datahora = Carbon::now();
          $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
          $log->acao = 'Alteração do Chamado';
          $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
          $log->save();

          return $updateTasks;

        // } catch (\Exception $e) {
        //   echo 'Erro ao tentar salvar!' , $e->getMessage();
        // }

      }
    }

    /*
    ** Funções que permite Alterar o Status do Chamado e Inserir Apontamentos
    */
    public function changeTask(Request $request)
    {
      if($request)
      {
        $conn = $this->connectApi();

        $userid = \Session::get('user')['id'];
        $taskid = $request->taskid;
        $task = $conn->issue->show($taskid)['issue'];

        $statusatual = $task['status']['id'];
        $statusid = $request->statusid;
        $status = $request->status;

        //8 paused para  2 in progress
        if($statusatual!=8 && $statusid!=2){
          $projectid = $request->projectid;
          $dt = $request->spent_on;
          $dt = explode('/',$dt);
          $spent_on = $dt[2].'-'.$dt[1].'-'.$dt[0];

          $hours = $request->hours;
          $atividades = $request->atividades;
          $activity = $request->activity;
          $entrada_trabalho = $request->hora_entrada_trabalho;
          $saida_almoco = $request->hora_saida_almoco;
          $retorno_almoco = $request->hora_retorno_almoco;
          $saida_trabalho = $request->hora_saida_trabalho;
          $notes = $request->notes;

          $custom_fields = [];
          if($entrada_trabalho) $custom_fields[] = ['id'=>1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
          if($saida_almoco) $custom_fields[] = ['id'=>2, 'name' => 'Hora Saída Almoço','value' => $saida_almoco];
          if($retorno_almoco) $custom_fields[] = ['id'=>3, 'name' => 'Hora Retorno Almoço','value' => $retorno_almoco];
          if($saida_trabalho) $custom_fields[] = ['id'=>4,'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
          if($atividades) $custom_fields[] = ['id'=>13, 'name' => 'Atividades', 'value' => $atividades];

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
          8 => 'Paused'
        ];

        $log = new Log;
        $log->datahora = Carbon::now();
        $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
        $log->acao = 'Mudança do Status de ' . $descstatus[$statusatual] . ' para ' . $status;
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
      if($request)
      {
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
        $log->datahora = Carbon::now();
        $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
        $log->acao = 'Trasferido para ' . $updateTasks['author']['name'];
        $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
        $log->save();

        return $updateTasks;

      }
    }


    /*
    ** Funções do Painel Meus Apontamentos
    */
    public function myTime(Request $request)
    {
      if($request)
      {
        $conn = $this->connectApi();
        $userid = \Session::get('user')['id'];
        $rowid = 1;

        $mytimes = $conn->time_entry->all(
          [
            'user_id' => $userid
          ]
        );

        $dados = array();
        if(isset($mytimes['time_entries'])){
        foreach ($mytimes['time_entries'] as $mytime) {
          $issueid = $mytime['issue']['id'];
          $task = $conn->issue->show($issueid);
          $statusid = $task['issue']['status']['id'];

          $data = date_format(date_create($mytime['spent_on']),'d/m/Y H:i:s');
          if($statusid==5){
            $dados[] = [
              'id'      => $rowid,
              'number'  => '<a href="#" class="btn btn-default btn-xs taskdetail" data-taskid="' . $issueid . '" data-task="'.$task['issue']['subject'].'" data-projectid="' . $task['issue']['project']['id'] . '" data-toggle="modal" data-target="#modal-detail" >' . $issueid . '</a>',
              'date'    => $data,
              'task'    => $task['issue']['subject'],
              'project' => $task['issue']['project']['name'],
              'amount'  => $mytime['hours']
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
      if($request)
      {
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

        foreach ($times['time_entries'] as $time)
        {
          $issue_id = $time['issue']['id'];
          $custom = $time['custom_fields'];

          $owner_id = $time['user']['id'];
          $user_id = \Session::get('user')['id'];

          $edit = false;
          if($user_id==$owner_id) $edit = true;

          if($issue_id==$request->taskid)
          {
            $data = date_format(date_create($time['spent_on']),'d/m/Y');
            $dados[] = [
              'id'        => $rowid,
              'timeid'    => $time['id'],
              'issueid'   => $issue_id,
              'atividade' => $atividade,
              'activityid'=> $time['activity']['id'],
              'activityname'=> $time['activity']['name'],
              'hours'     => $time['hours'],
              'spent_on'  => $data,
              'edit'      => $edit,
              'entrada_trabalho'  => $time['custom_fields'][0]['value'],
              'saida_almoco'      => $time['custom_fields'][1]['value'],
              'retorno_almoco'    => $time['custom_fields'][2]['value'],
              'saida_trabalho'    => $time['custom_fields'][3]['value'],
              'atividades'        => $time['custom_fields'][4]['value'],
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
      if($request)
      {
        $conn = $this->connectApi();

        $taskid = $request->taskid;
        $projectid = $request->projectid;
        $dt = $request->spent_on;
        $dt = explode('/',$dt);
        $spent_on = $dt[2].'-'.$dt[1].'-'.$dt[0];

        $hours = $request->hours;
        $atividades = $request->atividades;
        $activity = $request->activity;
        $entrada_trabalho = $request->hora_entrada_trabalho;
        $saida_almoco = $request->hora_saida_almoco;
        $retorno_almoco = $request->hora_retorno_almoco;
        $saida_trabalho = $request->hora_saida_trabalho;
        $tipo_hora = $request->tipo_hora;
        $notes = $request->notes;

        $custom_fields = [];
        if($entrada_trabalho) $custom_fields[] = ['id'=>1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
        if($saida_almoco) $custom_fields[] = ['id'=>2, 'name' => 'Hora Saída Almoço','value' => $saida_almoco];
        if($retorno_almoco) $custom_fields[] = ['id'=>3, 'name' => 'Hora Retorno Almoço','value' => $retorno_almoco];
        if($saida_trabalho) $custom_fields[] = ['id'=>4,'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
        if($atividades) $custom_fields[] = ['id'=>13, 'name' => 'Atividades', 'value' => $atividades];
        if($tipo_hora) $custom_fields[] = ['id'=>17, 'name' => 'Tipo de hora', 'value' => $tipo_hora];

        $conn->time_entry->create([
          'project_id' => $projectid,
          'issue_id' => $taskid,
          'activity_id' => $activity,
          'hours' => $hours,
          'spent_on' => $spent_on,
          'comments' => $atividades,
          'custom_fields' => $custom_fields,
        ]);

        $conn->issue->addNoteToIssue($taskid, $notes);

        $updateTime = $conn->time_entry->all([
            'issue_id' => $taskid,
            'project_id' => $projectid,
          ]);

        $updateTasks = $conn->issue->show($taskid);

        $log = new Log;
        $log->datahora = Carbon::now();
        $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
        $log->acao = 'Apontamento de Horas';
        $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
        $log->save();

        return $updateTime;
      }
    }

    /*
    ** Funções que permite Atulizar um Apontamento existente
    */
    public function saveTime(Request $request)
    {
      if($request)
      {
        $conn = $this->connectApi();

        $timeid = $request->timeid;
        $taskid = $request->taskid;

        $dt = $request->spent_on;
        $dt = explode('/',$dt);
        $spent_on = $dt[2].'-'.$dt[1].'-'.$dt[0];

        $hours = $request->hours;
        $atividades = $request->atividades;
        $activity = $request->activity;
        $entrada_trabalho = $request->hora_entrada_trabalho;
        $saida_almoco = $request->hora_saida_almoco;
        $retorno_almoco = $request->hora_retorno_almoco;
        $saida_trabalho = $request->hora_saida_trabalho;

        $custom_fields = [];
        if($entrada_trabalho) $custom_fields[] = ['id'=>1, 'name' => 'Hora Entrada Trabalho', 'value' => $entrada_trabalho];
        if($saida_almoco) $custom_fields[] = ['id'=>2, 'name' => 'Hora Saída Almoço','value' => $saida_almoco];
        if($retorno_almoco) $custom_fields[] = ['id'=>3, 'name' => 'Hora Retorno Almoço','value' => $retorno_almoco];
        if($saida_trabalho) $custom_fields[] = ['id'=>4,'name' => 'Hora Saída Trabalho', 'value' => $saida_trabalho];
        if($atividades) $custom_fields[] = ['id'=>13, 'name' => 'Atividades', 'value' => $atividades];

        $conn->time_entry->update($timeid, [
          'activity_id' => $activity,
          'hours' => $hours,
          'spent_on' => $spent_on,
          'comments' => $atividades,
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
      if($request)
      {
        $conn = $this->connectApi();

        $timeid = $request->timeid;
        $deleteTime = $conn->time_entry->show($timeid);

        $conn->time_entry->remove($timeid);

        $log = new Log;
        $log->datahora = Carbon::now();
        $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
        $log->acao = 'Exclusão do Apontamento de Horas';
        $log->json = json_encode($deleteTime, JSON_UNESCAPED_UNICODE);
        $log->save();

        return $deleteTime;
      }
    }

    /*
    ** Funções que permite Inserir Notas ao Chamado
    */
    public function saveNotes(Request $request)
    {
      if($request)
      {
        $conn = $this->connectApi();

        $userid = \Session::get('user')['id'];
        $taskid = $request->taskid;
        $notes = urldecode($request->notes);

        $conn->issue->addNoteToIssue($taskid, $notes);

        $updateTasks = $conn->issue->show($taskid);

        $log = new Log;
        $log->datahora = Carbon::now();
        $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
        $log->acao = 'Inclusão de Notas';
        $log->json = json_encode($updateTasks, JSON_UNESCAPED_UNICODE);
        $log->save();

        return $updateTasks;

      }
    }

    /*
    ** Funções que permite Inserir Notas ao Chamado
    */
    public function anexar(Request $request)
    {
      if($request)
      {

        $file = $request->file('fileUpload');
        $filecontent = file_get_contents($file->getPathName());
        $filename = $file->getClientOriginalName();
        $contenttype = $file->getMimeType();

        $conn = $this->connectApi();
        $taskid = $request->taskid;

        $upload = json_decode($conn->attachment->upload($filecontent));
        $conn->issue->attach($taskid, [
            'token' => $upload->upload->token,
            'filename' => $filename,
            'description' => $filename,
            'content_type' => $contenttype,
        ]);

        $updateTasks = $conn->issue->show($taskid);

        $log = new Log;
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
      if($request){
        $conn = $this->connectApi();

        $task = $conn->issue->show($request->taskid,[
          'include' => [
            'attachments'
          ]
          ])['issue'];

        $projectid = $task['project']['id'];
        if($request->projectid!='') $projectid = $request->projectid;

        $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = '.$projectid.'  ORDER BY tra.name';
        $trackers = \DB::connection('mysql_redmine')->select($sql);

        $dados = [];
        $files = [];
        if(isset($task['attachments'])){
          $dir = public_path() . '/anexos/';
          if(!is_dir($dir)) mkdir($dir, 0700);

          foreach ($task['attachments'] as $file) {
            $file_content = $conn->attachment->download($file['id']);
            //\Storage::disk('local')->put($file['filename'], $file_content);
            $filename = $dir . $file['filename'];
            file_put_contents($filename, $file_content);
            $url = '/anexos/' . $file['filename'];

            $files[] = ['filename' => $file['filename'], 'url' => $url];
          }
        }

        $journals = $this->journalsTaskMysql($request->taskid);

        return view('historico',[
          'trackers' => $trackers,
          'journals' => $journals,
          'files' => $files,
        ])->render();
      }
    }

    /*
    ** Visualiza e Edita os Apontamentos do Chamado
    */
    public function editHours(Request $request)
    {
      if($request){
        $conn = $this->connectApi();

        $task = $conn->issue->show($request->taskid,[
          'include' => [
            'attachments'
          ]
          ])['issue'];

        $projectid=0;
        if($task['project']['id']) $projectid = $task['project']['id'];
        if($request->projectid!='') $projectid = $request->projectid;

        $sql = 'SELECT tra.id, tra.name FROM trackers tra INNER JOIN projects_trackers prj ON tra.id = prj.tracker_id WHERE prj.project_id = '.$projectid.'  ORDER BY tra.name';
        $trackers = \DB::connection('mysql_redmine')->select($sql);

        $status = $conn->issue_status->all();
        $priorities = $conn->issue_priority->all();
        $custom_fields = $conn->custom_fields->all();

        $dados = $conn->time_entry->all(
          [
            'issue_id' => $request->taskid,
          ]
        )['time_entries'];

        //dd($dados);
        // $dados = [];
        // if(isset($times['time_entries'])){
        //   foreach ($times['time_entries'] as $time)
        //   {
        //     if(isset($time['issue'])){
        //       $issue_id = $time['issue']['id'];
        //       if($issue_id==$request->taskid) $dados[] = $time;
        //     }
        //   }
        // }

        $activities = $conn->time_entry_activity->all();

        return view('edithours',[
          'task' => $task,
          'times' => $dados,
          'trackers' => $trackers,
          'status' => $status['issue_statuses'],
          'activities' => $activities['time_entry_activities'],
          'priorities' => $priorities['issue_priorities'],
          'custom_fields' => $custom_fields['custom_fields'],
        ])->render();
      }
    }

}
