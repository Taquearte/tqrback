'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');

async function proy_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('estatus', sql.VarChar(10), 'ALTA')   
            .query('select ltrim(rtrim(proyecto)) as proyecto ,ltrim(rtrim(descripcion)) as descripcion, categoria from proy where estatus=@estatus')
        let mkproy= result.recordset;     
        res.status(200).json(mkproy);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}



module.exports={
    proy_list
};