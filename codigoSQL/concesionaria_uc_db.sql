CREATE DATABASE IF NOT EXISTS proyecto_final_bd1;
USE proyecto_final_bd1;

#CREACIÓN DE LAS TABLAS
CREATE TABLE dealership(
nit_dealership INT PRIMARY KEY NOT NULL,
dealership_name VARCHAR(75) UNIQUE NOT NULL
);

CREATE TABLE city(
	code_city INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    city_name VARCHAR(75) UNIQUE NOT NULL
);

CREATE TABLE address(
	id_address INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    street_type ENUM("Calle", "Carrera", "Avenida", "Circumbalar") DEFAULT"Calle",
    fk_code_city INT NOT NULL
);

CREATE TABLE branch(
	code_branch INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
	branch_name VARCHAR(105) UNIQUE NOT NULL,
    fk_id_address INT NOT NULL
);

CREATE TABLE person(
	id_person INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    person_name VARCHAR(25) NOT NULL,
    lastname VARCHAR(25) NOT NULL,
    document_type ENUM("C.C.", "C.E.", "P.E.P.", "Pasaporte") DEFAULT"C.C.",
    document VARCHAR(11) UNIQUE NOT NULL,
    age INT NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    fk_code_branch INT NOT NULL
);

CREATE TABLE advisor(
	id_advisor INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    contract_type ENUM("CONTRACTOR", "ON STAFF","PROVISIONAL") DEFAULT"ON STAFF",
    fk_id_person INT NOT NULL
);

CREATE TABLE client_p(
	id_client_p INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    client_type ENUM("FREQUENT", "NO FREQUENT") DEFAULT"NO FREQUENT",
    driver_license BOOLEAN DEFAULT 1 NOT NULL,
    expiration_date_license DATE NOT NULL,
    fk_id_person INT NOT NULL,
    fk_id_advisor INT NOT NULL
);

CREATE TABLE vehicle_brand(
	id_vehicle_brand INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    vehicle_brand VARCHAR(15) UNIQUE NOT NULL,
    original_country VARCHAR(15) NOT NULL,
    fk_nit_dealership INT NOT NULL
);

CREATE TABLE vehicle_type(
	id_vehicle_type INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    vehicle_type VARCHAR(15) UNIQUE NOT NULL,
    model INT NOT NULL,
    chassis_vehicule VARCHAR(17) UNIQUE NOT NULL,
    fk_id_vehicle_brand INT NOT NULL
);

CREATE TABLE vehicle_color(
	id_vehicle_color INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    vehicle_color_name VARCHAR(25) NOT NULL UNIQUE
);

#Nombre de aseguradoras de vehiculos: Sura, Colpatria,
CREATE TABLE vehicle_insurer(
	id_vehicle_insurer INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    vehicle_insurer VARCHAR(15) UNIQUE NOT NULL
);

#Tabla ternaria entre concesionaria y aseguradora
CREATE TABLE dealership_insurer(
	id_dealership_insurer INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    fk_id_vehicle_insurer INT NOT NULL,
    fk_nit_dealership INT NOT NULL
);

#Cuando se le asigna un seguro al vehiculo
#El vehiculo con chasis ----- del cliente ----- tiene como aseguradora a SURA 
CREATE TABLE insurance_types(
	id_insurance_types INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    insurance_types VARCHAR(15) UNIQUE NOT NULL,
    inception_date DATE NOT NULL,
    fk_id_vehicle_insurer INT NOT NULL,
    fk_id_vehicle_type INT NOT NULL
);

CREATE TABLE purchase_receipt(
	id_purchase_receipt INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    purchase_receipt_date DATE NOT NULL,
    unit_price FLOAT NOT NULL,
    tuition_value FLOAT NOT NULL,
    total FLOAT NOT NULL,
    payment_methods ENUM("CASH", "CREDIT","BOTH") DEFAULT"CASH",
    fk_id_vehicle_type INT NOT NULL,
    fk_id_advisor INT NOT NULL,
    fk_id_client INT NOT NULL
);

# ===============================================================================
#CREACIÓN DE RELACIONES ENTRE TABLAS
# ===============================================================================
ALTER TABLE address
ADD FOREIGN KEY (fk_code_city) REFERENCES city (code_city);

ALTER TABLE branch
ADD FOREIGN KEY (fk_id_address) REFERENCES address (id_address);

ALTER TABLE person
ADD FOREIGN KEY (fk_code_branch) REFERENCES branch (code_branch);

ALTER TABLE client_p
ADD FOREIGN KEY (fk_id_advisor) REFERENCES advisor(id_advisor);

ALTER TABLE advisor
ADD FOREIGN KEY (fk_id_person) REFERENCES person (id_person);

ALTER TABLE client_p
ADD FOREIGN KEY (fk_id_person) REFERENCES person (id_person);

ALTER TABLE insurance_types
ADD insurance_value INT NOT NULL,
ADD FOREIGN KEY (fk_id_vehicle_insurer) REFERENCES vehicle_insurer (id_vehicle_insurer),
ADD FOREIGN KEY (fk_id_vehicle_type) REFERENCES vehicle_type(id_vehicle_type);

ALTER TABLE purchase_receipt
ADD FOREIGN KEY (fk_id_advisor) REFERENCES advisor (id_advisor),
ADD FOREIGN KEY (fk_id_vehicle_type) REFERENCES vehicle_type (id_vehicle_type),
ADD FOREIGN KEY (fk_id_client) REFERENCES client_p (id_client_p);

ALTER TABLE vehicle_brand
ADD FOREIGN KEY (fk_nit_dealership) REFERENCES dealership(nit_dealership);

ALTER TABLE vehicle_type
ADD fk_id_vehicle_color INT NOT NULL DEFAULT 1,
ADD FOREIGN KEY (fk_id_vehicle_color) REFERENCES vehicle_color(id_vehicle_color),
ADD FOREIGN KEY (fk_id_vehicle_brand) REFERENCES vehicle_brand (id_vehicle_brand);

ALTER TABLE dealership_insurer
ADD FOREIGN KEY (fk_id_vehicle_insurer) REFERENCES vehicle_insurer (id_vehicle_insurer),
ADD FOREIGN KEY (fk_nit_dealership) REFERENCES dealership (nit_dealership);

ALTER TABLE branch
ADD COLUMN fk_nit_dealership INT NOT NULL,
ADD FOREIGN KEY (fk_nit_dealership) REFERENCES dealership (nit_dealership);

-- a toda persona se le asigna una dirección
ALTER TABLE person ADD fk_address INT NOT NULL,
ADD FOREIGN KEY (fk_address) REFERENCES address(id_address);



# ===============================================================================
#CREAR REGISTROS
# ===============================================================================
INSERT INTO city(city_name) 
VALUES("Manizales"), ("Armenia"), ("Pereira");

INSERT INTO address(street_type, fk_code_city)
VALUES
('Avenida', 1),
('Carrera', 1),
('Avenida', 1),
('Avenida', 2),
('Calle', 3),
('Avenida', 1),
('Carrera', 1),
('Avenida', 1),
('Avenida', 2),
('Calle', 3);

INSERT INTO dealership(nit_dealership, dealership_name)
VALUES 
(111, 'Mazda'),
(222, 'Ford'),
(333, 'Nizan');

#Le asociamos a la concesionaria de Mazda la sucursal Colautos
INSERT INTO branch (branch_name, fk_id_address, fk_nit_dealership)
VALUES 
("Colautos", 1, 111),
("Central Ford", 2, 222),
("Casa Real", 3, 333);

#Creamos 3 personas asociadas a la sucursal Colautos
INSERT INTO person 
(person_name, lastname, document, email, fk_code_branch, age, fk_address)
VALUES
("Jacinto", "Murillo", "105388778", "murillo@gmail.com", 1, 32, 4),
("Lola", "Mento", "105388777", "lolamento@gmail.com", 1, 27, 5),
("Marco", "De la Puerta", "105388776", "marco_puerta@gmail.com", 1, 57, 6),
("Rogelio", "Tapasco", "105388775","tapasco@gmail.com", 1, 28, 7),
("Andres", "Londoño", "105388774", "andres@gmail.com", 1, 26, 8),
("Camilo", "Amdé", "10072342", "cami@gmail.com", 3, 32, 9),
("Martha", "Torres", "19923213", "matha@gmail.com", 3, 27, 10),
("Ernesto", "Egildo", "100023123", "ernesto@gmail.com", 3, 57, 4),
("Martín", "Zuares", "1223456987","martin@gmail.com", 3, 28, 5),
("Clemencia", "Mendoza", "1223565786", "clem@gmail.com", 3, 26, 6),
("Rey", "Medina", "1223456788", "rey@gmail.com", 2, 32, 7),
("Andrea", "Murillo", "1004321234", "andrea@gmail.com", 2, 27, 8),
("Roy", "Medina", "1004982123", "roy@gmail.com", 2, 57, 9),
("Angi", "Rubiano", "1002345678","angi@gmail.com", 2, 28, 10),
("Helen", "Chufe", "1003493211", "helen@gmail.com", 2, 26, 4);

#Creamos como asesor a la persona con id 1 que en este caso es Jacinto
INSERT INTO advisor(fk_id_person) VALUES
(16),
(17);
-- INSERT INTO advisor(fk_id_person) VALUES(6);

#Al asesor Jacinto le asociamos dos clientes: a Lola y a Marco
INSERT INTO client_p(fk_id_person, fk_id_advisor, expiration_date_license)
VALUES
(18,2, "2026-12-31"),
(19,2, "2030-12-31"),
(20,2, "2026-12-31"),
(21,1, "2030-12-31"),
(22,1, "2026-12-31"),
(23,1, "2030-12-31"),
(24,1, "2026-12-31"),
(25,1, "2030-12-31"),
(26,1, "2026-12-31"),
(27,1, "2030-12-31"),
(28,1, "2026-12-31"),
(29,1, "2030-12-31"),
(30,1, "2030-12-31");

-- marca de vehículo asociada a una concesionaria
INSERT INTO vehicle_brand (vehicle_brand,original_country,fk_nit_dealership)
VALUES
('Mazda', 'USA', 111),
('Ford', 'USA', 222),
('BMW', 'USA', 333),
('Honda', 'USA', 111),
('Hyundai', 'USA', 111);

INSERT INTO vehicle_color(vehicle_color_name)
VALUES
('Rojo Ruby'),
('Verde Escarlata'),
('Azul Mar'),
('Verde Botella'),
('Amarillo'),
('Violeta'),
('Gris Pata'),
('Dorado');

INSERT INTO vehicle_type(vehicle_type, model, chassis_vehicule, fk_id_vehicle_brand, fk_id_vehicle_color)
VALUES
('Descapotable', 1,'MultiVolumen', 1, 1),
('Deportivo', 1,'Cuatro Puertas', 2, 2),
('Familiar', 1,'Dos Volumenes', 1, 3),
('Carguero', 1,'Tres Volumenes', 3, 4),
('Bronco Spor 4x4', 1,'Varios volúmenes', 2, 5);


INSERT INTO purchase_receipt(purchase_receipt_date, unit_price, tuition_value, total,
    fk_id_vehicle_type, fk_id_advisor, fk_id_client)
VALUES
('2022-02-14', 8000000, 3456, 97500000, 3, 1, 8),
('2021-07-18', 70000000, 1234, 70200000, 1, 1, 1),
('2021-07-23', 80000000, 3452, 80200000, 1, 1, 2),
('2022-02-12', 9000000, 5678, 97500000, 3, 1, 3),
('2021-07-18', 70000000, 5423, 70200000, 3, 1, 5),
('2021-07-23', 80000000, 9765, 80200000, 3, 1, 6),
('2021-05-12', 9000000, 4566, 97500000, 5, 1, 7),
('2021-08-12', 9000000, 1121, 97500000, 2, 1, 8),
('2021-08-12', 9000000, 2434, 97500000, 2, 1, 9),
('2021-07-18', 70000000, 4345, 70200000, 5, 1, 10),
('2021-12-23', 80000000, 8442, 80200000, 4, 2, 11),
('2021-05-12', 9000000, 3234, 97500000, 5, 2, 12),
('2021-06-12', 9000000, 9564, 97500000, 5, 2, 13);


INSERT INTO vehicle_insurer(vehicle_insurer)
VALUES
('Zura'),
('Mapfre'),
('Seguros Mundial');


INSERT INTO dealership_insurer(fk_nit_dealership, fk_id_vehicle_insurer)
VALUES
(111, 1),
(111, 2),
(111, 3),
(222, 1),
(222, 2),
(222, 3),
(333, 1),
(333, 2),
(333, 3);


INSERT insurance_types( insurance_types, insurance_value, inception_date, fk_id_vehicle_insurer, fk_id_vehicle_type )
VALUES
('Ordinario', 5000000, '2022-02-12', 1, 5),
('Pascua', 900000, '2022-03-15', 1, 5),
('Original', 2000000, '2022-02-12', 1, 5),
('Fin Año', 900000, '2022-03-15', 2, 1),
('Seguro Común', 1000000, '2022-02-12', 2, 2),
('Navideño', 900000, '2022-03-15', 2, 3),
('Descuento Doble', 1700000, '2022-01-22', 3, 3),
('Dos por Uno', 1500000, '2022-01-12', 3, 4),
('Cuotas', 2000000, '2022-04-12', 3, 4),
('Corto plazo', 500000, '2022-02-25', 2, 1);


# ===============================================================================
#ELIMINAR TABLAS
# ===============================================================================

DROP TABLE purchase_receipt;
DROP TABLE advisor;
DROP TABLE insurance_types;
DROP TABLE client_p;
DROP TABLE person;


# ===============================================================================
#RESTRICCIONES
# ===============================================================================

#Restriccion 1: 
#La fecha de vencimiento de la licencia debe ser mayor a la fecha actual
ALTER TABLE client_p
ADD CONSTRAINT CHK_expiration_date_license 
CHECK (YEAR(expiration_date_license) > YEAR(SYSDATE()));

#Restriccion 2: 
#La persona tanto de tipo asesor como tipo cliente, debe ser mayor de edad
ALTER TABLE person
ADD CONSTRAINT CHK_age CHECK(age >= 18);

#Eliminar una constraint
ALTER TABLE purchase_receipt
DROP CHK_unit_price;

#Restriccion 3: Precio del vehiculo estableciendo un rango de valores
ALTER TABLE purchase_receipt
ADD CONSTRAINT CHK_unit_price
CHECK (unit_price >10000000 AND unit_price <450000000);