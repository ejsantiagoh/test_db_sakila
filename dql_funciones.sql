-- Funciones

use sakila;

-- Desarrolla las siguientes funciones:

-- 1. TotalIngresosCliente(ClienteID, Año): Calcula los ingresos generados por un cliente en un año específico.
-- Esta función calcula el total de ingresos generados por un cliente en un año específico, 
-- sumando los montos de los pagos realizados por dicho cliente en el periodo indicado.

DELIMITER //

CREATE FUNCTION totalIngresosCliente(clienteID INT, anio INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT COALESCE(SUM(p.total), 0) INTO total
    FROM pago p
    WHERE p.id_cliente = clienteID
    AND YEAR(p.fecha_pago) = anio;

    RETURN total;
END //

DELIMITER ;

SELECT totalIngresosCliente(5, 2024);


-- 2.PromedioDuracionAlquiler(PeliculaID): Retorna la duración promedio de alquiler de una película específica.
-- Esta función devuelve la duración promedio en días de los alquileres de una película específica. 
-- Se calcula como la diferencia entre la fecha de devolución y la fecha de alquiler.

DELIMITER //

CREATE FUNCTION promedioDuracionAlquiler(peliculaID INT) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);

    SELECT COALESCE(AVG(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)), 0) INTO promedio
    FROM alquiler a
    JOIN inventario i ON a.id_inventario = i.id_inventario
    WHERE i.id_pelicula = peliculaID;

    RETURN promedio;
END //

DELIMITER ;

SELECT promedioDuracionAlquiler(10);

-- 3.IngresosPorCategoria(CategoriaID): Calcula los ingresos totales generados por una categoría específica de películas.
-- Esta función calcula el total de ingresos generados por todas las películas de una categoría específica.

DELIMITER //

CREATE FUNCTION ingresosPorCategoria(categoriaID INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT COALESCE(SUM(p.total), 0) INTO total
    FROM pago p
    JOIN alquiler a ON p.id_alquiler = a.id_alquiler
    JOIN inventario i ON a.id_inventario = i.id_inventario
    JOIN pelicula_categoria pc ON i.id_pelicula = pc.id_pelicula
    WHERE pc.id_categoria = categoriaID;

    RETURN total;
END //

DELIMITER ;

SELECT ingresosPorCategoria(3);


-- 4.DescuentoFrecuenciaCliente(ClienteID): Calcula un descuento basado en la frecuencia de alquiler del cliente.
-- Esta función calcula un porcentaje de descuento 
-- basado en la cantidad de alquileres que un cliente ha realizado en el último año. 

DELIMITER //

CREATE FUNCTION descuentoFrecuenciaCliente(clienteID INT) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE cantidad_alquileres INT;
    DECLARE descuento DECIMAL(5,2);

    -- Contar la cantidad de alquileres del cliente en el último año
    SELECT COUNT(*) INTO cantidad_alquileres
    FROM alquiler
    WHERE id_cliente = clienteID
    AND fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

    -- Aplicar descuentos según la cantidad de alquileres
    IF cantidad_alquileres >= 50 THEN
        SET descuento = 0.20; -- 20% de descuento
    ELSEIF cantidad_alquileres >= 30 THEN
        SET descuento = 0.15; -- 15%
    ELSEIF cantidad_alquileres >= 10 THEN
        SET descuento = 0.10; -- 10%
    ELSE
        SET descuento = 0.00; -- Sin descuento
    END IF;

    RETURN descuento;
END //

DELIMITER ;

SELECT descuentoFrecuenciaCliente(8);


-- 5.EsClienteVIP(ClienteID): Verifica si un cliente es "VIP" basándose en la cantidad de alquileres realizados y 
-- los ingresos generados.
-- Esta función determina si un cliente es considerado "VIP" en función de sus alquileres y 
-- los ingresos generados en el último año.
DELIMITER //

CREATE FUNCTION esClienteVIP(clienteID INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total_ingresos DECIMAL(10,2);
    DECLARE total_alquileres INT;
    DECLARE es_vip BOOLEAN;

    -- Calcular ingresos y cantidad de alquileres en el último año
    SELECT SUM(p.total), COUNT(a.id_alquiler) INTO total_ingresos, total_alquileres
    FROM pago p
    JOIN alquiler a ON p.id_alquiler = a.id_alquiler
    WHERE a.id_cliente = clienteID
    AND p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

    -- Definir si el cliente es VIP
    IF total_ingresos >= 500 OR total_alquileres >= 40 THEN
        SET es_vip = TRUE;
    ELSE
        SET es_vip = FALSE;
    END IF;

    RETURN es_vip;
END //

DELIMITER ;

SELECT esClienteVIP(12);



