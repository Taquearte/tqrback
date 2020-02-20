SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_UserNuevoPortal','P') is not null drop proc mksp_UserNuevoPortal
GO
CREATE PROCEDURE mksp_UserNuevoPortal
@uRazonSocial  varchar(100),
@RFC varchar(15),
@PerfilWeb Varchar(15),
@PaswordWeb Varchar(15),
@Clave  Varchar(10),
@PORTALProv varchar(15) output,
@OK int output,
@OkRef varchar(255) output

as
begin
	DECLARE 
	@Tipo varchar(15)='Usuario',
	@RFCGenerico varchar(15)='XEXX010101000',
	@Estatus varchar(15)='ALTA',
	@hoyhh datetime = getdate(),
	@hoy date =getdate(),
	@Moneda varchar(10)='Pesos',
	@CveUser varchar(10),
	@mkOK int=1,
	
	@Nombre varchar(100),
	@NombreCorto varchar(20)

	SELECT @RFC=LTRIM(RTRIM(@RFC)),	@uRazonSocial=LTRIM(RTRIM(@uRazonSocial))

	if not exists (select * from Prov where RFC=@RFC)
	BEGIN
		if @Clave IS NULL
		BEgin
			CREATE TABLE #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
			INSERT INTO #PasoConsecutivo
			EXEC spVerConsecutivo 'user', 0
			SELECT @CveUser=F1 from #PasoConsecutivo where ID=1
		END
		ELSE
			SELECT @CveUser=@Clave
	
		IF @mkOK=1 and LEN(ISNULL(@RFC,''))=0
			SELECT @mkOK=0,@OKRef='El RFC es un dato obligatorio'

		if @mkOK=1 and len(isnull(@uRazonSocial,''))=0
			Select @mkOK=0,@OKRef='El Nombre del usuario es un dato obligatorio'

		if @mkOK=1 
		BEGIN

			--select * from usuario where usuario<>'DEMO'
			--Select * from Prov where Proveedor in (select Usuario from usuario where usuario<>'DEMO')
			
			--Delete Prov where Proveedor in (select Usuario from usuario where usuario<>'DEMO')
			--Delete usuario where usuario<>'DEMO'
			select @CveUser
			INSERT INTO Usuario
			(Usuario, Nombre, Sucursal, GrupoTrabajo, Departamento, Contrasena, ContrasenaConfirmacion,  Telefono, DefMoneda, Afectar, Cancelar, ModificarSituacion, EnviarExcel, ImprimirMovs, PreliminarMovs, Reservar, DesReservar, Asignar, DesAsignar, Estatus, 
			UltimoCambio, Alta, eMail, Observaciones, Menu, Licenciamiento,RFC,PerfilWeb,PaswordWeb, Costos )
			VALUES (@CveUser, @Nombre, 0, 'MKSD', 'SISTEMAS', '0633971b5e442cd51b8e0a972d74f054', '0633971b5e442cd51b8e0a972d74f054',  '5557575757', 'Pesos', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,@Estatus, @hoyhh, @hoyhh, 'info@correo.com', '', '(Clasico)', 
			'(Total)',@RFC,@PerfilWeb,@PaswordWeb,1 )

			INSERT INTO Prov
				(Proveedor, Nombre,NombreCorto, Tipo,  RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, 
				CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos,Observaciones)
			VALUES (@CveUser, @Nombre,'', 'Proveedor',  @RFC, @Estatus, @hoy, @hoyhh, 0, 'Pesos', 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0,'')
		
			select @OK=@mkOK,@PORTALProv=@CveUser

		END
	END
	ELSE
		select @PORTALProv=Proveedor from prov where RFC=@RFC

END
GO