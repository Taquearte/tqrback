
'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');

async function prov_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('estatus', sql.VarChar(10), 'ALTA')   
            .query('selec Proveedor,Nombre from Prov where estatus=@estatus ')
        let mkprov= result.recordset;     
        res.status(200).json(mkprov);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

module.exports={
    prov_list
};