'use strict'

var express = require('express');
var router = express.Router();
var mk_auth=require('../middlewares/authenticate');


// Sucursal
var sucursalCtrl = require('../controllers/sucursal/sucursal.controller');
router.get('/mksucursal/list', mk_auth.ensureAuth,sucursalCtrl.sucursal_list);
module.exports = router;