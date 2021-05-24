<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
Route::get('/', 'HomeController@index')->name('home');
Route::get('/projects/{project_name}/{project_id}', 'HomeController@project');
// Route::get('/teste', 'HomeController@teste');


Route::get('/painel', 'HomeController@home');

Auth::routes();

Route::get('/home', 'HomeController@index')->name('home');
/*
* middleware:auth - proteje todas as rotas exigindo autenticação
*/
Route::group(['middleware' => ['auth']], function () {
//novos chamados
  Route::post('/issueslist', 'HomeController@issuesList');
  Route::post('/new_situacao', 'NewtaskController@new_situacao');
  Route::post('/rules', 'NewtaskController@rules');
  Route::get('/newtask/{project_id}', 'NewtaskController@newtask');
  Route::post('/newcustomfields', 'NewtaskController@campos_customizados');
  Route::post('/savenewtask','NewtaskController@savenewtask');
  Route::post('/anexarnew','NewtaskController@anexarnew');
  Route::post('/anexarcustom','NewtaskController@anexarcustom');

  ///brk
  Route::post('/anexosbrk','HomeController@anexosbrk');

   
  /////
  Route::get('/backlogs','BacklogController@backlog');
  Route::post('/backloglist','BacklogController@backloglist');

  Route::post('/taskdetail', 'HomeController@taskDetail');
  Route::get('/taskreport/{taskid}', 'HomeController@taskReport');
  Route::post('/changeviewtask', 'HomeController@changeViewTask');
  Route::post('/newtasksmysql/json', 'HomeController@newTasksMysql');
  Route::post('/capturetask', 'HomeController@captureTask');
  Route::post('/mytasks/json', 'HomeController@myTasks');
  Route::post('/edittask', 'HomeController@editTask');
  Route::post('/changetask', 'HomeController@changeTask');
  Route::post('/transfertask', 'HomeController@transferTask');
  Route::post('/mytime/json', 'HomeController@myTime');
  Route::post('/mygmuds/json', 'HomeController@myGmuds');
  Route::post('/myrcas/json', 'HomeController@myRcas');
  Route::post('/timeentries/json', 'HomeController@timeEntries');
  Route::post('/savenewtime', 'HomeController@saveNewTime');
  Route::post('/savetime', 'HomeController@saveTime');
  Route::post('/deletetime', 'HomeController@deleteTime');
  Route::post('/savenotes', 'HomeController@saveNotes');
  Route::post('/anexar', 'HomeController@anexar');
  Route::post('/anexarcf', 'HomeController@anexarcf');
  Route::get('/viewanexo/{attachmentId}', 'HomeController@visualizarAnexo');
  Route::get('/downanexo/{attachmentId}', 'HomeController@downanexo');
  Route::post('/delete', 'HomeController@deleteArquivos');



    Route::post('/historico', 'HomeController@historico');
  Route::post('/edithours', 'HomeController@editHours');

  Route::post('/customfields', 'HomeController@customFields');

  Route::post('/taskschart', 'HomeController@tasksChart');

  Route::get('/pesquisar/{param}', 'HomeController@pesquisar');

  Route::post('/checarhorario', 'HomeController@checarHorario');

  Route::post('/iniciarcontador', 'CronometroController@iniciarContador');

  Route::get('/reports', 'ReportsController@index');
  Route::post('/reports/json', 'ReportsController@toJson');

  Route::get('/logs', 'LogController@index');
  Route::post('/logs/json', 'LogController@toJson');


  /*/
  ** seleciona o idioma, etc.
  ** filtro cliente e instancia
  */
  Route::get('/language/{locale}', 'UserController@changeLocale');
  Route::get('/idcliente/{idcliente}', function($idcliente){
    \Session::put('idcliente', $idcliente);
  });
  Route::get('/idinstancia/{idinstancia}', function($idinstancia){
    \Session::put('idinstancia', $idinstancia);
  });

  /*
  ** Notificações
  */
  Route::group(['prefix' => 'notifications'], function(){
    Route::get('/unread', function(){
      $html = '<a href="#" class="dropdown-toggle notify" data-toggle="dropdown" aria-expanded="true">';
      if(count(auth()->user()->notifications)){
        $html .= '<i class="fa fa-bell text-white"></i>';

          if(count(auth()->user()->unreadNotifications)){
          $html .= '<span class="label label-danger">'.
            count(auth()->user()->unreadNotifications).
            '</span>';
          }
          $html .= '</a>';

        $html .= '<ul class="dropdown-menu" style="width: auto;">';

          if(count(auth()->user()->unreadNotifications)){
            $html .= '<li class="footer"><a href="#" id="markasread">' .
            \Lang::get('application.message-markasread-notifications') .
            '</a></li>';
          }

          $html .= '<li><ul class="menu">';

          foreach (collect(auth()->user()->notifications)->take(10) as $notify){
            $html .= '<li>'.
            '<a href="#">'.
            '<div class="pull-left">'.
            '<img src="' . env('APP_URL') . '/user.png" class="img-circle" />'.
            '</div>'.
            '<h4>'.
              $notify->data['title'].
              '<small><i class="fa fa-clock-o"></i> '.$notify->created_at.'</small>'.
            '</h4>'.
            '<p>'.
              substr($notify->data['message'], 0, 100) .
              '<br />'.
              $notify->data['user']['name'] .
            '</p>'.
            '</a>'.
            '</li>';
          }

          $html .= '</ul></li>';

        $html .= '<li class="footer"><a href="#">' .
          \Lang::get('application.message-all-notifications') .
          '</a></li></ul>';
      }else{
        $html .= '<i class="fa fa-bell text-white"></i></a>';
      }

      return $html;
    });
    Route::get('/markasread', function(){
      auth()->user()->unreadNotifications->markAsRead();
    });
  });

});
