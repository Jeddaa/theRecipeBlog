CREATE TABLE animals(
id INT GENERATED ALWAYS AS IDENTITY,
name VARCHAR,
date_of_birth DATE,
escape_attempts INT,
neutered BOOLEAN,
weight_kg DECIMAL
);

INSERT INTO animals (name, date_of_birth, escape_attempts, neutered, weight_kg) VALUES
('Agumon', '2020-02-03', null, TRUE, 10.23),
('Gabumon', '2018-11-15', 2, TRUE, 8),
('Pikachu', '2021-01-07', 1, FALSE, 15.04),
('Devimon', '2017-05-12', 5, TRUE, 11);

-- Find all animals whose name ends in "mon".
SELECT * FROM animals WHERE name LIKE '%mon';

-- List the name of all animals born between 2016 and 2019.
SELECT * FROM animals WHERE EXTRACT (YEAR FROM date_of_birth) >= 2016 AND EXTRACT (YEAR FROM date_of_birth) <= 2019;

-- List the name of all animals that are neutered and have less than 3 escape attempts.
SELECT * FROM animals WHERE neutered=TRUE AND escape_attempts < 3;

-- List the date of birth of all animals named either "Agumon" or "Pikachu".
SELECT name, date_of_birth FROM animals WHERE name = 'Agumon' OR name = 'Pikachu';

-- List name and escape attempts of animals that weigh more than 10.5kg
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;

-- Find all animals that are neutered.
SELECT * FROM animals WHERE neutered = TRUE;

-- Find all animals not named Gabumon.
SELECT * FROM animals WHERE name != 'Gabumon';

-- Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg)
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

-- Add a column species of type string to your animals table
ALTER TABLE animals ADD COLUMN species VARCHAR;

INSERT INTO animals (name, date_of_birth, escape_attempts, neutered, weight_kg) VALUES
('Charmander', '2020-02-08', null, FALSE, -11),
('Plantmon', '2021-11-15', 2, TRUE, -5.7),
('Squirtle', '1993-04-02', 3, FALSE, -12.13),
('Angemon', '2005-06-12', 1, TRUE, -45),
('Boarmon', '2005-06-07', 7, TRUE, 20.4),
('Blossom', '1998-10-13', 3, TRUE, 17),
('Ditto', '2022-05-14', 4, TRUE, 22);

-- Inside a transaction update the animals table by setting the species column to unspecified.
BEGIN;
UPDATE animals SET species = 'unspecified';

-- Verify that change was made.
SELECT * FROM animals;

-- Then roll back the change
ROLLBACK;

-- and verify that the species columns went back to the state before the transaction.
SELECT * FROM animals;

-- Inside a transaction:
BEGIN;

-- Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';

-- Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;

-- Verify that changes were made.
SELECT * FROM animals;

Commit the transaction.
COMMIT;

-- Verify that changes persist after commit.
SELECT * FROM animals;

-- Now, take a deep breath and... Inside a transaction delete all records in the animals table
BEGIN;
DELETE FROM animals;

-- then roll back the transaction.
ROLLBACK;

-- After the rollback verify if all records in the animals table still exists. After that, you can start breathing as usual
SELECT * FROM animals;


-- Inside a transaction:
BEGIN;

-- Delete all animals born after Jan 1st, 2022.
DELETE FROM animals WHERE date_of_birth > '2022-01-01';

-- Create a savepoint for the transaction.
SAVEPOINT TESTING;

-- Update all animals' weight to be their weight multiplied by -1.
UPDATE animals SET weight_kg = weight_kg * -1;

-- Rollback to the savepoint
ROLLBACK TO TESTING;

-- Update all animals' weights that are negative to be their weight multiplied by -1.
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 1;

-- Commit transaction
COMMIT;

-- How many animals are there?
SELECT COUNT(*) AS total_number_of_animals FROM animals;

-- How many animals have never tried to escape?
SELECT COUNT(name) AS number_animals_never_tried_escape FROM animals WHERE escape_attempts IS null;

-- What is the average weight of animals?
SELECT AVG(weight_kg) AS avg_weight FROM animals;
-- to 2 decimal places
SELECT CAST(AVG(weight_kg) AS DECIMAL(10,2)) AS avg_weight FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) FROM animals GROUP BY neutered;
SELECT neutered, AVG(escape_attempts) FROM animals GROUP BY neutered;

-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY species;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) FROM animals WHERE EXTRACT(YEAR from date_of_birth) BETWEEN 1990 and 2000 GROUP BY species;
-- cast to 2 decimal places
SELECT species, CAST(AVG(escape_attempts) AS DECIMAL(10, 2)) AS avg FROM animals WHERE EXTRACT(YEAR FROM date_of_birth) BETWEEN 1990 AND 2000 GROUP BY species;

CREATE TABLE owners (
  id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  full_name VARCHAR,
  age INT
);

CREATE TABLE species(
  id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR
);

-- Modify animals table:
-- Make sure that id is set as autoincremented PRIMARY KEY
ALTER TABLE animals
ADD CONSTRAINT animals_pkey PRIMARY KEY(id);

-- Remove column species
-- Add column species_id which is a foreign key referencing species table
-- Add column owner_id which is a foreign key referencing the owners table
ALTER TABLE animals
DROP COLUMN species,
ADD COLUMN species_id INT,
ADD FOREIGN KEY(species_id) REFERENCES species,
ADD COLUMN owner_id INT,
ADD FOREIGN KEY(owner_id) REFERENCES owners;

INSERT INTO owners (full_name, age) VALUES
('Sam Smith', 34),
('Jennifer Orwell', 19),
('Bob', 45),
('Melody Pond', 77),
('Dean Winchester', 14),
('Jodie Whittaker', 38);

INSERT INTO species (name) VALUES
('Pokemon'),
('Digimon');

-- Modify your inserted animals so it includes the species_id value:
-- If the name ends in "mon" it will be Digimon
Update animals SET species_id = (SELECT id from species WHERE name= 'Digimon') WHERE name LIKE '%mon';
Update animals SET species_id = 2 WHERE name LIKE '%mon';

-- All other animals are Pokemon
UPDATE animals SET species_id = (SELECT id FROM species WHERE name = 'Pokemon') WHERE name NOT LIKE '%mon';
Update animals SET species_id = 1 WHERE species_id IS null;

-- Modify your inserted animals to include owner information (owner_id):
-- Sam Smith owns Agumon.
UPDATE animals SET owner_id = (SELECT id FROM owners WHERE full_name = 'Sam Smith') WHERE name = 'Agumon';

-- Jennifer Orwell owns Gabumon and Pikachu.
UPDATE animals SET owner_id = (SELECT id FROM owners WHERE full_name = 'Jennifer Orwell') WHERE name IN ('Gabumon', 'Pikachu');

-- Bob owns Devimon and Plantmon.
UPDATE animals SET owner_id = (SELECT id FROM owners WHERE full_name = 'Bob') WHERE name IN ('Devimon', 'Plantmon');

-- Melody Pond owns Charmander, Squirtle, and Blossom.
UPDATE animals SET owner_id = (SELECT id FROM owners WHERE full_name = 'Melody Pond') WHERE name IN ('Charmander', 'Squirtle', 'Blossom');

-- Dean Winchester owns Angemon and Boarmon.
UPDATE animals SET owner_id = (SELECT id FROM owners WHERE full_name = 'Dean Winchester') WHERE name IN ('Angemon', 'Boarmon');

-- What animals belong to Melody Pond?
SELECT owners.full_name, animals.* FROM owners JOIN animals ON owners.id = animals.owner_id WHERE owners.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT species.name, animals.* FROM animals JOIN species ON animals.species_id = species.id WHERE species.name = 'Pokemon';

-- List all owners and their animals, remember to include those that don't own any animal.
SELECT animals.name, owners.full_name FROM animals FULL JOIN owners ON animals.owner_id = owners.id;

-- How many animals are there per species?
SELECT species.name, COUNT(animals.name) FROM animals JOIN species ON species.id = animals.species_id GROUP BY species.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT animals.name AS animal_name,  species.name AS specie_name, owners.full_name AS owner_name FROM animals
JOIN species ON animals.species_id = species.id
JOIN owners ON owners.id = animals.owner_id
WHERE species.name = 'Digimon' AND owners.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT owners.full_name, animals.name, animals.escape_attempts FROM owners
JOIN animals ON owners.id = animals.owner_id
WHERE owners.full_name = 'Dean Winchester' AND animals.escape_attempts IS NULL;

-- Who owns the most animals?
SELECT owners.full_name, COUNT(animals.name) AS total_number_of_animals
FROM owners JOIN animals ON owners.id = animals.owner_id
GROUP BY owners.full_name
ORDER BY total_number_of_animals DESC
LIMIT 1;

CREATE TABLE vets (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR,
  age INT,
  date_of_graduation DATE
);

CREATE TABLE specializations(
  vets_id INT,
  species_id INT,
  PRIMARY KEY(vets_id, species_id),
  FOREIGN KEY (vets_id) REFERENCES vets(id),
  FOREIGN KEY (species_id) REFERENCES species(id)
);

CREATE TABLE visits(
  animals_id INT,
  vets_id INT,
  visit_date DATE,
  FOREIGN KEY (animals_id) REFERENCES animals(id),
  FOREIGN KEY (vets_id) REFERENCES vets(id)
);

INSERT INTO vets(name, age, date_of_graduation) VALUES
('William Tatcher', 45, '2000-04-03'),
('Maisy Smith', 26, '2019-01-17'),
('Stephanie Mendez', 64, '1981-05-04'),
('Jack Harkness', 38, '2008-06-08');

INSERT INTO specializations (vets_id, species_id) VALUES
((SELECT id FROM vets WHERE name = 'William Tatcher'), (SELECT id FROM species WHERE name = 'Pokemon')),
((SELECT id FROM vets WHERE name = 'Stephanie Mendez'), (SELECT id FROM species WHERE name = 'Digimon')),
((SELECT id FROM vets WHERE name = 'Stephanie Mendez'), (SELECT id FROM species WHERE name = 'Pokemon')),
((SELECT id FROM vets WHERE name = 'Jack Harkness'), (SELECT id FROM species WHERE name = 'Digimon'));

-- either insert using this method:
INSERT INTO visits (animals_id, vets_id, visit_date) VALUES
((SELECT id FROM animals WHERE name = 'Agumon'), (SELECT id FROM vets WHERE name = 'William Tatcher'), '2020-05-24'),
((SELECT id FROM animals WHERE name = 'Agumon'), (SELECT id FROM vets WHERE name = 'Stephanie Mendez'), '2020-07-22'),
((SELECT id FROM animals WHERE name = 'Gabumon'), (SELECT id FROM vets WHERE name = 'Jack Harkness'), '2021-02-02'),
((SELECT id FROM animals WHERE name = 'Pikachu'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2020-01-05'),
((SELECT id FROM animals WHERE name = 'Pikachu'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2020-03-08'),
((SELECT id FROM animals WHERE name = 'Pikachu'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2020-05-14'),
((SELECT id FROM animals WHERE name = 'Devimon'), (SELECT id FROM vets WHERE name = 'Stephanie Mendez'), '2021-05-04'),
((SELECT id FROM animals WHERE name = 'Charmander'), (SELECT id FROM vets WHERE name = 'Jack Harkness'), '2021-02-24'),
((SELECT id FROM animals WHERE name = 'Plantmon'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2019-12-21'),
((SELECT id FROM animals WHERE name = 'Plantmon'), (SELECT id FROM vets WHERE name = 'William Tatcher'), '2020-08-10'),
((SELECT id FROM animals WHERE name = 'Plantmon'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2021-04-07'),
((SELECT id FROM animals WHERE name = 'Squirtle'), (SELECT id FROM vets WHERE name = 'Stephanie Mendez'), '2019-09-29'),
((SELECT id FROM animals WHERE name = 'Angemon'), (SELECT id FROM vets WHERE name = 'Jack Harkness'), '2020-10-03'),
((SELECT id FROM animals WHERE name = 'Angemon'), (SELECT id FROM vets WHERE name = 'Jack Harkness'), '2020-11-04'),
((SELECT id FROM animals WHERE name = 'Boarmon'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2019-01-24'),
((SELECT id FROM animals WHERE name = 'Boarmon'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2019-05-15'),
((SELECT id FROM animals WHERE name = 'Boarmon'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2020-02-27'),
((SELECT id FROM animals WHERE name = 'Boarmon'), (SELECT id FROM vets WHERE name = 'Maisy Smith'), '2019-08-03'),
((SELECT id FROM animals WHERE name = 'Blossom'), (SELECT id FROM vets WHERE name = 'Stephanie Mendez'), '2020-05-24'),
((SELECT id FROM animals WHERE name = 'Blossom'), (SELECT id FROM vets WHERE name = 'William Tatcher'), '2021-01-11');

-- or use this method to update all
WITH animal_ids AS (
    SELECT name, id FROM animals WHERE name IN ('Agumon', 'Gabumon', 'Pikachu', 'Devimon', 'Charmander', 'Plantmon', 'Squirtle', 'Angemon', 'Boarmon', 'Blossom')
),
vets_ids AS (
    SELECT name, id FROM vets WHERE name IN ('William Tatcher', 'Stephanie Mendez', 'Jack Harkness', 'Maisy Smith')
)
INSERT INTO visits (animals_id, vets_id, visit_date) VALUES
((SELECT id FROM animal_ids WHERE name = 'Agumon'), (SELECT id FROM vets_ids WHERE name = 'William Tatcher'), '2020-05-24'),
((SELECT id FROM animal_ids WHERE name = 'Agumon'), (SELECT id FROM vets_ids WHERE name = 'Stephanie Mendez'), '2020-07-22'),
((SELECT id FROM animal_ids WHERE name = 'Gabumon'), (SELECT id FROM vets_ids WHERE name = 'Jack Harkness'), '2021-02-02'),
((SELECT id FROM animal_ids WHERE name = 'Pikachu'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2020-01-05'),
((SELECT id FROM animal_ids WHERE name = 'Pikachu'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2020-03-08'),
((SELECT id FROM animal_ids WHERE name = 'Pikachu'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2020-05-14'),
((SELECT id FROM animal_ids WHERE name = 'Devimon'), (SELECT id FROM vets_ids WHERE name = 'Stephanie Mendez'), '2021-05-04'),
((SELECT id FROM animal_ids WHERE name = 'Charmander'), (SELECT id FROM vets_ids WHERE name = 'Jack Harkness'), '2021-02-24'),
((SELECT id FROM animal_ids WHERE name = 'Plantmon'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2019-12-21'),
((SELECT id FROM animal_ids WHERE name = 'Plantmon'), (SELECT id FROM vets_ids WHERE name = 'William Tatcher'), '2020-08-10'),
((SELECT id FROM animal_ids WHERE name = 'Plantmon'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2021-04-07'),
((SELECT id FROM animal_ids WHERE name = 'Squirtle'), (SELECT id FROM vets_ids WHERE name = 'Stephanie Mendez'), '2019-09-29'),
((SELECT id FROM animal_ids WHERE name = 'Angemon'), (SELECT id FROM vets_ids WHERE name = 'Jack Harkness'), '2020-10-03'),
((SELECT id FROM animal_ids WHERE name = 'Angemon'), (SELECT id FROM vets_ids WHERE name = 'Jack Harkness'), '2020-11-04'),
((SELECT id FROM animal_ids WHERE name = 'Boarmon'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2019-01-24'),
((SELECT id FROM animal_ids WHERE name = 'Boarmon'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2019-05-15'),
((SELECT id FROM animal_ids WHERE name = 'Boarmon'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2020-02-27'),
((SELECT id FROM animal_ids WHERE name = 'Boarmon'), (SELECT id FROM vets_ids WHERE name = 'Maisy Smith'), '2019-08-03'),
((SELECT id FROM animal_ids WHERE name = 'Blossom'), (SELECT id FROM vets_ids WHERE name = 'Stephanie Mendez'), '2020-05-24'),
((SELECT id FROM animal_ids WHERE name = 'Blossom'), (SELECT id FROM vets_ids WHERE name = 'William Tatcher'), '2021-01-11');

-- Who was the last animal seen by William Tatcher?
SELECT vets.name AS vet_name, animals.name AS animal_name, visits.visit_date FROM animals
JOIN visits on visits.animals_id = animals.id
JOIN vets ON vets.id = visits.vets_id
WHERE vets.name = 'William Tatcher'
ORDER BY visit_date DESC
LIMIT 1;

-- How many different animals did Stephanie Mendez see?
SELECT COUNT(DISTINCT visits.animals_id) AS number_of_animals, vets.name FROM visits
JOIN vets ON visits.vets_id = vets.id
WHERE vets.name = 'Stephanie Mendez'
GROUP BY vets.name;

-- List all vets and their specialties, including vets with no specialties.
SELECT DISTINCT vets.name, species.name FROM vets
LEFT JOIN specializations ON specializations.vets_id = vets.id
LEFT JOIN species ON specializations.species_id = species.id;

-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT animals.name, visits.visit_date, vets.name FROM animals
JOIN visits ON visits.animals_id = animals.id
JOIN vets ON vets.id = visits.vets_id
WHERE vets.name = 'Stephanie Mendez' AND visits.visit_date BETWEEN '2020-04-01' AND '2020-08-30';

-- What animal has the most visits to vets?
SELECT animals.name, COUNT(visits.animals_id) AS no_of_visit FROM visits
JOIN animals ON visits.animals_id = animals.id
GROUP BY animals.name ORDER BY no_of_visit DESC LIMIT 1;

-- Who was Maisy Smith's first visit?
SELECT animals.name AS animal_name, visits.visit_date, vets.name AS vet_name FROM vets
JOIN visits ON visits.vets_id = vets.id
JOIN animals ON visits.animals_id = animals.id
WHERE vets.name = 'Maisy Smith'
ORDER BY visits.visit_date LIMIT 1;

-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT visits.visit_date, animals.name AS animal_name, animals.date_of_birth AS animal_dob, animals.escape_attempts, animals.neutered, vets.name AS vet_name, vets.date_of_graduation, vets.age AS vet_age FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN vets ON vets.id = visits.vets_id
ORDER BY visits.visit_date DESC LIMIT 1;

-- Details for visits were a vet did not specialize in that animal's species?
SELECT animals.name, vets.name, visits.visit_date FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN vets ON vets.id = visits.vets_id
JOIN species ON species.id = animals.species_id
LEFT JOIN specializations ON  specializations.vets_id = vets.id
AND specializations.species_id = species.id
WHERE specializations.vets_id IS NULL
ORDER BY visits.visit_date;

SELECT
    animals.name AS animal_name,
    species.name AS animal_species,
    vets.name AS vet_name,
    visits.visit_date
FROM visits
JOIN animals ON visits.animals_id = animals.id
JOIN species ON animals.species_id = species.id
JOIN vets ON visits.vets_id = vets.id
LEFT JOIN specializations ON specializations.vets_id = vets.id
                          AND specializations.species_id = species.id
WHERE specializations.vets_id IS NULL
ORDER BY visits.visit_date;

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(visits.visit_date) FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN species ON species.id = animals.species_id
JOIN vets ON vets.id = visits.vets_id
LEFT JOIN specializations ON vets.id = specializations.vets_id
AND species.id = specializations.species_id
WHERE specializations.vets_id IS NULL;

-- get all visits, animals, animal species, vet and vet specialisation
SELECT visits.visit_date, animals.name, species.name AS animals_specie, vets.name AS vet_name, STRING_AGG(vet_specializations.name, ', ') AS vet_specialization FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN species ON species.id = animals.species_id
JOIN vets ON vets.id = visits.vets_id
LEFT JOIN specializations ON vets.id = specializations.vets_id
LEFT JOIN species AS vet_specializations ON vet_specializations.id = specializations.species_id
GROUP BY visits.visit_date, animals.name, animals_specie, vet_name
ORDER BY visits.visit_date;

SELECT
    animals.name AS animal_name,
    animal_species.name AS animal_specie,
    vets.name AS vet_name,
    visits.visit_date,
    STRING_AGG(vet_specializations.name, ', ') AS vet_specialization
FROM visits
JOIN animals ON visits.animals_id = animals.id
JOIN species AS animal_species ON animal_species.id = animals.species_id
JOIN vets ON vets.id = visits.vets_id
LEFT JOIN specializations ON specializations.vets_id = vets.id
LEFT JOIN species AS vet_specializations ON vet_specializations.id = specializations.species_id
GROUP BY animals.name, animal_species.name, vets.name, visits.visit_date
ORDER BY visit_date;

-- how do i get all visits by an animal to a vet that is specialised in that animals specie
SELECT animals.name, species.name AS animal_species, vets.name AS vet_name, visits.visit_date FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN species ON species.id = animals.species_id
JOIN vets ON vets.id = visits.vets_id
JOIN specializations ON vets.id = specializations.vets_id
AND animals.species_id = specializations.species_id
ORDER BY visits.visit_date;

SELECT
    animals.name AS animal_name,
    species.name AS animal_species,
    vets.name AS vet_name,
    visits.visit_date
FROM visits
JOIN animals ON visits.animals_id = animals.id
JOIN species ON animals.species_id = species.id
JOIN vets ON visits.vets_id = vets.id
JOIN specializations ON specializations.vets_id = vets.id
                    AND specializations.species_id = species.id
ORDER BY visits.visit_date;

-- same as above but with the vet specialty
SELECT animals.name, species.name AS animal_species, vets.name AS vet_name, visits.visit_date, vet_specializations.name FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN species ON species.id = animals.species_id
JOIN vets ON vets.id = visits.vets_id
JOIN specializations ON vets.id = specializations.vets_id
AND animals.species_id = specializations.species_id
JOIN species AS vet_specializations ON vet_specializations.id = specializations.species_id
ORDER BY visits.visit_date;

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT species.name AS specie_name, COUNT(species.name) AS animals_specie_with_most_visit_to_maisy_smith FROM visits
JOIN animals ON animals.id = visits.animals_id
JOIN species ON species.id = animals.species_id
JOIN vets ON vets.id = visits.vets_id
WHERE vets.name = 'Maisy Smith'
GROUP BY specie_name
ORDER BY animals_specie_with_most_visit_to_maisy_smith DESC
LIMIT 1;

