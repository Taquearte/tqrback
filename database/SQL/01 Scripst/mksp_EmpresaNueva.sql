
SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_EmpresaNueva','P') is not null drop proc mksp_EmpresaNueva
GO
CREATE PROCEDURE mksp_EmpresaNueva
@Empresa varchar(5),
@Nombre varchar(100),
@RFC varchar(15),
@FiscalRegimen varchar(30),
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


	SELECT @Empresa=LTRIM(RTRIM(@Empresa)),@Nombre=LTRIM(RTRIM(@Nombre)),@FiscalRegimen=LTRIM(RTRIM(@FiscalRegimen)),
	@RFC=LTRIM(RTRIM(@RFC))

	IF @OK=1 and  LEN(ISNULL(@Empresa,''))=0
		SELECT @OK=0,@OKRef='La empresa es un dato obligatorio'

	IF  @OK=1 and LEN(ISNULL(@FiscalRegimen,''))=0
		SELECT @OK=0,@OKRef='El Regimen Fiscal es un dato obligatorio'
					
	IF @OK=1 and LEN(ISNULL(@Nombre,''))=0
		SELECT @OK=0,@OKRef='El Nombre es un dato obligatorio'


	If @OK=1 and len(isnull(@RFC,''))=0 
		SET @RFC =@RFCGenerico


	IF @OK=1 and LEN(ISNULL(@RFC,''))=0
		SELECT @OK=0,@OKRef='El RFC es un dato obligatorio'

	if @OK=1 AND EXISTS (SELECT * FROM Empresa WHERE RFC = @RFC and RFC <> @RFCGenerico) 
		Select @OK=0,@OKRef='El RFC del usuario ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Empresa WHERE Nombre=@Nombre )
		Select @OK=0,@OKRef='El Nombre ya se encuentra en nuestra base de datos'

	if @OK=1
		INSERT INTO Empresa (Empresa, Nombre, Pais, RFC, Estatus, UltimoCambio, Alta, FiscalRegimen)
		VALUES (@Empresa, @Nombre, 'Mexico', @RFC, @Estatus, @hoyhh, @hoyhh, @FiscalRegimen)


		

	If @OK=1
	BEGIN
		SET @OKRef='La empresa se dio de alta correctamente'
		SELECT @OK as OK, @OKRef as OKRef 
	END
	ELSE
		SELECT @OK as OK, @OKRef as OKRef

END
GO
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'ARC14','ADMINISTRADORA DE RESTAURANTES CAF S.A','ARC141219AD2','Persona Moral','DEMO'

--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'
--	EXEC mksp_EmpresaNueva 'AAA12','ADMINISTRADORA DE ALIMENTOS APPLE AND PEAR SA DE CV','AAA120510CT1','Persona Moral','DEMO'







