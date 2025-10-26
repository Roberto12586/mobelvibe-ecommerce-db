-- =============================================================================
-- PROYECTO: MöbelVibe - E-Commerce de Mobiliario de Diseño
-- AUTOR: Roberto12586
-- DESCRIPCIÓN: Creación de estructura de base de datos (DDL), consultas analíticas 
--              de negocio (SELECT) y consultas operacionales seguras (DML).
-- COMPATIBILIDAD: MySQL 8.0+ / MySQL Workbench
-- =============================================================================

DROP DATABASE IF EXISTS mobelvibe_db;
CREATE DATABASE mobelvibe_db;
USE mobelvibe_db;

-- =============================================================================
-- 1. ESTRUCTURA DE TABLAS (DDL)
-- =============================================================================

-- TABLA: categorias
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT, 
    activo BOOLEAN DEFAULT TRUE
);

-- TABLA: proveedores
CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_comercial VARCHAR(150) NOT NULL,
    nif VARCHAR(9) NOT NULL UNIQUE,
    persona_contacto VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    ciudad VARCHAR(100),
    fecha_alta DATE NOT NULL
);

-- TABLA: productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    material VARCHAR(50),
    color VARCHAR(30),
    requiere_montaje BOOLEAN DEFAULT FALSE,
    fecha_catalogo DATE,
    activo BOOLEAN DEFAULT TRUE,
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- TABLA: clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    ciudad VARCHAR(200),
    fecha_registro DATE,
    acepta_comunicaciones BOOLEAN DEFAULT FALSE
);

-- TABLA: pedidos
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_pedido DATETIME NOT NULL,
    estado ENUM('Entregado', 'Enviado', 'Cancelado', 'Pendiente', 'En preparación') NOT NULL,
    direccion_entrega VARCHAR(150),
    coste_envio DECIMAL(10,2) DEFAULT 0.00, 
    fecha_entrega DATE NULL,                
    observaciones VARCHAR(255),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- TABLA: detalle_pedido
CREATE TABLE detalle_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento_pct DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- =============================================================================
-- 6. CONSULTAS DE SELECCIÓN (15) - BLOQUE INTERMEDIO
-- =============================================================================

-- 1. Mostrar todos los productos con su categoría y proveedor.
SELECT 
    p.nombre AS nombre_producto, 
    c.nombre AS categoria, 
    pr.nombre_comercial AS proveedor, 
    p.precio, 
    p.stock 
FROM productos p 
INNER JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
ORDER BY p.nombre ASC;

-- 2. Mostrar los productos activos cuyo precio esté entre 100 y 400 euros y tengan más de cinco unidades en stock.
SELECT 
    nombre AS nombre_producto, 
    precio, 
    stock 
FROM productos 
WHERE activo = TRUE 
  AND precio BETWEEN 100 AND 400 
  AND stock > 5
ORDER BY precio ASC;

-- 3. Listar los productos que requieren montaje, ordenados por categoría y nombre.
SELECT 
    c.nombre AS categoria,
    p.nombre AS nombre_producto
FROM productos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.requiere_montaje = TRUE
ORDER BY c.nombre ASC, p.nombre ASC;

-- 4. Obtener los clientes de Barcelona o Madrid que hayan aceptado recibir comunicaciones comerciales.
SELECT 
    nombre, 
    apellidos, 
    ciudad, 
    acepta_comunicaciones 
FROM clientes 
WHERE ciudad IN ('Barcelona', 'Madrid') 
  AND acepta_comunicaciones = TRUE
ORDER BY apellidos ASC;

-- 5. Mostrar los pedidos realizados entre dos fechas (por ejemplo '2026-04-01' y '2026-04-30').
SELECT 
    id_pedido, 
    id_cliente, 
    fecha_pedido, 
    estado 
FROM pedidos 
WHERE fecha_pedido BETWEEN '2026-04-01 00:00:00' AND '2026-04-30 23:59:59'
ORDER BY fecha_pedido ASC;

-- 6. Mostrar los pedidos que aún no se han entregado, indicando cliente, fecha, estado, dirección y coste de envío.
SELECT 
    p.id_pedido, 
    CONCAT(c.nombre, ' ', c.apellidos) AS cliente, 
    p.fecha_pedido, 
    p.estado, 
    p.direccion_entrega, 
    p.coste_envio 
FROM pedidos p
INNER JOIN clientes c ON p.id_cliente = c.id_cliente
WHERE p.estado IN ('Pendiente', 'En preparación', 'Enviado') 
ORDER BY p.fecha_pedido ASC;

-- 7. Calcular cuántas unidades se han vendido de cada producto, sin incluir los pedidos cancelados.
SELECT 
    pd.nombre AS nombre_producto, 
    SUM(d.cantidad) AS unidades_vendidas 
FROM detalle_pedido d
INNER JOIN pedidos p ON d.id_pedido = p.id_pedido
INNER JOIN productos pd ON d.id_producto = pd.id_producto
WHERE p.estado <> 'Cancelado'
GROUP BY pd.id_producto, pd.nombre
ORDER BY unidades_vendidas DESC;

-- 8. Calcular el importe neto de cada línea de pedido: cantidad × precio_unitario aplicando el descuento porcentual.
SELECT 
    id_detalle,
    id_pedido,
    cantidad,
    precio_unitario,
    descuento_pct,
    (cantidad * precio_unitario * (1 - (IFNULL(descuento_pct, 0) / 100))) AS importe_neto
FROM detalle_pedido
ORDER BY id_pedido ASC;

-- 9. Mostrar el precio medio, mínimo y máximo de los productos activos de cada categoría.
SELECT 
    c.nombre AS categoria,
    AVG(p.precio) AS precio_medio, 
    MIN(p.precio) AS precio_minimo, 
    MAX(p.precio) AS precio_maximo 
FROM productos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.activo = TRUE
GROUP BY c.id_categoria, c.nombre 
ORDER BY c.nombre ASC;

-- 10. Mostrar todos los clientes, incluso los que no tengan pedidos, indicando el número de pedidos y el gasto total acumulado.
SELECT 
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellidos) AS cliente,
    COUNT(DISTINCT p.id_pedido) AS numero_pedidos,
    IFNULL(SUM(d.cantidad * d.precio_unitario * (1 - (IFNULL(d.descuento_pct,0) / 100))), 0) AS gasto_total_productos
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente AND p.estado <> 'Cancelado' 
LEFT JOIN detalle_pedido d ON p.id_pedido = d.id_pedido
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY gasto_total_productos DESC;

-- 11. Mostrar cada proveedor con el número de productos que suministra y el total de unidades que hay en stock de sus productos.
SELECT 
    pv.nombre_comercial AS proveedor,
    COUNT(p.id_producto) AS total_productos, 
    IFNULL(SUM(p.stock), 0) AS stock_total 
FROM proveedores pv
LEFT JOIN productos p ON pv.id_proveedor = p.id_proveedor
GROUP BY pv.id_proveedor, pv.nombre_comercial
ORDER BY total_productos DESC;

-- 12. Mostrar los pedidos realizados durante el último trimestre que todavía no hayan sido enviados, ordenados por fecha de pedido de más reciente a más antiguo.
SELECT 
    id_pedido, 
    fecha_pedido, 
    estado 
FROM pedidos 
WHERE fecha_pedido >= DATE_SUB('2026-06-26', INTERVAL 3 MONTH) 
  AND estado IN ('Pendiente', 'En preparación') 
ORDER BY fecha_pedido DESC;

-- 13. Listar los productos que todavía no se hayan incluido en ninguna línea de pedido.
SELECT 
    p.id_producto, 
    p.nombre AS nombre_producto
FROM productos p
LEFT JOIN detalle_pedido d ON p.id_producto = d.id_producto
WHERE d.id_producto IS NULL
ORDER BY p.nombre ASC;

-- 14. Para cada pedido no cancelado, mostrar el número de líneas, las unidades totales, el importe de productos, el coste de envío y el total final.
SELECT 
    p.id_pedido,
    COUNT(d.id_detalle) AS numero_lineas,
    SUM(d.cantidad) AS unidades_totales,
    SUM(d.cantidad * d.precio_unitario * (1 - (IFNULL(d.descuento_pct,0) / 100))) AS importe_productos,
    p.coste_envio, 
    (SUM(d.cantidad * d.precio_unitario * (1 - (IFNULL(d.descuento_pct,0) / 100))) + p.coste_envio) AS total_final  
FROM pedidos p
INNER JOIN detalle_pedido d ON p.id_pedido = d.id_pedido
WHERE p.estado <> 'Cancelado'
GROUP BY p.id_pedido, p.coste_envio
ORDER BY p.id_pedido ASC;

-- 15. Mostrar los productos cuyo stock sea inferior al stock medio de los productos activos de su misma categoría.
SELECT 
    p1.nombre AS nombre_producto, 
    p1.stock,
    c.nombre AS categoria
FROM productos p1 
INNER JOIN categorias c ON p1.id_categoria = c.id_categoria
WHERE p1.stock < (
    SELECT AVG(p2.stock) 
    FROM productos p2 
    WHERE p2.id_categoria = p1.id_categoria 
      AND p2.activo = TRUE 
)
ORDER BY c.nombre ASC;


-- =============================================================================
-- 8. CONSULTAS DE ACCIÓN (10)
-- =============================================================================

START TRANSACTION;

-- 1. Insertar un proveedor nuevo llamado “Madera de Origen S.L.”
INSERT INTO proveedores (nombre_comercial, nif, persona_contacto, telefono, email, ciudad, fecha_alta) 
VALUES ('Madera de Origen S.L.', 'B33445566', 'Ana Segura', '930112233', 'pedidos@maderadeorigen.es', 'Girona', CURDATE());

-- 2. Insertar una categoría nueva denominada “Recibidor”
INSERT INTO categorias (nombre, descripcion, activo) 
VALUES ('Recibidor', 'Muebles y complementos para la entrada del hogar.', TRUE);

-- 3. Insertar un producto llamado “Consola Senda” en la categoría Recibidor y asociado al proveedor Madera de Origen S.L.
INSERT INTO productos (nombre, descripcion, precio, stock, material, color, requiere_montaje, fecha_catalogo, activo, id_categoria, id_proveedor) 
VALUES (
    'Consola Senda', 
    'Mueble recibidor elegante de alta calidad.', 
    315.00, 
    7, 
    'Madera', 
    'Roble oscuro', 
    TRUE, 
    CURDATE(), 
    TRUE, 
    (SELECT id_categoria FROM categorias WHERE nombre = 'Recibidor' LIMIT 1),   
    (SELECT id_proveedor FROM proveedores WHERE nombre_comercial = 'Madera de Origen S.L.' LIMIT 1) 
);

-- 4. Crear una tabla llamada productos_reposicion que contenga los productos activos con menos de cinco unidades en stock.
DROP TABLE IF EXISTS productos_reposicion;
CREATE TABLE productos_reposicion AS
SELECT 
    p.nombre AS producto,
    pv.nombre_comercial AS proveedor,
    p.stock,
    'Revisar' AS prioridad
FROM productos p
INNER JOIN proveedores pv ON p.id_proveedor = pv.id_proveedor
WHERE p.activo = TRUE 
  AND p.stock < 5;

-- 5. Crear una tabla llamada resumen_ventas_cliente que guarde, para cada cliente con pedidos no cancelados, su nombre completo, número de pedidos y total gastado.
DROP TABLE IF EXISTS resumen_ventas_cliente;
CREATE TABLE resumen_ventas_cliente AS
SELECT 
    CONCAT(c.nombre, ' ', c.apellidos) AS nombre_completo,
    COUNT(DISTINCT p.id_pedido) AS numero_pedidos,
    SUM(d.cantidad * d.precio_unitario * (1 - (IFNULL(d.descuento_pct,0) / 100))) + SUM(DISTINCT p.coste_envio) AS total_gastado
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
INNER JOIN detalle_pedido d ON p.id_pedido = d.id_pedido
WHERE p.estado <> 'Cancelado'
GROUP BY c.id_cliente, c.nombre, c.apellidos;

-- 6. Incrementar un 5 % el precio de los productos activos de la categoría Mesas.
UPDATE productos 
SET precio = precio * 1.05
WHERE activo = TRUE 
  AND id_categoria IN (SELECT id_categoria FROM categorias WHERE nombre = 'Mesas'); 

-- 7. Reducir en dos unidades el stock del producto “Mesa auxiliar Brisa”, pero únicamente si dispone de al menos dos unidades.
UPDATE productos 
SET stock = stock - 2
WHERE nombre = 'Mesa auxiliar Brisa' 
  AND stock >= 2;
  
-- 8. Cambiar a “En preparación” el estado de los pedidos pendientes realizados antes del 1 de mayo de 2026.
UPDATE pedidos 
SET estado = 'En preparación' 
WHERE estado = 'Pendiente' 
  AND fecha_pedido < '2026-05-01 00:00:00';
  
-- 9. Eliminar las líneas de detalle que pertenezcan a pedidos cancelados.
DELETE d 
FROM detalle_pedido d
INNER JOIN pedidos p ON d.id_pedido = p.id_pedido
WHERE p.estado = 'Cancelado';

-- 10. Eliminar los pedidos cancelados una vez eliminadas sus líneas de detalle.
DELETE FROM pedidos 
WHERE estado = 'Cancelado';

COMMIT;
