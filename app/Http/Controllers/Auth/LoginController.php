<?php

namespace App\Http\Controllers\Auth;

use Redmine\Client as Client;

use Validator;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\AuthenticatesUsers;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    protected $redirectTo = '/home';

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function login(Request $request)
    {
      $url = env('SD_URL');
      $login = $request->login; //username
      $pass = $request->password; //username

      $validator = Validator::make($request->all(),[
        'login' => 'required',
        'password' => 'required',
      ]);

      if($validator->fails()){
        return redirect('/login')
        ->withErrors($validator)
        ->withinput();
      }

      try{
        $conn = new Client($url, $login, $pass);
        $login = $conn->user->getCurrentUser();

      }catch(Exception $e){
         $validator->errors()->add('mensagem', $e);
         return redirect('/login')
           ->withErrors($validator)
           ->withinput();
      }

      if($login) {
        \Session::put('user', $login['user']);
        \Auth::loginUsingId(1);
        return redirect('/home');
      }else{
        $validator->errors()->add('mensagem', 'Usuário ou senha inválidos !');
        return redirect('/login')
          ->withErrors($validator)
          ->withinput();
      }
    }

}
