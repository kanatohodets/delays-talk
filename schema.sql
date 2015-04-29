--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: beer_log; Type: TABLE; Schema: public; Owner: btyler; Tablespace: 
--

CREATE TABLE beer_log (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    "time" timestamp without time zone
);


ALTER TABLE beer_log OWNER TO btyler;

--
-- Name: beer_log_id_seq; Type: SEQUENCE; Schema: public; Owner: btyler
--

CREATE SEQUENCE beer_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE beer_log_id_seq OWNER TO btyler;

--
-- Name: beer_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: btyler
--

ALTER SEQUENCE beer_log_id_seq OWNED BY beer_log.id;


--
-- Name: beer_price_scale; Type: TABLE; Schema: public; Owner: btyler; Tablespace: 
--

CREATE TABLE beer_price_scale (
    id integer NOT NULL,
    range_start integer,
    range_end integer,
    price money
);


ALTER TABLE beer_price_scale OWNER TO btyler;

--
-- Name: beer_price_scale_id_seq; Type: SEQUENCE; Schema: public; Owner: btyler
--

CREATE SEQUENCE beer_price_scale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE beer_price_scale_id_seq OWNER TO btyler;

--
-- Name: beer_price_scale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: btyler
--

ALTER SEQUENCE beer_price_scale_id_seq OWNED BY beer_price_scale.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: btyler; Tablespace: 
--

CREATE TABLE customers (
    id integer NOT NULL,
    name text
);


ALTER TABLE customers OWNER TO btyler;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: btyler
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE customers_id_seq OWNER TO btyler;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: btyler
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: btyler
--

ALTER TABLE ONLY beer_log ALTER COLUMN id SET DEFAULT nextval('beer_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: btyler
--

ALTER TABLE ONLY beer_price_scale ALTER COLUMN id SET DEFAULT nextval('beer_price_scale_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: btyler
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Data for Name: beer_log; Type: TABLE DATA; Schema: public; Owner: btyler
--

COPY beer_log (id, customer_id, "time") FROM stdin;
1	1	2015-04-29 11:21:46.0334
2	1	2015-04-29 11:21:48.801461
3	1	2015-04-29 11:21:49.505449
4	5	2015-04-29 11:24:24.581081
5	5	2015-04-29 11:24:25.341111
6	5	2015-04-29 11:24:25.837021
7	5	2015-04-29 11:24:26.277232
8	5	2015-04-29 11:24:26.685364
\.


--
-- Name: beer_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: btyler
--

SELECT pg_catalog.setval('beer_log_id_seq', 8, true);


--
-- Data for Name: beer_price_scale; Type: TABLE DATA; Schema: public; Owner: btyler
--

COPY beer_price_scale (id, range_start, range_end, price) FROM stdin;
1	0	2	$2.50
2	3	5	$5.00
3	6	10	$15.00
4	11	100	$50.00
\.


--
-- Name: beer_price_scale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: btyler
--

SELECT pg_catalog.setval('beer_price_scale_id_seq', 4, true);


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: btyler
--

COPY customers (id, name) FROM stdin;
1	Thirsty Tourist
2	Bob Jones
3	Cees
4	Jos
5	Tim
\.


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: btyler
--

SELECT pg_catalog.setval('customers_id_seq', 5, true);


--
-- Name: beer_log_pkey; Type: CONSTRAINT; Schema: public; Owner: btyler; Tablespace: 
--

ALTER TABLE ONLY beer_log
    ADD CONSTRAINT beer_log_pkey PRIMARY KEY (id);


--
-- Name: beer_price_scale_pkey; Type: CONSTRAINT; Schema: public; Owner: btyler; Tablespace: 
--

ALTER TABLE ONLY beer_price_scale
    ADD CONSTRAINT beer_price_scale_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: btyler; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: beer_log_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: btyler
--

ALTER TABLE ONLY beer_log
    ADD CONSTRAINT beer_log_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: btyler
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM btyler;
GRANT ALL ON SCHEMA public TO btyler;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

