'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql')
var jwt=require('../../services/jwt');


//  sucursal Lista

async function sucursal_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()
        .input('estatus', sql.VarChar(10), 'ALTA')  
        .query('Select * from Sucursal where Estatus=@estatus ')  
        let mksucursal= result.recordset;         
        res.status(200).json(mksucursal);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}



module.exports={
    sucursal_list
};