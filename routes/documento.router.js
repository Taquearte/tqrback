'use strict'

var express = require('express');
var router = express.Router();
var multer = require("multer");
var path = require('path');
const crypto = require('crypto');
var mk_auth=require('../middlewares/authenticate');



var documentoCtrl = require('../controllers/documento/documento.controller');
router.get('/documento/list'       ,mk_auth.ensureAuth,documentoCtrl.documentolist);
router.get('/documento/one/:id'    ,mk_auth.ensureAuth,documentoCtrl.documentocab,documentoCtrl.documentodet);
router.get('/documento/afectar/:id',mk_auth.ensureAuth,documentoCtrl.documentoafectar);

  
  
module.exports = router;