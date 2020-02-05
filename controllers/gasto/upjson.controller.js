'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');
const convert = require('xml-js');
var libxmljs = require("libxmljs");
var format = require('xml-formatter');
const fs = require('fs');

async function upjson_new (req, res) {
	 try {
	    console.log('MKInfo:',JSON.stringify(req.body));
	    let data =JSON.stringify(req.body, null, 2); 
	   // let data = JSON.stringify(MK_Json, null, 2);
		// let MK_nombre= 'cliente/assets/JSON/MK_Webhook_' + Date.now() + Math.floor(Math.random()*101) +'.json';
		let MK_nombre= 'C:/PayKey/JSON/MK_Webhook_' + Date.now() + Math.floor(Math.random()*101) +'.json';
		

		fs.writeFile(MK_nombre, data, (err) => {
			if (err) throw err;
			console.log('Data written to file',MK_nombre);
		});  
	   
    } catch (err) {
      console.log(err.message);
      res.status(500).json(err.message);
    }   
}



module.exports={
    upjson_new
};