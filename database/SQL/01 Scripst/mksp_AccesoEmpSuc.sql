/* Configuracion MS SQL Server */
SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1371358132
SET QUOTED_IDENTIFIER OFF
GO    

/****** mksp_AccesoEmpSuc ******/
IF OBJECT_ID('dbo.mksp_AccesoEmpSuc','P') IS NOT NULL  DROP PROC dbo.mksp_AccesoEmpSuc
GO  
CREATE PROCEDURE mksp_AccesoEmpSuc (
@Usuario varchar(10),
@Empresa varchar(5),
@Sucursal int
)
AS
BEGIN

	if not exists (Select * from UsuarioD where Usuario=@Usuario and Empresa=@Empresa ) AND
	Exists (Select * from Empresa where Empresa=@Empresa)
	INSERT INTO UsuarioD  (Usuario, Empresa) VALUES  (@Usuario, @Empresa)

	if not exists (Select * from UsuarioSucursalAcceso where Usuario=@Usuario and Sucursal=@Sucursal ) AND
	Exists (Select * from Sucursal where Sucursal=@Sucursal)
	INSERT INTO UsuarioSucursalAcceso (Usuario, Sucursal) VALUES  (@Usuario, @Sucursal)

	Select 1 as 'OK', 'El Acceso se dio correctamente' as 'OKRef'
END

GO

/*
exec mksp_AccesoEmpSuc 'JNEGRETE','ARC14','10'

SElect * from usuario
select * from Empresa
select * from Sucursal
Select * from UsuarioD
Select * from UsuarioSucursalAcceso
*/
--	EXEC mksp_EmpresaNueva 'TQART','TaqueArte S.A. de C.V.',NULL,'Persona Fisica','DEMO'
--	EXEC mksp_SucursalNueva 10,'ALVARO OBREGON',NULL,'DEMO'
