/* =========================================================
   PA1 - Programación Avanzada de Base de Datos (30627)
   Proyecto: TechStore Perú
   Integrante: Anthony Fernando Alcántara Valencia
   Script 01: Base de datos y modelo físico
   Motor: Microsoft SQL Server
   ========================================================= */

USE master;
GO

IF DB_ID('PA1_TechStore') IS NOT NULL
BEGIN
    ALTER DATABASE PA1_TechStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PA1_TechStore;
END;
GO

CREATE DATABASE PA1_TechStore;
GO

USE PA1_TechStore;
GO

CREATE TABLE Cliente (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Documento VARCHAR(12) NOT NULL,
    Nombres VARCHAR(60) NOT NULL,
    Apellidos VARCHAR(60) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    FechaRegistro DATE NOT NULL CONSTRAINT DF_Cliente_FechaRegistro DEFAULT (CAST(GETDATE() AS DATE)),
    Estado CHAR(1) NOT NULL CONSTRAINT DF_Cliente_Estado DEFAULT ('A'),

    CONSTRAINT UQ_Cliente_Documento UNIQUE (Documento),
    CONSTRAINT UQ_Cliente_Email UNIQUE (Email),
    CONSTRAINT CK_Cliente_Estado CHECK (Estado IN ('A','I'))
);
GO

CREATE TABLE Categoria (
    IdCategoria INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(60) NOT NULL,
    Descripcion VARCHAR(150) NULL,

    CONSTRAINT UQ_Categoria_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE Producto (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    IdCategoria INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL CONSTRAINT DF_Producto_Stock DEFAULT (0),
    FechaAlta DATE NOT NULL CONSTRAINT DF_Producto_FechaAlta DEFAULT (CAST(GETDATE() AS DATE)),
    Estado CHAR(1) NOT NULL CONSTRAINT DF_Producto_Estado DEFAULT ('A'),

    CONSTRAINT UQ_Producto_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Producto_Precio CHECK (Precio > 0),
    CONSTRAINT CK_Producto_Stock CHECK (Stock >= 0),
    CONSTRAINT CK_Producto_Estado CHECK (Estado IN ('A','I')),
    CONSTRAINT FK_Producto_Categoria
        FOREIGN KEY (IdCategoria) REFERENCES Categoria(IdCategoria)
);
GO

CREATE TABLE Venta (
    IdVenta INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL,
    FechaVenta DATETIME NOT NULL CONSTRAINT DF_Venta_Fecha DEFAULT (GETDATE()),
    MetodoPago VARCHAR(20) NOT NULL,
    Estado CHAR(1) NOT NULL CONSTRAINT DF_Venta_Estado DEFAULT ('R'),

    CONSTRAINT CK_Venta_MetodoPago CHECK (MetodoPago IN ('EFECTIVO','TARJETA','YAPE','PLIN')),
    CONSTRAINT CK_Venta_Estado CHECK (Estado IN ('R','A')),
    CONSTRAINT FK_Venta_Cliente
        FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);
GO

CREATE TABLE DetalleVenta (
    IdDetalle INT IDENTITY(1,1) PRIMARY KEY,
    IdVenta INT NOT NULL,
    IdProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Descuento DECIMAL(5,2) NOT NULL CONSTRAINT DF_Detalle_Descuento DEFAULT (0),

    CONSTRAINT CK_Detalle_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_Detalle_Precio CHECK (PrecioUnitario > 0),
    CONSTRAINT CK_Detalle_Descuento CHECK (Descuento BETWEEN 0 AND 100),
    CONSTRAINT FK_Detalle_Venta
        FOREIGN KEY (IdVenta) REFERENCES Venta(IdVenta),
    CONSTRAINT FK_Detalle_Producto
        FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
);
GO
