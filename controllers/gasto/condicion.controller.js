
'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');

async function condicion_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .query('select Condicion from Condicion ')
        let mkcond= result.recordset;     
        res.status(200).json(mkcond);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

module.exports={
    condicion_list
};