'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql')
var jwt=require('../../services/jwt');

//  Empresa Lista
async function empresa_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()        
            .query('select Empresa,Nombre from Empresa ')    
        let mkempresa= result.recordset;     
        res.status(200).json(mkempresa);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

//  sucursal Lista

async function sucursal_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()        
            .query('select Sucursal,Nombre from Sucursal')   
        let mksucursal= result.recordset;         
        res.status(200).json(mksucursal);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}


//Login
async function login(req,res){
    var params = req.body;
    try {
        const pool = await poolPromise
        const result = await pool.request()    
            .input('usuario', sql.VarChar(30), params.usuario)  
            .input('password', sql.VarChar(30), params.password)
            .input('empresa', sql.VarChar(30), params.empresa)
            .input('sucursal', sql.VarChar(30), params.sucursal)
            .execute('mksp_acceso')
            //console.log(result.recordset[0]);
            if (result.recordset[0].OKRef=='Correcto') {
                if( params.gettoken ){
                    //devolver el token
                    res.status(200).send({
                        token: jwt.createToken(params)
                    });
                }else{
                    res.status(200).json(result.recordset[0]);
                }
            } else {
                res.status(200).json(result.recordset[0]);
            }

      } catch (err) {
          //console.log(err.message);
        res.status(500).json(err.message);
      }        
}

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
    empresa_list,
    sucursal_list,
    login,
    perfil_new,
    perfil_list
};