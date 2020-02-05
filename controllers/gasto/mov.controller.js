'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');


async function mov_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('modulo', sql.VarChar(10), 'GAS')   
            .query('SELECT Mov,Orden,Clave,SubClave FROM Movtipo WHERE  Modulo = @modulo ORDER BY ORden ')
        let mkmov= result.recordset;     
        res.status(200).json(mkmov);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}
module.exports={
    mov_list
};