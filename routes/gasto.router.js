var express = require('express');
var router = express.Router();
var multer = require("multer");
var path = require('path');
const crypto = require('crypto');
const { poolPromise } = require('../database/conection');
//servicio jwt
var mk_auth=require('../middlewares/authenticate');





/* GET TESTING
router.get('/gastolst', async (req, res ) => {
  try {
    const pool = await poolPromise
    const result = await pool.request()        
        .query('select * from Color')      
    res.json(result.recordset)
  } catch (err) {
    res.status(500)
    res.send(err.message)
  }
});
*/

//UpJSON
var storage_upJSON = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'cliente/assets/JSON')
  },
  filename: (req, file, cb) => {
    cb(null, file.fieldname + '-' + Date.now() + Math.floor(Math.random()*101) + path.extname(file.originalname))
  }
});
var upload_upJSON = multer({storage: storage_upJSON}).array('files',100);
var upjsonCtrl = require('../controllers/gasto/upjson.controller');
router.post( '/upjson/new',upload_upJSON,upjsonCtrl.upjson_new);

//UpXML
var storage_upXML = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'cliente/assets/xml')
  },
  filename: (req, file, cb) => {
    cb(null, file.fieldname + '-' + Date.now() + Math.floor(Math.random()*101) + path.extname(file.originalname))
  }
});
var upload_upXML = multer({storage: storage_upXML}).array('files',100);
var upxmlCtrl = require('../controllers/gasto/upxml.controller');
//router.post( '/upxml/new',upload_upXML,upxmlCtrl.upxml_addRFC_Nom,upxmlCtrl.upxml_RFC_Receptor,upxmlCtrl.upxml_new);
  router.post( '/upxml/new',upload_upXML,upxmlCtrl.upxml_RFC_Receptor,upxmlCtrl.upxml_new);
router.get('/upxml/list',mk_auth.ensureAuth,upxmlCtrl.upxml_list);
router.get('/upxml/list10',mk_auth.ensureAuth,upxmlCtrl.upxml_list10);
router.get('/upxmlcab/:id',mk_auth.ensureAuth,upxmlCtrl.upxml_listcabecero);
router.get('/upxmlsp/:id',mk_auth.ensureAuth,upxmlCtrl.upxml_spafecta);
router.get('/upxmlsparchivar/:id',mk_auth.ensureAuth,upxmlCtrl.upxml_sparchivar);
router.get('/upxmldel/:id',mk_auth.ensureAuth,upxmlCtrl.upxml_del_one_xml);
router.get('/upxmluno/:id',mk_auth.ensureAuth,upxmlCtrl.upxml_uno);
router.get('/upxmlconsecutivo',mk_auth.ensureAuth,upxmlCtrl.upxml_consecutivo);


//MAPEO
var mapeoCtrl = require('../controllers/gasto/mapeo.controller');
router.get( '/mapeo/list',mk_auth.ensureAuth,mapeoCtrl.mapeo_list );
router.get( '/mapeo/edit/:id',mk_auth.ensureAuth,mapeoCtrl.mapeo_list );
router.get( '/mapeo/:id',mk_auth.ensureAuth,mapeoCtrl.mapeo_uno );
router.put( '/mapeo/:id',mk_auth.ensureAuth,mapeoCtrl.mapeo_edit );

//CONCEPTO
var conceptoCtrl = require('../controllers/gasto/concepto.controller');
router.get( '/concepto/list',mk_auth.ensureAuth,conceptoCtrl.concepto_list );
router.get( '/conceptocla/list',mk_auth.ensureAuth,conceptoCtrl.conceptocla_list );
router.get( '/conceptosub/list',mk_auth.ensureAuth,conceptoCtrl.conceptosub_list );
//formapago
var formapagoCtrl = require('../controllers/gasto/formapago.controller');
router.get( '/formapago/list',mk_auth.ensureAuth,formapagoCtrl.formapago_list);
//acreedor
var acreedorCtrl = require('../controllers/gasto/acreedor.controller');
router.get( '/acreedor/list',mk_auth.ensureAuth,acreedorCtrl.acreedor_list);
//prov
var provCtrl = require('../controllers/gasto/prov.controller');
router.get( '/prov/list',mk_auth.ensureAuth,provCtrl.prov_list);
//proy
var proyCtrl = require('../controllers/gasto/proy.controller');
router.get( '/proy/list',mk_auth.ensureAuth,proyCtrl.proy_list);
router.get( '/proy/list',mk_auth.ensureAuth,proyCtrl.proy_list);
//mov
var movCtrl = require('../controllers/gasto/mov.controller');
router.get( '/mov/list',mk_auth.ensureAuth,movCtrl.mov_list);
//mov
var condicionCtrl = require('../controllers/gasto/condicion.controller');
router.get( '/condicion/list',mk_auth.ensureAuth,condicionCtrl.condicion_list)



//GASTO
var gastoCtrl = require('../controllers/gasto/gasto.controller');
router.get( '/gasto/list/:id',mk_auth.ensureAuth,gastoCtrl.gasto_list);
router.get( '/gasto/list9/:id',mk_auth.ensureAuth,gastoCtrl.gasto_list9);
router.post( '/gasto/new',mk_auth.ensureAuth,gastoCtrl.gasto_new);
router.post( '/gasto/afectar',mk_auth.ensureAuth,gastoCtrl.gasto_afectar);
router.get( '/gasto/one/:id',mk_auth.ensureAuth,gastoCtrl.gasto_uno);
router.get( '/gasto/onedet/:id',mk_auth.ensureAuth,gastoCtrl.gasto_unodet);
//LOGIN
var loginCtrl = require('../controllers/login/login.controller');
router.post('/login',loginCtrl.login);
router.get( '/empresa',loginCtrl.empresa_list);
router.get( '/sucursal',loginCtrl.sucursal_list);


// PERFIL
var perfilCtrl = require('../controllers/login/perfil.controller');
var storage_perfil = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'cliente/assets/img/users')
  },
  filename: (req, file, cb) => {
    cb(null, file.fieldname + '-' + Date.now()+ path.extname(file.originalname))
  }
});
var upload_perfil = multer({storage: storage_perfil});
router.post('/perfil/new', upload_perfil.single("file"),perfilCtrl.perfil_new);
router.get('/perfil/:id', perfilCtrl.perfil_list);



/* GET TESTING*/
router.get('/gasto', function(req, res, next) {
    res.send('MKSD-BACK PORTAL DE GASTO');
  });
  
  
  module.exports = router;