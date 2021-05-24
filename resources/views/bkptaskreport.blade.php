@extends('adminlte::page')

@section('title', $task['id'] . ' - ' .strip_tags($task['subject']) )

@section('content_header')
    <h1><i class="fa fa-tasks"></i> Chamado {{ $task['id'] }} - {{ mb_substr(strip_tags($task['subject']),0, 100) }} {{ mb_substr(strip_tags($task['subject']),101, 100) }} {{ mb_substr(strip_tags($task['subject']),201, 100) }}
    <small>Atender Chamado</small>
    </h1>
@stop

@section('content')
<div class="row">
  <div class="col-md-12 col-xs-12">

    <div id="message"></div>

    <div class="nav-tabs-custom">
      <ul class="nav nav-tabs">
        <li class="active">
          <a href="#tab_1" data-toggle="tab">
            <i class="fa fa-pencil text-blue"></i> Chamado</a>
        </li>
        <li>
          <a href="#tab_2a" data-toggle="tab">
            <i class="fa fa-clock-o text-yellow"></i> Novo Apontamento</a>
        </li>
        <li>
          <a href="#tab_2" data-toggle="tab" id="aba-apontamentos">
            <i class="fa fa-clock-o text-yellow"></i> Apontamentos</a>
        </li>
          <li>
          <a href="#tab_3" data-toggle="tab" id="aba-historico">
            <i class="fa fa-list text-danger"></i> Histórico</a>
        </li>
        <li>
        <a href="#tab_4" data-toggle="tab">
          <i class="fa fa-sticky-note text-info"></i> Notas</a>
      </li>
      </ul>
      <div class="tab-content">
        <div class="tab-pane active" id="tab_1">

          <div class="box box-primary">
            <div class="box-header">

              <div class="box-tools form-inline">
                @if(\Session::get('user')['id']==$task['assigned_to']['id'])
                <div class="form-group">
                  <label for="novasituacao">Nova Situação <span class="text-red">*</span></label>
                  <select class="form-control input-sm" name="novasituacao" id="novasituacao" style="width: 200px;">
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

                <button type="button" class="btn btn-sm btn-primary" name="btn-save-task" id="btn-save-task">
                  <i class="fa fa-floppy-o"></i> Salvar Chamado
                </button>
                @endif

              </div>
            </div>

            <div class="box-body">
              <br />

              <form id="chamado">

                <input type="hidden" id="author" value="{{ $task['author']['id'] }}" />
                <input type="hidden" id="done_ratio" value="{{ $task['done_ratio'] }}" />

              <div class="row">
                <div class="col-md-3">
                  <div class="form-group">
                    <label for="contato">Contato</label>
                    <input type="text" class="form-control input-sm " name="contato" id="contato" value="{{ $contato[0]->nome_contato }}" readonly="">
                  </div>
                </div>

                <div class="col-md-3">
                  <div class="form-group">
                    <label for="contato_email">Email</label>
                    <input type="text" class="form-control input-sm" name="contato_email" id="contato_email" value="{{ $contato[0]->email }}" readonly="">
                  </div>
                </div>

                <div class="col-md-3">
                  <div class="form-group">
                    <label for="contato_telefone">Telefone</label>
                    <input type="text" class="form-control input-sm" name="contato_telefone" id="contato_telefone" value="{{ $contato[0]->telefone }}" readonly="">
                  </div>
                </div>
              </div>

              <div class="row">
                <div class="col-md-3">
                  <div class="form-group">
                    <label for="project_name">Projeto</label>
                    <input type="text" class="form-control input-sm" name="project_name" id="project_name" value="{{ $task['project']['name'] }}" readonly>
                    <input type="hidden" class="form-control input-sm" name="edit_task_id" id="edit_task_id" value="{{ $task['id'] }}" readonly>
                    <input type="hidden" class="form-control input-sm" name="edit_project_id" id="edit_project_id" value="{{ $task['project']['id'] }}" readonly>
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="status">Situação</label>
                    <input type="text" class="form-control input-sm" name="status_name" id="status_name" value="{{ $task['status']['name'] }}" readonly>
                  </div>
                </div>

                <!--div class="col-md-2">
                  <div class="form-group">
                    <label for="author_name">Criado por</label>
                    <input type="text" class="form-control input-sm" name="author_name" id="author_name" value="{{ $task['author']['name'] }}" readonly>
                  </div>
                </div-->

                <div class="col-md-3">
                  <div class="form-group">
                    <label for="assigned_to">Atribuído para</label>
                    @if(\Session::get('user')['id']==$task['assigned_to']['id'])
                      {!! $transferirpara !!}
                    @else
                    <input type="text" class="form-control input-sm" name="assigned_to_name" id="assigned_to_name" value="{{ $task['assigned_to']['name'] }}" readonly>
                    @endif
                  </div>
                </div>


                <div class="col-md-2">
                  <div class="form-group">
                    <label for="tracker">Tipo</label>
                    <select class="form-control input-sm" name="tracker" id="tracker" required>
                      @foreach ($trackers as $tracker)
                        @if($tracker->id==$task['tracker']['id'])
                          <option value="{{ $tracker->id }}" selected>{{ $tracker->name }}</option>
                        @else
                          <option value="{{ $tracker->id }}">{{ $tracker->name }}</option>
                        @endif
                      @endforeach
                    </select>
                  </div>
                </div>
              </div>

              <div class="row">
                <div class="col-md-4">
                  <div class="form-group">
                    <label for="title">Título</label>
                    <input type="text" class="form-control input-sm" name="title" id="title" value="{{ $task['subject'] }}" required>
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="created_on">Início</label>
                    <input type="text" class="form-control input-sm" name="created_on" id="created_on" value="{{ $task['start_date'] }}" required>
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="due_date">Data Prevista</label>
                    @if(isset($task['due_date']))
                      <input type="text" class="form-control input-sm" name="due_date" id="due_date" value="{{ $task['due_date'] }}">
                    @else
                      <input type="text" class="form-control input-sm" name="due_date" id="due_date" value="">
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
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="spent_hours">Tempo estimado</label>
                    <input type="text" class="form-control input-sm" name="spent_hours" id="spent_hours" value="{{ $task['spent_hours'] }}" required>
                  </div>
                </div>

              </div>

              <div class="row">
                <div class="col-md-12">
                  <div class="form-group">
                    <label for="description">Descrição</label>
                    <textarea rows="3" class="form-control input-ms" name="description" id="description">{{ $task['description'] }}</textarea>
                  </div>
                </div>
              </div>

              <div class="row">
                <div class="col-md-12">
                  <h4 class="h4">Outras Informações</h4>
                </div>
                <div class="col-md-12" id="outrasinfos"></div>
              </div>

                <!--- novo apontamento origatório --->
                <div class="row" id="novoapontamento" style="display:none;">
                  <div class="col-md-1">
                    <div class="form-group" id="help_spent_on_{{ $task['id'] }}" >
                      <label for="spent_on">Data <span class="text-red">*</span></label>
                      <input type="text" name="spent_on_{{ $task['id'] }}" id="spent_on_{{ $task['id'] }}" value="{{ date('d/m/Y') }}" placeholder="dd/mm/aaaa" class="form-control input-sm calcular required" style="width:90px;" />
                    </div>
                  </div>

                  <div class="col-md-1">
                    <div class="form-group" id="help_hora_entrada_trabalho_{{ $task['id'] }}" >
                      <label for="hora_entrada_trabalho">Entrada <span class="text-red">*</span></label>
                      <input type="text" name="hora_entrada_trabalho_{{ $task['id'] }}" id="hora_entrada_trabalho_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular required" style="width:60px;">
                    </div>
                  </div>

                  <div class="col-md-1">
                    <div class="form-group">
                      <label for="hora_saida_almoco">Saída</label>
                      <input type="text" name="hora_saida_almoco_{{ $task['id'] }}" id="hora_saida_almoco_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular" style="width:60px;">
                    </div>
                  </div>

                  <div class="col-md-1">
                    <div class="form-group">
                      <label for="hora_retorno_almoco">Retorno</label>
                      <input type="text" name="hora_retorno_almoco_{{ $task['id'] }}" id="hora_retorno_almoco_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular" style="width:60px;">
                    </div>
                  </div>

                  <div class="col-md-1">
                    <div class="form-group" id="help_hora_saida_trabalho_{{ $task['id'] }}">
                      <label for="hora_saida_trabalho">Saída <span class="text-red">*</span></label>
                      <input type="text" name="hora_saida_trabalho_{{ $task['id'] }}" id="hora_saida_trabalho_{{ $task['id'] }}" value="" placeholder="00:00" class="form-control input-sm calcular required" style="width:60px;">
                    </div>
                  </div>

                  <div class="col-md-1">
                    <div class="form-group" id="help_horas_{{ $task['id'] }}">
                      <label for="horas">Horas <span class="text-red">*</span></label>
                      <input type="text" name="horas_{{ $task['id'] }}" id="horas_{{ $task['id'] }}" value="" placeholder="0.00" class="form-control input-sm required" style="width:60px;">
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

              <div class="col-md-12">
                <label><span class="text-red">*</span> Campos obrigatórios</label>
                <label id="alerta_horario_{{ $task['id'] }}" class="pull-right"></label>
              </div>

              </form>

            </div>
            <!-- /.box-body -->
          </div>

        </div>

        <div class="tab-pane" id="tab_2a">

          <div class="box box-yellow">
            <div class="box-header">
              <div class="box-tools">
                <button type="button" class="btn btn-primary btn-sm" id="btn-save-newtime"><i class="fa fa-floppy-o"></i> Salvar</button>
              </div>
            </div>
            <!-- /.box-header -->
            <div class="box-body">

              <div class="row">
                <div class="col-md-12">
                  <div class="form-group">
                    <label for="notes">Descrever o atendimento <span class="text-red">*</span></label>
                    <input type="hidden" id="projectid" value="{{ $task['project']['id'] }}" />
                    <input type="hidden" id="taskid" value="{{ $task['id'] }}" />
                    <input type="hidden" id="statusid" value="" />
                    <input type="hidden" id="status" value="" />
                    <textarea class="form-control input-sm" name="notes" id="notes" rows="3" cols="80"></textarea>
                  </div>
                </div>
              </div>

              <div class="row">
                <div class="col-md-1">
                  <div class="form-group">
                    <label for="spent_on">Data <span class="text-red">*</span></label>
                    <input type="text" name="spent_on" id="spent_on" value="{{ date('d/m/Y') }}" placeholder="dd/mm/aaaa" class="form-control input-sm calcular_novo" style="width:90px;" />
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_entrada_trabalho">Entrada <span class="text-red">*</span></label>
                    <input type="text" name="hora_entrada_trabalho" id="hora_entrada_trabalho" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_saida_almoco">Saída</label>
                    <input type="text" name="hora_saida_almoco" id="hora_saida_almoco" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_retorno_almoco">Retorno</label>
                    <input type="text" name="hora_retorno_almoco" id="hora_retorno_almoco" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_saida_trabalho">Saída <span class="text-red">*</span></label>
                    <input type="text" name="hora_saida_trabalho" id="hora_saida_trabalho" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="horas">Horas <span class="text-red">*</span></label>
                    <input type="text" name="horas" id="horas" value="" placeholder="0.00" class="form-control input-sm" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="atividade">Atividade <span class="text-red">*</span></label>
                    <select class="form-control input-sm" name="atividade" id="atividade">
                      @foreach ($activities as $ativ)
                        <option value="{{ $ativ['id'] }}">{{ $ativ['name'] }}</option>
                      @endforeach
                    </select>
                  </div>
                </div>

                <div class="col-md-3">
                  <div class="form-group">
                    <label for="atividades">Atividades <span class="text-red">*</span></label>
                    <input class="form-control input-sm" type="text" name="atividades" id="atividades" value="" placeholder="atividades">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group" id="help_tipohora">
                    <label for="tipo_hora">Tipo Hora <span class="text-red">*</span></label>
                      <select class="form-control input-sm" name="tipo_hora" id="tipo_hora">
                        <option value="Normal">Normal</option>
                        <option value="Extra">Extra</option>
                      </select>
                  </div>
                </div>

              </div>

              <div class="col-md-12">
                <label><span class="text-red">*</span> Campos obrigatórios</label>
                <label id="alerta_horario" class="pull-right"></label>
             </div>
            </div>
          </div>
        </div>

        <div class="tab-pane" id="tab_2">
          <div class="box box-warning">
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
              <div class="box-tools">
                <button type="button" class="btn btn-xs btn-info" name="btn-save-notes" id="btn-save-notes">
                  <i class="fa fa-sticky-note"></i> Adicionar Notas
                </button>
              </div>
            </div>

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
                      <input class="form-control input-sm" type="file" name="fileUpload" id="fileUpload" />
                      <button class="btn btn-primary btn-sm" type="button" name="btnEnviar" id="btnEnviar">Enviar Arquivo</button>
                  </div>
                </div>

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
<script>
CKEDITOR.replace( 'description',{entities:false} );
CKEDITOR.replace( 'notes',{entities:false} );
CKEDITOR.replace( 'new_notes',{entities:false} );

function camposCustomizados(statusid, newstatus){
  $('#outrasinfos').html('carregado campos obrigatórios ...');
  $('#novoapontamento').hide();
  var taskid = $('#edit_task_id').val();

  var data = 'statusid='+statusid+'&taskid='+taskid+'&newstatus='+newstatus;
  $.ajax({
    url : "{{URL::to('/customfields')}}",
    data: data,
    type: 'post',
    dataType: 'html',
    success: function(data){
      $('#outrasinfos').html(data);
      var apontamento = $('#cf_26_'+taskid).val();
      if(apontamento) $('#novoapontamento').show();
    }
  });
}


$(document).on('change','#novasituacao', function(e){
  var statusid = $(this).val();
  camposCustomizados(statusid, 1);
});

camposCustomizados({{ $task['status']['id'] }},0);
</script>
@stop
