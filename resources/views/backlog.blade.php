@extends('adminlte::page')

@section('title','Backlogs')

@section('content_header')

    <h1><i class="fa fa-exclamation-triangle" aria-hidden="true"></i>
 Backlogs</h1>
  
@stop
<!--  -->

@section('content')
<div class="row">
<div id="message"></div>
        <div class="col-md-12">
                        <div class="box box-success" id="content-tarefa">
                            <div class="box-header">
                            <h3 class="box-title" style="float:left">Tarefas</h3>
                            <div class="col-md-8" id="qtd">
                                        <div class="form-group">
                                            
                                        </div>
                                    </div>

                            <div class="box-tools pull-right">
                         
                                    <button type="button" id="btn-pesquisar" name="btn-pesquisar" class="btn btn-sm btn-success"><i class="fa fa-search"></i> pesquisar</button>
                            </div>
                            
                            </div>
                            <div class="box-body">

                           
                              <!-- Filtro situação -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Filas</label>
                                            <select id="equipes" class="form-control input-sm filters">
                                            <option value="">Selecione a fila...</option>
                                            @foreach($grupos as $grupo)
                                            <option value="{{$grupo->name}}">{{$grupo->name}}</option>
                                            @endforeach
                                            </select>
                                    </div>
                                    </div>
                                    
                                    

                               
                            </div> <!-- /.box-body -->
                        <div class="box box-default box-body">
                            <div class="col-md-12">
                                        <div class="form-group table-responsive" id="lista-backlog">                                        
                                        <table id="table-back" class="table table-striped table-bordered table-hover display compact">
                                            <thead style="font-weight:700;"> 
                                            <tr>
                                            <td>Tarefa</td>
                                            <td>Título</td>
                                            <td>Atribuído Para</td>
                                            <td>Cliente</td>
                                            <td>Fila</td>
                                            <td>Abertura</td>
                                            <td>Vencimento</td>
                                            </tr>
                                            </thead>
                                            <tbody>
                                        
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                </div>
                                    <!-- /.box-body -->
                               
                         </div><!-- /.box -->
    </div>
    <!-- c...12 -->
</div>
<!-- row -->
@stop
@section('js')
<link rel="stylesheet" href="{{asset('DataTables/datatables.css')}}" type="text/css">
<script type="text/javascript" src="{{ asset('DataTables/datatables.min.js') }}"></script>
<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/plug-ins/1.10.10/sorting/datetime-moment.js"></script>
                        
<script>


       $('#table-back').DataTable({'pageLength'  : 10,
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

            function carregarBacklogs()
            {
                $("#table-back tbody").empty().html("<tr><td colspan=10 class=text-center> Carregando registros ...</td></tr>");
                

                var filtro = $('#equipes').val();
                $.ajax({
                    url : '{{ URL::to('/backloglist')}}',
                    type: 'POST',
                    data: '&equipe='+filtro,
                    dataType: 'json',
                    success: function(data){
                      
                        var html;
                        var dados = data;
                        var item;
                        var qtd;
                        for(var i in dados){
                            item = dados[i];

                                html += '<tr>' +
                                '<td style="width:56.7778px !important;">'+item.cdchamado+'</td>'+
                                '<td>' + item.dschamado + '</td>' +
                                '<td>' + item.responsavel + '</td>' +
                                '<td>' + item.cliente + '</td>'+
                                '<td>' + item.fila  + '</td>' +
                                '<td>' + item.dtchamado + '</td>' +
                                '<td>' + item.dt + '</td>' +
                                '</tr>';
                                qtd = item.html;       
                        }
                        $('#qtd').html('<b>'+qtd+'</b>');

                        $('#table-back').DataTable().destroy();
                        $('#table-back tbody').empty().append(html);
                        $('#table-back').DataTable({'pageLength'  : 10,
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
            }

            $(document).on('click','#btn-pesquisar', function(e){
                e.preventDefault();
                carregarBacklogs()
            });

</script>

@stop