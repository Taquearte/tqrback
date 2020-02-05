INSERT INTO [dbo].[TipoImpuesto]
           ([TipoImpuesto]
           ,[Tasa]
           ,[Concepto]
           ,[Referencia]
           ,[CodigoFiscal]
           ,[Tipo]
           ,[TieneMovimientos]
           ,[CuentaDeudora]
           ,[CuentaAcreedora])
     VALUES
           ('IVA 16%'
           ,16
           ,''
           ,'002'
           ,''
           ,'Impuesto 1'
           ,0
           ,NULL
           ,NULL),
		    ('ISR 10%'
           ,10
           ,''
           ,'001'
           ,''
           ,'Retencion 1'
           ,0
           ,NULL
           ,NULL),
		              ('IVA 10.6%'
           ,10.6667
           ,''
           ,'002'
           ,''
           ,'Retencion 2'
           ,0
           ,NULL
           ,NULL)
GO


SELECT * FROM mk_archivoxml
Select b.Descripcion,a.* from mk_archivoxmlEncabezado a join mk_archivoxml b on a.IDMov=b.ID
