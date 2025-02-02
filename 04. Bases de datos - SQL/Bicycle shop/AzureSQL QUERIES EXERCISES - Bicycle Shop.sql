-- EXERCISES BICICLE SHOP
/*Several exercises of queries on AzureSQL using the sample database of a bicicle shop offered
by the platform of Azure.<center>*/

/*1. Selecciona todos los detalles de los productos cuyo precio sea mayor a
100€ (Select all the details of the products whose price is more than 100€.)*/
SELECT *
    FROM SalesLT.Product
    WHERE ListPrice > 100;

/*2. Muestra los porductos que pertenecenm a la categoria ID 18 y tienen un peso mayor
a 1000. (Displays products that belong to ID 18 category and have a weight greater
than 1000).*/
SELECT p.Name, p.Weight
    FROM SalesLT.Product AS p
    JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
    WHERE pc.ProductCategoryID = 18 AND p.Weight > 1000;

/*3. Selecciona los nombres y precios de los productos cuyo precio esté entre 50€ y
300€ (Select the names and prices of the products whose price is between 50€ and
300€.) */
SELECT Name, ListPrice
    FROM SalesLT.Product
    WHERE ListPrice BETWEEN 50 AND 300;

/*4. Muestra cuántos productos hay en cada categoria (Shows how many products are
in each category.)*/
SELECT pc.Name AS CategoryName, COUNT(p.ProductID) AS NumberOfProducts
    FROM SalesLT.Product p
    JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.Name
    ORDER BY pc.Name;

/*5. Obten la cantidad total de ventas (cantidad de productos) por clientes.
[Obtain the total amount of sales (number of products) by customer.] */
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(*) AS TotalSales
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName;

/*6. Muestra los clientes que han comprado mas de 10 productos en total.
(Displays customers who have purchased more than 10 products in total)*/

-- OPTION 1
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(*) AS TotalProductsPurchased
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
    HAVING COUNT(*) > 10

-- OPTION 2
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(distinct sod.ProductID) as TotalProducts
    FROM SalesLT.Customer c
    JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
    HAVING COUNT(distinct sod.ProductID) > 10;

/*7. Muestra el nombre de los productos junto con el nombre de la categoría a la que
pertenecen. (Displays the name of the products together with the name of the category
to which they belong.)*/
SELECT p.Name AS ProductName, pc.Name AS CategoryName
    FROM SalesLT.Product AS p
    JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID

/*8. Muestra los nombres de los productos y las fechas de las ordenes en las que han
sido vendidos pero solo si fueron vendidos despues de enero de 2020 ( Shows the names
of the products and the dates of the orders in which they have been sold, but only if
they were sold after January 2020.)*/
SELECT p.Name, o.OrderDate
    FROM SalesLT.Product AS p
    JOIN SalesLT.SalesOrderDetail AS od ON p.ProductID = od.ProductID
    JOIN SalesLT.SalesOrderHeader AS o ON od.SalesOrderID = o.SalesOrderID
    WHERE o.OrderDate > '2020-01-01';

/*9. Muestra los nombres de los produtos y los nombres de los clientes que han
comprado esos productos (Displays product names and the names of customers who 
have purchased those products)*/
SELECT p.Name AS ProductName, c.FirstName + ' ' + c.LastName AS CustomerName
    FROM SalesLT.Product AS p
    JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    JOIN SalesLT.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID;

/*10. Encuentra los clientes que han gastado mas de 1000€ en total en productos.
(Find customers who have spent more than 1000€ in total on products.)*/
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(od.UnitPrice * od.OrderQty) AS TotalSpent
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS od ON soh.SalesOrderID = od.SalesOrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
    HAVING SUM(od.UnitPrice * od.OrderQty) > 1000;

/*11. Muestra los clientes que han hecho mas de 1 compra. (Displays customers who
have made more than 1 purchase.)*/
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(soh.SalesOrderID) AS PurchaseCount
    FROM SalesLT.Customer c
    JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
    HAVING COUNT(soh.SalesOrderID) > 1;