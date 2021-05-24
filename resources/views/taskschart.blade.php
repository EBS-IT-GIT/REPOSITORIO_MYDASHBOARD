@if(count($chart))
<table class="table table-bordered display compact">
    <thead>
      <tr>
        <th>Analista</th>
        <th style="width: 80px">New</th>
        <th style="width: 80px">In Progress</th>
        <th style="width: 80px">Paused</th>
        <th style="width: 80px">Feedback</th>
        <th style="width: 80px">Projeto</th>
      </tr>
    </thead>
    <tbody>
      @foreach ($chart as $key => $value)
      <tr>
        <td>{{ $value->responsavel }}</td>
        <td class="text-center" nowrap>
          <div class="progress-group">
            <span class="progress-number"><b>{{ $value->New }}</b></span>
            <div class="progress progress-xs">
              <div class="progress-bar progress-bar-green" style="width: {{ ($value->New/$total->New)*100 }}%"></div>
            </div>
          </div>
        </td>
        <td class="text-center">
          <div class="progress-group">
            <span class="progress-number"><b>{{ $value->InProgress }}</b></span>
            <div class="progress progress-xs">
              <div class="progress-bar progress-bar-yellow" style="width: {{ ($value->InProgress/$total->InProgress)*100 }}%"></div>
            </div>
          </div>
        </td>
        <td class="text-center">
          <div class="progress-group">
            <span class="progress-number"><b>{{ $value->Paused }}</b></span>
            <div class="progress progress-xs">
              <div class="progress-bar progress-bar-blue" style="width: @if($total->Paused>0){{ ($value->Paused / $total->Paused)*100 }}@else {{ $total->Paused }} @endif %"></div>
            </div>
          </div>
        </td>
        <td class="text-center">
          <div class="progress-group">
            <span class="progress-number"><b>{{ $value->Feedback }}</b></span>
            <div class="progress progress-xs">
              <div class="progress-bar progress-bar-aqua" style="width: @if($total->Feedback>0){{ ($value->Feedback / $total->Feedback)*100 }} @else {{ $total->Feedback }} @endif%"></div>
            </div>
          </div>
        </td>
        <td class="text-center">
          <div class="progress-group">
            <span class="progress-number"><b>{{ $value->Projeto }}</b></span>
            <div class="progress progress-xs">
              <div class="progress-bar progress-bar-red" style="width: @if($total->Projeto>0){{ ($value->Projeto/$total->Projeto)*100 }} @else {{ $total->Projeto }} @endif%"></div>
            </div>
          </div>
        </td>
      </tr>
      @endforeach
    </tbody>
  </table>
@else
  <h1>Nenhum registro encontrado!</h1>
@endif
