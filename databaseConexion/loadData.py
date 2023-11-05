import psycopg2
import csv
import os.path

chairs = {}

fp = open('pass.txt', "r")

connection = psycopg2.connect(
    host="localhost",
    database="classroombooking",
    user="northsoldier",
    password=fp.read()
)

fp.close()

cursor = connection.cursor()
base_query = "INSERT INTO students VALUES ("
query = ""

with open(os.path.dirname(__file__) + '/../data/StudentsDataBase.csv', mode ='r') as file:
    csvFile = csv.reader(file)
    for lines in csvFile:
        query += base_query + "'"+lines[0]+"', '" +lines[1]+"', '" +lines[2] + "', '" +lines[3] + "');\n"


print("Executing Querys:\n" + query)

# cursor.execute(query)
# connection.commit()
# count = cursor.rowcount
# print(count, "Record inserted successfully into mobile table")


base_query = "INSERT INTO classrooms VALUES ("
query = ""

with open(os.path.dirname(__file__) + '/../data/Classrooms.csv', mode ='r') as file:
    csvFile = csv.reader(file)
    for lines in csvFile:
        query += base_query + "'"+lines[0] + "', " + lines[1] + ");\n"
        chairs[lines[0]] = lines[1]

print("\nExecuting Querys:\n" + query)


# cursor.execute(query)
# connection.commit()
# count = cursor.rowcount
# print(count, "Record inserted successfully into mobile table")


base_query = "INSERT INTO bookings VALUES ("
query = ""

with open(os.path.dirname(__file__) + '/../data/Bookings.csv', mode ='r') as file:
    csvFile = csv.reader(file)
    for lines in csvFile:
        query += base_query + "'"+lines[0] + "', to_timestamp('" + lines[1] + "', 'DD-MM-YYYY HH24:MI'), " + "EXTRACT(epoch FROM (to_timestamp('" + lines[2] + "', 'DD-MM-YYYY HH24:MI') - " + "to_timestamp('" + lines[1] + "', 'DD-MM-YYYY HH24:MI')))/60, "+ chairs[lines[0]] +", NULL);\n"

print("\nExecuting Querys:\n" + query)

# cursor.execute(query)
# connection.commit()
# count = cursor.rowcount
# print(count, "Record inserted successfully into mobile table")


cursor.close()
connection.close()

# print(chairs)
