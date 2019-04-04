CREATE OR REPLACE FUNCTION dades_treballador (salari REAL)
  RETURNS setof VARCHAR AS
$BODY$
DECLARE
  cognoms comercial.treballadors.cognom%TYPE;
  curs1 CURSOR FOR SELECT treballadors.cognom FROM comercial.treballadors
                   WHERE treballadors.sou > salari;

BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO cognoms;
    EXIT WHEN NOT FOUND;
    RETURN NEXT cognoms;
  END LOOP;
  close curs1;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT * FROM comercial.treballadors;

SELECT dades_treballador(500);

--segona funció
CREATE OR REPLACE FUNCTION dades_treballador (nomtreb VARCHAR)
  RETURNS setof VARCHAR AS
$BODY$
DECLARE
  cognoms comercial.treballadors.cognom%TYPE;
  curs1 CURSOR FOR SELECT treballadors.cognom FROM comercial.treballadors
                   WHERE treballadors.nom = nomtreb;
BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO cognoms;
    EXIT WHEN NOT FOUND;
    RETURN NEXT cognoms;
  END LOOP;
  close curs1;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT dades_treballador('Paula');

--Activitat 2
CREATE TYPE tinfo AS (
  nom_mon character varying(20),
  cog_mon character varying(30),
  sou_mon real,
  email character varying(30));

CREATE OR REPLACE FUNCTION sous_treballadors (salari REAL)
  RETURNS setof tinfo AS
$BODY$
DECLARE
  informa tinfo;
  curs1 CURSOR FOR SELECT treballadors.nom, treballadors.cognom, treballadors.sou,
                          treballadors.email FROM comercial.treballadors
                   WHERE treballadors.sou >= salari;
BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO informa;
    EXIT WHEN NOT FOUND;
    RETURN NEXT informa;
  END LOOP;
  close curs1;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT sous_treballadors (1800);
DROP type uinfo cascade ;

SELECT * FROM comercial.treballadors;

CREATE TYPE uinfo AS (
  nom_mon character varying(20),
  cog_mon character varying(30));

CREATE OR REPLACE FUNCTION usuaris_inscripcions()
  RETURNS setof uinfo AS
$BODY$
DECLARE
  informa uinfo;
  curs1 CURSOR FOR SELECT usuaris.nom, usuaris.cognom FROM comercial.usuaris
                   WHERE usuaris.id_usuari IN (SELECT inscripcio.id_usuari FROM comercial.inscripcio
                                               GROUP BY inscripcio.id_usuari HAVING COUNT(inscripcio.id_act) > 2);
BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO informa;
    EXIT WHEN NOT FOUND;
    RETURN NEXT informa;
  END LOOP;
  close curs1;
end;
$BODY$
  LANGUAGE plpgsql;

SELECT usuaris_inscripcions();
DROP TYPE t_usuari CASCADE;

CREATE TYPE t_usuari AS (
  id_user VARCHAR(20),
  nom_user VARCHAR(20),
  cognom_user VARCHAR(40),
  email_user VARCHAR(50)
  );

CREATE OR REPLACE FUNCTION primers_usuaris()
  RETURNS setof t_usuari AS
$BODY$
DECLARE
  usuari  t_usuari;
  numero integer;
  curs1 CURSOR FOR SELECT id_usuari, nom, cognom, email
                   FROM comercial.usuaris ORDER BY id_usuari ;
BEGIN
  OPEN curs1;
  FOR numero IN 1..3 LOOP
    FETCH curs1 INTO usuari;
    EXIT WHEN NOT FOUND;
    RETURN next usuari;
  end LOOP;
  close curs1;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT primers_usuaris();
DROP FUNCTION  compta_activitats ();

SELECT id_usuari,nom,cognom,email  FROM comercial.usuaris;

CREATE OR REPLACE FUNCTION primers_usuaris(num INTEGER)
  RETURNS setof t_usuari AS
$BODY$
DECLARE
  usuari  t_usuari;
  numero integer;
  curs1 CURSOR FOR SELECT id_usuari, nom, cognom, email
                   FROM comercial.usuaris ORDER BY id_usuari ;
BEGIN
  OPEN curs1;
  FOR numero IN 1..num LOOP
    FETCH curs1 INTO usuari;
    EXIT WHEN NOT FOUND;
    RETURN next usuari;
  end LOOP;
  close curs1;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT primers_usuaris();
SELECT primers_usuaris(1);
SELECT primers_usuaris(10);

CREATE OR REPLACE FUNCTION compta_activitats (identif comercial.activitats.id_activitat
  %type) RETURNS integer AS $$
DECLARE
  quantitat integer;
BEGIN
  IF identif IS NULL THEN
    SELECT COUNT(*) INTO quantitat
    FROM comercial.activitats
    WHERE preu < 65;
  ELSE
    SELECT COUNT(*) INTO quantitat
    FROM comercial.activitats
    WHERE id_activitat < identif
      AND preu < 65;
  END IF;
  RETURN quantitat;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION compta_activitats () RETURNS VARCHAR(100) AS $$
DECLARE
BEGIN
  RETURN 'Si us plau, introduixi una activitat';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION inscripcions_activitats (identif comercial.activitats.id_activitat%type)
  RETURNS varchar(70) AS $$
DECLARE
  missatge varchar(70);
  quantitat integer;
BEGIN
  SELECT COUNT(*) INTO quantitat
  FROM comercial.inscripcio
  WHERE id_act = identif;
  IF (quantitat = 1) THEN missatge = 'D''aquesta activitat només hi ha una inscripció';
  ELSIF ((quantitat >= 1 ) AND (quantitat <= 4)) THEN missatge = 'D''aquesta activitat
hi ha menys de 5 inscripcions';
  ELSIF (quantitat >4) THEN missatge = 'D''aquesta activitat hi ha 5 o més inscripcions';
  END IF;
  RETURN missatge;
END;
$$ LANGUAGE plpgsql;

SELECT compta_activitats(NULL);
SELECT * FROM comercial.activitats;
SELECT * FROM comercial.inscripcio;
SELECT inscripcions_activitats(5);
--
CREATE OR REPLACE FUNCTION inscripcions_activitats (identif comercial.activitats.id_activitat%type)
  RETURNS varchar(100) AS $$
DECLARE
  quantitat INTEGER;
  m1 TEXT = 'Si us plau, introduixi una activitat que no sigui null';
  m2 TEXT = 'L’activitat que ens han passat com a paràmetre no existeix.';
  m3 TEXT = 'No hi ha cap inscripció d’aquesta activitat.';
BEGIN
  SELECT COUNT(*) INTO quantitat
  FROM comercial.inscripcio
  WHERE id_act = identif;

  IF identif IS NULL
  THEN RETURN m1;

  ELSEIF (identif < 0)
  THEN RAISE EXCEPTION 'Les activitats no poden ser inferiors a zero';

  ELSEIF  ((SELECT id_activitat FROM comercial.activitats WHERE id_activitat=identif) IS NULL)
  THEN RETURN m2;

  ELSEIF (quantitat = 0)
  THEN RETURN m3;

  ELSIF (quantitat = 1)
  THEN RETURN 'D´aquesta activitat només hi ha una inscripció';

  ELSIF ((quantitat >= 1 ) AND (quantitat <= 4))
  THEN RETURN 'D´aquesta activitat hi ha menys de 5 inscripcions';

  ELSIF (quantitat >4)
  THEN RETURN 'D´aquesta activitat hi ha 5 o més inscripcions';

  END IF;
END;
$$ LANGUAGE plpgsql;

SELECT inscripcions_activitats(-1);


--Primerament es crea la taula treballadors_log amb els camps descrits en l’activitat 8:
CREATE TABLE comercial.treballadors_log (
  dni VARCHAR(10),
  usuari VARCHAR(20),
  hora TIMESTAMP,
  accio CHAR(15)
);
DROP TABLE comercial.treballadors_log;
DROP FUNCTION modific_treballador_log() CASCADE;

-- el codi de la funció modific_treballador_log() associada al disparador
CREATE OR REPLACE FUNCTION modific_treballador_log()
RETURNS TRIGGER AS $$
  BEGIN
    IF TG_OP = 'INSERT' THEN
      INSERT INTO comercial.treballadors_log VALUES
      (NEW.dni, CURRENT_USER, CURRENT_TIMESTAMP,TG_OP );
    END IF;
    IF TG_OP = 'DELETE' THEN
      INSERT INTO comercial.treballadors_log VALUES
      (OLD.dni,CURRENT_USER, CURRENT_TIMESTAMP,TG_OP);
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;

--Es crea el disparador audit_treballadors
CREATE TRIGGER  audit_treballadors AFTER
  INSERT OR DELETE ON comercial.treballadors
  FOR EACH ROW EXECUTE PROCEDURE modific_treballador_log();

--Joc de Proves
INSERT INTO comercial.treballadors VALUES
( '52604534w', 'Josep', 'Faneca Trilla', 'tècnic', 'joanmb@barcelonaenjoy.cat', 1250);


DELETE FROM comercial.treballadors WHERE comercial.treballadors.dni = '52604534w';

SELECT * FROM comercial.treballadors_log;












