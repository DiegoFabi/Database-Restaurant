-- ============================================================
-- TRIGGER: TR_Pedido_Auditoria
-- Tabla objetivo: dbo.Pedido
-- Eventos auditados: INSERT, UPDATE, DELETE
-- Campos auditados: Estado_Pedido, SubTotal, Total
-- Base de datos: RanchoDB
-- ============================================================

USE RanchoDB;
GO

IF OBJECT_ID('dbo.TR_Pedido_Auditoria', 'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Pedido_Auditoria;
GO

CREATE TRIGGER dbo.TR_Pedido_Auditoria
ON dbo.Pedido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TipoAccion VARCHAR(10);
    DECLARE @RolUsuario NVARCHAR(128);

    -- Determinar tipo de sentencia DML ejecutada
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @TipoAccion = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @TipoAccion = 'INSERT';
    ELSE
        SET @TipoAccion = 'DELETE';

    -- Determinar el rol activo del usuario en la sesión
    SET @RolUsuario =
        CASE
            WHEN IS_ROLEMEMBER('db_owner')      = 1 THEN 'Administrador'
            WHEN IS_ROLEMEMBER('rol_cajero')    = 1 THEN 'Cajero'
            WHEN IS_ROLEMEMBER('rol_mesero')    = 1 THEN 'Mesero'
            WHEN IS_ROLEMEMBER('rol_cocinero')  = 1 THEN 'Cocinero'
            WHEN IS_ROLEMEMBER('rol_auditor')   = 1 THEN 'Auditor'
            ELSE 'Sin rol asignado'
        END;

    -- ── Auditoría de Estado_Pedido ────────────────────────────────
    IF UPDATE(Estado_Pedido) OR @TipoAccion IN ('INSERT', 'DELETE')
    BEGIN
        INSERT INTO dbo.TBL_AUDITORIA_LOG
            (FechaHora, NombreUsuario, NombreRol, TipoAccion,
             NombreTabla, NombreColumna, OldValue, NewValue,
             HostName, AppName, IDRegistroAfectado)
        SELECT
            GETDATE(),
            SYSTEM_USER,
            @RolUsuario,
            @TipoAccion,
            'Pedido',
            'Estado_Pedido',
            CAST(d.Estado_Pedido AS NVARCHAR(MAX)),
            CAST(i.Estado_Pedido AS NVARCHAR(MAX)),
            HOST_NAME(),
            APP_NAME(),
            COALESCE(i.ID_Pedido, d.ID_Pedido)
        FROM inserted i
        FULL OUTER JOIN deleted d
            ON i.ID_Pedido = d.ID_Pedido
        WHERE ISNULL(CAST(i.Estado_Pedido AS NVARCHAR(MAX)), '')
           <> ISNULL(CAST(d.Estado_Pedido AS NVARCHAR(MAX)), '')
           OR @TipoAccion IN ('INSERT', 'DELETE');
    END

    -- ── Auditoría de SubTotal ─────────────────────────────────────
    IF UPDATE(SubTotal)
    BEGIN
        INSERT INTO dbo.TBL_AUDITORIA_LOG
            (FechaHora, NombreUsuario, NombreRol, TipoAccion,
             NombreTabla, NombreColumna, OldValue, NewValue,
             HostName, AppName, IDRegistroAfectado)
        SELECT
            GETDATE(),
            SYSTEM_USER,
            @RolUsuario,
            @TipoAccion,
            'Pedido',
            'SubTotal',
            CAST(d.SubTotal AS NVARCHAR(MAX)),
            CAST(i.SubTotal AS NVARCHAR(MAX)),
            HOST_NAME(),
            APP_NAME(),
            i.ID_Pedido
        FROM inserted i
        INNER JOIN deleted d ON i.ID_Pedido = d.ID_Pedido
        WHERE ISNULL(i.SubTotal, 0) <> ISNULL(d.SubTotal, 0);
    END

    -- ── Auditoría de Total ────────────────────────────────────────
    IF UPDATE(Total)
    BEGIN
        INSERT INTO dbo.TBL_AUDITORIA_LOG
            (FechaHora, NombreUsuario, NombreRol, TipoAccion,
             NombreTabla, NombreColumna, OldValue, NewValue,
             HostName, AppName, IDRegistroAfectado)
        SELECT
            GETDATE(),
            SYSTEM_USER,
            @RolUsuario,
            @TipoAccion,
            'Pedido',
            'Total',
            CAST(d.Total AS NVARCHAR(MAX)),
            CAST(i.Total AS NVARCHAR(MAX)),
            HOST_NAME(),
            APP_NAME(),
            i.ID_Pedido
        FROM inserted i
        INNER JOIN deleted d ON i.ID_Pedido = d.ID_Pedido
        WHERE ISNULL(i.Total, 0) <> ISNULL(d.Total, 0);
    END

END;
GO

PRINT 'Trigger TR_Pedido_Auditoria creado exitosamente.';