'use strict'

const { poolPromise } = require('../../database/conection');
const sql = require('mssql');

async function adjunto_list (req, res) {    
    try {
        const pool = await poolPromise
        const result = await pool.request()  
          .input('id', sql.VarChar(10), req.params.id)    
          .input('modulo', sql.VarChar(10), 'COMS')
          .query('SELECT * FROM AnexoMov WHERE Rama=@modulo and ID=@id')  
        let mkadjuntos= result.recordset;  
        res.status(200).json(mkadjuntos);
      } catch (err) {
        res.status(500).json(err.message);
      }  
  }


// Insertar 
async function adjunto_new (req, res) { 
    var backend = new Object();
    var params=req.body; 
    //console.log(req.file);
    var mk_file = req.file.originalname;     
    var mk_type = req.file.originalname.substr(-3,3);   
    var mk_filename = req.file.filename;   
    var mk_path = req.file.path;  
    try {
        const pool = await poolPromise
        const result = await pool.request()  
          .input('id', sql.VarChar(10), params.id)    
          .input('modulo', sql.VarChar(10), params.rama)
          .input('tipo', sql.VarChar(10), mk_type)
          .input('nombre', sql.VarChar(255), mk_filename)
          .input('direccion', sql.VarChar(255), mk_path)
          .input('hoy', sql.VarChar(10), params.fecha)
          .input('usuario', sql.VarChar(10), params.usuario)
          .input('nombreoriginal', sql.VarChar(255), mk_file)
          .query('INSERT INTO AnexoMov '+
                 '(  Rama,  ID,  Nombre,  Tipo, Direccion, Icono, Orden,   FechaEmision, Alta, UltimoCambio, Usuario,Comentario) '+
          'VALUES (@modulo, @id, @nombre, @tipo, @direccion, 745, 2,   @hoy, @hoy, @hoy , @usuario,@nombreoriginal)')  
        let mkadjuntos= result.rowsAffected[0];   
        backend.Ok=0;
        backend.Ref='Se inserto correctamente'
        res.status(200).json(backend);

      } catch (err) {
        console.log(err.message);
        res.status(500).json(err.message);
      }  
  }

  async function adjunto_donwload (req, res) {    
    try {
        const pool = await poolPromise
        const result = await pool.request()  
          .input('id', sql.VarChar(10), req.params.id)    
          .query('SELECT * FROM AnexoMov WHERE Rama=@modulo and IDR=@id')  
        let mkadjuntos= result.recordset;  
/*         var fileContents = new Buffer(mkadjuntos[0].ArchivoDatos, "base64");
		            var readStream = new stream.PassThrough();
		            readStream.end(fileContents);		
                    res.set('Content-disposition', 'attachment; filename=' + mkadjuntos[0].Archivo);
                    res.set('Content-Type', mkadjuntos[0].Tipo);
                    readStream.pipe(res); */
        res.status(200).json(mkadjuntos);
      } catch (err) {
        res.status(500).json(err.message);
      }  
    }


module.exports={
    adjunto_list,
    adjunto_new,
    adjunto_donwload
};