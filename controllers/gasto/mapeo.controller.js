'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');
const topnumber = '500';


async function mapeo_list (req, res) {
    //req.params.id
    //req.body
    //console.log(req.params.id);
	var mkempresa=req.params.id;
    try {
        const pool = await poolPromise
        const result = await pool.request() 
            .input('mov', sql.VarChar(10), 'GAS')  
            .query('SELECT a.id,a.Proveedor,a.Modulo,a.Concepto,a.ClaveProdServ,a.ClaveUnidad,a.UltimaDes,a.Estatus,b.Nombre,c.Clase,c.SubClase '+
                   'FROM mk_mapeoxml a  '+
                   'left join prov b on a.Proveedor=b.RFC  '+
                   'left join concepto c on a.Concepto=c.Concepto  '+
                   'and c.Modulo=@mov '+ 
                   'group by  a.id,a.Proveedor,a.Modulo,a.Concepto,a.ClaveProdServ,a.ClaveUnidad,a.UltimaDes,a.Estatus,b.Nombre,c.Clase,c.SubClase')
        let mkmapeo= result.recordset;     
        res.status(200).json(mkmapeo);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

function mapeo_new(req,res){    
    console.log('new');
}

async function  mapeo_edit(req,res){  
    var mkequiid=req.params.id;
    var params=req.body; 
    //console.log(params);
    var hoy= new Date(); 
    try {
        const pool = await poolPromise
        const result = await pool.request() 
            .input('id', sql.VarChar(20), mkequiid)  
            .input('estatus', sql.VarChar(20), 'COMPLETO')
            .input('concepto', sql.VarChar(255), params.concepto)  
            .input('usuario', sql.VarChar(20), params.usuario) 
            .input('fmodificacion', sql.DateTime, hoy)             
            .query('Update mk_mapeoxml Set Concepto=@concepto, Estatus=@estatus, usuario=@usuario,fmodificacion=@fmodificacion  where ID=@id')
        let mkmapeo= result; 
        res.status(200).json(mkmapeo);
      } catch (err) {
          console.log(err.message);
        res.status(500).json(err.message);
      } 
}

async function mapeo_uno (req, res) {
    var mkequiid=req.params.id;
    console.log(mkequiid);
    try {
        const pool = await poolPromise
        const result = await pool.request() 
            .input('mov', sql.VarChar(10), 'GAS')  
            .input('id', sql.VarChar(10), mkequiid)  
            .query(' SELECT a.*,b.Nombre,c.Clase,c.SubClase '+
            'FROM mk_mapeoxml a '+
            'left join prov b on a.Proveedor=b.RFC '+
            'left join concepto c on a.Concepto=c.Concepto '+
            'and c.Modulo=@mov where a.Id=@id' )
        let mkmapeo= result.recordset;  
        console.log(mkmapeo);   
        console.log(mkequiid);
        res.status(200).json(mkmapeo);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

module.exports={
    mapeo_list,
    mapeo_new,
    mapeo_edit,
    mapeo_uno,
};