-- =============================================
-- RanchoDW — ESTRELLA 2
-- Proceso : Control de stock de ingredientes
-- =============================================

USE RanchoDW;
GO

-- =============================================
-- PASO 1 — CREAR DIMENSIONES (propias E2)
-- =============================================

CREATE TABLE dim_tiempo_inv (
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

CREATE TABLE dim_proveedor_inv (
    id_proveedor    INT          PRIMARY KEY,
    nombre_empresa  VARCHAR(200),
    tipo_suministro VARCHAR(200),
    estado          VARCHAR(50)
);
GO


CREATE TABLE dim_ingrediente (
    id_ingrediente     INT          PRIMARY KEY,
    nombre_ingrediente VARCHAR(100),
    unidad_medida      VARCHAR(20),
    descripcion        VARCHAR(200),
    costo_unitario     DECIMAL(10,2),
    estado             BIT,
    nombre_categoria   VARCHAR(50)
);
GO

-- =============================================
-- PASO 2 — CREAR TABLA DE HECHOS ESTRELLA 2
-- =============================================

CREATE TABLE fact_inventario (
    id_fact              INT          PRIMARY KEY IDENTITY(1,1),

    fecha_reposicion     DATE         NOT NULL,
    id_ingrediente       INT          NOT NULL,  
    id_proveedor         INT          NULL,

    id_inventario        INT,

    -- Métricas
    cantidad_stock       DECIMAL(10,2),
    stock_minimo         DECIMAL(10,2),
    stock_maximo         DECIMAL(10,2),
    unidades_bajo_minimo DECIMAL(10,2),
    costo_unitario       DECIMAL(10,2),
    costo_total_stock    DECIMAL(10,2),
    alerta_stock         BIT,

    CONSTRAINT FK_fi_tiempo
        FOREIGN KEY (fecha_reposicion) REFERENCES dim_tiempo_inv(fecha),
    CONSTRAINT FK_fi_ingrediente
        FOREIGN KEY (id_ingrediente)   REFERENCES dim_ingrediente(id_ingrediente),
    CONSTRAINT FK_fi_proveedor
        FOREIGN KEY (id_proveedor)     REFERENCES dim_proveedor_inv(id_proveedor)
);
GO

-- =============================================
-- PASO 3 — CARGAR DIMENSIONES (ETL)
-- =============================================

INSERT INTO dim_tiempo_inv (
    fecha, dia, nombre_dia, semana,
    mes, nombre_mes, trimestre, anio, es_fin_semana
)
SELECT DISTINCT
    inv.Fecha_Ultima_Reposicion,
    DAY(inv.Fecha_Ultima_Reposicion),
    DATENAME(WEEKDAY, inv.Fecha_Ultima_Reposicion),
    DATEPART(WEEK, inv.Fecha_Ultima_Reposicion),
    MONTH(inv.Fecha_Ultima_Reposicion),
    DATENAME(MONTH, inv.Fecha_Ultima_Reposicion),
    DATEPART(QUARTER, inv.Fecha_Ultima_Reposicion),
    YEAR(inv.Fecha_Ultima_Reposicion),
    CASE WHEN DATEPART(WEEKDAY, inv.Fecha_Ultima_Reposicion) IN (1,7)
         THEN 1 ELSE 0 END
FROM RanchoDB.dbo.Inventario inv
WHERE inv.Fecha_Ultima_Reposicion IS NOT NULL;
GO

INSERT INTO dim_proveedor_inv (id_proveedor, nombre_empresa, tipo_suministro, estado)
SELECT ID_Proveedor, Nombre_Empresa, Tipo_Suministro, Estado
FROM RanchoDB.dbo.Proveedor;
GO


INSERT INTO dim_ingrediente (
    id_ingrediente, nombre_ingrediente, unidad_medida,
    descripcion, costo_unitario, estado, nombre_categoria
)
SELECT
    i.ID_Ingrediente,
    i.Nombre_Ingrediente,
    i.Unidad_Medida,
    i.Descripcion,
    i.Costo_Unitario,
    i.Estado,
    ci.Nombre_Categoria  
FROM RanchoDB.dbo.Ingrediente i
INNER JOIN RanchoDB.dbo.Categoria_Ingrediente ci
    ON i.ID_Cat_Ingrediente = ci.ID_Cat_Ingrediente;
GO

-- =============================================
-- PASO 4 — CARGAR TABLA DE HECHOS (ETL)
-- =============================================

INSERT INTO fact_inventario (
    fecha_reposicion, id_ingrediente, id_proveedor,
    id_inventario, cantidad_stock, stock_minimo, stock_maximo,
    unidades_bajo_minimo, costo_unitario, costo_total_stock, alerta_stock
)
SELECT
    inv.Fecha_Ultima_Reposicion,
    inv.ID_Ingrediente,
    (SELECT TOP 1 pi2.ID_Proveedor
     FROM RanchoDB.dbo.Proveedor_Ingrediente pi2
     WHERE pi2.ID_Ingrediente = inv.ID_Ingrediente),
    inv.ID_Inventario,
    inv.Cantidad_Stock,
    inv.Stock_Minimo,
    inv.Stock_Maximo,
    ROUND(inv.Cantidad_Stock - inv.Stock_Minimo, 2),
    i.Costo_Unitario,
    ROUND(inv.Cantidad_Stock * i.Costo_Unitario, 2),
    CASE WHEN inv.Cantidad_Stock <= inv.Stock_Minimo THEN 1 ELSE 0 END
FROM RanchoDB.dbo.Inventario inv
INNER JOIN RanchoDB.dbo.Ingrediente i
    ON inv.ID_Ingrediente = i.ID_Ingrediente
WHERE inv.Fecha_Ultima_Reposicion IS NOT NULL;
GO

-- =============================================
-- PASO 5 — VERIFICAR DATOS
-- =============================================

SELECT * FROM dim_tiempo_inv;
SELECT * FROM dim_proveedor_inv;
SELECT * FROM dim_ingrediente;
SELECT * FROM fact_inventario;
GO

-- =============================================
-- PASO 6 — CONSULTAS OLAP
-- =============================================

-- OLAP 2.1: Stock por ingrediente y categoría (Drill-down)
SELECT
    di.nombre_categoria,
    di.nombre_ingrediente,
    di.unidad_medida,
    fi.cantidad_stock,
    fi.stock_minimo,
    fi.stock_maximo,
    fi.alerta_stock,
    fi.costo_total_stock
FROM fact_inventario fi
INNER JOIN dim_ingrediente di ON fi.id_ingrediente = di.id_ingrediente
ORDER BY fi.alerta_stock DESC, di.nombre_categoria, di.nombre_ingrediente;
GO

-- OLAP 2.2: Ingredientes con alerta de stock bajo (Slice)
SELECT
    di.nombre_ingrediente,
    di.nombre_categoria,
    di.unidad_medida,
    fi.cantidad_stock        AS stock_actual,
    fi.stock_minimo,
    fi.unidades_bajo_minimo  AS deficit,
    dp.nombre_empresa        AS proveedor
FROM fact_inventario fi
INNER JOIN dim_ingrediente   di ON fi.id_ingrediente = di.id_ingrediente
LEFT  JOIN dim_proveedor_inv dp ON fi.id_proveedor   = dp.id_proveedor
WHERE fi.alerta_stock = 1
ORDER BY fi.unidades_bajo_minimo ASC;
GO

-- OLAP 2.3: Costo total de inventario por categoría (Roll-up)
SELECT
    di.nombre_categoria,
    COUNT(fi.id_fact)         AS num_ingredientes,
    SUM(fi.cantidad_stock)    AS stock_total_unidades,
    SUM(fi.costo_total_stock) AS valor_total_soles
FROM fact_inventario fi
INNER JOIN dim_ingrediente di ON fi.id_ingrediente = di.id_ingrediente
GROUP BY di.nombre_categoria
ORDER BY valor_total_soles DESC;
GO

-- OLAP 2.4: Valor de inventario por proveedor (Drill-down)
SELECT
    ISNULL(dp.nombre_empresa, 'Sin proveedor asignado') AS proveedor,
    COUNT(fi.id_fact)         AS ingredientes_abastecidos,
    SUM(fi.costo_total_stock) AS valor_inventario_soles
FROM fact_inventario fi
LEFT JOIN dim_proveedor_inv dp ON fi.id_proveedor = dp.id_proveedor
GROUP BY dp.nombre_empresa
ORDER BY valor_inventario_soles DESC;
GO