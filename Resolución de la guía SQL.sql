USE [GD2015C1]
GO

-- Ejercicio 1

SELECT clie_codigo, clie_razon_social  FROM Cliente
WHERE clie_limite_credito > 1000
ORDER BY clie_codigo

-- Ejercicio 2


SELECT prod_codigo, prod_detalle, fact_fecha AS fecha_venta, item_cantidad AS cant_vendida

FROM Factura INNER JOIN Item_Factura 
ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
INNER JOIN Producto ON prod_codigo = item_producto

WHERE YEAR(fact_fecha) = 2012

ORDER BY cant_vendida DESC

-- Ejercicio 3


SELECT prod_codigo, prod_detalle, stoc_cantidad
FROM Producto INNER JOIN STOCK 
ON prod_codigo = stoc_producto
ORDER BY prod_detalle 

-- Ejercicio 4


SELECT tabla1.prod_codigo, tabla1.prod_detalle, tabla1.cant_componentes, tabla2.promedio_stock FROM

(SELECT prod_codigo, prod_detalle, COUNT(comp_componente) AS cant_componentes FROM
Producto LEFT JOIN Composicion ON comp_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle) AS tabla1

INNER JOIN 

(SELECT stoc_producto, AVG(stoc_cantidad) AS promedio_stock FROM STOCK 
GROUP BY stoc_producto HAVING AVG(stoc_cantidad) > 100 ) AS tabla2 
 
ON tabla2.stoc_producto = tabla1.prod_codigo

ORDER BY tabla1.cant_componentes DESC

-- Ejercicio 5


/*
Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
*/

SELECT prod_codigo, prod_detalle, SUM(ISNULL(item_cantidad, 0)) AS egresos FROM 

  Producto LEFT OUTER JOIN  Item_Factura
	ON prod_codigo = item_producto   
	LEFT OUTER JOIN Factura
	ON fact_tipo = item_tipo 
	AND fact_sucursal = item_sucursal 
	AND fact_numero = item_numero
	WHERE YEAR(fact_fecha) = 2012
	GROUP BY prod_codigo, prod_detalle HAVING SUM(ISNULL(item_cantidad, 0)) > (SELECT SUM(ISNULL(item_cantidad, 0)) FROM

	Factura INNER JOIN Item_Factura 
	ON fact_tipo = item_tipo 
	AND fact_sucursal = item_sucursal 
	AND fact_numero = item_numero 
	WHERE YEAR(fact_fecha) = 2011
	AND prod_codigo = item_producto)

ORDER BY prod_codigo 



--  Ejercicio 6

/*
Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’

Todos los rubros
rubr_id, rubr_detalle, sum(productos de rubro) sum(stock total de cada prod del rubro)
*/

SELECT rubr_id, rubr_detalle, (SELECT COUNT(*) FROM Producto WHERE prod_rubro = r1.rubr_id) AS cant_productos, 
 	(SELECT SUM(stoc_cantidad) FROM Rubro AS r2 INNER JOIN Producto ON rubr_id = prod_rubro 
	LEFT OUTER JOIN STOCK ON prod_codigo = stoc_producto WHERE r1.rubr_id = r2.rubr_id) AS stoc_total 
FROM Rubro AS r1