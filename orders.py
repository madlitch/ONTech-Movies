from database import CursorConnectionFromPool
import random


class Order:
    def __init__(self, order_id, user_id, seats, screening_id, order_date, id):
        self.order_id = order_id
        self.user_id = user_id
        self.seats = seats
        self.screening_id = screening_id
        self.order_date = order_date
        self.id = id
        self.incr = random.randint(1, 99999)

    def __repr__(self):
        return "<Order {}>".format(self.order_id)

    def save_to_db(self):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('INSERT INTO orders(order_id, user_id, seats, screening_id, order_date) '
                           'VALUES (stringify_bigint(pseudo_encrypt(%s)), %s, %s, %s, CURRENT_TIMESTAMP(0))',
                           (self.incr, self.user_id, self.seats, self.screening_id))

    @classmethod
    def load_from_db_by_user_id(cls, user_id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM orders WHERE user_id = %s ORDER BY id DESC LIMIT 1', (user_id,))
            order_data = cursor.fetchone()
            if order_data:
                return cls(order_id=order_data[1], user_id=order_data[2], seats=order_data[3],
                           screening_id=order_data[4], order_date=order_data[5], id=order_data[0])

    @classmethod
    def load_from_db_by_order_id(cls, order_id):
        with CursorConnectionFromPool() as cursor:
            cursor.execute('SELECT * FROM orders WHERE order_id = %s', (order_id,))
            order_data = cursor.fetchone()
            if order_data:
                return cls(order_id=order_data[1], user_id=order_data[2], seats=order_data[3],
                           screening_id=order_data[4], order_date=order_data[5], id=order_data[0])
