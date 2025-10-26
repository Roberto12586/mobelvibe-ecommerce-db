# 🛋️ MöbelVibe - Sistema de Gestión e Inteligencia de Datos para E-Commerce de Mobiliario

En este proyecto he diseñado, programado y optimizado la base de datos relacional para **MöbelVibe**, una tienda online de muebles de diseño. He desarrollado todo el ciclo de trabajo desde cero: desde la creación de las tablas y sus restricciones de integridad (DDL), hasta la resolución de consultas analíticas de negocio y la modificación segura de datos masivos (DML).

---

## 🚀 Tecnologías y Herramientas Utilizadas

*   **Motor de Base de Datos:** MySQL 8.0+
*   **Entorno de Desarrollo:** MySQL Workbench
*   **Lenguaje:** SQL (Structured Query Language)

---

## 📊 Arquitectura y Modelo de Datos

Estructuré la base de datos en **6 tablas conectadas** mediante claves foráneas. Para que el asistente de MySQL Workbench cargue los archivos `.csv` sin errores de dependencia, configuré este orden estricto de importación:

1.  `categorias`: Registro y clasificación de los tipos de muebles.
2.  `proveedores`: Información fiscal y de contacto de las empresas de suministro.
3.  `productos`: El catálogo de la tienda (enlazado a sus categorías y proveedores).
4.  `clientes`: Listado de compradores y sus preferencias de publicidad.
5.  `pedidos`: Cabeceras de compra con las fechas, estados y direcciones de envío.
6.  `detalle_pedido`: Las líneas de cada pedido, que conectan los productos con las compras.

---

## 🧠 ¿Qué he aprendido en este proyecto?

Escribir y pulir este código me ha servido para interiorizar conceptos que van más allá de la sintaxis básica de SQL:

*   **Precisión con datos financieros:** Aprendí que usar tipos genéricos destruye los céntimos en los costes de envío o totales de venta. Por eso definí campos estrictos como `DECIMAL(10,2)`.
*   **Evitar fallos por lógica booleana:** Descubrí cómo un mal uso de los operadores `AND` y `OR` puede mezclar datos por accidente (como listar clientes de una ciudad equivocada). Lo solucioné agrupando las condiciones con `IN` y paréntesis.
*   **Agrupaciones y reportes limpios:** Practiqué el uso de `GROUP BY` junto a sumas y medias, entendiendo qué columnas deben ir en el SELECT para que MySQL no devuelva errores de agregación.
*   **Subconsultas cruzadas:** Logré comparar filas individuales contra valores calculados al vuelo. Por ejemplo, pude encontrar qué productos específicos tienen menos stock que la media de su propia categoría.
*   **Control del orden de borrado:** Aprendí a respetar la jerarquía de los datos para no romper la base de datos; eliminando primero los detalles de las líneas antes de borrar un pedido cancelado.

---

## 🛠️ Buenas Prácticas aplicadas

Para asegurarme de que mi código se pueda usar en un entorno de trabajo real, seguí estas reglas:

*   **Uso de Transacciones:** Envolví todas las consultas de modificación (Updates y Deletes) dentro de `START TRANSACTION`. Así, si algo falla, puedo hacer un `ROLLBACK` y dejar los datos como estaban sin romper nada.
*   **Cero códigos fijos (Hardcoding):** En lugar de adivinar e insertar IDs a mano (como poner un "7" para una categoría), utilicé subconsultas dinámicas que buscan el ID correcto directamente por el nombre del registro.
*   **Tablas de respaldo para analítica:** Para no saturar las tablas principales con consultas pesadas, creé tablas independientes (`CREATE TABLE ... AS SELECT`) que guardan resúmenes listos para usar, como el total gastado por cliente.
*   **Estilo limpio y legible:** Escribí todas las palabras clave de SQL en mayúsculas (`SELECT`, `INNER JOIN`, `WHERE`) y utilicé alias claros (`AS`) para que cualquier compañero de equipo pueda entender mis consultas a primera vista.

---

## 📁 Contenido del Repositorio

*   `script.sql`: Mi archivo SQL con toda la estructura de tablas, las 15 consultas de selección ordenadas y las 10 consultas de acción listas para ejecutar.
