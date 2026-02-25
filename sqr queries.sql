-- Task 2 SQL queries 

-- Qeury 1
SELECT DISTINCT c.ContactName, c.City 
FROM Customers c 
JOIN Orders o 
ON o.CustomerID=c.CustomerID
JOIN Employees e
ON e.EmployeeID=o.EmployeeID
WHERE e.FirstName LIKE '%a'
ORDER BY c.City, c.ContactName;

-- Qeury 2
SELECT o.CustomerID, p.ProductName, SUM(od.quantity) TotalQuantitySold
FROM Orders o
JOIN [Order Details] od 
ON o.OrderID = od.OrderID
JOIN Products p 
ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '1997-01-01' AND o.OrderDate < '1998-01-01'
GROUP BY o.CustomerID, p.ProductName
HAVING SUM(od.Quantity) < 101;

-- Qeury 3
SELECT e.FirstName, e.LastName FROM Employees e
INNER JOIN Orders o 
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od 
ON o.OrderID = od.OrderID
INNER JOIN Products p 
ON od.ProductID = p.ProductID
WHERE p.ProductName = 'Boston Crab Meat'
GROUP BY e.EmployeeID, e.FirstName, e.LastName
HAVING MIN(od.Quantity) < (SELECT AVG(od.Quantity) FROM [Order Details] od 
WHERE ProductID = (SELECT ProductID FROM Products WHERE ProductName = 'Boston Crab Meat'))

-- Qeury 4
SELECT DISTINCT p.ProductName
FROM Products p
JOIN [Order Details] od 
ON p.ProductID = od.ProductID
JOIN Orders o 
ON od.OrderID = o.OrderID
JOIN Customers c 
ON o.CustomerID = c.CustomerID
WHERE c.Country NOT IN ('Germany', 'France')
GROUP BY p.ProductName
HAVING COUNT(o.OrderID) >= 10;

-- Qeury 5
WITH task5 AS (
   SELECT p.CategoryID, YEAR(o.OrderDate) AS OrderYear, MONTH(o.OrderDate) AS OrderMonth, SUM(od.Quantity) AS TotalQuantity
   FROM Products p
   INNER JOIN [Order Details] od 
   ON p.ProductID = od.ProductID
   INNER JOIN Orders o ON od.OrderID = o.OrderID
   GROUP BY p.CategoryID, YEAR(o.OrderDate), MONTH(o.OrderDate))

SELECT cat.CategoryName, task5.OrderYear, task5.OrderMonth, task5.TotalQuantity,
ROUND(AVG(task5.TotalQuantity) OVER (PARTITION BY task5.CategoryID ORDER BY task5.orderYear, task5.orderMonth 
ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 2) MovingAverage
FROM task5 
iNNER JOIN Categories cat
ON task5.CategoryID = cat.CategoryID
ORDER BY cat.CategoryName, task5.OrderYear, task5.OrderMonth;
