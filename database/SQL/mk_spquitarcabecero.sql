SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mk_spquitarcabecero','P') is not null drop proc mk_spquitarcabecero
GO
create proc mk_spquitarcabecero (@ID int )
as
begin

declare 
@OK int,
@OKRef varchar(255),
@Estatus varchar(20),
@Descripcion varchar(1500),
@IDMov int


	select @IDMov=IDMov,@Estatus=Estatus from mk_archivoxmlEncabezado where ID=@Id
	select @Descripcion=Descripcion from mk_archivoxml where ID=@IDMov


	if @Estatus not in ('SINPROCESAR','PENDIENTE')
	begin
		set @OK=-1
		set @OKRef = 'Para poder eliminar el registro debe estar en estatus SINPROCESAR'		
	end
	else
	begin
		delete mk_archivoxmlDetalle where IdCab=@Id
		delete mk_archivoxmlEncabezado where ID=@Id
		delete mk_archivoxml where id=@IDMov
		set @OK=1
		set @OKRef = 'El registro fue eliminado exitosamente'

	END

	Select @OK    as OK,
		   @OKRef as OKRef
 	
END 
GO

--exec mk_spquitarcabecero 1011




