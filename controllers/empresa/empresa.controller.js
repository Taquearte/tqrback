'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql')
var jwt=require('../../services/jwt');

//  Empresa Lista
async function empresa_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()  
        .input('estatus', sql.VarChar(10), 'ALTA')  
        .query('Select * from Empresa where Estatus=@estatus ')   
        let mkempresa= result.recordset;     
        res.status(200).json(mkempresa);
      } catch (err) {
        console.log(err);
        res.status(500).json(err.message);
      }  
}


module.exports={
    empresa_list
};