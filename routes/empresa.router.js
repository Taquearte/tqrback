'use strict'

var express = require('express');
var router = express.Router();
var mk_auth=require('../middlewares/authenticate');


// Empresa
var empresaCtrl = require('../controllers/empresa/empresa.controller');
router.get('/mkempresa/list', mk_auth.ensureAuth,empresaCtrl.empresa_list);
module.exports = router;