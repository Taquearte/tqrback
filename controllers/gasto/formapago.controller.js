
'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');


async function formapago_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()                
            .query('select FormaPago from FormaPago')
        let mkformapago= result.recordset;     
        res.status(200).json(mkformapago);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

module.exports={
    formapago_list
};