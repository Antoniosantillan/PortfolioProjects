import sqlite3
import os.path
#Verify that the file does not exist
path='./DataBase_cars.db'
#Create de connection and name
check_file=os.path.isfile(path)
connection=sqlite3.connect("DataBase_cars.db")
MyCursor=connection.cursor()
#Create Columns;
MyCursor.execute("""
    CREATE TABLE IF NOT EXISTS VEHICLES (
            REGISTRATION VARCHAR(10) PRIMARY KEY,
            MODEL VARCHAR(15),
            PRECIO INTEGER,
            COLOR VARCHAR (15)
            )
    """)
#Add data:
Add_Data=[ 
    ("5514-DSK", "Mercedes", "5000", "grey"),
    ("1234-SCD", "Seat", "1000", "red"),
    ("9832-FGV", "Renault", "2000", "yellow"),
    ("9898-KLS", "Seat", "2000", "blue"),
    ("1234-CCX", "BMW", "3500", "brown"),
        ]
if(check_file==False):
    MyCursor.executemany("INSERT INTO VEHICLES VALUES (?,?,?,?)",Add_Data)
    connection.commit()
    connection.close()
else:
    print("Delete existing file")