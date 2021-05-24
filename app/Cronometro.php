<?php

namespace App;

use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class Cronometro extends Model
{
  protected $table = 'cronometro';
  protected $fillable = ['user_id', 'task_id', 'started_at', 'finished_at'];
  public $timestamps = false;

  protected static function listarContadorEmAberto()
  {
      /*
      * verifica se tem algum contador em aberto
      */
      $user = \Session::get('user');
      $userid = $user['id'];
      // dd($userid);

      $sql = ' SELECT id, user_id, task_id, DATE_FORMAT(started_at,"%d/%m/%Y") date_started, DATE_FORMAT(started_at,"%H:%i:%s") hora_inicio, DATE_FORMAT(IFNULL(finished_at, NOW()),"%H:%i:%s") finished_at,  DATE_FORMAT(started_at,"%b %d, %Y  %H:%i:%s") started_at  '.
             ' FROM cronometro '.
             ' WHERE user_id = '.$userid.' AND finished_at IS NULL '.
             ' ORDER BY task_id ';
      $contador = DB::select($sql);
      return $contador;
  }
}
