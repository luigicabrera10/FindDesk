from flask import Flask, redirect, url_for, render_template, request, jsonify
from databaseConexion.conexion import *

app = Flask(__name__, static_folder='static')

@app.route("/")
def home():
    return redirect(url_for("login"))

@app.route("/login/")
def login():
    return render_template("login.html")

@app.route("/options/", methods=["GET", "POST"])
def options():
    if request.method == 'GET': 
        return render_template("options.html", mail = "Random email", code = "xxx-xxx-xxxxx")
    else:
        mail_value = request.values.get('mail')
        code_value = request.values.get('code')
        return render_template("options.html", mail = mail_value, code = code_value)

@app.route("/avisar/", methods=["GET", "POST"])
def avisar():
    if request.method == 'GET': return render_template("avisar.html", email="example@ucsp.edu.pe", code = "xxx-xx-xxxxx")
    else:
        mail_value = request.values.get('mail')
        code_value = request.values.get('code')
        return render_template("avisar.html", email=mail_value, student_code=code_value)

@app.route("/reservar/", methods=["GET", "POST"])
def reservar():
    if request.method == 'GET': 
        return render_template("reservar.html", email="example@ucsp.edu.pe", code = "xxx-xx-xxxxx")
    else:
        mail_value = request.values.get('mail')
        code_value = request.values.get('code')
        return render_template("reservar.html", email=mail_value, student_code=code_value)

@app.route("/confirmar_reserva/", methods=["GET", "POST"])
def confirmar_reserva():
    if request.method == 'GET': return render_template("bookingConfirm.html", 
                                date=[2023, 6, 1, 7,15], 
                                duration="15", 
                                class_code="N1000", 
                                chairs="100", 
                                email="example@ucsp.edu.pe",
                                student_code = "xxx-xx-xxxxx")
    else:
        mail_value = request.values.get('email')
        class_code_value = request.values.get('class_code')
        chairs_value = request.values.get('asientos')
        duration_value = request.values.get('minutos')
        date_value = request.form['date']
        student_code_value = request.form['student_code']

        # print(mail_value)
        # print(class_code_value)
        # print(chairs_value)
        # print(duration_value)
        # print(date_value)
        # print([date_value[:4], date_value[5:7], date_value[8:10], date_value[11:13], date_value[14:]])

        bookInsertion([date_value[:4], date_value[5:7], date_value[8:10], date_value[11:13], date_value[14:]],
                       duration_value, class_code_value, chairs_value, mail_value)

        return render_template("bookingConfirm.html", 
                                date=[date_value[:4], date_value[5:7], date_value[8:10], 
                                      date_value[11:13], date_value[14:]], 
                                duration=duration_value, 
                                class_code=class_code_value, 
                                chairs=chairs_value, 
                                email=mail_value,
                                student_code = student_code_value)


# Obtener aulas disponibles (RESERVAR)
@app.route("/request_login", methods=["POST"])
def request_login():
    code_r = request.form['code']
    mail_r = request.form['mail']
    return jsonify({'data' : exist(code_r, mail_r)})


# Hacer una reserva
@app.route("/request_book", methods=["POST"])
def request_book():
    date = request.form['date']
    # print(date)
    # print([date[:4], date[5:7], date[8:10], date[11:13], date[14:]])
    # print(request.form['minutos'], request.form['asientos'])

    answ = bookQuery(
        [date[:4], date[5:7], date[8:10], date[11:13], date[14:]],
        request.form['minutos'], request.form['asientos'])
    
    return jsonify({'data' : answ })

# Obtener aulas disponibles (AVISAR)
@app.route("/advice_book", methods=["POST"])
def advice_book():
    initdate = request.form['initdate']
    limitdate = request.form['limitdate']

    # print(initdate)
    # print([initdate[:4], initdate[5:7], initdate[8:10], initdate[11:13], initdate[14:]])
    # print([limitdate[:4], limitdate[5:7], limitdate[8:10], limitdate[11:13], limitdate[14:]])
    # print(request.form['minutos'], request.form['asientos'])

    answ = adviceQuery(
        [initdate[:4], initdate[5:7], initdate[8:10], initdate[11:13], initdate[14:]],
        [limitdate[:4], limitdate[5:7], limitdate[8:10], limitdate[11:13], limitdate[14:]],
        request.form['minutos'], request.form['asientos'])
    
    return jsonify({'data' : answ })


if __name__ == "__main__": app.run(debug=True)