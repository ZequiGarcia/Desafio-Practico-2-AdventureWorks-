/*
-- Ejecutar en SSMS conectado a localhost\SQLEXPRESS mediante Windows.
-- Cuenta verificada en las propiedades del servicio Analysis Services (OLAP).
-- Crea el inicio de sesion y el usuario si no existen y concede SELECT
-- sobre el esquema desafio2 de AdventureWorksDW2025.
*/

USE [master];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE [name] = N'NT SERVICE\MSOLAP$OLAP'
)
BEGIN
    CREATE LOGIN [NT SERVICE\MSOLAP$OLAP] FROM WINDOWS;
END;
GO

USE [AdventureWorksDW2025];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = N'NT SERVICE\MSOLAP$OLAP'
)
BEGIN
    CREATE USER [NT SERVICE\MSOLAP$OLAP]
        FOR LOGIN [NT SERVICE\MSOLAP$OLAP];
END;

GRANT SELECT ON SCHEMA::[desafio2] TO [NT SERVICE\MSOLAP$OLAP];
GO

-- Resultado esperado: una fila con Esquema=desafio2,
-- Permiso=SELECT y Estado=GRANT (o GRANT_WITH_GRANT_OPTION si ya existia).
SELECT
    CONVERT(nvarchar(128), SERVERPROPERTY(N'ServerName')) AS Instancia,
    DB_NAME() AS BaseDatos,
    u.[name] AS Cuenta,
    s.[name] AS Esquema,
    p.permission_name AS Permiso,
    p.state_desc AS Estado
FROM sys.database_permissions AS p
INNER JOIN sys.schemas AS s
    ON p.class = 3 AND p.major_id = s.schema_id
INNER JOIN sys.database_principals AS u
    ON p.grantee_principal_id = u.principal_id
WHERE u.[name] = N'NT SERVICE\MSOLAP$OLAP'
  AND s.[name] = N'desafio2'
  AND p.permission_name = N'SELECT';
