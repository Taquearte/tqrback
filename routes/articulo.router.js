'use strict'

var express = require('express');
var router = express.Router();
var mk_auth=require('../middlewares/authenticate');


// Empresa
var articuloCtrl = require('../controllers/articulo/articulo.controller');
router.get('/articulo/list', mk_auth.ensureAuth,articuloCtrl.articulo_list);

module.exports = router;