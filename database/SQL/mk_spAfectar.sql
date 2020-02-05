SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if Object_ID('mk_spAfectar','P') is not null drop proc mk_spAfectar
GO
create proc mk_spAfectar (@ID varchar(150),@Usuario varchar(150),@Modulo Varchar(20))
as
begin
declare 
@mkOK int ,
@mkOkREf varchar(255)

		create table #pasoafectar (F1 varchar(150) NULL,F2 varchar(150) NULL,F3 varchar(150) NULL,F4 varchar(150)  NULL,F5 varchar(150) NULL)
		insert into #pasoafectar (F1,F2,F3,F4,F5)
		Exec spAfectar @Modulo ,@ID, 'AFECTAR', 'Todo', NULL, @Usuario,@EnSilencio=0, @Estacion=2,@OK=@mkOK,@OkREf=@mkOkREf	
		select @mkOK=isnull(F1,0),@mkOkREf=isnull(F2,'')+' '+isnull(F3,'')+' '+' '+isnull(F4,'') from #pasoafectar
		select @mkOK=isnull(@mkOK,0)
		Select @mkOK as Ok,@mkOkREf as OkRef

end 
GO
-- exec mk_spAfectar 4,'Gconsuelos','GAS'