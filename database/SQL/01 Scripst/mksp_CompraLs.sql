

/* Configuracion MS SQL Server */
SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1371358132
SET QUOTED_IDENTIFIER OFF
GO    



/****** mksp_GetMovlist ******/
IF OBJECT_ID('dbo.mksp_GetMovlist','P') IS NOT NULL  DROP PROC dbo.mksp_GetMovlist
GO  
CREATE PROCEDURE mksp_GetMovlist (
@Usuario varchar(10),
@Empresa varchar(5),
@Sucursal int,
@Modulo varchar(5)
)
AS
BEGIN
	if @Modulo='COMS'
		SELECT a.ID, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
		FROM   Compra a
		Join Prov b on a.Proveedor=b.Proveedor
		Where 1=1
		AND a.Proveedor=@Usuario
		ORDER by a.ID desc
	Else IF @Modulo='GAS'
		SELECT a.ID, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
		FROM   Compra a
		Join Prov b on a.Proveedor=b.Proveedor
		Where 1=1
		AND a.Proveedor=@Usuario
		ORDER by a.ID desc
END

GO
EXEC mksp_GetMovlist 'KCOBAIN','','','COMS'
GO
--select * from usuario

/****** mksp_GetMov ******/
IF OBJECT_ID('dbo.mksp_GetMov','P') IS NOT NULL  DROP PROC dbo.mksp_GetMov
GO  
CREATE PROCEDURE mksp_GetMov (
@ID int,
@Usuario varchar(10),
@Empresa varchar(5),
@Sucursal int,
@Cabecero bit,
@Modulo varchar(5)
)
AS
BEGIN

	if @Modulo='COMS'
	BEGIN

		if @Cabecero=1
			SELECT a.ID, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
			FROM   Compra a
			Join Prov b on a.Proveedor=b.Proveedor
			Where 1=1
			AND a.Proveedor=@Usuario
			and a.ID=@ID
		Else
			SELECT a.ID--, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
			,d.Articulo,c.Descripcion1,d.Cantidad,d.Costo,(d.Cantidad*d.Costo) as Subtotal, (d.Cantidad*d.Costo)*(d.Impuesto1/100.0) as Iva,
			((d.Cantidad*d.Costo))+((d.Cantidad*d.Costo)*(d.Impuesto1/100.0)) as Total
			FROM   Compra a
			LEFT JOIN Prov b on a.Proveedor=b.Proveedor
			LEFT JOIN CompraD d on a.id=d.ID
			LEFT JOIN Art c on d.Articulo=c.Articulo
			Where 1=1
			AND a.Proveedor=@Usuario
			and a.ID=@ID
	END
	ELSE IF  @Modulo='GAS'
	BEGIN

		if @Cabecero=1
			SELECT a.ID, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
			FROM   Compra a
			Join Prov b on a.Proveedor=b.Proveedor
			Where 1=1
			AND a.Proveedor=@Usuario
			and a.ID=@ID
		Else
			SELECT a.ID--, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
			,d.Articulo,c.Descripcion1,d.Cantidad,d.Costo,(d.Cantidad*d.Costo) as Subtotal, (d.Cantidad*d.Costo)*(d.Impuesto1/100.0) as Iva,
			((d.Cantidad*d.Costo))+((d.Cantidad*d.Costo)*(d.Impuesto1/100.0)) as Total
			FROM   Compra a
			LEFT JOIN Prov b on a.Proveedor=b.Proveedor
			LEFT JOIN CompraD d on a.id=d.ID
			LEFT JOIN Art c on d.Articulo=c.Articulo
			Where 1=1
			AND a.Proveedor=@Usuario
			and a.ID=@ID
	END

	
END

GO
EXEC mksp_GetMov 4,'KCOBAIN','','',1,'COMS'
GO
EXEC mksp_GetMov 4,'KCOBAIN','','',0,'COMS'
--select * from usuario












/****** mksp_CompraLs ******/
IF OBJECT_ID('dbo.mksp_CompraLs','P') IS NOT NULL  DROP PROC dbo.mksp_CompraLs
GO  
CREATE PROCEDURE mksp_CompraLs (
@Usuario varchar(10),
@Empresa varchar(5),
@Sucursal int
)
AS
BEGIN

	SELECT a.ID, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
	FROM   Compra a
	Join Prov b on a.Proveedor=b.Proveedor
	Where 1=1
	AND a.Proveedor=@Usuario
	ORDER by a.ID desc
	
END

GO
EXEC mksp_CompraLs 'KCOBAIN','',''
GO
--select * from usuario

/****** mksp_Compra ******/
IF OBJECT_ID('dbo.mksp_Compra','P') IS NOT NULL  DROP PROC dbo.mksp_Compra
GO  
CREATE PROCEDURE mksp_Compra (
@ID int,
@Usuario varchar(10),
@Empresa varchar(5),
@Sucursal int,
@Cabecero bit
)
AS
BEGIN
	if @Cabecero=1
		SELECT a.ID, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
		FROM   Compra a
		Join Prov b on a.Proveedor=b.Proveedor
		Where 1=1
		AND a.Proveedor=@Usuario
		and a.ID=@ID
	Else
		SELECT a.ID--, a.Empresa, a.Mov, a.MovID, a.FechaEmision, a.Concepto, a.Proyecto, a.Moneda, a.TipoCambio, a.Usuario, a.Referencia, a.Estatus, a.Proveedor,b.Nombre, a.Importe, a.Impuestos
		,d.Articulo,c.Descripcion1,d.Cantidad,d.Costo,(d.Cantidad*d.Costo) as Subtotal, (d.Cantidad*d.Costo)*(d.Impuesto1/100.0) as Iva,
		((d.Cantidad*d.Costo))+((d.Cantidad*d.Costo)*(d.Impuesto1/100.0)) as Total
		FROM   Compra a
		LEFT JOIN Prov b on a.Proveedor=b.Proveedor
		LEFT JOIN CompraD d on a.id=d.ID
		LEFT JOIN Art c on d.Articulo=c.Articulo
		Where 1=1
		AND a.Proveedor=@Usuario
		and a.ID=@ID
	
END

GO
EXEC mksp_Compra 4,'KCOBAIN','','',1
GO
EXEC mksp_Compra 4,'KCOBAIN','','',0
--select * from usuario