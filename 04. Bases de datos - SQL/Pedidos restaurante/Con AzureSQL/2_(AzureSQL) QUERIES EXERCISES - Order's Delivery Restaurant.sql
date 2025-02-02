/* [EJERCICIO 1]
Obtener el listado de todos los productos */

    SELECT * FROM PRODUCTO;

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT * FROM PRODUCTO; */

/* [EJERCICIO 2]
Obtener el número de pedido, dni del repartidor y hora de reparto de aquellos pedidos que se toman nota después de las siete de la tarde */

    SELECT Numero, DNI_R, Hora_rep FROM PEDIDO WHERE Hora_tm >'19:00';

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT Numero, DNI_R, Hora_rep FROM PEDIDO WHERE Hora_tm >'19:00' and Hora_rep is not null; */

/* [EJERCICIO 3] 
Obtener todos los campos de empleados que cobran entre 900 y 1000 euros. */

    --Opción 1
    SELECT * FROM EMPLEADO WHERE Salario >= 900 AND Salario <= 1000;
    --Opción 2
    SELECT * FROM EMPLEADO WHERE Salario BETWEEN 900 AND 1000;


        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT * FROM EMPLEADO WHERE Salario BETWEEN 900 AND 1000; */

/* [EJERCICIO 4]
Obtener el número de pedido e importe de aquellos que han sido registrados en el mes de noviembre de 2020 y su importe es mayor a 15 Euros.*/

    SELECT Numero, importe FROM PEDIDO WHERE fecha BETWEEN '2020-11-01' AND '2020-11-30' AND importe >'15'

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT Numero, importe FROM PEDIDO WHERE fecha BETWEEN '2020-11-01' AND '2020-11-30' AND importe >'15'

/* [EJERCICIO 5]
Obtener por cada uno de los repartidores su DNI junto a la cantidad de pedidos entregados.*/

    SELECT DNI_R, COUNT(*) AS TOTAL_PEDIDOS_REPARTIDOS FROM PEDIDO where dni_R is not null GROUP BY DNI_R;

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT DNI_R, COUNT(*) AS TOTAL_PEDIDOS_REPARTIDOS FROM PEDIDO where dni_R is not null GROUP BY DNI_R; */

/* [EJERCICIO 6]
Obtener por cada mes (con el formato de nombre y no de número ej. Noviembre),la cantidad de pedidos realizados*/
    
    
    /*{RESPUESTA ESPERADA O CORRECTA} [ERROR: Failed to execute query. Error: 'MONTHNAME' is not a recognized built-in function name.]
    SELECT MONTHNAME(fecha) as Mes, COUNT(Numero) as Cant_pedidos FROM PEDIDO P WHERE P.NUmero and fecha IS NOT NULL GROUP BY MONTH(fecha)


/* [EJERCICIO 7]
Obtener por cada mes (con el formato de nombre y no de número ej. Noviembre),la cantidad de pedidos realizados.*/


    /*{RESPUESTA ESPERADA O CORRECTA}
    SELECT MONTHNAME(fecha) as Mes, COUNT(Numero) as Cant_pedidos FROM PEDIDO P WHERE P.NUmero and fecha IS NOT NULL GROUP BY MONTH(fecha)*/

/* [EJERCICIO 8]
Obtener un listado con el nombre y dni de los empleados en el mismo campo  </br> y
anteponiendo el dni al nombre de la siguiente forma </br>(ej; 45776633P, Juan Rodríguez López)
que tenga turno de “tarde” o "noche". Ordenar el listado por dni.*/

    SELECT CONCAT(DNI,', ', Nombre) as Identificación_completa FROM EMPLEADO E WHERE Turno IN ('tarde','noche') ORDER BY dni;

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT CONCAT(DNI,', ', Nombre) as Identificación_completa FROM EMPLEADO E WHERE Turno IN ('tarde','noche') ORDER BY dni;*/

/* [EJERCICIO 9]
Obtener el nombre, código y precio de aquellos productos que superen o igualen la media de todos los precios. Ordenar de mayor a menor precio.*/

    SELECT nombre, codigo, precio FROM PRODUCTO WHERE precio >= (SELECT AVG(precio) FROM PRODUCTO) ORDER BY precio DESC;

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT nombre, codigo, precio FROM PRODUCTO WHERE precio >= (SELECT AVG(precio) FROM PRODUCTO) ORDER BY precio DESC; */

/* [EJERCICIO 10]
Obtener un listado con el nombre y DNI de los empleados que no han preparado nunca ningún pedido.*/

    SELECT nombre, dni FROM EMPLEADO WHERE dni NOT IN (SELECT DISTINCT dni_EP FROM PEDIDO);

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT nombre, dni FROM EMPLEADO WHERE dni NOT IN (SELECT DISTINCT dni_EP FROM PEDIDO);*/

/* [EJERCICIO 11]
Obtener el código, nombre y precio de los productos(estos dos últimos en el mismo </br>
campo) que están contenidos en los pedidos que ha tomado nota "Luis" o "María</br>
Luisa". Ordena el listado de mayor a menor valor por fecha del pedido*/

    SELECT PR.Codigo, CONCAT(PR.Nombre, ' ' , PR.Precio) AS NOMBRE_PRECIO
                    FROM PRODUCTO PR, PEDIDO P, consta C, EMPLEADO E
                    WHERE PR.Codigo = C.Codigo_Pr
                    AND P.Numero= C.Numero_P
                    AND P.DNI_ETM= E.DNI
                    AND E.nombre LIKE '%Luis%'
                    ORDER BY P.Fecha DESC;

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT PR.Codigo, CONCAT(PR.Nombre, ' ' , PR.Precio) AS NOMBRE_PRECIO
                    FROM PRODUCTO PR, PEDIDO P, consta C, EMPLEADO E
                    WHERE PR.Codigo = C.Codigo_Pr
                    AND P.Numero= C.Numero_P
                    AND P.DNI_ETM= E.DNI
                    AND E.nombre LIKE '%Luis%'
                    ORDER BY P.Fecha DESC; */

/* [EJERCICIO 12]
Obtener por cada repartidor, su nombre, cantidad de pedidos y el tiempo medio </br>
que tardan en entregar los pedidos una vez preparados. Ordenar el listado el </br>
tiempo medio que tardan en entregarlos: </br>*/



        /*{RESPUESTA ESPERADA O CORRECTA} [ERROR: Failed to execute query. Error: 'TIMEDIFF' is not a recognized built-in function name ]
        SELECT R.nombre, COUNT(*) AS cantidad_repartos,
            TIME_FORMAT(AVG(TIMEDIFF(Hora_rep,Hora_pre)),'%T')AS tiempo_entrega
            FROM REPARTIDOR R, PEDIDO P
            WHERE R.DNI = P.DNI_R
            GROUP BY R.DNI
            ORDER BY 3; */

/* [EJERCICIO 13]
Obtener un listado obteniendo el código, nombre y el precio de los productos 
cuyo precios sea el más barato o el más caro de todos */

    SELECT Codigo, Nombre, precio
            FROM PRODUCTO
            WHERE precio = (SELECT MAX(precio)
            FROM PRODUCTO)
            OR precio = (SELECT MIN(precio)
            FROM PRODUCTO);

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT Codigo, Nombre, precio
            FROM PRODUCTO
            WHERE precio = (SELECT MAX(precio)
            FROM PRODUCTO)
            OR precio = (SELECT MIN(precio)
            FROM PRODUCTO); */

/* [EJERCICIO 14]
Obtener por cada producto , el nombre y código el número total de pedidos en los que se encuentra teniendo en cuenta que el total de pedidos en los cuales se  </br>
encuentre sea superior o igual a dos. Ordena el listado de mayor a menor número de productos.*/


        /*{RESPUESTA ESPERADA O CORRECTA} [ERROR:Failed to execute query. Error: Invalid column name 'cantidad_pedidos' ]
        SELECT PR.nombre, PR.codigo, count(P.Numero) as cantidad_pedidos
            FROM PEDIDO P, PRODUCTO PR, consta C
            WHERE P.numero = C.numero_P
            AND PR.codigo = C.codigo_Pr
            GROUP BY PR.codigo
            HAVING cantidad_pedidos>=2
            ORDER BY cantidad_pedidos DESC; */

/* [EJERCICIO 15]
Mostrar listado de los empleados (código y NSS en la misma columna) que han tomado nota de algún pedido y contienen el producto de código 13 y
además el repartidor sea 'Laura'.*/

    SELECT E.nombre, CONCAT(E.DNI, ' ' , E.NSS) as Identificación
            FROM EMPLEADO E, PEDIDO P, REPARTIDOR R, consta C
            WHERE E.DNI = P.DNI_ETM AND R.DNI= P.DNI_R AND P.numero =
            C.numero_P
            AND R.nombre LIKE '%Laura%'
            AND C.codigo_Pr ='13';

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT E.nombre, CONCAT(E.DNI, ' ' , E.NSS) as Identificación
            FROM EMPLEADO E, PEDIDO P, REPARTIDOR R, consta C
            WHERE E.DNI = P.DNI_ETM AND R.DNI= P.DNI_R AND P.numero =
            C.numero_P
            AND R.nombre LIKE '%Laura%'
            AND C.codigo_Pr ='13'; */

/* [EJERCICIO 16]
Obtener el nombre del producto que es menú junto con el código de los productos que lo componen en aquellos pedidos del mes de septiembre de 2020.

    SELECT P.numero AS numero_pedido,PR.nombre , PR.codigo,
            EC.codigo_P_compuesto as
            producto_que_lo_compone, PRODUCTO.nombre as descripción_p_que_lo_compone
            FROM PRODUCTO PR, PEDIDO P, esta_compuesto EC, consta C, PRODUCTO PRODUCTO
            WHERE PR.codigo=EC.codigo_p AND PR.codigo=C.codigo_PR
            AND P.numero=C.numero_P AND PRODUCTO.codigo= EC.codigo_p_compuesto
            AND P.fecha BETWEEN '2020-09-01' AND '2020-09-30';

        /*{RESPUESTA ESPERADA O CORRECTA}
        SELECT P.numero AS numero_pedido,PR.nombre , PR.codigo,
            EC.codigo_P_compuesto as
            producto_que_lo_compone, PRODUCTO.nombre as descripción_p_que_lo_compone
            FROM PRODUCTO PR, PEDIDO P, esta_compuesto EC, consta C, PRODUCTO PRODUCTO
            WHERE PR.codigo=EC.codigo_p AND PR.codigo=C.codigo_PR
            AND P.numero=C.numero_P AND PRODUCTO.codigo= EC.codigo_p_compuesto
            AND P.fecha BETWEEN '2020-09-01' AND '2020-09-30'; */
