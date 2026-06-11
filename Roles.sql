-- ============================================================
-- SCRIPT: Creación de roles, usuarios y permisos
-- Base de datos: RanchoDB
-- Fuente: Secciones 5.1.6, 5.1.7 y 5.1.8 del proyecto
-- ============================================================

USE RanchoDB;
GO

-- ============================================================
-- 1. ROLES DE BASE DE DATOS
-- ============================================================

-- Limpiar roles existentes si ya estaban creados
IF DATABASE_PRINCIPAL_ID('rol_cajero')   IS NOT NULL DROP ROLE rol_cajero;
IF DATABASE_PRINCIPAL_ID('rol_mesero')   IS NOT NULL DROP ROLE rol_mesero;
IF DATABASE_PRINCIPAL_ID('rol_cocinero') IS NOT NULL DROP ROLE rol_cocinero;
IF DATABASE_PRINCIPAL_ID('rol_auditor')  IS NOT NULL DROP ROLE rol_auditor;
GO

CREATE ROLE rol_cajero;
CREATE ROLE rol_mesero;
CREATE ROLE rol_cocinero;
CREATE ROLE rol_auditor;
GO

-- ============================================================
-- 2. LOGINS Y USUARIOS
-- ============================================================

-- Login a nivel servidor (SQL Authentication)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_cajero')
    CREATE LOGIN login_cajero   WITH PASSWORD = 'Cajero$2026!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_mesero')
    CREATE LOGIN login_mesero   WITH PASSWORD = 'Mesero$2026!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_cocinero')
    CREATE LOGIN login_cocinero WITH PASSWORD = 'Cocinero$2026!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_auditor')
    CREATE LOGIN login_auditor  WITH PASSWORD = 'Auditor$2026!';
GO

-- Usuarios dentro de RanchoDB
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_cajero')
    CREATE USER usr_cajero   FOR LOGIN login_cajero;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_mesero')
    CREATE USER usr_mesero   FOR LOGIN login_mesero;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_cocinero')
    CREATE USER usr_cocinero FOR LOGIN login_cocinero;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_auditor')
    CREATE USER usr_auditor  FOR LOGIN login_auditor;
GO

-- Asignar usuarios a sus roles
ALTER ROLE rol_cajero   ADD MEMBER usr_cajero;
ALTER ROLE rol_mesero   ADD MEMBER usr_mesero;
ALTER ROLE rol_cocinero ADD MEMBER usr_cocinero;
ALTER ROLE rol_auditor  ADD MEMBER usr_auditor;
GO

-- ============================================================
-- 3. PERMISOS POR ROL
-- ============================================================

-- ── ADMINISTRADOR (db_owner) ─────────────────────────────────
-- El DBA usa db_owner nativo de SQL Server; no requiere GRANT manual.
-- Se crea un usuario de ejemplo:
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin')
    CREATE LOGIN login_admin WITH PASSWORD = 'Admin$2026!';
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin')
    CREATE USER usr_admin FOR LOGIN login_admin;
ALTER ROLE db_owner ADD MEMBER usr_admin;
GO

-- ── ROL CAJERO ───────────────────────────────────────────────
-- Puede consultar pedidos, registrar pagos y emitir comprobantes
GRANT SELECT, INSERT, UPDATE ON dbo.Pedido             TO rol_cajero;
GRANT SELECT, INSERT         ON dbo.Pago               TO rol_cajero;
GRANT SELECT, INSERT         ON dbo.Comprobante_Pago   TO rol_cajero;
GRANT SELECT                 ON dbo.Producto            TO rol_cajero;
GRANT SELECT                 ON dbo.Cliente             TO rol_cajero;
GRANT SELECT                 ON dbo.Mesa_Restaurante    TO rol_cajero;
-- El cajero NO puede modificar precios ni inventario
DENY  UPDATE, DELETE         ON dbo.Producto            TO rol_cajero;
DENY  INSERT, UPDATE, DELETE ON dbo.Inventario          TO rol_cajero;
GO

-- ── ROL MESERO ───────────────────────────────────────────────
-- Registra y modifica pedidos en estado "Registrado"; consulta carta y mesas
GRANT SELECT, INSERT         ON dbo.Pedido             TO rol_mesero;
GRANT UPDATE                 ON dbo.Pedido             TO rol_mesero;  -- cambiar estado
GRANT SELECT, INSERT         ON dbo.Pedido_Detalle     TO rol_mesero;
GRANT SELECT                 ON dbo.Producto            TO rol_mesero;
GRANT SELECT                 ON dbo.Mesa_Restaurante    TO rol_mesero;
GRANT UPDATE                 ON dbo.Mesa_Restaurante    TO rol_mesero;  -- asignar mesa
GRANT SELECT                 ON dbo.Carta               TO rol_mesero;
-- El mesero NO accede a pagos ni comprobantes
DENY  SELECT, INSERT, UPDATE, DELETE ON dbo.Pago             TO rol_mesero;
DENY  SELECT, INSERT, UPDATE, DELETE ON dbo.Comprobante_Pago TO rol_mesero;
GO

-- ── ROL COCINERO ─────────────────────────────────────────────
-- Solo consulta comandas (pedidos) y actualiza su estado de preparación
GRANT SELECT                 ON dbo.Pedido             TO rol_cocinero;
GRANT SELECT                 ON dbo.Pedido_Detalle     TO rol_cocinero;
GRANT UPDATE                 ON dbo.Pedido             TO rol_cocinero;  -- cambiar estado a "En preparación"/"Listo"
GRANT SELECT                 ON dbo.Producto            TO rol_cocinero;
GRANT SELECT                 ON dbo.Inventario          TO rol_cocinero;
-- El cocinero NO accede a clientes, pagos ni configuración
DENY  SELECT, INSERT, UPDATE, DELETE ON dbo.Pago             TO rol_cocinero;
DENY  SELECT, INSERT, UPDATE, DELETE ON dbo.Cliente           TO rol_cocinero;
DENY  SELECT, INSERT, UPDATE, DELETE ON dbo.Comprobante_Pago TO rol_cocinero;
GO

-- ── ROL AUDITOR ──────────────────────────────────────────────
-- Solo lectura sobre la tabla de auditoría (política sección 5.1.7)
-- Ningún usuario operativo —incluido el Administrador— puede UPDATE/DELETE aquí
GRANT SELECT ON dbo.TBL_AUDITORIA_LOG TO rol_auditor;
DENY  INSERT, UPDATE, DELETE ON dbo.TBL_AUDITORIA_LOG TO rol_auditor;
GO

-- INSERT a TBL_AUDITORIA_LOG solo lo hace la aplicación (usuario de app)
-- Los triggers insertan bajo el contexto del usuario que dispara la operación DML
-- por lo que todos los roles operativos necesitan INSERT implícito vía trigger:
GRANT INSERT ON dbo.TBL_AUDITORIA_LOG TO rol_cajero;
GRANT INSERT ON dbo.TBL_AUDITORIA_LOG TO rol_mesero;
GRANT INSERT ON dbo.TBL_AUDITORIA_LOG TO rol_cocinero;
-- Ningún rol puede UPDATE ni DELETE sobre el log (inmutabilidad)
DENY  UPDATE, DELETE ON dbo.TBL_AUDITORIA_LOG TO rol_cajero;
DENY  UPDATE, DELETE ON dbo.TBL_AUDITORIA_LOG TO rol_mesero;
DENY  UPDATE, DELETE ON dbo.TBL_AUDITORIA_LOG TO rol_cocinero;
GO

-- ============================================================
-- 4. VERIFICACIÓN
-- ============================================================
SELECT
    r.name        AS Rol,
    m.name        AS Usuario,
    m.type_desc   AS Tipo
FROM sys.database_role_members rm
JOIN sys.database_principals   r ON rm.role_principal_id   = r.principal_id
JOIN sys.database_principals   m ON rm.member_principal_id = m.principal_id
WHERE r.name IN ('rol_cajero','rol_mesero','rol_cocinero','rol_auditor','db_owner')
ORDER BY r.name;
GO
