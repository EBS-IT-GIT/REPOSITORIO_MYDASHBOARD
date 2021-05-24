<?php

namespace App\Http\Controllers;

use App\Cronometro;
use Redmine\Client as Client;
use Illuminate\Http\Request;
use App\Http\Controllers\HomeController;

class LogController extends Controller
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

      return view('logs',
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
      $sql .= ' WHERE status = 1 AND type="User"';
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

      $sql = 'SELECT l.json->>"$.issue.project.id" id_projeto, l.json->>"$.issue.project.name" projeto,
                 l.json->>"$.issue.id" id_chamado,l.json->>"$.issue.subject"chamado, l.json->>"$.issue.status.name" situacao,
                 l.json->>"$.issue.total_spent_hours" horas, DATE_FORMAT(l.json->>"$.issue.start_date","%d/%m/%Y") data,
                 l.json->>"$.issue.assigned_to.id" id_analista, l.analista,
                 DATE_FORMAT(l.datahora,"%d/%m/%Y %H:%i:%s") datahora, l.acao,
                 CASE json->>"$.issue.priority.id"
             			WHEN 5 THEN "<span class=\"label label-danger\">prioridade 1"
                  WHEN 4 THEN "<span class=\"label label-warning\">prioridade 2"
                  WHEN 3 THEN "<span class=\"label label-info\">prioridade 3"
                  WHEN 2 THEN "<span class=\"label label-success\">prioridade 4"
                  ELSE "<span class=\"label label-primary\">prioridade 5"
                 END prioridade
              FROM logs l
              WHERE 1=1 ';

      if($request->usuario) {
        $sql .= ' AND l.json->>"$.issue.assigned_to.id" = ' . $request->usuario;
      }
      if($request->projeto) $sql .= ' AND l.json->>"$.issue.project.id" = ' . $request->projeto;
      if($request->situacao) $sql .= ' AND l.json->>"$.issue.status.id" = ' . $request->situacao;
      if($request->inicio && $request->termino) {
        $sql .= ' AND DATE_FORMAT(l.datahora,"%Y-%m-%d") BETWEEN "' . $request->inicio . '" AND "' . $request->termino .'"';
      }

      $sql .= ' ORDER BY l.datahora DESC';

      //var_dump($sql);exit;
      $dados = \DB::connection()->select($sql);

      return json_encode($dados, JSON_UNESCAPED_UNICODE);
    }

}
