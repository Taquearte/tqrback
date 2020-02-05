SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO


/**********************		dbo.mksp_acceso	***************************************/

if object_id('dbo.mksp_acceso','P') is not null drop procedure mksp_acceso
GO
create procedure dbo.mksp_acceso
@usuario varchar(20), 
@password varchar(20),
@empresa varchar(20), 
@sucursal varchar(20)
AS 
BEGIN

	DECLARE
	@ok int,
	@okref varchar(150),
	@empresaNom varchar(150), 
	@sucursalNom varchar(150),
	@TipoCambioDolar float

	
	IF not Exists (Select * from usuario where Usuario=@usuario)
	BEGIN
		SELECT @ok=1, @okref='El Usuario no se encuentra registrado'
	END
	
	IF @ok=0 and not Exists (Select * from usuario where Usuario=@usuario and PaswordWeb=@password)
	BEGIN
		SELECT @ok=1, @okref='El password es incorrecto'
	END

	IF @ok=0 and  @ok IS NULL AND NOT EXISTS (Select * from UsuarioD where Usuario=@usuario and Empresa=@empresa)
	BEGIN	
		SELECT @ok=1, @okref='El Usuario no tiene acceso a la empresa: '+@empresa
	END


	if  @ok=0 and  Exists (Select * from UsuarioSucursalAcceso where Usuario=@usuario)
	BEGIN
		if not Exists (Select * from UsuarioSucursalAcceso where Usuario=@usuario and Sucursal=@sucursal)
			SELECT @ok=1, @okref='El Usuario no tiene acceso a la sucursal: '+@sucursal
	END

	IF @ok=1
		SELECT @OK as OK,@OKRef as OKRef
	ELSE
	BEGIN
		select @TipoCambioDolar=TipoCambio from Mon where Moneda='DOLARES'
		select @TipoCambioDolar=isnull(@TipoCambioDolar,0)
		SELECT 0 as OK,'Correcto' as OKRef
		,u.Usuario,u.Nombre,u.DefAgente,u.DefCajero,u.DefAlmacen,u.DefCtaDinero,u.DefMoneda,u.DefProyecto,u.DefLocalidad,u.DefCliente,u.DefActividad,u.DefFormaPago,u.Afectar,u.eMail
		,e.Empresa,e.Nombre as EmpresaNombre
		,s.Sucursal,s.Nombre as SucursalNombre,eg.DefImpuesto, @TipoCambioDolar as TipoCambioDolar
		,u.PerfilWeb
		from usuario u
		join Empresa e on 1=1
		join Sucursal s on 1=1
		join EmpresaGral eg on e.Empresa=eg.Empresa
		where u.Usuario=@usuario
		and e.Empresa=@empresa
		and s.Sucursal=@sucursal
	END

end
GO
--	exec mksp_acceso 'DEMO','mexico','DEMO','0'

