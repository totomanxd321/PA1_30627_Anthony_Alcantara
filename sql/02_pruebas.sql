USE PA4_Comercial;
GO
SET NOCOUNT ON;
-- Las dos operaciones de prueba se revierten junto con sus seis eventos.
BEGIN TRY
    BEGIN TRAN;
    DECLARE @ids TABLE(id int PRIMARY KEY);
    INSERT dbo.Operacion (ClienteId,ProductoId,Cantidad,PrecioUnitario)
        OUTPUT inserted.OperacionId INTO @ids
        VALUES (3,10,4,7.50),(3,20,4,12.00);
    UPDATE dbo.Operacion SET Cantidad=5 WHERE OperacionId IN (SELECT id FROM @ids);
    DELETE dbo.Operacion WHERE OperacionId IN (SELECT id FROM @ids);
    SELECT h.* FROM dbo.Historial h JOIN @ids k ON k.id=h.OperacionId ORDER BY EventoId;
    IF EXISTS (
        SELECT k.id FROM @ids k LEFT JOIN dbo.Historial h ON h.OperacionId=k.id
        GROUP BY k.id HAVING COUNT(h.EventoId)<>3
        OR SUM(CASE WHEN Accion='INSERT' AND CantidadAntes IS NULL AND CantidadDespues=4 THEN 1 ELSE 0 END)<>1
        OR SUM(CASE WHEN Accion='UPDATE' AND CantidadAntes=4 AND CantidadDespues=5 THEN 1 ELSE 0 END)<>1
        OR SUM(CASE WHEN Accion='DELETE' AND CantidadAntes=5 AND CantidadDespues IS NULL THEN 1 ELSE 0 END)<>1
    ) THROW 51001,N'Historial incorrecto',1;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK;
    THROW;
END CATCH;
IF EXISTS (SELECT 1 FROM dbo.Historial WHERE ClienteAntes=3 OR ClienteDespues=3)
    THROW 51002,N'Persistieron datos de la prueba',1;
SELECT dbo.Importe(3,7.50) AS ImporteUnitarioDeLaLinea;
SELECT * FROM dbo.DetalleCliente(1) ORDER BY OperacionId;
IF dbo.Importe(3,7.50)<>22.50 OR (SELECT COUNT(*) FROM dbo.DetalleCliente(1))<>2
   OR (SELECT SUM(Importe) FROM dbo.DetalleCliente(1))<>46.50
   OR EXISTS (SELECT 1 FROM dbo.DetalleCliente(3))
    THROW 51003,N'Funciones incorrectas',1;
GO
DECLARE @cursorTotal TABLE (ClienteId int PRIMARY KEY, Total decimal(38,2));
DECLARE @conjunto TABLE (ClienteId int PRIMARY KEY, Total decimal(38,2));
DECLARE @cliente int;
DECLARE clientes CURSOR LOCAL FAST_FORWARD FOR SELECT ClienteId FROM dbo.Cliente ORDER BY ClienteId;
OPEN clientes;
FETCH NEXT FROM clientes INTO @cliente;
WHILE @@FETCH_STATUS=0
BEGIN
    INSERT @cursorTotal SELECT @cliente, COALESCE(SUM(Importe),0) FROM dbo.DetalleCliente(@cliente);
    FETCH NEXT FROM clientes INTO @cliente;
END;
CLOSE clientes;
DEALLOCATE clientes;
INSERT @conjunto
SELECT c.ClienteId, COALESCE(SUM(dbo.Importe(o.Cantidad,o.PrecioUnitario)),0)
FROM dbo.Cliente c LEFT JOIN dbo.Operacion o ON c.ClienteId=o.ClienteId
GROUP BY c.ClienteId;
SELECT a.ClienteId,a.Total AS TotalCursor,b.Total AS TotalConjunto
FROM @cursorTotal a JOIN @conjunto b ON a.ClienteId=b.ClienteId ORDER BY a.ClienteId;
IF EXISTS (SELECT * FROM @cursorTotal EXCEPT SELECT * FROM @conjunto)
OR EXISTS (SELECT * FROM @conjunto EXCEPT SELECT * FROM @cursorTotal)
    THROW 51004,N'Los resultados difieren',1;
GO
BEGIN TRY
    BEGIN TRAN;
    EXECUTE AS USER='OperadorDemo';
    SELECT Nombre FROM dbo.Producto ORDER BY ProductoId;
    INSERT dbo.Operacion (ClienteId,ProductoId,Cantidad,PrecioUnitario) VALUES (3,10,1,7.50);
    BEGIN TRY
        SELECT TOP (1) * FROM dbo.Historial;
        THROW 51005,N'El operador pudo leer la auditoría',1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()<>229 THROW;
        SELECT USER_NAME() AS Usuario, ERROR_NUMBER() AS LecturaHistorialDenegada;
    END CATCH;
    REVERT;
    EXECUTE AS USER='AuditorDemo';
    SELECT * FROM dbo.DetalleCliente(3);
    IF NOT EXISTS (SELECT 1 FROM dbo.Historial WHERE Usuario='OperadorDemo' AND ClienteDespues=3)
        THROW 51006,N'Falta el evento del operador',1;
    BEGIN TRY
        INSERT dbo.Operacion (ClienteId,ProductoId,Cantidad,PrecioUnitario) VALUES (3,20,1,12.00);
        THROW 51007,N'El auditor pudo registrar una operación',1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()<>229 THROW;
        SELECT USER_NAME() AS Usuario, ERROR_NUMBER() AS EscrituraDenegada;
    END CATCH;
    REVERT;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF USER_NAME() IN ('OperadorDemo','AuditorDemo') REVERT;
    IF @@TRANCOUNT>0 ROLLBACK;
    THROW;
END CATCH;
PRINT N'PA4: todas las comprobaciones finalizaron correctamente.';
GO
