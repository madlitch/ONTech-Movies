from database import CursorConnectionFromPool


class User:
    def __init__(self, first_name, last_name, student_id, id):
        self.first_name = first_name
        self.last_name = last_name
        self.student_id = student_id
        self.id = id

    def __repr__(self):
        return "<User {} {} {}>".format(self.first_name, self.last_name, self.student_id)

    def save_to_db(self):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('INSERT INTO users(first_name, last_name, student_id) '
                           'VALUES (%s, %s, %s)',
                           (self.first_name, self.last_name, self.student_id))

    @classmethod
    def load_from_db_by_student_id(cls, student_id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM users WHERE student_id = %s', (student_id,))
            user_data = cursor.fetchone()
            if user_data:
                return cls(first_name=user_data[1], last_name=user_data[2], student_id=user_data[3], id=user_data[0])

    @classmethod
    def load_from_db_by_id(cls, id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM users WHERE id = %s', (id,))
            user_data = cursor.fetchone()
            if user_data:
                return cls(first_name=user_data[1], last_name=user_data[2], student_id=user_data[3], id=user_data[0])
