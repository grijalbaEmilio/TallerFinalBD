from flask import Flask
from flask_pymongo import PyMongo


app = Flask(__name__)
app.config["MONGO_URI"] = 'mongodb+srv://luisDB:luisDB@cluster0.l1jjl.mongodb.net/final_proyect_db'
mongo = PyMongo(app)

class posts():

    def address(self, request):
        print(request.json)
        mongo.db.users.insert_one(request.json)
        return { 'message' : 'insertado desde posts'}
