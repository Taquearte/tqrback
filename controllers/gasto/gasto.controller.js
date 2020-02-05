'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');
const topnumber = '500';

async function gasto_list9 (req, res) {
  //req.params.id
  //req.body
  //console.log(req.params.id);
var mkempresa=req.params.id;
  try {
      const pool = await poolPromise
      const result = await pool.request()  
          .input('emp', sql.VarChar(10), mkempresa)   
          .input('est', sql.VarChar(10), 'SINAFECTAR')  
          .input('gasto', sql.VarChar(10), 'GAS') 
          .input('cxp', sql.VarChar(10), 'CXP') 
    
          .query('Select top 10 * from '+
                '(SELECT top 10 a.ID,@gasto as Modulo,a.Empresa, rtrim(Mov)+space(1)+rtrim(MovID) as Mov, FechaEmision, Usuario, a.Estatus, b.Nombre, Importe +Impuestos as Total '+
                'FROM gasto a join Prov b on a.Acreedor=b.Proveedor '+
                'WHERE  a.Estatus <> @est and Empresa = @emp order by FechaEmision desc '+
                'union ALL '+
                'SELECT  top 10 a.ID,@cxp as Modulo,a.Empresa, rtrim(Mov)+space(1)+rtrim(MovID) as Mov, FechaEmision, Usuario, a.Estatus, b.Nombre, Importe +Impuestos as Total '+
                'FROM cxp a join Prov b on a.Proveedor=b.Proveedor '+
                'WHERE  a.Estatus <> @est and Empresa = @emp order by FechaEmision desc)  x order by x.FechaEmision desc')
          let mkgasto= result.recordset;     
          res.status(200).json(mkgasto);
        } catch (err) {
          res.status(500).json(err.message);
        }  
}

async function gasto_list (req, res) {
    //req.params.id
    //req.body
    //console.log(req.params.id);
	var mkempresa=req.params.id;
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('emp', sql.VarChar(10), mkempresa)   
            .query('SELECT TOP 500  a.ID,a.Empresa, a.Mov,a.MovID,a.FechaEmision,a.Proyecto,a.Usuario,a.Estatus,a.Acreedor,a.Clase,a.SubClase,a.Importe, '+
            'a.Retencion,a.Impuestos,p.Nombre FROM gasto a join Prov p on a.Acreedor=p.Proveedor WHERE  a.Empresa =@emp Order by a.ID DESC ')
        let mkgasto= result.recordset;     
        res.status(200).json(mkgasto);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

async function gasto_afectar (req, res) {
 // let mkid=req.params.id
  //req.body
 // console.log(req.body);
//var mkempresa=req.params.id;
  try {
      const pool = await poolPromise
      const result = await pool.request()  
      .input('mkid', sql.VarChar(100), req.body.ID) 
      .input('usuario', sql.VarChar(10), req.body.Usuario)    
      .input('modulo', sql.VarChar(10), 'GAS')  
      .input('accion', sql.VarChar(10), req.body.Accion) 
      .input('mov', sql.VarChar(10), req.body.MovGenerar) 
      .query('Exec mk_spAfectar @mkid, @usuario, @modulo,@accion,@mov')
      let mkgasto= result.recordset;     
      res.status(200).json(mkgasto);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

async function gasto_new (req, res) {
      
  var params=req.body;
  
  
    try {
        const pool = await poolPromise
        const result = await pool.request()  
        .input('Empresa', sql.VarChar(100),params.Empresa)
        .input('Mov', sql.VarChar(100),params.Mov)
        .input('FechaEmision', sql.VarChar(100),params.FechaEmision)
        .input('UltimoCambio', sql.VarChar(100),params.UltimoCambio)
        .input('Acreedor', sql.VarChar(100),params.Acreedor)
        .input('Moneda', sql.VarChar(100),params.Moneda)
        .input('TipoCambio', sql.VarChar(100),params.TipoCambio)
        .input('Proyecto', sql.VarChar(100),params.Proyecto)
        .input('Usuario', sql.VarChar(100),params.Usuario)
        .input('Observaciones', sql.VarChar(100),params.Observaciones)    
        .input('Vencimiento', sql.VarChar(100),params.Vencimiento)
        .input('Importe', sql.VarChar(100),params.Importe)
        .input('Retencion', sql.VarChar(100),params.Retencion)
        .input('Impuestos', sql.VarChar(100),params.Impuestos)
        .input('FechaRequerida', sql.VarChar(100),params.FechaRequerida)
        .input('Sucursal', sql.VarChar(100),params.Sucursal)
        .input('SucursalOrigen', sql.VarChar(100),params.SucursalOrigen)
        .input('Comentarios', sql.VarChar(100),params.Comentarios)
        .input('Prioridad', sql.VarChar(100),params.Prioridad)
        .input('SubModulo', sql.VarChar(100),params.SubModulo)	
        .input('FormaPago', sql.VarChar(100),params.FormaPago)
        .input('Clase', sql.VarChar(100),params.Clase)
        .input('Subclase', sql.VarChar(100),params.Subclase)
        .input('Estatus', sql.VarChar(100),params.Estatus)
        .input('Condicion', sql.VarChar(100),params.Condicion)   
        .input('TieneRetencion', sql.VarChar(100),params.TieneRetencion)   
        .query('INSERT INTO Gasto (Empresa, Mov,  FechaEmision, UltimoCambio, Acreedor, Moneda, TipoCambio, Proyecto, Usuario, '+
               'Observaciones, Clase, Subclase, Estatus, Condicion, Vencimiento, Importe, Retencion, Impuestos, FechaRequerida, '+
               'Sucursal, SucursalOrigen, Comentarios, Prioridad, SubModulo,FormaPago,TieneRetencion) '+
               'Values (@Empresa,@Mov,@FechaEmision,@UltimoCambio, @Acreedor, @Moneda, @TipoCambio, @Proyecto,@Usuario, '+
               '@Observaciones, @Clase, @Subclase, @Estatus,@Condicion,@Vencimiento, @Importe, @Retencion, @Importe, @FechaRequerida, '+
               '@Sucursal, @SucursalOrigen, @Comentarios, @Prioridad,@SubModulo,@FormaPago,@TieneRetencion); SELECT @@IDENTITY AS ID')  
        let mkgastomov= result.recordset; 
        let GastoID=mkgastomov[0].ID;      
        let GastoDetalle=params.detalle; 

        try {
          for (let i = 0; i < GastoDetalle.length; i++) {
            let GastoReng=(i+1)*2048;
            const pool = await poolPromise
            const result = await pool.request()
            .input('ID',sql.VarChar(100),GastoID)
            .input('Renglon',sql.VarChar(100),GastoReng)
            .input('RenglonSub',sql.VarChar(100),GastoDetalle[i].RenglonSub)
            .input('Fecha',sql.VarChar(100),GastoDetalle[i].Fecha)
            .input('Concepto',sql.VarChar(100),GastoDetalle[i].Concepto)
            .input('Referencia',sql.VarChar(100),GastoDetalle[i].Referencia)
            .input('Cantidad',sql.VarChar(100),GastoDetalle[i].Cantidad)
            .input('Precio',sql.VarChar(100),GastoDetalle[i].Precio)
            .input('Importe',sql.VarChar(100),GastoDetalle[i].Importe)
            .input('Impuestos',sql.VarChar(100),GastoDetalle[i].Impuestos)
            .input('ContUso',sql.VarChar(100),GastoDetalle[i].ContUso)
            .input('Sucursal',sql.VarChar(100),GastoDetalle[i].Sucursal)
            .input('SucursalOrigen',sql.VarChar(100),GastoDetalle[i].SucursalOrigen)
            .input('Proyecto',sql.VarChar(100),GastoDetalle[i].Proyecto)
            .input('PorcentajeDeducible',sql.VarChar(100),GastoDetalle[i].PorcentajeDeducible)
            .input('TipoImpuesto1',sql.VarChar(100),GastoDetalle[i].TipoImpuesto1)
            .input('Impuesto1',sql.VarChar(100),GastoDetalle[i].Impuesto1)
            .input('Establecimiento',sql.VarChar(100),GastoDetalle[i].Establecimiento)
            .input('Retencion',sql.VarChar(100),GastoDetalle[i].ImpRetencion)
            .input('Retencion2',sql.VarChar(100),GastoDetalle[i].ImpRetencion2)

            .query(' INSERT INTO GastoD '+
                  '(ID, Renglon, RenglonSub, Fecha, Concepto, Referencia, Cantidad, Precio, Importe, Impuestos, ContUso, Sucursal, SucursalOrigen, '+
                  'Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1,AcreedorRef,Retencion,Retencion2) '+
                  'values (@ID,@Renglon, @RenglonSub, @Fecha, @Concepto, @Referencia, @Cantidad, @Precio, @Importe,@Impuestos, @ContUso, @Sucursal, @SucursalOrigen, '+
                  '@Proyecto, @PorcentajeDeducible, @TipoImpuesto1, @Impuesto1, @Establecimiento,@Retencion,@Retencion2)')
            if (i == GastoDetalle.length-1){              
              //console.log(result.rowsAffected[0]);
              //let mkgastomovd= result;      
              res.status(200).json({gastoid:GastoID});
              }
          }
          } catch (err) {
              console.log(err);
            res.status(500).json(err.message);
          }  
      } catch (err) {
          console.log(err);
        res.status(500).json(err.message);
      }  
}

function gasto_edit(req,res){  
    console.log('edit');
}

async function gasto_uno (req, res) {
   
  var mkID=req.params.id;
  var mkModulo='GAS';
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('id', sql.VarChar(10), mkID) 
            .input('modulo', sql.VarChar(10), mkModulo)   
            .input('nulo', sql.VarChar(10), '')
            .input('2espacios', sql.VarChar(10), '  ')
            .input('1espacios', sql.VarChar(10), ' ')
            .query('SELECT a.ID,a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.UltimoCambio, ltrim(rtrim(replace(a.Acreedor,@2espacios,@1espacios))) AS Acreedor,ltrim(rtrim(replace(p.Nombre,@2espacios,@1espacios))) AS PropveedorNombre,a.Clase,a.SubClase, a.Moneda, a.TipoCambio, '+
                'ltrim(rtrim(replace(a.Proyecto,@2espacios,@1espacios))) AS Proyecto, ltrim(rtrim(replace(pro.Descripcion,@2espacios,@1espacios))) as ProyectoNombre , a.Usuario, a.Observaciones, a.Estatus, a.Condicion, a.Vencimiento, a.Importe, a.Retencion, '+
                'a.Impuestos,  a.Sucursal, a.SucursalOrigen, a.Comentarios,  a.FormaPago, mt.Clave ,isnull(a.Origen,@nulo) as Origen, isnull(a.OrigenID,@nulo) as OrigenID '+
                'FROM gasto a '+
                'left join Prov p on ltrim(rtrim(replace(a.Acreedor,@2espacios,@1espacios))) = ltrim(rtrim(replace(p.Proveedor,@2espacios,@1espacios))) '+
                'left join Proy pro on ltrim(rtrim(replace(a.Proyecto,@2espacios,@1espacios))) = ltrim(rtrim(replace(pro.Proyecto,@2espacios,@1espacios))) '+
                'left join movtipo mt on a.mov =mt.mov and mt.modulo=@modulo '+  
                'WHERE  ID = @id' )
        let mkgasto= result.recordset;     
        res.status(200).json(mkgasto);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

async function gasto_unodet (req, res) {
    //console.log(req.params.id);
	var mkID=req.params.id;
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('id', sql.VarChar(10), mkID)   
            .query('SELECT ID, Renglon, RenglonSub, Fecha, Concepto, Referencia, Cantidad, Precio, Importe, Impuestos, '+
                   'ContUso, Sucursal, SucursalOrigen, Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1,ClavePresupuestal, '+
                   'Retencion as ImpRetencion ,Retencion2 as ImpRetencion2, '+
                   'convert(money,(Importe + isnull(Impuestos,0)- isnull(Retencion,0)-isnull(Retencion,0))) as Total FROM gastod WHERE  ID = @id ')
        let mkgasto= result.recordset;    
        //console.log(mkgasto) ;
        res.status(200).json(mkgasto);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}

async function gasto_movgenerar (req, res) { 
  console.log(req.body);  
  try {
       const pool = await poolPromise
       const result = await pool.request()  
           .input('modulo', sql.VarChar(100), req.body.modulo) 
           .input('clave', sql.VarChar(10), req.body.clave)    
           .input('subclave', sql.VarChar(10), req.body.subclave)  
           .input('empresa', sql.VarChar(10), req.body.empresa) 
           .query('Exec mksp_movflujo @modulo, @clave, @subclave, @empresa')
       let mkgastomovgenerar= result.recordset; 
       console.log(result);  
       console.log(mkgastomovgenerar);    
       res.status(200).json(mkgastomovgenerar);
     } catch (err) {
       res.status(500).json(err.message);
     }  
 }


module.exports={
    gasto_list,
    gasto_list9,
    gasto_new,
    gasto_edit,
    gasto_uno,
    gasto_unodet,
    gasto_afectar,
    gasto_movgenerar
};