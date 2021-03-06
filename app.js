var createError = require('http-errors');
var express = require('express');
var cors = require('cors')
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var bodyParser = require('body-parser');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var gastoRouter = require('./routes/gasto.router');
var documentoRouter = require('./routes/documento.router');
var adjuntoRouter = require('./routes/adjunto.router');

var empresaRouter = require('./routes/empresa.router');
var sucursalRouter = require('./routes/sucursal.router');
var usuarioRouter = require('./routes//usuario.router');
var articuloRouter = require('./routes/articulo.router');

var app = express();
app.use(cors());

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);

app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());

const mkappuse='/bkd';
app.use('/',express.static('cliente',{redirect:false}));

app.use(mkappuse,gastoRouter);
app.use(mkappuse,documentoRouter);
app.use(mkappuse,adjuntoRouter);
app.use(mkappuse,empresaRouter);
app.use(mkappuse,sucursalRouter);
app.use(mkappuse,articuloRouter);
app.use(mkappuse,usuarioRouter);

app.get('*',function(req,res,next){
  res.sendFile(path.resolve('cliente/index.html')); //estas
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
