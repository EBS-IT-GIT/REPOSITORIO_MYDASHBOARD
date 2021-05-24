
@extends('adminlte::page')

@foreach($name as $n)
@section('title', 'Nova tarefa - '.$n->name)
@endforeach
@section('content_header')

        <h1><i class="fa fa-folder"></i> @foreach($name as $n){{$n->name}}@endforeach<small><i class="fa fa-plus-circle" aria-hidden="true"></i> Nova Tarefa</small></h1>
@stop

@section('content')


<div class="row">
    <div class="col-md-12 col-xs-12">
        <input type="hidden" id="project_id" value="{{$project}}"/>
        <input type="hidden" id="data" value=""/>
        <div class="box box-success">
            <div class="box-header">
            <label><span class="text-red">*</span> Campos obrigatórios</label>
            </div>  
          <div class="box-body">
            <form id="chamado" enctype="multipart/form-data" >
              <div class="row">
                <div class="col-md-2">
                  <div class="form-group">
                    <label for="tracker" id="label_tracker">Tipo<span class="text-red">*</span></label>
                      <select class="form-control input-sm" name="tracker" id="new_tracker" required="required">
                        <option value=""></option>
                        @foreach($tipo as $tipo)
                              <option value="{{$tipo->id}}" >{{$tipo->name}}</option>
                        @endforeach
                      </select>
                      <div class="tooltip">sla</div>
                  </div>
                </div> 
                <div class="col-md-2">
                  <div class="form-group" >
                    <label for="new_status" id="label-status">Situação <span class="text-red">*</span></label>
                      <select class="form-control input-sm" name="new" id="new_status" required="required">
                        <option id="void" value=""></option>
                      </select>
                  </div>
                </div>  
                <div class="col-md-4">
                    <div class="form-group">
                        <label for="title" id="label_title">Título<span class="text-red">*</span></label>
                        <input type="text" class="form-control input-sm" name="title" id="new_title" value="">
                    </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                      <label for="assigned_to" id="label_assigned_to">Atribuído para</label>
                        {!! $transferir !!}
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label for="priority" id="label_priority">Prioridade</label>
                      <select class="form-control input-sm" name="priority" id="new_priority">
                        <option value=""></option>
                        @foreach($priorities as $priority)
                              <option value="{{$priority['id']}}" >{{$priority['name']}}</option>
                        @endforeach
                      </select>
                  </div>
                </div>
                <div class="col-md-2" style="display:none;">
                  <div class="form-group">
                      <label for="category" id="label_category"style="white-space: nowrap;">Categoria</label>
                        <select class="form-control input-sm" name="version" id="new_category">
                          <option value=""></option>
                          @foreach($categoria as $categoria)
                          <option value="{{$categoria->id}}">{{$categoria->name}}</option>
                          @endforeach
                        </select>
                  </div>
                </div>
                <div class="col-md-2" style="display:none;">
                  <div class="form-group">
                    <label for="version" id="label_version" style="white-space: nowrap;">Versão</label>
                      <select class="form-control input-sm" name="version" id="new_version">
                        <option value=""></option>
                        @foreach($versao as $ver)
                        <option value="{{$ver->id}}">{{$ver->name}}</option>
                        @endforeach
                      </select>
                  </div>
                    </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label for="tarefa-pai" id="label_pai" style="white-space: nowrap;">Tarefa Pai</label>
                    <select class="form-control input-sm" name="new_tarefa_pai" id="new_tarefa_pai">
                    <option value=""></option>
                    @foreach($parent['issues'] as $parent)
                    <option id="new_tarefa_pai" value="{{$parent['id']}}">{{$parent['subject']}}</option>
                    @endforeach
                    </select>
                  </div>
                </div>
                  
                <div class="col-md-2">
                  <div class="form-group">
                    <label for="created_on" id="label_created">Início</label>
                      <input type="date" class="form-control input-sm" name="created_on" id="new_created_on" value="{{$data}}"/>
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="due_date" id="label_due_date"style="white-space: nowrap;">Dt Prevista</label>
                    <input type="date" class="form-control input-sm" name="due_date" id="new_due_date" value=""/>
                  </div>
                </div>
                    <div class="col-md-1" style="display:none;">
                  <div class="form-group">
                    <label for="spent_hours" id="label_spent" style="white-space: nowrap;">T. estimado</label>
                    <input type="text" class="form-control input-sm" name="spent_hours" id="new_spent_hours" placeholder="00:00:00" style="text-align:center;"value=""/>
                  </div>
                </div>

                <div class="col-md-1">
                  <div class="form-group">
                    <label for="private" id="label_private" >Privado</label><br>
                    <input type="checkbox"  name="private" id="new_private" value=""/>
                  </div>
                </div>
      
                <div class="col-md-12" id="editor-descricao">
                  <div class="form-group">
                    <label for="new_description" id="label_description">Descrição</label>
                    <textarea class="form-control" id="new_description"></textarea>
                  </div>  
                </div>
              </div><!--row -->

              <div class="row">
                <div class="col-md-12">
                   <h4 class="h4">Outras Informações</h4>
                </div>
                <div class="col-md-12" id="outrasinfos"></div>
                </div>
                <div class="col-md-3">
                  <div class="form-group">
                    <label for="fileUploadNew">Upload</label>
                    <input class="form-control input-sm" multiple="multiple" type="file" name="fileUploadNew[]" id="fileUploadNew" />
                  </div>
                </div>

                <div class="col-md-2">
                  <div class="form-group">
                    <label for="new_watchers">Observadores</label>
                    {!! $watchers !!}
                  </div>
                </div>     
                <div class="col-md-12" style="text-align:center;">
                  <button type="button" class="btn btn-warning" id="btn_new_task">Criar Tarefa <span class="glyphicon glyphicon-send"></span></button>
                </div>
              </div><!-- row -->
            </form>
            <div id="message"></div>
          </div><!-- /.box-body -->
            
        </div> <!-- /.box-sucess -->   
    </div><!-- /.col-12 -->   
</div><!-- row -->
@stop
@section('js')
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.11/jquery.mask.min.js"></script>
<script>
//determinar situação de acordo com o tipo de chamado
$('#new_watcher').select2();
$(document).on('change','#new_tracker', function(e){
      var html_padrao = '<option id="void" value=""></option>';
      $('#void').append('Carregando...');             
      var tipo = $('#new_tracker').val();
      var project_id = $('#project_id').val();
      //validação
      if(project_id && tipo){
      $.ajax({
            url : "{{URL::to('/new_situacao')}}",
            data: '&tipo='+tipo+'&project_id='+project_id,
            type: 'post',
            dataType: 'json',
            success: function(data){
              var html;
              $('#new_status').empty();             
              $('#new_status').append(html_padrao);  
                for(var i in data){
                      var item = data[i];   
                      var html = '<option value="'+item.id+'" required>'+item.name+'</option>';           
                      $('#new_status').append(html);             
                  } 
              
            }
         });
      }
      else{
        $('#new_status').empty(); 
        $('#new_status').append(html_padrao);  
          

      }
      
});
//
$(document).on('change','#new_status', function(e){
      var tipo = $('#new_tracker').val();
      var project_id = $('#project_id').val();
      var status = $('#new_status').val();

      $('#label_description').find('span').remove();    
      $('#new_description').removeAttr('readonly').removeAttr('required');  
      $('#label_title').find('span').remove();  
      $('#new_title').removeAttr('readonly').removeAttr('required');       
      $('#label_spent').find('span').remove();   
      $('#new_spent_hours').removeAttr('readonly').removeAttr('required');     
      $('#label_due_date').find('span').remove();
      $('#new_due_date').removeAttr('readonly').removeAttr('required');               
      $('#label_created').find('span').remove(); 
      $('#new_created_on').removeAttr('readonly').removeAttr('required');                
      $('#label_pai').find('span').remove();   
      $('#new_tarefa_pai').removeAttr('readonly').removeAttr('required');                
      $('#label_category').find('span').remove();  
      $('#new_category').removeAttr('readonly').removeAttr('required');                   
      $('#label_private').find('span').remove(); 
      $('#new_private').removeAttr('readonly').removeAttr('required');                  
      $('#label_version').find('span').remove();  
      $('#new_version').removeAttr('readonly').removeAttr('required');    
      $('#label_assigned_to').find('span').remove(); 
      $('#new_assigned_to').removeAttr('readonly').removeAttr('required');
      $('#label_priority').find('span').remove(); 
      $('#new_priority').removeAttr('readonly').removeAttr('required');   
                         
      //validação
      if(project_id && tipo && status){
      $.ajax({
            url : "{{URL::to('/rules')}}",
            data: '&tipo='+tipo+'&project_id='+project_id+'&status='+status,
            type: 'post',
            dataType: 'json',
            success: function(data){
                camposCustomizados();
                var html = '<span class="text-red">*</span>';
                  for(var i in data){
                        var item = data[i];   

                      if(item.description == 'readonly'){
                        $('#new_description').attr('readonly','readonly');
                      }
                      else if(item.description == 'required'){
                        $('#label_description').append(html);
                        $('#new_description').attr('required','true');

                      }
                      //
                      if(item.title == 'readonly'){
                        $('#new_title').attr('readonly','readonly');
                      }
                      else if(item.title == 'required'){
                        $('#label_title').append(html);
                        $('#new_title').attr('required','true');

                      }
                      //
                      if(item.spent_hours == 'readonly'){
                        $('#new_spent_hours').attr('readonly','true');
                      }
                      else if(item.spent_hours == 'required'){
                        $('#label_spent').append(html);
                        $('#new_spent_hours').attr('required','true');

                      }
                      //
                      if(item.due_date == 'readonly'){
                        $('#new_due_date').attr('readonly','readonly');
                      }
                      else if(item.due_date == 'required'){
                        $('#label_due_date').append(html);
                        $('#new_due_date').attr('required','true');
                      }
                      //
                      if(item.created_on == 'readonly'){
                        $('#new_created_on').attr('readonly','readonly');
                        
                      }
                      else if(item.created_on == 'required'){
                        $('#label_created').append(html);
                        $('#new_created_on').attr('required','true');
                      }
                      //
                      if(item.tarefa_pai == 'readonly'){
                        $('#new_tarefa_pai').attr('readonly','readonly');
                      }
                      else if(item.tarefa_pai == 'required'){
                        $('#label_pai').append(html);
                        $('#new_tarefa_pai').attr('required','true');

                      }
                      //
                      if(item.version == 'readonly'){
                        $('#new_version').attr('readonly','readonly');
                      }
                      else if(item.version == 'required'){
                        $('#label_version').append(html);
                        $('#new_version').attr('required','true');
                      }
                      //
                      if(item.category == 'readonly'){
                        $('#new_category').attr('readonly','readonly');
                      }
                      else if(item.category == 'required'){
                        $('#label_category').append(html);
                        $('#new_category').attr('required','true');
                      }
                      //
                      if(item.private == 'readonly'){
                        $('#new_private').attr('readonly','readonly');
                      }
                      else if(item.private == 'required'){
                        $('#label_private').append(html);
                        $('#new_private').attr('required','true');
                      }
                      //
                      if(item.priority == 'readonly'){
                        $('#new_priority').attr('readonly','readonly');
                      }
                      else if(item.priority == 'required'){
                        $('#label_priority').append(html);
                        $('#new_priority').attr('required','true');
                      }
                      //
                      if(item.assigned_to == 'readonly'){
                        $('#new_transferir').attr('readonly','readonly');
                      }
                      else if(item.assigned_to == 'required'){
                        $('#label_assigned_to').append(html);
                        $('#new_transferir').attr('required','true');
                      }                  
                    } 
                  }
         });
      }
      
});
//função para os campos customizados
function camposCustomizados(){
      var tipo = $('#new_tracker').val();
      var project_id = $('#project_id').val();
      var status = $('#new_status').val();
      var data = '&tipo='+tipo+'&project_id='+project_id+'&status='+status;
      $.ajax({
        url : "{{URL::to('/newcustomfields')}}",
        data: data,
        type: 'post',
        dataType: 'html',
        async: false,
        success: function(data){
          $('#outrasinfos').html(data);
        },
              error: function(xhr, textStatus, errorThrown){
                Swal.fire({
                            title: 'Error!',
                            html: xhr.responseJSON.message,
                            icon: 'error',
                            confirmButtonText: 'OK'
                            });   
                  // $('#message').show().h('<div class="callout callout-danger"><h4>Status '+textStatus+'!</h4><p>'+xhr.responseJSON.message+'</p></div>').delay(1500).hide(6000);
              }
        
      });
    }
   
    

//markdown 

var new_description_mark = new SimpleMDE({ element: $("#new_description")[0],
    toolbar: ["bold", "italic", "heading", "|", "quote","unordered-list","ordered-list","link","image",	"preview"],spellChecker: false,forceSync : true ,forceSync : true ,});

//máscara
$("#new_spent_hours").mask("00:00");
   
</script>
@stop

