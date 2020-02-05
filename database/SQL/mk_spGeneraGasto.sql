SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mk_spGeneraGasto','P') is not null drop proc mk_spGeneraGasto
GO
--sp_helptext mk_spGeneraGasto

create proc mk_spGeneraGasto (@Descripcion varchar(150) )
as
begin
declare @idgasto int,
@CveProv varchar(20),
@hoy datetime=getdate(),
@moneda varchar(20)='Pesos',
@OK int,
@OKRef Varchar(255),
@mkOK Varchar(255),
@AntbEmisorRFC varchar (150)='',
@AntbReceptorRFC varchar (150)='',
@siokgen varchar (150)='',
@concepto varchar (150)='',
@Clase varchar (150)='',
@SubClase varchar (150)='',
@renglon float,
@NominaClase varchar (100) = 'GASTOS ADMINISTRACION',
@NominaSubclase varchar (100) = 'NOMINA', 
@NominaConcepto varchar (100) ='HONORARIOS ASIMILADOS A SALARIOS ADM'



Create Table #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
Create Table #PasoAfectar (ID int identity,F1 Varchar(150) NULL,F2 Varchar(150) NULL,F3 Varchar(150) NULL,F4 Varchar(150) NULL,F5 Varchar(150) NULL)

Declare @idmov int,
@aDescripcion  varchar(150),
@aEstatus  varchar(150),
@bIDCabecero int,
@bFecha datetime ,
@bFormaPago  varchar(150),
@bCondicionesDePago  varchar(150),
@bMoneda  varchar(150),
@bSubtotal Money,
@bTotal Money,
@bEmisorRFC varchar(150),
@bEmisorNombre varchar(150),
@bReceptorRFC varchar(150),
@bEstatus varchar(150),
@bUUID uniqueidentifier,
@cClaveProdServ varchar(150),
@cCantidad  varchar(150),
@cClaveUnidad  varchar(150) ,
@cUnidad  varchar(150),
@cDescripcion varchar(150),
@cValorUnitario money,
@cArtImporte Money,
@cBase money ,
@cTasaOCuota  money ,
@cImporte money,
@cRetBase money,
@cRetTasaOCuota money,
@cRetImporte money,	
@cRetBase2 money,
@cRetTasaOCuota2 money,
@cRetImporte2 money,
@idd int,
@iddmax int,
@ExisteUUID varchar(20)='',
@bTipoDeComprobante varchar(20)

		DECLARE CurXML CURSOR FAST_FORWARD FOR 
		SELECT a.id as idmov, a.Descripcion,a.Estatus,b.id,b.TipoDeComprobante, b.Fecha,b.FormaPago,b.CondicionesDePago,b.Moneda,b.Subtotal,b.Total,
		b.EmisorRFC,b.EmisorNombre,b.ReceptorRFC,b.Estatus,b.UUID,c.ClaveProdServ,c.Cantidad,c.ClaveUnidad,c.Unidad,c.Descripcion,
		c.ValorUnitario,c.ArtImporte,c.Base,c.TasaOCuota,c.Importe,	c.RetBase,c.RetTasaOCuota,c.RetImporte,c.RetBase2,c.RetTasaOCuota2,
		c.RetImporte2,	c.ID AS idd ,(SELECT MAX(id) FROM mk_archivoxmlDetalle WHERE idcab=b.id ) AS iddmax
		FROM mk_archivoxml a
		join mk_archivoxmlEncabezado b on a.id=b.idmov
		left join mk_archivoxmlDetalle c on b.id=c.idcab
		WHERE a.Descripcion=@Descripcion 
		ORDER BY b.EmisorRFC,UUID

		OPEN CurXML 
		FETCH NEXT FROM CurXML INTO @idmov, @aDescripcion,@aEstatus	,@bIDCabecero,@bTipoDeComprobante,@bFecha  ,@bFormaPago  ,@bCondicionesDePago  ,@bMoneda  ,@bSubtotal ,@bTotal ,
		@bEmisorRFC ,@bEmisorNombre ,@bReceptorRFC ,@bEstatus ,@bUUID ,@cClaveProdServ ,@cCantidad  ,@cClaveUnidad   ,@cUnidad  ,@cDescripcion ,
		@cValorUnitario ,@cArtImporte ,@cBase  ,@cTasaOCuota   ,@cImporte ,	@cRetBase ,@cRetTasaOCuota ,@cRetImporte ,@cRetBase2 ,@cRetTasaOCuota2 ,
		@cRetImporte2 ,@idd ,@iddmax


		WHILE @@FETCH_STATUS <> -1 
		BEGIN 
			set @OK=0
			set @siokgen='*'
			set @concepto=''
			set @OkRef=''
			set @ExisteUUID=''

			Select @ExisteUUID = rtrim(Mov) +' '+rtrim(MovID) from Gasto where UUID=@bUUID and Estatus='CONCLUIDO'
			if @ExisteUUID<>''
			BEGIN				
				UPDATE mk_archivoxml           set Estatus='CONCLUIDO' where id=@idmov	
				UPDATE mk_archivoxmlEncabezado set Estatus='CONCLUIDO', Observaciones = 'El UUID Ya Existe en la base de datos: '+@ExisteUUID where id=@bIDCabecero

			END

			if @aEstatus = ('ACTIVO') and @bEstatus in ('SINPROCESAR','PENDIENTE') and @ExisteUUID=''
			BEGIN			
				if @bTipoDeComprobante='I'
				BEGIN
					--Validamos q exista el
					if  @AntbEmisorRFC <> @bEmisorRFC
					begin
						--select @bEmisorRFC
						set @siokgen='Genera'
						set @renglon=2048.0
						set @AntbEmisorRFC=@bEmisorRFC
						IF NOT EXISTS (SELECT * FROM Prov WHERE RFC=@bEmisorRFC) 
						BEGIN 
							--SET @OK=1
							TRUNCATE TABLE #PasoConsecutivo
							INSERT INTO #PasoConsecutivo
							EXEC spVerConsecutivo 'Prov', 0
							select @CveProv=F1 from #PasoConsecutivo where ID=1
							-- select @CveProv
							INSERT INTO Prov
								(Proveedor, Nombre, Tipo, PedirTono, RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, 
								CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos)
							VALUES (@CveProv, @bEmisorNombre, 'Proveedor', 0, @bEmisorRFC, 'ALTA', @hoy, @hoy, 0, @moneda, 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0)
						END
						else
						begin
							select @CveProv= Proveedor from Prov where RFC=@bEmisorRFC

						end 
				 
					END

					--Validamos el articulo q tenga equivalencia
					--SELECT * FROM mk_mapeoxml WHERE Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ 
					IF @Ok=0 AND NOT EXISTS (SELECT * FROM mk_mapeoxml WHERE Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ  ) 
					BEGIN 
						SET @Ok=1
						INSERT INTO mk_mapeoxml (Proveedor,ClaveProdServ,Modulo,UltimaDes,Estatus) Values (@bEmisorRFC,@cClaveProdServ,'GAS',@cDescripcion,'PENDIENTE')
						UPDATE mk_archivoxmlEncabezado set Estatus='PENDIENTE',Observaciones = 'Falta Configurar Clave Art:'+@cClaveProdServ where id=@bIDCabecero
					END 
					ELSE
					BEGIN			
						IF @Ok=0 AND NOT EXISTS (SELECT * FROM mk_mapeoxml a join concepto b ON a.Concepto=b.Concepto and a.Modulo='GAS'
													WHERE a.Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ)
						BEGIN
							SET @Ok=1
							UPDATE mk_archivoxmlEncabezado set Estatus='PENDIENTE', Observaciones = ' Falta Configurar Clave Art:'+@cClaveProdServ+' ' where id=@bIDCabecero
						END 
						ELSE
						BEGIN
							SELECT @concepto=a.Concepto ,@Clase=Clase,@SubClase=SubClase
							FROM mk_mapeoxml a 
							JOIN concepto b on a.Concepto=b.Concepto and a.Modulo='GAS'
							WHERE a.Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ
						END
					END 

				END
				
				if @bTipoDeComprobante='N'
				BEGIN
					--Validamos q exista el
					if  @AntbReceptorRFC <> @bReceptorRFC
					begin
						--select @bEmisorRFC
						set @siokgen='Genera'
						set @renglon=2048.0
						set @AntbReceptorRFC=@bReceptorRFC
						IF NOT EXISTS (SELECT * FROM Prov WHERE RFC=@bReceptorRFC) 
						BEGIN 
							--SET @OK=1
							TRUNCATE TABLE #PasoConsecutivo
							INSERT INTO #PasoConsecutivo
							EXEC spVerConsecutivo 'Prov', 0
							select @CveProv=F1 from #PasoConsecutivo where ID=1
							--select @consecitivo
							INSERT INTO Prov
								(Proveedor, Nombre, Tipo, PedirTono, RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, 
								CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos)
							VALUES (@CveProv, @bEmisorNombre, 'Proveedor', 0, @bEmisorRFC, 'ALTA', @hoy, @hoy, 0, @moneda, 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0)
						END
						else
						begin
							select @CveProv= Proveedor from Prov where RFC=@bEmisorRFC

						end 
				 
					END
				END

				



				if @Ok=0
				begin
					if @siokgen='Genera'
					BEGIN

						INSERT INTO Gasto
						(Empresa, Mov, MovID, FechaEmision, UltimoCambio, Acreedor, Moneda, TipoCambio, Proyecto, Usuario, Observaciones, Clase, Subclase, Estatus, Condicion, Vencimiento, 
						Importe, Retencion, Impuestos, FechaRequerida, Sucursal, SucursalOrigen, Comentarios, Prioridad, 
						SubModulo,UUID)
						SELECT a.Empresa,'Gasto',NULL, @bFecha, @hoy, @CveProv, 'Pesos', 1.0,b.Proyecto,a.Usuario, 'Tipo de Comprobante: '+@bTipoDeComprobante,
						case when @bTipoDeComprobante='N' then  @NominaClase ELSE @Clase END, case when @bTipoDeComprobante='N' then  @NominaSubclase ELSE @SubClase END, 						 
						'SINAFECTAR', '10 Dias', @hoy, 
						isnull(b.Total,0), 0.0,isnull(b.Importe,0), @hoy, a.Sucursal, 0, '', 'Normal', 'GAS',@bUUID
						FROM mk_archivoxml a 
						JOIN mk_archivoxmlEncabezado b on a.id=b.idMov
						WHERE a.id=@idmov
						SET @idgasto = @@IDENTITY

					end 
					if @idgasto>0
					Begin

						INSERT INTO GastoD
						 (ID, Renglon, RenglonSub, Fecha, Concepto, Referencia, Cantidad, Precio, Importe, Impuestos, ContUso, Sucursal, SucursalOrigen, 
						 Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1,TipoRetencion1,Retencion,TipoRetencion2,Retencion2)
						values (@idgasto,@renglon, 0, @bFecha, 
						case when @bTipoDeComprobante='N' then  @NominaConcepto ELSE @concepto END,
						NULL, @cCantidad, @cValorUnitario, @cCantidad* @cValorUnitario, @cImporte, '', 0, 0, '', 100.0, 
						CASE WHEN isnull(@cTasaOCuota,'')='' then '' else 'IVA 16%' end, CASE WHEN isnull(@cTasaOCuota,'')='' then 0 else 16.0 end,
						CASE WHEN isnull(@cRetTasaOCuota,'')='' then '' else 'ISR 10%' end, @cRetImporte,
						CASE WHEN isnull(@cRetTasaOCuota,'')='' then '' else 'IVA 10.6%' end, @cRetImporte2					
						)

						set @renglon=@renglon+2048.0
					end
					---select @idd,@iddmax
					if @idd=@iddmax
					BEGIN
						TRUNCATE TABLE  #PasoAfectar
						set @OkRef=NULL
						--INSERT INTO #PasoAfectar (F1,F2,F3,F4,F5)
						EXEC spAfectar 'GAS', @idgasto, 'AFECTAR', 'Todo', NULL, 'GCONSUELOS',@EnSilencio=1, @Estacion=2,@OK=@mkOK,@OkREf=@OkRef
						--select @mkOK
						IF @mkOK=NULL
						BEGIN
							SELECT @OkRef=isnull(@OkRef,'')+' '+rtrim(Mov)+' '+rtrim(movID) from Gasto where ID=@idgasto				
							UPDATE mk_archivoxml           set Estatus='CONCLUIDO', Observaciones ='UUID: '+ convert(nvarchar(50),@bUUID)+' '+@OkRef where id=@idmov	
							UPDATE mk_archivoxmlEncabezado set Estatus='CONCLUIDO', Observaciones ='UUID: '+ convert(nvarchar(50),@bUUID)+' '+@OkRef where id=@bIDCabecero			

						END
						ELSE
						Begin
							UPDATE mk_archivoxmlEncabezado set Estatus='PENDIENTE', Observaciones = @OkRef where id=@bIDCabecero	
						END		
					END
				END
			END
	

		FETCH NEXT FROM CurXML INTO @idmov, @aDescripcion,@aEstatus
		,@bIDCabecero,@bTipoDeComprobante,@bFecha  ,@bFormaPago  ,@bCondicionesDePago  ,@bMoneda  ,@bSubtotal ,@bTotal ,@bEmisorRFC ,@bEmisorNombre ,@bReceptorRFC ,@bEstatus ,@bUUID 
		,@cClaveProdServ ,@cCantidad  ,@cClaveUnidad   ,@cUnidad  ,@cDescripcion ,@cValorUnitario ,@cArtImporte ,@cBase  ,@cTasaOCuota   ,@cImporte ,
		@cRetBase ,@cRetTasaOCuota ,@cRetImporte ,@cRetBase2 ,@cRetTasaOCuota2 ,@cRetImporte2 ,@idd ,@iddmax 
		END 
		CLOSE CurXML
		DEALLOCATE CurXML

		SELECT 'Procesado' as OK


		

END 
GO
--Exec mk_spGeneraGasto 'RENTARADIOS'

--select * from gasto where movID like '%1601%' order by id desc


--	exec mk_spGeneraGasto 'retenciones'


--Select * from Gasto order by id desc
--select * from GastoD where id=58727


	/*
		truncate table mk_mapeoxml
		truncate table mk_archivoxml
		truncate table mk_archivoxmlEncabezado
		truncate table mk_archivoxmlDetalle
		update gasto set UUID =null
	*/
	--	select * from mk_mapeoxml
	--	select * from mk_archivoxml where id=1
	--	select * from mk_archivoxmlEncabezado where idMov=1
	--	select * from mk_archivoxmlDetalle where IdCab=1

	--select * from Gasto order by id Desc


