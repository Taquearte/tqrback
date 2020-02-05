SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mk_sparchivar','P') is not null drop proc mk_sparchivar
GO
create proc mk_sparchivar (@Descripcion varchar(150) )
as
begin

	if (select count(*) from mk_archivoxml where Estatus='ACTIVO')=0
	Begin
		update mk_archivoxml set Mostrar=0 where Descripcion=@Descripcion
		SELECT 1 as OK, 'Procesado' as Mensaje
	end
	else
	begin
		SELECT -1 as OK, 'Es necesario no tener ningun archivo PENDIENTE' as Mensaje
	end 	
END 
GO

exec mk_sparchivar 'retenciones'




