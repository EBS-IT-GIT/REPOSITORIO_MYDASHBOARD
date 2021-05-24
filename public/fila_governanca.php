<?php
##########################

	// Dados da tabela
		$tabela = "hd_chamado";    #Nome da tabela
		$campo1 = "cdchamado";  #Nome do campo da tabela
		$campo2 = "dschamado";  #Nome de outro campo da tabela
		$campo3 = "dtchamado";  #Nome de outro campo da tabela
		$campoindex = "dtnumber";  #Nome de outro campo da tabela
		$campo4 = "sistema";
		$campo5 = "prioridade";
		$campo6 = "cliente";
		$campo7 = "situacao";
		$campo8 = "equipe";
		$campo9 = "cresponsavel";
		$campo10 = "csituacao";
		$campo11 = "cqtd";
		$campo12 = "dtprevisao";
		$campo13 = "fila";

#################### CHAMADOS REDMINE ###############################################

		//conectando no banco mysql do redmine

		#$SERVIDOR="servicedesk.ebsdba.local";
		$SERVIDOR="localhost";
		$DATABASE="redmine";
		$USUARIO="monitorafila";
		$PASSWORD="filadechamados";

		if(!($CONNECT = mysqli_connect($SERVIDOR,$USUARIO,$PASSWORD)))
		{
		   echo "CRITICAL - NAO FOI POSSIVEL CONECTAR CO SERVIDOR DE BANCO DE DADOS.";
		   exit;
		}
		if(!($con=mysqli_select_db($CONNECT,$DATABASE))) {
		   echo "CRITICAL - NAO FOI POSSIVEL CONECTAR COM A BASE DE DADOS";
		   exit;
		}
		
		$instrucaoSQL = "select concat('a4',a.due_date) $campoindex,
               if(a.status_id in (10,13),a.updated_on,a.created_on) $campo3, 
				a.id $campo1, subject $campo2, left(b.name,4) $campo6, 
				if (DATE(a.start_date) > CURDATE(),6,case a.priority_id
				when 5 then 1
                when 4 then 2
                when 3 then 3
                when 2 then 4
                else 5 end) $campo5, 'SD' $campo4, s.name $campo7, ifnull(concat(u.firstname,' ',u.lastname),'SEM EQUIPE') $campo8, a.due_date $campo12,
				(select value from custom_values where customized_id = a.id and custom_field_id = 24 order by id desc limit 1) $campo13
        from issues a 
        LEFT JOIN issue_slas isla ON a.project_id = isla.project_id and a.priority_id = isla.priority_id
        INNER JOIN projects b ON a.project_id = b.id                        
		   inner join issue_statuses s on a.status_id = s.id
	           inner join users u on a.assigned_to_id = u.id
		where  a.status_id not in (select id from issue_statuses where is_closed = true or id = 3)  
		and b.name like '%Suporte e Monitoramento%'
		and u.id = 635
		order by dtnumber asc;
		";

		$consulta = mysqli_query($CONNECT, $instrucaoSQL);
		$numRegistros = mysqli_num_rows($consulta);
		if ($numRegistros!=0) {
				while ($cadaLinha = mysqli_fetch_array($consulta)) {
				$chamados[] = $cadaLinha;
			}
		}

		//definindo o conteudo do xml do grafico

######################### FIM CHAMADOS REDMINE #######################################
		
?>
<!DOCTYPE html>
<html>
<meta http-equiv="refresh" content="20" >
<head>
<title>EBS IT - Fila Governanca</title>
<td><font size="15" ><strong>Fila de Chamados Governanca</strong></font></td>
<tr>
<?php 
echo "<tr><td><strong>Total de chamados em fila --> ".count($chamados)."</strong></td></tr>";
?>
</tr>
</head>
<body>
<table>
<tr><td valign=top>
<table border="1">
<thead>
<font><strong>
<td>Pri</td>
<td>Dt Solicitacao</td>
<td>Numero</td>
<td>Descricao</td>
<td>Sistema</td>
<td>Cliente</td>
<td>Situacao</td>
<td>DT Previsao</td>
<td>Equipe</td>
<td>Fila</td></tr>
</font></strong>
</thead>
<?php header('Content-Type: text/html; charset=ISO-8859-1');
#array_multisort($chamados[0], SORT_ASC, SORT_STRING);
#arsort($chamados);
function cmp($a, $b)
{
    return strcmp($a["dtnumber"], $b["dtnumber"]);
}
usort($chamados, "cmp");
foreach($chamados as $chamado)

{
if(trim($chamado[$campo8]) == 'EBS-IT - Governança')
	{	
		echo "<tr bgcolor='#FFFFFF'>";
	}else{
		echo "<tr>";
	}	
echo "<td>";
echo $chamado[$campo5];
echo "</td>";
echo "<td>";
echo $chamado[$campo3];
echo "</td>";
echo "<td>";
echo "<a onclick='window.open(this.href); return false;' href='https://servicedesk.ebs-it.services/issues/$chamado[$campo1]'>" .$chamado[$campo1]. "</a>";
echo "</td>";
echo "<td>";
echo $chamado[$campo2];
echo "</td>";
echo "<td>";
echo $chamado[$campo4];
echo "</td>";
echo "<td>";
echo $chamado[$campo6];
echo "</td>";
echo "<td>";
echo $chamado[$campo7];
echo "</td>";
echo "<td>";
echo $chamado[$campo12];
echo "</td>";
echo "<td>";
echo $chamado[$campo8];
echo "</td>";
echo "<td>";
echo $chamado[$campo13];
echo "</td>";
echo "</tr>";
}
?>
</table></td>
<td valign=top>
<?php

		$instrucaoSQL = "select concat(u.firstname,' ',u.lastname) $campo9
							from groups_users gu
							inner join users u on gu.user_id = u.id 
							where gu.group_id = 635
							order by cresponsavel;";
		
		$consultacon = mysqli_query($CONNECT,$instrucaoSQL);
		$numRegistroscon = mysqli_num_rows($consultacon);
		if ($numRegistroscon!=0) {
				while ($cadaLinhacon = mysqli_fetch_array($consultacon)) {
				$responsaveiscon[] = $cadaLinhacon;
			}
		}
		$instrucaoSQL = "select concat(u.firstname,' ',u.lastname) $campo9,
				if((select value from custom_values where custom_field_id = 14 and customized_id = a.project_id) = 'Suporte e Monitoramento', s.name, 'Projeto') $campo7, 
				count(a.id) $campo11
				from issues a inner join users u on a.assigned_to_id = u.id 
				inner join issue_statuses s on a.status_id = s.id
				where  a.status_id not in (select id from issue_statuses where is_closed = true or id = 3)  
				and  u.id in (select user_id from groups_users where group_id = 408) 
				group by cresponsavel, situacao
				order by cresponsavel, field(situacao,'New','In progress','Paused','Feedback','Projeto');";
		
		$consultacon = mysqli_query($CONNECT,$instrucaoSQL);
		$numRegistroscon = mysqli_num_rows($consultacon);
		if ($numRegistroscon!=0) {
				while ($cadaLinhacon = mysqli_fetch_array($consultacon)) {
				$chresponsaveiscon[] = $cadaLinhacon;
			}
		}
?>
<table border="1">
<thead>
<font><strong>
<td>Responsavel</td>
<td>New</td>
<td>In Progress</td>
<td>Paused</td>
<td>Feedback</td>
<td>Projeto</td>
</font></strong>
</thead>
<?php 


foreach($responsaveiscon as $responsavel)
{
echo "<tr><td>";
echo $responsavel[$campo9];
echo "</td>";

$cont = 0;

foreach($chresponsaveiscon as $chresponsavel)
{	
if ( $responsavel[$campo9] == $chresponsavel[$campo9])
{

if(trim($chresponsavel[$campo7]) == 'New')
	{	
		echo "<td bgcolor='#ffb3b3'>";
		echo $chresponsavel[$campo11];
		echo "</td>";
		$cont = $cont + 1; 
		goto e;
	}else{
		if($cont == 0){
			echo "<td> 0 </td>";
			$cont = $cont + 1;
		}		
		if(trim($chresponsavel[$campo7]) == 'In Progress')
		{	
			if (intval($chresponsavel[$campo11])> 3)
			{
				echo "<td bgcolor='#ffb3b3'>";
			}else
			{
				echo "<td>";
			}	
			echo $chresponsavel[$campo11];
			echo "</td>";
			$cont = $cont + 1;
			goto e;
		}else{
			if($cont == 1){
			echo "<td> 0 </td>";
			$cont = $cont + 1;
			}	
			if(trim($chresponsavel[$campo7]) == 'Paused')
			{	
				echo "<td>";
				echo $chresponsavel[$campo11];
				echo "</td>";
				$cont = $cont + 1;
				goto e;
			}else{
				if($cont == 2){
				echo "<td> 0 </td>";
				$cont = $cont + 1;
				}
				if(trim($chresponsavel[$campo7]) == 'Feedback')
				{	
					echo "<td>";
					echo $chresponsavel[$campo11];
					echo "</td>";
					$cont = $cont + 1;
					goto e;
				}else{
				if($cont == 3){
				echo "<td> 0 </td>";
				$cont = $cont + 1;
				}
					if(trim($chresponsavel[$campo7]) == 'Projeto')
					{	
						echo "<td>";
						echo $chresponsavel[$campo11];
						echo "</td>";
						$cont = $cont + 1;
					}else{
						echo "<td> 0 </td>";
						break;
					}	
					
				}	
				
			}	
			
		}	
		
	}	
e:
next;	
}
}
while($cont<=4)
{
echo "<td> 0 </td>";
$cont = $cont + 1;	
}
echo "</tr>";
}
?>
</table>
</td></tr>
</table>
</body>
</html>
