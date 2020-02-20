'use strict'

var express = require('express');
var router = express.Router();
var multer = require("multer");
var path = require('path');
const crypto = require('crypto');
var mk_auth=require('../middlewares/authenticate');


// adjunto
var adjuntoCtrl = require('../controllers/adjuntar/adjuntar.controller');
var storage_adjunto = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'cliente/assets/compra')
  },
  filename: (req, file, cb) => {
    cb(null, file.fieldname + '-' + Date.now()+ path.extname(file.originalname))
  }
});
var upload_adjunto = multer({storage: storage_adjunto});
router.post('/adjunto/new', upload_adjunto.single("file"),adjuntoCtrl.adjunto_new);
router.get('/adjunto/:id', mk_auth.ensureAuth,adjuntoCtrl.adjunto_list);

module.exports = router;