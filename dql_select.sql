-- Consultas 

use sakila;
select id_actor from actor;
select * from pelicula;
select id_empleado from empleado;
select id_alquiler  from alquiler;
select id_cliente from cliente;
select id_inventario from inventario;
select id_almacen from almacen;
select * from categoria c ;

-- Realiza las siguientes consultas en SQL relacionadas con el sistema de alquiler de películas:

-- 1.Encuentra el cliente que ha realizado la mayor cantidad de alquileres en los últimos 6 meses.

SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(a.id_alquiler) AS total_alquileres
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_alquileres DESC
LIMIT 1;


-- 2.Lista las cinco películas más alquiladas durante el último año.
SELECT p.id_pelicula, p.titulo, COUNT(a.id_alquiler) AS total_alquileres
FROM pelicula p
JOIN inventario i ON p.id_pelicula = i.id_pelicula
JOIN alquiler a ON i.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.id_pelicula, p.titulo
ORDER BY total_alquileres DESC
LIMIT 5;



-- 3.Obtén el total de ingresos y la cantidad de alquileres realizados por cada categoría de película.
SELECT c.nombre AS categoria, COUNT(a.id_alquiler) AS total_alquileres, SUM(p.total) AS ingresos_totales
FROM categoria c
JOIN pelicula_categoria pc ON c.id_categoria = pc.id_categoria
JOIN pelicula p ON pc.id_pelicula = p.id_pelicula
JOIN inventario i ON p.id_pelicula = i.id_pelicula
JOIN alquiler a ON i.id_inventario = a.id_inventario
JOIN pago p ON a.id_alquiler = p.id_alquiler
GROUP BY c.nombre;

-- 4.Calcula el número total de clientes que han realizado alquileres por cada idioma disponible en un mes específico.
SELECT i.nombre AS idioma, COUNT(DISTINCT a.id_cliente) AS total_clientes
FROM alquiler a
JOIN inventario inv ON a.id_inventario = inv.id_inventario
JOIN pelicula p ON inv.id_pelicula = p.id_pelicula
JOIN idioma i ON p.id_idioma = i.id_idioma
WHERE MONTH(a.fecha_alquiler) = 3 AND YEAR(a.fecha_alquiler) = YEAR(CURDATE()) -- el 3 es mes a analizar
GROUP BY i.nombre;


-- 5.Encuentra a los clientes que han alquilado todas las películas de una misma categoría.
SELECT id_cliente
FROM alquiler a
JOIN inventario i ON a.id_inventario = i.id_inventario
JOIN pelicula p ON i.id_pelicula = p.id_pelicula
JOIN pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
GROUP BY id_cliente, pc.id_categoria
HAVING COUNT(DISTINCT pc.id_pelicula) = (
    SELECT COUNT(*) FROM pelicula_categoria WHERE id_categoria = pc.id_categoria
);


-- 6.Lista las tres ciudades con más clientes activos en el último trimestre.
SELECT ci.nombre AS ciudad, COUNT(DISTINCT c.id_cliente) AS total_clientes
FROM cliente c
JOIN direccion d ON c.id_direccion = d.id_direccion
JOIN ciudad ci ON d.id_ciudad = ci.id_ciudad
WHERE c.activo = 1
AND c.fecha_creacion >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY ci.nombre
ORDER BY total_clientes DESC
LIMIT 3;


-- 7.Muestra las cinco categorías con menos alquileres registrados en el último año.
SELECT c.nombre AS categoria, COUNT(a.id_alquiler) AS total_alquileres
FROM categoria c
JOIN pelicula_categoria pc ON c.id_categoria = pc.id_categoria
JOIN pelicula p ON pc.id_pelicula = p.id_pelicula
JOIN inventario i ON p.id_pelicula = i.id_pelicula
JOIN alquiler a ON i.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY c.nombre
ORDER BY total_alquileres ASC
LIMIT 5;


-- 8.Calcula el promedio de días que un cliente tarda en devolver las películas alquiladas.
SELECT AVG(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS promedio_dias_retorno
FROM alquiler a
WHERE a.fecha_devolucion IS NOT NULL;
 

-- 9.Encuentra los cinco empleados que gestionaron más alquileres en la categoría de Acción.
SELECT e.id_empleado, e.nombre, e.apellidos, COUNT(a.id_alquiler) AS total_alquileres
FROM empleado e
JOIN alquiler a ON e.id_empleado = a.id_empleado
JOIN inventario i ON a.id_inventario = i.id_inventario
JOIN pelicula p ON i.id_pelicula = p.id_pelicula
JOIN pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
JOIN categoria c ON pc.id_categoria = c.id_categoria
WHERE c.nombre = 'Acción'
GROUP BY e.id_empleado, e.nombre, e.apellidos
ORDER BY total_alquileres DESC
LIMIT 5;


-- 10.Genera un informe de los clientes con alquileres más recurrentes.
SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(a.id_alquiler) AS total_alquileres
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_alquileres DESC
LIMIT 10;



-- 11.Calcula el costo promedio de alquiler por idioma de las películas.
SELECT i.nombre AS idioma, AVG(p.replacement_cost) AS costo_promedio
FROM pelicula p
JOIN idioma i ON p.id_idioma = i.id_idioma
GROUP BY i.nombre;


-- 12.Lista las cinco películas con mayor duración alquiladas en el último año.
SELECT p.titulo, p.duracion
FROM pelicula p
JOIN inventario i ON p.id_pelicula = i.id_pelicula
JOIN alquiler a ON i.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY p.duracion DESC
LIMIT 5;


-- 13.Muestra los clientes que más alquilaron películas de Comedia.
SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(a.id_alquiler) AS total_alquileres
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
JOIN inventario i ON a.id_inventario = i.id_inventario
JOIN pelicula p ON i.id_pelicula = p.id_pelicula
JOIN pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
JOIN categoria cat ON pc.id_categoria = cat.id_categoria
WHERE cat.nombre = 'Comedia'
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_alquileres DESC;


-- 14.Encuentra la cantidad total de días alquilados por cada cliente en el último mes.
SELECT c.id_cliente, c.nombre, c.apellidos, SUM(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS dias_totales
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND a.fecha_devolucion IS NOT NULL
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY dias_totales DESC;


-- 15.Muestra el número de alquileres diarios en cada almacén durante el último trimestre.
SELECT al.id_almacen, al.fecha_alquiler, COUNT(*) AS total_alquileres
FROM alquiler al
JOIN inventario i ON al.id_inventario = i.id_inventario
WHERE al.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY al.id_almacen, al.fecha_alquiler
ORDER BY al.fecha_alquiler DESC;
 

-- 16.Calcula los ingresos totales generados por cada almacén en el último semestre.
SELECT al.id_almacen, SUM(p.total) AS ingresos_totales
FROM pago p
JOIN alquiler a ON p.id_alquiler = a.id_alquiler
JOIN inventario i ON a.id_inventario = i.id_inventario
JOIN almacen al ON i.id_almacen = al.id_almacen
WHERE p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY al.id_almacen
ORDER BY ingresos_totales DESC;


-- 17.Encuentra el cliente que ha realizado el alquiler más caro en el último año.
SELECT c.id_cliente, c.nombre, c.apellidos, MAX(p.total) AS alquiler_mas_caro
FROM cliente c
JOIN pago p ON c.id_cliente = p.id_cliente
JOIN alquiler a ON p.id_alquiler = a.id_alquiler
WHERE p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY alquiler_mas_caro DESC
LIMIT 1;
 

-- 18.Lista las cinco categorías con más ingresos generados durante los últimos tres meses.
SELECT c.nombre AS categoria, SUM(p.total) AS ingresos_totales
FROM categoria c
JOIN pelicula_categoria pc ON c.id_categoria = pc.id_categoria
JOIN pelicula p ON pc.id_pelicula = p.id_pelicula
JOIN inventario i ON p.id_pelicula = i.id_pelicula
JOIN alquiler a ON i.id_inventario = a.id_inventario
JOIN pago p ON a.id_alquiler = p.id_alquiler
WHERE p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY c.nombre
ORDER BY ingresos_totales DESC
LIMIT 5;
 

-- 19.Obtén la cantidad de películas alquiladas por cada idioma en el último mes.
SELECT i.nombre AS idioma, COUNT(a.id_alquiler) AS total_alquileres
FROM idioma i
JOIN pelicula p ON i.id_idioma = p.id_idioma
JOIN inventario inv ON p.id_pelicula = inv.id_pelicula
JOIN alquiler a ON inv.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY i.nombre
ORDER BY total_alquileres DESC;


-- 20.Lista los clientes que no han realizado ningún alquiler en el último año.
SELECT c.id_cliente, c.nombre, c.apellidos
FROM cliente c
LEFT JOIN alquiler a ON c.id_cliente = a.id_cliente 
AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
WHERE a.id_alquiler IS NULL;
