CREATE DATABASE IF NOT EXISTS biblioteca;
USE biblioteca;

CREATE TABLE editorial (
    id_editorial INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50)
);

CREATE TABLE categoria (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE autor (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(75),
    nacionalidad VARCHAR(75)
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(75) NOT NULL,
    correo VARCHAR(100),
    fecha_registro DATETIME 
);

CREATE TABLE libro (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(155),
    id_autor INT,
    id_editorial INT,
    año_publicacion INT,
    FOREIGN KEY (id_autor) REFERENCES autor(id_autor),
    FOREIGN KEY (id_editorial) REFERENCES editorial(id_editorial)
);

CREATE TABLE libro_categoria (
    id_libro_categoria INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT,
    id_libro INT,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
);

CREATE TABLE prestamo (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    fecha_prestamo DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE detalle (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT,
    id_libro INT,
    fecha_devolucion DATETIME,
    FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
);

INSERT INTO autor (nombre, nacionalidad) VALUES 
('Gabriel García Márquez', 'Colombiana'), ('Isabel Allende', 'Chilena'),
('J.K. Rowling', 'Británica'), ('George R.R. Martin', 'Estadounidense');

INSERT INTO editorial (nombre, pais) VALUES 
('Editorial Sudamericana', 'Argentina'), ('Plaza & Janés', 'España'),
('Salamandra', 'España'), ('Penguin Random House', 'EE.UU.');

INSERT INTO categoria (id_categoria, nombre) VALUES 
(1, 'Realismo Mágico'), (2, 'Fantasía'), (3, 'Novela Histórica'), (4, 'Aventura');

INSERT INTO usuario (nombre, correo, fecha_registro) VALUES 
('Randy Lizarme', 'randy@gmail.com', '2026-04-20 10:00:00'),
('Steven Profe', 'Steven.@academia.com', '2026-04-21 11:30:00'),
('Luis Dev', 'luis.@gmail.com', NOW());

INSERT INTO libro (titulo, id_autor, id_editorial, año_publicacion) VALUES 
('Cien años de soledad', 1, 1, 1967), ('La casa de los espíritus', 2, 2, 1982),
('Harry Potter y la piedra filosofal', 3, 3, 1997), ('Juego de Tronos', 4, 4, 1996);

INSERT INTO libro_categoria (id_categoria, id_libro) VALUES 
(1, 1), (1, 2), (2, 3), (2, 4), (4, 3);

INSERT INTO prestamo (id_usuario, fecha_prestamo) VALUES (1, NOW()), (2, '2026-04-22 09:00:00');
INSERT INTO detalle (id_prestamo, id_libro, fecha_devolucion) VALUES (1, 1, NULL), (2, 3, '2026-04-23 14:00:00');

-- 1. Mostrar todos los libros
SELECT titulo AS Libros FROM libro;

-- 2. Mostrar títulos y años de publicación
SELECT titulo AS "Nombre del titulo", año_publicacion AS "Año de publicacion" FROM libro;

-- 3. Usuarios registrado recientemente
SELECT nombre, correo, fecha_registro 
FROM usuario 
ORDER BY fecha_registro DESC 
LIMIT 5;

-- 4. Mostrar libros con su autor
SELECT libro.titulo AS "Nombre del titulo", autor.nombre AS "Nombre del autor"
FROM libro
JOIN autor ON libro.id_autor = autor.id_autor;

-- 5. Mostrar libros con su editorial
SELECT libro.titulo AS "Nombre del titulo", editorial.nombre AS Editorial
FROM libro
JOIN editorial ON libro.id_editorial = editorial.id_editorial;

-- 6. Mostrar categoria del libro
SELECT libro.titulo AS "Nombre del titulo", categoria.nombre AS "Genero"
FROM libro
JOIN libro_categoria ON libro.id_libro = libro_categoria.id_libro
JOIN categoria ON libro_categoria.id_categoria = categoria.id_categoria;

-- 7. Mostrar todos los préstamos con nombre de usuario y libro
SELECT 
    usuario.nombre AS "Lector", 
    libro.titulo AS "Obra Prestada", 
    prestamo.fecha_prestamo AS "Fecha"
FROM prestamo
JOIN usuario ON prestamo.id_usuario = usuario.id_usuario
JOIN detalle ON prestamo.id_prestamo = detalle.id_prestamo
JOIN libro ON detalle.id_libro = libro.id_libro;

-- 8. Mostrar libros no devueltos
SELECT 
    usuario.nombre AS "Usuario", 
    libro.titulo AS "Libro Pendiente", 
    prestamo.fecha_prestamo
FROM detalle
JOIN prestamo ON detalle.id_prestamo = prestamo.id_prestamo
JOIN usuario ON prestamo.id_usuario = usuario.id_usuario
JOIN libro ON detalle.id_libro = libro.id_libro
WHERE detalle.fecha_devolucion IS NULL;

-- 9. Mostrar historial completo de préstamos
SELECT 
    p.id_prestamo AS "Folio",
    u.nombre AS "Usuario", 
    l.titulo AS "Libro", 
    p.fecha_prestamo AS "Salida", 
    d.fecha_devolucion AS "Retorno"
FROM detalle d
JOIN prestamo p ON d.id_prestamo = p.id_prestamo
JOIN usuario u ON p.id_usuario = u.id_usuario
JOIN libro l ON d.id_libro = l.id_libro
ORDER BY p.fecha_prestamo DESC;

-- 10. Cantidad de libros por categoría
SELECT categoria.nombre AS Categoria, COUNT(libro_categoria.id_libro) AS Total_Libros
FROM categoria
LEFT JOIN libro_categoria ON categoria.id_categoria = libro_categoria.id_categoria
GROUP BY categoria.nombre;

-- 11. Cantidad de préstamos por usuario
SELECT usuario.nombre AS Lector, COUNT(prestamo.id_prestamo) AS Cantidad_Prestamos
FROM usuario
LEFT JOIN prestamo ON usuario.id_usuario = prestamo.id_usuario
GROUP BY usuario.nombre
ORDER BY Cantidad_Prestamos DESC;

-- 12. Cantidad de libros por editorial
SELECT editorial.nombre AS Editorial, COUNT(libro.id_libro) AS Stock_Libros
FROM editorial
LEFT JOIN libro ON editorial.id_editorial = libro.id_editorial
GROUP BY editorial.nombre;

-- 13. Usuario con más préstamos
SELECT u.nombre AS "Lector Estrella", COUNT(p.id_prestamo) AS total
FROM usuario u
JOIN prestamo p ON u.id_usuario = p.id_usuario
GROUP BY u.nombre
ORDER BY total DESC
LIMIT 1;

-- 14. Libro más prestado
SELECT l.titulo AS "Libro más popular", COUNT(d.id_libro) AS veces_prestado
FROM libro l
JOIN detalle d ON l.id_libro = d.id_libro
GROUP BY l.titulo
ORDER BY veces_prestado DESC
LIMIT 1;

-- 15. Categoría más popular
SELECT c.nombre AS "Género Favorito", COUNT(d.id_libro) AS total_solicitudes
FROM categoria c
JOIN libro_categoria lc ON c.id_categoria = lc.id_categoria
JOIN detalle d ON lc.id_libro = d.id_libro
GROUP BY c.nombre
ORDER BY total_solicitudes DESC
LIMIT 1;