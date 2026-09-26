/* =========================================================
   Script 05: Separación y adjunción de la base de datos
   Contenido complementario de la sesión 1.
   IMPORTANTE: ajuste las rutas .mdf/.ldf a su equipo antes
   de ejecutar la parte de ATTACH.
   ========================================================= */

USE master;
GO

/* 1) Consultar rutas actuales de los archivos */
SELECT
    DB_NAME(database_id) AS BaseDatos,
    name AS NombreLogico,
    physical_name AS RutaFisica,
    type_desc AS TipoArchivo
FROM sys.master_files
WHERE database_id = DB_ID('PA1_TechStore');
GO

/* 2) Separar (DETACH) la base.
   Cierre conexiones a PA1_TechStore antes de ejecutar. */
ALTER DATABASE PA1_TechStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
EXEC sp_detach_db 'PA1_TechStore';
GO

/* 3) Adjuntar (ATTACH) nuevamente.
   REEMPLACE las rutas siguientes por las obtenidas en el paso 1.

CREATE DATABASE PA1_TechStore
ON
(FILENAME = 'C:\RUTA\PA1_TechStore.mdf'),
(FILENAME = 'C:\RUTA\PA1_TechStore_log.ldf')
FOR ATTACH;
GO
*/
