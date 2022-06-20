import mimetypes
from flask import Flask, request, Response
from flask_pymongo import PyMongo
from bson import json_util
import json

app = Flask(__name__)
app.config["MONGO_URI"] = 'mongodb+srv://luisDB:luisDB@cluster0.l1jjl.mongodb.net/final_proyect_db'
mongo = PyMongo(app)

# creación de direcciones
@app.route('/address', methods=["POST"])
def address():
        body = request.json
        street_type = body["street_type"]
        code_city = body["city"]["code_city"]
        city_name = body["city"]["city_name"]
        success = street_type and code_city and city_name
        
        if (success): 
            mongo.db.address.insert_one(request.json)
            return { 'message' : "dirección registrada con exito" }
        else :
            return { 'message' : "no se pudo registrar la dirección" }

# creación de concesionarias
@app.route('/dealership', methods=["POST"])
def dealership():
        body = request.json
        dealership_name = body["dealership_name"]
        success = dealership_name
        if (success): 
            mongo.db.dealership.insert_one(request.json)
            return { 'message' : "concesionaria registrada con exito" }
        else :
            return { 'message' : "no se pudo registrar la concesionaria" }

# creación de sede
@app.route('/branch', methods=["POST"])
def branch():
        body = request.json
        branch_name = body["branch_name"]
        address = body["address"]
        dealership = body["dealership"]
        success = branch_name and address and dealership
        if (success): 
            mongo.db.branch.insert_one(request.json)
            return { 'message' : "sede registrada con exito" }
        else :
            return { 'message' : "no se pudo registrar la sede" }

# creación de aseguradora
@app.route('/insurance', methods=["POST"])
def insurance():
        body = request.json
        vehicle_insurer = body["vehicle_insurer"]

        success = vehicle_insurer
        if (success): 
            mongo.db.insurance.insert_one(request.json)
            return { 'message' : "aseguradora registrada con exito" }
        else :
            return { 'message' : "no se pudo registrar la aseguradora" }

# creación la relación entre aseguradora y concecionaria de muchos a muchos
@app.route('/insurance_dealership', methods=["POST"])
def insurance_dealership():
        body = request.json
        vehicle_insurer = body["vehicle_insurer"]
        dealership = body["dealership"]

        success = vehicle_insurer and dealership
        if (success): 
            mongo.db.insurance_dealership.insert_one(request.json)
            return { 'message' : "relación aseguradora - concesionaria registrada con exito" }
        else :
            return { 'message' : "no se pudo registrar la relación" }

# creación de supervisor
@app.route('/advisor', methods=["POST"])
def advisor():
        body = request.json
        advisor_name = body["advisor_name"]
        advisor_lastname = body["advisor_lastname"]
        document_type = body["document_type"]
        document = body["document"]
        age = body["age"]
        email = body["email"]
        contract_type = body["contract_type"]
        branch = body["branch"]

        success = advisor_name and advisor_lastname and document_type and document and age and email and contract_type and branch
        if (success): 
            mongo.db.advisor.insert_one(request.json)
            return { 'message' : "supervisor registrado con exito" }
        else :
            return { 'message' : "no se pudo registrar el supervisor" }

# creación de supervisor
@app.route('/client_p', methods=["POST"])
def client_p():
        body = request.json
        client_name = body["client_name"]
        client_lastname = body["client_lastname"]
        document_type = body["document_type"]
        document = body["document"]
        age = body["age"]
        email = body["email"]
        driver_license = body["driver_license"]
        advisor = body["advisor"]

        success = client_name and client_lastname and document_type and document and age and email and driver_license and advisor
        if (success):
            mongo.db.client_p.insert_one(request.json)
            return { 'message' : "cliente registrado con exito"}
        else:
            return { 'message' : "no se pudo registrar el cliente"}

# --------------------------------------------------------------------------------------------------
# --------------------------------------CONSULTA i ---------------------------------------------------

# retorna las ciudades en las que está precente la concesionaria dada
@app.route('/getCitiesDealership/<dealership>', methods=['GET'])
def getCitiesDealership(dealership):
    id = dealership_name('Mazda')
    filtradas = branch_in_dealership(id)
    cities = city_branch(filtradas)
    return { 'ciudades' : cities}

#retorna el id de la concecionaria dado su nombre
def dealership_name(name_dealership):
    res = mongo.db.dealership.find()
    response_string = json_util.dumps(res)
    response_json = json.loads(response_string)
    for n in response_json:
        if n['dealership_name'] == name_dealership:
            return n['_id']['$oid']

#retorna las sedes de una concecionaria dado su id
def branch_in_dealership(id_dealership):
    res = mongo.db.branch.find()
    response_string = json_util.dumps(res)
    response_json = json.loads(response_string)
    final = []
    for n in response_json:
        if (n['dealership'] == id_dealership):
            final.append(n)
            None
    return final

#retorna lac ciudades de las sedes dadas
def city_branch(branch):
    res = mongo.db.address.find()
    response_string = json_util.dumps(res)
    response_json = json.loads(response_string)
    final = []
    for address in response_json:
        for bran in branch:
            if bran['address'] == address['_id']['$oid'] : 
                final.append(address['city']['city_name'])
    return final


# --------------------------------------------------------------------------------------------------
# --------------------------------------CONSULTA ii ----------------------------------------------------

# retorna las ciudades en las que está precente la concesionaria dada
@app.route('/getIsurance/<namedealership>', methods=['GET'])
def getIsurance(namedealership):
    insures = ids_insurance(namedealership)
    return { 'aseguradoras' : insures}

#retorna aseguradoras asociadas a una concesionaria
def ids_insurance(dealership_name):
    res = mongo.db.dealership.find()
    response_string = json_util.dumps(res)
    response_json = json.loads(response_string)
    final = []
    for dealership in response_json:
        if dealership['dealership_name'] == dealership_name :
            for insurance in dealership['insurance']:
                final.append(insurance['vehicle_insurer'])
    return final

# --------------------------------------------------------------------------------------------------
# --------------------------------------CONSULTA iii ----------------------------------------------------


# retorna las los clientes de un advisor dado
@app.route('/getClients/<nameAdvisor>', methods=['GET'])
def getClients(nameAdvisor):
    insures = clientsAdvisor(nameAdvisor)
    return { 'clientes' : insures}


#retorna el id del asesor dado su nombre
def id_advisor(advisor_name):
    res = mongo.db.advisor.find()
    response_string = json_util.dumps(res)
    response_json = json.loads(response_string)
    for n in response_json:
        if n['advisor_name'] == advisor_name:
            return n['_id']['$oid']

#retorna los cliente de un asesor dado
def clientsAdvisor(advisor):
    advisor = id_advisor(advisor)
    res = mongo.db.client_p.find()
    response_string = json_util.dumps(res)
    response_json = json.loads(response_string)
    final = []
    for n in response_json:
        if (n['advisor'] == advisor):
            final.append(n)
            None
    return final

if __name__ == "__main__":
    app.run(debug=True)