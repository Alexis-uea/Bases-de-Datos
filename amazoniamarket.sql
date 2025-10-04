-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 04-10-2025 a las 04:28:02
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `amazoniamarket`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto` (IN `p_codigo_producto` VARCHAR(20), IN `p_nuevo_precio` DECIMAL(10,2))   BEGIN
    DECLARE v_precio_anterior DECIMAL(10,2);
    DECLARE v_datos_anteriores TEXT;
    DECLARE v_datos_nuevos TEXT;

    -- Obtener el precio actual
    SELECT precio_unitario INTO v_precio_anterior
    FROM producto
    WHERE codigo_producto = p_codigo_producto;

    -- Actualizar el precio
    UPDATE producto
    SET precio_unitario = p_nuevo_precio
    WHERE codigo_producto = p_codigo_producto;

    -- Construir datos para el log (sin JSON)
    SET v_datos_anteriores = CONCAT('Precio anterior: ', v_precio_anterior);
    SET v_datos_nuevos = CONCAT('Precio nuevo: ', p_nuevo_precio);

    -- Registrar en log_cambios
    INSERT INTO log_cambios (
        tabla_afectada,
        operacion,
        clave_primaria,
        datos_anteriores,
        datos_nuevos,
        fecha_evento,
        usuario
    )
    VALUES (
        'producto',
        'UPDATE',
        p_codigo_producto,
        v_datos_anteriores,
        v_datos_nuevos,
        NOW(),
        CURRENT_USER()
    );
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `cedula` varchar(15) NOT NULL COMMENT 'Cédula de identidad del cliente, columna que no puede ser nula, con un máximo de 15 caracteres',
  `nombre_completo` varchar(100) NOT NULL COMMENT 'Nombre completo del cliente, columna obligatoria, con un máximo de 100 caracteres.',
  `correo_electronico` varchar(100) NOT NULL COMMENT 'Correo electrónico del cliente, columna obligatoria y tiene un máximo de 100 caracteres.',
  `celular` varchar(15) NOT NULL COMMENT 'Número de celular del cliente, no puede ser nulo, con un máximo de 15 caracteres.',
  `direccion` varchar(200) NOT NULL COMMENT 'Direccion del cliente  no puede ser nulo, con un máximo de 200 caracteres.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`cedula`, `nombre_completo`, `correo_electronico`, `celular`, `direccion`) VALUES
('1717171717', 'Juan López', 'juan.lopez@mail.com', '0999999999', 'Calle A'),
('1818181818', 'María Fernández', 'maria.fernandez@mail.com', '0988888888', 'Calle B');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleventa`
--

CREATE TABLE `detalleventa` (
  `id_detalle` varchar(20) NOT NULL COMMENT 'ID único del detalle de venta. Es la clave primaria de la tabla.',
  `id_venta` int(11) NOT NULL COMMENT 'ID de la venta a la que pertenece este detalle. Es una clave foránea que referencia a la tabla venta.',
  `codigo_producto` varchar(20) NOT NULL COMMENT 'Código del producto vendido. Es una clave foránea que referencia a la tabla producto.',
  `cantidad` int(11) NOT NULL COMMENT 'Cantidad de unidades del producto vendidas.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalleventa`
--

INSERT INTO `detalleventa` (`id_detalle`, `id_venta`, `codigo_producto`, `cantidad`) VALUES
('D001', 1001, 'P001', 5),
('D002', 1001, 'P006', 1),
('D003', 1002, 'P002', 1),
('D004', 1003, 'P007', 1),
('D005', 1003, 'P010', 2),
('D006', 1004, 'P005', 2),
('D007', 1005, 'P003', 1),
('D008', 1006, 'P004', 2),
('D009', 1007, 'P008', 1);

--
-- Disparadores `detalleventa`
--
DELIMITER $$
CREATE TRIGGER `trg_descuento_stock` AFTER INSERT ON `detalleventa` FOR EACH ROW BEGIN
    UPDATE producto
    SET stock_disponible = stock_disponible - NEW.cantidad
    WHERE codigo_producto = NEW.codigo_producto;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

CREATE TABLE `empleado` (
  `id_cajero` int(11) NOT NULL COMMENT 'ID único para el cajero. Clave primaria de la tabla auto incrementado.',
  `nombre` varchar(100) NOT NULL COMMENT 'Nombre completo del cajero, es un campo obligatorio.',
  `correo` varchar(100) NOT NULL COMMENT 'Correo electrónico del cajero, es un campo obligatorio.',
  `direccion` varchar(200) NOT NULL COMMENT 'Dirección del cajero, es un campo obligatorio utilizado para la ubicación.',
  `celular` varchar(45) NOT NULL COMMENT '''Numero de telefono celular del cajero, es un campo obligatorio.',
  `cedula` varchar(45) NOT NULL COMMENT 'Cedula del cajero, es un campo obligatorio.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleado`
--

INSERT INTO `empleado` (`id_cajero`, `nombre`, `correo`, `direccion`, `celular`, `cedula`) VALUES
(101, 'Ana Martínez', 'ana.martinez@amazoniamarket.com', 'Av. Principal 123', '0987654321', '0102030405'),
(102, 'Carlos Pérez', 'carlos.perez@amazoniamarket.com', 'Calle Secundaria 456', '0987654322', '0203040506'),
(103, 'Lucía Gómez', 'lucia.gomez@amazoniamarket.com', 'Av. Central 789', '0987654323', '0304050607');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago`
--

CREATE TABLE `pago` (
  `id_pago` int(11) NOT NULL COMMENT 'ID único para cada pago. Clave primaria de la tabla.',
  `id_venta` int(11) NOT NULL COMMENT 'ID de la venta relacionada con este pago. Relacionado con la tabla ventas.',
  `monto` decimal(10,2) NOT NULL COMMENT 'Monto del pago realizado. Utiliza un tipo decimal para almacenar montos con precisión.',
  `medio_pago` enum('Efectivo','Tarjeta de Crédito','Transferencia','Otros') NOT NULL COMMENT 'Medio de pago utilizado (Efectivo, Tarjeta de Crédito, Transferencia, etc.).',
  `fecha_pago` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha en la que se realizó el pago.',
  `banco` varchar(100) DEFAULT NULL COMMENT 'Banco relacionado con el pago (si el medio de pago es transferencia o tarjeta).',
  `numero_documento` varchar(50) DEFAULT NULL COMMENT 'Número de documento asociado al pago (por ejemplo, número de recibo o número de autorización de tarjeta).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pago`
--

INSERT INTO `pago` (`id_pago`, `id_venta`, `monto`, `medio_pago`, `fecha_pago`, `banco`, `numero_documento`) VALUES
(1, 1001, 12.50, 'Efectivo', '2025-08-16 09:31:00', NULL, NULL),
(2, 1002, 35.00, 'Tarjeta de Crédito', '2025-08-16 11:01:00', 'Banco Pichincha', 'AUTH123456'),
(3, 1003, 30.00, 'Transferencia', '2025-08-16 15:46:00', 'Banco Guayaquil', 'TRX789001'),
(4, 1003, 20.00, 'Efectivo', '2025-08-16 15:46:30', NULL, NULL),
(5, 1004, 25.00, 'Efectivo', '2025-08-16 17:21:00', NULL, NULL),
(6, 1005, 3.00, 'Otros', '2025-08-05 10:01:00', NULL, 'RECIBO987'),
(7, 1006, 5.00, 'Transferencia', '2025-08-10 14:31:00', 'Produbanco', 'TRX445566'),
(8, 1007, 2.00, 'Efectivo', '2025-08-18 16:01:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codigo_producto` varchar(20) NOT NULL COMMENT 'Código único del producto. Clave primaria de la tabla.',
  `nombre` varchar(100) NOT NULL COMMENT 'Nombre del producto. Es un campo obligatorio.',
  `categoria` varchar(50) NOT NULL COMMENT 'Categoría del producto. Campo obligatorio que clasifica el tipo de producto.',
  `marca` varchar(50) DEFAULT NULL COMMENT 'Marca del producto. Puede ser nula si no se proporciona.',
  `precio_unitario` decimal(10,2) NOT NULL COMMENT 'Precio unitario del producto. Se utiliza tipo decimal para representar el precio con precisión.',
  `unidad_medida` varchar(20) DEFAULT NULL COMMENT 'Unidad de medida del producto. Puede ser nula si no se especifica.',
  `stock_disponible` int(11) DEFAULT 0 COMMENT 'Stock disponible del producto. Si no se especifica, el valor predeterminado es 0.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codigo_producto`, `nombre`, `categoria`, `marca`, `precio_unitario`, `unidad_medida`, `stock_disponible`) VALUES
('P001', 'Manzana Fuji', 'Alimentos', 'FreshFruit', 0.50, 'kg', 100),
('P002', 'Licuadora X100', 'Electrodomésticos', 'HomeTech', 35.00, 'unidad', 20),
('P003', 'Leche Entera 1L', 'Alimentos', 'LacteosPlus', 1.50, 'unidad', 50),
('P004', 'Arroz Integral 1kg', 'Alimentos', 'GrainCo', 2.00, 'unidad', 30),
('P005', 'Café Molido', 'Alimentos', 'CafeExpress', 4.50, 'unidad', 15),
('P006', 'Jabón en barra', 'Higiene', 'CleanHome', 0.80, 'unidad', 40),
('P007', 'Televisor 42\"', 'Electrodomésticos', 'VisionPlus', 300.00, 'unidad', 5),
('P008', 'Papel Higiénico', 'Higiene', 'SoftTouch', 0.90, 'unidad', 100),
('P009', 'Cereal Integral', 'Alimentos', 'HealthyLife', 3.20, 'unidad', 10),
('P010', 'Detergente Líquido', 'Higiene', 'CleanHome', 2.50, 'unidad', 20);

--
-- Disparadores `producto`
--
DELIMITER $$
CREATE TRIGGER `log_producto_delete` AFTER DELETE ON `producto` FOR EACH ROW BEGIN
  INSERT INTO log_cambios (
    tabla_afectada, operacion, clave_primaria, datos_anteriores
  )
  VALUES (
    'producto', 'DELETE', OLD.codigo_producto,
    CONCAT('{"nombre":"', OLD.nombre,
           '", "categoria":"', OLD.categoria,
           '", "marca":"', OLD.marca,
           '", "precio_unitario":', OLD.precio_unitario,
           ', "stock_disponible":', OLD.stock_disponible, '}')
  );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `log_producto_insert` AFTER INSERT ON `producto` FOR EACH ROW BEGIN
  INSERT INTO log_cambios (
    tabla_afectada, operacion, clave_primaria, datos_nuevos
  )
  VALUES (
    'producto', 'INSERT', NEW.codigo_producto,
    CONCAT('{"nombre":"', NEW.nombre,
           '", "categoria":"', NEW.categoria,
           '", "marca":"', NEW.marca,
           '", "precio_unitario":', NEW.precio_unitario,
           ', "stock_disponible":', NEW.stock_disponible, '}')
  );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `log_producto_update` AFTER UPDATE ON `producto` FOR EACH ROW BEGIN
  INSERT INTO log_cambios (
    tabla_afectada, operacion, clave_primaria, datos_anteriores, datos_nuevos
  )
  VALUES (
    'producto', 'UPDATE', NEW.codigo_producto,
    CONCAT('{"nombre":"', OLD.nombre,
           '", "categoria":"', OLD.categoria,
           '", "marca":"', OLD.marca,
           '", "precio_unitario":', OLD.precio_unitario,
           ', "stock_disponible":', OLD.stock_disponible, '}'),
    CONCAT('{"nombre":"', NEW.nombre,
           '", "categoria":"', NEW.categoria,
           '", "marca":"', NEW.marca,
           '", "precio_unitario":', NEW.precio_unitario,
           ', "stock_disponible":', NEW.stock_disponible, '}')
  );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id_venta` int(11) NOT NULL COMMENT 'ID único de la venta. Clave primaria de la tabla.',
  `fecha_hora` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de la venta. Se establece como CURRENT_TIMESTAMP por defecto.',
  `total` decimal(10,2) NOT NULL COMMENT 'Total de la venta (incluye productos, impuestos, descuentos, etc.).',
  `subtotal` decimal(10,2) NOT NULL COMMENT 'Subtotal de la venta antes de aplicar impuestos.',
  `iva` varchar(20) NOT NULL COMMENT 'Monto o porcentaje del IVA aplicado a la venta.',
  `cedula_cliente` varchar(15) NOT NULL COMMENT 'Cédula del cliente. Relacionado con la tabla cliente.',
  `id_cajero` int(11) NOT NULL COMMENT 'ID del cajero que realizó la venta. Relacionado con la tabla empleado.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`id_venta`, `fecha_hora`, `total`, `subtotal`, `iva`, `cedula_cliente`, `id_cajero`) VALUES
(1001, '2025-08-16 09:30:00', 12.50, 11.20, '1.30', '1717171717', 101),
(1002, '2025-08-16 11:00:00', 35.00, 31.50, '3.50', '1818181818', 101),
(1003, '2025-08-16 15:45:00', 50.00, 45.00, '5.00', '1717171717', 102),
(1004, '2025-08-16 17:20:00', 25.00, 22.50, '2.50', '1818181818', 103),
(1005, '2025-08-05 10:00:00', 3.00, 2.75, '0.25', '1717171717', 102),
(1006, '2025-08-10 14:30:00', 5.00, 4.50, '0.50', '1818181818', 103),
(1007, '2025-09-13 16:00:00', 2.00, 1.80, '0.20', '1717171717', 101);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cedula`);

--
-- Indices de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_venta` (`id_venta`),
  ADD KEY `codigo_producto` (`codigo_producto`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`id_cajero`);

--
-- Indices de la tabla `pago`
--
ALTER TABLE `pago`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codigo_producto`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_cajero` (`id_cajero`),
  ADD KEY `idx_cliente_fecha` (`cedula_cliente`,`fecha_hora`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `empleado`
--
ALTER TABLE `empleado`
  MODIFY `id_cajero` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID único para el cajero. Clave primaria de la tabla auto incrementado.', AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT de la tabla `pago`
--
ALTER TABLE `pago`
  MODIFY `id_pago` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID único para cada pago. Clave primaria de la tabla.', AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID único de la venta. Clave primaria de la tabla.', AUTO_INCREMENT=1008;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD CONSTRAINT `codigo_producto` FOREIGN KEY (`codigo_producto`) REFERENCES `producto` (`codigo_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pago`
--
ALTER TABLE `pago`
  ADD CONSTRAINT `pago_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `cedula_cliente` FOREIGN KEY (`cedula_cliente`) REFERENCES `cliente` (`cedula`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_cajero` FOREIGN KEY (`id_cajero`) REFERENCES `empleado` (`id_cajero`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
