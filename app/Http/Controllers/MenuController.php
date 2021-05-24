<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Menu;

class MenuController extends Controller
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
      $instancias = Menu::listarMenu();
      return view('instancias',
        [
          'instancias'=> $instancias
        ]);
  }

  public function toJson(){
    $arr = [];
    $arr['data'] = Menu::listarMenu();
    return response($arr);
  }

  public function lista(Request $request)
  {
    $menu = Menu::listarMenu();
    return view('access',
      [
        'menu'=> $menu,
        'instancias' => $menu
      ]);
  }
}
