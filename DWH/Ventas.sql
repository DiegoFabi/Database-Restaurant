
-- =============================================
-- RanchoDW — ESTRELLA 1
-- Proceso : Ventas (proceso COMERCIAL)
-- =============================================

CREATE DATABASE RanchoDW;
GO

USE RanchoDW;
GO

-- =============================================
-- PASO 1 — CREAR DIMENSIONES (propias E1)
-- =============================================

CREATE TABLE dim_tiempo_ventas (
    fecha         DATE    PRIMARY KEY,
    dia           INT,
    nombre_dia    VARCHAR(15),
    semana        INT,
    mes           INT,
    nombre_mes    VARCHAR(15),
    trimestre     INT,
    anio          INT,
    es_fin_semana BIT
);
GO

CREATE TABLE dim_producto_ventas (
    id_producto      INT          PRIMARY KEY,
    nombre_plato     VARCHAR(100),
    categoria        VARCHAR(50),
    nombre_categoria VARCHAR(50),
    nombre_carta     VARCHAR(100),
    precio_unitario  DECIMAL(8,2),
    disponibilidad   BIT,
    tiempo_prep_min  FLOAT
);
GO

CREATE TABLE dim_cliente_ventas (
    id_cliente      INT         PRIMARY KEY,
    nombre_completo VARCHAR(100),
    tiene_ruc       BIT,
    tipo_cliente    VARCHAR(20)
);
GO

CREATE TABLE dim_empleado_ventas (
    id_empleado     INT         PRIMARY KEY,
    nombre_completo VARCHAR(100),
    cargo           VARCHAR(100),
    estado          VARCHAR(15)
);
GO

CREATE TABLE dim_mesa_ventas (
    id_mesa     INT         PRIMARY KEY,
    numero_mesa INT,
    capacidad   INT,
    ubicacion   VARCHAR(100)
);
GO

CREATE TABLE dim_proveedor_ventas (
    id_proveedor    INT          PRIMARY KEY,
    nombre_empresa  VARCHAR(200),
    tipo_suministro VARCHAR(200),
    estado          VARCHAR(50)
);
GO

CREATE TABLE dim_promocion_ventas (
    id_promocion         INT         PRIMARY KEY,
    nombre_promocion     VARCHAR(100),
    porcentaje_descuento DECIMAL(5,2),
    estado               BIT
);
GO

-- =============================================
-- PASO 2 — CREAR TABLA DE HECHOS
-- =============================================

CREATE TABLE fact_ventas (
    id_fact            INT          PRIMARY KEY IDENTITY(1,1),

    fecha_venta        DATE         NOT NULL,
    id_producto        INT          NOT NULL,
    id_cliente         INT          NULL,
    id_empleado        INT          NOT NULL,
    id_mesa            INT          NULL,
    id_proveedor       INT          NULL,
    id_promocion       INT          NULL,

    id_pedido          INT,
    id_pago            INT,
    id_comprobante     INT,

    -- Métricas comerciales
    cantidad           INT,
    precio_unitario    DECIMAL(10,2),
    subtotal_linea     DECIMAL(10,2),
    igv_linea          DECIMAL(10,2),
    total_linea        DECIMAL(10,2),
    descuento_aplicado DECIMAL(10,2),
    metodo_pago        VARCHAR(50),
    tipo_comprobante   VARCHAR(30),

    CONSTRAINT FK_fv_tiempo
        FOREIGN KEY (fecha_venta)  REFERENCES dim_tiempo_ventas(fecha),
    CONSTRAINT FK_fv_producto
        FOREIGN KEY (id_producto)  REFERENCES dim_producto_ventas(id_producto),
    CONSTRAINT FK_fv_cliente
        FOREIGN KEY (id_cliente)   REFERENCES dim_cliente_ventas(id_cliente),
    CONSTRAINT FK_fv_empleado
        FOREIGN KEY (id_empleado)  REFERENCES dim_empleado_ventas(id_empleado),
    CONSTRAINT FK_fv_mesa
        FOREIGN KEY (id_mesa)      REFERENCES dim_mesa_ventas(id_mesa),
    CONSTRAINT FK_fv_proveedor
        FOREIGN KEY (id_proveedor) REFERENCES dim_proveedor_ventas(id_proveedor),
    CONSTRAINT FK_fv_promocion
        FOREIGN KEY (id_promocion) REFERENCES dim_promocion_ventas(id_promocion)
);
GO

-- =============================================
-- PASO 3 — CARGAR DIMENSIONES (ETL)
-- =============================================

INSERT INTO dim_tiempo_ventas (
    fecha, dia, nombre_dia, semana,
    mes, nombre_mes, trimestre, anio, es_fin_semana
)
SELECT DISTINCT
    CAST(p.Fecha AS DATE),
    DAY(p.Fecha),
    DATENAME(WEEKDAY, p.Fecha),
    DATEPART(WEEK, p.Fecha),
    MONTH(p.Fecha),
    DATENAME(MONTH, p.Fecha),
    DATEPART(QUARTER, p.Fecha),
    YEAR(p.Fecha),
    CASE WHEN DATEPART(WEEKDAY, p.Fecha) IN (1,7) THEN 1 ELSE 0 END
FROM RanchoDB.dbo.Pedido p
WHERE p.Fecha IS NOT NULL
  AND p.Estado_Pedido IN ('Entregado', 'Completado'); 
GO

INSERT INTO dim_producto_ventas (
    id_producto, nombre_plato, categoria,
    nombre_categoria, nombre_carta,
    precio_unitario, disponibilidad, tiempo_prep_min
)
SELECT
    pr.ID_Producto, pr.Nombre_Plato, pr.Categoria,
    pc.Nombre_Categoria, c.Nombre_Carta,
    pr.Precio, pr.Disponibilidad, pr.Tiempo_Preparacion
FROM RanchoDB.dbo.Producto pr
INNER JOIN RanchoDB.dbo.Producto_Categoria pc ON pr.ID_Categoria = pc.ID_Categoria
INNER JOIN RanchoDB.dbo.Carta c               ON pc.ID_Carta     = c.ID_Carta;
GO

INSERT INTO dim_cliente_ventas (id_cliente, nombre_completo, tiene_ruc, tipo_cliente)
SELECT
    ID_Cliente,
    CONCAT(Nombre, ' ', Apellidos),
    CASE WHEN RUC IS NOT NULL THEN 1 ELSE 0 END,
    CASE WHEN RUC IS NOT NULL THEN 'Empresa' ELSE 'Natural' END
FROM RanchoDB.dbo.Cliente;
GO

INSERT INTO dim_empleado_ventas (id_empleado, nombre_completo, cargo, estado)
SELECT ID_Empleado, CONCAT(Nombre, ' ', Apellidos), Cargo, Estado
FROM RanchoDB.dbo.Empleado;
GO

INSERT INTO dim_mesa_ventas (id_mesa, numero_mesa, capacidad, ubicacion)
SELECT ID_Mesa, Numero_Mesa, Capacidad, Ubicacion
FROM RanchoDB.dbo.Mesa_Restaurante;
GO

INSERT INTO dim_proveedor_ventas (id_proveedor, nombre_empresa, tipo_suministro, estado)
SELECT ID_Proveedor, Nombre_Empresa, Tipo_Suministro, Estado
FROM RanchoDB.dbo.Proveedor;
GO

INSERT INTO dim_promocion_ventas (id_promocion, nombre_promocion, porcentaje_descuento, estado)
SELECT ID_Promocion, Nombre, Porcentaje_Descuento, Estado
FROM RanchoDB.dbo.Promocion;
GO

-- =============================================
-- PASO 4 — CARGAR TABLA DE HECHOS (ETL)
-- =============================================

INSERT INTO fact_ventas (
    fecha_venta, id_producto, id_cliente, id_empleado,
    id_mesa, id_proveedor, id_promocion,
    id_pedido, id_pago, id_comprobante,
    cantidad, precio_unitario,
    subtotal_linea, igv_linea, total_linea,
    descuento_aplicado, metodo_pago, tipo_comprobante
)
SELECT
    CAST(pe.Fecha AS DATE),
    pd.ID_Producto,
    pe.ID_Cliente,
    pe.ID_Empleado,
    pe.ID_Mesa,
    (SELECT TOP 1 pi2.ID_Proveedor
     FROM RanchoDB.dbo.Proveedor_Ingrediente pi2
     INNER JOIN RanchoDB.dbo.Producto_Ingrediente pring
         ON pi2.ID_Ingrediente = pring.ID_Ingrediente
     WHERE pring.ID_Producto = pd.ID_Producto),
    (SELECT TOP 1 pp.ID_Promocion
     FROM RanchoDB.dbo.Producto_Promocion pp
     INNER JOIN RanchoDB.dbo.Promocion promo ON pp.ID_Promocion = promo.ID_Promocion
     WHERE pp.ID_Producto = pd.ID_Producto AND promo.Estado = 1),
    pe.ID_Pedido,
    (SELECT TOP 1 pa.ID_Pago
     FROM RanchoDB.dbo.Pago pa WHERE pa.ID_Pedido = pe.ID_Pedido),
    (SELECT TOP 1 cp.ID_Comprobante
     FROM RanchoDB.dbo.Comprobante_Pago cp WHERE cp.ID_Pedido = pe.ID_Pedido),
    pd.Cantidad,
    pd.PrecioUnitario,
    ROUND(pd.Cantidad * pd.PrecioUnitario, 2),
    ROUND(pd.Cantidad * pd.PrecioUnitario * 0.18, 2),
    ROUND(pd.Cantidad * pd.PrecioUnitario * 1.18, 2),
    ISNULL(
        ROUND(pd.Cantidad * pd.PrecioUnitario *
            (SELECT TOP 1 promo2.Porcentaje_Descuento / 100.0
             FROM RanchoDB.dbo.Producto_Promocion pp2
             INNER JOIN RanchoDB.dbo.Promocion promo2
                 ON pp2.ID_Promocion = promo2.ID_Promocion
             WHERE pp2.ID_Producto = pd.ID_Producto
               AND promo2.Estado = 1), 2)
    , 0.00),
    (SELECT TOP 1 pa2.Metodo_Pago
     FROM RanchoDB.dbo.Pago pa2 WHERE pa2.ID_Pedido = pe.ID_Pedido),
    (SELECT TOP 1 cp2.Tipo_Comprobante
     FROM RanchoDB.dbo.Comprobante_Pago cp2 WHERE cp2.ID_Pedido = pe.ID_Pedido)
FROM RanchoDB.dbo.Pedido_Detalle pd
INNER JOIN RanchoDB.dbo.Pedido pe
    ON pd.ID_Pedido = pe.ID_Pedido
WHERE pe.Estado_Pedido IN ('Entregado', 'Completado'); 
GO

-- =============================================
-- PASO 5 — VERIFICAR DATOS
-- =============================================

SELECT * FROM dim_tiempo_ventas;
SELECT * FROM dim_producto_ventas;
SELECT * FROM dim_cliente_ventas;
SELECT * FROM dim_empleado_ventas;
SELECT * FROM dim_mesa_ventas;
SELECT * FROM dim_proveedor_ventas;
SELECT * FROM dim_promocion_ventas;
SELECT * FROM fact_ventas;
GO

-- =============================================
-- PASO 6 — CONSULTAS OLAP
-- =============================================

-- OLAP 1.1: Ventas totales por mes y año (Roll-up)
SELECT
    dt.anio, dt.nombre_mes, dt.mes,
    SUM(fv.subtotal_linea)       AS subtotal_soles,
    SUM(fv.igv_linea)            AS igv_soles,
    SUM(fv.total_linea)          AS total_soles,
    COUNT(DISTINCT fv.id_pedido) AS num_pedidos
FROM fact_ventas fv
INNER JOIN dim_tiempo_ventas dt ON fv.fecha_venta = dt.fecha
GROUP BY dt.anio, dt.mes, dt.nombre_mes
ORDER BY dt.anio, dt.mes;
GO

-- OLAP 1.2: Top 10 platos más vendidos (Drill-down)
SELECT TOP 10
    dp.nombre_plato, dp.nombre_categoria, dp.nombre_carta,
    SUM(fv.cantidad)        AS unidades_vendidas,
    SUM(fv.subtotal_linea)  AS ingresos_soles,
    AVG(fv.precio_unitario) AS precio_promedio
FROM fact_ventas fv
INNER JOIN dim_producto_ventas dp ON fv.id_producto = dp.id_producto
GROUP BY dp.nombre_plato, dp.nombre_categoria, dp.nombre_carta
ORDER BY unidades_vendidas DESC;
GO

-- OLAP 1.3: Ventas por categoría y mes (Slice)
SELECT
    dp.nombre_categoria, dt.nombre_mes, dt.anio,
    SUM(fv.cantidad)    AS unidades_vendidas,
    SUM(fv.total_linea) AS total_soles
FROM fact_ventas fv
INNER JOIN dim_producto_ventas dp ON fv.id_producto = dp.id_producto
INNER JOIN dim_tiempo_ventas   dt ON fv.fecha_venta = dt.fecha
GROUP BY dp.nombre_categoria, dt.nombre_mes, dt.anio, dt.mes
ORDER BY dt.anio, dt.mes, total_soles DESC;
GO

-- OLAP 1.4: Rendimiento comercial por empleado (Drill-down)
SELECT
    de.nombre_completo AS empleado, de.cargo,
    COUNT(DISTINCT fv.id_pedido) AS pedidos_cerrados,
    SUM(fv.cantidad)             AS platos_vendidos,
    SUM(fv.total_linea)          AS ventas_generadas_soles
FROM fact_ventas fv
INNER JOIN dim_empleado_ventas de ON fv.id_empleado = de.id_empleado
GROUP BY de.nombre_completo, de.cargo
ORDER BY ventas_generadas_soles DESC;
GO

-- OLAP 1.5: Ticket promedio por día de semana (Slice)
SELECT
    dt.nombre_dia, dt.es_fin_semana,
    COUNT(DISTINCT fv.id_pedido) AS num_pedidos,
    SUM(fv.total_linea)          AS ventas_totales,
    AVG(fv.total_linea)          AS ticket_promedio
FROM fact_ventas fv
INNER JOIN dim_tiempo_ventas dt ON fv.fecha_venta = dt.fecha
GROUP BY dt.nombre_dia, dt.es_fin_semana
ORDER BY ventas_totales DESC;
GO

-- OLAP 1.6: Impacto de promociones en ventas
SELECT
    ISNULL(dp.nombre_promocion,              'Sin promoción') AS promocion,
    ISNULL(dp.porcentaje_descuento, CAST(0 AS DECIMAL(5,2))) AS pct_descuento,
    COUNT(*)                   AS lineas_venta,
    SUM(fv.subtotal_linea)     AS subtotal_soles,
    SUM(fv.descuento_aplicado) AS descuento_otorgado,
    SUM(fv.total_linea)        AS total_cobrado
FROM fact_ventas fv
LEFT JOIN dim_promocion_ventas dp ON fv.id_promocion = dp.id_promocion
GROUP BY dp.nombre_promocion, dp.porcentaje_descuento
ORDER BY total_cobrado DESC;
GO
