-- Triggers

use sakila;

-- Implementa los siguientes triggers:

-- 1.ActualizarTotalAlquileresEmpleado: Al registrar un alquiler, actualiza el total de alquileres gestionados por el empleado correspondiente.

CREATE TABLE IF NOT EXISTS total_alquileres_empleado (
    id_empleado TINYINT UNSIGNED PRIMARY KEY,
    total_alquileres INT DEFAULT 0
);

DELIMITER //
CREATE TRIGGER ActualizarTotalAlquileresEmpleado
AFTER INSERT ON alquiler
FOR EACH ROW
BEGIN
    INSERT INTO total_alquileres_empleado (id_empleado, total_alquileres)
    VALUES (NEW.id_empleado, 1)
    ON DUPLICATE KEY UPDATE total_alquileres = total_alquileres + 1;
END //

DELIMITER ;

-- 2.AuditarActualizacionCliente: Cada vez que se modifica un cliente, registra el cambio en una tabla de auditoría.

CREATE TABLE IF NOT EXISTS auditoria_cliente (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente SMALLINT UNSIGNED,
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER AuditarActualizacionCliente
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    IF OLD.nombre <> NEW.nombre THEN
        INSERT INTO auditoria_cliente (id_cliente, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (OLD.id_cliente, 'nombre', OLD.nombre, NEW.nombre);
    END IF;
    IF OLD.apellidos <> NEW.apellidos THEN
        INSERT INTO auditoria_cliente (id_cliente, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (OLD.id_cliente, 'apellidos', OLD.apellidos, NEW.apellidos);
    END IF;
    IF OLD.email <> NEW.email THEN
        INSERT INTO auditoria_cliente (id_cliente, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (OLD.id_cliente, 'email', OLD.email, NEW.email);
    END IF;
END //

DELIMITER ;

-- 3.RegistrarHistorialDeCosto: Guarda el historial de cambios en los costos de alquiler de las películas.

CREATE TABLE IF NOT EXISTS historial_costos (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pelicula SMALLINT UNSIGNED,
    costo_anterior DECIMAL(5,2),
    costo_nuevo DECIMAL(5,2),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER RegistrarHistorialDeCosto
BEFORE UPDATE ON pelicula
FOR EACH ROW
BEGIN
    IF OLD.rental_rate <> NEW.rental_rate THEN
        INSERT INTO historial_costos (id_pelicula, costo_anterior, costo_nuevo)
        VALUES (OLD.id_pelicula, OLD.rental_rate, NEW.rental_rate);
    END IF;
END //

DELIMITER ;

-- 4.NotificarEliminacionAlquiler: Registra una notificación cuando se elimina un registro de alquiler.

CREATE TABLE IF NOT EXISTS notificacion_eliminacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_alquiler INT,
    mensaje VARCHAR(255),
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER NotificarEliminacionAlquiler
BEFORE DELETE ON alquiler
FOR EACH ROW
BEGIN
    INSERT INTO notificacion_eliminacion (id_alquiler, mensaje)
    VALUES (OLD.id_alquiler, CONCAT('El alquiler ', OLD.id_alquiler, ' ha sido eliminado.'));
END //

DELIMITER ;

-- 5.RestringirAlquilerConSaldoPendiente: Evita que un cliente con saldo pendiente pueda realizar nuevos alquileres.

CREATE TRIGGER RestringirAlquilerConSaldoPendiente
BEFORE INSERT ON alquiler
FOR EACH ROW
BEGIN
    DECLARE saldo DECIMAL(10,2);
    SELECT COALESCE(SUM(total), 0) INTO saldo
    FROM pago
    WHERE id_cliente = NEW.id_cliente AND fecha_pago IS NULL;

    IF saldo > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede realizar el alquiler porque el cliente tiene saldo pendiente.';
    END IF;
END //

DELIMITER ;

