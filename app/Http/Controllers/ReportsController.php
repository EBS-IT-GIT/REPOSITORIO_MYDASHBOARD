<?php

namespace App\Http\Controllers;

use App\Cronometro;
use Redmine\Client as Client;
use Illuminate\Http\Request;
use App\Http\Controllers\HomeController;

class ReportsController extends Controller
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

      $conn = HomeController::connectApi();
      $activity = $conn->time_entry_activity->all();
      $activities = [];
      if(isset($activity['time_entry_activities']))
        $activities = $activity['time_entry_activities'];
      $contador = Cronometro::listarContadorEmAberto();

      return view('reports',
        [
          'usuarios'=> $this->listarUsuarios(),
          'projetos'=> $this->listarProjetos(),
          'situacao'=> $this->listarSituacao(),
          'contador'=> $contador,
          'activities'=> $activities,
        ]
      );
    }

    public function listarUsuarios()
    {
      $isAdmin = \Session::get('isAdmin');

      $sql = 'SELECT id, CONCAT_WS(" ",firstname, lastname) name FROM users';
      $sql .= ' WHERE type="User"';
      if($isAdmin!=9)
        $sql .= ' AND id = '.\Auth::user()->id;
      $sql .= ' ORDER BY name';
      $usuarios = \DB::connection('mysql_redmine')->select($sql);

      return $usuarios;
    }

    public function listarProjetos(){
      $isAdmin = \Session::get('isAdmin');

      $sql = 'SELECT id, name FROM projects';
      // if($isAdmin!=9)
      //   $sql .= 'WHERE id = '.\Auth::user()->id;
      $sql .= ' ORDER BY name';
      $projetos = \DB::connection('mysql_redmine')->select($sql);

      return $projetos;
    }

    public function listarSituacao()
    {

      $sql = 'SELECT id, name FROM issue_statuses';
      $sql .= ' ORDER BY name';
      $situacao = \DB::connection('mysql_redmine')->select($sql);

      return $situacao;
    }

    public function toJson(Request $request)
    {

      $sql = 'SELECT prj.id id_projeto, prj.name projeto,
              	 isu.id id_chamado, isu.subject chamado, sit.name situacao,
              	 tim.id id_horas, TRUNCATE(IFNULL(tim.hours,0),2) horas,
                 DATE_FORMAT(IFNULL(isu.created_on,""),"%d/%m/%Y") data_abertura,
                 DATE_FORMAT(IFNULL(tim.spent_on,""),"%d/%m/%Y") data_apontamento,
              	 usr.id id_analista, IFNULL(CONCAT_WS(" ",usr.firstname,usr.lastname),"") analista,
                 STR_TO_DATE(IFNULL(entrada.value,"00:00"),"%H:%i") hora_entrada,
                 STR_TO_DATE(IFNULL(saida_almoco.value,"00:00"),"%H:%i") hora_saida_almoco,
                 STR_TO_DATE(IFNULL(retorno_almoco.value,"00:00"),"%H:%i") hora_retorno_almoco,
                 STR_TO_DATE(IFNULL(saida.value,"00:00"),"%H:%i") hora_saida,
                 IFNULL(tipohora.value,"") tipo_hora,
                 IFNULL(atividades.value,"") atividades,
                 tim.activity_id,
                 IF (DATE(isu.start_date) > CURDATE(),"<span class=\"label label-default\">prioridade 6",
                CASE isu.priority_id
            			WHEN 5 THEN "<span class=\"label label-danger\">prioridade 1"
                  WHEN 4 THEN "<span class=\"label label-warning\">prioridade 2"
                  WHEN 3 THEN "<span class=\"label label-info\">prioridade 3"
                  WHEN 2 THEN "<span class=\"label label-success\">prioridade 4"
                ELSE "<span class=\"label label-primary\">prioridade 5" END) prioridade
              FROM projects prj
              	INNER JOIN issues isu ON prj.id = isu.project_id
                INNER JOIN issue_statuses sit ON sit.id = isu.status_id
              	LEFT OUTER JOIN time_entries tim ON isu.id = tim.issue_id
              	INNER JOIN users usr ON usr.id = tim.user_id
                INNER JOIN (
                	SELECT customized_id, value FROM custom_values
            		  WHERE custom_field_id = 1
            	  ) entrada ON tim.id = entrada.customized_id
            	  INNER JOIN (
            		  SELECT customized_id, value FROM custom_values
            		  WHERE custom_field_id = 2
            	  ) saida_almoco ON tim.id = saida_almoco.customized_id
            	  INNER JOIN (
            		  SELECT customized_id, value FROM custom_values
            		  WHERE custom_field_id = 3
            	  ) retorno_almoco ON tim.id = retorno_almoco.customized_id
            	  INNER JOIN (
            		  SELECT customized_id, value FROM custom_values
            		  WHERE custom_field_id = 4
            	  ) saida ON tim.id = saida.customized_id
                INNER JOIN (
            		  SELECT customized_id, value FROM custom_values
            		  WHERE custom_field_id = 13
            	  ) atividades ON tim.id = atividades.customized_id
                INNER JOIN (
            		  SELECT customized_id, value FROM custom_values
            		  WHERE custom_field_id = 17
            	  ) tipohora ON tim.id = tipohora.customized_id
              WHERE 1=1 ';

      // if($request->usuario) {
      //   $sql .= ' AND usr.id = ' . $request->usuario;
      // }else{
        $sql .= ' AND usr.id = ' . \Session::get('user')['id'];
      //}
      if($request->projeto) $sql .= ' AND prj.id = ' . $request->projeto;
      if($request->situacao) $sql .= ' AND sit.id = ' . $request->situacao;
      if($request->inicio && $request->termino) {
        $sql .= ' AND DATE_FORMAT(tim.spent_on,"%Y-%m-%d") BETWEEN "' . $request->inicio . '" AND "' . $request->termino .'"';
      }else{
        $sql .= ' AND tim.spent_on = NOW() ';
      }

      $sql .= ' ORDER BY tim.spent_on DESC';

      // var_dump($sql);exit;
      $dados = \DB::connection('mysql_redmine')->select($sql);

      return json_encode($dados, JSON_UNESCAPED_UNICODE);
    }

}
