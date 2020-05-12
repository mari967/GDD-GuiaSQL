USE [GD2015C1]
GO



-- Ejercicio 1

/*
Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
igual a $ 1000 ordenado por código de cliente.
*/

SELECT clie_codigo, clie_razon_social  FROM Cliente
WHERE clie_limite_credito > 1000
ORDER BY clie_codigo



-- Ejercicio 2


/*
Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
cantidad vendida.
*/

SELECT prod_codigo, prod_detalle, fact_fecha AS fecha_venta, item_cantidad AS cant_vendida

FROM Factura INNER JOIN Item_Factura 
ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
INNER JOIN Producto ON prod_codigo = item_producto

WHERE YEAR(fact_fecha) = 2012

ORDER BY cant_vendida DESC



-- Ejercicio 3

/*
Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.
*/

SELECT prod_codigo, prod_detalle, stoc_cantidad
FROM Producto INNER JOIN STOCK 
ON prod_codigo = stoc_producto
ORDER BY prod_detalle 



-- Ejercicio 4

/*
Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.
*/

SELECT tabla1.prod_codigo, tabla1.prod_detalle, tabla1.cant_componentes, tabla2.promedio_stock FROM

(SELECT prod_codigo, prod_detalle, COUNT(comp_componente) AS cant_componentes FROM
Producto LEFT JOIN Composicion ON comp_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle) AS tabla1

INNER JOIN 

(SELECT stoc_producto, AVG(stoc_cantidad) AS promedio_stock FROM STOCK 
GROUP BY stoc_producto HAVING AVG(stoc_cantidad) > 100 ) AS tabla2 
 
ON tabla2.stoc_producto = tabla1.prod_codigo
ORDER BY tabla1.cant_componentes DESC

-- *** Una soluciòn con subselect  ***

SELECT prod_codigo, prod_detalle, COUNT(comp_componente) AS cant_componentes

FROM
Producto LEFT JOIN Composicion ON comp_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle HAVING (SELECT AVG(stoc_cantidad) FROM STOCK where stoc_producto = prod_codigo ) > 100
order by cant_componentes DESC



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
*/

SELECT rubr_id, rubr_detalle, (SELECT COUNT(*) FROM Producto WHERE prod_rubro = r1.rubr_id) AS cant_productos, 
 	(SELECT SUM(stoc_cantidad) FROM Rubro AS r2 INNER JOIN Producto ON rubr_id = prod_rubro 
	LEFT OUTER JOIN STOCK ON prod_codigo = stoc_producto WHERE r1.rubr_id = r2.rubr_id) AS stoc_total 
FROM Rubro AS r1


WHERE (SELECT SUM(stoc_cantidad) FROM Rubro AS r2 INNER JOIN Producto ON rubr_id = prod_rubro -- Preguntar
	LEFT OUTER JOIN STOCK ON prod_codigo = stoc_producto WHERE r1.rubr_id = r2.rubr_id) 

	 > (SELECT stoc_cantidad FROM STOCK WHERE stoc_producto = '00000000' AND stoc_deposito = 00)



-- Ejercicio 7

/*
 Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock.
*/

SELECT *, CAST((p.precio_max - p.precio_min )*100/p.precio_min AS decimal(12, 2)) AS dif FROM (SELECT prod_codigo, prod_detalle, 
(SELECT MAX(item_precio) FROM Item_Factura WHERE item_producto = prod_codigo) AS precio_max,
(SELECT MIN(item_precio) FROM Item_Factura WHERE item_producto = prod_codigo) AS precio_min

FROM Producto INNER JOIN STOCK ON prod_codigo = stoc_producto
WHERE stoc_cantidad > 0) AS p 

GROUP BY p.prod_codigo, p.prod_detalle, p.precio_max, p.precio_min



-- Ejercicio 8

/*
Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.
*/

SELECT prod_detalle, (SELECT MAX(stoc_cantidad) FROM STOCK WHERE stoc_producto = prod_codigo) AS stoc_maximo FROM Producto INNER JOIN 

(SELECT stoc_producto FROM STOCK 
GROUP BY stoc_producto HAVING COUNT(stoc_deposito) = (SELECT COUNT(*) FROM DEPOSITO)) AS t -- Hay 33 depósitos

ON prod_codigo = t.stoc_producto -- Da una tabla vacía como resultado



-- Ejercicio 9

/*
 Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados
*/

SELECT tabla1.jefe_id, tabla1.empleado_a_cargo, tabla1.empl_nombre, 
	(SELECT COUNT(*) FROM DEPOSITO where tabla1.jefe_id = depo_encargado OR tabla1.empleado_a_cargo = depo_encargado)
	AS  depositos_emple_mas_jefe
 FROM (SELECT E1.empl_codigo AS jefe_id, E2.empl_codigo empleado_a_cargo, E2.empl_nombre FROM Empleado E1 LEFT OUTER JOIN Empleado E2
ON  E1.empl_codigo = E2.empl_jefe --AND  E2.empl_codigo IS NOT NULL
) AS tabla1

WHERE  tabla1.empleado_a_cargo IS NOT NULL



-- Ejercicio 10

/*
Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo
*/


SELECT TOP 10 prod_codigo, prod_detalle, SUM(item_cantidad) cant_ventas_totales,

(SELECT TOP 1 tabla1.fact_cliente FROM (SELECT fact_cliente, SUM(item_cantidad) as cant_comprada 
	FROM Factura INNER JOIN Item_Factura 
ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
 
WHERE item_producto = prod_codigo
GROUP BY fact_cliente) AS tabla1  ORDER BY tabla1.cant_comprada DESC) AS mejor_comprador_id

FROM Producto INNER JOIN Item_Factura ON prod_codigo = item_producto

GROUP BY prod_codigo, prod_detalle
ORDER BY cant_ventas_totales DESC


-- Ejercicio 11

/*
Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.
*/

-- familia_detalle, productos vendidos por familia, monto de las centas sin impuestos

-- productos vendidos por familia

SELECT fami_detalle, cant_prod_vendidos, valor_ventas FROM 

(SELECT tabla1.prod_familia, 
COUNT(item_cantidad) AS cant_prod_vendidos, SUM(tabla1.item_total) AS valor_ventas 
FROM (SELECT prod_familia, item_cantidad, item_cantidad*item_precio AS item_total
FROM Producto INNER JOIN Item_Factura ON prod_codigo = item_producto) AS tabla1

GROUP BY tabla1.prod_familia) AS tabla2 INNER JOIN Familia ON tabla2.prod_familia = Familia.fami_id

WHERE fami_id IN 

(SELECT tabla3.prod_familia FROM (SELECT prod_familia, item_cantidad*item_precio AS item_total, YEAR(fact_fecha) AS anio
FROM Factura INNER JOIN Item_Factura 
ON item_tipo = fact_tipo 
AND item_sucursal = fact_sucursal 
AND fact_numero = item_numero
INNER JOIN Producto
ON prod_codigo = item_producto) AS tabla3

WHERE tabla3.anio = 2012 
GROUP BY tabla3.prod_familia HAVING SUM(tabla3.item_total) > 20000)

ORDER BY cant_prod_vendidos DESC
