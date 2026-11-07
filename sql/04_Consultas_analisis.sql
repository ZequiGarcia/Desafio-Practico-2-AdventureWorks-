/* DMD941 - Consultas del análisis de ventas. */
USE [AdventureWorksDW2025];
GO
SET NOCOUNT ON;
DECLARE @Moneda varchar(3)='USD';
DECLARE @Anio int=NULL;
DECLARE @Categoria nvarchar(100)=NULL;

DROP TABLE IF EXISTS #DMD941_Analisis;
SELECT f.*,d.Anio,d.Fecha,p.Producto,p.Categoria,p.Subcategoria,
       c.Cliente,t.Grupo,t.Pais,t.Region,m.CodigoMoneda
INTO #DMD941_Analisis
FROM desafio2.vVentasInternet AS f
JOIN desafio2.vFecha AS d ON d.FechaKey=f.FechaKey
JOIN desafio2.vProducto AS p ON p.ProductoKey=f.ProductoKey
JOIN desafio2.vCliente AS c ON c.ClienteKey=f.ClienteKey
JOIN desafio2.vTerritorio AS t ON t.TerritorioKey=f.TerritorioKey
JOIN desafio2.vMoneda AS m ON m.MonedaKey=f.MonedaKey
WHERE m.CodigoMoneda=@Moneda
  AND (@Anio IS NULL OR d.Anio=@Anio)
  AND (@Categoria IS NULL OR p.Categoria=@Categoria);

-- Totales para conciliación con el cubo y Power BI.
SELECT @Moneda AS Moneda,SUM(Ventas) AS Ventas,SUM(CostoProducto) AS CostoProducto,
       SUM(Ventas-CostoProducto) AS UtilidadProducto,
       SUM(Ventas-CostoProducto)/NULLIF(SUM(Ventas),0) AS MargenProducto,
       SUM(Unidades) AS Unidades,COUNT_BIG(*) AS LineasVenta
FROM #DMD941_Analisis;

-- P1 Evolución anual y cobertura.
SELECT Anio,MIN(Fecha) AS PrimeraFecha,MAX(Fecha) AS UltimaFecha,
       SUM(Ventas) AS Ventas,SUM(Ventas-CostoProducto) AS UtilidadProducto
FROM #DMD941_Analisis GROUP BY Anio ORDER BY Anio;

-- P2 Categorías y subcategorías.
SELECT Categoria,Subcategoria,SUM(Ventas) AS Ventas,
       SUM(Ventas-CostoProducto) AS UtilidadProducto,
       SUM(Ventas-CostoProducto)/NULLIF(SUM(Ventas),0) AS MargenProducto
FROM #DMD941_Analisis GROUP BY Categoria,Subcategoria
ORDER BY Categoria,Ventas DESC;

-- P3 Versiones de producto. Se conserva la clave de la dimensión.
SELECT TOP (10) ProductoKey,Producto,SUM(Ventas) AS Ventas,
       SUM(Ventas-CostoProducto) AS UtilidadProducto,
       SUM(Ventas-CostoProducto)/NULLIF(SUM(Ventas),0) AS MargenProducto
FROM #DMD941_Analisis GROUP BY ProductoKey,Producto
ORDER BY Ventas DESC,ProductoKey;

-- P4 Grupos territoriales comerciales.
SELECT Grupo,SUM(Ventas) AS Ventas,
       SUM(Ventas-CostoProducto) AS UtilidadProducto
FROM #DMD941_Analisis GROUP BY Grupo ORDER BY Ventas DESC;

-- P5 Clientes.
SELECT TOP (10) ClienteKey,Cliente,SUM(Ventas) AS Ventas,
       SUM(Ventas-CostoProducto) AS UtilidadProducto
FROM #DMD941_Analisis GROUP BY ClienteKey,Cliente
ORDER BY Ventas DESC,ClienteKey;

-- P6 Contribución y margen por categoría.
SELECT Categoria,SUM(Ventas) AS Ventas,
       SUM(Ventas-CostoProducto) AS UtilidadProducto,
       SUM(Ventas-CostoProducto)/NULLIF(SUM(Ventas),0) AS MargenProducto
FROM #DMD941_Analisis GROUP BY Categoria
ORDER BY UtilidadProducto DESC;

DROP TABLE #DMD941_Analisis;
GO
