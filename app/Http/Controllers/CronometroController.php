<?php

namespace App\Http\Controllers;

use App\Cronometro;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class CronometroController extends Controller
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
      // $instancias = Menu::listarMenu();
      // return view('instancias',
      //   [
      //     'instancias'=> $instancias
      //   ]);
  }

  // public function toJson(){
  //   $arr = [];
  //   $arr['data'] = Menu::listarMenu();
  //   return response($arr);
  // }
  //
  public function iniciarContador(Request $request)
  {
    if($request->ajax())
    {
      if(!$request->taskid) throw new \Exception('Campo TaskID é obrigatório!');

      $user = \Session::get('user');
      $userid = $user['id'];
      $taskid = $request->taskid;
      $started_at = Carbon::now();

      $contador = new Cronometro;
      $contador->user_id = $userid;
      $contador->task_id = $taskid;
      $contador->started_at = $started_at;
      $contador->save();

      return response($contador);
    }
  }

  public function apontamentoEmAberto(Request $request)
  {
    if($request->ajax())
    {
      if(!$request->taskid) throw new \Exception('Campo TaskID é obrigatório!');

      $user = \Session::get('user');
      $userid = $user['id'];
      $taskid = $request->task_id;
      $started_at = now();

      $contador = new Cronometro;
      $contador->user_id = $userid;
      $contador->task_id = $taskid;
      $contador->started_at = $started_at;
      $contador->save();

      return response($contador);
    }
  }
}
