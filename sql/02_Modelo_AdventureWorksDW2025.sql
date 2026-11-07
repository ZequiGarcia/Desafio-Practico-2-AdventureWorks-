/* Desafio Practico 2 - Modelo de ventas por Internet
   Base confirmada: AdventureWorksDW2025
   Instancia relacional: localhost\SQLEXPRESS
   Abrir este archivo completo en SSMS y ejecutar con F5.
   Crea o actualiza seis vistas en el esquema desafio2.
*/
USE [AdventureWorksDW2025];
GO
SET NOCOUNT ON;
IF DB_NAME() NOT LIKE N'AdventureWorksDW%'
    THROW 50003, 'Seleccione primero la base AdventureWorksDW restaurada.', 1;
IF OBJECT_ID(N'dbo.FactInternetSales',N'U') IS NULL
    THROW 50004, 'Falta FactInternetSales. Se necesita la version DW de AdventureWorks.', 1;
IF SCHEMA_ID(N'desafio2') IS NULL
    EXEC(N'CREATE SCHEMA desafio2 AUTHORIZATION dbo;');
GO
CREATE OR ALTER VIEW desafio2.vFecha AS
SELECT DateKey AS FechaKey, FullDateAlternateKey AS Fecha,
       CONVERT(int,CalendarYear) AS Anio,
       CONVERT(int,CalendarYear)*10 + CONVERT(int,CalendarQuarter) AS TrimestreKey,
       CONCAT(CalendarYear,N' T',CalendarQuarter) AS Trimestre,
       CONVERT(int,CalendarYear)*100 + CONVERT(int,MonthNumberOfYear) AS MesKey,
       CONCAT(CalendarYear,N'-',RIGHT(CONCAT(N'0',MonthNumberOfYear),2)) AS Mes,
       CONVERT(int,MonthNumberOfYear) AS NumeroMes
FROM dbo.DimDate;
GO
CREATE OR ALTER VIEW desafio2.vProducto AS
SELECT p.ProductKey AS ProductoKey, p.ProductAlternateKey AS CodigoProducto,
       CONCAT(p.EnglishProductName,N' [',p.ProductKey,N']') AS Producto,
       ISNULL(s.ProductSubcategoryKey,-1) AS SubcategoriaKey,
       ISNULL(s.EnglishProductSubcategoryName,N'Sin subcategoria') AS Subcategoria,
       ISNULL(c.ProductCategoryKey,-1) AS CategoriaKey,
       ISNULL(c.EnglishProductCategoryName,N'Sin categoria') AS Categoria
FROM dbo.DimProduct AS p
LEFT JOIN dbo.DimProductSubcategory AS s ON s.ProductSubcategoryKey=p.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory AS c ON c.ProductCategoryKey=s.ProductCategoryKey;
GO
CREATE OR ALTER VIEW desafio2.vCliente AS
SELECT c.CustomerKey AS ClienteKey, c.CustomerAlternateKey AS CodigoCliente,
       CONCAT(LTRIM(RTRIM(CONCAT(c.FirstName,N' ',c.LastName))),N' [',c.CustomerAlternateKey,N']') AS Cliente,
       ISNULL(g.EnglishCountryRegionName,N'Sin pais') AS PaisCliente,
       ISNULL(g.City,N'Sin ciudad') AS CiudadCliente
FROM dbo.DimCustomer AS c
LEFT JOIN dbo.DimGeography AS g ON g.GeographyKey=c.GeographyKey;
GO
CREATE OR ALTER VIEW desafio2.vTerritorio AS
SELECT SalesTerritoryKey AS TerritorioKey,
       SalesTerritoryRegion AS Region,
       SalesTerritoryCountry AS Pais,
       ISNULL(SalesTerritoryGroup,N'Sin grupo') AS Grupo
FROM dbo.DimSalesTerritory;
GO
CREATE OR ALTER VIEW desafio2.vMoneda AS
SELECT CurrencyKey AS MonedaKey,
       RTRIM(CurrencyAlternateKey) AS CodigoMoneda,
       CurrencyName AS Moneda
FROM dbo.DimCurrency;
GO
CREATE OR ALTER VIEW desafio2.vVentasInternet AS
SELECT SalesOrderNumber AS NumeroPedido, CONVERT(int,SalesOrderLineNumber) AS NumeroLinea,
       OrderDateKey AS FechaKey, ProductKey AS ProductoKey,
       CustomerKey AS ClienteKey, SalesTerritoryKey AS TerritorioKey, CurrencyKey AS MonedaKey,
       CONVERT(decimal(19,4),SalesAmount) AS Ventas,
       CONVERT(decimal(19,4),TotalProductCost) AS CostoProducto,
       CONVERT(bigint,OrderQuantity) AS Unidades,
       CONVERT(bigint,1) AS LineasVenta
FROM dbo.FactInternetSales;
GO

-- Verificacion: cada vista debe conservar el numero de filas de su origen.
SELECT 'vFecha' AS Vista,
       (SELECT COUNT_BIG(*) FROM dbo.DimDate) AS RegistrosOrigen,
       (SELECT COUNT_BIG(*) FROM desafio2.vFecha) AS RegistrosVista
UNION ALL
SELECT 'vProducto', (SELECT COUNT_BIG(*) FROM dbo.DimProduct),
       (SELECT COUNT_BIG(*) FROM desafio2.vProducto)
UNION ALL
SELECT 'vCliente', (SELECT COUNT_BIG(*) FROM dbo.DimCustomer),
       (SELECT COUNT_BIG(*) FROM desafio2.vCliente)
UNION ALL
SELECT 'vTerritorio', (SELECT COUNT_BIG(*) FROM dbo.DimSalesTerritory),
       (SELECT COUNT_BIG(*) FROM desafio2.vTerritorio)
UNION ALL
SELECT 'vMoneda', (SELECT COUNT_BIG(*) FROM dbo.DimCurrency),
       (SELECT COUNT_BIG(*) FROM desafio2.vMoneda)
UNION ALL
SELECT 'vVentasInternet', (SELECT COUNT_BIG(*) FROM dbo.FactInternetSales),
       (SELECT COUNT_BIG(*) FROM desafio2.vVentasInternet);
GO
