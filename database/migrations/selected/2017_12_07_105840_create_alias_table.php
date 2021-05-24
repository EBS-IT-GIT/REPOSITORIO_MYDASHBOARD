<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateAliasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('alias', function (Blueprint $table) {
          $table->increments('id');
          $table->integer('idcliente')->unsigned();
          $table->integer('idinstancia')->unsigned();
          $table->integer('iddimensao')->unsigned();
          $table->integer('idmembro')->unsigned();
          $table->integer('idaliastables')->unsigned();
          $table->foreign('idinstancia')->references('id')->on('instances');
          $table->foreign('idcliente')->references('id')->on('clients');
          $table->foreign('iddimensao')->references('id')->on('dimensions');
          $table->foreign('idmembro')->references('id')->on('members');
          $table->foreign('idaliastables')->references('id')->on('aliastables');
          $table->string('alias', 255);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('alias', function (Blueprint $table) {
            //
        });
    }
}
