-- Consultar los nombres completos y la dirección de su vivienda, de los clientes atendidos por
-- el empleado Jacinto durante el mes de febrero del año 2022.
SELECT cp.person_name, cp.lastname AS ' ', 
ad.street_type, ci.city_name FROM person AS cp
INNER JOIN client_p AS c
ON c.fk_id_person = cp.id_person
INNER JOIN advisor AS a
ON c.fk_id_advisor = a.id_advisor
INNER JOIN person AS ap
ON a.fk_id_person = ap.id_person
INNER JOIN purchase_receipt AS r
ON r.fk_id_client = c.id_client_p
INNER JOIN address AS ad
ON cp.fk_address = ad.id_address
INNER JOIN city as ci
ON ad.fk_code_city = ci.code_city
WHERE ap.person_name = 'Jacinto'
AND YEAR(r.purchase_receipt_date) = 2022
AND MONTH(r.purchase_receipt_date) = 2;

-- ---------------------------------------FIN UNO-----------------------------------------
-- ---------------------------------------------------------------------------------------

-- Consultar el color de carro más vendido de la marca Mazda durante el año 2022.

CALL color_vehicle_best_seller(2022, 12, "Mazda",1, @result);
SELECT @result AS "color vehículo";

-- ---------------------------------------------------------------------------------------
-- ---------------------------------------FIN DOS-----------------------------------------

-- Consultar la cantidad de vehículos que vendió Mazda en la sucursal situada en la ciudad de
-- Manizales durante el año 2021.

CALL calc_num_vehicles_year(2021, 12, "Manizales", "Mazda", @num);
SELECT @num AS "Número de vehículos";

-- ---------------------------------------------------------------------------------------
-- ---------------------------------------FIN TRES----------------------------------------

-- Consultar cuál fue el mes en el que Jacinto vendió más vehículos durante el segundo
-- semestre del año 2021.

CALL month_more_sales_second_semster_advisor("Jacinto", 2021, @mes);
SELECT @mes AS "número de més en el que mas vendió JACINTO";

-- ---------------------------------------------------------------------------------------
-- ---------------------------------------FIN CUATRO--------------------------------------

-- Cuál aseguradora de las que tiene convenio con la concesionaria Mazda, ofrecio el seguro
-- más costoso durante el primer trimestre del año 2022. La consulta debe mostrar el nombre
-- de la aseguradora, el costo del seguro contra todo riesgo, la placa del vehículo y el nombre
-- del cliente que adquirió el seguro.

CALL info_insurance(3, 2022, 'Mazda');

-- ---------------------------------------------------------------------------------------
-- ---------------------------------------FIN CINCO----------------------------------------

-- Consulta cual de las tres aseguradoras que tienen convenio con Ford para vehículos de uso
-- particular, ofrece un menor precio para el Bronco Sport 4x4 que adquirió Helen Chufe y cual
-- de las tres aseguradoras ofrece un mayor precio.

CALL insurer_more_less("Bronco Spor 4x4", "Mazda");

-- ---------------------------------------------------------------------------------------
-- ---------------------------------------FIN SEIS----------------------------------------