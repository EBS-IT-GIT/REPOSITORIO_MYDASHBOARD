<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateInstancesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('instances', function (Blueprint $table) {
          $table->increments('id');
          $table->integer('idcliente')->unsigned();;
          $table->integer('idproduto')->unsigned();;
          $table->foreign('idcliente')->references('id')->on('clients');
          $table->foreign('idproduto')->references('id')->on('products');
          $table->string('urlinstancia', 255);
          $table->string('localpath', 255);
          $table->integer('tipoinstancia');
          $table->string('user', 255);
          $table->string('pass', 255);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('instances', function (Blueprint $table) {
            //
        });
    }
}
