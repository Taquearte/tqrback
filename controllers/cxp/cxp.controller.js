'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');


async function cxp_list (req, res) {
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
          .query('Exec mk_spAfectar @mkid, @usuario, @modulo')
      console.log(result);
      let mkgasto= result.recordset;     
      res.status(200).json(mkgasto);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

async function gasto_new (req, res) {
      console.log(req.body);
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
    console.log(req.params.id);
	var mkID=req.params.id;
    try {
        const pool = await poolPromise
        const result = await pool.request()  
            .input('id', sql.VarChar(10), mkID)   
            .query('SELECT ID,Empresa, Mov, MovID, FechaEmision, UltimoCambio, Acreedor, Moneda, TipoCambio, Proyecto, Usuario, Observaciones, '+
            'Clase, Subclase, Estatus, Condicion, Vencimiento, Importe, Retencion, Impuestos, FechaRequerida, Sucursal, SucursalOrigen, Comentarios, Prioridad, '+
            'SubModulo,FormaPago FROM gasto WHERE  ID = @id ')
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
                   'ContUso, Sucursal, SucursalOrigen, Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1,ClavePresupuestal,Retencion as ImpRetencion ,Retencion2 as ImpRetencion2,convert(money,(Importe + isnull(Impuesto1,0)- isnull(Retencion,0)-isnull(Retencion,0))) as Total FROM gastod WHERE  ID = @id ')
        let mkgasto= result.recordset;     
        res.status(200).json(mkgasto);
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
    gasto_afectar
};