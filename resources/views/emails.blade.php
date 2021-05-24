<p>Prezado(a) <span>{{$user->name}},</span><br>
 Você possui chamados com SLA estourados ou que vencem no dia de hoje. Por favor, verificar os status. Caso o atendimento não seja possível, verifique a situação com seu líder.<br><br>
 <table border="1">
   <tr>
       <td>Número do chamado</td>
       <td>Data expiração</td>
       <td>Status</td>
       <td>Cliente</td>
       <td>Descrição</td>
   </tr>
   <tr>
  
   @foreach($user->emails as $emails)
   
       <td>{{$emails->cdchamado}}</td>
       <td>{{$emails->dtnumber}}</td>
       <td>{{$emails->status_name}}</td>
       <td>{{$emails->cliente}}</td>
       <td>{{$emails->dschamado}}</td>
   </tr>
   @endforeach
</table>
</p>