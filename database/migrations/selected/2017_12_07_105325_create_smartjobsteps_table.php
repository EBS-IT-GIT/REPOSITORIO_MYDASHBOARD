<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateSmartjobstepsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('smartjobsteps', function (Blueprint $table) {
          $table->increments('id');
          $table->integer('idcliente')->unsigned();;
          $table->integer('idinstancia')->unsigned();;
          $table->integer('idsmartjob')->unsigned();;
          $table->foreign('idinstancia')->references('id')->on('instances');
          $table->foreign('idcliente')->references('id')->on('clients');
          $table->foreign('idsmartjob')->references('id')->on('smartjobs');
          $table->integer('ordem');
          $table->integer('tipostep');
          $table->string('nomejob', 255);
          $table->string('epmautomatescript', 255);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('smartjobsteps', function (Blueprint $table) {
            //
        });
    }
}
