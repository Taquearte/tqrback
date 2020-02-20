SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mksp_ArtNuevo','P') is not null drop proc mksp_ArtNuevo
GO
CREATE PROCEDURE mksp_ArtNuevo
@Art varchar(10),
@Nombre varchar(100),
@Usuario varchar(10),
@Empresa varchar(5),
@Silencio bit=0
as
begin
	DECLARE 
	@Tipo varchar(15)='Proveedor',	
	@Estatus varchar(15)='ALTA',
	@hoyhh datetime = getdate(),
	@hoy date =getdate(),
	@Moneda varchar(10)='Pesos',
	@Articulo varchar(10),
	@OK int ,
	@OKRef varchar(255),
	@DefImpuesto float

	SET @OK =1

	SELECT @Nombre=LTRIM(RTRIM(@Nombre)),@Art=LTRIM(RTRIM(@Art)) ,@Usuario=LTRIM(RTRIM(@Usuario))


	IF len(isnull(@Art,''))=0
	BEGIN
		CREATE TABLE #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
		INSERT INTO #PasoConsecutivo
		EXEC spVerConsecutivo 'art', 0
		SELECT @Articulo=F1 from #PasoConsecutivo where ID=1
	END
	ELSE
		SET @Articulo=@Art


	IF LEN(ISNULL(@Articulo,''))=0
		SELECT @OK=0,@OKRef='La clave del articulo es un dato obligatorio'

	if @OK=1 and len(isnull(@Nombre,''))=0
		Select @OK=0,@OKRef='El Nombre del articulo es un dato obligatorio'

	if @OK=1 AND EXISTS (SELECT * FROM art WHERE articulo = @Articulo ) 
		Select @OK=0,@OKRef='La clave del articulo ya se encuentra en nuestra base de datos'

	if @OK=1 AND EXISTS (SELECT * FROM art WHERE Descripcion1=@Nombre )
		Select @OK=0,@OKRef='El Nombre del articulo ya se encuentra en nuestra base de datos'

	select @DefImpuesto=DefImpuesto from EmpresaGral where Empresa=@Empresa
	Set @DefImpuesto=isnull(@DefImpuesto,16.0)

	if @OK=1

	INSERT INTO Art
	  (Articulo, Rama, Descripcion1, Descripcion2, NombreCorto, Grupo, Categoria, CategoriaActivoFijo, Familia, Fabricante, Linea, ClaveFabricante, Impuesto1, Impuesto2, Impuesto3, Factor, Unidad, UnidadCompra, UnidadTraspaso, UnidadCantidad, TipoCosteo, Peso, Tara, 
	Volumen, Tipo, TipoOpcion, Accesorios, Refacciones, Servicios, Consumibles, MonedaCosto, MonedaPrecio, MargenMinimo, PrecioMinimo, DescuentoCompra, PrecioLista, FactorAlterno, PrecioAnterior, Utilidad, Comision, Arancel, ABC, Estatus, EstatusPrecio, UltimoCambio, 
	Sustitutos, Alta, Mensaje, Precio2, Precio3, Precio4, Precio5, Precio6, Precio7, Precio8, Precio9, Precio10, Refrigeracion, TieneCaducidad, CategoriaProd, ProdMovGrupo, wMostrar, TiempoEntrega, TiempoEntregaUnidad, TiempoEntregaSeg, TiempoEntregaSegUnidad, Merma, 
	Desperdicio, Usuario, ProdRuta, InvSeguridad, SeVende, SeCompra, SeProduce, EsFormula, LoteOrdenar, CantidadOrdenar, MultiplosOrdenar, AlmacenROP, RevisionUsuario, RevisionUltima, RevisionFrecuencia, RevisionFrecuenciaUnidad, RevisionSiguiente, Situacion, 
	SituacionFecha, SituacionUsuario, SituacionNota, TipoCompra, TieneMovimientos, Registro1, Registro1Vencimiento, AlmacenEspecificoVenta, AlmacenEspecificoVentaMov, CostoEstandar, EstatusCosto, Margen, RutaDistribucion, Proveedor, NivelAcceso, Temporada, SolicitarPrecios, 
	AutoRecaudacion, Concepto, Cuenta, Espacios, EspaciosEspecificos, EspaciosSobreventa, EspaciosNivel, EspaciosBloquearAnteriores, EspaciosHoraD, EspaciosHoraA, EspaciosMinutos, Retencion1, Retencion2, Retencion3, BasculaPesar, SerieLoteInfo, CantidadMinimaVenta, 
	CantidadMaximaVenta, EstimuloFiscal, OrigenPais, OrigenLocalidad, Incentivo, FactorCompra, Horas, ISAN, ExcluirDescFormaPago, EsDeducible, Peaje, CodigoAlterno, TipoCatalogo, AnexosAlFacturar, CaducidadMinima, Actividades, ValidarPresupuestoCompra, SeriesLotesAutoOrden, LotesFijos, LotesAuto, Consecutivo, TipoEmpaque, Modelo, Version, TieneDireccion, Direccion, DireccionNumero, DireccionNumeroInt, EntreCalles, Plano, Observaciones, Colonia, Poblacion, Estado, Pais, CodigoPostal, Delegacion, Ruta, Codigo, ClaveVehicular, TipoVehiculo, DiasLibresIntereses, PrecioLiberado, ValidarCodigo, Presentacion, GarantiaPlazo, CostoIdentificado, CantidadTarima, UnidadTarima, MinimoTarima, DepartamentoDetallista, TratadoComercial, CuentaPresupuesto, ProgramaSectorial, ArancelDesperdicio, PedimentoClave, PedimentoRegimen, Permiso, PermisoRenglon, Cuenta2, Cuenta3, Impuesto1Excento, InflacionPresupuesto, CalcularPresupuesto, Excento2, Excento3, ContUso, ContUso2, ContUso3, NivelToleranciaCosto, ToleranciaCosto, ToleranciaCostoInferior, ObjetoGasto, ObjetoGastoRef, ClavePresupuestalImpuesto1, ClavePresupuestalRetencion1, TipoImpuesto2, TipoImpuesto3, TipoImpuesto4, TipoRetencion1, TipoRetencion2, TipoRetencion3, TipoImpuesto5, ISBN, SAUX, INFORClavePrincipal, INFORStockMinimo, INFORStockMaximo, INFORPrefijo, INFORSufijo, INFORTipo, INFORCuarentena, INFORClavePlanta, INFORTrazabilidad, INFORLotificacionPropia, INFORUltimoNumeroLote, INFORUnidadesMaximaLote, INFORTieneNoSerie, INFORSMR, INFORTipoDeAsignacion, INFORNoSerie, INFORFormato, INFORAlmacenProd, ReferenciaIntelisisService, TipoVariante, TipoImpuesto1, AltoTarima, LargoTarima, AnchoTarima, TaraTarima, VolumenTarima, PesoTarima, CantidadCamaTarima, CamasTarima, EstibaMaxima, ControlArticulo, DiasControlCaducidad, EstibaMismaFecha, TipoRotacion, PermiteEstibar, EmidaRecargaTelefonica, EmidaTiempoAire, POSForma, LDI, LDIServicio, TarimasReacomodar)

	VALUES
	  (@Articulo, NULL, @Nombre, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @DefImpuesto, NULL, NULL, NULL, 'Piezas', 'Piezas', NULL, 1.0, 'Promedio', NULL, NULL, NULL, 'Normal', 'No', 0, 0, 0, 0, 'Pesos', 'Pesos', NULL, NULL, NULL, NULL, 1.0, NULL, NULL, NULL, NULL, NULL, @Estatus, 'NUEVO', @hoyhh, 0, @hoyhh, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, @Usuario, NULL, NULL, 1, 1, 0, 0, NULL, NULL, 1.0, NULL, @Usuario, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 'SINCAMBIO', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, NULL, 'Dia', 1, NULL, NULL, 60, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1.0, NULL, 0, 0, 0, NULL, NULL, 'Resurtible', 0, NULL, 0, 'No', '(Empresa)', 0, 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 0, 0, NULL, NULL, NULL, '(Empresa)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 'Posicion', 0, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)


	if @Silencio=0
	Begin
		If @OK=1
		BEGIN
			SET @OKRef='El Articulo se dio de alta correctamente'
			SELECT @OK as OK, @OKRef as OKRef 
		END
		ELSE
			SELECT @OK as OK, @OKRef as OKRef
	END
END
GO

