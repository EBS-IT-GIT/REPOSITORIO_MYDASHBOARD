<div class="nav-tabs-custom">
  <ul class="nav nav-tabs">
    <li class="active">
      <a href="#tab_change_1a" data-toggle="tab">
        <i class="fa fa-plus-square-o text-blue"></i> Novo Apontamento</a>
    </li>
    <li>
      <a href="#tab_change_2a" data-toggle="tab" id="aba-change-apontamentos">
        <i class="fa fa-clock-o text-yellow"></i> Apontamentos</a>
    </li>
  </ul>
  <div class="tab-content">
    <div class="tab-pane active" id="tab_change_1a">

      <div class="box box-primary">
        <div class="box-header">
          <div class="box-tools">
            <button type="button" class="btn btn-primary btn-sm" id="btn-save-time"><i class="fa fa-floppy-o"></i> Salvar</button>
          </div>
        </div>
        <!-- /.box-header -->
        <div class="box-body">

          <div class="row">
            <div class="col-md-12">
              <div class="form-group">
                <label for="time_notes">Descrever o atendimento <span class="text-red">*</span></label>
                <input type="hidden" id="projectid" value="{{ $task['project']['id'] }}" />
                <input type="hidden" id="taskid" value="{{ $task['id'] }}" />
                <input type="hidden" id="statusid" value="{{ $statusid }}" />
                <input type="hidden" id="status" value="{{ $status }}" />
                <textarea class="form-control input-sm" name="time_notes" id="time_notes" rows="3" cols="80"></textarea>
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
        </div>
      </div>
    </div>

    <div class="tab-pane" id="tab_change_2a">
      <div class="box box-warning">
        <!-- /.box-header -->
        <div class="box-body" id="content-change-apontamentos">
          <table id="table-apontamentos" class="table table-striped table-bordered table-hover display compact">
            <thead>
            <tr>
              <th style="width: 3%">#</th>
              <th>Analista</th>
              <th>Atividade</th>
              <th>Data</th>
              <th>Horas</th>
              <th>Atividades</th>
              <th>Entrada</th>
              <th>Saída</th>
              <th>Retorno</th>
              <th>Saída</th>
              <th></th>
            </tr>
            </thead>
            <tbody>
              @foreach ($times as $key => $time)
                @if(\Session::get('user')['id']==$time['user']['id'])
                  <tr>
                    <td>{{ $key+1 }}</td>
                    <td>{{ $time['user']['name'] }}</td>
                    <td>
                      <input type="text" class="form-control input-sm" name="atividades{{$time['id']}}" id="atividades{{$time['id']}}" value="{{ $time['custom_fields'][4]['value'] }}" placeholder="atividades"  style="width:300px;" >
                    </td>
                    <td>
                      <input type="text" name="data{{$time['id']}}" id="data{{$time['id']}}" value="{{$time['spent_on']}}" placeholder="dd/mm/aaaa" class="form-control input-sm" style="width:90px;" />
                    </td>
                    <td>
                      <input type="text" name="horas{{$time['id']}}" id="horas{{$time['id']}}" value="{{$time['hours']}}" placeholder="0.00" class="form-control input-sm" style="width:60px;">
                    </td>
                    <td>
                      <select class="form-control input-sm" name="activities{{$time['id']}}" id="activities{{$time['id']}}">
                        @foreach ($activities as $activity)
                          @if($activity['id']==$time['activity']['id'])
                            <option value="{{$activity['id']}}" selected>{{$activity['name']}}</option>
                          @else
                            <option value="{{$activity['id']}}" >{{$activity['name']}}</option>
                          @endif
                        @endforeach
                      </select>
                    </td>
                    <td>
                      <input type="text" name="hora_entrada_trabalho{{$time['id']}}" id="hora_entrada_trabalho{{$time['id']}}" value="{{ $time['custom_fields'][0]['value'] }}" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                    </td>
                    <td>
                      <input type="text" name="hora_saida_almoco{{$time['id']}}" id="hora_saida_almoco{{$time['id']}}" value="{{ $time['custom_fields'][1]['value'] }}" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                    </td>
                    <td>
                      <input type="text" name="hora_retorno_almoco{{$time['id']}}" id="hora_retorno_almoco{{$time['id']}}" value="{{ $time['custom_fields'][2]['value'] }}" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                    </td>
                    <td>
                      <input type="text" name="hora_saida_trabalho{{$time['id']}}" id="hora_saida_trabalho{{$time['id']}}" value="{{ $time['custom_fields'][3]['value'] }}" placeholder="00:00" class="form-control input-sm" style="width:60px;">
                    </td>
                    <td style="vertical-align: middle">
                      <button type="button" class="btn btn-sm btn-warning btn-edit-time" name="button" data-timeid="{{$time['id']}}"><i class="fa fa-floppy-o"></i> salvar</button>
                    </td>
                  </tr>
                @else
                  <tr>
                    <td>{{ $key+1 }}</td>
                    <td>{{ $time['user']['name'] }}</td>
                    <td>{{ $time['activity']['name'] }}</td>
                    <td>{{ $time['spent_on'] }}</td>
                    <td>{{ $time['hours'] }}</td>
                    <td>{{ $time['custom_fields'][4]['value'] }}</td>
                    <td>{{ $time['custom_fields'][0]['value'] }}</td>
                    <td>{{ $time['custom_fields'][1]['value'] }}</td>
                    <td>{{ $time['custom_fields'][2]['value'] }}</td>
                    <td>{{ $time['custom_fields'][3]['value'] }}</td>
                  </tr>
                @endif
              @endforeach
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
<script>
var time_notes_mark = new SimpleMDE({ element: $("#time_notes")[0],
toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],	spellChecker: false,autofocus: true,});

</script>
