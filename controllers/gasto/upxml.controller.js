'use strict'
const { poolPromise } = require('../../database/conection');
const sql = require('mssql');
const convert = require('xml-js');
var libxmljs = require("libxmljs");
var format = require('xml-formatter');
const fs = require('fs');

function isValidSyntaxStructure (text) {
  try {
      libxmljs.parseXml(text);
  } catch (e) {
      //console.log(e.Error);
      return false;
  }
  return true;
};


async function upxml_consecutivo (req, res) {
  try {
    const pool = await poolPromise
    const result = await pool.request()  
        .input('mkclave', sql.VarChar(100), 'XML') 
        .input('params2', sql.VarChar(10), '0')    
        .query('EXEC mkspVerConsecutivo @mkclave,@params2')
    //console.log(result.recordset[0]);
    let proy_con= result.recordset[0].Consecutivo;     
    res.status(200).json(proy_con);
  } catch (err) {
    res.status(500).json(err.message);
  }  
}

async function upxml_del_one_xml (req, res) {
  var mkID=req.params.id;
  try {
      const pool = await poolPromise
      const result = await pool.request()   
          .input('ID', sql.VarChar(10), mkID)      
          .query('EXEC mk_spquitarcabecero @ID')
      console.log(result.recordset[0]);    
      res.status(200).json(result.recordset[0]);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}
async function upxml_list (req, res) {
    try {
        const pool = await poolPromise
        const result = await pool.request()   
            .input('est', sql.VarChar(10), 'ACTIVO')     
            .input('est2', sql.VarChar(10), 'RECHAZADO')   
            .input('est3', sql.VarChar(10), 'CONCLUIDO')   
            .query('SELECT a.Descripcion, a.Usuario, b.Nombre as Empresa, c.Nombre as Sucursal, a.Fecha, '+
            'Sum(case when a.Estatus=@est then 1 else 0 end) as Activos, '+
            'Sum(case when a.Estatus=@est2 then 1 else 0 end) as Rechazados, '+
            'Sum(case when a.Estatus=@est3 then 1 else 0 end) as Concluidos, '+
            'Count(*) as Total '+
            'FROM   mk_archivoxml a '+
            'join Empresa b on a.Empresa=b.Empresa '+
            'join Sucursal c on a.Sucursal=c.Sucursal '+
            'WHERE (a.Mostrar = 1) '+
            'Group by a.Descripcion, a.Usuario, b.Nombre, c.Nombre , a.Fecha')
        let mkXML= result.recordset;     
        res.status(200).json(mkXML);
      } catch (err) {
        res.status(500).json(err.message);
      }  
}
async function upxml_list10 (req, res) {
  try {
      const pool = await poolPromise
      const result = await pool.request()   
      .input('est', sql.VarChar(10), 'ACTIVO')     
      .input('est2', sql.VarChar(10), 'RECHAZADO')   
      .input('est3', sql.VarChar(10), 'CONCLUIDO')   
      .query('SELECT TOP 10 a.Descripcion, a.Usuario, a.Empresa, a.Sucursal, a.Fecha, '+
      'Sum(case when a.Estatus=@est then 1 else 0 end) as Activos, '+
      'Sum(case when a.Estatus=@est2 then 1 else 0 end) as Rechazados, '+
      'Sum(case when a.Estatus=@est3 then 1 else 0 end) as Concluidos, '+
      'Count(*) as Total '+
      'FROM   mk_archivoxml a '+
      'WHERE (a.Mostrar = 1) '+
      'Group by a.Descripcion, a.Usuario, a.Empresa, a.Sucursal, a.Fecha')
      let mkXML= result.recordset;     
      res.status(200).json(mkXML);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}
async function upxml_RFC_Receptor (req, res, next) {
  var params=req.body; 
  console.log(params);
  try {      
      const pool = await poolPromise      
      const result = await pool.request()   
          .input('Empresa', sql.VarChar(100), params.empresa) 
          .query('select RFC From Empresa where Empresa=@Empresa')
          req.rfc_receptor= result.recordset[0].RFC;     
      next();     
    } catch (err) {
      res.status(500).json(err.message);
    } 
     
}
async function upxml_addRFC_Nom (req, res, next) {
  try {
      const pool = await poolPromise      
      const result = await pool.request()   
          .input('tabla', sql.VarChar(100), 'RFC_XML_Nomina') 
          .query('SELECT Valor FROM TablaValorD WHERE TablaValor=@tabla')
      let mkXML_rfc= result.recordset;     
      req.rfcvalidosnomina=mkXML_rfc; 
      next();     
    } catch (err) {
      res.status(500).json(err.message);
    } 
     
}
async function upxml_listcabecero (req, res) {
  var mkid=req.params.id;
  try {
      const pool = await poolPromise
      const result = await pool.request()   
          .input('descripcion', sql.VarChar(150), mkid)  
          .query('select b.* '+
          'from mk_archivoxml a '+
          'join mk_archivoxmlEncabezado b on a.id=b.IdMov '+
          'where Descripcion=@descripcion order by a.id')
      let mkcabecero= result.recordset;     
      //console.log(mkgasto);
      res.status(200).json(mkcabecero);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}
async function upxml_new (req, res) {
    var params=req.body; 
    var mkfiles=req.files;
    var isValidXML='';
    var XMLConceptos=[];
    var XMLRetenciones=[];
    console.log(req.rfc_receptor);
    var emisorencontrado=[];
    // [ { fieldname: 'files',
    // originalname: '1E63019D-DABE-4EEF-BCCB-DEAB49FBA3BD@1000000000XX0.xml',
    // encoding: '7bit',
    // mimetype: 'text/xml',
    // destination: 'cliente/assets/xml',
    // filename: 'files-1568673143421.xml',
    // path: 'cliente\\assets\\xml\\files-1568673143421.xml',
    // size: 5080 } ]
  try {
      for (let i = 0; i < mkfiles.length; i++) { 
        console.log('Archivo',mkfiles[i].originalname);       

        var xmlfile=mkfiles[i].path;
        var xml = fs.readFileSync(xmlfile, 'utf8');
        // Movimiento
        const pool = await poolPromise
        const archivoxml = await pool.request()   
        .input('des', sql.VarChar(100), params.descripcion)                 
        .input('usu', sql.VarChar(100), params.usuario)  
        .input('emp', sql.VarChar(100), params.empresa)  
        .input('suc', sql.VarChar(100), params.sucursal)  
        .input('fec', sql.VarChar(100), params.fecha)  
        .input('est', sql.VarChar(100), params.estatus)  
        .input('ori', sql.VarChar(100), mkfiles[i].originalname)  
        .input('gua', sql.VarChar(100), mkfiles[i].filename)  
        .query('INSERT INTO mk_archivoxml (Descripcion,Usuario,Empresa,Sucursal,Fecha,Estatus,OriginalNombre,GuardadoComo,Mostrar) '+
              'OUTPUT INSERTED.ID Values ( @des,@usu,@emp,@suc,@fec,@est,@ori,@gua,1 )')
        var IDMov=archivoxml.recordset[0].ID;

        isValidXML=''
        isValidXML = isValidSyntaxStructure(xml);

        if (isValidXML) {
          var JsonXml = convert.xml2json(xml, {compact: true, spaces: 4});
          var cfdi =JSON.parse(JsonXml);
          //console.log(JsonXml);

          var tipoComprobante=cfdi['cfdi:Comprobante']._attributes.TipoDeComprobante;
          var mkreceptor=cfdi['cfdi:Comprobante']['cfdi:Receptor']._attributes.Rfc
          var mkemisor=cfdi['cfdi:Comprobante']['cfdi:Emisor']._attributes.Rfc

          
          if ((tipoComprobante !='I')  &&  (tipoComprobante !='N')) {
            console.log('Rechazado','El archivo no es de tipo comprobante ni de tipo Nomina');
            const updrechazotipo = await pool.request()   
            .input('IDMov', sql.VarChar(100), IDMov)
            .input('Estatus', sql.VarChar(100), 'RECHAZADO') 
            .input('Observaciones', sql.VarChar(100), 'El comprobante no es de tipo ingreso, por lo cual no se puede generar un movimiento de gasto') 
            .query('UPDATE mk_archivoxml Set Estatus=@Estatus, Observaciones=@Observaciones Where ID=@IDMov ')
            //console.log( updrechazotipo);
          } else if ((tipoComprobante =='I') && ( mkreceptor != req.rfc_receptor)) {
            console.log('Rechazado','El receptor de l archivo es diferente');
            const updrechazorec = await pool.request()   
            .input('IDMov', sql.VarChar(100), IDMov)
            .input('Estatus', sql.VarChar(100), 'RECHAZADO') 
            .input('Observaciones', sql.VarChar(100), 'El comprobante tipo I no esta dirigido a la empresa: '+params.empresa+', RFC: '+req.rfc_receptor) 
            .query('UPDATE mk_archivoxml Set Estatus=@Estatus, Observaciones=@Observaciones Where ID=@IDMov ')
            //console.log( updrechazorec);
          } else if ((tipoComprobante =='N') && ( mkemisor != req.rfc_receptor)) {
            console.log('Rechazado','El emisor de l archivo es diferente');
            const updrechazorec = await pool.request()   
            .input('IDMov', sql.VarChar(100), IDMov)
            .input('Estatus', sql.VarChar(100), 'RECHAZADO') 
            .input('Observaciones', sql.VarChar(100), 'El comprobante tipo N, no esta emitido por la empresa: '+params.empresa+', RFC: '+req.rfc_receptor) 
            .query('UPDATE mk_archivoxml Set Estatus=@Estatus, Observaciones=@Observaciones Where ID=@IDMov ')
            //console.log( updrechazorec);
          } else {
            const archivoxmlCabecero = await pool.request()   
            .input('IDMov', sql.VarChar(100), IDMov)
            .input('Version', sql.VarChar(100), cfdi['cfdi:Comprobante']._attributes.Version) 
            .input('Serie', sql.VarChar(100), cfdi['cfdi:Comprobante']._attributes.Serie) 
            .input('Folio', sql.VarChar(100), cfdi['cfdi:Comprobante']._attributes.Folio)
            .input('Fecha',    sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.Fecha)
            .input('FormaPago',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.FormaPago)
            .input('NoCertificado',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.NoCertificado)
            .input('CondicionesDePago',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.CondicionesDePago)
            .input('Subtotal',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.SubTotal)
            .input('Moneda',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.Moneda)
            .input('TipoCambio',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.TipoCambio)
            .input('Total',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.Total)
            .input('TipoDeComprobante',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.TipoDeComprobante)
            .input('MetodoDePago',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.MetodoPago)
            .input('LugarExpedicion',sql.VarChar(100),cfdi['cfdi:Comprobante']._attributes.LugarExpedicion)
            .input('EmisorRFC', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Emisor']._attributes.Rfc)
            .input('EmisorNombre', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Emisor']._attributes.Nombre)
            .input('EmisorRegimenFiscal', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Emisor']._attributes.RegimenFiscal)
            .input('ReceptorRFC', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Receptor']._attributes.Rfc)
            .input('ReceptorNombre', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Receptor']._attributes.Nombre)
            .input('ReceptorRegimenFiscal', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Receptor']._attributes.RegimenFiscal)
            .input('Estatus', sql.VarChar(100), 'SINPROCESAR')
            .input('UUID', sql.VarChar(100), cfdi['cfdi:Comprobante']['cfdi:Complemento']['tfd:TimbreFiscalDigital']._attributes.UUID)
            .input('proyecto', sql.VarChar(100), params.proyecto)  
            .query('INSERT INTO mk_archivoxmlEncabezado ( IDMov, version,Serie,Folio,Fecha,FormaPago,NoCertificado,CondicionesDePago,Subtotal,Moneda,TipoCambio,Total,TipoDeComprobante,MetodoDePago,LugarExpedicion, '+
            'EmisorRFC,EmisorNombre,EmisorRegimenFiscal,ReceptorRFC,ReceptorNombre,ReceptorRegimenFiscal,Estatus,UUID,Proyecto ) '+
            'OUTPUT INSERTED.ID Values ( @IDMov, @Version, @Serie, @Folio, @Fecha,@FormaPago,@NoCertificado,@CondicionesDePago,@Subtotal,@Moneda,@TipoCambio,@Total,@TipoDeComprobante,@MetodoDePago,@LugarExpedicion, '+
            '@EmisorRFC,@EmisorNombre,@EmisorRegimenFiscal, @ReceptorRFC, @ReceptorNombre, @ReceptorRegimenFiscal, @Estatus ,@UUID, @proyecto )')
            var IDC=archivoxmlCabecero.recordset[0].ID;

            XMLConceptos=cfdi['cfdi:Comprobante']['cfdi:Conceptos']['cfdi:Concepto'];            
     
            if (XMLConceptos.length == undefined) {
                console.log('Info','Concepto Sin Array');
                const archivoxmlDetalle = await pool.request()   
                .input('IDCab', sql.VarChar(100), IDC)
                .input('ClaveProdServ', sql.VarChar(100), XMLConceptos._attributes.ClaveProdServ)                                                                       
                .input('Cantidad', sql.VarChar(100), XMLConceptos._attributes.Cantidad)
                .input('ClaveUnidad', sql.VarChar(100), XMLConceptos._attributes.ClaveUnidad)
                .input('Unidad', sql.VarChar(100), XMLConceptos._attributes.Unidad)
                .input('Descripcion', sql.VarChar(100),XMLConceptos._attributes.Descripcion)
                .input('ValorUnitario', sql.VarChar(100), XMLConceptos._attributes.ValorUnitario)
                .input('ArtImporte', sql.VarChar(100), XMLConceptos._attributes.Importe)
                .query('INSERT INTO mk_archivoxmlDetalle ( IDCab, ClaveProdServ, Cantidad, ClaveUnidad, Unidad, Descripcion,ValorUnitario,ArtImporte ) '+
                'OUTPUT INSERTED.ID Values ( @IDCab, @ClaveProdServ, @Cantidad, @ClaveUnidad, @Unidad, @Descripcion,@ValorUnitario,@ArtImporte )')
                var IDCD=archivoxmlDetalle.recordset[0].ID;
               if (tipoComprobante !='N') {
                  // verificamos si tiene la llave de impuestos trasladados IVA
                  if (XMLConceptos['cfdi:Impuestos'] == undefined)  {
                    console.log('Info','No Existe El Nodo Impuestos')
                  } else { 
                    //IVA
                    if (XMLConceptos['cfdi:Impuestos']['cfdi:Traslados'] == undefined){
                      console.log('Info','No Existe El Nodo Traslados');
                      } else {
                        
                        if (XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'].length == undefined) {
                          console.log('Info','El Nodo Traslados no es Array');
                          const updtras = await pool.request()   
                          .input('ID', sql.VarChar(100), IDCD)
                          .input('Base', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.Base)
                          .input('Impuesto', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.Impuesto)
                          .input('TipoFactor', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.TipoFactor)
                          .input('TasaOCuota', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.TasaOCuota)
                          .input('Importe', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.Importe) 
                          .query('UPDATE mk_archivoxmlDetalle Set Base=@Base,Impuesto=@Impuesto,TipoFactor=@TipoFactor, TasaOCuota=@TasaOCuota,Importe=@Importe Where ID=@ID ')                              

                        } else {
                          console.log('Info','El Nodo Traslados  Array');
                          for (let e = 0; e < XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'].length; e++) {
                            if (XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Importe != 0) {
                              const updtras = await pool.request()   
                              .input('ID', sql.VarChar(100), IDCD)
                              .input('Base', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Base)
                              .input('Impuesto', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Impuesto)
                              .input('TipoFactor', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.TipoFactor)
                              .input('TasaOCuota', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.TasaOCuota)
                              .input('Importe', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Importe) 
                              .query('UPDATE mk_archivoxmlDetalle Set Base=@Base,Impuesto=@Impuesto,TipoFactor=@TipoFactor, TasaOCuota=@TasaOCuota,Importe=@Importe Where ID=@ID ')
                             
                            }
                           }
                        }                          

                    }
                      // ISR
                      if (XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones'] == undefined) {
                        console.log('Info','No Existe El Nodo Retensiones');
                      } else { 
                        if (XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'].length == undefined) {
                          console.log('Info','El Nodo Retenciones no es Array');
                          const updret = await pool.request()                       
                          .input('ID', sql.VarChar(100), IDCD)  
                          .input('Base', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.Base)
                          .input('Impuesto', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.Impuesto)
                          .input('TipoFactor', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.TipoFactor)
                          .input('TasaOCuota', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.TasaOCuota)
                          .input('Importe', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.Importe)
  
                          .query('UPDATE mk_archivoxmlDetalle Set RetBase=@Base,RetImpuesto=@Impuesto,RetTipoFactor=@TipoFactor, RetTasaOCuota=@TasaOCuota,RetImporte=@Importe'+                        
                          ' Where ID=@ID ')
                        } else {
                          console.log('Info','El Nodo Retenciones  Array');
                          for (let a = 0; a < XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'].length; a++) {
                            if (XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe != 0) {
                              if (a==1){
                                console.log('Retencion Con Array Element',a);
                                const updret = await pool.request()                       
                                .input('ID', sql.VarChar(100), IDCD)  
                                .input('Base', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Base)
                                .input('Impuesto', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Impuesto)
                                .input('TipoFactor', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TipoFactor)
                                .input('TasaOCuota', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TasaOCuota)
                                .input('Importe', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe)
        
                                .query('UPDATE mk_archivoxmlDetalle Set RetBase=@Base,RetImpuesto=@Impuesto,RetTipoFactor=@TipoFactor, RetTasaOCuota=@TasaOCuota,RetImporte=@Importe'+                        
                                ' Where ID=@ID ')
                              } else if (a==2){
                                console.log('Retencion Con Array Element',a);
                                const updret = await pool.request()                       
                                .input('ID', sql.VarChar(100), IDCD)  
                                .input('Base', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Base)
                                .input('Impuesto', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Impuesto)
                                .input('TipoFactor', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TipoFactor)
                                .input('TasaOCuota', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TasaOCuota)
                                .input('Importe', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe)
        
                                .query('UPDATE mk_archivoxmlDetalle Set RetBase2=@Base,RetImpuesto2=@Impuesto,RetTipoFactor2=@TipoFactor, RetTasaOCuota2=@TasaOCuota,RetImporte2=@Importe'+                        
                                ' Where ID=@ID ')                              
                              } else if (a==3){
                                console.log('Retencion Con Array Element',a);
                                const updret = await pool.request()                       
                                .input('ID', sql.VarChar(100), IDCD)  
                                .input('Base', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Base)
                                .input('Impuesto', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Impuesto)
                                .input('TipoFactor', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TipoFactor)
                                .input('TasaOCuota', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TasaOCuota)
                                .input('Importe', sql.VarChar(100), XMLConceptos['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe)
        
                                .query('UPDATE mk_archivoxmlDetalle Set RetBase3=@Base,RetImpuesto3=@Impuesto,RetTipoFactor3=@TipoFactor, RetTasaOCuota3=@TasaOCuota,RetImporte3=@Importe'+                        
                                ' Where ID=@ID ')
                              }                                                    
                            }
                          }
                        }
                      } //fin ISR                         
                  }  
               }

            } else {
                console.log('Info','Concepto Array....');                
                for (let i = 0; i < XMLConceptos.length; i++) {
                   const archivoxmlDetalle = await pool.request()   
                  .input('IDCab', sql.VarChar(100), IDC)
                  .input('ClaveProdServ', sql.VarChar(100), XMLConceptos[i]._attributes.ClaveProdServ)
                  .input('Cantidad', sql.VarChar(100), XMLConceptos[i]._attributes.Cantidad)
                  .input('ClaveUnidad', sql.VarChar(100), XMLConceptos[i]._attributes.ClaveUnidad)
                  .input('Unidad', sql.VarChar(100), XMLConceptos[i]._attributes.Unidad)
                  .input('Descripcion', sql.VarChar(100), XMLConceptos[i]._attributes.Descripcion)
                  .input('ValorUnitario', sql.VarChar(100), XMLConceptos[i]._attributes.ValorUnitario)
                  .input('ArtImporte', sql.VarChar(100), XMLConceptos[i]._attributes.Importe)

                  .query('INSERT INTO mk_archivoxmlDetalle ( IDCab, ClaveProdServ, Cantidad, ClaveUnidad, Unidad, Descripcion,ValorUnitario,ArtImporte ) '+
                  'OUTPUT INSERTED.ID Values ( @IDCab, @ClaveProdServ, @Cantidad, @ClaveUnidad, @Unidad, @Descripcion,@ValorUnitario,@ArtImporte )')
                  var IDCD=archivoxmlDetalle.recordset[0].ID;
                  //console.log('aqui',IDCD,XMLConceptos[i]);
                // console.log(XMLConceptos[i]['cfdi:Impuestos']);
                  if (tipoComprobante !='N') {

                    if (XMLConceptos[i]['cfdi:Impuestos']== undefined){
                          console.log('Info','no existe el nodo traslados');
                      } else {
                        if (XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados'] == undefined){
                          console.log('Info','No Existe El Nodo Traslados');
                          } else {
                            if (XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'].length == undefined) {
                              console.log('Info','El Nodo Traslados no es Array');
                              const updtras = await pool.request()   
                              .input('ID', sql.VarChar(100), IDCD)
                              .input('Base', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.Base)
                              .input('Impuesto', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.Impuesto)
                              .input('TipoFactor', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.TipoFactor)
                              .input('TasaOCuota', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.TasaOCuota)
                              .input('Importe', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado']._attributes.Importe) 
                              .query('UPDATE mk_archivoxmlDetalle Set Base=@Base,Impuesto=@Impuesto,TipoFactor=@TipoFactor, TasaOCuota=@TasaOCuota,Importe=@Importe Where ID=@ID ')                              

                            } else {
                              console.log('Info','El Nodo Traslados Array');
                              for (let e = 0; e < XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'].length; e++) {
                                if (XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Importe != 0) {
                                  const updtras = await pool.request()   
                                  .input('ID', sql.VarChar(100), IDCD)
                                  .input('Base', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Base)
                                  .input('Impuesto', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Impuesto)
                                  .input('TipoFactor', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.TipoFactor)
                                  .input('TasaOCuota', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.TasaOCuota)
                                  .input('Importe', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Traslados']['cfdi:Traslado'][e]._attributes.Importe) 
                                  .query('UPDATE mk_archivoxmlDetalle Set Base=@Base,Impuesto=@Impuesto,TipoFactor=@TipoFactor, TasaOCuota=@TasaOCuota,Importe=@Importe Where ID=@ID ')
                                 
                                }
                               }
                            }                          

                        }
                      // ISR
                      if (XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones'] == undefined) {
                        console.log('Info','No Existe El Nodo Retensiones');
                      } else { 
                        if (XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'].length == undefined) {
                          console.log('Info','retencion sin array');
                          const updret = await pool.request()                       
                          .input('ID', sql.VarChar(100), IDCD)  
                          .input('Base', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.Base)
                          .input('Impuesto', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.Impuesto)
                          .input('TipoFactor', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.TipoFactor)
                          .input('TasaOCuota', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.TasaOCuota)
                          .input('Importe', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion']._attributes.Importe)
  
                          .query('UPDATE mk_archivoxmlDetalle Set RetBase=@Base,RetImpuesto=@Impuesto,RetTipoFactor=@TipoFactor, RetTasaOCuota=@TasaOCuota,RetImporte=@Importe'+                        
                          ' Where ID=@ID ')
                        } else {
                          console.log('Info','Retencion Con Array');
                          for (let a = 0; a < XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'].length; a++) {
                            if (XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe != 0) {
                              if (a==1){
                                console.log('Retencion Con Array Element',a);
                                const updret = await pool.request()                       
                                .input('ID', sql.VarChar(100), IDCD)  
                                .input('Base', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Base)
                                .input('Impuesto', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Impuesto)
                                .input('TipoFactor', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TipoFactor)
                                .input('TasaOCuota', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TasaOCuota)
                                .input('Importe', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe)
        
                                .query('UPDATE mk_archivoxmlDetalle Set RetBase=@Base,RetImpuesto=@Impuesto,RetTipoFactor=@TipoFactor, RetTasaOCuota=@TasaOCuota,RetImporte=@Importe'+                        
                                ' Where ID=@ID ')
                              } else if (a==2){
                                console.log('Retencion Con Array Element',a);
                                const updret = await pool.request()                       
                                .input('ID', sql.VarChar(100), IDCD)  
                                .input('Base', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Base)
                                .input('Impuesto', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Impuesto)
                                .input('TipoFactor', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TipoFactor)
                                .input('TasaOCuota', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TasaOCuota)
                                .input('Importe', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe)
        
                                .query('UPDATE mk_archivoxmlDetalle Set RetBase2=@Base,RetImpuesto2=@Impuesto,RetTipoFactor2=@TipoFactor, RetTasaOCuota2=@TasaOCuota,RetImporte2=@Importe'+                        
                                ' Where ID=@ID ')                              
                              } else if (a==3){
                                console.log('Retencion Con Array Element',a);
                                const updret = await pool.request()                       
                                .input('ID', sql.VarChar(100), IDCD)  
                                .input('Base', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Base)
                                .input('Impuesto', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Impuesto)
                                .input('TipoFactor', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TipoFactor)
                                .input('TasaOCuota', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.TasaOCuota)
                                .input('Importe', sql.VarChar(100), XMLConceptos[i]['cfdi:Impuestos']['cfdi:Retenciones']['cfdi:Retencion'][a]._attributes.Importe)
        
                                .query('UPDATE mk_archivoxmlDetalle Set RetBase3=@Base,RetImpuesto3=@Impuesto,RetTipoFactor3=@TipoFactor, RetTasaOCuota3=@TasaOCuota,RetImporte3=@Importe'+                        
                                ' Where ID=@ID ')
                              }                                                    
                            }
                          }
                        }
                      } //fin ISR                       
                      } 
                  }                
              }            
            }


          }  
          //console.log(isValidXML,mkfiles[i].originalname,mkfiles[i].filename);
        } else { // is Valid
          console.log(isValidXML,mkfiles[i].originalname,mkfiles[i].filename);
        }   
        if (i == mkfiles.length-1){            
            res.status(200).json({mkresxml:'los archivos subieron correctamente'});
        }
      }
    } catch (err) {
      console.log(err);
      res.status(500).json(err.message);
    }  
}
async function upxml_sparchivar(req,res){  
  var mkmov=req.params.id;
  try {
    const pool = await poolPromise
    const result = await pool.request()   
        .input('mov', sql.VarChar(100), mkmov) 
        .query('Exec mk_sparchivar @mov')
    let mkXML= result.recordset;     
    res.status(200).json(mkXML);
  } catch (err) {
    res.status(500).json(err.message);
  }  
}
async function upxml_spafecta(req,res){  
  var mkmov=req.params.id;
  try {
    const pool = await poolPromise
    const result = await pool.request()   
        .input('mov', sql.VarChar(100), mkmov) 
        .query('Exec mk_spGeneraGasto @mov')
    let mkXML= result.recordset;     
    res.status(200).json(mkXML);
  } catch (err) {
    res.status(500).json(err.message);
  }  
}
async function upxml_uno (req, res) {
  var mkmovid=req.params.id;
  //console.log(mkmovid);
  try {
      const pool = await poolPromise
       const result = await pool.request()   
          .input('ID', sql.VarChar(10), mkmovid)   
          .query('Select b.* from mk_archivoxml a '+
          'join mk_archivoxmlEncabezado b on a.ID=b.IdMov where a.id=@ID ')
      let mkXML= result.recordset;  
      //console.log(mkXML); 
      const pool2 = await poolPromise
      const result2 = await pool.request()   
      .input('ID', sql.VarChar(10), mkmovid)   
      .query('Select b.* from mk_archivoxmlEncabezado a join mk_archivoxmlDetalle b on a.ID=b.IdCab  where a.idMov=@ID ')
      let mkXMLDetalle= result2.recordset;  
      mkXML[0].Detalle=mkXMLDetalle;
      //console.log(mkXMLDetalle);
      res.status(200).json(mkXML);
    } catch (err) {
      res.status(500).json(err.message);
    }  
}

module.exports={
    upxml_list,
    upxml_list10,
    upxml_new,
    upxml_uno,
    upxml_spafecta,
    upxml_listcabecero,
    upxml_sparchivar,
    upxml_addRFC_Nom,
    upxml_del_one_xml,
    upxml_RFC_Receptor,
    upxml_consecutivo
};