'use strict'

const { poolPromise } = require('../../database/conection');
const sql = require('mssql');


async function documentolist (req, res) {
    console.log(req.query); 

  try {
      const pool = await poolPromise
      const result = await pool.request()  
          .input('usuario', sql.VarChar(10), req.query.usuario)    
          .input('empresa', sql.VarChar(10), req.query.empresa)    
          .input('sucursal', sql.VarChar(10), req.query.sucursal)    
          .input('modulo', sql.VarChar(10), req.query.modulo)  
          .input('perfil', sql.VarChar(10), req.query.perfil)   
          .query('Exec mksp_GetMovlist @Usuario, @empresa, @sucursal, @modulo')
      //console.log(result);
      let mkdocumento= result.recordset;     
      res.status(200).json(mkdocumento);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

async function documentocab (req, res) {
    console.log(req.id);
    console.log(req.body);
  try {
      const pool = await poolPromise
      const result = await pool.request()  
          .input('id', sql.VarChar(10), req.id)  
          .input('usuario', sql.VarChar(10), req.body.Usuario)    
          .input('empresa', sql.VarChar(10), req.body.Empresa)    
          .input('sucursal', sql.VarChar(10), req.body.Sucursal)  
          .input('cabecero', sql.VarChar(10), '1')      
          .input('modulo', sql.VarChar(10), req.body.Modulo)   
          .query('Exec mksp_GetMov @Usuario, @empresa, @sucursal, @modulo')
      console.log(result);
      let mkdocumentocab= result.recordset;     
      res.status(200).json(mkdocumentocab);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

async function documentodet (req, res) {
    console.log(req.id);
    console.log(req.body);
  try {
      const pool = await poolPromise
      const result = await pool.request()  
          .input('id', sql.VarChar(10), req.id)  
          .input('usuario', sql.VarChar(10), req.body.Usuario)    
          .input('empresa', sql.VarChar(10), req.body.Empresa)    
          .input('sucursal', sql.VarChar(10), req.body.Sucursal)  
          .input('cabecero', sql.VarChar(10), '0')      
          .input('modulo', sql.VarChar(10), req.body.Modulo)   
          .query('Exec mksp_GetMov @Usuario, @empresa, @sucursal, @modulo')
      console.log(result);
      let mkdocumentodet= result.recordset;     
      res.status(200).json(mkdocumentodet);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}


module.exports={
    documentolist,    
    documentocab,
    documentodet
};