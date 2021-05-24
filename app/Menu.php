<?php

namespace App;

use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\HomeController;
//
class Menu extends Model
{
  protected $table = 'menu';
  public $timestamps = false;

  protected static function listarMenu()
  {
      /*
      * traduzir o menu de acordo com o idioma do navegador
      */
      $locale = \Session::get('locale', \Config::get('app.locale'));
      ($locale=='en') ? $i = '1' : $i = '-1';

      $user = Auth::user();
      $level = $user->perfil;

      $sql = ' SELECT id, parent_id, SUBSTRING_INDEX(title,"/",'.$i.') title, title name, url, menu_order, status, level, icon, icon_color, description, label_color, menu_type '.
             ' FROM menu '.
             ' WHERE status = 1 AND level LIKE "%'.$level.'%" '.
             ' ORDER BY menu_order ';
      $menu = DB::select($sql);
      return $menu;
  }
  /*
    ** Função que Lista os Projetos do Usuário
    */
  protected static function submenuProjects(){
    
        $conn = HomeController::connectApi();
        $array = [];
        $html = '<ul class="list-group" id="buscar" style="font-size:12px;white-space:normal;overflow-y:scroll;max-height:200px;">
        ';
        //projetos em que estou associado
        $projects = $conn->user->getCurrentUser()['user']['memberships'];

        foreach($projects as $p){
          $array[] = [
            'name' => $p['project']['name'],
            'id' => $p['project']['id'],
          ];
        }
        sort($array);
        if($array){
        foreach($array as $a){

          if($a['id']  != 18 && $a['id']  != 24 && $a['id']  != 73 && $a['id']  != 74 && $a['id']  != 85){
            $html .= '
            <li class="submenu" data-timeid="'.$a['id'].'"><a  class="submenu"href=" ' . \URL::to('/projects') . '/' .$a['name'] .  '/' .$a['id'].'"><i class="fa fa-share"></i> <span>'.$a['name'].'</span></a></li>';
         }
   
        }
        $html.='</ul>';

        return $html;
        }
    }
//     public static function adms(){
// //se faz parte do grupo
//       $sql = 'SELECT user_id FROM redmine.groups_users where group_id = 898';
//       $adm = \DB::connection('mysql_redmine')->select($sql);

//       return $adm;
//     }
}

