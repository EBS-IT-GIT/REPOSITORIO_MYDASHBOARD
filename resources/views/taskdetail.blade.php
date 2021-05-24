<div class="row">
  <div class="col-md-12 col-xs-12">

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
              <div class="box-tools">
                <button type="button" class="btn btn-xs btn-primary" name="btn-save-task" id="btn-save-task">
                  <i class="fa fa-floppy-o"></i> Salvar Chamado
                </button>
              </div>
            </div>
            <div class="box-body">

              <div class="row">
                <div class="col-md-3">
                  <div class="form-group">
                    <label for="project_name">Projeto</label>
                    <input type="text" class="form-control input-sm" name="project_name" id="project_name" value="{{ $task['project']['name'] }}" readonly>
                    <input type="hidden" class="form-control input-sm" name="edit_task_id" id="edit_task_id" value="{{ $task['id'] }}" readonly>
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="author_name">Criado por</label>
                    <input type="text" class="form-control input-sm" name="author_name" id="author_name" value="{{ $task['author']['name'] }}" readonly>
                  </div>
                </div>

                <div class="col-md-3">
                  <div class="form-group">
                    <label for="assigned_to">Atribuído para</label>
                    <input type="text" class="form-control input-sm" name="assigned_to_name" id="assigned_to_name" value="{{ $task['assigned_to']['name'] }}" readonly>
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="status">Situação</label>
                    <input type="text" class="form-control input-sm" name="status_name" id="status_name" value="{{ $task['status']['name'] }}" readonly>
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
                <div class="col-md-12">
                  <div class="form-group">
                    <label for="description">Descrição/Notas</label>
                    <textarea rows="3" class="form-control input-ms" name="description" id="description">{{ $task['description'] }}</textarea>
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
              </div>

              <!-- custom fields issues -->
              @if(isset($task['custom_fields']))
              <div class="row">
                <h4 class="h4">Outras Informações</h4>

                @foreach ($task['custom_fields'] as $key => $value)
                  <div class="col-md-3">
                    <div class="form-group">
                      <label for="title">{{ $value['name']}} [{{ $value['id'] }}]</label>

                      @if(isset($custom_fields))
                        @foreach ($custom_fields as $cf_key => $cf_value)
                          @if($value['id']==$cf_value['id'])
                              @if(isset($cf_value['possible_values']))
                                <select class="form-control input-sm" name="cf_{{ $value['id'] }}" id="cf_{{ $value['id'] }}">
                                  <option value=""></option>
                                @foreach ($cf_value['possible_values'] as $pv_value)
                                  @if(isset($pv_value['value']) && isset($value['value']))
                                    @if($value['value']==$pv_value['value'])
                                      <option value="{{ $pv_value['value'] }}" selected>
                                        {{ $pv_value['value'] }}
                                      </option>
                                    @else
                                      <option value="{{ $pv_value['value'] }}">
                                        {{ $pv_value['value'] }}
                                      </option>
                                    @endif
                                  @endif
                                @endforeach
                                </select>
                              @else
                                <input type="text" class="form-control input-sm" name="cf_{{ $value['id'] }}" id="cf_{{ $value['id'] }}" value="{{ $value['value'] }}">
                              @endif
                          @endif
                        @endforeach
                      @endif
                    </div>
                  </div>
                @endforeach
              </div>
              @endif

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
                    <input type="hidden" id="projectid" value="" />
                    <input type="hidden" id="taskid" value="" />
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
                    <input type="text" name="spent_on" id="spent_on" value="{{ date('d/m/Y') }}" placeholder="dd/mm/aaaa" class="form-control input-sm" style="width:90px;" />
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="horas">Horas <span class="text-red">*</span></label>
                    <input type="text" name="horas" id="horas" value="" placeholder="0.00" class="form-control input-sm" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-4">
                  <div class="form-group">
                    <label for="atividades">Atividades <span class="text-red">*</span></label>
                    <input class="form-control input-sm" type="text" name="atividades" id="atividades" value="" placeholder="atividades">
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

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_entrada_trabalho">Entrada <span class="text-red">*</span></label>
                    <input type="text" name="hora_entrada_trabalho" id="hora_entrada_trabalho" value="" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_saida_almoco">Saída</label>
                    <input type="text" name="hora_saida_almoco" id="hora_saida_almoco" value="" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_retorno_almoco">Retorno</label>
                    <input type="text" name="hora_retorno_almoco" id="hora_retorno_almoco" value="" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="hora_saida_trabalho">Sáida <span class="text-red">*</span></label>
                    <input type="text" name="hora_saida_trabalho" id="hora_saida_trabalho" value="" placeholder="00:00" class="form-control input-sm" style="width:60px;">
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
<script>
  var description_mark = new SimpleMDE({ element: $("#description")[0],
  toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],	spellChecker: false,});
  var notes_mark = new SimpleMDE({ element: $("#notes")[0],
  toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],spellChecker: false,});
  var new_notes_mark = new SimpleMDE({ element: $("#new_notes")[0],toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],spellChecker: false,
});
</script>
