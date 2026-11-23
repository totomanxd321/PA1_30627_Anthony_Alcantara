# PA4 · Gestión y auditoría de operaciones comerciales
**ISIL · Programación Avanzada de Base de Datos · 30627 · Periodo 202620**

| Integrante | Participación |
|---|---|
| Anthony Fernando Alcantara Valencia | Desarrollo individual del modelo, programación T-SQL, diseño de pruebas, seguridad y sustentación. |

## Problema y objetivo
Una distribuidora de útiles necesita saber quién registró o modificó una línea de venta, consultar cuánto compró cada cliente y separar las tareas de registro y revisión. El objetivo es conservar los cambios, reutilizar el cálculo de importes y comprobar en SQL Server qué acciones permite cada perfil.

## Modelo y procedimiento
Cada operación corresponde a una línea de venta de un producto a un cliente. Las claves foráneas garantizan que ambos existan. La línea conserva el precio pactado y la cantidad debe ser positiva. El historial mantiene el identificador de la operación sin una clave foránea hacia ella para conservar el registro después de una eliminación. Los nombres y movimientos del caso son ficticios.

### Sesión 11 · Auditoría automática
El desencadenante AFTER registra una fila por operación afectada. Empareja inserted y deleted por la clave IDENTITY. Una clave presente solo en inserted identifica un alta, presente en ambas identifica una actualización y presente solo en deleted identifica una baja. Se conservan cliente, producto, cantidad y precio anteriores y posteriores, usuario efectivo y hora UTC. El registro se genera incluso cuando una sentencia cambia varias filas y participa en la misma transacción que el movimiento original.

### Sesión 12 · Dos formas de reutilizar una consulta
Importe devuelve un valor decimal para una cantidad y un precio. Se usa como expresión en una columna o dentro de SUM. DetalleCliente devuelve un conjunto de líneas con producto, cantidad, precio e importe. Se consume en FROM, admite filtros y devuelve cero filas para un cliente sin compras. Ambas rutas comparten la misma regla de cálculo.

El cursor LOCAL FAST_FORWARD procesa clientes de uno en uno. OPEN prepara el recorrido, FETCH obtiene el identificador, CLOSE cierra el conjunto y DEALLOCATE libera la referencia. Facilita seguir decisiones individuales cuando cada fila requiere un tratamiento distinto. Para este informe repite una consulta por cliente. La alternativa agrupa todas las operaciones mediante LEFT JOIN, GROUP BY y SUM. El enlace externo conserva clientes sin ventas y COALESCE les asigna cero. La prueba compara ambas salidas en los dos sentidos mediante EXCEPT. Para el informe se elige la agrupación por su menor complejidad y porque permite al motor planificar el cálculo como una operación de conjunto. La prueba mide equivalencia de resultados, no tiempos de ejecución.

### Sesión 13 · Autenticación y permisos
La conexión de prácticas utiliza autenticación integrada de Windows. Windows verifica la identidad y SQL Server aplica permisos mediante usuarios y roles. En modo mixto también se admiten inicios de sesión SQL con credenciales administradas por el motor. Para esta distribuidora se elige Windows porque permite administrar las cuentas desde un único directorio.

| Perfil | Acciones concedidas | Comprobación de límite |
|---|---|---|
| Registro | Consultar clientes y productos e insertar operaciones | La lectura directa de Historial devuelve el error 229. |
| Revisión | Consultar Historial y DetalleCliente | La inserción directa en Operacion devuelve el error 229. |

Los usuarios de demostración se crean WITHOUT LOGIN para reproducir la autorización con EXECUTE AS USER sin publicar credenciales. REVERT restaura el contexto original. El desencadenante y las tablas comparten propietario, por lo que el operador registra la venta sin recibir acceso directo de escritura al historial. Para cuentas reales de Windows, el administrador crea el login FROM WINDOWS, crea el usuario FOR LOGIN en la base y lo agrega al rol correspondiente.

Las claves simétricas permiten cifrar y descifrar datos con la misma clave. Un certificado vincula una identidad con una clave pública y puede proteger una clave simétrica dentro de SQL Server. El acceso a la clave privada debe limitarse y su copia de respaldo debe custodiarse separadamente para permitir la recuperación. Los roles resuelven los permisos del caso y el cifrado responde a una necesidad distinta de confidencialidad.

## Ejecución y evidencias
1. Conectar SSMS a una instancia de prácticas de Microsoft SQL Server mediante autenticación de Windows. Usar una cuenta con permiso para crear la base. La instancia debe carecer de una base llamada PA4_Comercial.
2. Ejecutar [01_modelo.sql](sql/01_modelo.sql) completo una sola vez. Crea la base, las tablas, los objetos del servidor, tres clientes, dos productos y tres líneas de venta.
3. Ejecutar [02_pruebas.sql](sql/02_pruebas.sql). Las modificaciones de ensayo se revierten para permitir nuevas ejecuciones sobre los datos iniciales. En SSMS se muestran las tablas en Resultados y el estado final en Mensajes.
4. El flujo de verificación de GitHub ejecuta los mismos archivos con SQL Server LocalDB y autenticación integrada. Una ejecución correcta genera el archivo resultados.txt con la salida del motor.

| Prueba | Resultado esperado sobre los datos iniciales |
|---|---|
| Alta, modificación y baja de dos filas | Seis eventos. Cada fila pasa de cantidad 4 a 5 y luego se elimina. El rollback revierte los seis eventos. |
| Importe y detalle del cliente Costa | 3 × S/ 7,50 = S/ 22,50. La segunda línea vale S/ 24,00. Total S/ 46,50. |
| Cursor y agrupación | Costa S/ 46,50, Sierra S/ 7,50, Selva S/ 0,00 en ambos recorridos. |
| Permisos efectivos | El operador registra una venta y queda identificado en la auditoría. El auditor puede verla. Cada perfil recibe el error 229 al intentar la acción restringida. |

## Conclusiones
La auditoría por sentencia conserva los valores de cada línea incluso en cambios masivos. Centralizar el importe evita discrepancias entre el detalle y los totales. La agrupación expresa directamente el informe comercial y conserva a los clientes sin ventas. Los roles permiten asignar las dos responsabilidades sin conceder control general de la base.

**Ejecución verificada.** [Salida real de SQL Server](evidencias/resultados.txt) · [Registro de ejecución en GitHub](https://github.com/totomanxd321/PA1_30627_Anthony_Alcantara/actions/runs/45091888625). El motor registró seis eventos de prueba, ambos métodos devolvieron los tres saldos previstos y las dos operaciones restringidas produjeron el error 229.

## Exposición individual
Video público de YouTube: pendiente de publicación.
