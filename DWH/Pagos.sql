-- =============================================
-- RanchoDW — ESTRELLA 4
-- Proceso : Pagos y facturación
-- =============================================

USE RanchoDW;
GO

-- =============================================
-- PASO 1 — CREAR DIMENSIONES (propias E4)
-- =============================================

CREATE TABLE dim_tiempo_pag (
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

CREATE TABLE dim_cliente_pag (
    id_cliente      INT         PRIMARY KEY,
    nombre_completo VARCHAR(100),
    tiene_ruc       BIT,
    tipo_cliente    VARCHAR(20)
);
GO

CREATE TABLE dim_metodo_pago (
    id_metodo     INT         PRIMARY KEY IDENTITY(1,1),
    nombre_metodo VARCHAR(50)
);
GO

CREATE TABLE dim_comprobante (
    id_comprobante     INT         PRIMARY KEY IDENTITY(1,1),
    tipo_comprobante   VARCHAR(30),
    estado_comprobante VARCHAR(30)
);
GO

-- =============================================
-- PASO 2 — CREAR TABLA DE HECHOS ESTRELLA 4
-- =============================================

CREATE TABLE fact_pagos (
    id_fact              INT          PRIMARY KEY IDENTITY(1,1),

    fecha_pago           DATE         NOT NULL,
    id_cliente           INT          NULL,
    id_metodo            INT          NOT NULL,
    id_comprobante_dim   INT          NOT NULL,

    -- Trazabilidad OLTP (sin FK, atributos degenerados)
    id_pago              INT,
    id_comprobante_oltp  INT,
    id_pedido            INT,

    -- Métricas financieras
    monto_pago           DECIMAL(10,2),
    subtotal             DECIMAL(10,2),
    igv                  DECIMAL(10,2),
    monto_total          DECIMAL(10,2),
    tiene_ruc            BIT,

    CONSTRAINT FK_fpg_tiempo
        FOREIGN KEY (fecha_pago)         REFERENCES dim_tiempo_pag(fecha),
    CONSTRAINT FK_fpg_cliente
        FOREIGN KEY (id_cliente)         REFERENCES dim_cliente_pag(id_cliente),
    CONSTRAINT FK_fpg_metodo
        FOREIGN KEY (id_metodo)          REFERENCES dim_metodo_pago(id_metodo),
    CONSTRAINT FK_fpg_comprobante
        FOREIGN KEY (id_comprobante_dim) REFERENCES dim_comprobante(id_comprobante)
);
GO

-- =============================================
-- PASO 3 — CARGAR DIMENSIONES (ETL)
-- =============================================

INSERT INTO dim_tiempo_pag (
    fecha, dia, nombre_dia, semana,
    mes, nombre_mes, trimestre, anio, es_fin_semana
)
SELECT DISTINCT
    CAST(pa.Fecha_Hora_Pago AS DATE),
    DAY(pa.Fecha_Hora_Pago),
    DATENAME(WEEKDAY, pa.Fecha_Hora_Pago),
    DATEPART(WEEK, pa.Fecha_Hora_Pago),
    MONTH(pa.Fecha_Hora_Pago),
    DATENAME(MONTH, pa.Fecha_Hora_Pago),
    DATEPART(QUARTER, pa.Fecha_Hora_Pago),
    YEAR(pa.Fecha_Hora_Pago),
    CASE WHEN DATEPART(WEEKDAY, pa.Fecha_Hora_Pago) IN (1,7) THEN 1 ELSE 0 END
FROM RanchoDB.dbo.Pago pa
WHERE pa.Fecha_Hora_Pago IS NOT NULL;
GO

INSERT INTO dim_cliente_pag (id_cliente, nombre_completo, tiene_ruc, tipo_cliente)
SELECT
    ID_Cliente,
    CONCAT(Nombre, ' ', Apellidos),
    CASE WHEN RUC IS NOT NULL THEN 1 ELSE 0 END,
    CASE WHEN RUC IS NOT NULL THEN 'Empresa' ELSE 'Natural' END
FROM RanchoDB.dbo.Cliente;
GO

INSERT INTO dim_metodo_pago (nombre_metodo)
SELECT DISTINCT Metodo_Pago
FROM RanchoDB.dbo.Pago
WHERE Metodo_Pago IS NOT NULL;
GO

INSERT INTO dim_comprobante (tipo_comprobante, estado_comprobante)
SELECT DISTINCT Tipo_Comprobante, Estado_Comprobante
FROM RanchoDB.dbo.Comprobante_Pago
WHERE Tipo_Comprobante   IS NOT NULL
  AND Estado_Comprobante IS NOT NULL;
GO

-- =============================================
-- PASO 4 — CARGAR TABLA DE HECHOS (ETL)
-- =============================================

INSERT INTO fact_pagos (
    fecha_pago, id_cliente, id_metodo, id_comprobante_dim,
    id_pago, id_comprobante_oltp, id_pedido,
    monto_pago, subtotal, igv, monto_total, tiene_ruc
)
SELECT
    CAST(pa.Fecha_Hora_Pago AS DATE),
    pe.ID_Cliente,
    (SELECT TOP 1 dm.id_metodo
     FROM dim_metodo_pago dm
     WHERE dm.nombre_metodo = pa.Metodo_Pago),
    (SELECT TOP 1 dc.id_comprobante
     FROM dim_comprobante dc
     WHERE dc.tipo_comprobante   = cp.Tipo_Comprobante
       AND dc.estado_comprobante = cp.Estado_Comprobante),
    pa.ID_Pago,
    cp.ID_Comprobante,
    pe.ID_Pedido,
    pa.Monto,
    cp.Sub_Total,
    cp.IGV,
    cp.Monto_Total,
    CASE WHEN cp.RUC IS NOT NULL AND cp.RUC <> '' THEN 1 ELSE 0 END
FROM RanchoDB.dbo.Comprobante_Pago cp
INNER JOIN RanchoDB.dbo.Pago pa   ON pa.ID_Pedido = cp.ID_Pedido
INNER JOIN RanchoDB.dbo.Pedido pe ON pe.ID_Pedido = cp.ID_Pedido;
GO

-- =============================================
-- PASO 5 — VERIFICAR DATOS
-- =============================================

SELECT * FROM dim_tiempo_pag;
SELECT * FROM dim_cliente_pag;
SELECT * FROM dim_metodo_pago;
SELECT * FROM dim_comprobante;
SELECT * FROM fact_pagos;
GO

-- =============================================
-- PASO 6 — CONSULTAS OLAP
-- =============================================

-- OLAP 4.1: Ingresos totales por método de pago (Drill-down)
SELECT
    dmp.nombre_metodo    AS metodo_pago,
    COUNT(fp.id_fact)    AS num_transacciones,
    SUM(fp.monto_pago)   AS monto_total_soles,
    AVG(fp.monto_pago)   AS ticket_promedio
FROM fact_pagos fp
INNER JOIN dim_metodo_pago dmp ON fp.id_metodo = dmp.id_metodo
GROUP BY dmp.nombre_metodo
ORDER BY monto_total_soles DESC;
GO

-- OLAP 4.2: Ingresos por mes y método de pago (Roll-up)
SELECT
    dt.anio, dt.nombre_mes, dt.mes,
    dmp.nombre_metodo,
    COUNT(fp.id_fact)   AS transacciones,
    SUM(fp.monto_total) AS ingresos_soles
FROM fact_pagos fp
INNER JOIN dim_tiempo_pag  dt  ON fp.fecha_pago = dt.fecha
INNER JOIN dim_metodo_pago dmp ON fp.id_metodo  = dmp.id_metodo
GROUP BY dt.anio, dt.mes, dt.nombre_mes, dmp.nombre_metodo
ORDER BY dt.anio, dt.mes, ingresos_soles DESC;
GO

-- OLAP 4.3: Comprobantes emitidos por tipo y estado (Slice)
SELECT
    dc.tipo_comprobante,
    dc.estado_comprobante,
    COUNT(fp.id_fact)   AS cantidad_emitida,
    SUM(fp.subtotal)    AS subtotal_soles,
    SUM(fp.igv)         AS igv_soles,
    SUM(fp.monto_total) AS total_soles
FROM fact_pagos fp
INNER JOIN dim_comprobante dc ON fp.id_comprobante_dim = dc.id_comprobante
GROUP BY dc.tipo_comprobante, dc.estado_comprobante
ORDER BY total_soles DESC;
GO

-- OLAP 4.4: Ingresos por día de semana (Slice — días pico)
SELECT
    dt.nombre_dia, dt.es_fin_semana,
    COUNT(fp.id_fact)   AS transacciones,
    SUM(fp.monto_total) AS ingresos_soles,
    AVG(fp.monto_total) AS ticket_promedio
FROM fact_pagos fp
INNER JOIN dim_tiempo_pag dt ON fp.fecha_pago = dt.fecha
GROUP BY dt.nombre_dia, dt.es_fin_semana
ORDER BY ingresos_soles DESC;
GO

-- OLAP 4.5: Top 10 clientes con mayor gasto (Drill-down)
SELECT TOP 10
    dc.nombre_completo, dc.tipo_cliente,
    COUNT(fp.id_fact)   AS num_pagos,
    SUM(fp.monto_total) AS gasto_total_soles,
    AVG(fp.monto_total) AS gasto_promedio
FROM fact_pagos fp
INNER JOIN dim_cliente_pag dc ON fp.id_cliente = dc.id_cliente
GROUP BY dc.nombre_completo, dc.tipo_cliente
ORDER BY gasto_total_soles DESC;
GO

-- OLAP 4.6: Proporción facturas vs boletas por mes (Slice)
SELECT
    dt.anio, dt.nombre_mes,
    dc.tipo_comprobante,
    COUNT(fp.id_fact)   AS cantidad,
    SUM(fp.monto_total) AS total_soles
FROM fact_pagos fp
INNER JOIN dim_tiempo_pag  dt ON fp.fecha_pago         = dt.fecha
INNER JOIN dim_comprobante dc ON fp.id_comprobante_dim = dc.id_comprobante
GROUP BY dt.anio, dt.mes, dt.nombre_mes, dc.tipo_comprobante
ORDER BY dt.anio, dt.mes, total_soles DESC;
GO




-- Verificar tablas de hechos
SELECT COUNT(*) AS fact_ventas     FROM fact_ventas;
SELECT COUNT(*) AS fact_inventario FROM fact_inventario;
SELECT COUNT(*) AS fact_pedidos    FROM fact_pedidos;
SELECT COUNT(*) AS fact_pagos      FROM fact_pagos;
