-- Ejecutar desde master en una instancia de prácticas. Se requiere una base nueva.
IF DB_ID(N'PA4_Comercial') IS NOT NULL
    THROW 51000, N'La base ya existe. Use otra instancia limpia o continúe con las pruebas.', 1;
GO
CREATE DATABASE PA4_Comercial;
GO
USE PA4_Comercial;
GO
CREATE TABLE dbo.Cliente (
    ClienteId int PRIMARY KEY, Nombre nvarchar(80) NOT NULL
);
CREATE TABLE dbo.Producto (
    ProductoId int PRIMARY KEY, Nombre nvarchar(80) NOT NULL
);
CREATE TABLE dbo.Operacion (
    OperacionId int IDENTITY PRIMARY KEY,
    ClienteId int NOT NULL REFERENCES dbo.Cliente,
    ProductoId int NOT NULL REFERENCES dbo.Producto,
    Cantidad int NOT NULL CHECK (Cantidad BETWEEN 1 AND 100000),
    PrecioUnitario decimal(10,2) NOT NULL CHECK (PrecioUnitario > 0)
);
CREATE TABLE dbo.Historial (
    EventoId bigint IDENTITY PRIMARY KEY,
    OperacionId int NOT NULL,
    Accion varchar(6) NOT NULL,
    CantidadAntes int NULL, CantidadDespues int NULL,
    PrecioAntes decimal(10,2) NULL, PrecioDespues decimal(10,2) NULL,
    ClienteAntes int NULL, ClienteDespues int NULL,
    ProductoAntes int NULL, ProductoDespues int NULL,
    Usuario sysname NOT NULL DEFAULT USER_NAME(),
    FechaUTC datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
INSERT dbo.Cliente VALUES (1,N'Cliente Costa'),(2,N'Cliente Sierra'),(3,N'Cliente Selva');
INSERT dbo.Producto VALUES (10,N'Cuaderno'),(20,N'Archivador');
GO
CREATE TRIGGER dbo.tr_Operacion_Historial ON dbo.Operacion
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Historial (OperacionId, Accion, CantidadAntes, CantidadDespues,
        PrecioAntes, PrecioDespues, ClienteAntes, ClienteDespues, ProductoAntes, ProductoDespues)
    SELECT COALESCE(i.OperacionId,d.OperacionId),
        CASE WHEN d.OperacionId IS NULL THEN 'INSERT'
             WHEN i.OperacionId IS NULL THEN 'DELETE' ELSE 'UPDATE' END,
        d.Cantidad,i.Cantidad,d.PrecioUnitario,i.PrecioUnitario,
        d.ClienteId,i.ClienteId,d.ProductoId,i.ProductoId
    FROM inserted AS i FULL JOIN deleted AS d ON i.OperacionId=d.OperacionId;
END;
GO
CREATE FUNCTION dbo.Importe(@cantidad int,@precio decimal(10,2))
RETURNS decimal(18,2) AS
BEGIN
    RETURN CAST(@cantidad*@precio AS decimal(18,2));
END;
GO
CREATE FUNCTION dbo.DetalleCliente(@cliente int)
RETURNS TABLE AS RETURN (
    SELECT o.OperacionId,p.Nombre AS Producto,o.Cantidad,o.PrecioUnitario,
           dbo.Importe(o.Cantidad,o.PrecioUnitario) AS Importe
    FROM dbo.Operacion AS o JOIN dbo.Producto AS p ON p.ProductoId=o.ProductoId
    WHERE o.ClienteId=@cliente
);
GO
INSERT dbo.Operacion (ClienteId,ProductoId,Cantidad,PrecioUnitario)
VALUES (1,10,3,7.50),(1,20,2,12.00),(2,10,1,7.50);
CREATE ROLE Registro;
CREATE ROLE Revision;
CREATE USER OperadorDemo WITHOUT LOGIN;
CREATE USER AuditorDemo WITHOUT LOGIN;
ALTER ROLE Registro ADD MEMBER OperadorDemo;
ALTER ROLE Revision ADD MEMBER AuditorDemo;
GRANT SELECT ON dbo.Cliente TO Registro;
GRANT SELECT ON dbo.Producto TO Registro;
GRANT INSERT ON dbo.Operacion TO Registro;
GRANT SELECT ON dbo.Historial TO Revision;
GRANT SELECT ON dbo.DetalleCliente TO Revision;
GO
