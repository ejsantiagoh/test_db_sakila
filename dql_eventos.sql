-- Eventos

use sakila;

-- Crea los siguientes eventos:

-- 1.InformeAlquileresMensual: Genera un informe mensual de alquileres y lo almacena automáticamente.
-- Este evento genera un informe mensual con el número total de alquileres y el ingreso total del mes. 
-- Se almacena en una tabla informe_alquileres.
-- Tabla para almacenar informes mensuales de alquileres
CREATE TABLE IF NOT EXISTS informe_alquileres (
    id_informe INT AUTO_INCREMENT PRIMARY KEY,
    mes VARCHAR(7), -- Formato: 'YYYY-MM'
    total_alquileres INT,
    ingresos_totales DECIMAL(10,2),
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE EVENT InformeAlquileresMensual
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY
DO
BEGIN
    INSERT INTO informe_alquileres (mes, total_alquileres, ingresos_totales)
    SELECT 
        DATE_FORMAT(fecha_alquiler, '%Y-%m') AS mes,
        COUNT(*) AS total_alquileres,
        SUM(p.total) AS ingresos_totales
    FROM alquiler a
    JOIN pago p ON a.id_alquiler = p.id_alquiler
    WHERE fecha_alquiler >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01')
        AND fecha_alquiler < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
    GROUP BY mes;
END;


-- 2.ActualizarSaldoPendienteCliente: Actualiza los saldos pendientes de los clientes al final de cada mes.
-- Este evento actualiza los saldos pendientes de los clientes al final de cada mes, sumando el total de pagos adeudados.

CREATE EVENT ActualizarSaldoPendienteCliente
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY
DO
BEGIN
    UPDATE cliente c
    SET saldo_pendiente = (
        SELECT COALESCE(SUM(total), 0)
        FROM pago p
        WHERE p.id_cliente = c.id_cliente
        AND p.fecha_pago IS NULL
    );
END;


-- 3.AlertaPeliculasNoAlquiladas: Envía una alerta cuando una película no ha sido alquilada en el último año.
-- Este evento revisa cada mes qué películas no han sido alquiladas en el último año y 
-- genera una alerta en una tabla alertas_peliculas.
CREATE TABLE IF NOT EXISTS alerta_peliculas (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_pelicula SMALLINT UNSIGNED,
    titulo VARCHAR(245),
    mensaje VARCHAR(255),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE EVENT AlertaPeliculasNoAlquiladas
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY
DO
BEGIN
    INSERT INTO alertas_peliculas (id_pelicula, mensaje, fecha_alerta)
    SELECT p.id_pelicula, 
           CONCAT('La película ', p.titulo, ' no ha sido alquilada en el último año.') AS mensaje,
           CURRENT_TIMESTAMP
    FROM pelicula p
    LEFT JOIN alquiler a ON p.id_pelicula = a.id_inventario
        AND a.fecha_alquiler >= CURRENT_DATE - INTERVAL 1 YEAR
    WHERE a.id_alquiler IS NULL;
END;
-- Busca películas que no han sido alquiladas en el último año y genera una alerta.

-- 4.LimpiarAuditoriaCada6Meses: Borra los registros antiguos de auditoría cada seis meses.
-- Este evento elimina registros antiguos en la tabla auditoria, manteniendo solo los últimos 6 meses.

CREATE EVENT LimpiarAuditoriaCada6Meses
ON SCHEDULE EVERY 6 MONTH
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY
DO
BEGIN
    DELETE FROM auditoria
    WHERE fecha_registro < CURRENT_DATE - INTERVAL 6 MONTH;
END;


-- 5.ActualizarCategoriasPopulares: Actualiza la lista de categorías más alquiladas al final de cada mes.
-- Este evento actualiza la tabla categorias_populares con las categorías más alquiladas al final de cada mes.

-- Tabla para registrar categorías populares por mes
CREATE TABLE IF NOT EXISTS categorias_populares (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria TINYINT UNSIGNED,
    nombre_categoria VARCHAR(25),
    total_alquileres INT,
    mes VARCHAR(7), -- Formato: 'YYYY-MM'
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Borra y actualiza la tabla categorias_populares con las 10 categorías más alquiladas en el último mes
CREATE EVENT ActualizarCategoriasPopulares
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY
DO
BEGIN
    TRUNCATE TABLE categorias_populares;
    
    INSERT INTO categorias_populares (id_categoria, nombre, total_alquileres)
    SELECT c.id_categoria, c.nombre, COUNT(*) AS total_alquileres
    FROM pelicula_categoria pc
    JOIN pelicula p ON pc.id_pelicula = p.id_pelicula
    JOIN alquiler a ON p.id_pelicula = a.id_inventario
    JOIN categoria c ON pc.id_categoria = c.id_categoria
    WHERE a.fecha_alquiler >= CURRENT_DATE - INTERVAL 1 MONTH
    GROUP BY c.id_categoria, c.nombre
    ORDER BY total_alquileres DESC
    LIMIT 10;
END;

