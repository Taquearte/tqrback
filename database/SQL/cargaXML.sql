SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mk_archivoxml','U') is null --drop table mk_archivoxml
create table mk_archivoxml 
(
id int identity,
Descripcion Varchar(255) NULL,
Usuario Varchar(255) NULL,
Empresa Varchar(255) NULL,
Sucursal Varchar(255) NULL,
Fecha Varchar(255) NULL,
Estatus Varchar(255) NULL,
OriginalNombre Varchar(255) NULL,
GuardadoComo Varchar(255) NULL,
Observaciones Varchar(255) NULL,
)

GO

if Object_ID('mk_archivoxmlEncabezado','U') is null --drop table mk_archivoxmlEncabezado
create table mk_archivoxmlEncabezado 
(
id int identity,
IdMov int NULL,
Version  Varchar(255) NULL,
Serie  Varchar(255) NULL,
Folio  Varchar(255) NULL,
Fecha  datetime NULL,
FormaPago  Varchar(255) NULL,
NoCertificado  Varchar(255) NULL,
CondicionesDePago Varchar(255) NULL,
Subtotal money NULL,
Moneda Varchar(255) NULL,
TipoCambio money NULL,
Total money NULL,
TipoDeComprobante Varchar(255) NULL,
MetodoDePago Varchar(255) NULL,
LugarExpedicion Varchar(255) NULL,
EmisorRFC Varchar(255) NULL,
EmisorNombre Varchar(255) NULL,
EmisorRegimenFiscal Varchar(255) NULL,
ReceptorRFC Varchar(255) NULL,
ReceptorNombre Varchar(255) NULL,
ReceptorRegimenFiscal Varchar(255) NULL,
Impuesto Varchar(255) NULL,
TipoFactor Varchar(255) NULL,
TasaOCuota money NULL,
Importe money NULL,
Estatus Varchar(255) NULL,
Observaciones Varchar(255) NULL,
UUID uniqueidentifier NULL
)

GO

if Object_ID('mk_archivoxmlDetalle','U') is null --	drop table mk_archivoxmlDetalle
create table mk_archivoxmlDetalle 
(
id int identity,
IdCab int NULL,
ClaveProdServ  Varchar(255) NULL,
Cantidad  money NULL,
ClaveUnidad  Varchar(255) NULL,
Unidad  Varchar(255) NULL,
Descripcion  Varchar(255) NULL,
ValorUnitario money NULL,
ArtImporte money NULL,
Base money NULL,
Impuesto Varchar(255) NULL,
TipoFactor Varchar(255) NULL,
TasaOCuota money NULL,
Importe money NULL,

)

GO

if Object_ID('mk_mapeoxml','U') is null -- drop table mk_mapeoxml
create table mk_mapeoxml
(
id int identity,
Proveedor  Varchar(255) NULL,
Modulo  Varchar(255) NULL,
Concepto  Varchar(255) NULL,
ClaveProdServ  Varchar(255) NULL,
ClaveUnidad   Varchar(255) NULL,
UltimaDes   Varchar(255) NULL,
Estatus   Varchar(20) NULL,
Usuario Varchar(20) NULL,
Fmodificacion datetime NULL

constraint proserv Unique (Proveedor,ClaveProdServ), 
)




/*

drop table mk_archivoxml
drop table mk_archivoxmlEncabezado
drop table mk_archivoxmlDetalle
drop table mk_mapeoxml

truncate table mk_archivoxml
truncate table mk_archivoxmlEncabezado
truncate table mk_archivoxmlDetalle
truncate table mk_mapeoxml

select * from mk_archivoxml order by id desc
select * from mk_archivoxmlEncabezado order by idmov desc
select * from mk_archivoxmlDetalle order by idCab desc
select * from mk_mapeoxml


*/



