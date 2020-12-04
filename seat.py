from database import CursorConnectionFromPool


class Seat:
    def __init__(self, pos, screening, id):
        self.col = pos
        self.screening = screening
        self.id = id

    def __repr__(self):
        return "{}_{}".format(self.col, self.screening)

    def save_to_db(self):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('INSERT INTO seat_booking(pos, screening) '
                           'VALUES (%s, %s)',
                           (self.col, self.screening))

    @classmethod
    def load_from_db_by_screening_id(cls, screening_id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM seat_booking WHERE screening = %s', (screening_id,))
            seats = cursor.fetchall()
            seat_list = [cls(pos=seats[i][1], screening=seats[i][2], id=seats[i][0])
                         for i in range(len(seats))]
            if seat_list:
                return seat_list

