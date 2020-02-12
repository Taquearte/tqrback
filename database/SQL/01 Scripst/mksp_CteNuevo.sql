SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_CteNuevo','P') is not null drop proc mksp_CteNuevo
GO
CREATE PROCEDURE mksp_CteNuevo
@Nombre varchar(100),
@NombreCorto varchar(20),
@RFC varchar(15),
@Usuario varchar(10),
@Observaciones varchar(100),
@CveCteOtra  varchar(10),
@OK int Output,
@OKRef varchar(255) Output
as
begin
	DECLARE 
	@Tipo varchar(15)='Cliente',
	@RFCGenerico varchar(15)='XEXX010101000',
	@Estatus varchar(15)='ALTA',
	@hoyhh datetime = getdate(),
	@hoy date =getdate(),
	@Moneda varchar(10)='Pesos',
	@CveCte varchar(10)

		SET @OK =1

	SELECT @Nombre=LTRIM(RTRIM(@Nombre)),@NombreCorto=LTRIM(RTRIM(@NombreCorto)) ,@RFC=LTRIM(RTRIM(@RFC)),@Observaciones=LTRIM(RTRIM(@Observaciones)),@CveCteOtra=LTRIM(RTRIM(@CveCteOtra))
	

	If len(isnull(@RFC,''))=0 
		SET @RFC =@RFCGenerico

	IF len(isnull(@CveCteOtra,''))=0
	BEGIN
		CREATE TABLE #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
		INSERT INTO #PasoConsecutivo
		EXEC spVerConsecutivo 'cte', 0
		SELECT @CveCte=F1 from #PasoConsecutivo where ID=1
	END
	ELSE
		SET @CveCte=@CveCteOtra


	IF LEN(ISNULL(@RFC,''))=0
	SELECT @OK=0,@OKRef='El RFC es un dato obligatorio'

	if @OK=1 and len(isnull(@CveCte,''))=0
	Select @OK=0,@OKRef='La clave del cliente no se genero correctamente'

	if @OK=1 and len(isnull(@Nombre,''))=0
	Select @OK=0,@OKRef='El Nombre del cliente es un dato obligatorio'

	if @OK=1 AND EXISTS (SELECT * FROM Cte WHERE RFC = @RFC and RFC <> @RFCGenerico) 
	Select @OK=0,@OKRef='El RFC ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Cte WHERE Nombre=@Nombre )
	Select @OK=0,@OKRef='El Nombre ya se encuentra en nuestra base de datos'

	if @OK=1
	INSERT INTO Cte
				 (Cliente, Nombre, NombreCorto, Tipo, Direccion, DireccionNumero, DireccionNumeroInt, EntreCalles, Observaciones, Delegacion, Colonia, CodigoPostal, Poblacion, Estado, RFC, Telefonos, TelefonosLada, Contacto1, Contacto2, eMail1, eMail2, Categoria, Familia, Credito, Estatus, 
				 UltimoCambio, Alta, DefMoneda, CreditoMoneda, ChecarCredito, BloquearMorosos, ModificarVencimiento, RecorrerVencimiento, BonificacionTipo, DeducibleMoneda, Usuario, Comentarios)
	VALUES (@CveCte, @Nombre, @NombreCorto, @Tipo, NULL, NULL, NULL, NULL, @Observaciones,NULL, NULL, NULL, NULL, NULL, @RFC, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @Estatus, @hoyhh, @hoy, @Moneda, @Moneda, '(Empresa)', '(Empresa)', '(Empresa)', 
				 '(Empresa)', 'No', @Moneda, @Usuario, '')

	If @OK=1
	BEGIN
		SET @OKRef='El Cliente se dio de alta correctamente'
		--SELECT @OK as OK, @OKRef as OKRef 
	END
	--ELSE
		--SELECT @OK as OK, @OKRef as OKRef

END
GO
--EXEC mksp_CteNuevo 'LUCILA URIBE PEREZ','LURIBE',NULL,'DEMO','PORTAL 2020','USE12'




----SET @OK=1
--TRUNCATE TABLE #PasoConsecutivo
--INSERT INTO #PasoConsecutivo
--EXEC spVerConsecutivo 'Prov', 0
--select @CveProv=F1 from #PasoConsecutivo where ID=1
---- select @CveProv
--INSERT INTO Prov
--	(Proveedor, Nombre, Tipo, PedirTono, RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, 
--	CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos)
--VALUES (@CveProv, @bEmisorNombre, 'Proveedor', 0, @bEmisorRFC, 'ALTA', @hoy, @hoy, 0, @moneda, 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0)


--sp_helptext mk_spGeneraGasto




--Select * from Usuario
--select * from cte
--Select * from Prov where Tipo='Proveedor'



--INSERT INTO Consecutivo
--  (Tipo, Nivel, Prefijo, Consecutivo, TieneControl, Concurrencia)

--VALUES
--  ('cte', 'Global', 'CTE', 100, 0, 'Normal')