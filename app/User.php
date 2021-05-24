<?php

namespace App;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class User extends Authenticatable
{
    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

    public $timestamps = true;

    public function clients(){
      return $this->hasMany('App\Clienteusers', 'iduser', 'id');
    }

    protected static function listarUsuarios()
    {
      $isAdmin = \Session::get('isAdmin');

      if($isAdmin!=9)
      {
        $sql = 'SELECT DISTINCT u.id, u.name, u.email, iu.idcliente, u.perfil, iu.id iduserclient, u.status FROM users u INNER JOIN clientusers iu ON u.id = iu.iduser ';
        $sql .= 'WHERE iu.idcliente IN (SELECT idcliente FROM clientusers WHERE iduser = '.\Auth::user()->id.') ';
        $sql .= 'ORDER BY u.name';
      }
      else
      {
        $sql = 'SELECT DISTINCT u.id, u.name, u.email, iu.idcliente, u.perfil, iu.id iduserclientm, u.status FROM users u LEFT OUTER JOIN clientusers iu ON u.id = iu.iduser ';
        $sql .= 'ORDER BY u.name';
      }
      $usuarios = DB::select($sql);

      return $usuarios;
    }

    public function findForPassport($identifier) {
      return User::orWhere('email', $identifier)->where('status', 1)->first();
    }
}
