SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_UserNuevo','P') is not null drop proc mksp_UserNuevo
GO
CREATE PROCEDURE mksp_UserNuevo
@uNombre varchar(33),
@uPaterno varchar(33),
@uMaterno varchar(33),
@RFC varchar(15),
@Usuario varchar(10),
@Observaciones varchar(100),
@CveUserOtra  varchar(10),
@PerfilWeb Varchar(15),
@PaswordWeb Varchar(15)

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
	@OK int=1,
	@OKRef varchar(255),
	@Nombre varchar(100),
	@NombreCorto varchar(20)


	create table #pasoUser (OK int NULL, OKRef varchar(255))

	SELECT @uNombre=LTRIM(RTRIM(@uNombre)),@uPaterno=LTRIM(RTRIM(@uPaterno)),@uMaterno=LTRIM(RTRIM(@uMaterno)),
	@NombreCorto=LTRIM(RTRIM(@NombreCorto)) ,@RFC=LTRIM(RTRIM(@RFC)),
	@Observaciones=LTRIM(RTRIM(@Observaciones)),@CveUserOtra=LTRIM(RTRIM(@CveUserOtra))

	IF LEN(ISNULL(@PerfilWeb,''))=0
		SELECT @OK=0,@OKRef='El Perfil del usuario es un dato obligatorio'

	IF LEN(ISNULL(@PaswordWeb,''))=0
		SELECT @OK=0,@OKRef='El Nombre es un dato obligatorio'
					
	IF LEN(ISNULL(@uNombre,''))=0
		SELECT @OK=0,@OKRef='El Nombre es un dato obligatorio'

	IF @OK=1 and LEN(ISNULL(@uPaterno,''))=0
		SELECT @OK=0,@OKRef='El apellido paterno es un dato obligatorio'

	IF @OK=1 
		Select @Nombre=@uNombre+' '+@uPaterno+' '+isnull(@uMaterno,'')



	If @OK=1 and len(isnull(@RFC,''))=0 
		SET @RFC =@RFCGenerico

	IF @OK=1 and len(isnull(@CveUserOtra,''))=0
	BEGIN
		CREATE TABLE #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
		INSERT INTO #PasoConsecutivo
		EXEC spVerConsecutivo 'user', 0
		SELECT @CveUser=F1 from #PasoConsecutivo where ID=1
	END
	ELSE
		SET @CveUser=@CveUserOtra


	IF @OK=1 and LEN(ISNULL(@RFC,''))=0
		SELECT @OK=0,@OKRef='El RFC es un dato obligatorio'

	if @OK=1 and len(isnull(@CveUser,''))=0
		Select @OK=0,@OKRef='La clave del usuario no se genero correctamente'

	if @OK=1 and len(isnull(@Nombre,''))=0
		Select @OK=0,@OKRef='El Nombre del usuario es un dato obligatorio'

	if @OK=1 AND EXISTS (SELECT * FROM Usuario WHERE RFC = @RFC and RFC <> @RFCGenerico) 
		Select @OK=0,@OKRef='El RFC del usuario ya se encuentra en nuestra base de datos'

	if @OK=1 AND not EXISTS (SELECT * FROM Usuario WHERE Usuario=@Usuario )
		Select @OK=0,@OKRef='El usuario No se encuentra en la base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Usuario WHERE Usuario=@CveUser )
		Select @OK=0,@OKRef='El usuario ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM Usuario WHERE Nombre=@Nombre )
		Select @OK=0,@OKRef='El Nombre ya se encuentra en nuestra base de datos'

	if @OK=1
	BEGIN
		INSERT INTO Usuario
		(Usuario, Nombre, Sucursal, GrupoTrabajo, Departamento, Contrasena, ContrasenaConfirmacion,  Telefono, DefMoneda, Afectar, Cancelar, ModificarSituacion, EnviarExcel, ImprimirMovs, PreliminarMovs, Reservar, DesReservar, Asignar, DesAsignar, Estatus, 
		UltimoCambio, Alta, eMail, Observaciones, Menu, Licenciamiento,uNombre,uPaterno,uMaterno,RFC,PerfilWeb,PaswordWeb, Costos )
		VALUES (@CveUser, @Nombre, 0, 'MKSD', 'SISTEMAS', '0633971b5e442cd51b8e0a972d74f054', '0633971b5e442cd51b8e0a972d74f054',  '5557575757', 'Pesos', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,@Estatus, @hoyhh, @hoyhh, 'info@correo.com', @Observaciones, '(Clasico)', 
		'(Total)',@uNombre,@uPaterno,@uMaterno,@RFC,@PerfilWeb,@PaswordWeb,1 )

		EXEC mksp_CteNuevo  @Nombre,'',@RFC,@Usuario,@Observaciones,@CveUser,@OK output,@OKRef output
		EXEC mksp_ProvNuevo @Nombre,'',@RFC,@Usuario,@Observaciones,@CveUser,@OK output,@OKRef output

	END
	

	If @OK=1
	BEGIN
		SET @OKRef='El Usuario se dio de alta correctamente'
		SELECT @OK as OK, @OKRef as OKRef 
	END
	ELSE
		SELECT @OK as OK, @OKRef as OKRef

END
GO
-- EXEC mksp_UserNuevo 'Hector','Rosales','Ortiz','XEXX010101000','DEMO','PORTAL 2020','HROSALES','ADMIN','mexico'
-- EXEC mksp_UserNuevo 'Mick','Jagger',NULL,'XEXX010101000','DEMO','PORTAL 2020','MJAGGER','ADMIN','mexico'
-- EXEC mksp_UserNuevo 'Kurt','Cobain',NULL,'XEXX010101000','DEMO','PORTAL 2020','KCOBAIN','ADMIN','mexico'
-- EXEC mksp_UserNuevo 'Elizabeth','Armendariz',NULL,'XEXX010101000','DEMO','PORTAL 2020','ARMELY','ADMIN','mexico'

-- EXEC mksp_UserNuevo 'Arturo','Tapia',NULL,'XEXX010101000','DEMO','PORTAL 2020','ATAPIA','MEDIUM','mexico'
-- EXEC mksp_UserNuevo 'Fernando','Gomez',NULL,'XEXX010101000','DEMO','PORTAL 2020','FGOMEZ','MEDIUM','mexico'

-- EXEC mksp_UserNuevo 'Pedro','Infante',NULL,'XEXX010101000','DEMO','PORTAL 2020','PINFANTE','USER','mexico'
-- EXEC mksp_UserNuevo 'Jorge','Negrete',NULL,'XEXX010101000','DEMO','PORTAL 2020','JNEGRETE','USER','mexico'


--exec mksp_AccesoEmpSuc 'ARMELY','ARC14','10'

--SElect * from usuario
--select * from Empresa
--select * from Sucursal
--ARC14,10

/*

declare @user varchar(10)
set @user='PINFANTE'
select * from usuario where usuario=@user
select * from cte where cliente=@user
select * from prov where proveedor=@user


declare @user varchar(10)
set @user='KCOBAIN'
DELETE usuario where usuario=@user
DELETE cte where cliente=@user
DELETE prov where proveedor=@user


INSERT INTO UsuarioD  (Usuario, Empresa) VALUES  ('HMENDEZ', 'IMP')
INSERT INTO UsuarioSucursalAcceso (Usuario, Sucursal) VALUES  ('HMENDEZ', 0)
INSERT INTO UsuarioSucursalAcceso (Usuario, Sucursal) VALUES ('DEMO', 1)



UPDATE Usuario
SET
  Usuario = 'HMENDEZ',
  Nombre = 'Heliodoro MEndez',
  Sucursal = NULL,
  GrupoTrabajo = 'INTELISIS',
  Departamento = 'AUDITORIA',
  Contrasena = '0633971b5e442cd51b8e0a972d74f054',
  ContrasenaConfirmacion = '0633971b5e442cd51b8e0a972d74f054',
  ContrasenaFecha = '26/01/2020 18:52:20',
  ContrasenaModificar = 0,
  Telefono = '5557575757',
  Extencion = NULL,
  DefAgente = NULL,
  DefCajero = NULL,
  DefAlmacen = 'A001',
  DefAlmacenTrans = NULL,
  DefCtaDinero = NULL,
  DefCtaDineroTrans = NULL,
  DefMoneda = 'Pesos',
  DefLocalidad = NULL,
  DefProyecto = NULL,
  DefCliente = NULL,
  DefActividad = NULL,
  DefMovVentas = NULL,
  Afectar = 1,
  Cancelar = 1,
  Desafectar = 0,
  Autorizar = 0,
  AfectarOtrosMovs = 1,
  CancelarOtrosMovs = 1,
  ConsultarOtrosMovs = 1,
  ConsultarOtrosMovsGrupo = 0,
  ConsultarOtrasEmpresas = 0,
  ConsultarOtrasSucursales = 1,
  AccesarOtrasSucursalesEnLinea = 0,
  AfectarOtrasSucursalesEnLinea = 1,
  ModificarOtrosMovs = 1,
  ModificarVencimientos = 0,
  ModificarEntregas = 0,
  ModificarFechaRequerida = 0,
  ModificarEnvios = 0,
  ModificarReferencias = 0,
  ModificarAlmacenEntregas = 0,
  ModificarSituacion = 1,
  ModificarAgente = 0,
  ModificarUsuario = 0,
  ModificarSucursalDestino = 0,
  AgregarCteExpress = 0,
  AgregarArtExpress = 0,
  VerInfoDeudores = 0,
  VerInfoAcreedores = 0,
  VerComisionesPendientes = 0,
  Costos = 0,
  BloquearCostos = 0,
  EnviarExcel = 1,
  ImprimirMovs = 1,
  PreliminarMovs = 1,
  Reservar = 1,
  DesReservar = 1,
  Asignar = 1,
  DesAsignar = 1,
  ModificarAlmacenPedidos = 0,
  ModificarConceptos = 0,
  ModificarListaPrecios = 0,
  ModificarZonaImpuesto = 0,
  Oficina = NULL,
  Estatus = 'ALTA',
  UltimoCambio = '26/01/2020 18:57:04',
  Alta = '26/01/2020 18:50:55',
  BloquearEncabezadoVenta = 0,
  BloquearCxpCtaDinero = 0,
  BloquearCxcCtaDinero = 0,
  BloquearDineroCtaDinero = 0,
  BloquearCondiciones = 0,
  BloquearMoneda = 0,
  BloquearAlmacen = 0,
  BloquearAgente = 0,
  BloquearProyecto = 0,
  BloquearFechaEmision = 0,
  BloquearPrecios = 0,
  BloquearDescGlobal = 0,
  BloquearDescLinea = 0,
  BloquearNotasNegativas = 0,
  Configuracion = NULL,
  DefUnidad = NULL,
  DefArtTipo = NULL,
  AbrirCajon = 0,
  TieneMovimientos = 0,
  BloquearCobroInmediato = 0,
  ConsultarCompraPendiente = 1,
  Refacturar = 0,
  DefListaPreciosEsp = NULL,
  LimiteTableroControl = NULL,
  CteInfo = 1,
  ImpresionInmediata = 0,
  CambioValidarCobertura = 0,
  AccesoTotalCuentas = 0,
  CambioNormatividad = 0,
  CambioEditarCobertura = 0,
  AutorizarVenta = 0,
  AutorizarCompra = 0,
  AutorizarCxp = 0,
  AutorizarGasto = 0,
  AutorizarDinero = 0,
  AutorizarPV = 0,
  AutorizarGestion = 0,
  AutorizarSeriesLotes = 0,
  MostrarCampos = 1,
  AsistentePrecios = 0,
  Acceso = NULL,
  CambioVerPosicionEmpresa = 1,
  CambioVerPosicionSucursal = 1,
  CambioVerPosicionOtraSucursal = 1,
  AutoDobleCapturaPrecios = 1,
  AutoArtGrupo = NULL,
  BloquearActividad = 0,
  CteBloquearOtrosDatos = 0,
  CteSucursalVenta = 0,
  ArtBloquearOtrosDatos = 0,
  UEN = NULL,
  eMail = 'info@correo.com',
  CteMov = 0,
  CteArt = 0,
  ProvMov = 0,
  ArtMov = 0,
  DefContUso = NULL,
  BloquearContUso = 0,
  ModificarReferenciasSiempre = 0,
  ModificarProyUENActCC = 0,
  Observaciones = 'Obser',
  TraspasarTodo = 0,
  AutoAgregarRecaudacionConsumo = 0,
  AutoDiesel = 0,
  ModificarAgenteCxcPendiente = 0,
  ModificarSerieLoteProp = 0,
  NominaEliminacionParcial = 0,
  CtaDineroInfo = 1,
  DefZonaImpuesto = NULL,
  DefFormaPago = NULL,
  BloquearFormaPago = 0,
  PVAbrirCajonSiempre = 0,
  PVBloquearEgresos = 0,
  ModificarPropiedadesLotes = 0,
  PVCobrarNotasEstatusBorrador = 0,
  PVModificarEstatusBorrador = 0,
  BloquearPersonalCfg = 0,
  ModificarMovsNominaVigentes = 0,
  BloquearFacturacionDirecta = 0,
  Idioma = NULL,
  ModificarDatosVIN = 0,
  ModificarDatosCliente = 0,
  CxcExpress = 0,
  CxpExpress = 0,
  SubModuloAtencion = NULL,
  BloquearCancelarFactura = 0,
  CambioPresentacionExpress = 0,
  ModificarConsecutivos = 0,
  ModificarVINFechaBaja = 0,
  ModificarVINFechaPago = 0,
  ModificarVINAccesorio = 0,
  PVEditarNota = 1,
  ModificarDescGlobalImporte = 0,
  ConsultarClientesOtrosAgentes = 1,
  ACLCUsoEspecifico = NULL,
  ACEditarTablaAmortizacion = 0,
  CambioAutorizarOperacionLimite = 0,
  PlantillasOffice = 1,
  ConfigPlantillasOffice = 0,
  ACTasaGrupo = NULL,
  CambioAgregarBeneficiarios = 1,
  AgregarConceptoExpress = 0,
  BloquearArtMaterial = 0,
  InfoPath = 0,
  InfoPathExe = 'C:\Archivos de programa\Microsoft Office\OFFICE11\INFOPATH.EXE',
  FEA = 0,
  FEACertificado = NULL,
  FEALlave = NULL,
  ContrasenaNuncaExpira = 0,
  AgregarProvExpress = 0,
  Menu = '(Clasico)',
  BloquearPDF = 0,
  VerificarOrtografia = 0,
  ContSinOrigen = 0,
  UnidadOrganizacional = NULL,
  ProyMov = 0,
  CompraDevTodo = 0,
  ProyectoMov = 0,
  BloquearWebContenido = 0,
  BloquearWebHTML = 0,
  DBMailPerfil = NULL,
  UltimoAcceso = NULL,
  InformacionConfidencial = 0,
  BloquearSituacionUsuario = 0,
  BloquearInvSalidaDirecta = 0,
  PerfilForma = NULL,
  Licenciamiento = '(Total)',
  SituacionArea = NULL,
  ModificarTipoImpuesto = 0,
  BloquearTipoCambio = 0,
  INFORSupervisor = 0,
  ReferenciaIntelisisService = NULL,
  INFORPerfil = NULL,
  ISMESNotificarError = 0,
  Personal = NULL,
  AfectarCORTE = 0,
  ModificarPosicionSugeridaWMS = 0,
  ModificarAgenteWMS = 0,
  POSPerfil = NULL,
  OPORTPlantilla = NULL
WHERE
  Usuario = 'HMENDEZ'






*/