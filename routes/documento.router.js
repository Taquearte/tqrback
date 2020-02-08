var express = require('express');
var router = express.Router();
var multer = require("multer");
var path = require('path');
const crypto = require('crypto');
//const { poolPromise } = require('../database/conection');
var mk_auth=require('../middlewares/authenticate');



var documentoCtrl = require('../controllers/documento/documento.controller');
router.get( '/documento/list',mk_auth.ensureAuth,documentoCtrl.documentolist);

  
  
module.exports = router;