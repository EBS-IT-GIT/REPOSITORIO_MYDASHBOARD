<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateExportdimTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('exportdim', function (Blueprint $table) {
          $table->increments('id');
          $table->integer('idcliente')->unsigned();;
          $table->integer('idinstancia')->unsigned();;
          $table->integer('idsmartjob')->unsigned();;
          $table->integer('idsmartjobstep')->unsigned();;
          $table->integer('idaliastable')->unsigned();;
          $table->integer('iddimensao')->unsigned();;
          $table->foreign('idinstancia')->references('id')->on('instances');
          $table->foreign('idcliente')->references('id')->on('clients');
          $table->foreign('idsmartjob')->references('id')->on('smartjobs');
          $table->foreign('idsmartjobstep')->references('id')->on('smartjobsteps');
          $table->foreign('idaliastable')->references('id')->on('aliastables');
          $table->foreign('iddimensao')->references('id')->on('dimensions');
          $table->string('nomejob', 255);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('exportdim', function (Blueprint $table) {
            //
        });
    }
}
