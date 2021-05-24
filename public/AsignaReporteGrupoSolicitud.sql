DECLARE
  l_program_short_name  VARCHAR2 (200);
  l_program_application VARCHAR2 (200);
  l_request_group       VARCHAR2 (200);
  l_group_application   VARCHAR2 (200);
  l_check               VARCHAR2 (2);
  --
BEGIN
  --

  l_program_short_name  := 'XXANDROIDSYNC';
  l_program_application := 'Business Online';
  l_request_group       := 'XX TCG Programador';
  l_group_application   := 'Process Manufacturing Systems';

  IF NOT fnd_program.program_in_group 
       (program_short_name  => l_program_short_name 
       ,program_application => l_program_application 
       ,request_group       => l_request_group 
         ,group_application   => l_group_application) 
   THEN 
           apps.fnd_program.add_to_group (program_short_name  => l_program_short_name,
                                  program_application => l_program_application,
                                  request_group       => l_request_group,
                                  group_application   => l_group_application                            
                                 );  
    END IF;



COMMIT;
END;