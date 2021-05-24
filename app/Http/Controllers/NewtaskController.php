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

class NewtaskController extends Controller
{
    //criar um novo chamado 
    public function newtask($project_id){
        $conn = HomeController::connectApi();
        $user_id = \Session::get('user')['id'];
        $project_id = $project_id;
        $priorities = $conn->issue_priority->all();
        $data = date("Y-m-d");
        $activities = [];
        if (isset($activity['time_entry_activities']))
            $activities = $activity['time_entry_activities'];

        $contador = Cronometro::listarContadorEmAberto();
        //tracker do chamado
        $tipo = 'SELECT  tck.id, tck.name, tck.position FROM  projects_trackers pj_tck 
        INNER JOIN trackers tck on pj_tck.tracker_id = tck.id
        WHERE pj_tck.project_id = '.$project_id.' ORDER BY tck.position ASC';

        $tipo = \DB::connection('mysql_redmine')->select($tipo);
        //nome do projeto

        $project_name = 'SELECT name FROM projects WHERE id = '.$project_id.'';
        $project_name = \DB::connection('mysql_redmine')->select($project_name);

        //versão
        $version = 'SELECT id, name FROM versions WHERE status = "open"  AND project_id  = '.$project_id.'';   

        $version = \DB::connection('mysql_redmine')->select($version);     
        
        //categoria
        $category = 'SELECT id,name, assigned_to_id FROM issue_categories WHERE project_id = '.$project_id.'';

        $category = \DB::connection('mysql_redmine')->select($category);     
        $option_group = '';

        $usuarios = 'SELECT * FROM (SELECT DISTINCT u.id, CONCAT(u.firstname," ",u.lastname) nome
        FROM users u
        inner join members m on m.user_id = u.id
        inner join projects pj on pj.id = m.project_id
        inner join member_roles mr on mr.member_id = m.id
        inner join roles r on r.id = mr.role_id
        where pj.id = '.$project_id.' and u.status <> 3 and r.assignable = true and u.type <> "Group" order by nome asc) analistas';
        $usuarios = \DB::connection('mysql_redmine')->select($usuarios);     


        $grupos = 'SELECT * FROM (SELECT DISTINCT u.id, concat(u.firstname,"",u.lastname) nome 
        FROM users u
        inner join members m on m.user_id = u.id
        inner join projects pj on pj.id = m.project_id
        inner join member_roles mr on mr.member_id = m.id
        inner join roles r on r.id = mr.role_id
        where pj.id = '.$project_id.' and u.status <> 3 and r.assignable = true and u.type = "Group" order by nome asc) grupos';
        $grupos = \DB::connection('mysql_redmine')->select($grupos);
        
        $option = '<option value=""></option>';

            foreach ($usuarios as $users) {
                $option .= '<option value="' . $users->id . '">' . $users->nome . '</option>';
            }
            //observadores
            $watchers =  '<select name="new_watcher[]" multiple id="new_watcher" class="form-control input-sm" data-projectid="' . $project_id . '"  placeholder="" style="width: 100%
            ;">' . $option . '</select>';

            foreach ($grupos as $groups) {
                $option_group .= '<option value="' . $groups->id . '">' . $groups->nome . '</option>';
            }

            $option .= '<optgroup label="Grupos">' . $option_group . '</optgroup>';

            $transferirpara = '<select name="" id="new_transferir" class="form-control input-sm" data-projectid="' . $project_id . '"  placeholder="" style="width: 100%
            ;">' . $option . '</select>';

            
            //parent_id
            $parent_id = $conn->issue->all([
                'project_id' => $project_id,
                'limit' => 100,
            ]);

        return view('newtask', [
            'contador' => $contador,
            'activities' => $activities,
            'tipo' => $tipo,
            'project' => $project_id,
            'transferir'=>  $transferirpara,
            'priorities' => $priorities['issue_priorities'],
            'versao' => $version,
            'categoria' => $category,
            'parent' => $parent_id,
            'watchers' => $watchers,
            'data' => $data,
            'name' => $project_name,

        ])->render();
    }

    //filtrar de acordo com o status selecionado
    public function new_situacao(Request $request){
        if ($request) {
        $user_id = \Session::get('user')['id'];
        $tipo = $request->tipo;
        $project_id = $request->project_id;
        $dados = [];


        $situacao = 'SELECT DISTINCT inew.id id, inew.name name
        FROM workflows w
        INNER JOIN issue_statuses inew ON inew.id = w.new_status_id
        INNER JOIN (
            SELECT mr.role_id
            FROM members mb
            INNER JOIN member_roles mr ON mb.id = mr.member_id
            WHERE mb.user_id = '.$user_id.'  and mb.project_id = '.$project_id.'
        ) grp ON w.role_id = grp.role_id
        WHERE w.type = "WorkflowTransition"
            AND w.old_status_id=0
            AND w.tracker_id = '.$tipo.'';
            $situacao = \DB::connection('mysql_redmine')->select($situacao);
        //caso for nulo pegar o valor padrão definido
        if(!$situacao){
            $situacao  = 'SELECT t.default_status_id id, i.name from trackers t 
            left join issue_statuses i on t.default_status_id = i.id 
            where t.id = '.$tipo.'';
             $situacao = \DB::connection('mysql_redmine')->select($situacao);
        }
            return json_encode($situacao, JSON_UNESCAPED_UNICODE);
        }     

    }
    public function rules(Request $request){
        if ($request) {
        $user_id = \Session::get('user')['id'];
        $tipo = $request->tipo;
        $project_id = $request->project_id;
        $status_id = $request->status;

        $rules = 'SELECT distinct w.field_name name, w.rule rule
        FROM workflows w
        INNER JOIN (
            SELECT mr.role_id
            FROM members mb
            INNER JOIN member_roles mr ON mb.id = mr.member_id
            WHERE mb.user_id = '.$user_id.' and mb.project_id = '.$project_id.'
        ) grp ON w.role_id = grp.role_id
        WHERE w.type = "WorkflowPermission"
            AND w.field_name in ("project_id","tracker_id","subject","priority_id","is_private","assigned_to_id","fixed_version_id","parent_issue_id","start_date","due_date","estimated_hours","done_ratio","description","category_id")
            AND w.old_status_id='.$status_id.'
            AND w.tracker_id = '.$tipo.'';

        $rules = \DB::connection('mysql_redmine')->select($rules);
        $title = '';
        $priority = '';
        $assigned_to = '';    
        $description = '';
        $spent_hours= '';
        $due_date = '';
        $created_on = '';
        $tarefa_pai = '';
        $version = '';
        $category = '';
        $private = '';
        $priority = '';
        $assigned_to = '';

        //Verifica as regras dos campos fixos
        if($rules){
        foreach ($rules as $rule){
            if($rule->name == 'subject'){
                $title = $rule->rule ;
            }
            //
            if($rule->name == 'assigned_to_id'){
                $assigned_to = $rule->rule;
            }
            //
            if($rule->name == 'priority_id'){
                $priority = $rule->rule;
            }
            //
            if($rule->name == 'is_private'){
                $is_private = $rule->rule;
            }
            //
            if($rule->name == 'category_id'){
                $category = $rule->rule;
            }
            //
            if($rule->name == 'fixed_version_id'){
                $version = $rule->rule;
            }
            //
            if($rule->name == 'parent_issue_id'){
                $tarefa_pai = $rule->rule;
            }
            //
            if($rule->name == 'start_date'){
                $created_on = $rule->rule;
            }
            //
            if($rule->name == 'due_date'){
                $due_date = $rule->rule;
            }
            //
            if($rule->name == 'estimated_hours'){
                $spent_hours = $rule->rule;
            }
            //
            if($rule->name == 'description'){
                $description = $rule->rule;
            }
            //
       
        }
    }
        $dados[] = 
        [
            'title' => $title,
            'description' => $description,
            'spent_hours' => $spent_hours,
            'due_date' => $due_date,
            'created_on' => $created_on,
            'tarefa_pai' => $tarefa_pai,
            'version' => $version,
            'category' => $category,
            'private' => $private,
            'priority' => $priority,
            'assigned_to' => $assigned_to,

        ];

        return $dados;

    }
}
public function campos_customizados(Request $request){

    if($request){
        $user_id = \Session::get('user')['id'];
        $tipo = $request->tipo;
        $project_id = $request->project_id;
        $status_id = $request->status;

        $conn = HomeController::connectApi();

        $sql = 'SELECT distinct id, name, is_required, field_format, max(rule) rule, possible_values from
        (SELECT  cf.id, cf.name, cf.field_format, cf.is_required, wf.rule, cf.possible_values
                FROM (select distinct * from
                        (select custom_field_id from custom_fields_projects cfp
        where cfp.project_id = '.$project_id.' AND custom_field_id in (select custom_field_id from custom_fields_trackers cft where cft.tracker_id = '.$tipo.')
                            UNION
                        SELECT custom_field_id from custom_fields_trackers cft
                        where cft.tracker_id =  '.$tipo.' and cft.custom_field_id in (select id from custom_fields where is_for_all = true)) fil
                        inner join custom_fields cf on cf.id = fil.custom_field_id
                where  cf.visible = true) cf
        left JOIN custom_fields_projects cfp ON cf.id=cfp.custom_field_id and cfp.project_id =  '.$project_id.'
        left JOIN workflows wf ON cf.id = wf.field_name AND wf.tracker_id = '.$tipo.' AND wf.old_status_id =  '.$status_id.'
            AND wf.role_id in (SELECT role_id FROM member_roles
                                WHERE member_id IN (SELECT id FROM members WHERE user_id =  '.$user_id.' and project_id= '.$project_id.')) order by wf.rule desc) sub
        group by id, name, field_format, possible_values';
        $campos = \DB::connection('mysql_redmine')->select($sql);

        
        

        $regras = array_column($campos, 'rule', 'id');
        //dd($regras);

        $html = '';
        foreach ($campos as $key => $value) {
            $required = '';
            $readonly = '';
            $is_required = '';

            if ($value->is_required == 1) {
                $required = 'issue_required';
                $is_required = ' <span class="text-red">*</span>';
            }

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

            $tam = 3;
            if ($value->field_format == "text") $tam = 12;
            $html .= '<div class="col-md-' . $tam . '">' .
                '<div class="form-group" id="help_cf_' . $value->id . '" >' .
                '<label for="title">' . $value->name . ' [' . $value->id . ']' . $is_required . '</label>';

            switch ($value->field_format) {
                case 'string':
                    $html .= '<input type="text" class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->name . '" id="cf_' . $value->id . '" value="">';
                    break;
                case 'attachment':
                     $html .= '<input class="form-control input-sm" multiple="multiple" enctype= "multipart/form-data" type="file" name="customUpload[]" id="customUpload" />
                    ';
                break;
                case 'bool':
                        $opt = '<option value="0">Não</option>';
                        $opt .= '<option value="1">Sim</option>';
                
                    $html .= '<select class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->name . '" id="cf_' . $value->id . '">' . $opt . '</select>';
                    break;
                case 'text':
                    $html .= '<textarea rows="4" class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->name . '" id="cf_' . $value->id . '"></textarea>';
                    break;
                case 'list':
                    $html .= '<select class="form-control input-sm ' . $required . '" ' . $readonly . ' name="cf_' . $value->name . '" id="cf_' . $value->id . '">';
                    if ($value->possible_values) {
                        $possible_values = preg_replace("/\r|\n/", "|", $value->possible_values);
                        $opt = explode('|', $possible_values);
                        $options = '';
                        foreach ($opt as $op) {
                            $op = str_replace('-','',$op);
                            $op = str_replace("'","",$op);
                            
                            $options .= '<option value="' . $op . '" >' . $op . '</option>';
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

        return $html;
    }
}
//Criar novo chamado
public function savenewtask(Request $request){
    if($request){
        $conn = HomeController::connectApi();
        $user_id = \Session::get('user')['id'];
        $project_id = $request->project_id;
        $tracker_id = $request->tracker_id;
        $status_id = $request->status_id;
        $subject = $request->subject;
        // $subject = HomeController\convert_encoding($subject, 'UTF-8');
        $priority = $request->priority; 
        $description = $request->description;
        // $description = HomeController\convert_encoding($description, 'UTF-8');
        $category_id = $request->category_id;
        $assigned_to_id = $request->assigned_to_id;
        $is_private = $request->is_private;
        $version = $request->version;
        $watchers = $request->input('watchers');
        $watchers = explode(',',$watchers);
        if($watchers = null) $watchers = '';

        $start_date = date_format(date_create($request->start_date),'Y-m-d');
        $due_date = date_format(date_create($request->due_date),'Y-m-d');
        $estimated_hours = $request->estimated_hours;
        $exist = strstr($estimated_hours, ':');
        if($exist){
        $hours = explode(':',$estimated_hours);
        $estimated_hours = $hours[0] + ($hours[1]/60);
        }
        $author_id = $user_id;
        $parent_issue = $request->parent_issue;
        
        $custom_fields = [];
        
        for ($i = 1; $i < 50; $i++) {
            $campo = $request['cf_' . $i];
            if ($campo != 'undefined' && $campo != NULL) $custom_fields[] = ['id' => $i, 'value' => $campo];
        }
        
        
            $issue_data = [];
            $issue_data['tracker_id'] = $tracker_id; //required
            $issue_data['project_id'] = $project_id; //required
            $issue_data['subject'] = $subject; //required
            $issue_data['description'] = urldecode($description);
            $issue_data['due_date'] = $due_date;
            $issue_data['status_id'] = $status_id; //required
            $issue_data['assigned_to_id'] = $assigned_to_id;
            $issue_data['priority_id'] = $priority; //required
            $issue_data['author_id'] = $author_id; //required
            $issue_data['start_date'] = $start_date;
            $issue_data['estimated_hours'] = $estimated_hours;
            $issue_data['watcher_user_ids'] = $watchers;
            $issue_data['fixed_version_id'] = $version;
            $issue_data['category_id'] = $category_id;
            $issue_data['parent_issue_id'] = $parent_issue;
            $issue_data['is_private'] = $is_private;
            $issue_data['custom_fields'] = $custom_fields;

            if($request->upload !=""){
            $issue_data['uploads'] = json_decode($request->upload);

        }
             //return $issue_data;
             $issues = $conn->issue->create($issue_data);

            return json_encode($issues); 

            $log->datahora = Carbon::now();
            $log->analista = \Session::get('user')['firstname'] . ' ' . \Session::get('user')['lastname'];
            $log->acao = 'Criação de Chamado';
            $log->json = json_encode($issues, JSON_UNESCAPED_UNICODE);
            $log->save();



            }
            
    } 
    public function anexarnew(Request $request){
        
        $conn = HomeController::connectApi();

        if($files = $request->file('fileUpload')){

        foreach ($files as $file) {
            $filecontent = file_get_contents($file->getPathName());
            $filename = $file->getClientOriginalName();
            $contenttype = $file->getMimeType();
            $filesize = $file->getClientSize();


            // if($filesize <= 48){
            $upload = json_decode($conn->attachment->upload($filecontent));
            $arquivo[] = [
                'token' => $upload->upload->token,
                'filename' => $filename,
                'description' => $filename,
                'content_type' => $contenttype,
            ];
            
            return json_encode($arquivo);
        }
        // 
    }
    }
    //anexar campo customizado 29
    public function anexarcustom(Request $request){
        
        $conn = HomeController::connectApi();
        $taskid = $request->taskid;

        if($files = $request->file('customUpload')){

        foreach ($files as $file) {
            $filecontent = file_get_contents($file->getPathName());
            $filename = $file->getClientOriginalName();
            $contenttype = $file->getMimeType();
            $filesize = $file->getClientSize();


            if($filesize <= 48){
            $upload = json_decode($conn->attachment->upload($filecontent));
    
           $custom = $conn->issue->attach($taskid, [

                'token' => $upload->upload->token,
                'filename' => $filename,
                'description' => $filename,
                'content_type' => $contenttype,
            ]);  

        }
        $attachment_id = 'SELECT id FROM attachments ORDER BY id DESC LIMIT 1';
        $attachment = \DB::connection('mysql_redmine')->select($attachment_id);
        
        foreach($attachment as $attach){
        //    
        $custom_values = 'SELECT id FROM custom_values WHERE customized_id = '.$taskid.' AND custom_field_id = 29 AND customized_type = "Issue"'; 
            
        $custom_values = \DB::connection('mysql_redmine')->select($custom_values);
        foreach($custom_values as $value){ 
        //   
        $update = 'UPDATE attachments SET container_id = '.$value->id.', container_type = "CustomValue" where id = '.$attach->id.'';

        $update = \DB::connection('mysql_redmine')->select($update);

        $custom_fields = [];
        $custom_fields[] = ['id' => 29, 'value' =>$attach->id];    
        $fields = $conn->issue->update($taskid,
        [
            'custom_fields' =>$custom_fields,
        ]
        );

        }
        }
        return json_encode($fields);

        }
    }
    }
    
}
   

