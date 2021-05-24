
@extends('adminlte::page')

@section('title', $task['id'] . ' - ' .strip_tags($task['subject']) )

@section('content_header')
<!-- input hidden -->
<input type="hidden" class="form-control input-sm" name="projectid" id="projectid" value="{{ $task['project']['id'] }}" readonly>
<input type="hidden" class="form-control input-sm" name="project_name" id="project_name" value="{{ $task['project']['name'] }}" readonly>
<input type="hidden" class="form-control input-sm" name="edit_task_id" id="edit_task_id" value="{{ $task['id'] }}" readonly>
<input type="hidden" class="form-control input-sm" name="edit_project_id" id="edit_project_id" value="{{ $task['project']['id'] }}" readonly>
<input type="hidden" class="form-control input-sm " name="contato" id="contato" value="{{ $contato[0]->nome_contato }}" readonly="">
<input type="hidden" class="form-control input-sm" name="contato_email" id="contato_email" value="{{ $contato[0]->email }}" readonly="">
<input type="hidden" class="form-control input-sm" name="status_name" id="status_name" value="{{ $task['status']['name'] }}" readonly>  
<input type="hidden" class="form-control input-sm" name="taskid" id="taskid" value="{{ $task['id']}}" readonly>  


<!--  -->
  @if(isset($contador[0]))
    @if($contador[0]->task_id==$task['id'])
      <div class="callout callout-danger">
        <h3><strong>Chamado {{ $task['id'] }}</strong> - {{ mb_substr(strip_tags($task['subject']),0, 100) }} {{ mb_substr(strip_tags($task['subject']),101, 100) }} {{ mb_substr(strip_tags($task['subject']),201, 100) }}
        </h3>
        <h4><strong>Projeto -</strong> {{ $task['project']['name'] }}<strong>{{$grupo}}</strong></h4>

      </div>
    @else
      <h1><strong>Chamado {{ $task['id'] }} -<strong> {{ mb_substr(strip_tags($task['subject']),0, 100) }} {{ mb_substr(strip_tags($task['subject']),101, 100) }} {{ mb_substr(strip_tags($task['subject']),201, 100) }}
      </h1>
      <h4><strong>Projeto -</strong> {{ $task['project']['name'] }}<strong>{{$grupo}}</strong></h4>
    @endif
  @else
    <h1><strong> Chamado {{ $task['id'] }} -</strong> {{ mb_substr(strip_tags($task['subject']),0, 100) }} {{ mb_substr(strip_tags($task['subject']),101, 100) }} {{ mb_substr(strip_tags($task['subject']),201, 100) }}
    </h1>
    <h4><strong>Projeto -</strong> {{ $task['project']['name'] }}<strong>{{$grupo}}</strong></h4>

  @endif
@stop

@section('content')
  <div class="row">
    <div class="col-md-12 col-xs-12">


      <div class="nav-tabs-custom">
        <ul class="nav nav-tabs">
          <li class="active">
            <a href="#tab_1" data-toggle="tab">
              <i class="fa fa-pencil text-blue"></i> Chamado</a>
          </li>
          <li>
            <a href="#tab_2" data-toggle="tab" id="aba-apontamentos">
              <i class="fa fa-clock-o text-yellow"></i> Apontamentos</a>
          </li>
          <li>
            <a href="#tab_3" data-toggle="tab" id="aba-historico">
              <i class="fa fa-list text-danger"></i> Histórico</a>
          </li>
          <li style="display:none;">
            <a href="#tab_4" data-toggle="tab">
              <i class="fa fa-sticky-note text-info"></i> Notas</a>
          </li>
          
        </ul>
        <div class="tab-content">
        <div id="message"></div>
          <div class="tab-pane active" id="tab_1">
          
            <div class="box box-primary">
              <div class="box-header" id="header-taskreport">

<!--  -->
                <div class="box-tools form-inline">

                {!!$open!!}
                @if(!isset($task['assigned_to']['id'])||\Session::get('user')['id']!=$task['assigned_to']['id']) 
                {!!$capturar!!}      
                  @endif

                  @if(isset($task['assigned_to']['id']))
                 
                    @if(\Session::get('user')['id']==$task['assigned_to']['id'])

                     
                      @if(!isset($contador[0]) AND ($task['status']['id']==2 || $task['status']['id']==10 || $task['status']['id']==13) )
                        <button type="button" class="btn btn-sm btn-success" id="btn-iniciar-contador">
                          <i class="fa fa-play"></i> Iniciar cronômetro
                        </button>
                      @endif


                      @if(isset($contador[0]) AND ($task['id']== $contador[0]->task_id))
                        <button type="button" class="btn btn-sm btn-warning" id="btn-stop-contador" style="right: -6px !important;"  data-taskid="@if(isset($contador[0])){{$contador[0]->task_id}}@endif">
                          <i class="fa fa-stop"></i> Parar cronômetro
                        </button>
                      @endif
                      
                    
                  
                    @endif
                  @endif

                </div>
              </div>

              <div class="box-body" id="box-taskreport">
              <div id="message"></div>

                <form id="chamado">

                  <input type="hidden" id="author" value="{{ $task['author']['id'] }}" />
                  <input type="hidden" id="done_ratio" value="{{ $task['done_ratio'] }}" />

                  <div class="box box-default">
                    <div class="box-header with-border">

                      <div class="row" >
                      <div class="col-md-12">
                          <div class="form-group">
                          <label for="contato">Contato: <span class="text-light-blue">{{ $contato[0]->nome_contato }}/{{ $contato[0]->email }}/{{ $contato[0]->telefone }}
                            </span>
                          </label>
                          </div>
                      </div>
                      <div class="col-md-4">
                          <div class="form-group">

                            <label for="title">Abertura: <span class="text-light-blue">@if(isset($created)){{$created}}@endif</span></label>
                            </br><label for="title">Vencimento Resposta: {!!$dt_p!!}</label>
                            </br><label for="title">Vencimento Solução: {!!$dt_s!!}</label>


                          </div>
                        </div>

                        <div class="col-md-3">
                          <div class="form-group">
                          <label for="title">Início Atendimento: <span class="text-light-blue">{{$resposta}}</span></label>
                          </br> <label for="title">SLA Resposta: <span class="text-light-blue">{{$sla_p}}</span></label>
                          </br><label for="title">SLA Solução: <span class="text-light-blue">{{$sla_s}}</span></label>
                          </div> 
                        </div>

                        <div class="col-md-3">
                          <div class="form-group">
                          <label for="title">Encerramento: <span class="text-light-blue">{{$solucao}}</span></label>                      
                          </div>
                          
                        </div>
                        <div class="col-md-2">
                          <div class="form-group">
                          <label for="title">Situação: <span class="text-light-blue">{{ $task['status']['name'] }}</span></label>
                                                 
                          </div>
                          
                        </div>                       

                      </div>

                    </div><!-- box-header-->
                  </div><!-- box -->
                  
                  <div style="margin-bottom:5px;">
                  <label><span class="text-red">*</span> Campos obrigatórios</label>
                  </div>
                  <div class="row">

                  <div class="col-md-2">

                      <div class="form-group">
                        <label for="tracker">Tipo <span class="text-red">*</span></label>
                        <select class="form-control input-sm" name="tracker" id="tracker" required>
                          @foreach ($trackers as $tracker)
                            @if($tracker->id==$task['tracker']['id'])
                              <option value="{{ $tracker->id }}" selected>{{ $tracker->name }}</option>
                            @else
                              <option value="{{ $tracker->id }}">{{ $tracker->name }}</option>
                            @endif
                          @endforeach
                        </select>
                        <input type="hidden" class="form-control input-sm" name="status_name" id="input_tracker" value="{{$task['tracker']['id']}}" readonly> 
                      </div>
                    </div>

                      <div class="col-md-2">

                      <div class="form-group" >
                        <label for="novasituacao">Nova Situação <span class="text-red">*</span></label>
                        <select class="form-control input-sm" name="novasituacao" id="novasituacao">
                          <option value="0" readonly>Mudar para ...</option>
                        @foreach ($novasituacao as $sit)
                          @if($sit->id==$task['status']['id'])
                            <!--option selected="selected" value="{{ $sit->id }}">{{ $sit->name }}</option-->
                            @else
                              <option value="{{ $sit->id }}">{{ $sit->name }}</option>
                            @endif
                          @endforeach
                        </select>
                      </div>
                      </div>

                    <div class="col-md-4">
                      <div class="form-group">
                        <label for="title">Título<span class="text-red">*</span></label></label>
                        <input type="text" class="form-control input-sm" name="title" id="title" value="{{ $task['subject'] }}" required>
                        <input type="hidden" class="form-control input-sm" name="input_title" id="input_title" value="{{ $task['subject'] }}">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group">
                        <label for="assigned_to">Atribuído para</label>
                        @if(isset($task['assigned_to']['id']))
                          @if(\Session::get('user')['id']==$task['assigned_to']['id'])
                            {!! $transferirpara !!}
                          @else
                            <input type="text" class="form-control input-sm" name="assigned_to_name" id="assigned_to_name" value="{{ $task['assigned_to']['name'] }}" readonly>
                          @endif
                        @endif
                      </div>
                    </div>
                    <div class="col-md-2">
                      <div class="form-group">
                        <label for="priority">Prioridade</label>
                        <select class="form-control input-sm" name="priority" id="priority" required>
                          @foreach ($priorities as $priority)
                            @if($priority['id']==$task['priority']['id'])
                              <option value="{{ $priority['id'] }}" selected>{{ $priority['name'] }}</option>
                            @else
                              <option value="{{ $priority['id'] }}">{{ $priority['name'] }}</option>
                            @endif
                          @endforeach
                        </select>
                        <input type="hidden" class="form-control input-sm" name="input_priority" id="input_priority" value="{{$task['priority']['id']}}"/>
                      </div>
                    </div>

                   
                    <div class="col-md-2">
                      <div class="form-group">
                        <label for="created_on">Início</label>
                        <input type="date" class="form-control input-sm" name="created_on" id="created_on" value="@if(isset($task['start_date'])){{$task['start_date']}}@endif">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group">
                        <label for="due_date" style="white-space: nowrap;">Dt Prevista</label>
                        @if(isset($task['due_date']))
                          <input type="date" class="form-control input-sm" name="due_date" id="due_date" value="{{$task['due_date'] }}">
                        @else
                          <input type="date" class="form-control input-sm" name="due_date" id="due_date" value="">
                        @endif
                      </div>
                    </div>

                    

                    <div class="col-md-1" style="display:none">
                      <div class="form-group">
                        <label for="spent_hours" style="white-space: nowrap;">T. estimado</label>
                        <input type="text" class="form-control input-sm" name="spent_hours" id="spent_hours" value="@IF(isset($task['spent_hours'])) {{ $task['spent_hours'] }} @ENDIF" required>
                      </div>
                    </div>
                  </div>

                  <div class="row">
                    <div class="col-md-12">
                      <div class="form-group">
                        <label for="title">Descrição <button type="button" class="btn btn-xs btn-info" name="btn-ver-descricao" id="btn-ver-descricao"><i class="fa fa-pencil-square-o" aria-hidden="true"></i> editar</button></label>
                        <div class="col-md-12" id="html-descricao" style="word-wrap: break-word;white-space: break-spaces; overflow: none;background-color:#e8eaed;"><p>@if(isset($task['description'])){!! $task['description'] !!}@endif</p></div>
                      </div>
                    </div>

                   

                    <div class="col-md-12" id="editor-descricao">
                      <textarea  class="form-control input-ms" name="description" id="description">@if(isset($task['description'])){!! $task['description'] !!}@endif</textarea>
                      <input type="hidden" class="form-control input-sm" name="input_description" id="input_description" value="@if(isset($task['description'])){!! $task['description'] !!}@endif">
                    </div>

                    <div class="col-md-12">
                      <div class="form-group">
                        <label for="notes_task">Notas</label>
                        <textarea rows="3" class="form-control input-ms" name="notes_task" id="notes_task"></textarea>
                      </div>
                      <div style="text-align:center;">
                      @if(!isset($task['assigned_to']['id'])||\Session::get('user')['id']!=$task['assigned_to']['id'])
                            <button type="button" class="btn btn-sm btn-primary" name="btn-save-notes" id="btn-save-notes">
                            <i class="fa fa-floppy-o"></i> Salvar Nota</button>
                            @endif
                      </div>
                    </div>


                    <div class="col-md-12">
                      <h4 class="h4">Outras Informações</h4>
                    </div>
                    <div class="col-md-12" id="outrasinfos"></div>

                  <div class="col-md-4">
                      <div class="form-group">
                        <label for="fileUploadChamado">Upload</label>
                        <input class="form-control input-sm" multiple="multiple" type="file" name="fileUploadChamado[]" id="fileUploadChamado" />
                        <button class="btn btn-primary btn-sm btnEnviar hidden" type="button" name="btnEnviarChamado" id="btnEnviarChamado"><i class="fa fa-paper-plane" aria-hidden="true"></i> Enviar Arquivo</button>
                      </div>
                    </div>
                  </div>

                  <!--- novo apontamento origatório --->
                  <div class="row" id="novoapontamento" style="display:none;">
                    <div class="col-md-2">
                      <div class="form-group" id="help_spent_on_{{ $task['id'] }}" >
                        <label for="spent_on">Data <span class="text-red">*</span></label>
                        <input type="text" name="spent_on_{{ $task['id'] }}" id="spent_on_{{ $task['id'] }}" value="{{ date('d/m/Y') }}" placeholder="dd/mm/aaaa" class="form-control input-sm calcular required" style="width:90px;" />
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group" id="help_hora_entrada_trabalho_{{ $task['id'] }}" >
                        <label for="hora_entrada_trabalho">Entrada <span class="text-red">*</span></label>
                        <input type="text" name="hora_entrada_trabalho_{{ $task['id'] }}" id="hora_entrada_trabalho_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular required" style="width:90px;">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group">
                        <label for="hora_saida_almoco">Saída</label>
                        <input type="text" name="hora_saida_almoco_{{ $task['id'] }}" id="hora_saida_almoco_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular" style="width:90px;">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group">
                        <label for="hora_retorno_almoco">Retorno</label>
                        <input type="text" name="hora_retorno_almoco_{{ $task['id'] }}" id="hora_retorno_almoco_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular" style="width:90px;">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group" id="help_hora_saida_trabalho_{{ $task['id'] }}">
                        <label for="hora_saida_trabalho">Saída <span class="text-red">*</span></label>
                        <input type="text" name="hora_saida_trabalho_{{ $task['id'] }}" id="hora_saida_trabalho_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular required" style="width:90px;">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group" id="help_horas_{{ $task['id'] }}">
                        <label for="horas">Horas <span class="text-red">*</span></label>
                        <input type="text" name="horas_{{ $task['id'] }}" id="horas_{{ $task['id'] }}" value="" placeholder="0.00" class="form-control input-sm required" style="width:90px;" disabled="disabled">
                      </div>
                    </div>

                    <div class="col-md-2">
                      <div class="form-group" id="help_atividade_{{ $task['id'] }}">
                        <label for="atividade">Atividade <span class="text-red">*</span></label>
                        <select class="form-control input-sm required" name="atividade_{{ $task['id'] }}" id="atividade_{{ $task['id'] }}">
                          @foreach ($activities as $ativ)
                            <option value="{{ $ativ['id'] }}">{{ $ativ['name'] }}</option>
                          @endforeach
                        </select>
                      </div>
                    </div>

                    <div class="col-md-3">
                      <div class="form-group" id="help_atividades_{{ $task['id'] }}">
                        <label for="atividades">Atividades <span class="text-red">*</span></label>
                        <input class="form-control input-sm required" type="text" name="atividades_{{ $task['id'] }}" id="atividades_{{ $task['id'] }}" value="" placeholder="atividades">
                      </div>
                    </div>

                    <div class="col-md-1">
                      <div class="form-group" id="help_tipohora_{{ $task['id'] }}">
                        <label for="tipo_hora">Tipo Hora <span class="text-red">*</span></label>
                        <select class="form-control input-sm" name="tipo_hora_{{$task['id']}}" id="tipo_hora_{{$task['id']}}">
                          <option value="Normal">Normal</option>
                          <option value="Extra">Extra</option>
                        </select>
                      </div>
                    </div>
                  </div>
                 

                  <div class="col-md-12" style="text-align:center;">
                  @if(isset($task['assigned_to']['id']))
                    @if(\Session::get('user')['id']==$task['assigned_to']['id'])
                  <button type="button" class="btn btn-sm btn-primary" name="btn-save-task" id="btn-save-task">
                        <i class="fa fa-floppy-o"> </i> Salvar Chamado
                      </button>
                      @endif
                  @endif
                  </div>
                </div>
                @if($task['project']['id'] == 228)
                  <div class="box box-default">
                  <div class="row" >
                  <div class="box-header">
                      <div class="col-md-12">
                      <button type="button" class="btn btn-xs btn-info" name="btn-anexos-brk" id="btn-anexos-brk">
                      <i class="fa fa-eye" aria-hidden="true"></i> Mostrar Anexos</button>
                          <div class="form-group" id="anexosbrk">
                          </div>
                  </div>
                  </div>
                  </div>
                  </div>
                  @endif

                </form>

              </div>
              <!-- /.box-body -->
            </div>
           

           

          <div class="tab-pane" id="tab_2">
            <div class="box box-warning">
            <div class="col-md-12">
                    <label id="alerta_horario_{{$task['id']}}" class="pull-right"></label>
</div>
              <div class="box-body" id="content-edit-apontamentos">
            
              </div>
            </div>
          </div>

          <div class="tab-pane" id="tab_3">
            <div class="box box-danger">

              <div class="box-body" id="content-historico">
              </div>
            </div>
          </div>

          <div class="tab-pane" id="tab_4">
            <div class="box box-info">
              <div class="box-header">
              </div>
              <style>

              </style>
              <div class="box-body">
                <div class="row">
                  <div class="col-md-12">
                    <div class="form-group">
                      <label for="new_notes">Notas</label>
                      <textarea rows="5" class="form-control input-sm" name="new_notes" id="new_notes"></textarea>

                    </div>
                  </div>

                  <div class="col-md-6">
                    <div class="form-group">
                      <label for="fileUpload">Upload</label>
                      <input class="form-control input-sm" multiple="multiple" type="file" name="fileUpload[]" id="fileUpload" />
                    </div>
                  </div>

                </div>
                <div class="col-md-12" style="text-align:center;">
          <button type="button" class="btn btn-xs btn-info" name="btn-save-notes" id="btn-save-notes" style="padding: 5px 15px;">
                    <i class="fa fa-floppy-o"></i> Salvar Dados
                  </button>
        </div>
              </div>
            </div>
            
          </div>
        
        </div>
      </div>
      <!-- /.box -->
    </div>
  </div>
@stop



@section('js')

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.11/jquery.mask.min.js"></script>
  
  
<script>

  $(document).ready(function(){
  $('[data-toggle="popover"]').popover();
});

//botão anexos da BRK
$(document).on('click','#btn-anexos-brk', function(e){
    var project_id =  $('#projectid').val();
    var taskid =  $('#taskid').val();
    var data = '&project_id=' + project_id + '&taskid=' + taskid;

    if(data){
      $.ajax({
        url : "{{URL::to('/anexosbrk')}}",
        data: data,
        type: 'POST',
        success: function(data){
          console.log(data);
          $('#btn-anexos-brk').hide();
          $('#anexosbrk').html(data);

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
    });
  
var description_mark = new SimpleMDE({ element: $("#description")[0],
  toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],	spellChecker: false,status: false});

  var notes_task_mark = new SimpleMDE({ element: $("#notes_task")[0],
  toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],	spellChecker: false,status: false});
  // var notes_mark = new SimpleMDE({ element: $("#notes")[0],
  // toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],spellChecker: false,	status: false});
  var new_notes_mark = new SimpleMDE({ element: $("#new_notes")[0],toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],spellChecker: false,status: false
});



    //atualizar quando um chamado for capturado
    var atualiza = localStorage.getItem('sla');

    if(atualiza == 2){

      localStorage.setItem('contador', 4);

    }
    
    var editar_descricao = false;

    function camposCustomizados(statusid, newstatus){
      $('#outrasinfos').html('<h3>carregado campos obrigatórios ...</h3>');
      $('#novoapontamento').hide();
      $('#btn-save-task').hide('');
      var taskid = $('#edit_task_id').val();

      var data = 'statusid='+statusid+'&taskid='+taskid+'&newstatus='+newstatus;
      $.ajax({
        url : "{{URL::to('/customfields')}}",
        data: data,
        type: 'post',
        dataType: 'html',
        async: false,
        success: function(data){
          $('#outrasinfos').html(data);
          var apontamento = $('#cf_26_'+taskid).val();
          if(apontamento) $('#novoapontamento').show();
          $('#btn-save-task').show('');
        }
      });
      
     jQuery(function($){
      // $("#spent_on").mask("00/00/0000");
      // $("#hora_entrada_trabalho").mask("00:00");
      // $("#hora_saida_almoco").mask("00:00");
      // $("#hora_retorno_almoco").mask("00:00");
      // $("#hora_saida_trabalho").mask("00:00");
      $("#cf_21_"+{{$task['id']}}).mask("0000-00-00 00:00");
      $("#cf_22_"+{{$task['id']}}).mask("0000-00-00 00:00");
      $("#cf_30_"+{{$task['id']}}).mask("0000-00-00 00:00");
      $("#cf_31_"+{{$task['id']}}).mask("0000-00-00 00:00");

    });
    }


    $(document).on('change','#novasituacao', function(e){
      $('#btn-save-task').hide('');
      var statusid = $(this).val();
      camposCustomizados(statusid, 1);
    });
    
    $(document).on('click','#btn-ver-descricao', function(e){
      $('#editor-descricao').prop('height','200px');
      $('#editor-descricao').toggle();
      $('#html-descricao').toggle();
      editar_descricao=true;
      // var valorDaDiv = $('#editor-descricao').closest('div').closest('p').html();    
      // alert(valorDaDiv);
    });
    $('#editor-descricao').prop('height','0');
    $('#editor-descricao').hide();

    camposCustomizados({{ $task['status']['id'] }},0);

</script>


@stop
