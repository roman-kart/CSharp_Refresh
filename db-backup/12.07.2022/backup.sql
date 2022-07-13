--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: barcode_info; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.barcode_info AS (
	code character varying(128),
	kind text
);


ALTER TYPE public.barcode_info OWNER TO postgres;

--
-- Name: consumtoion_type_name; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.consumtoion_type_name AS ENUM (
    'lost',
    'trash',
    'expired',
    'sell',
    'purpose',
    'help'
);


ALTER TYPE public.consumtoion_type_name OWNER TO postgres;

--
-- Name: energy_value; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.energy_value AS numeric(6,3)
	CONSTRAINT energy_value_check CHECK (((VALUE >= (0)::numeric) AND (VALUE <= (100)::numeric)));


ALTER DOMAIN public.energy_value OWNER TO postgres;

--
-- Name: positive_numeric; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.positive_numeric AS numeric(10,3)
	CONSTRAINT positive_numeric_check CHECK ((VALUE >= (0)::numeric));


ALTER DOMAIN public.positive_numeric OWNER TO postgres;

--
-- Name: product_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_type AS ENUM (
    'food_and_chem',
    'electronics',
    'for_house',
    'transport',
    'medicines',
    'vacation',
    'other'
);


ALTER TYPE public.product_type OWNER TO postgres;

--
-- Name: units_of_measuremen; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.units_of_measuremen AS ENUM (
    'pcs',
    'g',
    'ml'
);


ALTER TYPE public.units_of_measuremen OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: consumption; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consumption (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type public.consumtoion_type_name,
    modify_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.consumption OWNER TO postgres;

--
-- Name: consumption_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consumption_detail (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    consumption_id uuid NOT NULL,
    barcode public.barcode_info,
    cost public.positive_numeric,
    currency character varying(3),
    quantity public.positive_numeric
);


ALTER TABLE public.consumption_detail OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    barcode public.barcode_info NOT NULL,
    description text,
    proteins public.energy_value,
    fats public.energy_value,
    carbohydrates public.energy_value,
    calories numeric(6,3),
    composition jsonb,
    type public.product_type NOT NULL,
    uom public.units_of_measuremen NOT NULL,
    quantity public.positive_numeric NOT NULL,
    user_id uuid NOT NULL,
    CONSTRAINT products_calories_check CHECK ((calories >= (0)::numeric)),
    CONSTRAINT products_check CHECK ((((((proteins)::numeric + (fats)::numeric) + (carbohydrates)::numeric) >= (0)::numeric) AND ((((proteins)::numeric + (fats)::numeric) + (carbohydrates)::numeric) <= (100)::numeric)))
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: purchases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    shop_name text,
    modify_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.purchases OWNER TO postgres;

--
-- Name: purchases_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchases_detail (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    purchase_id uuid NOT NULL,
    barcode public.barcode_info,
    price public.positive_numeric,
    currency character varying(3),
    quantity public.positive_numeric
);


ALTER TABLE public.purchases_detail OWNER TO postgres;

--
-- Name: total_day_consumption; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.total_day_consumption (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    barcode public.barcode_info NOT NULL,
    cost public.positive_numeric,
    currency character varying(3) NOT NULL,
    quantity public.positive_numeric,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.total_day_consumption OWNER TO postgres;

--
-- Name: total_day_purchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.total_day_purchase (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    barcode public.barcode_info NOT NULL,
    cost public.positive_numeric,
    currency character varying(3) NOT NULL,
    quantity public.positive_numeric,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.total_day_purchase OWNER TO postgres;

--
-- Name: total_month_shops; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.total_month_shops (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    shop_name text NOT NULL,
    count_of_orders integer NOT NULL,
    create_date date DEFAULT now() NOT NULL
);


ALTER TABLE public.total_month_shops OWNER TO postgres;

--
-- Data for Name: consumption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consumption (id, user_id, type, modify_date) FROM stdin;
\.


--
-- Data for Name: consumption_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consumption_detail (id, consumption_id, barcode, cost, currency, quantity) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (barcode, description, proteins, fats, carbohydrates, calories, composition, type, uom, quantity, user_id) FROM stdin;
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchases (id, user_id, shop_name, modify_date) FROM stdin;
\.


--
-- Data for Name: purchases_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchases_detail (id, purchase_id, barcode, price, currency, quantity) FROM stdin;
\.


--
-- Data for Name: total_day_consumption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.total_day_consumption (user_id, barcode, cost, currency, quantity, create_date) FROM stdin;
\.


--
-- Data for Name: total_day_purchase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.total_day_purchase (user_id, barcode, cost, currency, quantity, create_date) FROM stdin;
\.


--
-- Data for Name: total_month_shops; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.total_month_shops (user_id, shop_name, count_of_orders, create_date) FROM stdin;
\.


--
-- Name: consumption_detail consumption_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_detail
    ADD CONSTRAINT consumption_detail_pkey PRIMARY KEY (id, consumption_id);


--
-- Name: consumption consumption_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption
    ADD CONSTRAINT consumption_id_key UNIQUE (id);


--
-- Name: consumption consumption_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption
    ADD CONSTRAINT consumption_pkey PRIMARY KEY (id, user_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (barcode, user_id);


--
-- Name: purchases_detail purchases_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases_detail
    ADD CONSTRAINT purchases_detail_pkey PRIMARY KEY (id, purchase_id);


--
-- Name: purchases purchases_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_id_key UNIQUE (id);


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id, user_id);


--
-- Name: total_day_consumption total_day_consumption_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.total_day_consumption
    ADD CONSTRAINT total_day_consumption_pkey PRIMARY KEY (user_id, barcode, currency, create_date);


--
-- Name: total_day_purchase total_day_purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.total_day_purchase
    ADD CONSTRAINT total_day_purchase_pkey PRIMARY KEY (user_id, barcode, currency, create_date);


--
-- Name: total_month_shops total_month_shops_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.total_month_shops
    ADD CONSTRAINT total_month_shops_pkey PRIMARY KEY (user_id, shop_name, create_date);


--
-- Name: products_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_barcode_idx ON public.products USING btree (barcode);


--
-- Name: consumption_detail consumption_detail_consumption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_detail
    ADD CONSTRAINT consumption_detail_consumption_id_fkey FOREIGN KEY (consumption_id) REFERENCES public.consumption(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchases_detail purchases_detail_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases_detail
    ADD CONSTRAINT purchases_detail_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

