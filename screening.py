from database import CursorConnectionFromPool


class Screening:
    def __init__(self, movie_id, theatre, date, attending, id):
        self.movie_id = movie_id
        self.theatre = theatre
        self.date = date
        self.attending = attending
        self.id = id

    def __repr__(self):
        return "<Screening {} of movie {} at theatre {} on {}>".format(self.id, self.movie_id, self.theatre, self.date)

    @staticmethod
    def update_attending(count, id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('UPDATE screenings SET attending = attending + %s WHERE id = %s', (count, id,))

    @classmethod
    def load_from_db_by_screening_id(cls, id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM screenings WHERE id = %s', (id,))
            screening_data = cursor.fetchone()
            if screening_data:
                return cls(movie_id=screening_data[1], theatre=screening_data[2], date=screening_data[3],
                           attending=screening_data[4], id=screening_data[0])

    @classmethod
    def load_screenings_by_movie_id(cls, id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM screenings WHERE movie_id= %s', (id,))
            screenings = cursor.fetchall()
            screening_list = [cls(movie_id=screenings[i][1], theatre=screenings[i][2], date=screenings[i][3],
                                  attending=screenings[i][4], id=screenings[i][0])
                              for i in range(len(screenings))]
            if screening_list:
                return screening_list

