@extends('adminlte::page')

@section('title', 'EBS-IT myDashboard')

@section('content_header')
    <h1 ><i class="fa fa-list-alt"></i> Relatórios
        <small>Relatórios</small>
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

                        <div class="col-md-3">
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

                        <div class="col-md-5">
                            <div class="form-group">
                                <label id="teste">Projetos</label>
                                <select multiple="multiple" id="projeto" class="form-control auto-save">
                                    <option value=""></option>
                                    @foreach($projetos as $projeto)
                                        <option value="{{ $projeto->id }}">{{ $projeto->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                        </div>

                    <!--    {{-- <div class="col-md-2">
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

                    {{-- <div class="row">
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

                      <div class="col-md-5">
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
                    </div> --}} -->
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12 col-xs-12" >
            <div class="box box-primary">
                <div class="box-header">
                    <h3 class="box-title"><i class="fa fa-newspaper-o text-blue"></i> Resultado</h3>

                    <div class="box-tools">

                    </div>
                </div>
                <!-- /.box-header -->
                <div class="box-body table-responsive" id="lista-fatura">
                    <table id="table-" class="table table-striped table-bordered table-hover display compact">
                        <thead>
                        <tr>
                            <th>Projeto</th>
                            <th >Chamado</th>
                            <th style="white-space:nowap;">Data do Apontamento</th>
                            <th>Horas</th>
                            <th>Entrada</th>
                            <th style="white-space:nowap !important;">Saída Almoço</th>
                            <th style="white-space:nowap !important;">Retorno Almoço</th>
                            <th>Saída</th>
                            <th>Situação</th>
                            <th id="edit"></th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                    
                    <table class="table table-striped table-bordered table-hover display compact">
                        <tbody>
                        <tr>
                            <td style="text-align: right; width: 50%">Total de Horas</td>
                            <td id="totalhoras">0.00</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <!-- /.box-body -->
            </div>
            <!-- /.box -->
        </div>
    </div>


    <div class="modal fade"  data-toggle="modal" id="modal-edittime" data-backdrop = "false" style="display:none; ">
        <div class="modal-dialog modal-lg"  >
            <div class="modal-content">
                <div class="modal-header" style="text-align:center;">
                    <h3><strong>Editar Horas</strong></h3>
                </div>   
                <div class="modal-body" style="margin-bottom:50px;">
                    <div class="row"  >
                        <div class="col-md-12" >
                            <input type="hidden" name="taskid" id="taskid" value="" />

                                <div class="form-group" >
                                    <label for="title">Atividades</label>
                                    <textarea rows="3" class="form-control input-sm" name="atividades" id="atividades" value="" placeholder="atividades"></textarea>
                                </div>
                        </div>
                   </div>
                        <div class="row">
                            <div class="col-md-2"> 
                                <div class="form-group ">
                                    <label for="title" >Data</label>
                                    <input type="text" name="spent_on" id="spent_on" value="" placeholder="dd/mm/aaaa" class="form-control input-sm calcular_edit" data-timeid="" style="width:90px;">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="title">Entrada</label>
                                    <input type="text" name="hora_entrada_trabalho" id="hora_entrada_trabalho" value="" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="" style="width:90px;">
                                </div>
                            </div>

                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="title" style="white-space: nowrap;">Saída Almoço</label>
                                    <input type="text" name="hora_saida_almoco" id="hora_saida_almoco" value="" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="" style="width:90px;">
                                </div>
                            </div>

                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="title" style="white-space: nowrap;">Retorno Almoço </label>
                                    <input type="text" name="hora_retorno_almoco" id="hora_retorno_almoco" value="" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="" style="width:90px;">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="title">Saída</label>
                                    <input type="text" name="hora_saida_trabalho" id="hora_saida_trabalho" value="" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="" style="width:90px;">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="title">Horas</label>
                                    <input type="text" name="horas" id="horas" value="" placeholder="0.00" readonly= "true"class="form-control input-sm" style="width:90px;" disabled="disabled">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group" >
                                    <label for="title">Atividade</label>
                                    <select class="form-control input-sm" name="activities" id="activities" style="width:110px;">
                                        <option value="9">Execução</option>
                                        <option value="8">Planejamento</option>
                                        <option value="10">Documentação</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group ">
                                    <label for="title" >Tipo Hora</label>
                                    <select class="form-control input-sm" name="tipo_hora" id="tipo_hora" style="width: 100px;">
                                        <option value="Normal">Normal</option>
                                        <option value="Extra">Extra</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                </div>
                <!-- /.modal-body -->
                <div class="modal-footer">
                    <button class="btn btn-sm btn-primary" id="btn-edit-time-report" data-timeid="">Salvar</button>
                    <button id="model"class="btn btn-sm btn-default" data-dismiss="modal">Fechar</button>
                </div>

            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
@stop

@section('js')
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.11/jquery.mask.min.js"></script>
                        
    <script>
    
    window.onload = function() {
        $(function () {
            $.ajaxSetup({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                }
            });

            $('select').select2();
            $('#table-').DataTable();

            function carregarDadosReport()
            {
                $("#table- tbody").empty().html("<tr><td colspan=10 class=text-center> Carregando registros ...</td></tr>");

                var situacao = $('#situacao').val();
                var projeto = $('#projeto').val();
                var inicio = $('#datainicio').val();
                var termino = $('#datatermino').val();

                var filtro = '';
                if(situacao!='') filtro += '&situacao=' + situacao;
                if(projeto!='') filtro += '&projeto=' + projeto;
                if(inicio!='') filtro += '&inicio=' + inicio;
                if(termino!='') filtro += '&termino=' + termino;

                $.ajax({
                    url : '{{ URL::to('/reports/json')}}',
                    type: 'POST',
                    data: filtro,
                    dataType: 'json',
                    success: function(data){
                        var html;
                        var totalhoras=0.00;
                        for(var i in data){
                            var item = data[i];

                            totalhoras += parseFloat(item.horas);

                            html += '<tr>' +
                                '<td>' + item.projeto + '</td>'+
                                '<td>' + '<a target="_blank" href="{{ url('/taskreport')}}/'+ item.id_chamado +'" class="btn btn-default btn-xs taskdetail">' + item.id_chamado + '</a> '+ '<br />' + item.chamado +'</td>'+
                                '<td>' + item.data_apontamento + '</td>' +
                                '<td>' + item.horas + '</td>'+
                                '<td>' + item.hora_entrada  + '</td>' +
                                '<td>' + item.hora_saida_almoco + '</td>' +
                                '<td>' + item.hora_retorno_almoco + '</td>' +
                                '<td>' + item.hora_saida + '</td>'+
                                '<td>' + item.situacao + '</td>'+
                                '<td>' +
                                '<button type="button" class="btn btn-sm btn-info edit-time" data-target="#modal-edittime" name="button" ' +
                                'data-timeid="' + item.id_horas + '" ' +
                                'data-taskid="' + item.id_chamado + '" ' +
                                'data-spent_on="' + item.data_apontamento + '" ' +
                                'data-hora_entrada_trabalho="' + item.hora_entrada + '" ' +
                                'data-hora_saida_almoco="' + item.hora_saida_almoco + '" ' +
                                'data-hora_retorno_almoco="' + item.hora_retorno_almoco + '" ' +
                                'data-hora_saida_trabalho="' + item.hora_saida + '" ' +
                                'data-horas="' + item.horas + '" ' +
                                'data-activities="' + item.activity_id + '" ' +
                                'data-atividades="' + item.atividades + '" ' +
                                'data-tipo_hora="' + item.tipo_hora + '"><i class="fa fa-pencil"></i> </button>' +
                                '<button type="button" class="btn btn-sm btn-danger btn-delete-time-report" name="button" data-timeid="' + item.id_horas + '"  data-taskid="' + item.id_chamado + '" ><i class="fa fa-trash-o"></i> </button>' +
                                '</td>'+
                                '</tr>';
                        }
                        $('#table-').DataTable().destroy();
                        $('#table- tbody').empty().append(html);
                        $('#table-').DataTable({'pageLength'  : 100}).draw();
                        $('#totalhoras').html('<b>'+totalhoras+'</b>');

                    }
                });
            }
           
            $('#table-').DataTable();
            carregarDadosReport();

            $(document).on('click','#btn-pesquisar', function(e){
                e.preventDefault();
                carregarDadosReport();
            });
            $(document).on('click','#model', function(e){
               var atividades = atividades_mark.value("");
            });


            $(document).on('click','.edit-time', function(e){
                e.preventDefault();
                var timeid = $(this).data('timeid');
                var taskid = $(this).data('taskid');
                var spent_on = $(this).data('spent_on');
                var hora_entrada_trabalho = $(this).data('hora_entrada_trabalho');
                var hora_saida_almoco = $(this).data('hora_saida_almoco');
                var hora_retorno_almoco = $(this).data('hora_retorno_almoco');
                var hora_saida_trabalho = $(this).data('hora_saida_trabalho');
                var horas = $(this).data('horas');
                var activities = $(this).data('activities');
                var atividades = $(this).data('atividades');
                var tipo_hora = $(this).data('tipo_hora');

                $('#btn-edit-time-report').attr('data-timeid',timeid);
                $('#taskid').val(taskid);
                $('#spent_on').val(spent_on);
                $('#hora_entrada_trabalho').val(hora_entrada_trabalho);
                $('#hora_saida_almoco').val(hora_saida_almoco);
                $('#hora_retorno_almoco').val(hora_retorno_almoco);
                $('#hora_saida_trabalho').val(hora_saida_trabalho);
                $('#horas').val(horas);
                $('#activities').val(activities);
                atividades = atividades_mark.value(atividades);
                $('#tipo_hora').val(tipo_hora);
                localStorage.setItem('data-timeid', timeid);
                $('#modal-edittime').modal('show');



            });

            /*
            ** Funcao de Atualizar Apontamento existente
            */
            $(document).on('click', '#btn-edit-time-report', function(e){
                var timeid = localStorage.getItem('data-timeid');
                var taskid = $('#taskid').val();
                var spent_on = $('#spent_on').val();
                var hours = $('#horas').val();
                var atividades = atividades_mark.value();
                var atividade = $('#activities').val();
                var hora_entrada_trabalho = $('#hora_entrada_trabalho').val();
                var hora_saida_almoco = $('#hora_saida_almoco').val();
                var hora_retorno_almoco = $('#hora_retorno_almoco').val();
                var hora_saida_trabalho = $('#hora_saida_trabalho').val();
                var tipo_hora = $('#tipo_hora').val();

                //validaÃ§Ã£o
                if(timeid && hours && atividades)
                {

                    var data = 'timeid='+timeid+
                        '&taskid='+taskid+
                        '&spent_on='+spent_on+
                        '&hours='+hours+
                        '&atividades='+atividades+
                        '&activity='+atividade+
                        '&hora_entrada_trabalho='+hora_entrada_trabalho+
                        '&hora_saida_almoco='+hora_saida_almoco+
                        '&hora_retorno_almoco='+hora_retorno_almoco+
                        '&hora_saida_trabalho='+hora_saida_trabalho+
                        '&tipo_hora='+tipo_hora;

                    $.ajax({
                        url : '{{ URL::to('/savetime')}}',
                        data: data,
                        type: 'POST',
                        success: function(data){
                            Swal.fire({
                            title: 'Success!',
                            html: 'Dados Atualizados Corretamente',
                            icon: 'success',
                            confirmButtonText: 'OK'
                            });  
                            carregarDadosReport();
                            $('#modal-edittime').modal('hide');

                        },
                        error: function(XMLHttpRequest, textStatus, errorThrown){
                        Swal.fire({
                            title: 'Error!',
                            html: errorThrown,
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });   
                            // $('#message-modal').show().html('<div class="callout callout-danger"><h4>Status '+textStatus+'!</h4><p>'+errorThrown+'</p></div>').delay(400).hide(1000);
                        }
                    });
                }else{
                    var campos = '';
                    if(!notes) campos += '  '
                    Swal.fire({
                            title: 'Error!',
                            html: 'Campos Obrigatórios',
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });   
                    // $('#message-modal').show().html('<div class="callout callout-danger"><h4>Campos obrigatÃ³rios!</h4></div>').delay(400).hide(1000);
                }
            });

            /*
            ** FunÃ§Ã£o de Atualizar Apontamento existente
            */


            $(document).on('click', '.btn-delete-time-report', function(e){
                var timeid = $(this).data('timeid');
                var taskid = $(this).data('taskid');


                // if (confirm('Realmente deseja excluir o apontamento?')) {
                    Swal.fire({
                    title: 'Realmente deseja excluir o apontamento?',
                    text: "Você não será capaz de reverter isso!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Sim'
                    }).then((result) => {
                    if (result.isConfirmed) {
                       
                    
                 
                    
                var data = 'timeid=' + timeid + '&taskid='+ taskid;
                
                $.ajax({
                    url : '{{ URL::to('/deletetime')}}',
                    data: data,
                    type: 'POST',
                    success: function(data){
                        Swal.fire({
                            title: 'Success!',
                            html: 'Apontamento excluído corretamente!',
                            icon: 'success',
                            confirmButtonText: 'OK'
                            });  
                        carregarDadosReport();

                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown){
                        Swal.fire({
                            title: 'Error!',
                            html: errorThrown,
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });                    }
                });
                }
            })


            });
        });
    };
 
        jQuery(function($){
            $("#spent_on").mask("00/00/0000");
            $("#hora_entrada_trabalho").mask("00:00");
            $("#hora_saida_almoco").mask("00:00");
            $("#hora_retorno_almoco").mask("00:00");
            $("#hora_saida_trabalho").mask("00:00");
        });
       //markdown 

       var atividades_mark = new SimpleMDE({ element: $("#atividades")[0],
                toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],	spellChecker: false,autofocus: true,});





    </script>
@stop
