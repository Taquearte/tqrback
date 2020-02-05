
SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mk_spGeneraGasto','P') is not null drop proc mk_spGeneraGasto
GO
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
@siokgen varchar (150)='',
@concepto varchar (150)='',
@renglon float



Create Table #PasoConsecutivo (ID int identity,F1 Varchar(150) NULL)
Create Table #PasoAfectar (ID int identity,F1 Varchar(150) NULL,F2 Varchar(150) NULL,F3 Varchar(150) NULL,F4 Varchar(150) NULL,F5 Varchar(150) NULL)

	Declare @idmov int,
	@aDescripcion  varchar(150),@aEstatus  varchar(150)
	,@bIDCabecero int,@bFecha datetime ,@bFormaPago  varchar(150),@bCondicionesDePago  varchar(150),@bMoneda  varchar(150),@bSubtotal Money,@bTotal Money,@bEmisorRFC varchar(150),@bEmisorNombre varchar(150),@bReceptorRFC varchar(150),@bEstatus varchar(150),@bUUID uniqueidentifier
	,@cClaveProdServ varchar(150),@cCantidad  varchar(150),@cClaveUnidad  varchar(150) ,@cUnidad  varchar(150),@cDescripcion varchar(150),@cValorUnitario money,@cArtImporte Money,@cBase money ,@cTasaOCuota  money ,@cImporte money
	,@idd int,@iddmax int



	
	DECLARE CurXML CURSOR FAST_FORWARD FOR 
    select a.id as idmov, a.Descripcion,a.Estatus
	,b.id,b.Fecha,b.FormaPago,b.CondicionesDePago,b.Moneda,b.Subtotal,b.Total,b.EmisorRFC,b.EmisorNombre,b.ReceptorRFC,b.Estatus,b.UUID
	,c.ClaveProdServ,c.Cantidad,c.ClaveUnidad,c.Unidad,c.Descripcion,c.ValorUnitario,c.ArtImporte,c.Base,c.TasaOCuota,c.Importe,
	c.ID as idd ,(select max(id) from mk_archivoxmlDetalle where idcab=b.id ) as iddmax
	from mk_archivoxml a
	join mk_archivoxmlEncabezado b on a.id=b.idmov
	join mk_archivoxmlDetalle c on b.id=c.idcab
	where a.Descripcion=@Descripcion --and b.ID=1
	order by b.EmisorRFC,UUID

    OPEN CurXML 
	FETCH NEXT FROM CurXML INTO @idmov, @aDescripcion,@aEstatus
	,@bIDCabecero,@bFecha  ,@bFormaPago  ,@bCondicionesDePago  ,@bMoneda  ,@bSubtotal ,@bTotal ,@bEmisorRFC ,@bEmisorNombre ,@bReceptorRFC ,@bEstatus ,@bUUID 
	,@cClaveProdServ ,@cCantidad  ,@cClaveUnidad   ,@cUnidad  ,@cDescripcion ,@cValorUnitario ,@cArtImporte ,@cBase  ,@cTasaOCuota   ,@cImporte ,@idd ,@iddmax 
	WHILE @@FETCH_STATUS <> -1 
	BEGIN 
		set @OK=0
		set @siokgen='*'
		set @concepto=''
		
			if @aEstatus not in ('CONCLUIDO','RECHAZADO')
			BEGIN

			
			 
			--Validamos q exista el
			if  @AntbEmisorRFC <> @bEmisorRFC
			begin
				--select @bEmisorRFC
				set @siokgen='Genera'
				set @renglon=2048.0
				set @AntbEmisorRFC=@bEmisorRFC
				if not exists (select * from Prov where RFC=@bEmisorRFC) 
				begin 
					set @Ok=1
					truncate table #PasoConsecutivo
					insert into #PasoConsecutivo
					exec spVerConsecutivo 'Prov', 0
					select @CveProv=F1 from #PasoConsecutivo where ID=1
					--select @consecitivo
					INSERT INTO Prov
						(Proveedor, Nombre, Tipo, PedirTono, RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos)
					VALUES (@CveProv, @bEmisorNombre, 'Proveedor', 0, @bEmisorRFC, 'ALTA', @hoy, @hoy, 0, @moneda, 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0)
				END
				else
				begin
				select @CveProv= Proveedor from Prov where RFC=@bEmisorRFC

				end 
				 
			END

			--Validamos el articulo q tenga equivalencia
			if @Ok=0 and not exists (select * from mk_mapeoxml where Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ  ) 
			begin 
				set @Ok=1
				insert into mk_mapeoxml (Proveedor,ClaveProdServ,Modulo,UltimaDes,Estatus) Values (@bEmisorRFC,@cClaveProdServ,'GAS',@cDescripcion,'PENDIENTE')
				update mk_archivoxmlEncabezado set Observaciones = ' Falta Configurar Clave Art:'+@cClaveProdServ where id=@bIDCabecero
				--select observaciones from mk_archivoxmlEncabezado where id=@bIDCabecero
			end 
			ELSE
			BEGIN
				if @Ok=0 and not Exists (select * from mk_mapeoxml a join concepto b on a.Concepto=b.Concepto and a.Modulo='GAS'
											where a.Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ)
				begin
					set @Ok=1
					update mk_archivoxmlEncabezado set Observaciones = ' Falta Configurar Clave Art:'+@cClaveProdServ+' ' where id=@bIDCabecero
				end 
				else
				begin
				select @concepto=a.Concepto from mk_mapeoxml a join concepto b on a.Concepto=b.Concepto and a.Modulo='GAS'
											where a.Proveedor=@bEmisorRFC and ClaveProdServ=@cClaveProdServ
				end

			END 


			if @Ok=0
			begin


			    if @siokgen='Genera'
				BEGIN
					--select 'genera mov'
					INSERT INTO Gasto
					(Empresa, Mov, MovID, FechaEmision, UltimoCambio, Acreedor, Moneda, TipoCambio, Proyecto, Usuario, Observaciones, Clase, Subclase, Estatus, Condicion, Vencimiento, Importe, Retencion, Impuestos, FechaRequerida, Sucursal, SucursalOrigen, Comentarios, Prioridad, 
					SubModulo,UUID)

					select a.Empresa,'Gasto',NULL, @hoy, @hoy, @CveProv, 'Pesos', 1.0, '',a.Usuario, 'Observaciones','Gastos de Operaci�n', 'Combustibles', 'SINAFECTAR', '10 Dias', @hoy, b.Total, 0.0, b.Importe, @hoy, 0, 0, '', 'Normal', 'GAS',@bUUID
					from mk_archivoxml a 
					join mk_archivoxmlEncabezado b on a.id=b.idMov
					where a.id=1
					set @idgasto = @@IDENTITY

				end 

				if @idgasto>0
				Begin
					
					--select 'genera movd'
					INSERT INTO GastoD
					 (ID, Renglon, RenglonSub, Fecha, Concepto, Referencia, Cantidad, Precio, Importe, Impuestos, ContUso, Sucursal, SucursalOrigen, Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1)
					values (@idgasto,@renglon, 0, @hoy, @concepto, NULL, @cCantidad, @cValorUnitario, @cCantidad* @cValorUnitario, @cImporte, '', 0, 0, '', 100.0, CASE WHEN isnull(@cTasaOCuota,'')='' then '' else 'IVA 16%' end, CASE WHEN isnull(@cTasaOCuota,'')='' then 0 else 16.0 end)
			 

					set @renglon=@renglon+2048.0
				end
				--select @siokgen
				if @idd=@iddmax
				BEGIN
				--select 'afecta'
					truncate table  #PasoAfectar
					--insert into #PasoAfectar (F1,F2,F3,F4,F5)
					Exec spAfectar 'GAS', @idgasto, 'AFECTAR', 'Todo', NULL, 'GCONSUELOS',@EnSilencio=1, @Estacion=2,@OK=@mkOK,@OkREf=@OkRef
					--select @mkOK,@OkRef
				  if @mkOK=NULL
				  Begin
				  --select 'actuali'+convert(varchar,@idmov)
					update mk_archivoxml set Estatus='CONCLUIDO' where ID =@idmov
					

				  END
				  ELSE
				  Begin

					update mk_archivoxml set Observaciones='Error al Afectar' where ID =@idmov
				  END

				  

				end 
				-- VALUES ('OAD', 'Gasto', NULL, @hoy, @hoy, @CveProv, 'Pesos', 1.0, '', 'GC', 'CHALKES', '', 'Gastos de Operaci�n', 'Combustibles', 'SINAFECTAR', '10 Dias', @hoy, 0.0, 0.0, 0.0, @hoy, 0, 0, '', 'Normal', 'GAS')
				

			end

			END
	

		FETCH NEXT FROM CurXML INTO @idmov,@aDescripcion,@aEstatus
	,@bIDCabecero, @bFecha  ,@bFormaPago  ,@bCondicionesDePago  ,@bMoneda  ,@bSubtotal ,@bTotal ,@bEmisorRFC ,@bEmisorNombre ,@bReceptorRFC ,@bEstatus ,@bUUID 
	,@cClaveProdServ ,@cCantidad  ,@cClaveUnidad   ,@cUnidad  ,@cDescripcion ,@cValorUnitario ,@cArtImporte ,@cBase  ,@cTasaOCuota   ,@cImporte ,@idd ,@iddmax
	END 
	CLOSE CurXML
	DEALLOCATE CurXML
	
	Select 'Procesado' as OK
	--	truncate table mk_mapeoxml

	--	select * from mk_mapeoxml
	--	select * from mk_archivoxml where id=1
	--	select * from mk_archivoxmlEncabezado where idMov=1
	--	select * from mk_archivoxmlDetalle where IdCab=1


	/*

	select * from mk_archivoxmlEncabezado order by idmov desc
	select * from mk_archivoxmlDetalle order by idCab desc


	exec @Consecitivo=spVerConsecutivo 'Prov', 0


	INSERT INTO Prov
				 (Proveedor, Nombre, Tipo, PedirTono, RFC, Estatus, UltimoCambio, Alta, Conciliar, DefMoneda, ProntoPago, TieneMovimientos, DescuentoRecargos, CompraAutoCargosTipo, Pagares, wGastoSolicitud, ConLimiteAnticipos, ChecarLimite, eMailAuto, Intercompania, GarantiaCostos)
	VALUES (@Consecitivo, 'Hector Rosales', 'Proveedor', 0, 'DOHG900916NI4', 'ALTA', @hoy, @hoy, 0, 'Pesos', 0, 0, 0, 'No', 0, 0, 0, 'Anticipo', 0, 0, 0)



	select * from gasto order by id desc


		INSERT INTO Gasto
					 (Empresa, Mov, MovID, FechaEmision, UltimoCambio, Acreedor, Moneda, TipoCambio, Proyecto, Usuario, Observaciones, Clase, Subclase, Estatus, Condicion, Vencimiento, Importe, Retencion, Impuestos, FechaRequerida, Sucursal, SucursalOrigen, Comentarios, Prioridad, 
					 SubModulo)
		VALUES ('OAD', 'Gasto', NULL, @hoy, @hoy, 'AAA100723V', 'Pesos', 1.0, 'OAD-Masaryk', 'GC', 'CHALKES', 'Gastos de Operaci�n', 'Combustibles', 'SINAFECTAR', '10 Dias', @hoy, 0.0, 0.0, 0.0, @hoy, 0, 0, '', 'Normal', 'GAS')
		set @idgasto = @@IDENTITY

		select @idgasto


		--INSERT INTO GastoD
		--			 (ID, Renglon, RenglonSub, Fecha, Concepto, Referencia, Cantidad, Precio, Importe, Impuestos, ContUso, Sucursal, SucursalOrigen, Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1)
		--VALUES (36190, 2048.0, 0, '2019/09/18 00:00:00', 'Cafeteria', NULL, 1.0, 500.0, 500.0, 80.0, 'UC LA RIOJA', 0, 0, 'OAD-Masaryk', 100.0, 'IVA 16%', 16.0)

INSERT INTO GastoD
             (ID, Renglon, RenglonSub, Fecha, Concepto, Referencia, Cantidad, Precio, Importe, Impuestos, ContUso, Sucursal, SucursalOrigen, Proyecto, PorcentajeDeducible, TipoImpuesto1, Impuesto1)
VALUES (@idgasto, 2048.0, 0, '2019/09/18 00:00:00', 'Gasolina y Combustibles', 'HRO', 20.0, 19.85, 397.0, 63.52, 'MASARYK', 0, 0, 'OAD-Masaryk', 100.0, 'IVA 16%', 16.0)


		/* GC */ Exec spAfectar 'GAS', @idgasto, 'AFECTAR', 'Todo', NULL, 'GC', @Estacion=2
*/

end 
GO
--truncate table mk_mapeoxml
GO
-- Exec mk_spGeneraGasto 'MOV001'

/*
select top 20 * from gasto order by id desc
select * from gastod where id=58603
*/




--	select * from mk_mapeoxml



--select * from Consecutivo
--insert into Consecutivo (Tipo,Nivel,TieneControl,Prefijo,Consecutivo,Concurrencia,FueraLinea)
--values ('Prov',	'Global',	0,	'MK',	1	,'Normal',	0)