const app = require('express')();
const http = require('http').createServer(app);
const port = 3000;

const bodyParser = require('body-parser');

const io = require('socket.io')(http);
const mysql = require('mysql');

/*
conexão com o MySql
*/
const conn = mysql.createConnection({
  host     : 'localhost',
  port     : 3306,
  user     : 'smartadmin',
  password : 'smartadmin',
  database : 'smartadmin'
});

const notificationsSql = 'SELECT read_at, DATE_FORMAT(created_at,"%d/%m/%Y %H:%i:%s") created_at, updated_at, JSON_UNQUOTE(data->"$.tipo") tipo, JSON_UNQUOTE(data->"$.title") title, JSON_UNQUOTE(data->"$.message") message, JSON_UNQUOTE(data->"$.user.id") idusuario, JSON_UNQUOTE(data->"$.user.name") name, JSON_UNQUOTE(data->"$.user.email") email, JSON_UNQUOTE(data->"$.user.perfil") perfil, JSON_UNQUOTE(data->"$.cliente.id") idcliente, JSON_UNQUOTE(data->"$.cliente.nomecliente") cliente, JSON_UNQUOTE(data->"$.instancia.id") idinstancia,    JSON_UNQUOTE(data->"$.instancia.urlinstancia") instancia, JSON_UNQUOTE(data->"$.instancia.tipoinstancia") tipoinstancia FROM notifications ';
conn.connect(function(err){
  if(err) return console.log(err);
  //console.log('conectou!');
});

function execSQLQuery(conn, sql, res){
  conn.query(sql, function(error, results, fields){
    if(error){
      res.json(error);
    }else{
      res.json(results);
    }
    //conn.end();
  });
}

/*
body parser para os comandos POST
*/
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

/*
configurando as Rotas no express
*/
app.get('/', function(req, res){
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.json({
    'message' : 'Funcionando.'
  });
});
app.get('/notifications/:userid?', function(req, res){
  res.setHeader("Access-Control-Allow-Origin", "*");
  let filter = '';
  if(req.params.userid)
    filter = ' WHERE JSON_UNQUOTE(data->"$.user.id") = ' + parseInt(req.params.userid);
  let sql = notificationsSql + filter + ' ORDER BY created_at';
  execSQLQuery(conn, sql, res);
});

app.get('/unreadnotifications/:userid?', function(req, res){
  res.setHeader("Access-Control-Allow-Origin", "*");
  let filter = '';
  if(req.params.userid)
    filter = ' WHERE read_at IS NULL AND JSON_UNQUOTE(data->"$.user.id") = ' + parseInt(req.params.userid)
  let sql = notificationsSql + filter + ' ORDER BY created_at';
  execSQLQuery(conn, sql, res);
});

/*
io connection
*/
io.set('origins', '*:*');
io.on('connection', function(socket){
  //console.log('connection ',socket.id);
  socket.on('msg', function(msg){
    console.log(msg);
  })
});

/*
iniciando o Export na Porta 3000
*/
http.listen(port);
console.log('Servidor funcionando');
