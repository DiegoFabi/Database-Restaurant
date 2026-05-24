-- =============================================
-- RanchoDW — ESTRELLA 3
-- Proceso : Análisis operativo de pedidos
-- =============================================

USE RanchoDW;
GO

-- =============================================
-- PASO 1 — CREAR DIMENSIONES (propias E3)
-- =============================================
CREATE TABLE dim_tiempo_pedido (
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

CREATE TABLE dim_producto_pedido (
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

CREATE TABLE dim_cliente_pedido (
    id_cliente      INT         PRIMARY KEY,
    nombre_completo VARCHAR(100),
    tiene_ruc       BIT,
    tipo_cliente    VARCHAR(20)
);
GO

CREATE TABLE dim_empleado_pedido (
    id_empleado     INT         PRIMARY KEY,
    nombre_completo VARCHAR(100),
    cargo           VARCHAR(100),
    estado          VARCHAR(15)
);
GO

CREATE TABLE dim_mesa_pedido (
    id_mesa     INT         PRIMARY KEY,
    numero_mesa INT,
    capacidad   INT,
    ubicacion   VARCHAR(100)
);
GO

CREATE TABLE dim_estado_pedido (
    id_estado     INT         PRIMARY KEY IDENTITY(1,1),
    nombre_estado VARCHAR(50)
);
GO

-- =============================================
-- PASO 2 — CREAR TABLA DE HECHOS ESTRELLA 3
-- =============================================

CREATE TABLE fact_pedidos (
    id_fact        INT          PRIMARY KEY IDENTITY(1,1),

    fecha_pedido   DATE         NOT NULL,
    id_producto    INT          NOT NULL,
    id_cliente     INT          NULL,
    id_empleado    INT          NOT NULL,
    id_mesa        INT          NULL,
    id_estado      INT          NOT NULL,

    -- Trazabilidad OLTP
    id_pedido      INT,
    id_detalle     INT,

    -- Métricas
    cantidad        INT,
    precio_unitario DECIMAL(10,2),
    subtotal_linea  DECIMAL(10,2),

    CONSTRAINT FK_fp_tiempo
        FOREIGN KEY (fecha_pedido) REFERENCES dim_tiempo_pedido(fecha),
    CONSTRAINT FK_fp_producto
        FOREIGN KEY (id_producto)  REFERENCES dim_producto_pedido(id_producto),
    CONSTRAINT FK_fp_cliente
        FOREIGN KEY (id_cliente)   REFERENCES dim_cliente_pedido(id_cliente),
    CONSTRAINT FK_fp_empleado
        FOREIGN KEY (id_empleado)  REFERENCES dim_empleado_pedido(id_empleado),
    CONSTRAINT FK_fp_mesa
        FOREIGN KEY (id_mesa)      REFERENCES dim_mesa_pedido(id_mesa),
    CONSTRAINT FK_fp_estado
        FOREIGN KEY (id_estado)    REFERENCES dim_estado_pedido(id_estado)
);
GO

-- =============================================
-- PASO 3 — CARGAR DIMENSIONES (ETL)
-- =============================================

INSERT INTO dim_tiempo_pedido (
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
WHERE p.Fecha IS NOT NULL;
GO

INSERT INTO dim_producto_pedido (
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

INSERT INTO dim_cliente_pedido (id_cliente, nombre_completo, tiene_ruc, tipo_cliente)
SELECT
    ID_Cliente,
    CONCAT(Nombre, ' ', Apellidos),
    CASE WHEN RUC IS NOT NULL THEN 1 ELSE 0 END,
    CASE WHEN RUC IS NOT NULL THEN 'Empresa' ELSE 'Natural' END
FROM RanchoDB.dbo.Cliente;
GO

INSERT INTO dim_empleado_pedido (id_empleado, nombre_completo, cargo, estado)
SELECT ID_Empleado, CONCAT(Nombre, ' ', Apellidos), Cargo, Estado
FROM RanchoDB.dbo.Empleado;
GO

INSERT INTO dim_mesa_pedido (id_mesa, numero_mesa, capacidad, ubicacion)
SELECT ID_Mesa, Numero_Mesa, Capacidad, Ubicacion
FROM RanchoDB.dbo.Mesa_Restaurante;
GO

-- Carga todos los estados distintos del OLTP
INSERT INTO dim_estado_pedido (nombre_estado)
SELECT DISTINCT Estado_Pedido
FROM RanchoDB.dbo.Pedido
WHERE Estado_Pedido IS NOT NULL;
GO

-- =============================================
-- PASO 4 — CARGAR TABLA DE HECHOS (ETL)
-- =============================================

INSERT INTO fact_pedidos (
    fecha_pedido, id_producto, id_cliente, id_empleado,
    id_mesa, id_estado, id_pedido, id_detalle,
    cantidad, precio_unitario, subtotal_linea
)
SELECT
    CAST(pe.Fecha AS DATE),
    pd.ID_Producto,
    pe.ID_Cliente,
    pe.ID_Empleado,
    pe.ID_Mesa,
    (SELECT TOP 1 dep.id_estado
     FROM dim_estado_pedido dep
     WHERE dep.nombre_estado = pe.Estado_Pedido),
    pe.ID_Pedido,
    pd.ID_Pedido_Detalle,
    pd.Cantidad,
    pd.PrecioUnitario,
    ROUND(pd.Cantidad * pd.PrecioUnitario, 2)
FROM RanchoDB.dbo.Pedido_Detalle pd
INNER JOIN RanchoDB.dbo.Pedido pe ON pd.ID_Pedido = pe.ID_Pedido;
GO

-- =============================================
-- PASO 5 — VERIFICAR DATOS
-- =============================================

SELECT * FROM dim_tiempo_pedido;
SELECT * FROM dim_producto_pedido;
SELECT * FROM dim_cliente_pedido;
SELECT * FROM dim_empleado_pedido;
SELECT * FROM dim_mesa_pedido;
SELECT * FROM dim_estado_pedido;
SELECT * FROM fact_pedidos;
GO

-- =============================================
-- PASO 6 — CONSULTAS OLAP
-- =============================================

-- OLAP 3.1: Productos más pedidos por fecha (Drill-down)
SELECT
    dt.fecha, dt.nombre_dia,
    dp.nombre_plato, dp.nombre_categoria,
    SUM(fp.cantidad)       AS unidades_pedidas,
    SUM(fp.subtotal_linea) AS subtotal_soles
FROM fact_pedidos fp
INNER JOIN dim_tiempo_pedido   dt ON fp.fecha_pedido = dt.fecha
INNER JOIN dim_producto_pedido dp ON fp.id_producto  = dp.id_producto
GROUP BY dt.fecha, dt.nombre_dia, dp.nombre_plato, dp.nombre_categoria
ORDER BY dt.fecha, unidades_pedidas DESC;
GO

-- OLAP 3.2: Top 10 productos más pedidos del período (Roll-up)
SELECT TOP 10
    dp.nombre_plato, dp.nombre_categoria,
    SUM(fp.cantidad)             AS total_unidades,
    SUM(fp.subtotal_linea)       AS subtotal_soles,
    COUNT(DISTINCT fp.id_pedido) AS en_num_pedidos
FROM fact_pedidos fp
INNER JOIN dim_producto_pedido dp ON fp.id_producto = dp.id_producto
GROUP BY dp.nombre_plato, dp.nombre_categoria
ORDER BY total_unidades DESC;
GO

-- OLAP 3.3: Pedidos por estado operativo (Slice)
SELECT
    de.nombre_estado,
    COUNT(DISTINCT fp.id_pedido) AS num_pedidos,
    SUM(fp.cantidad)             AS unidades_solicitadas,
    SUM(fp.subtotal_linea)       AS subtotal_soles
FROM fact_pedidos fp
INNER JOIN dim_estado_pedido de ON fp.id_estado = de.id_estado
GROUP BY de.nombre_estado
ORDER BY num_pedidos DESC;
GO

-- OLAP 3.4: Pedidos por día de semana (días pico operativos)
SELECT
    dt.nombre_dia, dt.es_fin_semana,
    COUNT(DISTINCT fp.id_pedido) AS num_pedidos,
    SUM(fp.cantidad)             AS unidades_pedidas,
    SUM(fp.subtotal_linea)       AS subtotal_soles
FROM fact_pedidos fp
INNER JOIN dim_tiempo_pedido dt ON fp.fecha_pedido = dt.fecha
GROUP BY dt.nombre_dia, dt.es_fin_semana
ORDER BY num_pedidos DESC;
GO

-- OLAP 3.5: Carga operativa por empleado (Drill-down)
SELECT
    de.nombre_completo AS empleado, de.cargo,
    COUNT(DISTINCT fp.id_pedido) AS pedidos_gestionados,
    SUM(fp.cantidad)             AS platos_preparados,
    SUM(fp.subtotal_linea)       AS subtotal_soles
FROM fact_pedidos fp
INNER JOIN dim_empleado_pedido de ON fp.id_empleado = de.id_empleado
GROUP BY de.nombre_completo, de.cargo
ORDER BY pedidos_gestionados DESC;
GO

-- OLAP 3.6: Producto más solicitado por mesa (Drill-down)
SELECT
    dm.numero_mesa, dm.ubicacion, dp.nombre_plato,
    SUM(fp.cantidad)       AS unidades_pedidas,
    SUM(fp.subtotal_linea) AS subtotal_soles
FROM fact_pedidos fp
INNER JOIN dim_mesa_pedido     dm ON fp.id_mesa     = dm.id_mesa
INNER JOIN dim_producto_pedido dp ON fp.id_producto = dp.id_producto
GROUP BY dm.numero_mesa, dm.ubicacion, dp.nombre_plato
ORDER BY dm.numero_mesa, unidades_pedidas DESC;
GO