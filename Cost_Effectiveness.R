##This code will help us to know the most profitable products of a company and the most effective employees, 
#making use of the Northwind.db database
library(tidyverse)
library(DBI)
library(RSQLite)
#other databases:
#library(RPostgreSQL)
#library(RMySQL)
Data_Base <- dbConnect(SQLite(),dbname="Northwind.db")
dbListTables(Data_Base)
#Most profitable products:
Querry_1 <- dbGetQuery(Data_Base,'SELECT ProductName, SUM(Price*Quantity) as Profits
                                 FROM OrderDetails as od
                                 JOIN Products as p ON p.ProductID=od.ProductID
                                 GROUP BY od.ProductID
                                 ORDER BY Profits DESC
                                 LIMIT 10') 
print(Querry_1)
ggplot(Querry_1, aes(x = reorder(ProductName, -Profits), y = Profits)) +
geom_col(fill = "blue") +
labs(title = "10 most profitable products", x = "Products", y = "Profits") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
#More efficent Employees:
Querry_2 <- dbGetQuery(Data_Base,'SELECT FirstName || " " || LastName as Employee, Count(*) as Total
                                  FROM Orders as o
                                  JOIN Employees as e
                                  ON e.EmployeeID=o.EmployeeID
                                  GROUP BY o.EmployeeID
                                  ORDER BY Total DESC
                                  ')
print(Querry_2)
ggplot(Querry_2, aes(x = reorder(Employee, -Total), y = Total)) +
geom_col(fill = "blue") +
labs(title = "10 most efficient employees", x = "Employees", y = "Total Sold") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))