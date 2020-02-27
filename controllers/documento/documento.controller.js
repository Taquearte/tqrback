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
    console.log(req.query);
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
      console.log(mkdocumentocab);
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


async function documentoafectar (req, res ) {
  try {
       //console.log(req.params);
       //console.log(req.query);
        const pool = await poolPromise
        const result = await pool.request()  
        .input('mkid', sql.VarChar(15), req.params.id) 
        .input('usuario', sql.VarChar(15), req.query.usuario)    
        .input('modulo', sql.VarChar(20), req.query.modulo)  
        .input('accion', sql.VarChar(20), 'AFECTAR') 
        .input('mov', sql.VarChar(50), 'Orden Compra') 
        .query('Exec mksp_Afectar2 @mkid, @usuario, @modulo, @accion, @mov')
       // console.log('MK',result);
      let mkafectar= result.recordset[0];  
      res.status(200).json(mkafectar);        
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

/* async function documentoafectar (req, res) {
  // let mkid=req.params.id
   //req.body
   console.log(req.body);
 //var mkempresa=req.params.id;
   try {
       const pool = await poolPromise
       const result = await pool.request()  
       .input('mkid', sql.VarChar(100), req.body.id) 
       .input('usuario', sql.VarChar(10), req.body.usuario)    
       .input('modulo', sql.VarChar(10), 'COMS')  
       .input('accion', sql.VarChar(10), 'Afectar') 
       .input('mov', sql.VarChar(10), 'Orden Compra') 
       .query('Exec mksp_Afectar @mkid, @usuario, @modulo,@accion,@mov')
       console.log(result);
       let mkgasto= result.recordset;     
       res.status(200).json(mkgasto);
     } catch (err) {
       console.log(err.message);
       res.status(500).json(err.message);
     }  
 } */



module.exports={
    documentolist,    
    documentocab,
    documentodet,
    documentoafectar
};