-- CREACIÓN BASE DE DATOS
create database colegio character set utf8mb4 collate utf8mb4_bin;

-- SELECCIÓN DE BASE DE DATOS QUE SE VA A USAR
use colegio;

-- CREACIÓN DE TABLAS

-- Tabla para asignaturas
create table asignatura (
    id int(6) not null auto_increment,  -- Identificador único de la asignatura
    nombre varchar(25) not null,        -- Nombre de la asignatura
    primary key (id)                    -- Clave primaria
) engine=InnoDB default charset=latin1 auto_increment=1;

-- Tabla para alumnos
create table alumno (
    id int(6) not null auto_increment,  -- Identificador único del alumno
    nombre varchar(25) not null,        -- Nombre del alumno
    apellido varchar(25) not null,      -- Apellido del alumno
    fecha_nacimiento date not null,     -- Fecha de nacimiento del alumno
    primary key (id)                    -- Clave primaria
) engine=InnoDB default charset=latin1 auto_increment=1;

-- Tabla para notas
CREATE TABLE nota ( 
    id INT(6) NOT NULL auto_increment,   -- Identificador único de la nota
    asignatura_id INT,                   -- Identificador de la asignatura
    calificacion FLOAT NOT NULL,         -- Calificación obtenida
    fecha_examen DATE NOT NULL,          -- Fecha del examen
    convocatoria INT(6),                 -- Número de convocatoria
    alumno_id INT,                       -- Identificador del alumno
    INDEX alum_ind (alumno_id),          -- Índice para búsquedas rápidas por alumno
    FOREIGN KEY (alumno_id)              -- Clave foránea que referencia al alumno
        REFERENCES alumno(id)
        ON DELETE CASCADE,
    INDEX signat_ind (asignatura_id),    -- Índice para búsquedas rápidas por asignatura
    FOREIGN KEY (asignatura_id)          -- Clave foránea que referencia a la asignatura
        REFERENCES asignatura(id)
        ON DELETE CASCADE,       
    PRIMARY KEY (id)                     -- Clave primaria
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1; 

-- Tabla para labores extraescolares
CREATE TABLE labor_extra (
    puesto VARCHAR(50) NOT NULL,         -- Puesto desempeñado en la labor extraescolar
    alumno_id INT NOT NULL,              -- Identificador del alumno
    INDEX alum_ind (alumno_id),          -- Índice para búsquedas rápidas por alumno
    FOREIGN KEY (alumno_id)              -- Clave foránea que referencia al alumno
        REFERENCES alumno(id)
        ON DELETE CASCADE,
    PRIMARY KEY (puesto, alumno_id)      -- Clave primaria compuesta por puesto y alumno
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- RELLENAR DE DATOS LAS TABLAS | INSERTAR DATOS EN TABLAS

-- Insertar asignaturas
INSERT INTO asignatura(nombre) VALUES ('Matemáticas');
INSERT INTO asignatura(nombre) VALUES ('Lengua'); 

-- Insertar alumnos
INSERT INTO alumno(nombre, apellido, fecha_nacimiento) VALUES ('Juan', 'Quesada', '1980-09-03');
INSERT INTO alumno(nombre, apellido, fecha_nacimiento) VALUES ('Manuel', 'Rico', '1992-11-10');
INSERT INTO alumno(nombre, apellido, fecha_nacimiento) VALUES ('Pedro', 'Riesgo', '1980-01-05');
INSERT INTO alumno(nombre, apellido, fecha_nacimiento) VALUES ('Maria', 'Valenzuela', '1986-12-19'); 

-- Insertar notas
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (1, 7, '2018-12-19', 1, 1);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (2, 5, '2018-11-03', 2, 1);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (1, 3, '2018-11-03', 3, 2);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (2, 8, '2018-11-03', 1, 2);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (1, 2, '2018-07-05', 2, 3);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (2, 5, '2018-11-03', 1, 3);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (1, 9, '2018-09-13', 3, 4);
INSERT INTO nota(asignatura_id, calificacion, fecha_examen, convocatoria, alumno_id) VALUES (2, 5, '2018-11-23', 1, 4);

-- Insertar labores extraescolares
INSERT INTO labor_extra(puesto, alumno_id) VALUES ('Delegado', 1);
INSERT INTO labor_extra(puesto, alumno_id) VALUES ('Director', 2);
