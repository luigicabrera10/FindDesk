import psycopg2

fp = open('databaseConexion/pass.txt', "r")

connection = psycopg2.connect(
    host="localhost",
    database="classroombooking",
    user="northsoldier",
    password=fp.read()
)

fp.close()
cursor = connection.cursor()

def exist(code, email):
    query = "SELECT * from students WHERE code = '" + code + "' AND email = '" + email + "';"

    print("\n", query, "\n")

    cursor.execute(query)
    results = cursor.fetchall()
    print(results)

    if len(results) == 0: return 0
    return 1

def bookQuery(start, duration, chairs):
    query = "SELECT * FROM reservarResults(to_timestamp('"+str(start[0])+"-"+str(start[1])+"-"+str(start[2])
    query += " "+str(start[3])+":"+str(start[4])+"', 'YYYY-MM-DD HH24:MI') , " 
    query += str(duration)+", "+ str(chairs)+");"

    print("\n", query, "\n")

    cursor.execute(query)
    results = cursor.fetchall()
    print(results)
    return results

def bookInsertion(start, duration, class_code, chairs, email):
    query = "INSERT INTO bookings VALUES ('"+str(class_code)+"', to_timestamp('"+str(start[0])+"-"+str(start[1])+"-"+str(start[2])+" "+str(start[3])+":"+str(start[4])+"', 'YYYY-MM-DD HH24:MI'), "+str(duration)+", "+str(chairs)+", '"+str(email)+"');"

    print("\n", query, "\n")

    cursor.execute(query)
    connection.commit()
    count = cursor.rowcount
    return count


def adviceQuery(start, limit, duration, chairs):
    query = "SELECT * FROM avisarFinalResults(to_timestamp('"+str(start[0])+"-"+str(start[1])+"-"+str(start[2])
    query += " "+str(start[3])+":"+str(start[4])+"', 'YYYY-MM-DD HH24:MI') , " 
    query += "to_timestamp('"+str(limit[0])+"-"+str(limit[1])+"-"+str(limit[2])
    query += " "+str(limit[3])+":"+str(limit[4])+"', 'YYYY-MM-DD HH24:MI') , "
    query += str(duration)+", "+ str(chairs)+");"

    print("\n", query, "\n")

    cursor.execute(query)
    results = cursor.fetchall()
    print(results)
    return results


# exist("201-05-47572","arianne.delgado@ucsp.edu.pe")

# bookQuery([2023,5,7,11,9], 100, 50, 1)

# adviceQuery([2023,6,18,7,0], [2023,6,18,18,30], 120, 6)