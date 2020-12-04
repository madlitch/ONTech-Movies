# MASSIMO ALBANESE 2020
# ONTECHMOVIES FOR SOFE2800U

# database logic is explained in movie.py
# database connection is explained in database.py
# html logic is explained in templates/order.html
# input validation in javascript is explained in static/UIUpdate.js
"""
TODO | To replicate the project on your machine, you have to initialize the database.
TODO | Make sure to use the database_instantiation.sql file to do so, in the database 'theatre' and 'public' schema.
TODO | The user, password, and port are in the Database.initialise on line 27 below.
TODO | Remember that our database is written in POSTGRESQL and the instantiation file WILL NOT WORK with MySQL.
"""
# import technologies needed for the project
from flask import Flask, render_template, request
# import class files with embedded functions to write/read from the database
from database import Database
from user import User
from movie import Movie
from screening import Screening
from orders import Order
from seat import Seat

# server and database connection initialization
app = Flask(__name__)
app.secret_key = '1234'
Database.initialise(user='postgres', password='localtest', database='theatre', host='localhost', port=5433)

# all @app.route functions are linked with a function right below them, that supplies the logic needed when the server
# gets a request at that URL
# the render_template function allows us to render an html file and pass along information into the files themselves,
# which allows us to have logic embedded in the html files
@app.route('/')
def gallery():
    movies = Movie.load_all()
    return render_template('gallery.html', movies=movies)


# request.args.get allows us to parse the arguments send in an url
@app.route('/movie')
def movie():
    query = request.args.get('q')
    movie_data = Movie.load_from_db_by_name(query)
    if movie_data:
        return render_template('movie.html', content=movie_data)
    else:
        return render_template('404.html', content=query)


@app.route('/order')
def order():
    query = request.args.get('q')
    movie_data = Movie.load_from_db_by_name(query)
    screenings = Screening.load_screenings_by_movie_id(movie_data.id)
    booked_seats = []
    # compiles all the seat bookings by the screening id from the database, puts them in a list, and passes that list
    # into the html file
    for i in range(len(screenings)):
        seat_list = Seat.load_from_db_by_screening_id(screenings[i].id)
        if seat_list:
            booked_seats.extend(seat_list)
    # compiles a list of dates with a specific format for all screenings of the chosen movie
    date_list = [(screenings[i].date.strftime("%B %d, %Y %I:%M %p"), screenings[i].id) for i in range(len(screenings))]
    if screenings:
        return render_template('order.html', movie_data=movie_data, screenings=date_list, seat_list=booked_seats)


@app.route('/order/process', methods=['POST'])
def process():
    # pulls the form information from the post query
    form = request.form
    user = User.load_from_db_by_student_id(form["student_id"])
    # if the user doesn't exist in the database already, then creates a new user
    # users are classified by student id
    if not user:
        user = User(form["first_name"], form["last_name"], form["student_id"], None)
        user.save_to_db()
        user = User.load_from_db_by_student_id(form["student_id"])
    # compiles a list of the seats chosen in the form from the post query
    seats = ""
    seat_list = form.getlist('seats')
    for seat in seat_list:
        seats += seat + " "
        new_seat = Seat(seat, form["screening"], None)
        new_seat.save_to_db()
    # updates attending in the screening database, then creates a new order in the database. all the fields that are
    # passed as None are filled by the database itself.
    Screening.update_attending(len(seat_list), form["screening"])
    new_order = Order(None, user.id, seats, form["screening"], None, None)
    new_order.save_to_db()
    new_order = Order.load_from_db_by_user_id(user.id)
    screening = Screening.load_from_db_by_screening_id(new_order.screening_id)
    movie = Movie.load_from_db_by_id(screening.movie_id)
    order_date = new_order.order_date.strftime("%B %d, %Y %I:%M %p")
    screening_date = screening.date.strftime("%B %d, %Y %I:%M %p")
    return render_template('orderdetails.html', user=user, order=new_order, movie=movie, screening=screening,
                           order_date=order_date, screening_date=screening_date)


@app.route('/pastorder')
def past_order():
    return render_template('pastorder.html')


@app.route('/orderdetails')
def order_details():
    query = request.args.get('q')
    # if the query is not valid, returns a 404
    if query:
        order = Order.load_from_db_by_order_id(query)
        # if the requested order id doesn't exist in the database, returns a 404
        if order:
            user = User.load_from_db_by_id(order.user_id)
            screening = Screening.load_from_db_by_screening_id(order.screening_id)
            movie = Movie.load_from_db_by_id(screening.movie_id)
            order_date = order.order_date.strftime("%B %d, %Y %I:%M %p")
            screening_date = screening.date.strftime("%B %d, %Y %I:%M %p")
            return render_template('orderdetails.html', user=user, order=order, movie=movie, screening=screening,
                                   order_date=order_date, screening_date=screening_date)
        else:
            return render_template('404.html', content="Order")
    return render_template('404.html', content=query)


app.run(port=4995, debug=False)

