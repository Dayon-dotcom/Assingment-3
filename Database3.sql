CREATE DATABASE energy_company;



USE energy_company;


-- Table 1 is countries
-- Geogarphic table

CREATE TABLE countries (
countrycode VARCHAR(3) PRIMARY KEY,
countryname VARCHAR(100),
continent VARCHAR(50)

);

-- Table 2 operators
-- Manage operating systems

CREATE TABLE operators (
operatorid INT PRIMARY KEY,
operatorname VARCHAR(100),
headquaterscountry VARCHAR(3),
 FOREIGN KEY (headquaterscountry)
 REFERENCES countries (countrycode)
 );
 
 -- Table 3 fuel_types
 -- the energy soucrces
 
 CREATE TABLE fuel_types (
 fuelid INT PRIMARY KEY,
 fuelcategory VARCHAR(50),
 fuelname VARCHAR(50)
 );
 
 -- Table 4 power_plants
 -- linking the location and other things
 
 CREATE TABLE power_plants (
 plantid INT PRIMARY KEY,
 plantname VARCHAR(150),
 countrycode VARCHAR(3),
 operatorid INT,
 fuelid INT,
 capacitymw INT,
 commissionyear INT,
 
 FOREIGN KEY (countrycode)
	REFERENCES countries(countrycode),
    
 FOREIGN KEY (operatorid)
	REFERENCES operators(operatorid),
    
 FOREIGN KEY (fuelid)
	REFERENCES fuel_types(fuelid)

 );
 
 CREATE TABLE generation_records (
 plantid INT,
 year INT,
 generationgwh DECIMAL (12,2),
 
 PRIMARY KEY (plantid,year),
 
 FOREIGN KEY (plantid)
	REFERENCES power_plants(plantid)
    );
    
    CREATE TABLE emission_metric (
    plantid INT,
    year INT,
    co2emissionstonnes DECIMAL (15,2), 
    
    PRIMARY KEY (plantid, year),
    
    FOREIGN KEY (plantid)
    REFERENCES power_plants(plantid)
    );
    -- Query 1

SELECT 
    power_plants.plantname,
    countries.countryname,
    operators.operatorname,
    fuel_types.fuelcategory,
    fuel_types.fuelname,
    power_plants.capacitymw,
    power_plants.commissionyear
FROM power_plants
JOIN countries 
    ON power_plants.countrycode = countries.countrycode
JOIN operators 
    ON power_plants.operatorid = operators.operatorid
JOIN fuel_types 
    ON power_plants.fuelid = fuel_types.fuelid
ORDER BY power_plants.capacitymw DESC;


-- Query 2

SELECT 
    power_plants.plantname,
    power_plants.countrycode,
    generation_records.year,
    generation_records.generationgwh
FROM power_plants
JOIN generation_records 
    ON power_plants.plantid = generation_records.plantid
WHERE generation_records.year = 2024
ORDER BY generation_records.generationgwh DESC;


-- Query 3

SELECT 
    power_plants.plantname,
    power_plants.countrycode,
    generation_records.year,
    generation_records.generationgwh,
    emission_metrics.co2emissionstonnes
FROM power_plants
JOIN generation_records 
    ON power_plants.plantid = generation_records.plantid
JOIN emission_metrics 
    ON power_plants.plantid = emission_metrics.plantid 
    AND generation_records.year = emission_metrics.year
WHERE generation_records.year = 2024
ORDER BY emission_metrics.co2emissionstonnes ASC;


-- Query 4

WITH operator_generation (operatorid, total_generation) AS (
    SELECT 
        power_plants.operatorid,
        SUM(generation_records.generationgwh)
    FROM power_plants
    JOIN generation_records 
        ON power_plants.plantid = generation_records.plantid
    GROUP BY power_plants.operatorid
)
SELECT 
    operators.operatorname,
    operators.headquarterscountry,
    operator_generation.total_generation
FROM operators
JOIN operator_generation 
    ON operators.operatorid = operator_generation.operatorid
ORDER BY operator_generation.total_generation DESC;


-- Query 5
WITH country_generation (countrycode, total_generation) AS (
    SELECT 
        power_plants.countrycode,
        SUM(generation_records.generationgwh)
    FROM power_plants
    JOIN generation_records 
        ON power_plants.plantid = generation_records.plantid
    GROUP BY power_plants.countrycode
),
country_emissions (countrycode, total_emissions) AS (
    SELECT 
        power_plants.countrycode,
        SUM(emission_metrics.co2emissionstonnes)
    FROM power_plants
    JOIN emission_metrics 
        ON power_plants.plantid = emission_metrics.plantid
    GROUP BY power_plants.countrycode
)
SELECT 
    countries.countryname,
    country_generation.total_generation,
    country_emissions.total_emissions
FROM countries
JOIN country_generation 
    ON countries.countrycode = country_generation.countrycode
JOIN country_emissions 
    ON countries.countrycode = country_emissions.countrycode
ORDER BY country_generation.total_generation DESC;countriesemission_metrics
    
    
    
 



