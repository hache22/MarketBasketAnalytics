-- =====================================================
-- ANÁLISIS EXPLORATORIO DE DATOS - MARKET BASKET ANALYTICS
-- Autor: Horacio Laphitz
-- Fecha: 2025-07-29
-- Descripción: Consultas SQL para análisis exploratorio de datos de tickets de venta
-- =====================================================

-- =====================================================
-- 1. ANÁLISIS GENERAL DE DATOS
-- =====================================================

-- Verificar el volumen total de registros
SELECT COUNT(*) as total_registros
FROM tickets;

-- Ingresos totales del negocio
SELECT SUM(precio_total) as ingreso_total_empresa
FROM tickets;

-- Total de pedidos únicos
SELECT COUNT(DISTINCT id_pedido) as total_pedidos_unicos
FROM tickets;

-- =====================================================
-- 2. ANÁLISIS TEMPORAL
-- =====================================================

-- Tendencia de ingresos mensuales
SELECT 
    strftime('%Y-%m', fecha) as mes, 
    SUM(precio_total) as ventas_mensuales,
    COUNT(DISTINCT id_pedido) as pedidos_mes
FROM tickets
GROUP BY mes
ORDER BY mes;

-- =====================================================
-- 3. ANÁLISIS POR DEPARTAMENTO Y SECCIÓN
-- =====================================================

-- Rendimiento por departamento (ventas)
SELECT 
    id_departamento, 
    SUM(precio_total) AS ventas_departamento,
    COUNT(DISTINCT nombre_producto) as productos_departamento
FROM tickets  
GROUP BY id_departamento  
ORDER BY ventas_departamento DESC;

-- Top 10 secciones con mayores ventas
SELECT 
    id_seccion, 
    SUM(precio_total) AS ventas_seccion,
    COUNT(DISTINCT nombre_producto) as productos_seccion
FROM tickets  
GROUP BY id_seccion  
ORDER BY ventas_seccion DESC
LIMIT 10;

-- =====================================================
-- 4. ANÁLISIS DE PRODUCTOS
-- =====================================================

-- Top 10 productos que generan más ingresos
SELECT 
    nombre_producto, 
    SUM(precio_total) as ventas_producto,
    SUM(cantidad) as cantidad_total_vendida,
    COUNT(DISTINCT id_cliente) as clientes_compradores
FROM tickets
GROUP BY nombre_producto
ORDER BY ventas_producto DESC
LIMIT 10;

-- Top 10 productos más vendidos por cantidad
SELECT 
    nombre_producto, 
    SUM(cantidad) as cantidad_vendida,
    SUM(precio_total) as ingresos_producto,
    COUNT(DISTINCT id_pedido) as apariciones_pedidos
FROM tickets
GROUP BY nombre_producto
ORDER BY cantidad_vendida DESC
LIMIT 10;

-- =====================================================
-- 5. ANÁLISIS DE CLIENTES
-- =====================================================

-- Top 20 clientes con mayor volumen de compras
SELECT 
    id_cliente, 
    SUM(precio_total) as gasto_total_cliente,
    COUNT(DISTINCT id_pedido) as pedidos_realizados,
    COUNT(DISTINCT nombre_producto) as productos_diferentes_comprados
FROM tickets
GROUP BY id_cliente
ORDER BY gasto_total_cliente DESC
LIMIT 20;

-- Productos únicos comprados por cliente
SELECT 
    id_cliente, 
    COUNT(DISTINCT nombre_producto) as productos_unicos_comprados,
    SUM(precio_total) as gasto_total
FROM tickets
GROUP BY id_cliente
ORDER BY productos_unicos_comprados DESC
LIMIT 15;

-- =====================================================
-- 6. MÉTRICAS DE NEGOCIO
-- =====================================================

-- Ticket promedio por cliente
SELECT 
    ROUND(AVG(gasto_total_cliente), 2) as ticket_promedio_cliente
FROM (
    SELECT 
        id_cliente, 
        SUM(precio_total) AS gasto_total_cliente
    FROM tickets
    GROUP BY id_cliente 
) subconsulta_clientes;

-- Valor promedio por pedido
SELECT 
    ROUND(AVG(valor_pedido), 2) as ticket_promedio_pedido
FROM (
    SELECT 
        id_pedido,
        SUM(precio_total) as valor_pedido
    FROM tickets
    GROUP BY id_pedido
) subconsulta_pedidos;

-- Productos promedio por pedido
SELECT 
    ROUND(AVG(productos_por_pedido), 2) as productos_promedio_pedido
FROM (
    SELECT 
        id_pedido,
        COUNT(DISTINCT nombre_producto) as productos_por_pedido
    FROM tickets
    GROUP BY id_pedido
) subconsulta_productos_pedido;

-- =====================================================
-- 7. ANÁLISIS PARA MARKET BASKET
-- =====================================================

-- Preparación de datos para análisis de canasta
-- Pedidos con más de un producto (aptos para Market Basket Analysis)
SELECT 
    COUNT(*) as pedidos_multiples_productos
FROM (
    SELECT id_pedido
    FROM tickets
    GROUP BY id_pedido
    HAVING COUNT(DISTINCT nombre_producto) > 1
) pedidos_multiples;

-- Distribución de productos por pedido
SELECT 
    productos_por_pedido,
    COUNT(*) as cantidad_pedidos,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT id_pedido) FROM tickets), 2) as porcentaje
FROM (
    SELECT 
        id_pedido,
        COUNT(DISTINCT nombre_producto) as productos_por_pedido
    FROM tickets
    GROUP BY id_pedido
) distribucion
GROUP BY productos_por_pedido
ORDER BY productos_por_pedido;
