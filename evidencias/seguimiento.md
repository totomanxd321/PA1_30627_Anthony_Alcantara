# Seguimiento del desarrollo y verificación de la PA4

**Anthony Fernando Alcantara Valencia · Programación Avanzada de Base de Datos · ISIL**

## Registro de avances

| Fecha y hora de Perú | Avance verificable | Evidencia |
|---|---|---|
| 22/11/2026, 7:58:32 p. m. | Se registraron el modelo, los objetos T-SQL, las pruebas, el flujo de ejecución y la documentación. | [Versión de implementación](https://github.com/totomanxd321/PA1_30627_Anthony_Alcantara/commit/c175134c984b9c6720b04a36b95aa99932c0feba) |
| 22/11/2026, 7:58:55 p. m. | SQL Server registró las altas, modificaciones y bajas de las operaciones 4 y 5. La ejecución también comprobó las funciones, la equivalencia de los totales y los límites de ambos roles. | [Salida del motor](resultados.txt) · [Ejecución en Windows](https://github.com/totomanxd321/PA1_30627_Anthony_Alcantara/actions/runs/45091888625) |
| 22/11/2026, 7:59:19 p. m. | Se incorporaron los resultados al repositorio junto con el enlace al registro de ejecución. | [Versión con evidencias](https://github.com/totomanxd321/PA1_30627_Anthony_Alcantara/commit/56d99f2e3d3cd9cdfbe77247ceca22d659853841) |

## Relación con las sesiones evaluadas

| Sesión y contenido | Qué se comprueba | Resultado observado |
|---|---|---|
| 11 · Desencadenantes | Se modifican dos líneas por sentencia y se comparan los valores anteriores y posteriores. | Eventos 4 a 9: dos altas con cantidad 4, dos cambios de 4 a 5 y dos bajas con cantidad anterior 5. |
| 12 · Funciones | Se calcula el importe de una línea y se consulta el detalle del cliente 1. | Tres cuadernos a S/ 7,50 suman S/ 22,50. Dos archivadores a S/ 12,00 completan el total de S/ 46,50. |
| 12 · Cursor y conjuntos | Se comparan los totales por cliente, incluido el cliente sin ventas. | Los tres pares coinciden: S/ 46,50, S/ 7,50 y S/ 0,00. |
| 13 · Seguridad | Se realiza una operación permitida y otra restringida bajo cada identidad. | El operador registra la venta y el auditor la consulta. El motor devuelve el error 229 ante la lectura del historial por el operador y la inserción por el auditor. |

[Implementación](../sql/01_modelo.sql) · [Pruebas reproducibles](../sql/02_pruebas.sql)
