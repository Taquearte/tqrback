
SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_SucursalNueva','P') is not null drop proc mksp_SucursalNueva
GO
CREATE PROCEDURE mksp_SucursalNueva
@Sucursal Int,
@Nombre varchar(100),
@RFC varchar(15),
@Usuario varchar(10)

as
begin
	DECLARE 
	@RFCGenerico varchar(15)='XEXX010101000',
	@Estatus varchar(15)='ALTA',
	@hoyhh datetime = getdate(),
	@hoy date =getdate(),
	@OK int=1,
	@OKRef varchar(255)


	SELECT @Nombre=LTRIM(RTRIM(@Nombre)),	@RFC=LTRIM(RTRIM(@RFC))

	IF @OK=1 and  ISNULL(@Sucursal,-1)=-1
		SELECT @OK=0,@OKRef='La sucursal es un dato obligatorio'

					
	IF @OK=1 and LEN(ISNULL(@Nombre,''))=0
		SELECT @OK=0,@OKRef='El Nombre es un dato obligatorio'


	If @OK=1 and len(isnull(@RFC,''))=0 
		SET @RFC =@RFCGenerico


	IF @OK=1 and LEN(ISNULL(@RFC,''))=0
		SELECT @OK=0,@OKRef='El RFC es un dato obligatorio'

	if @OK=1 AND EXISTS (SELECT * FROM Sucursal WHERE RFC = @RFC and RFC <> @RFCGenerico) 
		Select @OK=0,@OKRef='El RFC del usuario ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Sucursal WHERE Nombre=@Nombre )
		Select @OK=0,@OKRef='El Nombre ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Sucursal WHERE Sucursal=@Sucursal )
		Select @OK=0,@OKRef='La Sucursal ya se encuentra en nuestra base de datos'

	if @OK=1
	INSERT INTO Sucursal
				 (Sucursal, Nombre, Prefijo, Relacion, Pais, RFC, Estatus, UltimoCambio)
	VALUES (@Sucursal, @Nombre, 'S'+LTRIM(RTRIM(Convert(varchar(3),@Sucursal))), 'n/a', 'Mexico', @RFC, @Estatus, @hoyhh)


		

	If @OK=1
	BEGIN
		SET @OKRef='La Sucursal se dio de alta correctamente'
		SELECT @OK as OK, @OKRef as OKRef 
	END
	ELSE
		SELECT @OK as OK, @OKRef as OKRef

END
GO
-- EXEC mksp_SucursalNueva 10,'ALVARO OBREGON',NULL,'DEMO'


--

