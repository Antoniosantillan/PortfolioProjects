#This code will help us to know the most profitable products of a company and the most effective employees, making use of the Northwind.db database
import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
conecction=sqlite3.connect("Northwind.db")
#Most profitable products:
Querry_1=('''
        SELECT ProductName, SUM(Price*Quantity) as Profits
        FROM OrderDetails as od
        JOIN Products as p ON p.ProductID=od.ProductID
        GROUP BY od.ProductID
        ORDER BY Profits DESC
        LIMIT 10
''')
top_Products=pd.read_sql_query(Querry_1,conecction)
print(top_Products)
top_Products.plot(x="ProductName",y="Profits",kind="bar",figsize=(10,5),legend=False)
plt.title("10 most profitable products")
plt.xlabel("Products")
plt.ylabel("Profits")
plt.xticks(rotation=45)
plt.show()
#More efficent Employees:
Querry_2=('''       
        SELECT FirstName || " " || LastName as Employee, Count(*) as Total
        FROM Orders as o
        JOIN Employees as e
        ON e.EmployeeID=o.EmployeeID
        GROUP BY o.EmployeeID
        ORDER BY Total DESC
''')
top_Employees=pd.read_sql_query(Querry_2,conecction)
print(top_Employees)
top_Employees.plot(x="Employee",y="Total",kind="bar",figsize=(10,5),legend=False)
plt.title("10 most efficient employees")
plt.xlabel("Employees")
plt.ylabel("Total Sold")
plt.xticks(rotation=45)
plt.show()