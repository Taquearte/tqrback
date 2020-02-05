SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO


/**********************		Agregar campo de password	***************************************/
exec spALTER_TABLE 'usuario','PaswordWeb varchar(20) NULL','',''
exec spALTER_TABLE 'usuario','PerfilWeb varchar(20) NULL','',''
exec spALTER_TABLE 'usuario','RFC varchar(15) NULL','',''
exec spALTER_TABLE 'usuario','uNombre varchar(33) NULL','',''
exec spALTER_TABLE 'usuario','uPaterno varchar(33) NULL','',''
exec spALTER_TABLE 'usuario','uMaterno varchar(33) NULL','',''
exec spALTER_TABLE 'gasto','UUID uniqueidentifier null ','',''
exec spALTER_TABLE 'compra','UUID uniqueidentifier null ','',''

GO
update usuario set PaswordWeb='mexico',PerfilWeb='ADMIN' where Usuario='DEMO'

GO

select * from Usuario

