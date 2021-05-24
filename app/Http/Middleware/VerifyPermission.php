<?php

namespace App\Http\Middleware;

use Closure;

class VerifyPermission
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
      if(!\Auth::guest())
      {
        $user_id = \Auth::user()->id;
        $level = \App\User::find($user_id)->perfil;
        $request->session()->put('isAdmin', $level);
      }

      return $next($request);
    }
}
