SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
if Object_ID('spContSATConexionContable','P') is not null drop proc spContSATConexionContable

GO
create PROCEDURE [dbo].[spContSATConexionContable]
	@Empresa	char(5),
	@Modulo		char(5),
	@ID			int
AS
BEGIN
	DECLARE
	@Tabla		as varchar(50),
	@ModuloID	as int,
	@ContID		as int,
	@SQL		as varchar(max)

	DECLARE @TablaModulo as table(Modulo varchar(20), Tabla varchar(20))
	DECLARE @Poliza as table(ContID int)
	DECLARE @Movimientos as table(ID int)
	INSERT INTO @TablaModulo(Modulo, Tabla)
					  VALUES('VTAS','Venta')
	INSERT INTO @TablaModulo(Modulo, Tabla)
					  VALUES('GAS','Gasto')
	INSERT INTO @TablaModulo(Modulo, Tabla)
					  VALUES('NOM','Nomina')
	INSERT INTO @TablaModulo(Modulo, Tabla)
					  VALUES('COMS','Compra')
	INSERT INTO @TablaModulo(Modulo, Tabla)
					  VALUES('CXC','Cxc')
	INSERT INTO @TablaModulo(Modulo, Tabla)
					  VALUES('CXP','Cxp')
	INSERT INTO @TablaModulo(Modulo, Tabla)
				      VALUES('DIN','Dinero')
	IF @Modulo = 'CONT'
	  SELECT @Modulo = ISNULL(OrigenTipo,'CONT') FROM Cont WHERE ID = @ID		
	SELECT @Tabla = Tabla FROM @TablaModulo WHERE Modulo = @Modulo
	IF @Tabla IS NULL
		SET @Tabla = 'Cont'	
	
	--drop table MKSDTEM
	--CREATE TABLE  MKSDTEM (Empresa	char(5),
	--Modulo		char(5),
	--IDRef			int,
	--ID			int)

	IF @Modulo NOT IN ('CONT') AND @Tabla <> 'Cont'
	BEGIN
		delete MKSDTEM where Empresa=@Empresa and Modulo=@Modulo and IDRef =@Id
		SELECT @SQL = 'SELECT ContID FROM '+@Tabla+' WHERE ID = '+CAST(@ID as varchar)
		INSERT INTO @Poliza(ContID) VALUES(@ID)
		SELECT TOP 1 @ContID = ContID FROM @Poliza
		-- Original 
		--SELECT @SQL = 'SELECT ID FROM '+@Tabla+' WHERE ContID = '+CAST(@ContID as varchar)
		--INSERT INTO @Movimientos(ID) EXEC(@SQL)
		--select * from MKSDTEM
		SELECT @SQL = 'insert into MKSDTEM (Empresa,Modulo,IDRef,ID) SELECT '+char(39)+@Empresa+char(39)+' as Empresa,'+char(39)+@Modulo+char(39)+' as Modulo,'+char(39)+convert(varchar,@ID)+char(39)+' as IDRef, ID   FROM '+@Tabla+' WHERE ContID = '+CAST(@ContID as varchar)

		 EXEC(@SQL)
		 INSERT INTO @Movimientos(ID) Select ID FROM MKSDTEM where Empresa=@Empresa and Modulo=@Modulo and IDRef =@Id
		
		IF EXISTS(SELECT * FROM ContSATTranferencia WHERE Modulo = @Modulo AND ModuloID IN (SELECT ID FROM @Movimientos) AND ISNULL(ContID,'') <> '')
			BEGIN
				DELETE FROM @Movimientos WHERE ID IN(SELECT ModuloID FROM ContSATTranferencia WHERE Modulo = @Modulo AND ModuloID IN (SELECT ID FROM @Movimientos))
			END
		IF EXISTS(SELECT * FROM ContSATCheque WHERE Modulo = @Modulo AND ModuloID IN (SELECT ID FROM @Movimientos) AND ISNULL(ContID,'') <> '')
			BEGIN
				DELETE FROM @Movimientos WHERE ID IN(SELECT ModuloID FROM ContSATTranferencia WHERE Modulo = @Modulo AND ModuloID IN (SELECT ID FROM @Movimientos))
			END
		IF EXISTS(SELECT * FROM ContSATOtroMetodoPago WHERE Modulo = @Modulo AND ModuloID IN (SELECT ID FROM @Movimientos) AND ISNULL(ContID,'') <> '')
			BEGIN
				DELETE FROM @Movimientos WHERE ID IN(SELECT ModuloID FROM ContSATTranferencia WHERE Modulo = @Modulo AND ModuloID IN (SELECT ID FROM @Movimientos))
			END				
		
	END
	IF @Modulo IN ('CONT') AND @Tabla <> 'Cont'
	BEGIN
		SELECT @SQL = 'SELECT ID FROM '+@Tabla+' WHERE ContID = '+ CAST(@ID as varchar)
		SET @ContID = @ID
		INSERT INTO @Movimientos(ID) EXEC(@SQL)
	END
	IF @Modulo = 'CONT' AND @Tabla = 'Cont'
	BEGIN
		SELECT @SQL = 'SELECT ID FROM '+@Tabla+' WHERE ID = '+ CAST(@ID as varchar)
		SET @ContID = @ID
		INSERT INTO @Movimientos(ID) EXEC(@SQL)
	END
	IF @ContID IS NOT NULL
	BEGIN
		DECLARE CurConexionContable	CURSOR
		FOR
		SELECT ID FROM @Movimientos		
		OPEN CurConexionContable
		FETCH NEXT FROM CurConexionContable INTO @ModuloID
		WHILE @@FETCH_STATUS = 0
			BEGIN
                EXEC spActualizaMonedaTipoCambio @ModuloID, @Modulo, @Empresa
				EXEC xpContSAT @Empresa, @Modulo, @ModuloID, @ContID
				IF @Modulo = 'CXP'
					BEGIN
						DECLARE cDinero CURSOR FOR
						SELECT A.ID
						  FROM dbo.fnBuscaMovs(@Modulo,@ModuloID,@Empresa) A
						  JOIN MovTipo B ON A.Modulo = B.Modulo AND A.Mov = B.Mov AND AsociaMovAnterior = 1
						 WHERE A.Modulo = 'DIN'
						OPEN cDinero
						FETCH NEXT FROM cDinero INTO @ModuloID
						WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC spContSATDineroActualizarCtaDineroRfc @ModuloID
							EXEC xpContSAT @Empresa, 'DIN', @ModuloID, @ContID
							FETCH NEXT FROM cDinero INTO @ModuloID
						END
						CLOSE cDinero
						DEALLOCATE cDinero
					END
				FETCH NEXT FROM CurConexionContable INTO @ModuloID
			END
		CLOSE CurConexionContable
		DEALLOCATE CurConexionContable
	END
END