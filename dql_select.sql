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

select id_cliente cl, nombre cl
FROM cliente cl
join alquiler a on a.id_alquiler = cl.id_cliente
having a.fecha_alquiler < 6 MONTH 
limit 1;

-- 2.Lista las cinco películas más alquiladas durante el último año.
SELECT p id_pelicula , p titulo 
from pelicula p
join alquiler a on p.id_pelicula = a.id_alquiler;
having a.fecha_alquiler < 1 year
limit 5;


-- 3.Obtén el total de ingresos y la cantidad de alquileres realizados por cada categoría de película.
select sum(total) as total_Ingresos 
FROM pago ;

-- 4.Calcula el número total de clientes que han realizado alquileres por cada idioma disponible en un mes específico.
SELECT  count(id_cliente) as totalClientes
FROM cliente
join alquiler on id_alquiler = id_cliente
join idioma on id_alquiler = id_idioma;

-- 5.Encuentra a los clientes que han alquilado todas las películas de una misma categoría.
select id_cliente
from

-- 6.Lista las tres ciudades con más clientes activos en el último trimestre.
select id_ciudad, nombre
from ciudad

-- 7.Muestra las cinco categorías con menos alquileres registrados en el último año.
SELECT nombre
FROM categoria c 
join alquiler a on a.id_alquiler = c.id_categoria;

-- 8.Calcula el promedio de días que un cliente tarda en devolver las películas alquiladas.
SELECT 
FROM 

-- 9.Encuentra los cinco empleados que gestionaron más alquileres en la categoría de Acción.
SELECT 
FROM 


-- 10.Genera un informe de los clientes con alquileres más recurrentes.
SELECT 
FROM 


-- 11.Calcula el costo promedio de alquiler por idioma de las películas.
SELECT 
FROM 

-- 12.Lista las cinco películas con mayor duración alquiladas en el último año.
SELECT 
FROM 

-- 13.Muestra los clientes que más alquilaron películas de Comedia.
SELECT 
FROM 

-- 14.Encuentra la cantidad total de días alquilados por cada cliente en el último mes.
SELECT
FROM 

-- 15.Muestra el número de alquileres diarios en cada almacén durante el último trimestre.
SELECT 
FROM 

-- 16.Calcula los ingresos totales generados por cada almacén en el último semestre.
SELECT 
FROM 

-- 17.Encuentra el cliente que ha realizado el alquiler más caro en el último año.
SELECT 
FROM 

-- 18.Lista las cinco categorías con más ingresos generados durante los últimos tres meses.
SELECT 
FROM 

-- 19.Obtén la cantidad de películas alquiladas por cada idioma en el último mes.
SELECT 
FROM 

-- 20.Lista los clientes que no han realizado ningún alquiler en el último año.
select
FROM 