Задание 1: Создание моделей SQLAlchemy

from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Date
from sqlalchemy.orm import relationship, declarative_base

Base = declarative_base()

class Publisher(Base):
    __tablename__ = 'publishers'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)

class Shop(Base):
    __tablename__ = 'shops'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)

class Book(Base):
    __tablename__ = 'books'
    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    publisher_id = Column(Integer, ForeignKey('publishers.id'))
    publisher = relationship("Publisher", back_populates="books")

class Stock(Base):
    __tablename__ = 'stocks'
    id = Column(Integer, primary_key=True)
    book_id = Column(Integer, ForeignKey('books.id'))
    shop_id = Column(Integer, ForeignKey('shops.id'))
    book = relationship("Book", back_populates="stocks")
    shop = relationship("Shop", back_populates="stocks")

class Sale(Base):
    __tablename__ = 'sales'
    id = Column(Integer, primary_key=True)
    stock_id = Column(Integer, ForeignKey('stocks.id'))
    price = Column(Integer, nullable=False)
    sale_date = Column(Date, nullable=False)
    stock = relationship("Stock", back_populates="sales")

# Взаимосвязи
Publisher.books = relationship("Book", order_by=Book.id, back_populates="publisher")
Shop.stocks = relationship("Stock", order_by=Stock.id, back_populates="shop")
Book.stocks = relationship("Stock", order_by=Stock.id, back_populates="book")
Stock.sales = relationship("Sale", order_by=Sale.id, back_populates="stock")

def create_tables(engine):
    Base.metadata.create_all(engine)



Задание 2: Запрос выборки магазинов

import sqlalchemy
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# Подключение к базе данных
DSN = 'postgresql://user:password@localhost:5432/database'  # Обновите свои данные
engine = sqlalchemy.create_engine(DSN)
Session = sessionmaker(bind=engine)
session = Session()

# Запрос данных
publisher_name = input("Введите имя издателя: ")

results = session.query(Sale).join(Stock).join(Book).join(Publisher).filter(Publisher.name == publisher_name).all()

for sale in results:
    book_title = sale.stock.book.title
    shop_name = sale.stock.shop.name
    price = sale.price
    sale_date = sale.sale_date.strftime('%d-%m-%Y')
    print(f"{book_title} | {shop_name} | {price} | {sale_date}")



Задание 3: Заполнение БД тестовыми данными


import json
from sqlalchemy.orm import sessionmaker

# Подключение к базе данных
DSN = 'postgresql://user:password@localhost:5432/database'  # Обновите свои данные
engine = sqlalchemy.create_engine(DSN)
create_tables(engine)

Session = sessionmaker(bind=engine)
session = Session()

with open('fixtures/tests_data.json', 'r') as fd:
    data = json.load(fd)

for record in data:
    model = {
        'publisher': Publisher,
        'shop': Shop,
        'book': Book,
        'stock': Stock,
        'sale': Sale,
    }[record.get('model')]
    session.add(model(id=record.get('pk'), **record.get('fields')))
session.commit()
