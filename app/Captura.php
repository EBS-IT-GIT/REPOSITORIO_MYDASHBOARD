<?php

namespace App;

use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Model;


class Captura extends Model
{
    protected $table = 'captura';
    protected $fillable = ['log_id','anterior', 'analista', 'justificativa','json','datahora'];
    public $timestamps = false;
}
