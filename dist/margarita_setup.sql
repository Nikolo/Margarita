CREATE TYPE usex AS ENUM (
    'm',
    'f'
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
    menu_name character varying(100),
    title character varying(250),
	CONSTRAINT pages_pkey PRIMARY KEY (id)
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
