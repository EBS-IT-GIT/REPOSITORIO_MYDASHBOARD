<?php
$username = 'ronney.dutra';
$password = '12345678';

$ch = curl_init();
curl_setopt($ch, CURLOPT_USERPWD, "$username:$password");
curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
curl_setopt_array($ch, array(
  CURLOPT_URL => "http://192.168.107.30/time_entrie.xml",
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => "",
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 30,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => "GET"
));

$xml = '<?xml version="1.0"?><time_entry>
    <project_id>153</project_id>
    <issue_id>27041</issue_id>
    <user_id>464</user_id>
    <activity_id>9</activity_id>
    <hours>1.0</hours>
    <comments>time entry comment</comments>
    <spent_on>2018-07-21</spent_on>
    <custom_fields type=\"array\">
        <custom_field internal_name=\"Hora Entrada Trabalho\">
            <value>00:00</value>
        </custom_field>
        <custom_field internal_name=\"Hora Saída Trabalho\">
            <value>00:00</value>
        </custom_field>
        <custom_field internal_name=\"Atividades\">
            <value>00:00</value>
        </custom_field>
    </custom_fields>
</time_entry>';
curl_setopt($ch, CURLOPT_POSTFIELDS,$xml);

curl_setopt($ch, CURLOPT_HTTPHEADER, array(
  "Content-Type: application/xml"
));

$response = curl_exec($ch);
curl_close($ch);

var_dump($response);

?>
