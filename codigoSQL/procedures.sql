DELIMITER $$
-- retorna el número de ventas de un tipo de vehículo registradas en un mes dado
CREATE PROCEDURE calc_num_vehicles_month_type(IN number_year INT, IN number_month INT,
IN vehicle_brand VARCHAR(30),IN vehicle_type VARCHAR(30), OUT result INT)
BEGIN
	SELECT COUNT(*) INTO result  FROM purchase_receipt AS r
    INNER JOIN vehicle_type AS v
	ON r.fk_id_vehicle_type = v.id_vehicle_type
	INNER JOIN vehicle_brand AS vb
	ON v.fk_id_vehicle_brand = vb.id_vehicle_brand
	WHERE
    vb.vehicle_brand = vehicle_brand
    AND
	MONTH(r.purchase_receipt_date) = number_month
    AND 
    YEAR(r.purchase_receipt_date) = number_year
    AND v.vehicle_type = vehicle_type;
END $$

DELIMITER $$
-- retorna el número de ventas de un typo de vehículo en los primeros n mese
CREATE PROCEDURE calc_num_vehicles_year_type(IN number_year INT, IN limit_month INT, 
IN vehicle_brand VARCHAR(30),IN vehicle_type VARCHAR(30), OUT result INT)
BEGIN
	SET @result=0;
    SET @month=1;
    WHILE @month <= limit_month DO
        call calc_num_vehicles_month_type(number_year, @month,vehicle_brand, vehicle_type, @num);
        SET @result := @result+@num;
        SET @month := @month+1;
	END WHILE;
    #SELECT @result;
    SELECT @result INTO result;
END $$

DELIMITER $$
-- retorna el color del carro más vendido en los primeros n meses de una marca dada
CREATE PROCEDURE color_vehicle_best_seller(IN number_year INT, IN limit_month INT, 
IN vehicle_brand VARCHAR(30),IN counter INT, OUT result VARCHAR(30))
BEGIN
    SET counter=0;
    SET @final="nada";
    SET @bandera=0;
    WHILE counter < (SELECT COUNT(*) FROM vehicle_type) DO
        SET @type=(
		SELECT vehicle_type FROM vehicle_type
        limit 1
        OFFSET counter
        );
		CALL calc_num_vehicles_year_type(number_year, limit_month, vehicle_brand, @type, @num);
        IF @num > @bandera THEN
			SET @bandera = @num;
			SET @final=(
				SELECT DISTINCT(vehicle_color_name) FROM vehicle_color AS vc
                INNER JOIN vehicle_type AS vt
                ON vt.fk_id_vehicle_color = vc.id_vehicle_color
				WHERE vt.vehicle_type = @type
				);
        END IF;
        SET counter := counter+1;
	END WHILE;
    SELECT @final INTO result;
END $$
-- ------------------------------------------------------------------------------------------------
-- ----------------------------------- HASTA AQUÍ EL PUTO DOS --------------------------------------
-- ------------------------------------------------------------------------------------------------


DELIMITER $$
-- retorna el número de ventas de una marca registradas en una ciudad en un mes
CREATE PROCEDURE calc_num_vehicles_month(IN number_year INT, 
IN number_month INT, IN city VARCHAR(30), IN vehicle_brand VARCHAR(30), 
OUT result INT)
BEGIN
	SELECT COUNT(*) INTO result  FROM purchase_receipt AS r
	INNER JOIN vehicle_type AS v
	ON r.fk_id_vehicle_type = v.id_vehicle_type
	INNER JOIN vehicle_brand AS vb
	ON v.fk_id_vehicle_brand = vb.id_vehicle_brand
	INNER JOIN dealership AS d
	ON vb.fk_nit_dealership = d.nit_dealership
	INNER JOIN branch AS b
	ON b.fk_nit_dealership = d.nit_dealership
	INNER JOIN address AS ad
	ON b.fk_id_address = ad.id_address
	INNER JOIN city as ci
	ON ad.fk_code_city = ci.code_city
	WHERE ci.city_name = city 
	AND
	vb.vehicle_brand = vehicle_brand
	AND 
	MONTH(r.purchase_receipt_date) = number_month
    AND YEAR(r.purchase_receipt_date) = number_year;
END $$

DELIMITER $$
-- retorna el número de ventas de una marca en los primeros n meses en determinada ciudad
CREATE PROCEDURE calc_num_vehicles_year(IN number_year INT, IN limit_month INT, 
IN city VARCHAR(30), IN vehicle_brand VARCHAR(30), OUT result INT)
BEGIN
	SET @result=0;
    SET @month=1;
    WHILE @month <= limit_month DO
        call calc_num_vehicles_month(number_year, @month, city, vehicle_brand, @num);
        SET @result := @result+@num;
        SET @month := @month+1;
	END WHILE;
    #SELECT @result;
    SELECT @result INTO result;
END $$
-- ------------------------------------------------------------------------------------------------
-- ----------------------------------- HASTA AQUÍ EL PUTO TRES --------------------------------------
-- ------------------------------------------------------------------------------------------------

DELIMITER $$
-- retorna el número de ventas hechas por un supervisor en un mes dado y año dado
CREATE PROCEDURE sales_advisor_month(IN advisor_name VARCHAR(50),
IN number_month INT, IN number_year INT, OUT result INT)
BEGIN
	SELECT COUNT(*) INTO result FROM purchase_receipt AS r
	INNER JOIN advisor AS a
	ON r.fk_id_advisor = a.id_advisor
	INNER JOIN person AS p
	ON a.fk_id_person = p.id_person
	WHERE 
    p.person_name = advisor_name
	AND 
    MONTH(r.purchase_receipt_date) = number_month
	AND 
    YEAR(r.purchase_receipt_date) = number_year;
END $$

DELIMITER $$
-- retorna el mes del segundo semestre en el que el supervisor dado vendió más
CREATE PROCEDURE month_more_sales_second_semster_advisor(IN advisor_name VARCHAR(50), IN number_year INT, 
OUT result INT)
BEGIN
	SET @counter=6;
    SET @greate=0;
    WHILE @counter <= 12 DO
		CALL sales_advisor_month(advisor_name, @counter, number_year, @sales);
        IF @sales > @greate THEN 
			SET @greate = @counter;
		END IF;
		SET @counter := @counter+1;
    END WHILE;
    SELECT @greate INTO result;
END $$

-- ------------------------------------------------------------------------------------------------
-- ----------------------------------- HASTA AQUÍ EL PUTO CUATRO --------------------------------------
-- ------------------------------------------------------------------------------------------------

DELIMITER $$
-- retorna el ID del insurance_type más vendido hasta el mes n asociado a un vehicle_insurer asociado a 
-- su vez a un dealership 
CREATE PROCEDURE insurer_cost_n_months(IN limit_month INT, IN number_year INT, 
IN dealership VARCHAR(30), OUT result INT)
BEGIN
	SET @counter=1;
    SET @final=0;
    SET @bandera=0;
	WHILE @counter <= limit_month DO 
		SET @id_insurance=(
		SELECT it.id_insurance_types FROM dealership AS d
		INNER JOIN dealership_insurer AS d_i
		ON d_i.fk_nit_dealership = d.nit_dealership
		INNER JOIN vehicle_insurer AS vi
		ON d_i.fk_id_vehicle_insurer = vi.id_vehicle_insurer
		INNER JOIN insurance_types AS it
		ON it.fk_id_vehicle_insurer = vi.id_vehicle_insurer
		WHERE MONTH(it.inception_date) = @counter
		AND
		YEAR(it.inception_date) = number_year
		AND d.dealership_name = dealership
		ORDER BY it.insurance_value DESC
		LIMIT 1
		);
        SET @value_insurance_month = (
			SELECT insurance_value FROM insurance_types
            WHERE id_insurance_types = @id_insurance
        );
        IF @value_insurance_month > @bandera THEN 
        SET @final = @id_insurance;
        SET @bandera = @value_insurance_month;
        END IF;
        SET @counter := @counter+1;
    END WHILE;
    SELECT @final INTO result;
END $$;

DELIMITER $$
-- hace la consulta de la concesionaria, cliente, placas, valor de seguro, del seguro más vendidio 
-- en el primer trimestre del 2022
CREATE PROCEDURE info_insurance(IN limit_month INT, IN number_year INT, IN dealership VARCHAR(30))
BEGIN
	CALL insurer_cost_n_months(limit_month, number_year, dealership, @result);
	SELECT DISTINCT it.insurance_types AS aseguradora, it.insurance_value AS "valor seguro", 
    r.tuition_value AS placas, p.person_name AS cliente FROM insurance_types AS it
    INNER JOIN vehicle_insurer AS vi
    ON it.fk_id_vehicle_insurer = vi.id_vehicle_insurer
    INNER JOIN dealership_insurer AS d_i
    ON d_i.fk_id_vehicle_insurer = vi.id_vehicle_insurer
    INNER JOIN dealership AS d
    ON d_i.fk_nit_dealership = d.nit_dealership
    INNER JOIN vehicle_type AS v
    ON it.fk_id_vehicle_type = v.id_vehicle_type
    INNER JOIN purchase_receipt AS r
    ON r.fk_id_vehicle_type = v.id_vehicle_type
    INNER JOIN client_p AS c
    ON r.fk_id_client = c.id_client_p
    INNER JOIN person AS p
    ON c.fk_id_person = p.id_person
    WHERE it.id_insurance_types = @result;
END $$

-- ------------------------------------------------------------------------------------------------
-- ----------------------------------- HASTA AQUÍ EL PUTO CINCO --------------------------------------
-- ------------------------------------------------------------------------------------------------

DELIMITER $$
-- retorna el id del seguro menos costoso para un tipo de vehículo de asociado a una concesionaria
CREATE PROCEDURE more_expensive_for_type_vehicle(IN type_vehicle VARCHAR(45), IN dealership VARCHAR(30), 
IN index_insurer_type INT,OUT result INT)
BEGIN
	SELECT it.id_insurance_types INTO result FROM dealership AS d 
	INNER JOIN dealership_insurer AS d_i
	ON d_i.fk_nit_dealership = d.nit_dealership
	INNER JOIN vehicle_insurer AS vi
	ON d_i.fk_id_vehicle_insurer  = vi.id_vehicle_insurer 
	INNER JOIN insurance_types AS it
	ON vi.id_vehicle_insurer = it.fk_id_vehicle_insurer
	INNER JOIN vehicle_type AS v
	ON it.fk_id_vehicle_type = v.id_vehicle_type
	WHERE v.vehicle_type = type_vehicle
    AND d.dealership_name = dealership
    ORDER BY it.insurance_value DESC
    LIMIT 1
    OFFSET index_insurer_type;
END $$

DELIMITER $$
-- retorna el id del seguro más costoso para un tipo de vehículo de asociado a una concesionaria
CREATE PROCEDURE less_expensive_for_type_vehicle(IN type_vehicle VARCHAR(45), IN dealership VARCHAR(30), 
IN index_insurer_type INT,OUT result INT)
BEGIN
	SELECT it.id_insurance_types INTO result FROM dealership AS d 
	INNER JOIN dealership_insurer AS d_i
	ON d_i.fk_nit_dealership = d.nit_dealership
	INNER JOIN vehicle_insurer AS vi
	ON d_i.fk_id_vehicle_insurer  = vi.id_vehicle_insurer 
	INNER JOIN insurance_types AS it
	ON vi.id_vehicle_insurer = it.fk_id_vehicle_insurer
	INNER JOIN vehicle_type AS v
	ON it.fk_id_vehicle_type = v.id_vehicle_type
	WHERE v.vehicle_type = type_vehicle
    AND d.dealership_name = dealership
    ORDER BY it.insurance_value
    LIMIT 1
    OFFSET index_insurer_type;
END $$


DELIMITER $$
-- consulta la aseguradora que ofrece el seguro más económico para un carro
-- consulta la aseguradora que ofrece el seguro más costoso para un carro
CREATE PROCEDURE insurer_more_less(IN type_vehicle VARCHAR(45), IN dealership VARCHAR(30))
BEGIN 
	CALL less_expensive_for_type_vehicle(type_vehicle, dealership, 0, @less_price);
    CALL more_expensive_for_type_vehicle(type_vehicle, dealership, 0, @more_price);
    
    SELECT vi.vehicle_insurer, insurance_value AS "Aseguradora menor ofrece valor" FROM vehicle_insurer AS vi
    INNER JOIN insurance_types AS it
    ON it.fk_id_vehicle_insurer = vi.id_vehicle_insurer
    WHERE it.id_insurance_types = @less_price;
    
    SELECT vi.vehicle_insurer, insurance_value AS "Aseguradora mayor ofrece valor" FROM vehicle_insurer AS vi
    INNER JOIN insurance_types AS it
    ON it.fk_id_vehicle_insurer = vi.id_vehicle_insurer
    WHERE it.id_insurance_types = @more_price;
END $$

-- ------------------------------------------------------------------------------------------------
-- ----------------------------------- HASTA AQUÍ EL PUTO SEIS --------------------------------------
-- ------------------------------------------------------------------------------------------------

