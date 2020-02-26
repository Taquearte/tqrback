'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql')
var jwt=require('../../services/jwt');

//  Articulo Lista
async function articulo_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request() 
        .input('estatus', sql.VarChar(10), 'ALTA')  
        .query('Select * from Art where Estatus=@estatus ')    
        let mkArticulos= result.recordset;     
        res.status(200).json(mkArticulos);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}



module.exports={
    articulo_list
};