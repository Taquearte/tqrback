'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');




async function concepto_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request() 
            .input('mov', sql.VarChar(10), 'GAS')  
            .input('nuloc', sql.VarChar(20), 'SIN CLASE')   
            .input('nulos', sql.VarChar(20), 'SIN SUBCLASE')  
            .query('Select Modulo,Concepto,isnull(Clase,@nuloc) as Clase ,isnull(SubClase,@nulos) as SubClase,PorcentajeDeducible, '+
                   'TipoImpuesto1,Impuestos,Retencion,Retencion2,Retencion3 from concepto where modulo=@mov')
        let mkconcepto= result.recordset;     
        res.status(200).json(mkconcepto);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

async function conceptocla_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request() 
            .input('mov', sql.VarChar(10), 'GAS')
            .input('nulo', sql.VarChar(20), 'SIN CLASE')   
            .query('Select isnull(Clase,@nulo) as Clase from Clase where modulo=@mov')
        let mkconcepto= result.recordset;     
        res.status(200).json(mkconcepto);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

async function conceptosub_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request() 
            .input('mov', sql.VarChar(10), 'GAS')  
            .input('nulo', sql.VarChar(20), 'SIN SUBCLASE') 
            .input('nuloc', sql.VarChar(20), 'SIN CLASE') 
            .query('Select isnull(Clase,@nuloc) as Clase,isnull(SubClase,@nulo) as SubClase  from SubClase where modulo=@mov')
        let mkconcepto= result.recordset;     
        res.status(200).json(mkconcepto);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

function concepto_new(req,res){    
    console.log('new');
}

function concepto_edit(req,res){  
    console.log('edit');
}

function concepto_uno (req,res){
    console.log('uno');
}

module.exports={
    concepto_list,
    conceptocla_list,
    conceptosub_list,
    concepto_new,
    concepto_edit,
    concepto_uno,
};