-- connect postgres 
psql -U postgres -h cbc-server-app
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
\timming -- activar o desactivar el tiempo de respusta de las consultas
\q --cerra consola
-- Crear DB transporte
CREATE DATABASE transporte
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
-- crear DB pasajer
CREATE TABLE public.pasajero
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