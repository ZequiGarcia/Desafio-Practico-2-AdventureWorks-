/* DMD941 - Comprobaciones complementarias.
   Conexión: localhost\SQLEXPRESS. No modifica tablas del almacén de datos. */
USE [AdventureWorksDW2025];
GO
SET NOCOUNT ON;

-- Conteo global del hecho y su vista. Incluye todas las monedas.
SELECT (SELECT COUNT_BIG(*) FROM dbo.FactInternetSales) AS FilasHecho,
       (SELECT COUNT_BIG(*) FROM desafio2.vVentasInternet) AS FilasVista;

-- Si no hay duplicados de la clave de línea, esta consulta no devuelve filas.
SELECT NumeroPedido, NumeroLinea, COUNT_BIG(*) AS Repeticiones
FROM desafio2.vVentasInternet
GROUP BY NumeroPedido, NumeroLinea
HAVING COUNT_BIG(*) > 1;

-- Claves de dimensión que no se pueden resolver desde el hecho.
SELECT
 SUM(CONVERT(bigint,CASE WHEN d.FechaKey IS NULL THEN 1 ELSE 0 END)) AS SinFecha,
 SUM(CONVERT(bigint,CASE WHEN p.ProductoKey IS NULL THEN 1 ELSE 0 END)) AS SinProducto,
 SUM(CONVERT(bigint,CASE WHEN c.ClienteKey IS NULL THEN 1 ELSE 0 END)) AS SinCliente,
 SUM(CONVERT(bigint,CASE WHEN t.TerritorioKey IS NULL THEN 1 ELSE 0 END)) AS SinTerritorio,
 SUM(CONVERT(bigint,CASE WHEN m.MonedaKey IS NULL THEN 1 ELSE 0 END)) AS SinMoneda
FROM desafio2.vVentasInternet AS f
LEFT JOIN desafio2.vFecha AS d ON d.FechaKey=f.FechaKey
LEFT JOIN desafio2.vProducto AS p ON p.ProductoKey=f.ProductoKey
LEFT JOIN desafio2.vCliente AS c ON c.ClienteKey=f.ClienteKey
LEFT JOIN desafio2.vTerritorio AS t ON t.TerritorioKey=f.TerritorioKey
LEFT JOIN desafio2.vMoneda AS m ON m.MonedaKey=f.MonedaKey;

-- Cobertura de las ventas por año y moneda; no presupone años completos.
SELECT m.CodigoMoneda,d.Anio,MIN(d.Fecha) AS PrimeraFecha,
       MAX(d.Fecha) AS UltimaFecha,COUNT_BIG(*) AS LineasVenta
FROM desafio2.vVentasInternet AS f
JOIN desafio2.vFecha AS d ON d.FechaKey=f.FechaKey
JOIN desafio2.vMoneda AS m ON m.MonedaKey=f.MonedaKey
GROUP BY m.CodigoMoneda,d.Anio
ORDER BY m.CodigoMoneda,d.Anio;
GO
