/*-------------------------------------------------------------------------------- -------------
-- Entregavel neste script
    • 1 (um) Script para excluir os documentos com título repetido e arquivos do tipo PDF.
 ----------------------------------------------------------------------------------------------*/
set serveroutput  on size 100000
declare
  --  
  cursor cur_document is
    select     r.cddocument
              ,r.cdrevision	
              ,r.cdcomplexfilecont
              ,g.cdfile
			  ,t.identificador 
    from       temptb_documentos t
    inner join saepsfx.dcdocrevision r on r.iddocument = t.identificador 
    inner join saepsfx.gnfile    g on g.cdcomplexfilecont = r.cdcomplexfilecont
    inner join saepsfx.dccategory c on c.cdcategory = r.cdcategory and c.idcategory = t.idcategoria 
    where      tipoacao = 'Excluir';
  --
  reg_document cur_document%rowtype;  
  --
  l_tabela varchar2(50);  
  --
  l_erro varchar2(1); 
  l_msg  varchar2(4000); 
  --
  erro exception;
  --
  wretorno varchar2(4000); 
begin
  /*
  -- Busca documentos para exclusao
  */
  open cur_document;
  --
  loop
    fetch cur_document 
    into  reg_document;
    exit when cur_document%notfound;
    --
    BEGIN
 			begin
				l_erro:= 'N';
				l_tabela:= 'GNFILE';	
				delete saepsfx.gnfile 
					where  cdfile = reg_document.cdfile;
			exception
				when others then
					l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';   			
			end;
      --
			if  l_erro = 'S'
			then
			   rollback;
				 dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cdfile);
				exception
					when others then
						l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
								dbms_output.put_line(l_msg);
						end;				
					end loop;
				end;
			end if;
      --
  
		  begin
				l_erro:= 'N';
				l_tabela:= 'DCDOCUMENTUSER';	
				delete saepsfx.dcdocumentuser
				where  cddocument = reg_document.cddocument
				and    cdrevision = reg_document.cdrevision;      
			exception
				when others then
					l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;
      --      
 			if  l_erro = 'S'
			then
			   rollback;
				dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cddocument);
					 exception
						when others then
							l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
						  dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
								dbms_output.put_line(l_msg);
						end;					
					end loop;
				end;
			end if;
      --   
			begin
				l_erro:= 'N';
				l_tabela:= 'DCDOCACCESSROLE';	
				delete saepsfx.DCDOCACCESSROLE
				where  cddocument = reg_document.cddocument;	
			exception
				when others then
					l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;
			if  l_erro = 'S'
			then
			   rollback;
				 dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cddocument);
					 exception
						when others then
							l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);

						exception
							when others then
								dbms_output.put_line(l_msg);
						end;					
					end loop;
				end;
			end if; 
     --
			begin
				l_erro:= 'N';
				l_tabela:= 'DCDOCUMENTARCHIVAL';	
				delete saepsfx.DCDOCUMENTARCHIVAL 
				where  cddocument = reg_document.cddocument
				and    nvl(cdrevision,reg_document.cdrevision) = reg_document.cdrevision;
			exception
				when others then
					l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;     
			--
			if  l_erro = 'S'
			then
			   rollback;
				dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cddocument);
					 exception
						when others then
							l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
								dbms_output.put_line(l_msg);
						end;				
					end loop;
				end;
			end if; 
      --     
			begin
				l_erro:= 'N';
				l_tabela:= 'DCDOCREVISION';	
				delete saepsfx.dcdocrevision 
				where  cddocument = reg_document.cddocument
				and    cdrevision = reg_document.cdrevision;
			exception
				when others then
					l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;     
			--
			if  l_erro = 'S'
			then
			  rollback;
				dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cddocument);
					 exception
						when others then
								l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
								dbms_output.put_line(l_msg);
						end;				
					end loop;
				end;
			end if; 
      --     
		begin
				l_erro:= 'N';
				l_tabela:= 'DCDOCUMENT';	
  			delete saepsfx.dcdocument 
				where  cddocument = reg_document.cddocument;
			exception
				when others then
				    l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;
			--
			if  l_erro = 'S'
			then
			  rollback;
				dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cddocument);
					 exception
						when others then
							l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
									dbms_output.put_line(l_msg);
						end;					
					end loop;
				end;
			end if;
      --      
      			begin
				l_erro:= 'N';
				l_tabela:= 'GNREVUPDATE';
				delete saepsfx.gnrevupdate 
				where cdrevision = reg_document.cdrevision;
        -- 
			exception
				when others then
					 l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;
      --
			if  l_erro = 'S'
			then
			  rollback;
				 dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cdrevision);
				exception
						when others then
							l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
								dbms_output.put_line(l_msg);
						end;				
					end loop;
			  end;
			end if;
   --           
		begin
				l_erro:= 'N';
				l_tabela:= 'GNREVISION';
				delete saepsfx.gnrevision 
				where cdrevision = reg_document.cdrevision;
        -- 
			exception
				when others then
					 l_msg := 'Erro delete ' || l_tabela || ' ID: ' || reg_document.identificador || ' ' || sqlerrm;
					l_erro:= 'S';       
			end;
      --
			if  l_erro = 'S'
			then
			  rollback;
				 dbms_output.put_line(l_msg);
				--Executa a procedure
				begin 
					 saepsfx.sep_related_table_record(l_tabela,reg_document.cdrevision);
				exception
						when others then
							l_msg := l_msg|| ' Erro execute procedure' || sqlerrm;
				end;	    
				--Lista o resultado
				begin
					for r in (select * from saepsfx.related_table_record)
					loop
						begin
							dbms_output.put_line(l_msg || '   '|| r.tab_name);
						exception
							when others then
								dbms_output.put_line(l_msg);
						end;				
					end loop;
			  end;
			end if;
                 
            commit;
			exception
				when others then
					wretorno := substr('Erro loop documento:  - '||sqlerrm,1,255);
					dbms_output.put_line(wretorno);
					rollback;
			end;
			--
  end loop;
  --
  close cur_document;  
  commit;
  --   
  exception
    when erro then
      wretorno :=  substr(nvl(wretorno,'ERRO GERAL. ')||sqlerrm,1,255);
      rollback;
    when others then
      wretorno :=  substr(nvl(wretorno,'ERRO GERAL. ')||sqlerrm,1,255);
       dbms_output.put_line(wretorno);
       rollback;
end;
/