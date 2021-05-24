@extends('adminlte::page')

@section('title', 'myDashboard')

@section('content_header')

    <h1><i class="{{__('application.dashboard-icon')}}"></i> {{__('application.dashboard-title')}}
    <small>{{__('application.dashboard-subtitle')}}</small>
    </h1>
@stop

@section('content')
    <div class="row" >
    <div id="message"></div>
        <div class="col-lg-6 col-xs-12" >
        
          <div class="box box-primary">
      
            <div class="box-header" id="header-home-new">
            <h3 class="box-title"><i class="{{__('application.dashboard-icon-news')}} text-blue"></i> {{__('application.news-title')}}</h3>

            <div id="tools-home-new">
                <select name="filtro_newtasks" id="filtro_newtasks" class=".filtro_newtasks" style="width: 200px;">
                
                <option value="">Todos</option>
                <!-- @foreach ($preferencial as $preferencial)
                      <option value="{{$preferencial->id}}">{{$preferencial->descricao}}</option> 
                @endforeach -->
                @foreach ($grupos as $grupo)
                        @if($grupo->descricao == "N1 - Fila N1")
                          <option value="{{ $grupo->id }}">{{ $grupo->descricao }}</option>
                          <option value="null">Sem Equipe</option>
                        @else
                          <option value="{{ $grupo->id }}">{{ $grupo->descricao }}</option>
                        @endif
                @endforeach
                </select>
            </div>
         
              <div class="box-tools pull-right">
              <!-- Collapse Button -->
              <button type="button" class="btn btn-box-tool" data-widget="collapse">
                <i class="fa fa-minus"></i>
              </button>
            </div>
              
              
            
            </div>
            <!-- /.box-header -->
           
           
            <div class="box-body table-responsive" id="lista-news">
            
              <table id="table-news" class="table table-striped table-bordered table-hover display compact">
                <thead>
                <tr>
                  <th style="width: 3%">#</th>
                  <th style="width: 10% ">{{__('application.news-number')}}</th>
                  <th style="width: 20%">{{__('application.news-description')}}</th>
                  <th style="width: 20%">{{__('application.news-client')}}</th>
                  <th style="width: 10%; white-space: nowrap;">{{__('application.news-date')}}</th>
                  <th style="width: 10%">{{__('application.mytasks-expire')}}</th>
                  <th style="width: 10%;">{{__('application.news-action')}}</th>
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
        <div class="col-lg-6 col-xs-12" >
          <div class="box box-success">
            <div class="box-header" id="header-home-my">
              <h3 class="box-title"><i class="fa {{__('application.dashboard-icon-mytasks')}} text-green"></i> {{__('application.mytasks-title')}}</h3>
              
              <label class="label label-success" id="total_new">0</label>
              <label class="label label-warning" id="total_inprogress">0</label>
              <label class="label label-info" id="total_feedback">0</label>
              <label class="label label-default" id="total_paused">0</label>
              <label class="label label-primary" id="total_transferido">0</label>


              <div id="tools-home-my">
                <select name="filtro_mytasks" id="filtro_mytasks" class=".filtro_mytasks" style="width: 200px;">

                  <option value="">Todos</option>
                  @foreach ($status as $s)
                              <option value="{{ $s['name'] }}">{{ $s['name'] }}</option>
                          @endforeach
                </select>
              </div>
              <div class="box-tools pull-right">
              <!-- Collapse Button -->
              <button type="button" class="btn btn-box-tool" data-widget="collapse">
                <i class="fa fa-minus"></i>
              </button>
            </div>
            
            </div>
            <!-- /.box-header -->
            <div class="box-body table-responsive" id="lista-mytasks">
            <button type="button" class="btn btn-sm btn-primary" style="padding:4px 4px 4px 4px; margin-botton:0;" id="btn-vencimento"><i class="fa fa-refresh" aria-hidden="true"></i> Atualizar</button>
              <table id="table-mytasks" class="table table-striped table-bordered table-hover display compact ">
                <thead>
                <tr>
                
                  <th style="width: 3%">{{__('application.mytasks-refresh')}}</th>
                  <th style="width: 10%">{{__('application.mytasks-number')}}</th>
                  <th style="width: 30%">{{__('application.mytasks-description')}}</th>
                  <th style="width: 30%">{{__('application.mytasks-client')}}</th>
                  <th style="width: 10%">{{__('application.mytasks-expire')}}</th>
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
        <div class="col-lg-6 col-xs-12">
          <div class="box box-danger">
            <div class="box-header">
              <h3 class="box-title"><i class="fa {{__('application.dashboard-icon-mygmuds')}} text-red"></i> {{__('application.mygmuds-title')}}</h3>
              <div class="box-tools pull-right">
              <!-- Collapse Button -->
              <button type="button" class="btn btn-box-tool" data-widget="collapse">
                <i class="fa fa-minus"></i>
              </button>
            </div>
            </div>
            
            <!-- /.box-header -->
            <div class="box-body table-responsive">
              <table id="table-mygmuds" class="table table-striped table-bordered table-hover display compact">
                <thead>
                <tr>
                  <th style="width: 10%">{{__('application.mygmuds-date')}}</th>
                  <th style="width: 15%">{{__('application.mygmuds-number')}}</th>
                  <th style="width: 25%">{{__('application.mygmuds-descri')}}</th>
                  <th style="width: 25%">{{__('application.mygmuds-cliente')}}</th>
                  <th style="width: 20%">{{__('application.mygmuds-fila')}}</th>
                  <th style="width: 20%">{{__('application.mygmuds-action')}}</th>
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
        <!-- /.col -->
         <div class="col-lg-6 col-xs-12">
          <div class="box box-danger">
            <div class="box-header">
              <h3 class="box-title"><i class="fa {{__('application.dashboard-icon-myrcas')}} text-red"></i> {{__('application.myrcas-title')}}</h3>
              <div class="box-tools pull-right">
              <!-- Collapse Button -->
              <button type="button" class="btn btn-box-tool" data-widget="collapse">
                <i class="fa fa-minus"></i>
              </button>
            </div>
            </div>
            <!-- /.box-header -->
            <div class="box-body table-responsive">
              <table id="table-myrcas" class="table table-striped table-bordered table-hover display compact">
                <thead>
                <tr>
                  <th style="width: 10%">{{__('application.myrcas-date')}}</th>
                  <th style="width: 15%">{{__('application.myrcas-number')}}</th>
                  <th style="width: 25%">{{__('application.myrcas-descri')}}</th>
                  <th style="width: 25%">{{__('application.myrcas-cliente')}}</th>
                  <th style="width: 20%">{{__('application.myrcas-fila')}}</th>
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
        <!-- /.col -->
        <!-- Graphics -->
        <div class="col-lg-6 col-xs-12">
          <div class="box box-info">
            <div class="box-header">
              <h3 class="box-title"><i class="fa fa-bar-chart text-aqua"></i> Analista x Status</h3>
              <div class="box-tools pull-right">
              <!-- Collapse Button -->
              <button type="button" class="btn btn-box-tool" data-widget="collapse">
                <i class="fa fa-minus"></i>
              </button>
            </div>
              <div id="tools-home-new">
                <select name="filtro_chart" id="filtro_chart" class=".filtro_chart" style="width: 200px;">
                  <option value="">Todos</option>
                  @foreach ($grupos as $grupo)
                    <option value="{{ $grupo->id }}">{{ $grupo->descricao }}</option>
                  @endforeach
                </select>
              </div>

            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <div class="box-body ">
              <div id="tasks-chart" class="chart">

              </div>
            </div>
            </div>
            <!-- /.box-body -->
          </div>
          <!-- /.box -->

        </div>
        <!-- /.col -->
        

      </div>
      <!-- /.row -->
</div>
<!-- Task FeedBack and Close -->
<div class="modal fade" id="modal-default" style="display: none;" >
  <div class="modal-dialog modal-lg" style="width: 1200px;">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">×</span></button>
          <h4 class="modal-title"><i class="fa fa-list"></i>
            <span  id="titulo-chamado"></span></h4>
          <div id="message-modal"></div>
      </div>
        <div class="modal-body" id="content-change">

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal"><i class="fa fa-door"></i> {{__('application.btn-close')}}</button>
        </div>
    </div>
    <!-- /.modal-content -->
  </div>
  <!-- /.modal-dialog -->
</div>

@stop
@section('js')
<script src="//apps.bdimg.com/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
<!-- <link rel="stylesheet" href="jqueryui/style.css" type="text/css"></style> -->
<link rel="stylesheet" href="{{asset('DataTables/datatables.css')}}" type="text/css">
<script type="text/javascript" src="{{ asset('DataTables/datatables.min.js') }}"></script>
<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/plug-ins/1.10.10/sorting/datetime-moment.js"></script>
    <script>
   $(function() {
    $( ".draggable" ).draggable();
  });
      $(function () {
        function atualizarChart()
        {
          $('#tasks-chart').empty().append('Carregando o gráfico ...');

          var filtro = '';
          var valor = $('#filtro_chart').val();
          if(valor) filtro += '&group='+valor;
          $.ajax({
            url : "{{URL::to('/taskschart')}}",
            data: filtro,
            type: 'post',
            dataType: 'html',
            success: function(data){
              $('#tasks-chart').empty().append(data);
            }
          });
        }

        $(document).on('click','#btn-vencimento', function(e){
            carregarMyTasks();
        });

        $(document).on('change','#filtro_chart', function(e){
          atualizarChart();
        });

        $(document).on('change','#filtro_newtasks', function(e){
          carregarNewTasks();
        });

        var todos_mytasks = [];
        $(document).on('change','#filtro_mytasks', function(e){
          carregarMyTasks();
        });

        /*function carregarNewTasks()
        {
          $("#table-news tbody").empty().html("<tr><td colspan=6 class=text-center>Carregando registros ...</td></tr>");

          var filtro = 'newtask=1';
          var valor = $('#filtro_newtasks').val();
          if(valor) filtro += '&group='+valor;
          var html = '';
          $.ajax({
            url : "{{URL::to('/newtasksmysql/json')}}",
            data: filtro,
            type: 'post',
            dataType: 'json',
            success: function(data){
              total_news = 0;

              var dados = data;
              for(var i in dados){
                var item = dados[i];
                if(item.capturado){
                html += '<tr><td>' + item.id + '</td><td style="text-align:center">' + item.number + '</td><td>' + item.description + '</td><td>' + item.client + '</td><td style="text-align:center">' + item.date + '</td><td><b><font color="red">Capturado por: </font></b>' + item.capturado + '</td></tr>';
                }else{
                html += '<tr><td>' + item.id + '</td><td style="text-align:center">' + item.number + '</td><td>' + item.description + '</td><td>' + item.client + '</td><td style="text-align:center">' + item.date + '</td><td>' + item.button + '</td></tr>';    
                }
                total_news++;
              }
              $('#table-news').DataTable().destroy();
              $('#table-news tbody').empty().append(html);
              $('#table-news').DataTable({
                "columns": [
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                ]
              }).order([]).draw();

            }
          });
        }
            */
        
               
        function carregarNewTasks()
        {

          $("#table-news tbody").empty().html("<tr><td colspan=7 class=text-center> Carregando registros ...</td></tr>");

          var page = $('#table-news_wrapper select').val();  
          var filtro = 'newtask=1';
          var valor = $('#filtro_newtasks').val();
          if(valor) filtro += '&group='+valor;
          var html = '';
          $.ajax({
            url : "{{URL::to('/newtasksmysql/json')}}",
            data: filtro,
            type: 'post',
            dataType: 'json',
            success: function(data){
              total_news = 0;
              var dados = data;
              for(var i in dados){
                var item = dados[i];
                
              
                html += '<tr><td>' + item.id + '</td><td style="text-align:center">' + item.number + '</td><td>' + item.description + '</td><td>' + item.client + '</td><td>' + item.date + '</td><td>' + item.expire + '</td><td>' + item.button + '</td></tr>';
                total_news++;

              }
              $('#table-news').DataTable().destroy();
              $('#table-news tbody').empty().append(html);
              $('#table-news').DataTable({
                'pageLength'  : page,
                "dom": '<f<t>lip>',
                
                'language': {
                  url: '{{ asset('/')}}js/Portuguese-Brasil.json'
                },
                "columns": [
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                ]
              }).order([]).draw();

            }
          });

        }

        function carregarMyTasks()
        {

          var filtro = $('#filtro_mytasks').val();

          $("#table-mytasks tbody").empty().html("<tr><td colspan=6 class=text-center> Carregando registros ...</td></tr>");
          var html = '';
          $.ajax({
            url : "{{URL::to('/mytasks/json')}}",
            data: 'newtask=1',
            type: 'post',
            dataType: 'json',
            success: function(data){
              total_inprogress = 0;
              total_feedback = 0;
              total_new = 0;
              total_paused = 0;
              total_transferido = 0;

              var dados = data;
              todos_mytasks = dados; //para o filtro
              for(var i in dados){
               
                var item = dados[i];
              
                if(filtro){
                  if(item.description.includes(filtro))
                  {
                    html += '<tr><td>' + item.id + '</td><td style="text-align:center">' + item.number + '</td><td>' + item.description + '</td><td>' + item.client + '</td><td>' + item.expire + '</td></tr>';
                  }
                }else{
                  html += '<tr><td>' + item.id + '</td><td style="text-align:center">' + item.number + '</td><td>' + item.description + '</td><td>' + item.client + '</td><td>' + item.expire + '</td></tr>';
                }
                if(item.status==2) total_inprogress++;
                if(item.status==7) total_feedback++;
                if(item.status==1) total_new++;
                if(item.status==8) total_paused++;
                if(item.status==19) total_transferido++;

              }

              $('#total_inprogress').html(total_inprogress);
              $('#total_feedback').html(total_feedback);
              $('#total_new').html(total_new);
              $('#total_paused').html(total_paused);
              $('#total_transferido').html(total_transferido);


              $('#table-mytasks').DataTable().destroy();  
              $('#table-mytasks tbody').empty().append(html);
              
              $(document).ready(function() {

                // você pode usar um dos dois com data ou data e hora
                $.fn.dataTable.moment( 'DD/MM/YYYY HH:mm:ss' );

               $('#table-mytasks').DataTable(
                {
                  "dom": '<f<t>lip>',
                  'language': {
                  url: '{{ asset('/')}}js/Portuguese-Brasil.json'
                },
                  "orderFixed": [4, 'asc']
              } 
              );
              });
              carregarMyRcas();
              carregarMyGmuds();
            }
          });
        }
        

        function carregarMyTime()
        {
          $("#table-mytime tbody").empty().html("<tr><td colspan=6 class=text-center>Carregando registros ...</td></tr>");
          var html = '';
          $.ajax({
            url : "{{URL::to('/mytime/json')}}",
            data: 'newtask=1',
            type: 'post',
            dataType: 'json',
            success: function(data){
              var dados = data;
              for(var i in dados){
                var item = dados[i];
                html += '<tr><td>' + item.id + '</td><td style="text-align:center">' + item.number + '</td><td>' + item.date + '</td><td>' + item.task + '</td><td>' + item.project + '</td><td>' + item.amount + '</td></tr>';
              }
              $('#table-mytime').DataTable().destroy();
              $('#table-mytime tbody').empty().append(html);
              $('#table-mytime').DataTable().draw();
            }
          });
        }
        function carregarMyGmuds()
        {
          $("#table-mygmuds tbody").empty().html("<tr><td colspan=6 class=text-center>Carregando registros ...</td></tr>");

          var filtro = 'newtask=1';
       
          var html = '';
          $.ajax({
            url : "{{URL::to('/mygmuds/json')}}",
            data: filtro,
            type: 'post',
            dataType: 'json',
            success: function(data){
              total_news = 0;

              var dados = data;
              for(var i in dados){
                var item = dados[i];

                html += '<tr><td>' + item.previsao + '</td>\n\
                         <td>' + item.number + '</td>\n\
                         <td>' + item.description + '</td>\n\
                         <td>' + item.client + '</td>\n\
                         <td>' + item.fila + '</td>\n\
                         <td>' + item.button + '</td></tr>';   
                total_news++;

              }
              $('#table-mygmuds').DataTable().destroy();
              $('#table-mygmuds tbody').empty().append(html);
              $('#table-mygmuds').DataTable({
                "dom": '<f<t>lip>',
                'language': {
                  url: '{{ asset('/')}}js/Portuguese-Brasil.json'
                },
                "columns": [
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                ]
              }).order([]).draw();

            }
          });
        }
        
        function carregarMyRcas()
        {
          $("#table-mygmuds tbody").empty().html("<tr><td colspan=6 class=text-center>Carregando registros ...</td></tr>");

          var filtro = 'newtask=1';
       
          var html = '';
          $.ajax({
            url : "{{URL::to('/myrcas/json')}}",
            data: filtro,
            type: 'post',
            dataType: 'json',
            success: function(data){
              total_news = 0;

              var dados = data;
              for(var i in dados){
                var item = dados[i];

                html += '<tr><td><b><font color="red">' + item.status + '</font></b></td>\n\
                         <td style="text-align:center">' + item.number + '</td>\n\
                         <td>' + item.description + '</td>\n\
                         <td>' + item.client + '</td>\n\
                         <td>' + item.fila + '</td></tr>';   
                total_news++;

              }
              $('#table-myrcas').DataTable().destroy();
              $('#table-myrcas tbody').empty().append(html);
              $('#table-myrcas').DataTable({
                "dom": '<f<t>lip>',
                'language': {
                  url: '{{ asset('/')}}js/Portuguese-Brasil.json'
                },
                "columns": [
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                  { "orderable": false },
                ]
              }).order([]).draw();
            }
          });
        }

        $('#filtro_newtasks').select2();
        $('#filtro_mytasks').select2();
        $('#filtro_chart').select2();
        $('#table-news').DataTable({
          "columns": [
            { "orderable": false },
            { "orderable": false },
            { "orderable": false },
            { "orderable": false },
            { "orderable": false },
            { "orderable": false },
            { "orderable": false },

          ]
        }).order([]).draw();
        

        //inicializa todos os paineis
        carregarNewTasks();
        
        $('#table-mytasks').DataTable();
        carregarMyTasks();
        $('#table-mygmuds').DataTable();
        $('#table-myrcas').DataTable();
        atualizarChart();
        setInterval(function(){
          carregarNewTasks();
        },60000);

        //capturar


       /* $(document).on('click', '.capturar', function(e){
            var taskid = $(this).data('taskid');
          var rowid = $(this).data('rowid');

          var t = $("#total_inprogress").text();
          var total = parseInt(t);
          if(total >= 3) {
            alert('Você já possui 3 chamados!');
          }else {
            var contador = 0;
            var cont_ativo = localStorage.getItem('contador');
            if (cont_ativo == 1) {
              alert('Chamado capturado com sucesso!');
            }else {
              if (confirm('Confirma a captura do chamado ' + taskid + '?')) {
                  var url = "{{ URL::to('/taskreport')}}/" + taskid;
                $("<a>").attr("href",url).attr("target", "_blank")[0].click();
                
                $.ajax({
              url: '{{ URL::to('/capturetask')}}',
              data: 'taskid=' + taskid + '&rowid=' + rowid + '&contador=' + contador,
              type: 'POST',
              success: function (data) {
                carregarNewTasks();
                carregarMyTasks();
                var sla = 2;
                localStorage.setItem('sla', 2);
                }
                });
              }
            }
          }
        });*/
        
        $(document).on('click', '.capturar', function(e){
          var taskid = $(this).data('taskid');
          var rowid = $(this).data('rowid');
          var statusid = 2;
          var url = "{{ URL::to('/taskreport')}}/" + taskid;

          var t = $("#total_inprogress").text();
          var total = parseInt(t);
          if(total >= 3) {
            Swal.fire({
                            title: 'Error!',
                            html: 'Você já possui 3 chamados!',
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });

                            return false;
          }
            var contador = 0;
            var cont_ativo = localStorage.getItem('contador');
            if (cont_ativo == 0) {  
              if (confirm('Iniciar o Contador no chamado ' + taskid + '?')) {
                contador = 1;
              }
                
                //   Swal.fire({
                //   title: 'Iniciar o Contador no chamado ' + taskid + '?',
                //   icon: 'warning',
                //   showCancelButton: true,
                //   confirmButtonColor: '#3085d6',
                //   cancelButtonColor: '#d33',
                //   confirmButtonText: 'Sim'
                // }).then((result) => {
                //   if (result.isConfirmed) {
                //     contador = 1;

                //   }

                // })

            }

            $.ajax({
              url: '{{ URL::to('/capturetask')}}',
              data: 'taskid=' + taskid + '&rowid=' + rowid + '&contador=' + contador + '&statusid=' + statusid,
              type: 'POST',
              success: function (data) {
                $("<a>").attr("href",url).attr("target", "_blank")[0].click();

                carregarNewTasks();
                carregarMyTasks();
                var sla = 2;
                localStorage.setItem('sla', 2);

              },
              error: function(xhr, textStatus, errorThrown){
                      Swal.fire({
                            title: 'Error!',
                            html: xhr.responseJSON.message,
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });
                    }
            });
          
        });


        function carregarAtividades(taskid, projectid)
        {

          var html = '';
          $.ajax({
            url : '{{ URL::to('/timeentries/json')}}',
            data: 'taskid='+taskid+'&projectid='+projectid,
            type: 'POST',
            success: function(data){
              $('#table-atividades tbody').empty();
              var json = JSON.parse(data);
              for(var i in json){
                var item = json[i];
                  if(item.edit){
                    var option = '<option value=""></option>';
                    var ativ = item.atividade;
                    for(var i=0; i < ativ.length; i++){
                      var selected = '';
                      if(ativ[i].id==item.activityid) selected = 'selected="selected"';
                      option += '<option value="'+ativ[i].id+'" '+selected+'>'+ativ[i].name+'</option>';
                    }

                    html += '<tr>'+
                      '<td>'+
                        '<input type="text" name="data'+item.timeid+'" id="data'+item.timeid+'" value="'+ item.spent_on+'" placeholder="dd/mm/aaaa" class="form-control input-sm" style="width:90px;" />'+
                      '</td>'+
                      '<td>'+
                        '<input type="text" name="horas'+item.timeid+'" id="horas'+item.timeid+'" value="'+ item.hours +'" placeholder="0.00" class="form-control input-sm" style="width:60px;">'+
                      '</td>'+
                      '<td>'+
                        '<input type="text" class="form-control input-sm" name="atividades'+item.timeid+'" id="atividades'+item.timeid+'" value="'+item.atividades+'" placeholder="atividades"  style="width:400px;" >'+
                      '</td>'+
                      '<td>'+
                        '<select class="form-control input-sm" name="activities'+item.timeid+'" id="activities'+item.timeid+'">'+option+
                        '</select>'+
                      '</td>'+
                      '<td>'+
                        '<input type="text" name="hora_entrada_trabalho'+item.timeid+'" id="hora_entrada_trabalho'+item.timeid+'" value="'+item.entrada_trabalho+'" placeholder="00:00" class="form-control input-sm" style="width:60px;">'+
                      '</td>'+
                      '<td>'+
                        '<input type="text" name="hora_saida_almoco'+item.timeid+'" id="hora_saida_almoco'+item.timeid+'" value="'+item.saida_almoco+'" placeholder="00:00" class="form-control input-sm" style="width:60px;">'+
                      '</td>'+
                      '<td>'+
                        '<input type="text" name="hora_retorno_almoco'+item.timeid+'" id="hora_retorno_almoco'+item.timeid+'" value="'+item.retorno_almoco+'" placeholder="00:00" class="form-control input-sm" style="width:60px;">'+
                      '</td>'+
                      '<td>'+
                        '<input type="text" name="hora_saida_trabalho'+item.timeid+'" id="hora_saida_trabalho'+item.timeid+'" value="'+item.saida_trabalho+'" placeholder="00:00" class="form-control input-sm" style="width:60px;">'+
                      '</td>'+
                      '<td style="vertical-align: middle">'+
                        '<button type="button" class="btn btn-sm btn-warning btn-edit-time" name="button" data-timeid="'+item.timeid+'"><i class="fa fa-floppy-o"></i> salvar</button>'+
                      '</td>'+
                    '</tr>';
                }else{
                  html += '<tr>'+
                    '<td>'+ item.spent_on + '</td>'+
                    '<td>'+ item.hours + '</td>'+
                    '<td>'+ item.atividades + '</td>'+
                    '<td>'+ item.activityname + '</td>'+
                    '<td>'+ item.entrada_trabalho + '</td>'+
                    '<td>'+ item.saida_almoco + '</td>'+
                    '<td>'+ item.retorno_almoco + '</td>'+
                    '<td>'+ item.saida_trabalho + '</td>'+
                    '<td style="vertical-align: middle"></td>'+
                  '</tr>';
                }
              }
              //$('#table-atividades').DataTable().destroy();
              $('#table-atividades tbody').empty().append(html);
              //$('#table-atividades').DataTable().draw();
            }
          });
        }

        /*
        ** Abre o Popup para Inserir o Apontamento e Mudar o Status
        */
        $(document).on('click', '.changestatus', function(e){
          var taskid = $(this).data('taskid');
          var task = $(this).data('task');
          var projectid = $(this).data('projectid');
          var statusid = $(this).data('statusid');
          var status = $(this).data('status');
          $('#btn-save-task').hide();

          var data = 'taskid='+taskid+
                     '&task='+task+
                     '&projectid='+projectid+
                     '&statusid='+statusid+
                     '&status='+status;

           $('#titulo-chamado').html('#'+taskid+' - '+task);
           $('#content-change').html('Carregando dados...');

          $.ajax({
            url : '{{ URL::to('/changeviewtask')}}',
            data: data,
            type: 'POST',
            success: function(data){
              $('#content-change').html(data);
              $('#btn-save-task').show();
              $('#btn-save-notes').show();
            },
            error: function(XMLHttpRequest, textStatus, errorThrown){
              Swal.fire({
                            title: 'Error!',
                            html: xhr.responseJSON.message,
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });   
              // $('#content-change').html('<div class="callout callout-danger"><h4>Status '+textStatus+'!</h4><p>'+errorThrown+'</p></div>');
            }
          });
        });

        /*
        ** Função de Mudança do Status New e Paused para In Progress - botão retomar
        */
        $(document).on('click', '.retomar', function(e){
          var taskid = $(this).data('taskid');
          var projectid = $(this).data('projectid');
          var statusid = $(this).data('statusid');
          var status = $(this).data('status');

          var data = 'taskid='+taskid+
          '&projectid='+projectid+
          '&statusid='+statusid+
          '&status='+status;
          $.ajax({
            url : '{{ URL::to('/changetask')}}',
            data: data,
            type: 'POST',
            success: function(data){
              //$('#message').html('<div class="callout callout-success"><h4>Dados atualizados corretamente!</h4></div>').delay(400).hide(1000);
              carregarMyTasks();
            },
            error: function(XMLHttpRequest, textStatus, errorThrown){
              $('#message').html('<div class="callout callout-danger"><h4>Status '+textStatus+'!</h4><p>'+errorThrown+'</p></div>').delay(400).hide(1000);
            }
          });
        });

      });
    </script>

@stop
