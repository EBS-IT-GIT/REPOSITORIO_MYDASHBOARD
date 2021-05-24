<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.11/jquery.mask.min.js"></script>
<div class="box-header" id="header-taskreport">
<div class="box-tools form-inline">

 <button type="button" style="background-color:transparent;"id="show-apontamento" class="btn pull-right"><i class="fa fa-plus-circle text-green"></i><strong> Adicionar Apontamento</strong></button>
 <button type="button" style="background-color:transparent;display:none;"id="hide-apontamento" class="btn pull-right"><i class="fa fa-times-circle text-red" aria-hidden="true"></i></i><strong> Cancelar Apontamento</strong></button>
  </div>

</div>
<div class="box box-default" id="box-taskreport">
<input type="hidden" id="taskid_edit" value="{{$task['id']}}"/>
<input type="hidden" id="project_edit" value="{{$task['project']['id']}}"/>

<div class="table-responsive">
  <label id="alerta_horario" class="pull-left"></label>
  <table id="table-apontamentos" class="table table-striped table-bordered table-hover table-striped display compact">

    <thead>
    <tr>
      <th style="width: 3%">#</th>
      <th style="white-space: nowrap;">Analista</th>
      <th style="white-space: nowrap;">Data <span class="text-red">*</span></th>
      <th style="white-space: nowrap;">Entrada <span class="text-red">*</span></th>
      <th style="white-space: nowrap;">Saída</th>
      <th style="white-space: nowrap;">Retorno</th>
      <th style="white-space: nowrap;">Saída <span class="text-red">*</span></th>
      <th style="white-space: nowrap;">Horas <span class="text-red">*</span></th>
      <th style="padding:5px 40px;">Atividade<span class="text-red">*</span></th>
      <th style="padding:5px 0px;white-space: nowrap;">Descrever o atendimento <span class="text-red">*</span></th>
      <th style="padding:5px 20px;white-space: nowrap;">Tipo Hora <span class="text-red">*</span></th>
      <th></th>
    </tr>
    </thead>
    <tbody>
    <tr id="apontamento-bloco"  style="display:none;background-color:#e8eaed;">
            <td><i class="fa fa-plus-circle text-green" aria-hidden="true"></i></td>
            <td>{{\Session::get('user')['firstname']}} {{\Session::get('user')['lastname']}}</td>
            <td>
            <input type="text" name="spent_on" id="spent_on" value="{{ date('d/m/Y') }}" placeholder="dd/mm/aaaa" class="form-control input-sm calcular_novo" style="width:80px;" />
            </td>
            <td>
            <input type="text" name="hora_entrada_trabalho" id="hora_entrada_trabalho" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
            </td>
            <td>
            <input type="text" name="hora_saida_almoco" id="hora_saida_almoco" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
            </td>
            <td>
            <input type="text" name="hora_retorno_almoco" id="hora_retorno_almoco" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
            </td>
            <td>
            <input type="text" name="hora_saida_trabalho" id="hora_saida_trabalho" value="" placeholder="00:00" class="form-control input-sm calcular_novo" style="width:60px;">
            </td>
            <td>
            <input type="text" name="horas" id="horas" value="" placeholder="0.00" class="form-control input-sm" style="width:60px;" disabled="disabled">
            </td>
            <td>
            <select class="form-control input-sm" name="atividade" id="atividade">
                @foreach ($activities as $activity)
                    <option value="{{$activity['id']}}" >{{$activity['name']}}</option>
                @endforeach
              </select>
            </td>
            <td style="max-width:180px;">

              <textarea rows="3" class="form-control input-sm" name="notes" id="notes" value="" placeholder="Descrever o atendimento..."  style="max-width:160px;min-height:32px;"></textarea>
            </td>
            <td>
            <select class="form-control input-sm" name="tipo_hora" id="tipo_hora">
                <option value="Normal">Normal</option>
                <option value="Extra">Extra</option>
              </select>
            </td>
            <td>
            @if(!isset($contador[0]))
                    <button type="button" class="btn btn-primary btn-sm" id="btn-save-newtime"><i class="fa fa-floppy-o"></i></button>
            @endif
            </td>
 </tr>

      @foreach ($times as $key => $time)
        @if(\Session::get('user')['id']==$time['user']['id'])
          <tr>
            <td>{{ $key+1 }}</td>
            <td>{{ $time['user']['name'] }}</td>
            <td>
              <input type="text" name="spent_on{{$time['id']}}"  id="spent_on{{$time['id']}}" value="{{ date("d/m/Y", strtotime($time['spent_on'])) }}" placeholder="dd/mm/aaaa" class="form-control input-sm calcular_edit" data-timeid="{{ $time['id'] }}" style="width:80px;" />
            </td>
            <td>
              <input type="text" name="hora_entrada_trabalho{{$time['id']}}" id="hora_entrada_trabalho{{$time['id']}}" value="{{ $time['custom_fields'][0]['value'] }}" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="{{ $time['id'] }}" style="width:60px;">
            </td>
            <td>
              <input type="text" name="hora_saida_almoco{{$time['id']}}" id="hora_saida_almoco{{$time['id']}}" value="{{ $time['custom_fields'][1]['value'] }}" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="{{ $time['id'] }}" style="width:60px;">
            </td>
            <td>
              <input type="text" name="hora_retorno_almoco{{$time['id']}}" id="hora_retorno_almoco{{$time['id']}}" value="{{ $time['custom_fields'][2]['value'] }}" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="{{ $time['id'] }}" style="width:60px;">
            </td>
            <td>
              <input type="text" name="hora_saida_trabalho{{$time['id']}}" id="hora_saida_trabalho{{$time['id']}}" value="{{ $time['custom_fields'][3]['value'] }}" placeholder="00:00" class="form-control input-sm calcular_edit" data-timeid="{{ $time['id'] }}" style="width:60px;">
            </td>
            <td>
              <input type="text" name="horas{{$time['id']}}" id="horas{{$time['id']}}" value="{{$time['hours']}}" placeholder="0.00" class="form-control input-sm" disabled="disabled" style="width:60px;">
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
            <td style="max-width:180px;">

              <textarea rows="3" class="form-control input-sm" name="atividades{{$time['id']}}" id="atividades{{$time['id']}}" value="{{ $time['custom_fields'][4]['value'] }}" placeholder="Descrever o atendimento"  style="max-width:160px;min-height:32px;" >{{ $time['custom_fields'][4]['value'] }}</textarea>
            </td>
            <td>
              <select class="form-control input-sm" name="tipo_hora{{$time['id']}}" id="tipo_hora{{$time['id']}}">
                <option value="Normal" @if($time['custom_fields'][5]['value']=="Normal") selected @endif>Normal</option>
                <option value="Extra" @if($time['custom_fields'][5]['value']=="Extra") selected @endif>Extra</option>
              </select>
            </td>
            <td style="vertical-align: middle">
              @if(!isset($contador[0]))
              <button type="button" class="btn btn-primary btn-sm btn-edit-time" name="button" data-timeid="{{$time['id']}}"><i class="fa fa-floppy-o"></i> </button>
              @endif
              <button type="button" class="btn btn-sm btn-danger btn-delete-time" name="button" data-timeid="{{$time['id']}}"><i class="fa fa-trash-o"></i> </button>
            </td>
          </tr>
        @else
          <tr>
            <td>{{ $key+1 }}</td>
            <td>{{ $time['user']['name'] }}</td>
            <td>{{ $time['spent_on'] }}</td>
            <td>{{ $time['custom_fields'][0]['value'] }}</td>
            <td>{{ $time['custom_fields'][1]['value'] }}</td>
            <td>{{ $time['custom_fields'][2]['value'] }}</td>
            <td>{{ $time['custom_fields'][3]['value'] }}</td>
            <td>{{ $time['hours'] }}</td>
            <td>{{ $time['activity']['name'] }}</td>
            <td style="max-width:200px;">{{ $time['custom_fields'][4]['value'] }}</td>
            <td>@IF(isset($time['custom_fields'][17])){{ $time['custom_fields'][17]['value'] }} @ELSE Normal @ENDIF</td>
          </tr>
        @endif

        <script>
         jQuery(function($){
            $("#spent_on{{$time['id']}}").mask("00/00/0000");
            $("#hora_entrada_trabalho{{$time['id']}}").mask("00:00");
            $("#hora_saida_almoco{{$time['id']}}").mask("00:00");
            $("#hora_retorno_almoco{{$time['id']}}").mask("00:00");
            $("#hora_saida_trabalho{{$time['id']}}").mask("00:00");
         });
          var atividades_time_mark = new SimpleMDE({ element: $("#atividades{{$time['id']}}")[0]});
          atividades_time_mark.toTextArea();
          atividades_time_mark = null;

        </script>
      @endforeach
    </tbody>
  </table>
</div>
</div>

<script>
 jQuery(function($){
           
            $("#hora_entrada_trabalho").mask("00:00");
            $("#hora_saida_almoco").mask("00:00");
            $("#hora_retorno_almoco").mask("00:00");
            $("#hora_saida_trabalho").mask("00:00");

          });
</script>




