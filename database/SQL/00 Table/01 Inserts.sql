SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO


/**********************		Agregar campo de password	***************************************/
update usuario set PaswordWeb='mexico',PerfilWeb='ADMIN' where Usuario='DEMO'
GO
If Not exists (Select * from Consecutivo where Tipo='cte'  )
INSERT INTO Consecutivo (Tipo, Nivel, Prefijo, Consecutivo, TieneControl, Concurrencia)
                VALUES  ('cte', 'Global', 'CTE', 100, 0, 'Normal')

GO
If Not exists (Select * from Consecutivo where Tipo='Prov'  )
INSERT INTO Consecutivo (Tipo, Nivel, Prefijo, Consecutivo, TieneControl, Concurrencia)
                VALUES  ('Prov', 'Global', 'PROV', 100, 0, 'Normal')

GO
If Not exists (Select * from Consecutivo where Tipo='user'  )
INSERT INTO Consecutivo (Tipo, Nivel, Prefijo, Consecutivo, TieneControl, Concurrencia)
                VALUES  ('user', 'Global', 'UMK', 100, 0, 'Normal')
GO
If Not exists (Select * from Consecutivo where Tipo='art'  )
INSERT INTO Consecutivo (Tipo, Nivel, Prefijo, Consecutivo, TieneControl, Concurrencia)
                VALUES  ('art', 'Global', 'AR', 100, 0, 'Normal')