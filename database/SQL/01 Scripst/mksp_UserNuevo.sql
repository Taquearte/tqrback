SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_UserNuevo','P') is not null drop proc mksp_UserNuevo
GO
CREATE PROCEDURE mksp_UserNuevo
@uRazonSocial  varchar(100),
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
	@Observaciones=LTRIM(RTRIM(@Observaciones)),@CveUserOtra=LTRIM(RTRIM(@CveUserOtra)),
	@uRazonSocial=LTRIM(RTRIM(@uRazonSocial))

	IF LEN(ISNULL(@PerfilWeb,''))=0
		SELECT @OK=0,@OKRef='El Perfil del usuario es un dato obligatorio'

	IF LEN(ISNULL(@PaswordWeb,''))=0 
		SELECT @OK=0,@OKRef='El password es un dato obligatorio'
					
	IF LEN(ISNULL(@uNombre,''))=0 AND LEN(ISNULL(@uRazonSocial,''))=0
		SELECT @OK=0,@OKRef='El Nombre es un dato obligatorio'

	IF @OK=1 and LEN(ISNULL(@uPaterno,''))=0 AND LEN(ISNULL(@uRazonSocial,''))= 0
		SELECT @OK=0,@OKRef='El apellido paterno es un dato obligatorio'

	IF @OK=1 AND LEN(ISNULL(@uRazonSocial,''))= 0
		Select @Nombre=@uNombre+' '+@uPaterno+' '+isnull(@uMaterno,'')
	else 
		Select @Nombre= @uRazonSocial

		--select len(isnull(@RFC,''))
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
		--select @RFC
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


-- EXEC mksp_UserNuevo 'VIOLETA AIZA XX',NULL,NULL,NULL,'AIAV8411193XX','DEMO','PORTAL 2020','OLEXX','USER','Svtm@2029'
-- update usuario set Costos=1 
-- update usuario set Configuracion = 'DEMO',Acceso = 'DEMO' Where Usuario <>'DEMO' 

UPDATE Usuario
SET
  
  

/*

EXEC mksp_UserNuevo 'ABASTECEDORA FRES-FRUT SA DE CV',NULL,NULL,NULL, 'AFR170912FS6','DEMO','PORTAL 2020','FFRUT','USER','LpYsf@2019'
EXEC mksp_UserNuevo 'ADYERIN, S.A. DE C.V.',NULL,NULL,NULL,           'ADY101011IS1','DEMO','PORTAL 2020','ADYER','USER','Svtm@2019'
EXEC mksp_UserNuevo 'AGITADORA COMERCIAL, S.A. DEC.V.',NULL,NULL,NULL,'ACO1603033J5','DEMO','PORTAL 2020','TRAFI','USER','Nhlceh@2019'


EXEC mksp_UserNuevo 'Agroproductos de Alto Valor',NULL,NULL,NULL,'AAV160209M59','DEMO','PORTAL 2020','AZUCE','USER','Nhlceh@2020'
EXEC mksp_UserNuevo 'Alimentos BAAB',NULL,NULL,NULL,'ABA131030NV2','DEMO','PORTAL 2020','BAAB','USER','LpYsf@2024'
EXEC mksp_UserNuevo 'Campiña Mexicana',NULL,NULL,NULL,'CME020117U51','DEMO','PORTAL 2020','CPIMX','USER','LpYsf@2025'
EXEC mksp_UserNuevo 'CARNES PREMIUM XO, S.A. DE C.V.',NULL,NULL,NULL,'KAR100211115','DEMO','PORTAL 2020','XOCHI','USER','LpYsf@2020'
EXEC mksp_UserNuevo 'CERVECERIA MODELO DE MEXICO S DE RL DE CV',NULL,NULL,NULL,'AMH080702RMA','DEMO','PORTAL 2020','MODEL','USER','Svtm@2020'
EXEC mksp_UserNuevo 'Comercializadora BHLM',NULL,NULL,NULL,'CBH160604PI9','DEMO','PORTAL 2020','BHLM','USER','Nhlceh@2021'
EXEC mksp_UserNuevo 'Comercializadora Grumer',NULL,NULL,NULL,'CGR921112D27','DEMO','PORTAL 2020','GRUME','USER','Nhlceh@2026'
EXEC mksp_UserNuevo 'COMPAÑIA RESTAURANTERA MARIA CANDELARIA SA DE CV',NULL,NULL,NULL,'RMC9207279R2','DEMO','PORTAL 2020','CALLE','USER','Nhlceh@2020'
EXEC mksp_UserNuevo 'CRUJIENTE TRADICIÓN MEXICANA, SA DE CV',NULL,NULL,NULL,'CTM151022Q52','DEMO','PORTAL 2020','FRITU','USER','LpYsf@2021'
EXEC mksp_UserNuevo 'Cruz Martinez Meza',NULL,NULL,NULL,'MAMC7601302H6','DEMO','PORTAL 2020','MAMA','USER','LpYsf@2020'
EXEC mksp_UserNuevo 'Deep Services',NULL,NULL,NULL,'DSE1808308P1','DEMO','PORTAL 2020','DEEPS','USER','LpYsf@2022'

EXEC mksp_UserNuevo 'DELTA TIGER SA DE CV',NULL,NULL,NULL,'DTI081211J61','DEMO','PORTAL 2020','DELTA','USER','Nhlceh@2021'
EXEC mksp_UserNuevo 'Dinamica Alimenticia Profesional',NULL,NULL,NULL,'DAP031202U12','DEMO','PORTAL 2020','DAPSA','USER','Svtm@2026'

EXEC mksp_UserNuevo 'Distrib. Carnes Ideal',NULL,NULL,NULL,'DCI9802185I5','DEMO','PORTAL 2020','IDEAL','USER','LpYsf@2026'

EXEC mksp_UserNuevo 'Eduardo Sigales Vertti',NULL,NULL,NULL,'SIVE640405IS4','DEMO','PORTAL 2020','AGUIL','USER','Nhlceh@2023'
EXEC mksp_UserNuevo 'Envai Food Packaging',NULL,NULL,NULL,'EFP160312UM1','DEMO','PORTAL 2020','FOOD','USER','LpYsf@2023'
EXEC mksp_UserNuevo 'Felipe de Jesus Ramirez Juarez',NULL,NULL,NULL,'RAJF305012X7','DEMO','PORTAL 2020','FJRAM','USER','Svtm@2025'
EXEC mksp_UserNuevo 'FOOD SERVICE DE MEXICO, SA DE CV',NULL,NULL,NULL,'FSM960712789','DEMO','PORTAL 2020','NESPR','USER','Nhlceh@2022'
EXEC mksp_UserNuevo 'GARCOMEX SA DE CV',NULL,NULL,NULL,'GAR9110176E5','DEMO','PORTAL 2020','STAFE','USER','LpYsf@2023'
EXEC mksp_UserNuevo 'Guillermo Matus Bocanegra',NULL,NULL,NULL,'MABG7311063ZA','DEMO','PORTAL 2020','BOCAN','USER','LpYsf@2028'
EXEC mksp_UserNuevo 'Horizonte Claro Negocios',NULL,NULL,NULL,'HCN060427MZ3','DEMO','PORTAL 2020','MATEO','USER','Svtm@2020'

EXEC mksp_UserNuevo 'INDUSTRIA DE REFRESCOS S DE RL DE CV',NULL,NULL,NULL,'IRE820805HA3','DEMO','PORTAL 2020','PEPSI','USER','Nhlceh@2023'
EXEC mksp_UserNuevo 'JAVIER AURELIO A. AVILA',NULL,NULL,NULL,'AAAJ440820GD9','DEMO','PORTAL 2020','AVILA','USER','LpYsf@2024'
EXEC mksp_UserNuevo 'Jose Claudio Reyes Medina',NULL,NULL,NULL,'REMC820403NQ3','DEMO','PORTAL 2020','JREY','USER','Nhlceh@2024'
EXEC mksp_UserNuevo 'Jose Guadalupe Avila Hernandez',NULL,NULL,NULL,'AIHG6601271X7','DEMO','PORTAL 2020','JAVI','USER','Nhlceh@2022'
EXEC mksp_UserNuevo 'KAZA & GAEL DISTRIBUIDORA DE MEXICO S.A. DE C.V.',NULL,NULL,NULL,'KAG120828EX5','DEMO','PORTAL 2020','KYG','USER','Svtm@2024'
EXEC mksp_UserNuevo 'KELCO QUIMICOS SA DE CV',NULL,NULL,NULL,'KQU150429GI9','DEMO','PORTAL 2020','KELCO','USER','Nhlceh@2024'
EXEC mksp_UserNuevo 'LA EUROPEA MEXICO SAPI DE CV',NULL,NULL,NULL,'EME910610G1A','DEMO','PORTAL 2020','EUROP','USER','LpYsf@2025'
EXEC mksp_UserNuevo 'LA TEXANA, S.A. DE C.V.',NULL,NULL,NULL,'TEX931122JL3','DEMO','PORTAL 2020','TEXAN','USER','Svtm@2025'
EXEC mksp_UserNuevo 'MARIA DEL CARMEN HERNANDEZ FERNANDEZ',NULL,NULL,NULL,'HEFC431005SR9','DEMO','PORTAL 2020','CANNO','USER','Nhlceh@2025'
EXEC mksp_UserNuevo 'MARIA ESTHER JIMENEZ LOZANO',NULL,NULL,NULL,'JILE921003NU8','DEMO','PORTAL 2020','CARV','USER','LpYsf@2026'


EXEC mksp_UserNuevo 'Marisol Fabiola Castañeda Larios',NULL,NULL,NULL,'CALM841114B8A','DEMO','PORTAL 2020','DCALD','USER','Svtm@2021'
EXEC mksp_UserNuevo 'MONICA AGUILAR GONZALEZ',NULL,NULL,NULL,'AUGM7101238Q3','DEMO','PORTAL 2020','MONDE','USER','Nhlceh@2026'
EXEC mksp_UserNuevo 'NETMAR S.A. DE C.V.',NULL,NULL,NULL,'NET010823IQ0','DEMO','PORTAL 2020','NMAR','USER','LpYsf@2027'
EXEC mksp_UserNuevo 'ROCIO GOMEZ NAVA',NULL,NULL,NULL,'GONR651119UU9','DEMO','PORTAL 2020','CUIST','USER','Svtm@2027'

EXEC mksp_UserNuevo 'SANTO MARTINEZ DELGADO',NULL,NULL,NULL,'MADS760522I20','DEMO','PORTAL 2020','VAZQZ','USER','Nhlceh@2027'
EXEC mksp_UserNuevo 'SERVICIOS E INSUMOS MUNDIALES SA DE CV',NULL,NULL,NULL,'SEI100729773','DEMO','PORTAL 2020','SEIM','USER','LpYsf@2028'

EXEC mksp_UserNuevo 'Super Carnes Selectas',NULL,NULL,NULL,'SCS011115HH4','DEMO','PORTAL 2020','GRANF','USER','Nhlceh@2025'
EXEC mksp_UserNuevo 'UNILEVER DE MEXICO S. DE R.L. DE C.V.',NULL,NULL,NULL,'UME651115N48','DEMO','PORTAL 2020','HOLAN','USER','Nhlceh@2028'
EXEC mksp_UserNuevo 'VICTOR IBARRA MOLINA',NULL,NULL,NULL,'IAMV830921IJ5','DEMO','PORTAL 2020','HLALA','USER','LpYsf@2029'
EXEC mksp_UserNuevo 'VIOLETA AIZA ABRAHAM',NULL,NULL,NULL,'AIAV8411193Q4','DEMO','PORTAL 2020','OLETA','USER','Svtm@2029'


*/
--exec mksp_AccesoEmpSuc 'KCOBAIN','AAA12','10'

--update usuario set Nombre=upper(Nombre)

--SElect * from usuario
--select * from Empresa
--select * from Sucursal
--ARC14,10

/*

declare @user varchar(10)
set @user='GRANF'
select * from usuario where usuario=@user
select * from cte where cliente=@user
select * from prov where proveedor=@user


declare @user varchar(10)
set @user='OLEXX'
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