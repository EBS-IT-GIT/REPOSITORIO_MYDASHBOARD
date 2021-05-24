<ul>
@foreach ($attachments as $attachment)
  <li>

    <a href="/viewanexo/{{$attachment['id']}}" target="_blank" >
      <i class="fa fa-paperclip"></i>{{ $attachment['filename'] }}</a>
    <a class="btn btn-xs btn-primary btn-flat" href="/downanexo/{{$attachment['id']}}" target="_blank" style="border-radius: 3px;" download="{{$attachment['filename']}}"><i class="fa fa-download"></i> Download</a>
    <button type="button" class="btn btn-sm btn-danger btn-delete-time-report" data-timeid="{{$attachment['id']}}" id="btn-deletar-arquivo" value="{{ $attachment['id'] }}" style="padding: 1px 10px;"><i class="fa fa-trash-o"></i></button><br><br>
  </li>
@endforeach
</ul>
<hr />
@foreach (collect($journals)->groupBy('atualizado_por') as $key => $journal)
  <h5 style="border-bottom: 1px dashed #c1c1c1; width: 100%;">{!! $key !!}</h5>
  <ul>
  @foreach ($journal as $desc)
      @if($desc->historico)
        <li>{!! $desc->historico !!}</li>
   @endif
    @if($desc->property=='attachment')
          @endif
        @if($desc->property=='attachment' && $desc->btdowload == 1)
          <a href="/viewanexo/{{ $desc->prop_key }}" target="_blank">
            <i class="fa fa-paperclip"></i> {{ $desc->value }}
          </a>
          <a class="btn btn-xs btn-primary btn-flat" href="/downanexo/{{ $desc->prop_key }}" target="_blank" download="/downanexo/{{ $desc->id }}"><i class="fa fa-download"></i> download</a><br />
            @endif

  @endforeach
  </ul>
  @if($journal[0]->notes)
    <p>{!! $journal[0]->notes !!}</p>
  @endif
@endforeach
