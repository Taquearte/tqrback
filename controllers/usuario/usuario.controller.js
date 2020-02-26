'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql')
var jwt=require('../../services/jwt');

//  Usuario Lista
async function usuario_list (req, res) {

    try {
        const pool = await poolPromise
        const result = await pool.request()
        .input('estatus', sql.VarChar(10), 'ALTA')  
        .query('Select * from Usuario where Estatus=@estatus ')     
        let mkUsuario= result.recordset;     
        res.status(200).json(mkUsuario);
      } catch (err) {
        console.log(err.message);
        res.status(500).json(err.message);
      }  
}



module.exports={
    usuario_list
};