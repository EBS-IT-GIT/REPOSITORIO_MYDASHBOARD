@extends('adminlte::page')

@section('title',$project_name)

@section('content_header')

    <h1 id="projectname"><i class="fa fa-folder"></i> {{$project_name}}</h1>
    @if($add !== "")
    <div class="box-tools pull-right">
    <a href="{{ URL::to('/newtask/'.$project_id)}}" target="_blank" ><label style="color:#333;cursor:pointer;">
    <i class="fa fa-plus-circle" aria-hidden="true" style="color:green;"></i> Nova Tarefa
    </label></a>
    </div>
    @else
    <div class="box-tools pull-right">
     <a  target="_blank"><label  style="color:#333;cursor:no-drop;">
    <i class="fa fa-plus-circle" aria-hidden="true" style="color:green;"></i> Nova Tarefa
    </label></a>
    </div>
    @endif
@stop
<!--  -->

@section('content')
<input type="hidden" id="project" value="{{$project_id}}"/>
<div class="row">
<div id="message"></div>
        <div class="col-md-12">
                        <div class="box box-success" id="content-tarefa">
                            <div class="box-header">
                            <h3 class="box-title" style="float:left">Tarefas</h3>
                            <div class="col-md-2">
                            <label>+ Filtros</label>
                            <select id="filter" class="filters">
                            <option value=""></option>
                            <option value="created_on"> Criado em</option>
                            </select>
                            </div>

                            <div class="box-tools pull-right">
                         
                                    <button type="button" id="btn-pesquisar" name="btn-pesquisar" class="btn btn-sm btn-success"><i class="fa fa-search"></i> pesquisar</button>
                            </div>
                            </div>
                            <div class="box-body">

                           
                              <!-- Filtro situação -->
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label>Situação</label>
                                            <select id="situacao" class="form-control input-sm filters">
                                            <option value="o">Aberta</option>
                                            <option value="=">Igual a</option>
                                            <option value="!">Diferente de</option>
                                            <option value="c">Fechado</option>
                                            <option value="*">Todos</option>
                                            </select>
                                    </div>
                                    </div>

                                    <div class="col-md-2" id="filter-status" style="display:none">
                                        <div class="form-group">
                                        <label style="visibility:hidden;">status</label>
                                            <select id="status" class="form-control input-sm">
                                            @foreach($situacao as $sit)
                                                    <option value="{{ $sit->id }}">{{ $sit->name }}</option>
                                            @endforeach
                                            </select>
                                    </div>
                                    </div>

                                  <!-- filtro criado em  -->

                                    <div class="col-md-2" id="filter-created_on" style="display:none">
                                        <div class="form-group">
                                            <label>Criado em</label>
                                            <select id="created_on" class="filters form-control input-sm">
                                            <option value=""></option>
                                            <option value="=">Igual a</option>
                                            <option value=">=">Maior ou igual</option>
                                            <option value="<=">Menor ou igual</option>
                                            <option value="><">Entre</option>
                                            <option value=">t-">Menos de</option>
                                            <option value="<t-">Mais de</option>
                                            <option value="><t-">Nos dias anteriores</option>
                                            <option value="t-">Dias atrás</option>
                                            <option value="t">Hoje</option>
                                            <option value="ld">Ontem</option>
                                            <option value="w">Esta semana</option>
                                            <option value="lw">Última semana</option>
                                            <option value="l2w">Últimas 2 semanas</option>
                                            <option value="m">Este mês</option>
                                            <option value="lm">Último mês</option>
                                            <option value="y">Este ano</option>
                                            <option value="!*">Nenhum</option>
                                            <option value="*">Todos</option>
                                            </select>                                        </div>
                                    </div>
                                    <div class="col-md-2" id="filter-created_on-values" style="display:none">
                                        <div class="form-group" id="div-datainicio" style="display:none">
                                            <label style="visibility:hidden;">Período</label>
                                            <input type="date" id="inicio" class="form-control input-sm" value="" />
                                           
                                        </div>
                                        <div class="form-group" id="div-datafim" style="display:none">
                                            <label style="visibility:hidden;">Período</label>
                                            <input type="date" id="fim" class="form-control input-sm" value="" />
                                        </div>
                                        <div class="form-group" style="width:30%;" id="div-dia" style="display:none">
                                            <label style="visibility:hidden;">Período</label>
                                            <input type="text" id="dia"  class="form-control input-sm" value="" placeholder="Dias"/>
                                           
                                        </div>
                                    </div>
                                  
                                  
                               
                            </div> <!-- /.box-body -->
                        <div class="box box-default box-body">
                            <div class="col-md-12">
                                        <div class="form-group table-responsive" id="lista-fatura">                                        
                                        <table id="table-" class="table table-striped table-bordered table-hover display compact">
                                            <thead style="font-weight:700;"> 
                                            <td>Tarefa</td>
                                            <td>Projeto</td>
                                            <td>Título</td>
                                            <td>Tipo</td>
                                            <td>Prioridade</td>
                                            <td>Situação</td>
                                            <td>Autor	</td>
                                            <td>Criado em</td>
                                            <td>Atribuído para</td>
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

            $(document).on('click','.filters', function(e){
                e.preventDefault();


                var situacao = $('#situacao').val();
                var filters = $('#filter').val();
                var filter_data = $('#created_on').val();


                //filtro situação
                if(situacao == '!'||situacao == '='){
                    document.getElementById('filter-status').style.display = "block";
                    document.getElementById('status').style.borderColor = "red";

                }
                else{
                    document.getElementById('filter-status').style.display = "none";

                }
                
                //filtro criado em 
                if(filters == 'created_on'){

                document.getElementById('filter-created_on').style.display = "block";
                document.getElementById('dia').style.borderColor = "red";
                document.getElementById('inicio').style.borderColor = "red";
                document.getElementById('fim').style.borderColor = "red";


                if(filter_data == '=' || filter_data == '>=' || filter_data == '<='){
                    document.getElementById('filter-created_on-values').style.display = "block";  
                    document.getElementById('div-datainicio').style.display = "block";  
                    document.getElementById('div-dia').style.display = "none";
                    document.getElementById('div-datafim').style.display = "none";
                
                    $('#dia').val("");
                    $('#fim').val("");
                
                
                }
                else if(filter_data == '><'){
                    document.getElementById('filter-created_on-values').style.display = "block";  
                    document.getElementById('div-datafim').style.display = "block";
                    document.getElementById('div-datainicio').style.display = "block";
                    document.getElementById('div-dia').style.display = "none";
                    $('#inicio').val("");
                     $('#dia').val("");
                
}
                else if(filter_data == '>t-' || filter_data == '<t-' || filter_data == '><t-'|| filter_data == 't-'){
                    document.getElementById('filter-created_on-values').style.display = "block";  
                    document.getElementById('div-dia').style.display = "block";
                    document.getElementById('div-datainicio').style.display = "none";
                    document.getElementById('div-datafim').style.display = "none";
                    $('#inicio').val("");
                    $('#fim').val("");
                
                }
                else{
                document.getElementById('filter-created_on-values').style.display = "none";  
                $('#inicio').val("");
                $('#fim').val("");
                $('#dia').val("");

                }
            }
                else{
                    document.getElementById('filter-created_on').style.display = "none";  
                    document.getElementById('filter-created_on-values').style.display = "none";  
                    $('#dia').val("");
                    $('#inicio').val("");
                     $('#fim').val("");
                }



            });
    
            $('#table-').DataTable();

            function carregarIssues()
            {
                $("#table- tbody").empty().html("<tr><td colspan=10 class=text-center> Carregando registros ...</td></tr>");
                

                var situacao = $('#situacao').val();
                var status = $('#status').val();
                var filter_data = $('#created_on').val();
                var dias = $('#dia').val();
                var inicio = $('#inicio').val();
                var fim = $('#fim').val();
                   
              
                var filtro = '';
                if(dias!='')filtro += '&dias=' + dias;
                if(inicio!='') filtro += '&inicio=' + inicio;
                if(fim!='') filtro += '&fim=' + '|'+fim;
                if(filter_data!='') filtro += '&filterdata=' + filter_data;
                if(situacao!='') filtro += '&situacao=' + situacao;
                if(status!='') filtro += '&status=' + status;

                var project_id = $('#project').val();
                $.ajax({
                    url : '{{ URL::to('/issueslist')}}',
                    type: 'POST',
                    data: filtro + '&project_id='+project_id,
                    dataType: 'json',
                    success: function(data){
                      
                        var html;
                        var dados = data;
                        for(var i in dados){
                        
                            var item = dados[i];
    
                                html += '<tr>' +
                                '<td style="width:56.7778px !important;">'+item.id+'</td>'+
                                '<td>' + item.projeto + '</td>' +
                                '<td>' + item.titulo + '</td>' +
                                '<td>' + item.tipo + '</td>'+
                                '<td>' + item.prioridade  + '</td>' +
                                '<td>' + item.status + '</td>' +
                                '<td>' + item.autor + '</td>' +
                                '<td>' + item.criacao + '</td>'+
                                '<td>' + item.atribuido +'</td>'+
                                '</tr>';
                        }
                        $('#table-').DataTable().destroy();
                        $('#table- tbody').empty().append(html);
                        $('#table-').DataTable({'pageLength'  : 10,
                "dom": '<f<t>lip>',
                'language': {
                  url: '{{ asset('/')}}js/Portuguese-Brasil.json'
                },
                "order": [0, 'desc']
              }).draw();

                        
                    },
                    error: function(xhr, textStatus, errorThrown){
                        Swal.fire({
                            title: 'Error!',
                            html: xhr.responseJSON.message,
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });   
                    // $('#message').html('<div class="callout callout-danger"><h4>Status '+textStatus+'!</h4><p>'+xhr.responseJSON.message+'</p></div>').delay(400).hide(1000);
                    }

                });
            }
            carregarIssues()

            $(document).on('click','#btn-pesquisar', function(e){
                e.preventDefault();
                carregarIssues()
            });

</script>

@stop