CREATE DATABASE RanchoDB
GO

USE RanchoDB
GO

-- =============================================
-- CREACIÓN DE TABLAS
-- =============================================

CREATE TABLE [Empleado] (
  [ID_Empleado] INT           IDENTITY(1,1),
  [Nombre]      VARCHAR(50),
  [Apellidos]   VARCHAR(50),
  [Direccion]   VARCHAR(100),
  [Cargo]       VARCHAR(100),
  [Telefono]    VARCHAR(9),
  [Estado]      VARCHAR(15),
  [DNI]         VARCHAR(8),
  PRIMARY KEY ([ID_Empleado])
);

CREATE TABLE [Rol] (
  [ID_Rol]      INT,
  [Nombre_Rol]  VARCHAR(50),
  [Descripcion] VARCHAR(150),
  PRIMARY KEY ([ID_Rol])
);

CREATE TABLE [Usuario] (
  [ID_Usuario]     INT IDENTITY(1,1),
  [ID_Rol]         INT,
  [ID_Empleado]    INT,
  [Nombre_Usuario] VARCHAR(50),
  [Email]       VARCHAR(100),
  [Password]       VARCHAR(255),
  [Estado]         BIT,
  PRIMARY KEY ([ID_Usuario]),
  CONSTRAINT [FK_Usuario_ID_Empleado]
    FOREIGN KEY ([ID_Empleado])
      REFERENCES [Empleado]([ID_Empleado]),
  CONSTRAINT [FK_Usuario_ID_Rol]
    FOREIGN KEY ([ID_Rol])
      REFERENCES [Rol]([ID_Rol])
);

CREATE TABLE [Proveedor] (
  [ID_Proveedor]    INT IDENTITY(1,1),
  [Nombre_Empresa]  VARCHAR(200),
  [RUC]             VARCHAR(11),
  [Email_Contacto]  VARCHAR(100),
  [Telefono]        VARCHAR(9),
  [Direccion]       VARCHAR(250),
  [Tipo_Suministro] VARCHAR(200),
  [Estado]          VARCHAR(50),
  PRIMARY KEY ([ID_Proveedor])
);

CREATE TABLE [Contrato] (
  [ID_Contrato]   INT IDENTITY(1,1),
  [Fecha_Inicio]  DATE,
  [Fecha_Fin]     DATE,
  [Tipo_Contrato] VARCHAR(50),
  [Salario]       DECIMAL(10,2),
  [Clausula]      VARCHAR(500),
  [ID_Empleado]   INT,
  [ID_Proveedor]  INT,
  PRIMARY KEY ([ID_Contrato]),
  CONSTRAINT [FK_Contrato_ID_Empleado]
    FOREIGN KEY ([ID_Empleado])
      REFERENCES [Empleado]([ID_Empleado]),
  CONSTRAINT [FK_Contrato_ID_Proveedor]
    FOREIGN KEY ([ID_Proveedor])
      REFERENCES [Proveedor]([ID_Proveedor])
);

CREATE TABLE [Turno] (
  [ID_Turno]     INT,
  [Nombre_Turno] VARCHAR(50),
  [Hora_Inicio]  TIME,
  [Hora_Fin]     TIME,
  [Dias_Semana]  VARCHAR(15),
  PRIMARY KEY ([ID_Turno])
);

CREATE TABLE [Empleado_Turno] (
  [ID_Turno]    INT,
  [ID_Empleado] INT,
  PRIMARY KEY ([ID_Turno], [ID_Empleado]),
  CONSTRAINT [FK_Empleado_Turno_ID_Empleado]
    FOREIGN KEY ([ID_Empleado])
      REFERENCES [Empleado]([ID_Empleado]),
  CONSTRAINT [FK_Empleado_Turno_ID_Turno]
    FOREIGN KEY ([ID_Turno])
      REFERENCES [Turno]([ID_Turno])
);

CREATE TABLE [Carta] (
  [ID_Carta]        INT,
  [Nombre_Carta]    VARCHAR(100),
  [Cantidad_Platos] INT,
  [Descripcion]     VARCHAR(100),
  [Precio]          DECIMAL(8,2),
  PRIMARY KEY ([ID_Carta])
);

CREATE TABLE [Producto_Categoria] (
  [ID_Categoria]     INT,
  [Nombre_Categoria] VARCHAR(50),
  [Descripcion]      VARCHAR(200),
  [ID_Carta]         INT,
  PRIMARY KEY ([ID_Categoria]),
  CONSTRAINT [FK_Producto_Categoria_ID_Carta]
    FOREIGN KEY ([ID_Carta])
      REFERENCES [Carta]([ID_Carta])
);

CREATE TABLE [Producto] (
  [ID_Producto]        INT IDENTITY(1,1),
  [Nombre_Plato]       VARCHAR(100),
  [Descripcion]        VARCHAR(255),
  [Tiempo_Preparacion] FLOAT,
  [Precio]             DECIMAL(5,2),
  [Disponibilidad]     BIT,
  [Categoria]          VARCHAR(50),
  [ID_Categoria]       INT,
  PRIMARY KEY ([ID_Producto]),
  CONSTRAINT [FK_Producto_ID_Categoria]
    FOREIGN KEY ([ID_Categoria])
      REFERENCES [Producto_Categoria]([ID_Categoria])
);

CREATE TABLE [Categoria_Ingrediente] (
  [ID_Cat_Ingrediente] INT,
  [Nombre_Categoria]   VARCHAR(50),
  PRIMARY KEY ([ID_Cat_Ingrediente])
);

CREATE TABLE [Ingrediente] (
  [ID_Ingrediente]     INT IDENTITY(1,1),
  [Nombre_Ingrediente] VARCHAR(100),
  [Unidad_Medida]      VARCHAR(20),
  [Descripcion]        VARCHAR(100),
  [Costo_Unitario]     DECIMAL(10,2),
  [Estado]             BIT,
  [ID_Cat_Ingrediente] INT,
  PRIMARY KEY ([ID_Ingrediente]),
  CONSTRAINT [FK_Ingrediente_ID_Cat_Ingrediente]
    FOREIGN KEY ([ID_Cat_Ingrediente])
      REFERENCES [Categoria_Ingrediente]([ID_Cat_Ingrediente])
);

CREATE TABLE [Producto_Ingrediente] (
  [ID_Producto_Ingrediente] INT IDENTITY(1,1),
  [ID_Ingrediente]          INT,
  [ID_Producto]             INT,
  [Cantidad]                DECIMAL(10,3),
  [Unidad_Medida]           VARCHAR(100),
  [Observaciones]           VARCHAR(200),
  PRIMARY KEY ([ID_Producto_Ingrediente]),
  CONSTRAINT [FK_Producto_Ingrediente_ID_Producto]
    FOREIGN KEY ([ID_Producto])
      REFERENCES [Producto]([ID_Producto]),
  CONSTRAINT [FK_Producto_Ingrediente_ID_Ingrediente]
    FOREIGN KEY ([ID_Ingrediente])
      REFERENCES [Ingrediente]([ID_Ingrediente])
);

CREATE TABLE [Mesa_Restaurante] (
  [ID_Mesa]     INT,
  [Numero_Mesa] INT,
  [Capacidad]   INT,
  [Ubicacion]   VARCHAR(100),
  [Estado]      VARCHAR(20),
  PRIMARY KEY ([ID_Mesa])
);

CREATE TABLE [Cliente] (
  [ID_Cliente]       INT IDENTITY(1,1),
  [Nombre]           VARCHAR(50),
  [Apellidos]        VARCHAR(50),
  [Telefono]         VARCHAR(9),
  [Email]            VARCHAR(100),
  [Fecha_Nacimiento] DATE,
  [Direccion]        VARCHAR(150),
  [DNI]              VARCHAR(8),
  [RUC]              VARCHAR(11),
  PRIMARY KEY ([ID_Cliente])
);

CREATE TABLE [Pedido] (
  [ID_Pedido]      INT IDENTITY(1,1),
  [ID_Empleado]    INT,
  [ID_Cliente]     INT,
  [ID_Mesa]        INT,
  [Fecha]          DATE,
  [Estado_Pedido]  VARCHAR(50),
  [Detalle_Pedido] VARCHAR(255),
  [SubTotal]       DECIMAL(10,2),
  [Total]          DECIMAL(10,2),
  PRIMARY KEY ([ID_Pedido]),
  CONSTRAINT [FK_Pedido_ID_Empleado]
    FOREIGN KEY ([ID_Empleado])
      REFERENCES [Empleado]([ID_Empleado]),
  CONSTRAINT [FK_Pedido_ID_Mesa]
    FOREIGN KEY ([ID_Mesa])
      REFERENCES [Mesa_Restaurante]([ID_Mesa]),
  CONSTRAINT [FK_Pedido_ID_Cliente]
    FOREIGN KEY ([ID_Cliente])
      REFERENCES [Cliente]([ID_Cliente])
);

CREATE TABLE [Pago] (
  [ID_Pago]          INT IDENTITY(1,1),
  [Fecha_Hora_Pago]  DATETIME,
  [Monto]            DECIMAL(10,2),
  [Metodo_Pago]      VARCHAR(50),
  [Detalles_Tarjeta] VARCHAR(100),
  [Estado]           VARCHAR(20),
  [ID_Pedido]        INT,
  PRIMARY KEY ([ID_Pago]),
  CONSTRAINT [FK_Pago_ID_Pedido]
    FOREIGN KEY ([ID_Pedido])
      REFERENCES [Pedido]([ID_Pedido])
);

CREATE TABLE [Comprobante_Pago] (
  [ID_Comprobante]     INT IDENTITY(1,1),
  [ID_Pedido]          INT,
  [Tipo_Comprobante]   VARCHAR(30),
  [Numero_Comprobante] VARCHAR(10),
  [Serie]              VARCHAR(10),
  [Fecha_Emision]      DATETIME,
  [Sub_Total]          DECIMAL(10,2),
  [Monto_Total]        DECIMAL(10,2),
  [IGV]                DECIMAL(10,2),
  [Estado_Comprobante] VARCHAR(30),
  [Metodo_Pago]        VARCHAR(30),
  [Razon_Social]       VARCHAR(200),
  [RUC]                VARCHAR(11),
  [Direccion_Fiscal]   VARCHAR(200),
  PRIMARY KEY ([ID_Comprobante]),
  CONSTRAINT [FK_Comprobante_Pago_ID_Pedido]
    FOREIGN KEY ([ID_Pedido])
      REFERENCES [Pedido]([ID_Pedido])
);


CREATE TABLE [Pedido_Detalle] (
  [ID_Pedido_Detalle] INT IDENTITY(1,1),
  [ID_Pedido]         INT,
  [ID_Producto]       INT,
  [Cantidad]          INT,
  [PrecioUnitario]    DECIMAL(10,2),
  PRIMARY KEY ([ID_Pedido_Detalle]),
  CONSTRAINT [FK_Pedido_Detalle_ID_Pedido]
    FOREIGN KEY ([ID_Pedido])
      REFERENCES [Pedido]([ID_Pedido]),
  CONSTRAINT [FK_Pedido_Detalle_ID_Producto]
    FOREIGN KEY ([ID_Producto])
      REFERENCES [Producto]([ID_Producto])
);

CREATE TABLE [Reservacion] (
  [ID_Reservacion]     INT IDENTITY(1,1),
  [Fecha_Hora]         DATETIME,
  [Numero_Personas]    INT,
  [Ocasion_Especial]   VARCHAR(100),
  [Estado_Reservacion] VARCHAR(20),
  [Notas]              VARCHAR(300),
  [ID_Cliente]         INT,
  [ID_Mesa]            INT,
  PRIMARY KEY ([ID_Reservacion]),
  CONSTRAINT [FK_Reservacion_ID_Mesa]
    FOREIGN KEY ([ID_Mesa])
      REFERENCES [Mesa_Restaurante]([ID_Mesa]),
  CONSTRAINT [FK_Reservacion_ID_Cliente]
    FOREIGN KEY ([ID_Cliente])
      REFERENCES [Cliente]([ID_Cliente])
);

CREATE TABLE [Proveedor_Ingrediente] (
  [ID_Proveedor]  INT,
  [ID_Ingrediente] INT,
  CONSTRAINT [FK_Proveedor_Ingrediente_ID_Proveedor]
    FOREIGN KEY ([ID_Proveedor])
      REFERENCES [Proveedor]([ID_Proveedor]),
  CONSTRAINT [FK_Proveedor_Ingrediente_ID_Ingrediente]
    FOREIGN KEY ([ID_Ingrediente])
      REFERENCES [Ingrediente]([ID_Ingrediente])
);

CREATE TABLE [Inventario] (
  [ID_Inventario]           INT IDENTITY(1,1),
  [Cantidad_Stock]          DECIMAL(10,2),
  [Fecha_Ultima_Reposicion] DATE,
  [Stock_Minimo]            DECIMAL(10,2),
  [Stock_Maximo]            DECIMAL(10,2),
  [ID_Ingrediente]          INT,
  PRIMARY KEY ([ID_Inventario]),
  CONSTRAINT [FK_Inventario_ID_Ingrediente]
    FOREIGN KEY ([ID_Ingrediente])
      REFERENCES [Ingrediente]([ID_Ingrediente])
);

CREATE TABLE [Promocion] (
  [ID_Promocion]         INT IDENTITY(1,1),
  [Nombre]               VARCHAR(100),
  [Descripcion]          VARCHAR(300),
  [Porcentaje_Descuento] DECIMAL(5,2),
  [Fecha_Inicio]         DATETIME,
  [Fecha_Fin]            DATETIME,
  [Estado]               BIT,
  PRIMARY KEY ([ID_Promocion])
);

CREATE TABLE [Producto_Promocion] (
  [ID_Producto]  INT,
  [ID_Promocion] INT,
  CONSTRAINT [FK_Producto_Promocion_ID_Promocion]
    FOREIGN KEY ([ID_Promocion])
      REFERENCES [Promocion]([ID_Promocion]),
  CONSTRAINT [FK_Producto_Promocion_ID_Producto]
    FOREIGN KEY ([ID_Producto])
      REFERENCES [Producto]([ID_Producto])
);
GO

-- =============================================
-- DATOS DE PRUEBA — 3 registros por tabla
-- Insertados en orden jerárquico de dependencias
-- Contexto: Peru | Moneda: Soles | IGV: 18 %
-- =============================================

-- 1. Rol  (Diccionario — IDs explícitos, sin IDENTITY)
INSERT INTO [Rol] ([ID_Rol], [Nombre_Rol], [Descripcion]) VALUES
(1, 'Administrador', 'Acceso total: gestión de personal, reportes financieros y configuración del sistema'),
(2, 'Mesero',        'Toma y seguimiento de pedidos, atención de mesas y registro de clientes'),
(3, 'Cajero',      'Visualización de pedidos activos y montos totales');

-- 2. Empleado  (IDENTITY → ID omitido; IDs resultantes: 1, 2, 3, etc.)
INSERT INTO [Empleado] ([Nombre], [Apellidos], [Direccion], [Cargo], [Telefono], [Estado], [DNI]) VALUES
('Juan Carlos',    'Pérez Mamani',   'Av. Javier Prado Este 1234, San Isidro, Lima',  'Administrador', '987654321', 'Activo', '45678901'),
('María Elena',    'Quispe Flores',  'Jr. Moquegua 567, Cercado de Lima, Lima',        'Mesero',        '978563214', 'Activo', '56789012'),
('Carlos Alberto', 'Huanca Condori', 'Calle Los Álamos 789, Miraflores, Lima',         'Cocinero',      '965478123', 'Activo', '67890123'),
('Luis Fernando',  'Gómez Sánchez',   'Av. Arequipa 2450, Lince, Lima',               'Cocinero',      '954123654', 'Activo', '67890123'),
('Ana Lucía',      'Mendoza Torres',  'Calle San Martín 420, Miraflores, Lima',       'Mesero',        '941258369', 'Activo', '78901234'),
('Jorge Luis',     'Ramírez Vega',    'Jr. Junín 835, Magdalena del Mar, Lima',       'Bartender',     '932147586', 'Activo', '89012345'),
('Diana Marcela',  'Rojas Castro',    'Av. Larco 765, Miraflores, Lima',              'Cajero',        '921547863', 'Activo', '12345678'),
('Pedro Alcides',  'Chávez Flores',   'Av. Universitaria 1420, San Miguel, Lima',     'Repartidor',    '915487263', 'Activo', '23456789'),
('Sofía Beatriz',  'Guerrero Palacios','Calle Las Flores 112, Surco, Lima',           'Recepcionista', '999654123', 'Activo', '34567890'),
('Miguel Ángel',   'Villanueva Díaz', 'Av. Brasil 3450, Magdalena, Lima',             'Cocinero',      '988755421', 'Activo', '45612378'),
('Carmen Rosa',    'Espinoza Rios',   'Jr. Trujillo 415, Rímac, Lima',                'Mesero',        '977451236', 'Inactivo', '52143698'),
('Ricardo Javier', 'Paredes Vargas',  'Av. La Marina 1820, San Miguel, Lima',         'Personal Limpieza','966321458', 'Activo', '63251478'),
('Andrea del Pilar','Cáceras Luna',   'Calle Los Pinos 290, San Borja, Lima',         'Subgerente',    '955214789', 'Activo', '74125896');

-- 3. Usuario  (IDENTITY → ID omitido; vincula Rol y Empleado con coherencia de cargo y ahora incluye Email)
INSERT INTO [Usuario] ([ID_Rol], [ID_Empleado], [Nombre_Usuario], [Password], [Email], [Estado]) VALUES
(1, 1, 'jperez',  'sd12@$12$EixZ', 'jc.perez@ranchoonline.pe',  1), -- Juan Carlos
(2, 2, 'mquispe', '$2s#12$GFmQ3X', 'me.quispe@ranchoonline.pe', 1), -- Maria Elena
(3, 3, 'chuanca', 'R4WoY8HnLs5bT', 'ca.huanca@ranchoonline.pe', 1), -- Carlos Alberto
(3, 4, 'lgomez',  'Gom3z.C0c_2026!', 'lf.gomez@ranchoonline.pe',  1), -- Luis Gómez
(2, 5, 'amendoza', 'M3nd0z@.M3s#94!', 'al.mendoza@ranchoonline.pe',1), -- Ana Mendoza
(2, 6, 'jramirez', 'Ram1r3z_B@rt$26', 'jl.ramirez@ranchoonline.pe',1), -- Jorge Ramírez
(2, 7, 'drojas',  'R0j@s.C@j_921*',  'dm.rojas@ranchoonline.pe',  1), -- Diana Rojas
(2, 8, 'pchavez', 'Ch@v3z.D3l1v%8',  'pa.chavez@ranchoonline.pe', 1), -- Pedro Chávez
(2, 9, 'sguerrero', 'Gu3rr3r0.R3c@9',  'sb.guerrero@ranchoonline.pe',1), -- Sofía Guerrero
(3, 10, 'mvillanueva', 'V1ll@nu3v@_C0c#', 'ma.villanueva@ranchoonline.pe',1), -- Miguel Villanueva
(2, 11, 'cespinoza', 'Esp1n0z@.M3s*52', 'cr.espinoza@ranchoonline.pe',0), -- Carmen Espinoza (Inactivo)
(3, 12, 'rparedes', 'P@r3d3s.L1mp$26', 'rj.paredes@ranchoonline.pe',1), -- Ricardo Paredes
(1, 13, 'acaceres', 'C@c3r3s.SubG#26!', 'ap.caceres@ranchoonline.pe', 1); -- Andrea Cáceres



-- 4. Proveedor  (IDENTITY → ID omitido; RUC persona jurídica inicia con 20)
INSERT INTO [Proveedor] ([Nombre_Empresa], [RUC], [Email_Contacto], [Telefono], [Direccion], [Tipo_Suministro], [Estado]) VALUES
('Distribuidora El Campo Cajamarca S.A.C.', '20512345678', 'ventas@elcampocajamarca.pe', '943215678', 'Av. Vía de Evitamiento Norte 1420, Cajamarca', 'Carnes y Aves de Corral',  'Activo'),
('Cajamarca Fresh Proveedores E.I.R.L.',   '20498765432', 'contacto@cajafresh.pe',      '956781234', 'Jr. Chanchamayo 456, Cajamarca',              'Verduras y Tubérculos',    'Activo'),
('Carnes del Valle Gavilán E.I.R.L.',      '20567891234', 'ventas@carnesdelvalle.pe',   '974123568', 'Jr. Tarapacá 835, Cajamarca',                 'Carnes y Embutidos',       'Activo'),
('Gas Centro Cajamarca S.A.C.',            '20781234567', 'pedidos@gascentrocaja.com',  '076363214', 'Av. Industrial 240, Parque Industrial, Cajamarca', 'Gas GLP e Industrial', 'Activo'),
('Lácteos Porcón Seleccionados',           '20451278934', 'ventas@lacteosporcon.pe',    '994125863', 'Granja Porcón S/N, Cajamarca',                'Lácteos y Quesos',         'Activo'),
('Distribuidora San Ignacio S.A.C.',       '20542316789', 'contacto@dsanignacio.pe',    '941258763', 'Av. Hoyos Rubio 1105, Cajamarca',             'Abarrotes y Alimentos Secos','Activo'),
('Avícola El Porvenir Chota S.A.C.',       '20612345789', 'ventas@avicolaelporvenir.pe','935612478', 'Jr. Anaximandro Vega 450, Chota, Cajamarca',  'Aves y Huevos',            'Activo'),
('Huacariz Lácteos Especiales',            '20341256789', 'contacto@huacariz.com.pe',   '076341295', 'Carretera Baños del Inca Km 3.5, Cajamarca',  'Lácteos, Yogures y Mantequilla','Activo'),
('Café de Altura San Ignacio E.I.R.L.',    '20601234567', 'comercial@cafesanignacio.pe','984512367', 'Jr. Comercio 520, San Ignacio, Cajamarca',    'Café e Infusiones',        'Activo'),
('Frutería del Valle Condebamba',         '20557812349', 'pedidos@frutascondebamba.pe','971452369', 'Mercado Central Puesto 45, Cajamarca',        'Frutas Exóticas y de Estación','Activo'),
('Soles Gas S.A.C. - Sucursal Cajamarca',  '20124578123', 'cajamarca@solesgas.com.pe',  '076361122', 'Av. Atahualpa 425, Baños del Inca, Cajamarca','Gas GLP y Mantenimiento',  'Activo'),
('Distribuidora Alva & Hermanos',          '20481236547', 'ventas@distribuidoraalva.pe','966325147', 'Jr. Amazonas 1024, Cajamarca',                'Bebidas, Aguas y Licores', 'Activo'),
('Huertas de Celendín S.A.C.',             '20594512367', 'contacto@huertascelendin.pe','947125369', 'Jr. Dos de Mayo 315, Celendín, Cajamarca',    'Hortalizas y Hierbas Aromáticas','Activo'),
('Pesquera El Pacífico - Sede Cajamarca',   '20413265498', 'ventas@pacificocaja.pe',     '951236478', 'Av. San Martín 1510, Cajamarca',              'Pescados y Mariscos Congelados','Activo'),
('Empaques y Plásticos del Norte',         '20653214789', 'informes@empaquesnorte.pe',  '991245783', 'Jr. Amalia Puga 265, Cajamarca',              'Envases y Descartables',   'Activo'),
('Trigo de Oro Cajamarquino S.A.C.',       '20541287369', 'panificacion@trigodeoro.pe', '932145876', 'Jr. Bellavista 112, Cajamarca',               'Harinas, Panes y Pastelería','Activo'),
('EquipaRancho S.A.C. (Menaje y Equipos)', '20683412579', 'proyectos@equiparancho.pe',  '076348912', 'Av. El Maestro 740, Cajamarca',               'Menaje y Limpieza Industrial','Activo'),
('Especias y Condimentos del Norte',       '20542163987', 'ventas@especiasnorte.pe',    '921478536', 'Jr. José Gálvez 580, Cajamarca',            'Especias y Saborizantes',  'Inactivo');



-- 5. Contrato  (IDENTITY → ID omitido; contratos laborales para los 3 empleados)
INSERT INTO [Contrato] ([Fecha_Inicio], [Fecha_Fin], [Tipo_Contrato], [Salario], [Clausula], [ID_Empleado], [ID_Proveedor]) VALUES
-- ==========================================
-- CONTRATOS DE EMPLEADOS (IDs: 1 al 13)
-- ==========================================
('02-01-2024', '31-12-2026', 'Indefinido',  4200.00, 'Jornada de 48h semanales. Labores exclusivas de alta gerencia y administración general del restaurante Rancho.', 1, NULL), 
('15-01-2025', '14-01-2026', 'Plazo Fijo',  1300.00, 'Jornada de 48h semanales rotativas. Atención directa al cliente, manejo de comandas y asignación de mesas.', 2, NULL),
('01-02-2025', '31-01-2026', 'Plazo Fijo',  2200.00, 'Jornada completa. Encargado de la preparación de platos principales, control de porciones y mermas en cocina.', 3, NULL), 
('15-02-2025', '14-02-2026', 'Plazo Fijo',  2000.00, 'Jornada completa. Preparación de menús, mantenimiento de BPM (Buenas Prácticas de Manipulación) en área caliente.', 4, NULL), 
('01-03-2025', '31-08-2025', 'Plazo Fijo',  1300.00, 'Jornada parcial o completa según rol. Atención de mesas, despacho de pedidos y soporte en limpieza del salón.', 5, NULL), 
('15-03-2025', '14-03-2026', 'Plazo Fijo',  1600.00, 'Control de inventario de barra, preparación de bebidas, coctelería y atención directa en la barra del restaurante.', 6, NULL), 
('01-04-2025', '31-03-2026', 'Plazo Fijo',  1500.00, 'Responsable del arqueo de caja diario, cobros con tarjeta/efectivo y emisión de comprobantes electrónicos (boletas/facturas).', 7, NULL),
('10-04-2025', '09-10-2025', 'Por Obra',    1400.00, 'Distribución y delivery de pedidos asignados. Cuenta con movilidad propia y documentos en regla (SOAT vigente).', 8, NULL),
('15-04-2025', '14-04-2026', 'Plazo Fijo',  1400.00, 'Recepción de clientes, gestión de reservas telefónicas/digitales y asistencia en la organización del ingreso.', 9, NULL), 
('01-05-2025', '30-04-2026', 'Plazo Fijo',  2000.00, 'Especialista en la preparación de salsas, entradas y soporte logístico en la línea de producción de cocina.', 10, NULL), 
('01-01-2024', '31-12-2024', 'Plazo Fijo',  1300.00, 'Contrato vencido y no renovado. El colaborador se encuentra en condición inactiva en el sistema.', 11, NULL), 
('01-05-2025', '31-10-2025', 'Plazo Fijo',  1100.00, 'Mantenimiento del orden y la limpieza profunda de las áreas comunes, cocina, salón principal y servicios higiénicos.', 12, NULL),
('15-11-2024', '31-12-2026', 'Indefinido',  3200.00, 'Soporte directo a la administración, supervisión de personal en salón y cocina, y control de estándares de calidad.', 13, NULL),

-- ==========================================
-- CONTRATOS DE PROVEEDORES (IDs: 1 al 15)
-- ==========================================
('01-01-2025', '31-12-2025', 'Proveedor',    NULL, 'Abastecimiento semanal de cortes cárnicos selectos y aves.', NULL, 1),  
('01-01-2025', '30-06-2025', 'Proveedor',    NULL, 'Despacho interdiario de verduras frescas del valle y tubérculos.', NULL, 2),  
('15-01-2025', '14-01-2026', 'Proveedor',    NULL, 'Suministro de embutidos artesanales y carnes para parrilla.', NULL, 3), 
('01-02-2025', '31-01-2026', 'Suministro',   NULL, 'Abastecimiento continuo de balones de gas GLP de 45kg.', NULL, 4), 
('01-02-2025', '31-07-2025', 'Proveedor',    NULL, 'Entrega los lunes y jueves de quesos regionales de la Granja Porcón.', NULL, 5),     
('10-02-2025', '09-02-2026', 'Proveedor',    NULL, 'Provisión mensual de abarrotes por volumen mayorista.', NULL, 6),                 
('15-02-2025', '14-02-2026', 'Proveedor',    NULL, 'Suministro diario de pollo eviscerado y huevos frescos de granja chotana.', NULL, 7),  
('01-03-2025', '28-02-2026', 'Proveedor',    NULL, 'Despacho de lácteos, yogures naturales y mantequilla gourmet.', NULL, 8),        
('01-03-2025', '31-12-2025', 'Proveedor',    NULL, 'Entrega de café en grano especial de altura para la barra de bar.', NULL, 9), 
('15-03-2025', '15-09-2025', 'Proveedor',    NULL, 'Abastecimiento estacional de frutas frescas directamente del valle de Condebamba.', NULL, 10), 
('01-04-2025', '31-03-2026', 'Suministro',   NULL, 'Mantenimiento del sistema de gas y recarga preferencial de balones comerciales.', NULL, 11), 
('05-04-2025', '04-04-2026', 'Proveedor',    NULL, 'Distribución de licores nacionales e importados y aguas embotelladas.', NULL, 12), 
('15-04-2025', '14-10-2025', 'Proveedor',    NULL, 'Suministro semanal de hierbas aromáticas finas y hortalizas orgánicas.', NULL, 13),           
('01-05-2025', '31-10-2025', 'Proveedor',    NULL, 'Distribución de pescados y mariscos congelados IQF con cadena de frío.', NULL, 14),       
('15-05-2025', '14-05-2026', 'Suministro',   NULL, 'Provisión de vajilla, menaje de cocina y productos químicos de limpieza.', NULL, 15),
('01-06-2025', '31-12-2025', 'Proveedor',    NULL, 'Suministro de harinas, panes especializados y pastelería fina para el restaurante.', NULL, 16),
('01-06-2025', '31-05-2026', 'Suministro',   NULL, 'Provisión de indumentaria textil, mantelería y uniformes para el personal.', NULL, 17),
('15-06-2025', '14-12-2025', 'Proveedor',    NULL, 'Acuerdo comercial de especias y condimentos (Actualmente suspendido/Inactivo).', NULL, 18);
GO

-- 6. Turno  (Diccionario — IDs explícitos, sin IDENTITY)
INSERT INTO [Turno] ([ID_Turno], [Nombre_Turno], [Hora_Inicio], [Hora_Fin], [Dias_Semana]) VALUES
(1, 'Turno Mañana', '07:00:00', '15:00:00', 'Lun-Sab'),
(2, 'Turno Tarde',  '15:00:00', '23:00:00', 'Lun-Dom'),
(3, 'Turno Noche',  '23:00:00', '07:00:00', 'Vie-Dom');


-- 7. Empleado_Turno  (Tabla intermedia — IDs explícitos)
INSERT INTO [Empleado_Turno] ([ID_Turno], [ID_Empleado]) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(1, 7),
(2, 8),
(1, 9),
(1, 10),
(2, 11),
(2, 12),
(2, 13);

-- 8. Carta  (Diccionario — IDs explícitos, sin IDENTITY)
INSERT INTO [Carta] ([ID_Carta], [Nombre_Carta], [Cantidad_Platos], [Descripcion], [Precio]) VALUES
(1, 'Carta Principal', 15, 'Platos bandera de la gastronomía peruana',   0.00),
(2, 'Carta de Bebidas', 8, 'Bebidas nacionales e importadas',             0.00),
(3, 'Carta de Postres', 6, 'Postres tradicionales peruanos',              0.00);

-- 9. Producto_Categoria  (Diccionario — IDs explícitos; apunta a Carta 1, 2 y 3) 
INSERT INTO [Producto_Categoria] ([ID_Categoria], [Nombre_Categoria], [Descripcion], [ID_Carta]) VALUES
(1, 'Menú Económico', 'Platos accesibles del día con el sabor de siempre', 1),
(2, 'Menú Ejecutivo', 'Platos seleccionados orientados a almuerzos de trabajo', 1),
(3, 'Especialidades Cajamarquinas', 'Platos bandera de la región con insumos locales', 1),
(4, 'Porciones y Piqueos', 'Porciones extras y platos para compartir al centro', 1),
(5, 'Bebidas Personales', 'Gaseosas, aguas y jugos individuales', 2),
(6, 'Bebidas Familiares y Jarras', 'Jarras de refrescos tradicionales para la mesa', 2),
(7, 'Tragos y Cocteles', 'Bebidas alcohólicas y coctelería de la barra', 2),
(8, 'Postres Dulces', 'Postres tradicionales azucarados y pastelería', 3),
(9, 'Postres Salados y Aperitivos', 'Antojos y aperitivos ligeros no dulces', 3);

-- 10. Categoria_Ingrediente  (Diccionario — IDs explícitos, sin IDENTITY)
INSERT INTO [Categoria_Ingrediente] ([ID_Cat_Ingrediente], [Nombre_Categoria]) VALUES
(1, 'Carnes y Aves'),
(2, 'Verduras y Tubérculos'),
(3, 'Condimentos y Especias'),
(4, 'Lácteos y Quesos'),
(5, 'Abarrotes y Alimentos Secos'),
(6, 'Frutas y Hierbas Aromáticas'),
(7, 'Licores y Líquidos de Barra'),
(8, 'Combustibles y Energía'),
(9, 'Panadería y Pastelería'),
(10, 'Pescados y Mariscos');

-- 11. Ingrediente  (IDENTITY → ID omitido; IDs resultantes: 1, 2, 3)
INSERT INTO [Ingrediente] ([Nombre_Ingrediente], [Unidad_Medida], [Descripcion], [Costo_Unitario], [Estado], [ID_Cat_Ingrediente]) VALUES
('Pollo', 'kg', 'Pollo entero fresco de primera calidad, sin vísceras', 12.50, 1, 1),
('Lomo de Res', 'kg', 'Corte de lomo fino de res refrigerado, sin grasa excesiva', 28.00, 1, 1),
('Papa Amarilla', 'kg', 'Papa amarilla fresca seleccionada, calibre mediano', 3.50, 1, 2),
('Carne de Cerdo', 'kg', 'Carne de cerdo para chicharrones o fritos', 18.50, 1, 1),
('Carne de Res', 'kg', 'Corte de carne de res para guisados o estofados', 22.00, 1, 1),
('Carne de Cordero', 'kg', 'Corte de carne de cordero fresca', 26.00, 1, 1),
('Lechuga', 'Unidad', 'Lechuga fresca para ensaladas y decoraciones', 1.50, 1, 2),
('Tomate', 'kg', 'Tomate maduro para ensaladas y salsas de cocina', 3.00, 1, 2),
('Cebolla', 'kg', 'Cebolla roja para aderezos y ensaladas criollas', 2.50, 1, 2),
('Yuca', 'kg', 'Yuca fresca para sancochar o freír', 2.20, 1, 2),
('Papa Blanca', 'kg', 'Papa blanca para fritura en bastones', 1.80, 1, 2),
('Mote', 'kg', 'Maíz mote cocido desgranado', 3.80, 1, 2),
('Zanahoria', 'kg', 'Zanahoria fresca para ensaladas y aderezos', 2.00, 1, 2),
('Alvejas', 'kg', 'Alvejas verdes peladas frescas', 4.50, 1, 2),
('Choclo', 'Unidad', 'Mazorca de maíz tierno o choclo', 1.20, 1, 2),
('Camote', 'kg', 'Camote morado o amarillo', 2.00, 1, 2),
('Espinaca', 'kg', 'Hojas de espinaca fresca', 4.00, 1, 2),
('Limon', 'kg', 'Limón ácido para ceviches y bebidas', 4.20, 1, 6),
('Maracuja', 'kg', 'Fruta fresca para jugos y salsas', 4.50, 1, 6),
('Chicha Morada', 'kg', 'Maíz morado seco en mazorca', 5.00, 1, 5),
('Paico', 'kg', 'Hierba aromática para sopas tradicionales', 3.00, 1, 6),
('Hierbabuena', 'kg', 'Hierba aromática fresca', 3.50, 1, 6),
('Culantro', 'kg', 'Culantro fresco para aderezos y arroz con pollo', 4.00, 1, 6),
('Ají Amarillo', 'kg', 'Ají amarillo fresco para cremas y bases', 5.50, 1, 3),
('Ajo', 'kg', 'Ajo molido o en pasta para aderezos', 11.00, 1, 3),
('Pimienta', 'kg', 'Pimienta negra molida', 25.00, 1, 3),
('Comino', 'kg', 'Comino molido para sazón', 24.00, 1, 3),
('Orégano', 'kg', 'Orégano seco para sopas y pizzas', 18.00, 1, 3),
('Ají Panca', 'kg', 'Ají panca seco molido para aderezos rojos', 8.50, 1, 3),
('Quesillo', 'kg', 'Quesillo fresco artesanal sin sal', 14.00, 1, 4),
('Queso Mantecoso', 'kg', 'Queso mantecoso para piqueos o entradas', 18.00, 1, 4),
('Leche', 'Litro', 'Leche entera líquida para cocina y repostería', 3.80, 1, 4),
('Mantequilla', 'kg', 'Mantequilla para cocina comercial', 20.00, 1, 4),
('Crema de Leche', 'Litro', 'Crema de leche para salsas y postres', 12.50, 1, 4),
('Arroz', 'kg', 'Arroz blanco de grano largo para guarniciones', 4.00, 1, 5),
('Aceite', 'Litro', 'Aceite vegetal refinado para freír', 7.20, 1, 5),
('Sal', 'kg', 'Sal de cocina fina', 1.20, 1, 5),
('Azúcar', 'kg', 'Azúcar rubia para jugos y postres', 3.50, 1, 5),
('Harina', 'kg', 'Harina de trigo para repostería y apanados', 3.20, 1, 5),
('Fideos Tallarines', 'kg', 'Fideos largos delgados tipo tallarín', 4.50, 1, 5),
('Fideos Cortos', 'kg', 'Fideos cortos para sopas del menú', 4.20, 1, 5),
('Huevo', 'Unidad', 'Huevo fresco de gallina', 0.55, 1, 5),
('Vinagre', 'Litro', 'Vinagre tinto o blanco para cocina', 5.00, 1, 5),
('Sillao', 'Litro', 'Salsa de soya para salteados', 8.50, 1, 5),
('Manjarblanco', 'kg', 'Dulce de leche para postres', 15.00, 1, 4),
('Pisco', 'Botella', 'Pisco puro para coctelería', 45.00, 1, 7),
('Jarabe de Goma', 'Botella', 'Jarabe dulce para barra de bebidas', 12.00, 1, 7),
('Gas GLP 45kg', 'Unidad', 'Balón de gas para cocina industrial', 150.00, 1, 8),
('Pan de Molde', 'Unidad', 'Bolsa de pan blanco para espesantes o sándwiches', 6.00, 1, 9),
('Trucha', 'kg', 'Filete de trucha fresca con piel', 22.00, 1, 10),
('Pescado Trucha', 'kg', 'Filete de trucha limpia para platos de fondo o fritos', 22.50, 1, 10),
('Pescado Corvina', 'kg', 'Filete de pescado blanco para ceviche', 35.00, 1, 10),
('Marisco Camarón', 'kg', 'Camarones frescos enteros para caldos o salsas', 42.00, 1, 10),
('Pulpo', 'kg', 'Pulpo fresco refrigerado para entradas o parrilas', 38.00, 1, 10),
('Carne de Cuy', 'Unidad', 'Cuy entero beneficiado listo para la cocina', 25.00, 1, 1),
('Carne de Pato', 'kg', 'Presas de pato tierno para arroces o guisados', 24.00, 1, 1),
('Gallina', 'kg', 'Gallina eviscerada para caldos concentrados', 16.00, 1, 1),
('Bistec de Res', 'kg', 'Cortes delgados de carne de res para segundos rápidos', 21.00, 1, 1),
('Apio', 'kg', 'Tallos de apio fresco para bases de sopas y caldos', 2.50, 1, 2),
('Poro', 'Unidad', 'Poro fresco para aromatizar fondos y caldos', 1.80, 1, 2),
('Nabo', 'kg', 'Nabo fresco para sopas del menú', 2.00, 1, 2),
('Col', 'Unidad', 'Col blanca para ensaladas o caldos', 3.50, 1, 2),
('Caigua', 'kg', 'Caigua fresca para platos rellenos o guisos', 3.00, 1, 2),
('Brócoli', 'kg', 'Brócoli fresco para ensaladas cocidas o saltados', 4.50, 1, 2),
('Vainita', 'kg', 'Vainitas verdes para saltados o ensaladas', 3.80, 1, 2),
('Palta', 'Unidad', 'Palta madura para ensaladas o entradas', 2.50, 1, 2),
('Rocoto', 'kg', 'Rocoto fresco para cremas picantes o salsas', 7.00, 1, 3),
('Ají Limo', 'kg', 'Ají limo para la preparación exclusiva de ceviches', 9.00, 1, 3),
('Palillo', 'kg', 'Palillo amarillo molido para dar color a los guisos', 12.00, 1, 3),
('Tuco', 'kg', 'Sazonador rojo en polvo para tuco y tallarines', 15.00, 1, 3),
('Sillao Claro', 'Litro', 'Salsa de soya clara para sazonar caldos', 9.00, 1, 5),
('Salsa de Ostión', 'Litro', 'Salsa de ostión para saltados estilo chifa', 14.50, 1, 5),
('Yogurt', 'Litro', 'Yogurt natural para desayunos o postres', 6.50, 1, 4),
('Queso Crema', 'kg', 'Queso crema para salsas de postres o entradas', 19.00, 1, 4),
('Fideos Canuto', 'kg', 'Fideos cortos tubulares para sopas o ensaladas frías', 4.30, 1, 5),
('Fideos Cabello de Ángel', 'kg', 'Fideos muy delgados para sopas ligeras del día', 4.60, 1, 5),
('Garbanzo', 'kg', 'Legumbre seca para platos de fondo del menú', 5.50, 1, 5),
('Lenteja', 'kg', 'Lenteja seca para los platos de los lunes', 4.80, 1, 5),
('Frijol', 'kg', 'Frijol seco para acompañar secos o guisos', 6.00, 1, 5),
('Harina de Maíz', 'kg', 'Harina fina de maíz para tamales o espesantes', 4.00, 1, 5),
('Galleta de Soda', 'Paquete', 'Galletas de soda saladas para espesar cremas', 0.80, 1, 5),
('Piña', 'Unidad', 'Piña fresca para jugos o postres', 4.50, 1, 6),
('Fresa', 'kg', 'Fresas frescas para jugos, batidos o repostería', 7.00, 1, 6),
('Papaya', 'kg', 'Papaya para el jugo del desayuno o menú', 3.20, 1, 6),
('Naranja', 'kg', 'Naranja para jugo natural exprimido', 2.80, 1, 6),
('Plátano', 'kg', 'Plátano para freír o acompañar platos de fondo', 2.00, 1, 6),
('Canela', 'kg', 'Canela entera en rama para postres y bebidas calientes', 32.00, 1, 3),
('Clavo de Olor', 'kg', 'Clavo de olor entero para repostería e infusiones', 35.00, 1, 3),
('Esencia de Vainilla', 'Litro', 'Extracto de vainilla para repostería y dulces', 15.00, 1, 5),
('Ron', 'Botella', 'Ron blanco o dorado para coctelería de la barra', 38.00, 1, 7),
('Vodka', 'Botella', 'Vodka puro para combinados en la barra', 42.00, 1, 7),
('Crema de Menta', 'Botella', 'Licor de menta para tragos de la casa', 30.00, 1, 7);

-- 12. Producto  (IDENTITY → ID omitido; IDs resultantes: 1, 2, 3)
INSERT INTO [Producto] ([Nombre_Plato], [Descripcion], [Tiempo_Preparacion], [Precio], [Disponibilidad], [Categoria], [ID_Categoria]) VALUES
-- Platos principales (Porciones y Piqueos / Menú)
('Ají de Gallina', 'Pollo deshilachado en crema de ají amarillo con pan, nueces y papa amarilla, servido con arroz blanco', 30, 25.00, 1, 'Porciones y Piqueos', 4),
('Lomo Saltado', 'Lomo fino de res salteado con cebolla, tomate, ají amarillo, papas fritas y arroz blanco', 15, 35.00, 1, 'Porciones y Piqueos', 4),
('Causa Limeña', 'Masa de papa amarilla con ají amarillo, rellena de pollo desmenuzado, palta y mayonesa', 20, 18.00, 1, 'Porciones y Piqueos', 4),
 
-- Especialidades Cajamarquinas
('Caldo Verde', 'Sopa tradicional a base de papas, quesillo fresco y un batido de hierbas aromáticas locales', 15, 15.00, 1, 'Especialidades Cajamarquinas', 3),
('Frito con Mote', 'Cerdo sazonado y dorado acompañado de maíz mote cocido y una porción de ceviche de papa', 20, 18.00, 1, 'Especialidades Cajamarquinas', 3),
('Chicharrón de Cerdo', 'Costillas de cerdo fritas en su propia grasa acompañadas de mote, papa sancochada y ensalada', 25, 30.00, 1, 'Especialidades Cajamarquinas', 3),
('Cuy Frito', 'Cuy entero crocante acompañado de guiso de papa con ají panca y maíz tostado', 35, 45.00, 1, 'Especialidades Cajamarquinas', 3),
('Seco de Cordero', 'Guisado de cordero en salsa de culantro y chicha de jora, servido con frijoles y arroz', 30, 32.00, 1, 'Especialidades Cajamarquinas', 3),
('Sopa Chochoca', 'Sopa espesa a base de harina de maíz chochoca, carne de res, papas y hierbas', 25, 16.00, 1, 'Especialidades Cajamarquinas', 3),
 
-- Porciones y Piqueos (platos de fondo generales)
('Pollo a la Brasa', 'Un cuarto de pollo marinado al horno sazonado con especias, papas fritas y ensalada', 20, 24.00, 1, 'Porciones y Piqueos', 4),
('Pollo a la Plancha', 'Pechuga de pollo grillada acompañada de arroz blanco, papas fritas y ensalada fresca', 15, 20.00, 1, 'Porciones y Piqueos', 4),
('Milanesa de Pollo', 'Filete de pechuga de pollo apanada y frita, servida con arroz y papas fritas', 15, 22.00, 1, 'Porciones y Piqueos', 4),
('Tallarín Saltado de Res', 'Fideos tallarines salteados con tiras de carne de res, cebolla, tomate y un toque de sillao', 15, 26.00, 1, 'Porciones y Piqueos', 4),
('Tallarín Saltado de Pollo', 'Fideos tallarines salteados con tiras de pollo, cebolla, tomate, pimientos y salsa de soya', 15, 22.00, 1, 'Porciones y Piqueos', 4),
('Trucha Frita', 'Filete de trucha dorada al espantar con harina, servida con yucas fritas y ensalada criolla', 15, 25.00, 1, 'Porciones y Piqueos', 4),
('Bistec a lo Pobre', 'Corte de carne de res a la plancha servido con arroz, papas fritas, plátano frito y huevo frito', 20, 28.00, 1, 'Porciones y Piqueos', 4),
('Arroz con Pollo', 'Arroz sazonado con culantro y espinaca acompañado de una presa de pollo y ensalada de papa', 25, 20.00, 1, 'Porciones y Piqueos', 4),
('Estofado de Res', 'Carne de res guisada en salsa de tomate, zanahorias y arvejas, servido con arroz', 25, 18.00, 1, 'Porciones y Piqueos', 4),
('Seco de Pollo', 'Pollo guisado en salsa verde de culantro acompañado de frijoles y arroz blanco', 25, 18.00, 1, 'Porciones y Piqueos', 4),
('Sudado de Trucha', 'Filete de trucha cocido al vapor en su propio jugo con tomate, cebolla, chicha y yucas', 20, 26.00, 1, 'Porciones y Piqueos', 4),
 
-- Menús
('Menú Económico del Día', 'Entrada simple, plato de fondo básico del día y un vaso de refresco natural', 10, 12.00, 1, 'Menú Económico', 1),
('Menú Ejecutivo Especial', 'Entrada seleccionada, plato de fondo premium a elegir y un vaso de refresco grande', 12, 16.00, 1, 'Menú Ejecutivo', 2),
 
-- Más Porciones y Piqueos
('Pescado Frito', 'Filete de pescado blanco empanizado y frito, servido con arroz y ensalada criolla', 15, 20.00, 1, 'Porciones y Piqueos', 4),
('Seco de Res', 'Carne de res tierna guisada en salsa de culantro y especias, servido con frijoles y arroz blanco', 25, 20.00, 1, 'Porciones y Piqueos', 4),
('Arroz Chaufa de Pollo', 'Arroz salteado a fuego alto con trozos de pollo, huevo, cebolla de verdeo y salsa de soya', 15, 18.00, 1, 'Porciones y Piqueos', 4),
('Tallarines Verdes con Bistec', 'Fideos tallarines en salsa cremosa de espinaca y albahaca, acompañados de carne de res a la plancha', 20, 25.00, 1, 'Porciones y Piqueos', 4),
('Chicharrón de Trucha', 'Trozos de filete de trucha empanizados y fritos al crocante, servidos con yucas y salsa criolla', 15, 24.00, 1, 'Porciones y Piqueos', 4),
('Lomo a la Pobre', 'Corte de lomo de res a la plancha servido con papas fritas, arroz, plátano frito y huevo frito', 20, 32.00, 1, 'Porciones y Piqueos', 4),
 
-- Postres Dulces
('Manjarblanco con Quesillo', 'Dulce de leche tradicional servido con una porción de quesillo fresco', 5, 8.00, 1, 'Postres Dulces', 8),
('Mazamorra Morada', 'Postre clásico a base de maíz morado concentrado, harina de camote y frutas secas', 10, 7.00, 1, 'Postres Dulces', 8),
('Arroz con Leche', 'Arroz cocido lentamente con leche, azúcar, canela y un toque de esencia de vainilla', 10, 7.00, 1, 'Postres Dulces', 8),
('Combinado Tradicional', 'Porción mitad mazamorra morada y mitad arroz con leche servido con canela molida', 5, 9.00, 1, 'Postres Dulces', 8),
('Suspiro a la Limeña', 'Crema suave a base de leches condesadas con cobertura de merengue al oporto', 5, 12.00, 1, 'Postres Dulces', 8),
('Crema Volteada', 'Flan horneado a base de leche y huevos con una capa de caramelo líquido', 5, 8.00, 1, 'Postres Dulces', 8),
('Picarones', 'Anillos fritos de masa de camote y zapallo, bañados en miel de chancaca caliente', 15, 10.00, 1, 'Postres Dulces', 8),
('Tarta de Trufa', 'Porción de pastel de chocolate relleno y cubierto con crema de trufa', 5, 11.00, 1, 'Postres Dulces', 8),
('Pie de Limón', 'Masa quebrada rellena de crema ácida de limón y coronada con merengue tostado', 5, 9.00, 1, 'Postres Dulces', 8),
('Leche Asada', 'Postre horneado individual a base de leche, huevos y azúcar con superficie dorada', 5, 6.50, 1, 'Postres Dulces', 8),
('Alfajores Caseros', 'Tres unidades de galletas suaves de harina rellenas de manjarblanco y espolvoreadas con azúcar fina', 5, 5.00, 1, 'Postres Dulces', 8),
('Humita Dulce', 'Masa de maíz tierno molido con pasas y azúcar, envuelta en panca y cocida al vapor', 10, 6.00, 1, 'Postres Dulces', 8),
 ('Porción de Queso con Miel', 'Láminas de queso mantecoso acompañadas de miel de caña pura', 5, 8.50, 1, 'Postres Dulces', 8),

-- Postres Salados y Aperitivos
('Humita Salada', 'Masa de maíz tierno molido sazonada con sal y rellena de una lámina de quesillo fresco', 10, 6.00, 1, 'Postres Salados y Aperitivos', 9),
('Tamal de Pollo', 'Masa de maíz sazonada con ají panca, rellena de pollo y huevo, cocida envuelta en hojas de plátano', 12, 7.50, 1, 'Postres Salados y Aperitivos', 9),
 
-- Bebidas Personales
('Chicha Morada Personal', 'Vaso de refresco tradicional a base de maíz morado, frutas y limón', 3, 4.00, 1, 'Bebidas Personales', 5),
('Maracuyá Personal', 'Vaso de jugo natural de maracuyá fresco', 3, 4.00, 1, 'Bebidas Personales', 5),
('Limonada Personal', 'Vaso de limonada clásica preparada al momento con limones frescos', 3, 3.50, 1, 'Bebidas Personales', 5),
('Gaseosa Personal', 'Botella de gaseosa individual de marcas comerciales a escoger', 2, 4.50, 1, 'Bebidas Personales', 5),
('Agua Mineral', 'Botella de agua de mesa con o sin gas', 1, 3.00, 1, 'Bebidas Personales', 5),
 
-- Bebidas Familiares y Jarras
('Jarra de Chicha Morada', 'Jarra de un litro de refresco hervido de maíz morado y especias', 4, 14.00, 1, 'Bebidas Familiares y Jarras', 6),
('Jarra de Maracuyá', 'Jarra de un litro de jugo natural de maracuyá licuado', 4, 14.00, 1, 'Bebidas Familiares y Jarras', 6),
('Jarra de Limonada', 'Jarra de un litro de agua fresca con zumo de limón sutil y azúcar', 4, 12.00, 1, 'Bebidas Familiares y Jarras', 6),
 
-- Bebidas Personales (calientes)
('Infusión Caliente', 'Taza de agua caliente acompañada de filtrantes de hierbas o té', 3, 3.50, 1, 'Bebidas Personales', 5),
('Café Pasado', 'Taza de café concentrado obtenido por gota a gota tradicional', 4, 5.00, 1, 'Bebidas Personales', 5),
 
-- Tragos y Cocteles
('Pisco Sour', 'Coctel bandera a base de pisco, jugo de limón, jarabe de goma y clara de huevo', 5, 18.00, 1, 'Tragos y Cocteles', 7),
('Chilcano de Pisco', 'Bebida refrescante de pisco mezclada con gaseosa de jengibre y gotas de limón', 3, 16.00, 1, 'Tragos y Cocteles', 7),
('Coctel de Algarrobina', 'Trago dulce y cremoso a base de pisco, algarrobina, leche, yema de huevo y jarabe', 5, 20.00, 1, 'Tragos y Cocteles', 7),
('Cuba Libre', 'Combinado clásico de ron blanco, gaseosa negra de cola y rodajas de limón', 3, 15.00, 1, 'Tragos y Cocteles', 7),
('Vodka con Naranja', 'Bebida directa de vodka puro complementada con jugo de naranja natural', 3, 16.00, 1, 'Tragos y Cocteles', 7);



-- 13. Producto_Ingrediente  (IDENTITY → ID omitido; relaciona recetas con insumos)
INSERT INTO [Producto_Ingrediente] ([ID_Ingrediente], [ID_Producto], [Cantidad], [Unidad_Medida], [Observaciones]) VALUES
--===============================================
-- PLATOS PRINCIPALES
--================================================
-- 1. Ají de Gallina
(1, 1, 0.300, 'kg', 'Pollo cocido y deshilachado para el ají de gallina'),
(3, 1, 0.150, 'kg', 'Papa amarilla sancochada en rodajas'),
(24, 1, 0.050, 'kg', 'Ají amarillo para la crema base'),
(25, 1, 0.010, 'kg', 'Ajo para el aderezo de la base'),
(32, 1, 0.100, 'Litro', 'Leche para licuar con el pan'),
(49, 1, 0.050, 'Unidad', 'Pan de molde para dar consistencia'),
(35, 1, 0.150, 'kg', 'Arroz blanco para la guarnición'),

-- 2. Lomo Saltado
(2, 2, 0.250, 'kg', 'Lomo de res cortado en tiras gruesas para el salteado'),
(9, 2, 0.080, 'kg', 'Cebolla cortada en gajos'),
(8, 2, 0.080, 'kg', 'Tomate cortado en gajos sin semillas'),
(11, 2, 0.200, 'kg', 'Papa blanca frita en bastones'),
(24, 2, 0.020, 'kg', 'Ají amarillo cortado en tiras finas'),
(44, 2, 0.015, 'Litro', 'Sillao para sazonar en el fuego'),
(43, 2, 0.010, 'Litro', 'Vinagre tinto para el flameado'),

-- 3. Causa Limeña
(3, 3, 0.200, 'kg', 'Papa amarilla sancochada y prensada para la masa de causa'),
(24, 3, 0.040, 'kg', 'Ají amarillo licuado para dar sabor y color a la masa'),
(1, 3, 0.100, 'kg', 'Pollo deshilachado sazonado para el relleno'),
(18, 3, 0.020, 'kg', 'Limón para darle acidez a la masa'),
(66, 3, 0.500, 'Unidad', 'Palta madura en láminas para el centro'),

-- 4. Caldo Verde
(3, 4, 0.250, 'kg', 'Papa amarilla picada para espesar el caldo básico'),
(30, 4, 0.150, 'kg', 'Quesillo desmenuzado al servir'),
(21, 4, 0.030, 'kg', 'Paico molido para el color y sabor verde característico'),
(25, 4, 0.005, 'kg', 'Ajo para el fondo base del caldo'),
(42, 4, 1.000, 'Unidad', 'Huevo batido incorporado al final'),

-- 5. Frito con Mote
(4, 5, 0.250, 'kg', 'Carne de cerdo sazonada y dorada'),
(12, 5, 0.200, 'kg', 'Mote cocido como base del plato'),
(3, 5, 0.150, 'kg', 'Papa amarilla para la porción de ceviche de papa'),
(18, 5, 0.030, 'kg', 'Limón para el curtido del ceviche'),
(9, 5, 0.040, 'kg', 'Cebolla para la ensalada criolla de acompañamiento'),

-- 6. Chicharrón de Cerdo
(4, 6, 0.300, 'kg', 'Carne de cerdo frita en su propia grasa'),
(12, 6, 0.200, 'kg', 'Mote gigante cocido de guarnición'),
(11, 6, 0.150, 'kg', 'Papa blanca sancochada'),
(9, 6, 0.050, 'kg', 'Cebolla roja para la sarsa criolla'),
(22, 6, 0.005, 'kg', 'Hierbabuena fresca para aromatizar la sarsa'),

-- 7. Cuy Frito
(55, 7, 1.000, 'Unidad', 'Carne de cuy entero eviscerado y frito al crocante'),
(11, 7, 0.200, 'kg', 'Papa blanca para el guiso de acompañamiento'),
(29, 7, 0.030, 'kg', 'Ají panca molido para la base del guiso de papa'),
(36, 7, 0.050, 'Litro', 'Aceite para la fritura profunda del cuy'),

-- 8. Seco de Cordero
(6, 8, 0.300, 'kg', 'Carne de cordero cortada en trozos grandes'),
(23, 8, 0.040, 'kg', 'Culantro licuado para la base verde de la salsa'),
(39, 8, 0.150, 'kg', 'Frijol seco sancochado y guisado'),
(35, 8, 0.150, 'kg', 'Arroz blanco cocido para guarnición'),
(25, 8, 0.010, 'kg', 'Ajo para el aderezo del seco'),

-- 9. Sopa Chochoca
(79, 9, 0.060, 'kg', 'Harina de maíz chochoca para espesar de forma tradicional'),
(5, 9, 0.150, 'kg', 'Carne de res con hueso para dar sustancia al fondo'),
(11, 9, 0.150, 'kg', 'Papa blanca cortada en cubos pequeños'),
(28, 9, 0.002, 'kg', 'Orégano seco espolvoreado al finalizar la cocción'),

-- 10. Pollo a la Brasa
(1, 10, 0.350, 'kg', 'Un cuarto de pollo marinado con especias al horno'),
(11, 10, 0.250, 'kg', 'Papa blanca cortada y frita en bastones'),
(7, 10, 0.050, 'Unidad', 'Lechuga limpia para la ensalada'),
(8, 10, 0.050, 'kg', 'Tomate en rodajas para la ensalada'),

-- 11. Pollo a la Plancha
(1, 11, 0.200, 'kg', 'Filete de pechuga de pollo grillado'),
(35, 11, 0.150, 'kg', 'Arroz blanco cocido'),
(11, 11, 0.150, 'kg', 'Papa blanca frita en bastones'),
(7, 11, 0.040, 'Unidad', 'Lechuga para acompañamiento fresco'),
(8, 11, 0.040, 'kg', 'Tomate para ensalada'),

-- 12. Milanesa de Pollo
(1, 12, 0.200, 'kg', 'Filete de pechuga de pollo delgada'),
(39, 12, 0.050, 'kg', 'Harina para el proceso de apanado'),
(42, 12, 0.500, 'Unidad', 'Huevo batido para ligar el pan rallado'),
(35, 12, 0.150, 'kg', 'Arroz blanco cocido'),
(11, 12, 0.150, 'kg', 'Papa blanca frita'),

-- 13. Tallarín Saltado de Res
(40, 13, 0.200, 'kg', 'Fideos tallarines largos sancochados al dente'),
(2, 13, 0.150, 'kg', 'Lomo de res cortado en tiras'),
(9, 13, 0.060, 'kg', 'Cebolla en gajos medianos'),
(8, 13, 0.060, 'kg', 'Tomate en gajos'),
(44, 13, 0.015, 'Litro', 'Sillao para humectar el salteado'),

-- 14. Tallarín Saltado de Pollo
(40, 14, 0.200, 'kg', 'Fideos tallarines largos sancochados'),
(1, 14, 0.150, 'kg', 'Pollo cortado en tiras o trozos'),
(9, 14, 0.060, 'kg', 'Cebolla en gajos'),
(8, 14, 0.060, 'kg', 'Tomate en gajos'),
(44, 14, 0.015, 'Litro', 'Sillao para saltear'),

-- 15. Trucha Frita
(51, 15, 0.250, 'kg', 'Filete de pescado trucha limpio con piel'),
(39, 15, 0.030, 'kg', 'Harina para espolvorear el pescado antes de freír'),
(10, 15, 0.150, 'kg', 'Yuca sancochada y frita en trozos'),
(9, 15, 0.040, 'kg', 'Cebolla en pluma para la ensalada criolla'),

-- 16. Bistec a lo Pobre
(58, 16, 0.180, 'kg', 'Bistec de res extendido a la plancha'),
(35, 16, 0.150, 'kg', 'Arroz blanco suelto'),
(11, 16, 0.150, 'kg', 'Papa blanca frita en bastones'),
(85, 16, 1.000, 'kg', 'Plátano frito abierto por la mitad'),
(42, 16, 1.000, 'Unidad', 'Huevo frito montado sobre el plato'),

-- 17. Arroz con Pollo
(35, 17, 0.180, 'kg', 'Arroz cocido con el extracto de hierbas'),
(1, 17, 0.220, 'kg', 'Presa de pollo dorada y cocida en el arroz'),
(23, 17, 0.030, 'kg', 'Culantro licuado para el aderezo base del arroz'),
(17, 17, 0.020, 'kg', 'Espinaca para intensificar el color verde'),
(14, 17, 0.020, 'kg', 'Alvejas verdes peladas mezcladas con el arroz'),

-- 18. Estofado de Res
(5, 18, 0.200, 'kg', 'Carne de res troceada para guiso lento'),
(8, 18, 0.050, 'kg', 'Tomate licuado para formar la salsa base'),
(13, 18, 0.030, 'kg', 'Zanahoria en rodajas delgadas'),
(14, 18, 0.025, 'kg', 'Alvejas verdes integradas al guiso'),
(35, 18, 0.150, 'kg', 'Arroz blanco de guarnición'),

-- 19. Seco de Pollo
(1, 19, 0.220, 'kg', 'Presa de pollo fresca'),
(23, 19, 0.030, 'kg', 'Culantro fresco licuado para la salsa verde'),
(78, 19, 0.150, 'kg', 'Frijol seco cocido como acompañamiento'),
(35, 19, 0.150, 'kg', 'Arroz blanco cocido'),

-- 20. Sudado de Trucha
(51, 20, 0.250, 'kg', 'Filete de pescado trucha fresca'),
(8, 20, 0.080, 'kg', 'Tomate picado en tiras para el sudado'),
(9, 20, 0.080, 'kg', 'Cebolla picada en tiras'),
(10, 20, 0.150, 'kg', 'Yuca sancochada servida con el jugo del pescado'),

-- 21. Menú Económico del Día
(1, 21, 0.120, 'kg', 'Pollo en trozos pequeños asignado al segundo del menú'),
(41, 21, 0.030, 'kg', 'Fideos cortos para la sopa de entrada'),
(35, 21, 0.150, 'kg', 'Arroz blanco para el plato de fondo del menú'),

-- 22. Menú Ejecutivo Especial
(2, 22, 0.150, 'kg', 'Lomo de res para el plato seleccionado premium'),
(3, 22, 0.100, 'kg', 'Papa amarilla para la causa de entrada elegida'),
(35, 22, 0.150, 'kg', 'Arroz blanco para el plato de fondo'),

-- 23. Pescado Frito
(52, 23, 0.200, 'kg', 'Filete de pescado blanco fresco'),
(39, 23, 0.030, 'kg', 'Harina para cubrir el pescado antes de la sartén'),
(35, 23, 0.150, 'kg', 'Arroz blanco suelto'),
(9, 23, 0.040, 'kg', 'Cebolla para la sarsa criolla'),

-- 24. Seco de Res
(5, 24, 0.200, 'kg', 'Carne de res tierna troceada'),
(23, 24, 0.030, 'kg', 'Culantro fresco licuado para la base verde de la salsa'),
(78, 24, 0.150, 'kg', 'Frijol seco cocido y sazonado'),
(35, 24, 0.150, 'kg', 'Arroz blanco de guarnición'),

-- 25. Arroz Chaufa de Pollo
(35, 25, 0.250, 'kg', 'Arroz cocido frío para el proceso de salteado masivo'),
(1, 25, 0.120, 'kg', 'Pollo picado en dados pequeños'),
(42, 25, 1.000, 'Unidad', 'Huevo hecho tortilla y picado en cuadrados'),
(44, 25, 0.020, 'Litro', 'Sillao para pintar y dar sabor oriental al arroz'),

-- 26. Tallarines Verdes con Bistec
(40, 26, 0.200, 'kg', 'Fideos tallarines largos sancochados'),
(17, 26, 0.040, 'kg', 'Espinaca licuada para la crema verde de la pasta'),
(32, 26, 0.050, 'Litro', 'Leche entera para cremosidad de la salsa verde'),
(58, 26, 0.180, 'kg', 'Bistec de res cocido a la plancha'),

-- 27. Chicharrón de Trucha
(51, 27, 0.220, 'kg', 'Filete de trucha picado en cubos medianos'),
(39, 27, 0.040, 'kg', 'Harina para el rebozado crocante'),
(10, 27, 0.150, 'kg', 'Yuca sancochada y frita'),
(9, 27, 0.040, 'kg', 'Cebolla roja para sarsa criolla de acompañamiento'),

-- 28. Lomo a la Pobre
(2, 28, 0.220, 'kg', 'Corte de lomo de res tierno'),
(11, 28, 0.180, 'kg', 'Papa blanca frita en bastones'),
(35, 28, 0.150, 'kg', 'Arroz blanco cocido'),
(85, 28, 1.000, 'kg', 'Plátano frito entero'),
(42, 28, 1.000, 'Unidad', 'Huevo frito montado'),

--===============================================
-- POSTRES
--================================================
-- 29. Manjarblanco con Quesillo
(45, 29, 0.100, 'kg', 'Manjarblanco tradicional servido en base'),
(30, 29, 0.120, 'kg', 'Quesillo fresco sin sal en láminas'),

-- 30. Mazamorra Morada
(20, 30, 0.100, 'kg', 'Maíz morado seco hervido para obtener la esencia'),
(39, 30, 0.030, 'kg', 'Harina de camote o chuño para espesar la mazamorra'),
(38, 30, 0.050, 'kg', 'Azúcar para endulzar el concentrado'),
(82, 30, 0.005, 'kg', 'Canela entera para el aroma en la cocción'),

-- 31. Arroz con Leche
(35, 31, 0.050, 'kg', 'Arroz blanco cocido lentamente'),
(32, 31, 0.150, 'Litro', 'Leche entera líquida para la cocción base'),
(38, 31, 0.040, 'kg', 'Azúcar para endulzar la mezcla'),
(84, 31, 0.002, 'Litro', 'Esencia de vainilla para aromatizar al final'),

-- 32. Combinado Tradicional
(20, 32, 0.050, 'kg', 'Maíz morado para la mitad de mazamorra morada'),
(35, 32, 0.025, 'kg', 'Arroz para la mitad de arroz con leche'),
(32, 32, 0.075, 'Litro', 'Leche para la porción de arroz con leche'),
(38, 32, 0.045, 'kg', 'Azúcar para ambas preparaciones'),

-- 33. Suspiro a la Limeña
(32, 33, 0.200, 'Litro', 'Leche evaporada o entera base para la reducción'),
(38, 33, 0.100, 'kg', 'Azúcar para la base del manjar y el merengue'),
(42, 33, 1.000, 'Unidad', 'Yema de huevo para espesar y clara para el merengue'),

-- 34. Crema Volteada
(32, 34, 0.250, 'Litro', 'Leche entera para la mezcla líquida'),
(42, 34, 2.000, 'Unidad', 'Huevos enteros para dar estructura al flan'),
(38, 34, 0.080, 'kg', 'Azúcar para el batido y la preparación del caramelo'),

-- 35. Picarones
(40, 35, 0.080, 'kg', 'Harina de trigo para la masa elástica'),
(16, 35, 0.050, 'kg', 'Camote cocido y prensado para incorporar a la masa'),
(36, 35, 0.100, 'Litro', 'Aceite para la fritura honda en forma de anillos'),
(38, 35, 0.040, 'kg', 'Azúcar o chancaca para elaborar la miel caliente'),

-- 36. Tarta de Trufa
(39, 36, 0.060, 'kg', 'Harina de trigo para el bizcocho de chocolate'),
(42, 36, 0.500, 'Unidad', 'Huevo para la estructura del bizcocho'),
(34, 36, 0.080, 'Litro', 'Crema de leche para batir junto con el chocolate'),
(33, 36, 0.020, 'kg', 'Mantequilla para dar textura suave al relleno'),

-- 37. Pie de Limón
(39, 37, 0.070, 'kg', 'Harina de trigo para la base quebrada'),
(33, 37, 0.030, 'kg', 'Mantequilla para arenar la masa base'),
(18, 37, 0.040, 'kg', 'Limón exprimido para la crema ácida del centro'),
(32, 37, 0.100, 'Litro', 'Leche condensada o evaporada para espesar el relleno'),
(42, 37, 1.000, 'Unidad', 'Clara de huevo para batir el merengue de la cobertura'),

-- 38. Leche Asada
(32, 38, 0.200, 'Litro', 'Leche entera líquida sazonada'),
(42, 38, 1.500, 'Unidad', 'Huevos batidos mezclados con la leche'),
(38, 38, 0.050, 'kg', 'Azúcar refinada para dulzor base'),

-- 39. Alfajores Caseros
(39, 39, 0.080, 'kg', 'Harina de trigo para las tapas suaves'),
(33, 39, 0.040, 'kg', 'Mantequilla para lograr la textura quebradiza'),
(45, 39, 0.050, 'kg', 'Manjarblanco denso para el relleno del centro'),

-- 40. Humita Dulce
(15, 40, 0.250, 'Unidad', 'Choclo tierno desgranado y molido para la masa'),
(38, 40, 0.040, 'kg', 'Azúcar rubia para endulzar el maíz molido'),
(33, 40, 0.015, 'kg', 'Mantequilla derretida mezclada con la masa'),

-- 41. Humita Salada
(15, 41, 0.250, 'Unidad', 'Choclo tierno molido base'),
(37, 41, 0.005, 'kg', 'Sal de cocina fina para sazonar la masa'),
(30, 41, 0.040, 'kg', 'Quesillo fresco colocado en el centro de la humita'),

-- 42. Tamal de Pollo
(80, 42, 0.080, 'kg', 'Harina de maíz para la masa compacta del tamal'),
(29, 42, 0.020, 'kg', 'Ají panca molido para aderezar y dar color rojo'),
(1, 42, 0.040, 'kg', 'Pollo en trozo cocido colocado en el centro'),
(42, 42, 0.250, 'Unidad', 'Huevo sancochado en rodaja como decoración interna'),

-- 43. Porción de Queso con Miel
(31, 43, 0.150, 'kg', 'Queso mantecoso cortado en tajadas gruesas'),
(38, 43, 0.040, 'kg', 'Azúcar o miel de caña pura para bañar el queso'),

--===============================================
-- BEBIDAS
--================================================
-- 44. Chicha Morada Personal
(20, 44, 0.040, 'kg', 'Maíz morado para la base del refresco individual'),
(18, 44, 0.010, 'kg', 'Limón exprimido al momento de servir el vaso'),
(38, 44, 0.020, 'kg', 'Azúcar para el dulzor del vaso'),

-- 45. Maracuyá Personal
(19, 45, 0.050, 'kg', 'Fruta maracuyá fresca para la pulpa del vaso'),
(38, 45, 0.020, 'kg', 'Azúcar rubia para endulzar'),

-- 46. Limonada Personal
(18, 46, 0.040, 'kg', 'Limón sutil fresco para el zumo del vaso'),
(38, 46, 0.020, 'kg', 'Azúcar para la mezcla individual'),

-- 47. Gaseosa Personal
(36, 47, 1.000, 'Unidad', 'Botella de gaseosa comercial helada de inventario de barra'),

-- 48. Agua Mineral
(36, 48, 1.000, 'Unidad', 'Botella de agua de mesa individual de inventario de barra'),

-- 49. Jarra de Chicha Morada
(20, 49, 0.150, 'kg', 'Maíz morado seco en mazorca para hervir la jarra de litro'),
(18, 49, 0.040, 'kg', 'Limón fresco para la acidez de la jarra'),
(38, 49, 0.080, 'kg', 'Azúcar para endulzar el litro de refresco'),
(82, 49, 0.005, 'kg', 'Canela entera añadida durante la ebullición'),

-- 50. Jarra de Maracuyá
(19, 50, 0.200, 'kg', 'Fruta maracuyá para licuar el litro de jugo natural'),
(38, 50, 0.080, 'kg', 'Azúcar para el dulzor de la jarra familiar'),

-- 51. Jarra de Limonada
(18, 51, 0.150, 'kg', 'Limón ácido exprimido para la base de la jarra'),
(38, 51, 0.075, 'kg', 'Azúcar para el balance de la jarra de litro'),

-- 52. Infusión Caliente
(22, 52, 0.005, 'kg', 'Hierba fresca o filtrante para la taza caliente'),
(38, 52, 0.015, 'kg', 'Azúcar servida de forma opcional al cliente'),

-- 53. Café Pasado
(84, 53, 0.030, 'Litro', 'Esencia pura de café concentrado obtenido por gota a gota'),
(38, 53, 0.015, 'kg', 'Azúcar rubia complementaria para la taza'),

-- 54. Pisco Sour
(46, 54, 0.090, 'Litro', 'Pisco puro quebranta como base alcohólica principal'),
(18, 54, 0.030, 'Litro', 'Jugo de limón fresco recién extraído para la acidez'),
(47, 54, 0.030, 'Litro', 'Jarabe de goma para balancear el amargor'),
(42, 54, 0.500, 'Unidad', 'Clara de huevo batida para lograr la consistencia de espuma'),

-- 55. Chilcano de Pisco
(46, 55, 0.060, 'Litro', 'Pisco puro para la base del trago largo'),
(18, 55, 0.010, 'Litro', 'Gotas de zumo de limón fresco'),
(47, 55, 0.150, 'Botella', 'Gaseosa de jengibre blanca para completar el vaso'),

-- 56. Coctel de Algarrobina
(46, 56, 0.045, 'Litro', 'Pisco puro para la base del coctel cremoso'),
(32, 56, 0.060, 'Litro', 'Leche evaporada o entera líquida para la textura'),
(42, 56, 0.500, 'Unidad', 'Yema de huevo para dar cuerpo y densidad a la mezcla'),
(85, 56, 0.030, 'Litro', 'Salsa o jarabe de algarrobina dulce'),

-- 57. Cuba Libre
(86, 57, 0.060, 'Litro', 'Ron blanco o dorado de barra'),
(47, 57, 0.200, 'Litro', 'Gaseosa negra de cola para completar el trago largo'),
(18, 57, 0.015, 'kg', 'Rodajas de limón para aromatizar e incorporar al vaso'),

-- 58. Vodka con Naranja
(87, 58, 0.060, 'Litro', 'Vodka puro estándar refrigerado'),
(81, 58, 0.180, 'kg', 'Naranja fresca exprimida para obtener el jugo natural del vaso');


-- 14. Mesa_Restaurante  (Diccionario — IDs explícitos, sin IDENTITY)
INSERT INTO [Mesa_Restaurante] ([ID_Mesa], [Numero_Mesa], [Capacidad], [Ubicacion], [Estado]) VALUES
(1,  1,  4, 'Salón Principal — Entrada', 'Disponible'),
(2,  2,  6, 'Salón Principal — Medio',   'Disponible'),
(3,  3,  2, 'Salón Principal — Fondo',   'Disponible'),
(4,  4,  7, 'Salón Principal — Entrada', 'Disponible'),
(5,  5,  4, 'Salón Principal — Medio',   'Disponible'),
(6,  6,  5, 'Salón Principal — Fondo',   'Disponible'),
(7,  7,  2, 'Salón Principal — Entrada', 'Disponible'),
(8,  8,  6, 'Salón Principal — Medio',   'Disponible'),
(9,  9,  4, 'Salón Principal — Fondo',   'Disponible'),
(10, 10, 7, 'Salón Principal — Entrada', 'Disponible'),
(11, 11, 3, 'Salón Principal — Medio',   'Disponible'),
(12, 12, 5, 'Salón Principal — Fondo',   'Disponible');

-- 15. Cliente  (IDENTITY → ID omitido; IDs resultantes: 1, 2, 3)
INSERT INTO [Cliente] ([Nombre], [Apellidos], [Telefono], [Email], [Fecha_Nacimiento], [Direccion], [DNI], [RUC]) VALUES
('Pedro',   'Flores Mendoza', '987123456', 'pedro.flores@gmail.com',  '1990-03-15', 'Av. Benavides 4521, Miraflores, Lima',    '78901234', NULL),
('Ana',     'Torres Vásquez', '976543219', 'ana.torres@hotmail.com',   '1985-07-22', 'Jr. Azángaro 896, Cercado de Lima, Lima', '89012345', NULL),
('Roberto', 'Ríos Cáceres',   '965321478', 'roberto.rios@empresa.pe',  '1978-11-08', 'Calle Monte Rosa 350, Surco, Lima',       '90123456', '10901234569');

-- Archivos de clientes por separado, agregar.



-- 16. Pedido  (IDENTITY → ID omitido; atendidos por Empleado 2 = María (mesera))
--     SubTotal = Total / 1.18 | IGV 18 % incluido en precio de venta
INSERT INTO [Pedido] ([ID_Empleado], [ID_Cliente], [ID_Mesa], [Fecha], [Estado_Pedido], [Detalle_Pedido], [SubTotal], [Total]) VALUES
(2, 1, 1, '05-10-2025', 'Entregado',      '2x Ají de Gallina',  42.37, 50.00),
(2, 2, 2, '05-10-2025', 'Entregado',      '1x Lomo Saltado',    29.66, 35.00),
(2, 3, 3, '05-10-2025', 'En preparación', '3x Causa Limeña',    45.76, 54.00);
-- Archivos de pedidos por separado, agregar.


-- 17. Pago  (IDENTITY → ID omitido; monto = Total del pedido correspondiente)
INSERT INTO [Pago] ([Fecha_Hora_Pago], [Monto], [Metodo_Pago], [Detalles_Tarjeta], [Estado], [ID_Pedido]) VALUES
('05-10-2025 13:50:00', 50.00, 'Tarjeta Débito', 'VISA **** **** **** 4532', 'Completado', 1),
('05-10-2025 14:45:00', 35.00, 'Efectivo',        NULL,                       'Completado', 2),
('05-10-2025 21:00:00', 54.00, 'Yape',            'Yape 965321478',           'Completado', 3);


-- 18. Comprobante_Pago  (IDENTITY → ID omitido; Pedido 3 genera Factura por RUC de Roberto)
INSERT INTO [Comprobante_Pago] ([ID_Pedido], [Tipo_Comprobante], [Numero_Comprobante], [Serie], [Fecha_Emision], [Sub_Total], [Monto_Total], [IGV], [Estado_Comprobante], [Metodo_Pago], [Razon_Social], [RUC], [Direccion_Fiscal]) VALUES
(1, 'Boleta',  'B001-0001', 'B001', '05-10-2025 13:51:00', 42.37, 50.00, 7.63, 'Emitido', 'Tarjeta Débito', 'Pedro Flores Mendoza',  NULL,          NULL),
(2, 'Boleta',  'B001-0002', 'B001', '05-10-2025 14:46:00', 29.66, 35.00, 5.34, 'Emitido', 'Efectivo',       'Ana Torres Vásquez',    NULL,          NULL),
(3, 'Factura', 'F001-0001', 'F001', '05-10-2025 21:01:00', 45.76, 54.00, 8.24, 'Emitido', 'Yape',           'Roberto Ríos Cáceres',  '10901234569', 'Calle Monte Rosa 350, Surco, Lima');

-- 19. Pedido_Detalle  (IDENTITY → ID omitido; PrecioUnitario = precio con IGV incluido)
INSERT INTO [Pedido_Detalle] ([ID_Pedido], [ID_Producto], [Cantidad], [PrecioUnitario]) VALUES
(1, 1, 2, 25.00),
(2, 2, 1, 35.00),
(3, 3, 3, 18.00);

-- 20. Reservacion  (IDENTITY → ID omitido; reservas futuras de los 3 clientes)
INSERT INTO [Reservacion] ([Fecha_Hora], [Numero_Personas], [Ocasion_Especial], [Estado_Reservacion], [Notas], [ID_Cliente], [ID_Mesa]) VALUES
('15-01-2026 13:30:00', 3, NULL, 'Completada', 'Mesa cerca a la entrada', 1420, 1),
('22-01-2026 20:15:00', 5, 'Cumpleaños', 'Completada', NULL, 843, 2),
('05-02-2026 14:00:00', 2, 'Aniversario', 'Completada', 'Prefiere zona tranquila', 2105, 3),
('14-02-2026 21:00:00', 6, 'Aniversario', 'Completada', 'Celebración especial', 344, 4),
('18-02-2026 19:45:00', 4, NULL, 'Completada', NULL, 2891, 5),
('03-03-2026 13:15:00', 5, 'Cena de Negocios', 'Completada', 'Prefiere zona tranquila', 1102, 6),
('12-03-2026 20:30:00', 1, NULL, 'Cancelada', NULL, 567, 7),
('20-03-2026 14:30:00', 6, 'Reunión Familiar', 'Completada', 'Espacio para cochecito', 1984, 8),
('28-03-2026 21:15:00', 3, NULL, 'Completada', NULL, 2450, 9),
('04-04-2026 13:00:00', 7, 'Cumpleaños', 'Completada', 'Celebración especial', 89, 10),
('11-04-2026 19:30:00', 2, NULL, 'Completada', 'Cliente solicita silla para bebé', 1732, 11),
('19-04-2026 20:00:00', 4, 'Cena de Negocios', 'Completada', NULL, 2999, 12),
('25-04-2026 14:15:00', 4, 'Reunión Familiar', 'Completada', 'Mesa cerca a la entrada', 512, 1),
('02-05-2026 21:00:00', 4, NULL, 'Completada', NULL, 1267, 2),
('08-05-2026 13:45:00', 2, NULL, 'Completada', 'Prefiere zona tranquila', 2341, 3),
('15-05-2026 20:30:00', 5, 'Cumpleaños', 'Confirmada', 'Celebración especial', 903, 4),
('16-05-2026 14:00:00', 3, NULL, 'Confirmada', NULL, 154, 5),
('17-05-2026 19:15:00', 5, 'Cena de Negocios', 'Confirmada', 'Prefiere zona tranquila', 2780, 6),
('22-05-2026 21:30:00', 2, 'Aniversario', 'Confirmada', NULL, 1115, 7),
('24-05-2026 13:30:00', 6, 'Reunión Familiar', 'Confirmada', 'Espacio para cochecito', 452, 8),
('29-05-2026 20:00:00', 4, NULL, 'Confirmada', NULL, 1890, 9),
('03-06-2026 14:15:00', 6, 'Cumpleaños', 'Confirmada', 'Celebración especial', 2143, 10),
('06-06-2026 19:45:00', 3, NULL, 'Confirmada', 'Cliente solicita silla para bebé', 725, 11),
('12-06-2026 21:00:00', 5, 'Cena de Negocios', 'Confirmada', NULL, 1432, 12),
('14-06-2026 13:00:00', 2, NULL, 'Confirmada', 'Mesa cerca a la entrada', 2055, 1),
('19-06-2026 20:30:00', 6, 'Reunión Familiar', 'Confirmada', NULL, 612, 2),
('21-06-2026 14:30:00', 2, 'Aniversario', 'Confirmada', 'Prefiere zona tranquila', 1840, 3),
('26-06-2026 21:15:00', 7, 'Cumpleaños', 'Confirmada', 'Celebración especial', 2901, 4),
('28-06-2026 19:00:00', 4, NULL, 'Confirmada', NULL, 995, 5),
('03-07-2026 13:30:00', 4, NULL, 'Confirmada', 'Prefiere zona tranquila', 1314, 6),
('05-07-2026 20:15:00', 2, NULL, 'Cancelada', NULL, 2240, 7),
('10-07-2026 14:00:00', 5, 'Reunión Familiar', 'Confirmada', 'Espacio para cochecito', 1521, 8),
('12-07-2026 21:00:00', 3, NULL, 'Confirmada', NULL, 78, 9),
('17-07-2026 13:15:00', 6, 'Cena de Negocios', 'Confirmada', 'Celebración especial', 2611, 10),
('19-07-2026 19:45:00', 2, NULL, 'Confirmada', 'Cliente solicita silla para bebé', 1374, 11),
('24-07-2026 20:30:00', 5, 'Cumpleaños', 'Confirmada', NULL, 499, 12),
('26-07-2026 14:15:00', 4, NULL, 'Confirmada', 'Mesa cerca a la entrada', 1602, 1),
('31-07-2026 21:00:00', 4, 'Aniversario', 'Confirmada', NULL, 2333, 2),
('02-08-2026 13:45:00', 1, NULL, 'Confirmada', 'Prefiere zona tranquila', 911, 3),
('07-08-2026 20:30:00', 7, 'Reunión Familiar', 'Confirmada', 'Celebración especial', 1450, 4),
('09-08-2026 14:00:00', 3, NULL, 'Confirmada', NULL, 2814, 5),
('14-08-2026 19:15:00', 4, 'Cena de Negocios', 'Confirmada', 'Prefiere zona tranquila', 655, 6),
('16-08-2026 21:30:00', 2, NULL, 'Confirmada', NULL, 1922, 7),
('21-08-2026 13:30:00', 6, 'Cumpleaños', 'Confirmada', 'Espacio para cochecito', 1104, 8),
('23-08-2026 20:00:00', 4, NULL, 'Confirmada', NULL, 2187, 9),
('28-08-2026 14:15:00', 5, 'Reunión Familiar', 'Confirmada', 'Celebración especial', 504, 10),
('30-08-2026 19:45:00', 2, NULL, 'Confirmada', 'Cliente solicita silla para bebé', 2711, 11),
('04-09-2026 21:00:00', 4, 'Cena de Negocios', 'Confirmada', NULL, 1399, 12),
('06-09-2026 13:00:00', 3, NULL, 'Confirmada', 'Mesa cerca a la entrada', 841, 1),
('11-09-2026 20:30:00', 5, 'Cumpleaños', 'Confirmada', NULL, 1622, 2),
('13-09-2026 14:30:00', 2, 'Aniversario', 'Confirmada', 'Prefiere zona tranquila', 2290, 3),
('18-09-2026 21:15:00', 6, NULL, 'Confirmada', 'Celebración especial', 415, 4),
('20-09-2026 19:00:00', 2, NULL, 'Confirmada', NULL, 2560, 5),
('25-09-2026 13:30:00', 5, 'Cena de Negocios', 'Confirmada', 'Prefiere zona tranquila', 1033, 6),
('27-09-2026 20:15:00', 2, NULL, 'Cancelada', NULL, 1789, 7),
('02-10-2026 14:00:00', 4, 'Reunión Familiar', 'Confirmada', 'Espacio para cochecito', 1204, 8),
('04-10-2026 21:00:00', 4, NULL, 'Confirmada', NULL, 677, 9),
('09-10-2026 13:15:00', 7, 'Cumpleaños', 'Confirmada', 'Celebración especial', 2411, 10),
('11-10-2026 19:45:00', 3, NULL, 'Confirmada', 'Cliente solicita silla para bebé', 1550, 11),
('16-10-2026 20:30:00', 3, 'Cena de Negocios', 'Confirmada', NULL, 312, 12),
('18-10-2026 14:15:00', 2, NULL, 'Confirmada', 'Mesa cerca a la entrada', 944, 1),
('23-10-2026 21:00:00', 6, 'Aniversario', 'Confirmada', NULL, 2877, 2),
('25-10-2026 13:45:00', 2, NULL, 'Confirmada', 'Prefiere zona tranquila', 1350, 3),
('30-10-2026 20:30:00', 5, 'Reunión Familiar', 'Confirmada', 'Celebración especial', 492, 4),
('01-11-2026 14:00:00', 4, NULL, 'Confirmada', NULL, 2011, 5),
('06-11-2026 19:15:00', 4, 'Cena de Negocios', 'Confirmada', 'Prefiere zona tranquila', 1184, 6),
('08-11-2026 21:30:00', 1, NULL, 'Confirmada', NULL, 2640, 7),
('13-11-2026 13:30:00', 5, 'Cumpleaños', 'Confirmada', 'Espacio para cochecito', 802, 8),
('15-11-2026 20:00:00', 3, NULL, 'Confirmada', NULL, 1945, 9),
('20-11-2026 14:15:00', 6, 'Reunión Familiar', 'Confirmada', 'Celebración especial', 144, 10),
('22-11-2026 19:45:00', 2, NULL, 'Confirmada', 'Cliente solicita trona para bebé', 1650, 11),
('27-11-2026 21:00:00', 5, 'Cena de Negocios', 'Confirmada', NULL, 2388, 12),
('29-11-2026 13:00:00', 4, NULL, 'Confirmada', 'Mesa cerca a la entrada', 711, 1),
('04-12-2026 20:30:00', 4, 'Cumpleaños', 'Confirmada', NULL, 1822, 2),
('06-12-2026 14:30:00', 2, 'Aniversario', 'Confirmada', 'Prefiere zona tranquila', 2940, 3),
('11-12-2026 21:15:00', 7, NULL, 'Confirmada', 'Celebración especial', 555, 4),
('13-12-2026 19:00:00', 3, NULL, 'Confirmada', NULL, 1209, 5),
('18-12-2026 13:30:00', 3, 'Cena de Negocios', 'Confirmada', 'Prefiere zona tranquila', 2433, 6),
('20-12-2026 20:15:00', 2, NULL, 'Confirmada', NULL, 980, 7),
('25-12-2026 14:00:00', 6, 'Reunión Familiar', 'Confirmada', 'Espacio para cochecito', 1642, 8),
('27-12-2026 21:00:00', 2, NULL, 'Confirmada', NULL, 2150, 9),
('30-12-2026 13:15:00', 5, 'Cumpleaños', 'Confirmada', 'Celebración especial', 399, 10),
('02-01-2026 19:45:00', 3, NULL, 'Completada', 'Cliente solicita silla para bebé', 112, 11),
('03-01-2026 20:30:00', 4, 'Cena de Negocios', 'Completada', NULL, 2804, 12),
('04-01-2026 14:15:00', 2, NULL, 'Completada', 'Mesa cerca a la entrada', 991, 1),
('05-01-2026 21:00:00', 5, 'Aniversario', 'Completada', NULL, 1677, 2),
('06-01-2026 13:45:00', 2, NULL, 'Completada', 'Prefiere zona tranquila', 2540, 3),
('08-01-2026 20:30:00', 4, 'Reunión Familiar', 'Completada', 'Celebración especial', 133, 4),
('09-01-2026 14:00:00', 2, NULL, 'Completada', NULL, 2199, 5),
('10-01-2026 19:15:00', 5, 'Cena de Negocios', 'Completada', 'Prefiere zona tranquila', 840, 6),
('11-01-2026 21:30:00', 1, NULL, 'Completada', NULL, 1492, 7),
('12-01-2026 13:30:00', 6, 'Cumpleaños', 'Completada', 'Espacio para cochecito', 2701, 8),
('13-01-2026 20:00:00', 4, NULL, 'Completada', NULL, 650, 9),
('14-01-2026 14:15:00', 7, 'Reunión Familiar', 'Completada', 'Celebración especial', 1833, 10),
('16-01-2026 19:45:00', 3, NULL, 'Completada', 'Cliente solicita silla para bebé', 2455, 11),
('17-01-2026 21:00:00', 4, 'Cena de Negocios', 'Completada', NULL, 509, 12),
('18-01-2026 13:00:00', 3, NULL, 'Completada', 'Mesa cerca a la entrada', 1288, 1),
('19-01-2026 20:30:00', 6, 'Cumpleaños', 'Completada', NULL, 2911, 2),
('20-01-2026 14:30:00', 2, 'Aniversario', 'Completada', 'Prefiere zona tranquila', 740, 3),
('21-01-2026 21:15:00', 5, NULL, 'Completada', 'Celebración especial', 1522, 4),
('23-01-2026 19:00:00', 4, NULL, 'Completada', NULL, 2309, 5),
('24-01-2026 13:30:00', 4, 'Cena de Negocios', 'Completada', 'Prefiere zona tranquila', 611, 6),
('25-01-2026 20:15:00', 2, NULL, 'Completada', NULL, 1433, 7),
('26-01-2026 14:00:00', 4, 'Reunión Familiar', 'Completada', 'Espacio para cochecito', 2890, 8),
('27-01-2026 21:00:00', 3, NULL, 'Completada', NULL, 1105, 9),
('28-01-2026 13:15:00', 6, 'Cumpleaños', 'Completada', 'Celebración especial', 2044, 10),
('29-01-2026 19:45:00', 2, NULL, 'Completada', 'Cliente solicita silla para bebé', 799, 11),
('30-01-2026 20:30:00', 5, 'Cena de Negocios', 'Completada', NULL, 1612, 12),
('31-01-2026 14:15:00', 4, NULL, 'Completada', 'Mesa cerca a la entrada', 2410, 1),
('01-02-2026 21:00:00', 5, 'Aniversario', 'Completada', NULL, 532, 2),
('02-02-2026 13:45:00', 2, NULL, 'Completada', 'Prefiere zona tranquila', 1877, 3),
('03-02-2026 20:30:00', 6, 'Reunión Familiar', 'Completada', 'Celebración especial', 944, 4),
('04-02-2026 14:00:00', 3, NULL, 'Completada', NULL, 2612, 5),
('05-02-2026 19:15:00', 4, 'Cena de Negocios', 'Completada', 'Prefiere zona tranquila', 1355, 6),
('06-02-2026 21:30:00', 1, NULL, 'Completada', NULL, 492, 7),
('07-02-2026 13:30:00', 6, 'Cumpleaños', 'Completada', 'Espacio para cochecito', 2111, 8),
('08-02-2026 20:00:00', 4, NULL, 'Completada', NULL, 1780, 9),
('09-02-2026 14:15:00', 7, 'Reunión Familiar', 'Completada', 'Celebración especial', 2900, 10),
('10-02-2026 19:45:00', 3, NULL, 'Completada', 'Cliente solicita silla para bebé', 612, 11),
('11-02-2026 21:00:00', 4, 'Cena de Negocios', 'Completada', NULL, 1540, 12),
('12-02-2026 13:00:00', 2, NULL, 'Completada', 'Mesa cerca a la entrada', 2311, 1),
('13-02-2026 20:30:00', 6, 'Cumpleaños', 'Completada', NULL, 802, 2),
('14-02-2026 14:30:00', 2, 'Aniversario', 'Completada', 'Prefiere zona tranquila', 1945, 3),
('15-02-2026 21:15:00', 4, NULL, 'Completada', 'Celebración especial', 144, 4),
('16-02-2026 19:00:00', 4, NULL, 'Completada', NULL, 1650, 5),
('17-02-2026 13:30:00', 5, 'Cena de Negocios', 'Completada', 'Prefiere zona tranquila', 2388, 6),
('18-02-2026 20:15:00', 2, NULL, 'Completada', NULL, 711, 7),
('19-02-2026 14:00:00', 5, 'Reunión Familiar', 'Completada', 'Espacio para cochecito', 1822, 8);

-- 21. Proveedor_Ingrediente  (Tabla intermedia — IDs explícitos; coherencia de rubro)
--     Proveedor 1 (Carnes/Aves) → Pollo | Proveedor 2 (Verduras) → Papa Amarilla | Proveedor 3 (Carnes) → Lomo de Res
INSERT INTO [Proveedor_Ingrediente] ([ID_Proveedor], [ID_Ingrediente]) VALUES
-- Proveedor 1: Distribuidora El Campo Cajamarca S.A.C. (Carnes y Aves de Corral)
(1, 1),  -- Pollo
(1, 2),  -- Lomo de Res
(1, 4),  -- Carne de Cerdo
(1, 5),  -- Carne de Res
(1, 6),  -- Carne de Cordero
(1, 56), -- Carne de Pato
(1, 57), -- Gallina
(1, 58), -- Bistec de Res

-- Proveedor 2: Cajamarca Fresh Proveedores E.I.R.L. (Verduras y Tubérculos)
(2, 3),  -- Papa Amarilla
(2, 7),  -- Lechuga
(2, 8),  -- Tomate
(2, 9),  -- Cebolla
(2, 10), -- Yuca
(2, 11), -- Papa Blanca
(2, 13), -- Zanahoria
(2, 14), -- Alvejas
(2, 59), -- Apio
(2, 60), -- Poro
(2, 61), -- Nabo
(2, 62), -- Col

-- Proveedor 3: Carnes del Valle Gavilán E.I.R.L. (Carnes y Embutidos)
(3, 2),  -- Lomo de Res
(3, 4),  -- Carne de Cerdo
(3, 5),  -- Carne de Res
(3, 6),  -- Carne de Cordero
(3, 58), -- Bistec de Res

-- Proveedor 4: Gas Centro Cajamarca S.A.C. (Gas GLP e Industrial)
(4, 48), -- Gas GLP 45kg

-- Proveedor 5: Lácteos Porcón Seleccionados (Lácteos y Quesos)
(5, 30), -- Quesillo
(5, 31), -- Queso Mantecoso
(5, 32), -- Leche
(5, 33), -- Mantequilla
(5, 34), -- Crema de Leche
(5, 45), -- Manjarblanco
(5, 74), -- Queso Crema

-- Proveedor 6: Distribuidora San Ignacio S.A.C. (Abarrotes y Alimentos Secos)
(6, 20), -- Chicha Morada (Maíz seco)
(6, 35), -- Arroz
(6, 36), -- Aceite
(6, 37), -- Sal
(6, 38), -- Azúcar
(6, 39), -- Harina
(6, 40), -- Fideos Tallarines
(6, 41), -- Fideos Cortos
(6, 43), -- Vinagre
(6, 44), -- Sillao
(6, 71), -- Sillao Claro
(6, 72), -- Salsa de Ostión
(6, 75), -- Fideos Canuto
(6, 76), -- Fideos Cabello de Ángel

-- Proveedor 7: Avícola El Porvenir Chota S.A.C. (Aves y Huevos)
(7, 1),  -- Pollo
(7, 42), -- Huevo
(7, 57), -- Gallina

-- Proveedor 8: Huacariz Lácteos Especiales (Lácteos, Yogures y Mantequilla)
(8, 30), -- Quesillo
(8, 31), -- Queso Mantecoso
(8, 32), -- Leche
(8, 33), -- Mantequilla
(8, 45), -- Manjarblanco
(8, 73), -- Yogurt

-- Proveedor 9: Café de Altura San Ignacio E.I.R.L. (Café e Infusiones)
(9, 53), -- Café Pasado (Insumo base / esencia)

-- Proveedor 10: Frutería del Valle Condebamba (Frutas Exóticas y de Estación)
(10, 18), -- Limon
(10, 19), -- Maracuja
(10, 82), -- Piña
(10, 83), -- Fresa
(10, 84), -- Papaya
(10, 85), -- Naranja
(10, 86), -- Plátano

-- Proveedor 11: Soles Gas S.A.C. - Sucursal Cajamarca (Gas GLP)
(11, 48), -- Gas GLP 45kg

-- Proveedor 12: Distribuidora Alva & Hermanos (Bebidas, Aguas y Licores)
(12, 46), -- Pisco
(12, 47), -- Jarabe de Goma
(12, 90), -- Ron
(12, 91), -- Vodka
(12, 92), -- Crema de Menta

-- Proveedor 13: Huertas de Celendín S.A.C. (Hortalizas y Hierbas Aromáticas)
(13, 12), -- Mote
(13, 15), -- Choclo
(13, 16), -- Camote
(13, 17), -- Espinaca
(13, 21), -- Paico
(13, 22), -- Hierbabuena
(13, 23), -- Culantro
(13, 63), -- Caigua
(13, 64), -- Brócoli
(13, 65), -- Vainita
(13, 66), -- Palta

-- Proveedor 14: Pesquera El Pacífico - Sede Cajamarca (Pescados y Mariscos)
(14, 50), -- Trucha
(14, 51), -- Pescado Trucha
(14, 52), -- Pescado Corvina
(14, 53), -- Marisco Camarón
(14, 54), -- Pulpo

-- Proveedor 15: Empaques y Plásticos del Norte (Envases y Descartables)
-- Nota: Al no haber insumos alimenticios directos, se deja listo para futura expansión o se asocia un comodín.

-- Proveedor 16: Trigo de Oro Cajamarquino S.A.C. (Harinas, Panes y Pastelería)
(16, 39), -- Harina
(16, 49), -- Pan de Molde

-- Proveedor 17: EquipaRancho S.A.C. (Menaje y Limpieza)
-- Nota: Sin insumos alimenticios directos.

-- Proveedor 18: Especias y Condimentos del Norte (Especias y Condimentos)
(18, 24), -- Ají Amarillo
(18, 25), -- Ajo
(18, 26), -- Pimienta
(18, 27), -- Comino
(18, 28), -- Orégano
(18, 29), -- Ají Panca
(18, 67), -- Rocoto
(18, 68), -- Ají Limo
(18, 69), -- Palillo
(18, 70), -- Tuco
(18, 87), -- Canela
(18, 88), -- Clavo de Olor
(18, 89); -- Esencia de Vainilla



-- 22. Inventario  (IDENTITY → ID omitido; stock actual de cada ingrediente)
INSERT INTO [Inventario] ([Cantidad_Stock], [Fecha_Ultima_Reposicion], [Stock_Minimo], [Stock_Maximo], [ID_Ingrediente]) VALUES
-- Carnes, Aves y Cuyes (Alta rotación, control diario/semanal)
(22.50, '12-05-2026',  8.00,  40.00, 1),  -- Pollo
(14.00, '14-05-2026',  5.00,  25.00, 2),  -- Lomo de Res
(18.00, '13-05-2026',  6.00,  30.00, 4),  -- Carne de Cerdo
(15.50, '14-05-2026',  5.00,  30.00, 5),  -- Carne de Res
(9.00,  '11-05-2026',  4.00,  20.00, 6),  -- Carne de Cordero
(12.00, '10-05-2026',  4.00,  15.00, 55), -- Carne de Cuy
(8.50,  '12-05-2026',  3.00,  15.00, 56), -- Carne de Pato
(11.00, '13-05-2026',  4.00,  20.00, 57), -- Gallina
(16.00, '14-05-2026',  6.00,  25.00, 58), -- Bistec de Res

-- Tubérculos, Verduras y Hortalizas (Perecederos, stock controlado)
(35.00, '15-05-2026', 15.00,  60.00, 3),  -- Papa Amarilla
(15.00, '16-05-2026',  8.00,  25.00, 7),  -- Lechuga
(20.00, '15-05-2026', 10.00,  35.00, 8),  -- Tomate
(28.50, '15-05-2026', 12.00,  45.00, 9),  -- Cebolla
(18.00, '14-05-2026',  8.00,  30.00, 10), -- Yuca
(45.00, '15-05-2026', 20.00,  80.00, 11), -- Papa Blanca
(22.00, '14-05-2026', 10.00,  40.00, 12), -- Mote
(12.00, '15-05-2026',  5.00,  20.00, 13), -- Zanahoria
(9.50,  '15-05-2026',  4.00,  15.00, 14), -- Alvejas
(25.00, '16-05-2026', 10.00,  40.00, 15), -- Choclo
(15.00, '14-05-2026',  6.00,  25.00, 16), -- Camote
(6.00,  '16-05-2026',  3.00,  12.00, 17), -- Espinaca
(8.00,  '15-05-2026',  3.00,  15.00, 59), -- Apio
(10.00, '15-05-2026',  4.00,  15.00, 60), -- Poro
(7.00,  '13-05-2026',  3.00,  12.00, 61), -- Nabo
(9.00,  '14-05-2026',  4.00,  15.00, 62), -- Col
(8.50,  '15-05-2026',  3.00,  15.00, 63), -- Caigua
(11.00, '16-05-2026',  4.00,  18.00, 64), -- Brócoli
(10.00, '15-05-2026',  4.00,  16.00, 65), -- Vainita
(14.00, '16-05-2026',  5.00,  20.00, 66), -- Palta

-- Frutas frescas (Para jugos y postres)
(24.00, '15-05-2026', 10.00,  40.00, 18), -- Limon
(15.50, '15-05-2026',  6.00,  25.00, 19), -- Maracuja
(12.00, '14-05-2026',  5.00,  20.00, 82), -- Piña
(7.00,  '15-05-2026',  3.00,  12.00, 83), -- Fresa
(14.00, '15-05-2026',  5.00,  20.00, 84), -- Papaya
(18.50, '15-05-2026',  8.00,  30.00, 85), -- Naranja
(12.00, '14-05-2026',  5.00,  20.00, 86), -- Plátano

-- Hierbas Aromáticas y Ajíes frescos
(5.00,  '15-05-2026',  2.00,   8.00, 21), -- Paico
(4.50,  '16-05-2026',  2.00,   8.00, 22), -- Hierbabuena
(6.50,  '15-05-2026',  2.00,  10.00, 23), -- Culantro
(14.00, '14-05-2026',  5.00,  25.00, 24), -- Ají Amarillo
(5.00,  '15-05-2026',  2.00,  10.00, 67), -- Rocoto
(4.00,  '16-05-2026',  1.50,   8.00, 68), -- Ají Limo

-- Pescados y Mariscos (Cadena de frío estricta)
(16.50, '14-05-2026',  6.00,  25.00, 50), -- Trucha
(15.00, '14-05-2026',  5.00,  25.00, 51), -- Pescado Trucha
(12.00, '13-05-2026',  4.00,  20.00, 52), -- Pescado Corvina
(8.00,  '13-05-2026',  3.00,  15.00, 53), -- Marisco Camarón
(6.50,  '12-05-2026',  2.00,  12.00, 54), -- Pulpo

-- Lácteos y Quesos (Frescos de Cajamarca)
(18.00, '15-05-2026',  8.00,  30.00, 30), -- Quesillo
(12.50, '14-05-2026',  5.00,  25.00, 31), -- Queso Mantecoso
(24.00, '15-05-2026', 10.00,  45.00, 32), -- Leche
(8.00,  '12-05-2026',  3.00,  15.00, 33), -- Mantequilla
(6.00,  '14-05-2026',  2.00,  10.00, 34), -- Crema de Leche
(10.00, '11-05-2026',  4.00,  18.00, 45), -- Manjarblanco
(12.00, '13-05-2026',  4.00,  20.00, 73), -- Yogurt
(5.50,  '14-05-2026',  2.00,  10.00, 74), -- Queso Cream

-- Abarrotes, Alimentos Secos y Pastas (Mayor almacenamiento)
(85.00, '02-05-2026', 30.00, 150.00, 35), -- Arroz
(42.00, '02-05-2026', 15.00,  80.00, 36), -- Aceite
(15.00, '01-05-2026',  5.00,  30.00, 37), -- Sal
(55.00, '02-05-2026', 20.00, 100.00, 38), -- Azúcar
(32.00, '05-05-2026', 10.00,  60.00, 39), -- Harina
(24.00, '06-05-2026',  8.00,  45.00, 40), -- Fideos Tallarines
(18.00, '06-05-2026',  6.00,  35.00, 41), -- Fideos Cortos
(14.00, '03-05-2026',  5.00,  25.00, 75), -- Fideos Canuto
(12.00, '03-05-2026',  4.00,  25.00, 76), -- Fideos Cabello de Ángel
(15.00, '30-04-2026',  5.00,  30.00, 77), -- Garbanzo
(18.00, '30-04-2026',  5.00,  30.00, 78), -- Lenteja
(22.00, '30-04-2026',  6.00,  40.00, 79), -- Frijol
(15.00, '05-05-2026',  5.00,  30.00, 80), -- Harina de Maíz
(45.00, '08-05-2026', 15.00,  80.00, 81), -- Galleta de Soda
(20.00, '01-05-2026',  5.00,  30.00, 20), -- Chicha Morada (Maíz seco)

-- Líquidos, Salsas y Aderezos de Barra/Cocina
(8.00,  '05-05-2026',  3.00,  15.00, 43), -- Vinagre
(14.00, '05-05-2026',  5.00,  25.00, 44), -- Sillao
(6.00,  '05-05-2026',  2.00,  12.00, 71), -- Sillao Claro
(8.50,  '06-05-2026',  3.00,  15.00, 72), -- Salsa de Ostión
(120.00,'14-05-2026', 40.00, 200.00, 42), -- Huevo (Unidades)
(8.00,  '12-05-2026',  3.00,  15.00, 49), -- Pan de Molde

-- Especias y Condimentos Secos (Bajo peso, alta duración)
(4.50,  '28-04-2026',  1.50,   8.00, 25), -- Ajo
(2.50,  '15-04-2026',  0.80,   5.00, 26), -- Pimienta
(3.00,  '15-04-2026',  0.80,   5.00, 27), -- Comino
(1.80,  '20-04-2026',  0.50,   4.00, 28), -- Orégano
(6.00,  '25-04-2026',  2.00,  12.00, 29), -- Ají Panca
(2.00,  '20-04-2026',  0.50,   5.00, 69), -- Palillo
(3.50,  '25-04-2026',  1.00,   6.00, 70), -- Tuco
(2.20,  '18-04-2026',  0.50,   4.00, 87), -- Canela
(1.50,  '18-04-2026',  0.50,   3.00, 88), -- Clavo de Olor
(3.00,  '02-05-2026',  1.00,   6.00, 89), -- Esencia de Vainilla

-- Licores y Barra de Bar (Botellas)
(14.00, '01-05-2026',  4.00,  24.00, 46), -- Pisco
(8.00,  '01-05-2026',  2.00,  12.00, 47), -- Jarabe de Goma
(10.00, '01-05-2026',  3.00,  18.00, 90), -- Ron
(9.00,  '01-05-2026',  3.00,  18.00, 91), -- Vodka
(5.00,  '01-05-2026',  2.00,  10.00, 92), -- Crema de Menta

(3.00,  '10-05-2026',  1.00,   5.00, 48); -- Gas GLP 45kg



-- 23. Promocion  (IDENTITY → ID omitido; IDs resultantes: 1, 2, 3)
INSERT INTO [Promocion] ([Nombre], [Descripcion], [Porcentaje_Descuento], [Fecha_Inicio], [Fecha_Fin], [Estado]) VALUES
('Almuerzo Corporativo', '10% de descuento aplicable al Menú Ejecutivo Especial al pagar con tarjeta de lunes a viernes de 12:00 a 15:00', 10.00, '15-05-2026 00:00:00', '31-12-2026 23:59:00', 1),
('Combo Criollo Doble', '15% de descuento por la compra conjunta de un Lomo Saltado o Ají de Gallina más una Jarra de Chicha Morada', 15.00, '01-05-2026 00:00:00', '30-06-2026 23:59:00', 1),
('Finde Cajamarquino', '20% de descuento en platos tradicionales seleccionados (Cuy Frito, Chicharrón de Cerdo y Caldo Verde) los sábados y domingos', 20.00, '01-05-2026 00:00:00', '31-07-2026 23:59:00', 1),
('Dulce Atardecer', '12% de descuento combinando cualquier Postre Dulce de la casa (como Manjarblanco con Quesillo o Picarones) con una taza de Café Pasado', 12.00, '10-05-2026 00:00:00', '31-08-2026 23:59:00', 1);

-- 24. Producto_Promocion  (Tabla intermedia — IDs explícitos)
INSERT INTO [Producto_Promocion] ([ID_Producto], [ID_Promocion]) VALUES
(22, 1), -- Almuerzo Coporativo

-- Promocion 2
(1,  2),
(2,  2),
(49, 2), 

-- Promocion 3
(4,  3), 
(6,  3), 
(7,  3),

-- Promocion 4
(29, 4),
(35, 4), 
(53, 4); 



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



