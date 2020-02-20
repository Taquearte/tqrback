'use strict'

const { poolPromise } = require('../../database/conection');
const sql = require('mssql');


async function documentolist (req, res) {
    //console.log(req.query); 

  try {
      const pool = await poolPromise
      const result = await pool.request()  
          .input('usuario', sql.VarChar(10), req.query.usuario)    
          .input('empresa', sql.VarChar(10), req.query.empresa)    
          .input('sucursal', sql.VarChar(10), req.query.sucursal)    
          .input('modulo', sql.VarChar(10), req.query.modulo)  
          .input('perfil', sql.VarChar(10), req.query.perfil)   
          .query('Exec mksp_GetMovlist @usuario, @empresa, @sucursal, @modulo, @perfil')
      //console.log(result);
      let mkdocumento= result.recordset;     
      res.status(200).json(mkdocumento);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}



async function documentocab (req, res, next ) {
  try {
      const pool = await poolPromise
      const result = await pool.request()  
        .input('id', sql.VarChar(10), req.params.id)  
        .input('usuario', sql.VarChar(10), req.query.usuario)    
        .input('empresa', sql.VarChar(10), req.query.empresa)    
        .input('sucursal', sql.VarChar(10), req.query.sucursal)  
        .input('cabecero', sql.VarChar(10), '1')      
        .input('modulo', sql.VarChar(10), req.query.modulo)   
        .input('perfil', sql.VarChar(10), req.query.perfil)  
        .query('Exec mksp_GetMov @id,@usuario, @empresa, @sucursal,@cabecero, @modulo, @perfil')
     
      let mkdocumentocab= result.recordset[0]; 
      req.documento = mkdocumentocab;
      next();     
      
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

async function documentodet (req, res) {    
  try {
      const pool = await poolPromise
      const result = await pool.request()  
        .input('id', sql.VarChar(10), req.params.id)  
        .input('usuario', sql.VarChar(10), req.query.usuario)    
        .input('empresa', sql.VarChar(10), req.query.empresa)    
        .input('sucursal', sql.VarChar(10), req.query.sucursal)  
        .input('cabecero', sql.VarChar(10), '0')      
        .input('modulo', sql.VarChar(10), req.query.modulo)   
        .input('perfil', sql.VarChar(10), req.query.perfil)  
        .query('Exec mksp_GetMov @id,@usuario, @empresa, @sucursal,@cabecero, @modulo, @perfil')

      let mkdocumentodet= result.recordset;  
      req.documento.detalle= mkdocumentodet;
     // console.log(req.documento);  
      res.status(200).json(req.documento);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}


module.exports={
    documentolist,    
    documentocab,
    documentodet
};