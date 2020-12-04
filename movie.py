# MASSIMO ALBANESE 2020
# ONTECHMOVIES FOR SOFE2800U

from database import CursorConnectionFromPool


# creates the Movie object
class Movie:
    def __init__(self, name, director, synopsis, photo_url, id):
        self.name = name
        self.director = director
        self.synopsis = synopsis
        self.photo_url = photo_url
        self.id = id

    # a tostring function, returns a readable string describing the object
    def __repr__(self):
        return "<Movie {}>".format(self.name)

    # class method that returns an object of class Movie, in this case a list of Movie objects
    @classmethod
    def load_all(cls):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM movie')
            # gets all movies in the database
            movies = cursor.fetchall()
            # uses list comprehension to generate a list of movies, then returns that list
            movie_list = [cls(name=movies[i][1], director=movies[i][2], synopsis=movies[i][3],
                              photo_url=movies[i][4], id=movies[i][0])
                          for i in range(len(movies))]
            if movie_list:
                return movie_list

    @classmethod
    def load_from_db_by_name(cls, name):
        with CursorConnectionFromPool() as cursor:
            # the replace function allows us to directly put the name in the url when requesting for that movie,
            # replacing all of the spaces with a dashes
            # the %s allows us to format the sql query with variables in python, replacing the %s with the variable
            # next to it, in this case the variable 'name'
            cursor.execute('SELECT * FROM movie WHERE name = %s', (name.replace("-", " "),))
            movie_data = cursor.fetchone()
            if movie_data:
                # returns a movie object if it exists in the database
                return cls(name=movie_data[1], director=movie_data[2], synopsis=movie_data[3], photo_url=movie_data[4],
                           id=movie_data[0])

    @classmethod
    def load_from_db_by_id(cls, id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM movie WHERE id = %s', (id,))
            movie_data = cursor.fetchone()
            if movie_data:
                return cls(name=movie_data[1], director=movie_data[2], synopsis=movie_data[3], photo_url=movie_data[4],
                           id=movie_data[0])
