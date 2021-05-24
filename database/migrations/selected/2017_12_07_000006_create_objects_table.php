<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateObjectsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('objects', function (Blueprint $table) {
          $table->increments('id');
          $table->integer('idcliente')->unsigned();;
          $table->integer('idinstancia')->unsigned();;
          $table->integer('idsnapshot')->unsigned();;
          $table->foreign('idinstancia')->references('id')->on('instances');
          $table->foreign('idcliente')->references('id')->on('clients');
          $table->foreign('idsnapshot')->references('id')->on('snapshots');
          $table->string('filename', 255);
          $table->string('statusdiff', 255);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('objects', function (Blueprint $table) {
            //
        });
    }
}
