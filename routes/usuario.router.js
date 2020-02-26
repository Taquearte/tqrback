'use strict'

var express = require('express');
var router = express.Router();
var mk_auth=require('../middlewares/authenticate');


// Usuario
var usuarioCtrl = require('../controllers/usuario/usuario.controller');
router.get('/usuario/list', mk_auth.ensureAuth,usuarioCtrl.usuario_list);
module.exports = router;