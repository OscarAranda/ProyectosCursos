-- connect postgres 
psql -U postgres -h cbc-server-app
Sispcadmin670.
User app 
ovc_user_query
--pass: CBCsqlUser*
CREATE ROLE ovc_user_query;
ALTER ROLE ovc_user_query WITH LOGIN;
ALTER ROLE ovc_user_query WITH SUPERUSER;
ALTER ROLE ovc_user_query WITH PASSWORD 'CBCsqlUser*';

SELECT VERSION();
\h -- ayuda
\h comnado -- ayuda del comando especifico
\l -- Listar las bases
\c base de datos --moverse a una base de datos especifica
\dt -- listar las tablas de la base actual
\dn -- listar los esquemas de la base actual
\dv -- listar las vistas
\df -- listar las funciones
\du -- listar los usuarios
\g -- ejecutar ultimo comando 
\s -- historial de comandos
\l nombrearchivo --guardar lista de comandos
\i nombre archivo -- ejecuta comandos guardados
\e -- abrir editor 
\ef -- editor de funciones
\timing -- activar o desactivar el tiempo de respusta de las consultas
\q --cerra consola


-- Crear DB transporte
CREATE DATABASE ovc
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
-- crear DB pasajer
CREATE TABLE public.pasajeroq

(
    id serial,
    nombre character varying(100),
    direccion_residencia character varying,
    fecha_nacimiento date,
    CONSTRAINT pasajero_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.pasajero
    OWNER to postgres;    
--insert en pasajero
INSERT INTO public.pasajero(
	nombre, direccion_residencia, fecha_nacimiento)
	VALUES ('Primer Pasajero', 'Arcamendia 671', '1984-08-02');

--creacion viaje
CREATE TABLE public.viaje
(
    id serial,
    id_pasajero serial,
    id_trayecto serial,
    inicio date,
    fin date,
    CONSTRAINT viaje_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.viaje
    OWNER to postgres;

-- creacion trayecto
 CREATE TABLE public.trayecto
 (
     id serial,
     id_tren serial,
     id_estacion serial,
     CONSTRAINT trayecto_pkey PRIMARY KEY (id)

 )   
 WITH (
    OIDS = FALSE
);
ALTER TABLE public.trayecto
    OWNER to postgres;
--creacion de tabla estacion
CREATE TABLE public.estacion
(
    id serial,
    nombre CHARACTER VARYING(50),
    direccion CHARACTER VARYING(50),
    CONSTRAINT estacion_pkey PRIMARY KEY (id)
)    
WITH (
    OIDS = FALSE
);
ALTER TABLE public.estacion
    OWNER to postgres;

/*Crear Particiones, se crea una tabla Ej bitacora Viajes con tres columnas la que se va a 
particionar es la de fecha*/
CREATE TABLE public.bitacora_viaje
(
    id serial,
    id_viaje integer,
    fecha date
) PARTITION BY RANGE (fecha) 
WITH (
    OIDS = FALSE
);

ALTER TABLE public.bitacora_viaje
    OWNER to postgres;
/*Ahora hay que crear la particion con los valores a particionar del campo fecha, por ejemplo enero del 2018*/
CREATE TABLE bitacora_viaje201801 PARTITION OF bitacora_viaje
FOR VALUES FROM ('2018-01-01') TO ('2018-01-31');
--insert en particion
INSERT INTO public.bitacora_viaje(
    id_viaje, fecha)
    VALUES ('1','2018-01-10');
-- crear Rol
CREATE ROLE usuario_consulta,
-- asignarle permisos
ALTER ROLE usuario_consulta WITH LOGIN;
ALTER ROLE usuario_consulta WITH SUPERUSER;
ALTER ROLE usuario_consulta WITH PASSWORD 'etc123';
--borrar Rol
DROP ROLE usuario_consulta;
--consultar roles
 \dg
-- foreing key, relacion entre trayecto y estacion
ALTER TABLE public.trayecto
    ADD CONSTRAINT trayecto_estacion_fkey FOREIGN KEY (id_estacion)
    REFERENCES public.estacion (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
--foreing key, relacion entre trayecto y tren
ALTER TABLE public.trayecto
    ADD CONSTRAINT trayecto_tren_fkey FOREIGN KEY (id_tren)
    REFERENCES public.tren (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
--foreing key, relacion entre viaje y tren
ALTER TABLE public.viaje
    ADD CONSTRAINT viaje_trayecto_fkey FOREIGN KEY (id_trayecto)
    REFERENCES public.trayecto (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
--foreing key, relacion entre viaje y tren
ALTER TABLE public.viaje
    ADD CONSTRAINT viaje_pasajero_fkey FOREIGN KEY (id_pasajero)
    REFERENCES public.pasajero (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
--insert
INSERT INTO public.estacion(
    nombre, direccion)
    VALUES ('Estacion norte','St 100# 112');

INSERT INTO public.tren(
    capacidad, modelo)
    VALUES (100, 'renault');

INSERT INTO public.trayecto(
    id_estacion, id_tren, nombre)
    VALUES (1, 2, 'Ruta 2');

--INNER join

  SELECT u.first_name, u.last_name, u.email, o.status 
    FROM users u 
    JOIN orders o 
    ON u.id=o.user_id
    WHERE o.id=1;


SELECT * FROM pasajero
JOIN viaje ON (viaje.id_pasajero=pasajero.id);
-- left join 
SELECT * FROM pasajero
LEFT JOIN viaje ON (viaje.id_pasajero=pasajero.id)
WHERE viaje.id IS NULL;
--returninn
INSERT INTO public.estacion(nombre, direccion) VALUES ('RET', 'RETORI') RETURNING *;
-- LIKE - ILIKE, la diferencia es que ilike no diferencia ente may y min a la hora de hacer busqueda
SELECT nombre FROM public.pasajero WHERE nombre ILIKE 'o%';
-- case
SELECT id, nombre, fecha_nacimiento, direccion_residencia, 
CASE 
WHEN fecha_nacimiento > '2011-01-01' THEN
'Niño'
ELSE
'Mayor'
END,
CASE 
WHEN nombre ILIKE 'o%' THEN 
'Nombre'
ELSE
'No comienza con o'
END AS inicial
FROM pasajero;
--VISTAS
--crear vista
CREATE OR REPLACE VIEW public.menor_mayor_view
AS 
SELECT id, nombre, fecha_nacimiento, direccion_residencia, 
CASE 
WHEN fecha_nacimiento > '2011-01-01' THEN
'Niño'
ELSE
'Mayor'
END,
CASE 
WHEN nombre ILIKE 'o%' THEN 
'Nombre'
ELSE
'No comienza con o'
END AS inicial
FROM pasajero;
--VISTA MATERIALIZADA
CREATE MATERIALIZED VIEW public.despues_noche_mview
AS
SELECT * FROM viaje WHERE inicio > '2000-01-01'
WITH NO DATA;
ALTER TABLE public.despues_noche_mview
    OWNER TO postgres;
-- Para cargar la vista con datos q
 REFRESH MATERIALIZED VIEW despues_noche_mview;
 -- hassta que no se carga no muestra datos tampoco se actualiza- Se usan para consultar datos que no cambian por lo general

 -- PL
 --Probar parametros de funcion PL
DO $$ 
 DECLARE
    rec record := NULL;
    contador INTEGER := 0;
 BEGIN
 	FOR rec IN SELECT * FROM pasajero LOOP
	    RAISE NOTICE 'Un pasajero se llama %',rec.nombre;
        contador := contador + 1;
	END LOOP;
    RAISE NOTICE 'Conteo es %', contador;
 END
 $$
 --Crear funcion
 CREATE FUNCTION primerPL()
 RETURNS void
 AS $$
 DECLARE
    rec record := NULL;
    contador INTEGER := 0;
 BEGIN
 	FOR rec IN SELECT * FROM pasajero LOOP
	    RAISE NOTICE 'Un pasajero se llama %',rec.nombre;
        contador := contador + 1;
	END LOOP;
    RAISE NOTICE 'Conteo es %', contador;
 END
 $$
LANGUAGE PLPGSQL;
--Retorna el conteo de pasajeros
CREATE OR REPLACE FUNCTION primerPL()
 	RETURNS integer
	LANGUAGE 'plpgsql'
 	COST 100
	VOLATILE
 AS $$
 DECLARE
    rec record := NULL;
    contador INTEGER := 0;
 BEGIN
 	FOR rec IN SELECT * FROM pasajero LOOP
	    RAISE NOTICE 'Un pasajero se llama %',rec.nombre;
        contador := contador + 1;
	END LOOP;
    INSERT INTO cont_pasajero (total,tiempo)
	VALUES (contador, now());
	RETURN contador;
 END
 $$
 

-- insert entabla conteo pasajero cuando se inserta en pasajero (Trigger)
CREATE FUNCTION public.primerpl()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
 DECLARE
    rec record;
    contador INTEGER := 0;
 BEGIN
 	FOR rec IN SELECT * FROM pasajero LOOP
        contador := contador + 1;
	END LOOP;
    INSERT INTO cont_pasajero (total,tiempo)
	VALUES (contador, now());
	RETURN NEW;
 END
 $BODY$;

ALTER FUNCTION public.primerpl()
    OWNER TO postgres;

    --Crea TRIGGER
    
CREATE TRIGGER mitrigger
    AFTER INSERT
    ON public.pasajero
    FOR EACH ROW
    EXECUTE PROCEDURE public.primerpl();

insert into public.tables (menu_id, table_state, restaurant_id, waiter_id,table_number) VALUES (2,'true',113,1,205);
INSERT INTO public.waiters (waiter_name, waiter_number, restaurant_id) VALUES ('josefa cañete',1, 113);


CREATE TABLE public.orders

(
    id serial,
    dateCrated date,
    direccion_residencia character varying,
    fecha_nacimiento date,
    CONSTRAINT pasajero_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.pasajero
    OWNER to postgres;   


    Cliente: Integracion Energetica Argentina SA (IEASA)
    Licencia PaperCut MF
    Equipos
    SHARP MFP: 20
    Lexmark Printer: 09
    Mantenimiento: 24 y 36 meses





 SELECT d.id, o.id orden, o.date fecha, o.status, l.id, u.first_name, l.product_id, p.product_name producto,
 p.price 
    FROM orders_detail d
    JOIN orders o
    ON o.id=d.order_id 
    JOIN orders_list l
    ON l.order_id=o.id
    JOIN users u 
    ON u.id=o.user_id
    JOIN products p 
    ON l.product_id=p.id
    WHERE d.id=1 and l.order_id=1;



SELECT COALESCE(p.price)
FROM products;
    

    DO $$
DECLARE 
rec record;

BEGIN
FOR rec IN SELECT sum(products) 
	FROM orders_list l
	join products  
	ON products.id=l.product_id loop
	--WHERE l.order_id=1 LOOP 
	RAISE NOTICE 'el precio es %', rec.price;
END LOOP;
END
$$



INSERT INTO orders (status, user_id) VALUES ('t',15);
INSERT INTO orders_detail (order_id) VALUES (lastval());


INSERT INTO orders_detail (order_id) SELECT "id" MAX (code) from orders;

--Cuando se inserta una nueva orden, se debe generar automaticamente un nueva order_detail 
INSERT INTO orders (status, user_id) VALUES ('t',15);
INSERT INTO orders_detail (order_id) SELECT  MAX(id) from orders;

SELECT u.email AS usuario, 
FROM orders_detail d 
JOIN orders_list l 
ON d.id=l.order_id
JOIN products p 
ON p.id=l.product_id
JOIN orders o 
ON o.id=d.order_id
JOIN users u
ON u.id=o.user_id 
WHERE o.id=1



---------------------------------------------------------
--meeting
USE meeting
CREATE TABLE meetings(
    id INT IDENTITY(1,1) PRIMARY KEY,
    createdAt datetime NOT NULL,
    meetingDate DATE NOT NULL,
    meetingTime TIME NOT NULL,
    owner VARCHAR(30) NOT NULL,
    idHash VARCHAR(MAX) NOT NULL
);

CREATE TABLE meetingTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    type VARCHAR(20) NOT NULL
);

CREATE TABLE registerUsers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    registered BIT NOT NULL DEFAULT(0),
    connected BIT NOT NULL DEFAULT(0),
    idUserMeeting INT NOT NULL
);

CREATE TABLE userMeetings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idMeeting INT NOT NULL,
    idUser INT NOT NULL,
    idRegister INT NOT NULL,
    FOREIGN KEY (idMeeting) REFERENCES meetings(id),
    FOREIGN KEY (idUser) REFERENCES users(id),
    FOREIGN KEY (idRegister) REFERENCES registerUsers(id)
;)

ALTER TABLE meetings ADD 
idTypes INT NOT NULL,
FOREIGN KEY (idtypes) REFERENCES types(id);

ALTER TABLE registerUsers
FOREIGN KEY (idUserMeeting) REFERENCES userMeetings(id)

INSERT INTO meetings (createdAt, meetingDate,meetingTime,owner,idHash,idTypes)
VALUES (GETDATE(), '26/06/2020', '19:00:00','Oscar','cacaf3121feda3dacadc23ddcsdc33', 1);}

INSERT INTO meetingTypes (type)
VALUES ('Comercial'),('Tecnico');