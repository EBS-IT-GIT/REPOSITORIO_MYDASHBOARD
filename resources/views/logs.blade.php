@extends('adminlte::page')

@section('title', 'EBS-IT myDashboard')

@section('content_header')
    <h1><i class="fa fa-tasks"></i> Log de Atividades
    <small>Log de Atividades</small>
    </h1>
@stop

@section('content')
  <div class="row">
      <div class="col-md-12">

          <div class="box box-success">
            <div class="box-header">
              <h3 class="box-title">Relatórios</h3>
              <div class="box-tools">
                <button type="button" id="btn-pesquisar" name="btn-pesquisar" class="btn btn-sm btn-success"><i class="fa fa-search"></i> pesquisar</button>
              </div>
            </div>

            <div class="box-body">

              <div class="row">
                <div class="col-md-2">
                  <div class="form-group">
                     <label>Período: Início</label>
                     <input type="date" id="datainicio" name="datainicio" class="form-control auto-save" value="" />
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                     <label>Término</label>
                     <input type="date" id="datatermino" name="datatermino" class="form-control auto-save" value="" />
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                     <label>Situação</label>
                     <select id="situacao" class="form-control auto-save">
                       <option value=""></option>
                       @foreach($situacao as $sit)
                       <option value="{{ $sit->id }}">{{ $sit->name }}</option>
                       @endforeach
                     </select>
                  </div>
                </div>

                {{-- <div class="col-md-2">
                  <div class="form-group">
                     <label>Agrupar por</label>
                     <select id="agrupar" class="form-control auto-save">
                       <option value="1" selected>Dia</option>
                       <option value="2">Mês</option>
                       <option value="3">Ano</option>
                     </select>
                  </div>
                </div> --}}
              </div>

              <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                       <label>Analista</label>
                       <select multiple="multiple" id="analista" class="form-control auto-save">
                           <option value=""></option>
                           @foreach($usuarios as $usuario)
                           <option value="{{ $usuario->id }}">{{ $usuario->name }}</option>
                           @endforeach
                      </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                       <label>Projetos</label>
                       <select multiple="multiple" id="projeto" class="form-control auto-save">
                           <option value=""></option>
                           @foreach($projetos as $projeto)
                           <option value="{{ $projeto->id }}">{{ $projeto->name }}</option>
                           @endforeach
                      </select>
                    </div>
                </div>
              </div>
            </div>
          </div>
  </div>
</div>

<div class="row">
  <div class="col-lg-12 col-xs-12">
    <div class="box box-primary">
      <div class="box-header">
        <h3 class="box-title"><i class="fa fa-newspaper-o text-blue"></i> Resultado</h3>

        <div class="box-tools">

        </div>
      </div>
      <!-- /.box-header -->
      <div class="box-body table-responsive" id="lista-fatura">
        <table id="table-reports" class="table table-striped table-bordered table-hover display compact">
          <thead>
          <tr>
            <th style="width: 20%">Analista</th>
            <th style="width: 20%">Projeto</th>
            <th style="width: 20%">Atividade</th>
            <th style="width: 10%">Data/Horas</th>
            <th style="width: 20%">Ação</th>
            <th style="width: 5%">Situação</th>
            <th style="width: 5%">Prioridade</th>
          </tr>
          </thead>
          <tbody>

          </tbody>
        </table>
      </div>
      <!-- /.box-body -->
    </div>
    <!-- /.box -->
  </div>
</div>
@stop

@section('js')
    <script>
      $(function () {
        $.ajaxSetup({
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            }
        });

        $('select').select2();
        $('#table-reports').DataTable();

        function carregarDados()
        {
          $("#table-reports tbody").empty().html("<tr><td colspan=6 class=text-center>Carregando registros ...</td></tr>");

          var situacao = $('#situacao').val();
          var usuario = $('#analista').val();
          var projeto = $('#projeto').val();
          var inicio = $('#datainicio').val();
          var termino = $('#datatermino').val();

          var filtro = '';
          if(situacao!='') filtro += '&situacao=' + situacao;
          if(usuario!='') filtro += '&usuario=' + usuario;
          if(projeto!='') filtro += '&projeto=' + projeto;
          if(inicio!='') filtro += '&inicio=' + inicio;
          if(termino!='') filtro += '&termino=' + termino;

          $.ajax({
            url : '{{ URL::to('/logs/json')}}',
            type: 'POST',
            data: filtro,
            dataType: 'json',
            success: function(data){
              var html;
              for(var i in data){
                var item = data[i];

                html += '<tr>' +
                    '<td>' + item.analista + '</td>'+
                    '<td>' + item.projeto + '</td>'+
                    '<td>' + '['+ item.id_chamado +'] ' + item.chamado + '</td>'+
                    '<td>' + item.datahora + '</td>'+
                    '<td>' + item.acao + '</td>'+
                    '<td>' + item.situacao + '</td>'+
                    '<td>' + item.prioridade + '</td>'+
                  '</tr>';
              }
              $('#table-reports').DataTable().destroy();
              $('#table-reports tbody').empty().append(html);
              $('#table-reports').DataTable({'pageLength'  : 50}).draw();
            }
          });
        }

        $('#table-reports').DataTable();
        carregarDados();

        $(document).on('click','#btn-pesquisar', function(e){
          e.preventDefault();

          carregarDados();
      });
    });
    </script>
@stop
