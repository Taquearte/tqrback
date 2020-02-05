'use strict'
var express = require('express');
var cors = require('cors')
var path = require('path');
var stream = require('stream');
const dbconection = require('../../database/conection');


function perfil_list (req,res){
    const con =dbconection();
    var perfil_id=req.params.id;
    var modulo='PERFIL';
    //link_id=457;    
    //console.log(plan);
    if (perfil_id){
    var modulo='PERFIL';
        con.query('SELECT * FROM linkmov where Modulo=? and Usuario=? Order by IDInterno desc LIMIT 1',[modulo,perfil_id],(err,perfil,fields) => {

            if (err){
                //console.log(err);
                res.status(500).send({message:err.sqlMessage});
            } else {
                
                if (!perfil){
                    res.status(400).send({message:'No se pudo realizar la consulta'});
                } else {
                    res.status(200).send({perfil});
                    //console.log(perfil);
                    con.end();
                }
            }
        })
    } else {
        res.status(404).send({message:'la informacion no esta completa'});
    }
}

// Insertar 
function perfil_new(req,res){  
    const con =dbconection();
    var params=req.body; 
    var mk_file = req.file.filename;
    var mk_type = req.file.mimetype;   
    var mk_data = null;
    //console.log(req.file);
    if (params.usuario  ){
        con.query('INSERT INTO linkmov '+
        '(ID, Modulo, Nombre, Tipo, Archivo, Nota, Vinculo, Usuario, Fecha,ArchivoDatos ) '+
        'VALUES (?,?,?,?,?,?,?,?,?,?);',[params.renglon,params.modulo,mk_file,mk_type,mk_file,'','',params.usuario,'',mk_data],(err,perfil,fields) => {
            if (err){
                console.log(err.sqlMessage);
                res.status(500).send({message:err.sqlMessage});
            } else {
                if (perfil.affectedRows===0){                            
                    res.status(400).send({message:'No se pudo realizar la insercion'});
                } else {
                    res.status(200).send({perfil:'Se inserto correctamente'});
                    con.end();
                }
            }
        })
    } else {
        res.status(404).send({message:'la informacion no esta completa'});
    }

}

module.exports={
    perfil_new,
    perfil_list
};