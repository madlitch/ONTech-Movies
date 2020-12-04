from database import CursorConnectionFromPool


class Theatre:
    def __init__(self, capacity, id):
        self.capacity = capacity
        self.id = id

    def __repr__(self):
        return "<Theatre {}, Capacity {}>".format(self.row, self.col, self.screening, self.id)

    @classmethod
    def load_from_db_by_theatre_id(cls, theatre_id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM seat_booking WHERE screening = %s', (theatre_id,))
            theatre_data = cursor.fetchone()
            if theatre_data:
                return cls(capacity=theatre_data[1], id=theatre_data[0])
