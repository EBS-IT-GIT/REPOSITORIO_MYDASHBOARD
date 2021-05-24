@extends('adminlte::page')
@section('content_header')
<h1><i class="fa fa-home fa-lg" aria-hidden="true"></i> Página Inicial
    <small>Página Inicial</small>
    </h1>

@stop
<!--  -->
@section('content')
<div class="row">
<div id="message"></div>
        <div class="col-md-12">
        <div class="box box-success">
        
      </button>
                <div class="box-header" id="meudiv">
                    <h2 class="box-title">Bem vindo ao <strong>MydashBoard Painel</strong>!</h2><br><br>
                    <h4 class="box-title">Escolha o Projeto</h4>

                </div>
                <div class="box-body">
                {!! $menu !!}

                </div>
        </div>

</div>

 





@stop
@section('js')
<link rel="stylesheet" href="{{ asset('list/css/listnav.css') }}" type="text/css"/>
<script type="text/javascript" src="{{asset('list/jquery-listnav.min.js')}}"></script>

<script>
    $('.open').css('cursor','no-drop');

    $("#myList").listnav();
    
   

   
</script>

@stop