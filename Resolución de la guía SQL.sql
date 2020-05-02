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


/* Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.

prod_codigo, prod_detalle ventas_del_producto

ventas de producto
*/
SELECT prod_codigo, prod_detalle, ventas_anyio.cant_vendida, ventas_anyio.anyo FROM Producto INNER JOIN 

(SELECT item_producto, SUM(item_cantidad) AS cant_vendida, YEAR(fact_fecha) AS anyo FROM Item_Factura INNER JOIN Factura
ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero

GROUP BY item_producto, YEAR(fact_fecha)) AS ventas_anyio

ON prod_codigo = ventas_anyio.item_producto

--GROUP BY prod_codigo, prod_detalle 
--ORDER BY item_producto