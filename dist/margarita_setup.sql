CREATE TYPE usex AS ENUM (
    'm',
    'f'
);
CREATE table menu_types ( 
	id serial, 
	name varchar(128),
	CONSTRAINT menu_type_pkey PRIMARY KEY (id)
);
CREATE TABLE grps (
    id serial,
    name character varying(128),
    description text,
	CONSTRAINT grps_pkey PRIMARY KEY (id)
);
CREATE TABLE pages (
    id serial,
    action character varying(50),
    controller character varying(50),
    title character varying(250),
	top_menu boolean not null default false,
	CONSTRAINT pages_pkey PRIMARY KEY (id)
);
CREATE table menu (
	id serial,
	menu_type_id int,
	page_id int,
	name character varying(100),
	position int,
	CONSTRAINT ref_menu_type_id FOREIGN KEY (menu_type_id) REFERENCES menu_types(id),
	CONSTRAINT ref_page_id FOREIGN KEY (page_id) REFERENCES pages(id),
	CONSTRAINT menu_pkey PRIMARY KEY (id)
);
CREATE TABLE acls (
    grp_id integer,
    page_id integer,
	CONSTRAINT ref_grp_id FOREIGN KEY (grp_id) REFERENCES grps(id),
	CONSTRAINT ref_page_id FOREIGN KEY (page_id) REFERENCES pages(id)
);
CREATE TABLE users (
    id serial,
    password character varying(128),
    email character varying(128),
    first_name character varying(128),
    last_name character varying(128),
    country character varying(50),
    city character varying(512),
    comment text,
    activationid character varying(128),
    sex usex,
    code character varying(255),
    birth_date date,
    last_visit date,
    not_receive_mailer boolean,
	CONSTRAINT users_pkey PRIMARY KEY (id),
	UNIQUE (email)
);
CREATE TABLE roles (
    id serial,
    user_id integer,
    grp_id integer,
	CONSTRAINT roles_pkey PRIMARY KEY (id),
	CONSTRAINT ref_grp_id FOREIGN KEY (grp_id) REFERENCES grps(id),
	CONSTRAINT ref_user_id FOREIGN KEY (user_id) REFERENCES users(id),
	UNIQUE (user_id, grp_id)
);
CREATE TYPE uploadtype AS ENUM ('menu');
CREATE OR REPLACE FUNCTION check_obj(_tbl uploadtype,_i integer, OUT res integer) AS
$$
BEGIN
	EXECUTE 'SELECT (EXISTS (SELECT 1 FROM ' || _tbl || ' WHERE id = ' || _i || '))::int'
	INTO res;
END;
$$ LANGUAGE plpgsql;
CREATE TABLE upload ( 
	id serial, 
	name character varying(128), 
	owner_id integer not null, 
	date date, 
	file_media_type character varying(32), 
	obj_name uploadtype, 
	obj_id integer not null, 
	tmpl_keyword character varying(32), 
	tags character varying(512), 
	constraint check_exist_object CHECK (check_obj(obj_name, obj_id) > 0)
);
