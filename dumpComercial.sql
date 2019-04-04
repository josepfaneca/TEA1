--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: comercial; Type: SCHEMA; Schema: -; Owner: master
--

CREATE SCHEMA comercial;


ALTER SCHEMA comercial OWNER TO master;

--
-- Name: t_usuari; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.t_usuari AS (
	id_user character varying(20),
	nom_user character varying(20),
	cognom_user character varying(40),
	email_user character varying(50)
);


ALTER TYPE public.t_usuari OWNER TO master;

--
-- Name: tinfo; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.tinfo AS (
	nom_mon character varying(20),
	cog_mon character varying(30),
	sou_mon real,
	email character varying(30)
);


ALTER TYPE public.tinfo OWNER TO master;

--
-- Name: uinfo; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.uinfo AS (
	nom_mon character varying(20),
	cog_mon character varying(30)
);


ALTER TYPE public.uinfo OWNER TO master;

--
-- Name: actualitzar_sou(character varying, numeric); Type: FUNCTION; Schema: comercial; Owner: master
--

CREATE FUNCTION comercial.actualitzar_sou(dni_empleat character varying, nou_sou numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
 
BEGIN
UPDATE comercial.treballadors SET sou=nou_sou WHERE dni=dni_empleat;
END;
$$;


ALTER FUNCTION comercial.actualitzar_sou(dni_empleat character varying, nou_sou numeric) OWNER TO master;

--
-- Name: compta_activitats(integer); Type: FUNCTION; Schema: comercial; Owner: master
--

CREATE FUNCTION comercial.compta_activitats(id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  num_act comercial.activitats.id_activitat%TYPE;
  price comercial.activitats.preu%TYPE;
BEGIN
  price = 65;
  IF (id IS NULL) THEN num_act=(SELECT COUNT(id_activitat) FROM comercial.activitats WHERE preu < price);
  ELSE num_act = (SELECT COUNT(id_activitat) FROM comercial.activitats WHERE id_activitat < id);

  END IF;
  RETURN num_act;
END;
$$;


ALTER FUNCTION comercial.compta_activitats(id integer) OWNER TO master;

--
-- Name: dades_treballador(character varying); Type: FUNCTION; Schema: comercial; Owner: master
--

CREATE FUNCTION comercial.dades_treballador(nomtreb character varying) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION comercial.dades_treballador(nomtreb character varying) OWNER TO master;

--
-- Name: esborra_activitat(integer); Type: FUNCTION; Schema: comercial; Owner: master
--

CREATE FUNCTION comercial.esborra_activitat(identificador integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
 
BEGIN
DELETE FROM comercial.activitats WHERE id_activitat=identificador;
END;
$$;


ALTER FUNCTION comercial.esborra_activitat(identificador integer) OWNER TO master;

--
-- Name: inscripcions_activitats(integer); Type: FUNCTION; Schema: comercial; Owner: master
--

CREATE FUNCTION comercial.inscripcions_activitats(id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  m1 CHAR(100);
  m2 CHAR(100);
  m3 CHAR(100);
  numInsc NUMERIC;
BEGIN
  m1 = 'D’aquesta activitat només hi ha una inscripció';
  m2 = 'D’aquesta activitat hi ha menys de 5 inscripcions';
  m3 = 'D’aquesta activitat hi ha 5 o més inscripcions';
  numInsc = (SELECT count(*) FROM comercial.inscripcio WHERE id_act = id GROUP BY id_act);
  IF numInsc = 1 THEN RETURN m1;
  ELSIF numInsc >= 1 AND numInsc <= 4 THEN RETURN m2;
  ELSIF numInsc >= 5 THEN RETURN m3;

  ELSE RETURN 'No hi han incripcions' ;
  END IF;
END;
$$;


ALTER FUNCTION comercial.inscripcions_activitats(id integer) OWNER TO master;

--
-- Name: compta_activitats(integer); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.compta_activitats(identif integer) RETURNS character
    LANGUAGE plpgsql
    AS $$
DECLARE
  quantitat INTEGER;
  m1 TEXT = 'Si us plau, introduixi una activitat que no sigui null';
  m2 TEXT = 'L’activitat que ens han passat com a paràmetre no existeix.';
  m3 TEXT = 'No hi ha cap inscripció d’aquesta activitat.';
BEGIN
  IF identif IS NULL THEN
    RETURN m1;
  ELSEIF  ((SELECT id_activitat FROM comercial.activitats WHERE id_activitat=identif) IS NULL)
  THEN
    RETURN m2;
  ELSEIF  ((SELECT COUNT(*)
            FROM comercial.activitats
            WHERE id_activitat < identif
              AND preu < 65) = 0)
  THEN
    RETURN m3;
  ELSE
    SELECT COUNT(*) INTO quantitat
    FROM comercial.activitats
    WHERE id_activitat < identif
      AND preu < 65;
  END IF;
  RETURN CAST (quantitat AS character);
END;
$$;


ALTER FUNCTION public.compta_activitats(identif integer) OWNER TO master;

--
-- Name: dades_treballador(real); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.dades_treballador(salari real) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.dades_treballador(salari real) OWNER TO master;

--
-- Name: dades_treballador(character varying); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.dades_treballador(nomtreb character varying) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.dades_treballador(nomtreb character varying) OWNER TO master;

--
-- Name: inscripcions_activitats(integer); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.inscripcions_activitats(identif integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.inscripcions_activitats(identif integer) OWNER TO master;

--
-- Name: modific_treballador_log(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.modific_treballador_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.modific_treballador_log() OWNER TO master;

--
-- Name: multiplica_num(numeric, numeric); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.multiplica_num(num1 numeric, num2 numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$BEGIN
RAISE notice '% * % = %', num1, num2, num1*num2;
RETURN  num1*num2;
END;
$$;


ALTER FUNCTION public.multiplica_num(num1 numeric, num2 numeric) OWNER TO master;

--
-- Name: primers_usuaris(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.primers_usuaris() RETURNS SETOF public.t_usuari
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.primers_usuaris() OWNER TO master;

--
-- Name: primers_usuaris(integer); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.primers_usuaris(num integer) RETURNS SETOF public.t_usuari
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.primers_usuaris(num integer) OWNER TO master;

--
-- Name: sous_treballadors(real); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.sous_treballadors(salari real) RETURNS SETOF public.tinfo
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.sous_treballadors(salari real) OWNER TO master;

--
-- Name: usuaris_inscripcions(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.usuaris_inscripcions() RETURNS SETOF public.uinfo
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.usuaris_inscripcions() OWNER TO master;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activitats; Type: TABLE; Schema: comercial; Owner: master
--

CREATE TABLE comercial.activitats (
    id_activitat integer NOT NULL,
    nom_activitat character varying(50) NOT NULL,
    descripcio character varying(100),
    preu numeric(10,0)
);


ALTER TABLE comercial.activitats OWNER TO master;

--
-- Name: activitats_id_activitat_seq; Type: SEQUENCE; Schema: comercial; Owner: master
--

CREATE SEQUENCE comercial.activitats_id_activitat_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comercial.activitats_id_activitat_seq OWNER TO master;

--
-- Name: activitats_id_activitat_seq; Type: SEQUENCE OWNED BY; Schema: comercial; Owner: master
--

ALTER SEQUENCE comercial.activitats_id_activitat_seq OWNED BY comercial.activitats.id_activitat;


--
-- Name: inscripcio; Type: TABLE; Schema: comercial; Owner: master
--

CREATE TABLE comercial.inscripcio (
    id_inscripcio character varying(20) NOT NULL,
    id_usuari character varying(20) NOT NULL,
    id_act integer,
    fecha_inici date,
    fecha_final date
);


ALTER TABLE comercial.inscripcio OWNER TO master;

--
-- Name: TABLE inscripcio; Type: COMMENT; Schema: comercial; Owner: master
--

COMMENT ON TABLE comercial.inscripcio IS 'inscripcio (id_inscripcio, id_usuari, id_act, data_inici, data_fi)
	Restriccions:

L''atribut id_inscripcio  és únic i no pot ser nul (serà la clau primària de tipus serial)
L''atribut id_usuari fa referència a un usuari, no pot ser nul, i la integritat actualitza en cascada (és clau forana a usuaris. Si s''esborra un usuari s''esborren les seves inscripcions. Si s''actualitza l''id d''un usuari, s''actualitza l''id_usuari a la taula inscripcio)
L''atribut id_act fa referència a una activitat, no pot ser nul, i la integritat  actualitza en cascada (és clau forana a activitats. Si s''esborra una activitat s''esborren les seves inscripcions.( Si s''actualitza l''id d''una activitat, s''actualitza l''id_act a la taula inscripcio)
L’atribut data_inici i data_fi contindran valors de dates (per exemple, ‘01/03/2017’)';


--
-- Name: treballadors; Type: TABLE; Schema: comercial; Owner: master
--

CREATE TABLE comercial.treballadors (
    dni character varying(10) NOT NULL,
    nom character varying(20) NOT NULL,
    cognom character varying(30) NOT NULL,
    carrec character varying(30) NOT NULL,
    email character varying(30) NOT NULL,
    sou numeric(10,0) DEFAULT 1050
);


ALTER TABLE comercial.treballadors OWNER TO master;

--
-- Name: treballadors_log; Type: TABLE; Schema: comercial; Owner: master
--

CREATE TABLE comercial.treballadors_log (
    dni character varying(10),
    usuari character varying(20),
    hora timestamp without time zone,
    accio character(15)
);


ALTER TABLE comercial.treballadors_log OWNER TO master;

--
-- Name: usuaris; Type: TABLE; Schema: comercial; Owner: master
--

CREATE TABLE comercial.usuaris (
    id_usuari character varying(20) NOT NULL,
    nom character varying(20) NOT NULL,
    cognom character varying(40) NOT NULL,
    adreca character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    dni character varying(10) NOT NULL
);


ALTER TABLE comercial.usuaris OWNER TO master;

--
-- Name: vista_inscripcions_usuaris; Type: VIEW; Schema: public; Owner: master
--

CREATE VIEW public.vista_inscripcions_usuaris AS
 SELECT usuaris.nom,
    usuaris.cognom,
    inscripcio.id_act
   FROM comercial.usuaris,
    comercial.inscripcio
  WHERE ((inscripcio.id_usuari)::text = (usuaris.id_usuari)::text);


ALTER TABLE public.vista_inscripcions_usuaris OWNER TO master;

--
-- Name: vista_treballador; Type: VIEW; Schema: public; Owner: master
--

CREATE VIEW public.vista_treballador AS
 SELECT treballadors.dni,
    treballadors.nom,
    treballadors.cognom,
    treballadors.carrec,
    treballadors.email,
    treballadors.sou
   FROM comercial.treballadors
  WHERE (treballadors.sou < (1250)::numeric);


ALTER TABLE public.vista_treballador OWNER TO master;

--
-- Name: activitats id_activitat; Type: DEFAULT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.activitats ALTER COLUMN id_activitat SET DEFAULT nextval('comercial.activitats_id_activitat_seq'::regclass);


--
-- Data for Name: activitats; Type: TABLE DATA; Schema: comercial; Owner: master
--

COPY comercial.activitats (id_activitat, nom_activitat, descripcio, preu) FROM stdin;
1	EnjoyTibidabo	visita al parc del Tibidabo. Transport+entrada+dinar	50
2	BarcelonaHistòrica	visites guiades a indrets històrics de BCN+dinar	50
3	barcelonaOculta	indrets Barcelona del segle XIX	60
4	barça	tour pel Camp Nou	66
5	espanyol	visita a Cornellà El Prat	40
\.


--
-- Data for Name: inscripcio; Type: TABLE DATA; Schema: comercial; Owner: master
--

COPY comercial.inscripcio (id_inscripcio, id_usuari, id_act, fecha_inici, fecha_final) FROM stdin;
1	1	1	2019-02-28	2019-02-28
2	2	2	2019-02-28	2019-02-28
3	3	3	2019-03-15	2019-03-15
4	4	4	2019-03-14	2019-03-14
5	1	2	2019-03-01	2019-03-01
6	1	3	2019-03-02	2019-03-02
7	1	4	2019-03-04	2019-03-04
8	2	1	2019-03-04	2019-03-04
9	2	3	2019-03-05	2019-03-05
10	2	4	2019-03-08	2019-03-08
\.


--
-- Data for Name: treballadors; Type: TABLE DATA; Schema: comercial; Owner: master
--

COPY comercial.treballadors (dni, nom, cognom, carrec, email, sou) FROM stdin;
52607534	Pep	Cases	tècnic	pepcases@barcelonaenjoy.cat	1800
52607000a	Paula	Garcia Navarro	tècnic	paulagn@barcelonaenjoy.cat	1289
52607001a	Santi	Pérez Sánchez	tècnic	paulagn@barcelonaenjoy.cat	1059
52607011a	Joan	Florit Borrrull	guia	joanfb@barcelonaenjoy.cat	850
52607535	Gal-la	Plàcida	gerent	galaplacida@barcelonaenjoy.cat	4000
\.


--
-- Data for Name: treballadors_log; Type: TABLE DATA; Schema: comercial; Owner: master
--

COPY comercial.treballadors_log (dni, usuari, hora, accio) FROM stdin;
52604534w	master	2019-04-04 18:58:58.067037	INSERT         
52604534w	master	2019-04-04 18:58:58.067037	DELETE         
\.


--
-- Data for Name: usuaris; Type: TABLE DATA; Schema: comercial; Owner: master
--

COPY comercial.usuaris (id_usuari, nom, cognom, adreca, email, dni) FROM stdin;
1	Josep	Faneca Trilla	Persefone 7, 41014 Sevilla	jfanecat@ioc.cat	52607534w
2	Teresa	Faneca Trilla	Gran Via CC 125, 08080 BCN	tfanecat@ioc.cat	52607535w
3	Pol	Jota Max	Pau Casals 1 43512 Benifallet	pjmax@outlook.es	62607538b
4	Joan	Jiménez Lleixà	Rector Rovira 5 43500 Tortosa	jjlleixa@outlook.es	62605538b
\.


--
-- Name: activitats_id_activitat_seq; Type: SEQUENCE SET; Schema: comercial; Owner: master
--

SELECT pg_catalog.setval('comercial.activitats_id_activitat_seq', 1, false);


--
-- Name: activitats activitats_pkey; Type: CONSTRAINT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.activitats
    ADD CONSTRAINT activitats_pkey PRIMARY KEY (id_activitat);


--
-- Name: inscripcio incripcio_pkey; Type: CONSTRAINT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.inscripcio
    ADD CONSTRAINT incripcio_pkey PRIMARY KEY (id_inscripcio);


--
-- Name: treballadors treballadors_pkey; Type: CONSTRAINT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.treballadors
    ADD CONSTRAINT treballadors_pkey PRIMARY KEY (dni);


--
-- Name: usuaris usuaris_pkey; Type: CONSTRAINT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.usuaris
    ADD CONSTRAINT usuaris_pkey PRIMARY KEY (id_usuari);


--
-- Name: vista_treballador del_vista_treballador; Type: RULE; Schema: public; Owner: master
--

CREATE RULE del_vista_treballador AS
    ON DELETE TO public.vista_treballador DO INSTEAD  DELETE FROM comercial.treballadors
  WHERE ((treballadors.dni)::text = (old.dni)::text);


--
-- Name: vista_treballador ins_vista_treballador; Type: RULE; Schema: public; Owner: master
--

CREATE RULE ins_vista_treballador AS
    ON INSERT TO public.vista_treballador DO INSTEAD  INSERT INTO comercial.treballadors (dni, nom, cognom, carrec, email, sou)
  VALUES (new.dni, new.nom, new.cognom, new.carrec, new.email, new.sou);


--
-- Name: treballadors audit_treballadors; Type: TRIGGER; Schema: comercial; Owner: master
--

CREATE TRIGGER audit_treballadors AFTER INSERT OR DELETE ON comercial.treballadors FOR EACH ROW EXECUTE PROCEDURE public.modific_treballador_log();


--
-- Name: inscripcio FK_activitat; Type: FK CONSTRAINT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.inscripcio
    ADD CONSTRAINT "FK_activitat" FOREIGN KEY (id_act) REFERENCES comercial.activitats(id_activitat) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inscripcio FK_usuaris; Type: FK CONSTRAINT; Schema: comercial; Owner: master
--

ALTER TABLE ONLY comercial.inscripcio
    ADD CONSTRAINT "FK_usuaris" FOREIGN KEY (id_usuari) REFERENCES comercial.usuaris(id_usuari) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA comercial; Type: ACL; Schema: -; Owner: master
--

GRANT ALL ON SCHEMA comercial TO comercial;
GRANT ALL ON SCHEMA comercial TO guiaturistic;
GRANT ALL ON SCHEMA comercial TO informatic;
GRANT ALL ON SCHEMA comercial TO skywalker;
GRANT ALL ON SCHEMA comercial TO wally;
GRANT ALL ON SCHEMA comercial TO harrods;


--
-- Name: TABLE activitats; Type: ACL; Schema: comercial; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.activitats TO informatic;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.activitats TO guiaturistic;
GRANT SELECT ON TABLE comercial.activitats TO comercial;
GRANT ALL ON TABLE comercial.activitats TO wally;
GRANT ALL ON TABLE comercial.activitats TO harrods;
GRANT ALL ON TABLE comercial.activitats TO skywalker;


--
-- Name: SEQUENCE activitats_id_activitat_seq; Type: ACL; Schema: comercial; Owner: master
--

GRANT ALL ON SEQUENCE comercial.activitats_id_activitat_seq TO wally;
GRANT ALL ON SEQUENCE comercial.activitats_id_activitat_seq TO harrods;
GRANT ALL ON SEQUENCE comercial.activitats_id_activitat_seq TO skywalker;


--
-- Name: TABLE inscripcio; Type: ACL; Schema: comercial; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.inscripcio TO informatic;
GRANT SELECT ON TABLE comercial.inscripcio TO guiaturistic WITH GRANT OPTION;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.inscripcio TO comercial;
GRANT ALL ON TABLE comercial.inscripcio TO wally;
GRANT ALL ON TABLE comercial.inscripcio TO harrods;
GRANT ALL ON TABLE comercial.inscripcio TO skywalker;


--
-- Name: TABLE treballadors; Type: ACL; Schema: comercial; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.treballadors TO informatic;
GRANT SELECT ON TABLE comercial.treballadors TO comercial;
GRANT ALL ON TABLE comercial.treballadors TO wally;
GRANT ALL ON TABLE comercial.treballadors TO harrods;
GRANT ALL ON TABLE comercial.treballadors TO skywalker;


--
-- Name: TABLE usuaris; Type: ACL; Schema: comercial; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.usuaris TO informatic;
GRANT SELECT ON TABLE comercial.usuaris TO guiaturistic;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE comercial.usuaris TO comercial;
GRANT ALL ON TABLE comercial.usuaris TO wally;
GRANT ALL ON TABLE comercial.usuaris TO harrods;
GRANT ALL ON TABLE comercial.usuaris TO skywalker;


--
-- PostgreSQL database dump complete
--

