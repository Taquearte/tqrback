SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_ProvNuevo','P') is not null drop proc mksp_ProvNuevo
GO
CREATE PROCEDURE mksp_ProvNuevo
@Nombre varchar(100),
@NombreCorto varchar(20),
@RFC varchar(15),
@Usuario varchar(10),
@Observaciones varchar(100),
@CveProvOtra  varchar(10),
@OK int Output,
@OKRef varchar(255) Output
as
begin
	DECLARE 
	@Tipo varchar(15)='Proveedor',
	@RFCGenerico varchar(15)='XEXX010101000',
	@Estatus varchar(15)='ALTA',
	@hoyhh datetime = getdate(),
	@hoy date =getdate(),
	@Moneda varchar(10)='Pesos',
	@CveProv varchar(10)
	--@OK int=1,
	--@OKRef varchar(255)
	SET @OK =1

	SELECT @Nombre=LTRIM(RTRIM(@Nombre)),@NombreCorto=LTRIM(RTRIM(@NombreCorto)) ,@RFC=LTRIM(RTRIM(@RFC)),
	@Observaciones=LTRIM(RTRIM(@Observaciones)),@CveProvOtra=LTRIM(RTRIM(@CveProvOtra))
	

	If len(isnull(@RFC,''))=0 
		SET @RFC =@RFCGenerico

	IF len(isnull(@CveProvOtra,''))=0
	BEGIN
		CREATE TABLE #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
		INSERT INTO #PasoConsecutivo
		EXEC spVerConsecutivo 'cte', 0
		SELECT @CveProv=F1 from #PasoConsecutivo where ID=1
	END
	ELSE
		SET @CveProv=@CveProvOtra


	IF LEN(ISNULL(@RFC,''))=0
	SELECT @OK=0,@OKRef='El RFC es un dato obligatorio'

	if @OK=1 and len(isnull(@CveProv,''))=0
	Select @OK=0,@OKRef='La clave del proveedor no se genero correctamente'

	if @OK=1 and len(isnull(@Nombre,''))=0
	Select @OK=0,@OKRef='El Nombre del proveedor es un dato obligatorio'

	if @OK=1 AND EXISTS (SELECT * FROM Prov WHERE RFC = @RFC and RFC <> @RFCGenerico) 
	Select @OK=0,@OKRef='El RFC del proveedor ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Prov WHERE Nombre=@Nombre )
	Select @OK=0,@OKRef='El Nombre ya se encuentra en nuestra base de datos'

	if @OK=1
		INSERT INTO Prov
			(Proveedor, Nombre,NombreCorto, Tipo,  RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, 
			CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos,Observaciones)
		VALUES (@CveProv, @Nombre,@NombreCorto, @Tipo,  @RFC, @Estatus, @hoy, @hoyhh, 0, @moneda, 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0,@Observaciones)


	If @OK=1
	BEGIN
		SET @OKRef='El Proveedor se dio de alta correctamente'
		--SELECT @OK as OK, @OKRef as OKRef 
	END
	--ELSE
		--SELECT @OK as OK, @OKRef as OKRef

END
GO
--EXEC mksp_ProvNuevo 'LUCILA URIBE PEREZ','LURIBE',NULL,'DEMO','PORTAL 2020',NULL





