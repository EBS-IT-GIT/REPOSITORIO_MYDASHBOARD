<?php

namespace App\Http\Middleware;

use Closure;
use Session;
use App;
use Config;

class SetLocale
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
      if (Session::has('locale')) {
          $locale = Session::get('locale', Config::get('app.locale'));
      } else {
          $str = $request->server('HTTP_ACCEPT_LANGUAGE');
          if(str_contains($str, 'pt-BR')){
            $locale = 'pt-br';
          }else{
            $locale = 'en';
          }
      }

      App::setLocale($locale);

      return $next($request);
    }
}
