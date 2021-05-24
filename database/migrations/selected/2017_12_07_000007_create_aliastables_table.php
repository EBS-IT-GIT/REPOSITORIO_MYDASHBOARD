<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateAliastablesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('aliastables', function (Blueprint $table) {
          $table->increments('id');
          $table->integer('idcliente')->unsigned();;
          $table->integer('idinstancia')->unsigned();;
          $table->foreign('idinstancia')->references('id')->on('instances');
          $table->foreign('idcliente')->references('id')->on('clients');
          $table->string('nometabelaalias', 255);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('aliastables', function (Blueprint $table) {
            //
        });
    }
}
