-- MOSTRAR TABLAS | SELECCIÓN DE DATOS
-- Mostramos todas las asignaturas registradas
select * from asignatura;
-- Mostramos todos los alumnos registrados
select * from alumno;
-- Mostramos todas las notas registradas
select * from nota;
-- Mostramos todas las labores extraescolares registradas
select * from labor_extra;
-- Ver los nombres y apellidos de todos los alumnos
select nombre, apellido from alumno;
-- Ver el ID de la asignatura, la calificación y el ID del alumno en la tabla de notas
select asignatura_id, calificacion, alumno_id from nota;
