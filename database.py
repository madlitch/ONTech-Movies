from psycopg2 import pool


class Database:
    __connection_pool = None

    # initializes a connection pool of size 10 to the database
    @staticmethod
    def initialise(**kwargs):
        Database.__connection_pool = pool.SimpleConnectionPool(1, 10, **kwargs)

    # returns one of those connections in the pool
    @staticmethod
    def get_connection():
        return Database.__connection_pool.getconn()

    # when the connection is not needed anymore, returns that connection to the pool
    @staticmethod
    def return_connection(connection):
        return Database.__connection_pool.putconn(connection)

    # closes all connections
    @staticmethod
    def close_all_connections():
        Database.__connection_pool.closeall()


# creates the class CursorConnectionFromPool
class CursorConnectionFromPool:
    def __init__(self):
        self.connection = None
        self.cursor = None

    def __enter__(self):
        self.connection = Database.get_connection()
        self.cursor = self.connection.cursor()
        return self.cursor

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_val is not None:
            self.connection.rollback()
        else:
            self.cursor.close()
            self.connection.commit()
        Database.return_connection(self.connection)





