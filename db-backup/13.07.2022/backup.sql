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
-- Name: barcode_kind_names; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.barcode_kind_names AS ENUM (
    'EAN13',
    'EAN8',
    'CUSTOM'
);


ALTER TYPE public.barcode_kind_names OWNER TO postgres;

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

--
-- Name: cud_total_day_consumption(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cud_total_day_consumption() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
  	old_user_id uuid;  
  	new_user_id uuid;
    
    old_create_date date;
    new_create_date date;
  BEGIN
	CASE TG_OP 
    	WHEN 'INSERT' THEN
        	SELECT user_id FROM consumption c WHERE c.id = NEW.consumption_id INTO STRICT new_user_id;
        	SELECT modify_date FROM consumption c WHERE c.id = NEW.consumption_id INTO STRICT new_create_date;
            PERFORM update_or_create_total_day_consumption(new_user_id, NEW.barcode_code, NEW.barcode_kind, NEW.cost, NEW.currency, NEW.quantity, new_create_date);
        WHEN 'UPDATE' THEN
        	SELECT user_id FROM consumption c WHERE c.id = NEW.consumption_id INTO STRICT new_user_id;
        	SELECT user_id FROM consumption c WHERE c.id = OLD.consumption_id INTO STRICT old_user_id;
            SELECT modify_date FROM consumption c WHERE c.id = NEW.consumption_id INTO STRICT new_create_date;
            SELECT modify_date FROM consumption c WHERE c.id = OLD.consumption_id INTO STRICT old_create_date;
        
        	PERFORM update_or_create_total_day_consumption(new_user_id, NEW.barcode_code, NEW.barcode_kind, NEW.cost, NEW.currency, NEW.quantity, new_create_date);
        	PERFORM update_or_create_total_day_consumption(old_user_id, OLD.barcode_code, OLD.barcode_kind, - OLD.cost, OLD.currency, - OLD.quantity, old_create_date);
        WHEN 'DELETE' THEN
        	SELECT user_id FROM consumption c WHERE c.id = OLD.consumption_id INTO STRICT old_user_id;
            SELECT modify_date FROM consumption c WHERE c.id = OLD.consumption_id INTO STRICT old_create_date;
        	PERFORM update_or_create_total_day_consumption(old_user_id, OLD.barcode_code, OLD.barcode_kind, - OLD.cost, OLD.currency, - OLD.quantity, old_create_date);
    END CASE;
    CASE TG_OP 
    	WHEN 'INSERT', 'UPDATE' THEN
        	RETURN NEW;
        WHEN 'DELETE' THEN
        	RETURN OLD;
    END CASE;
  END;
$$;


ALTER FUNCTION public.cud_total_day_consumption() OWNER TO postgres;

--
-- Name: cud_total_day_purchase(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cud_total_day_purchase() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
  	old_user_id uuid;  
  	new_user_id uuid;
    
    old_create_date date;
    new_create_date date;
  BEGIN
	CASE TG_OP 
    	WHEN 'INSERT' THEN
        	SELECT user_id FROM purchases c WHERE c.id = NEW.purchase_id INTO STRICT new_user_id;
        	SELECT modify_date FROM purchases c WHERE c.id = NEW.purchase_id INTO STRICT new_create_date;
            PERFORM update_or_create_total_day_purchase(new_user_id, NEW.barcode_code, NEW.barcode_kind, NEW.price, NEW.currency, NEW.quantity, new_create_date);
        WHEN 'UPDATE' THEN
        	SELECT user_id FROM purchases c WHERE c.id = NEW.purchase_id INTO STRICT new_user_id;
        	SELECT user_id FROM purchases c WHERE c.id = OLD.purchase_id INTO STRICT old_user_id;
            SELECT modify_date FROM purchases c WHERE c.id = NEW.purchase_id INTO STRICT new_create_date;
            SELECT modify_date FROM purchases c WHERE c.id = OLD.purchase_id INTO STRICT old_create_date;
        
        	PERFORM update_or_create_total_day_purchase(new_user_id, NEW.barcode_code, NEW.barcode_kind, NEW.price, NEW.currency, NEW.quantity, new_create_date);
        	PERFORM update_or_create_total_day_purchase(old_user_id, OLD.barcode_code, OLD.barcode_kind, - OLD.price, OLD.currency, - OLD.quantity, old_create_date);
        WHEN 'DELETE' THEN
        	SELECT user_id FROM purchases c WHERE c.id = OLD.purchase_id INTO STRICT old_user_id;
            SELECT modify_date FROM purchases c WHERE c.id = OLD.purchase_id INTO STRICT old_create_date;
        	PERFORM update_or_create_total_day_purchase(old_user_id, OLD.barcode_code, OLD.barcode_kind, - OLD.price, OLD.currency, - OLD.quantity, old_create_date);
    END CASE;
    CASE TG_OP 
    	WHEN 'INSERT', 'UPDATE' THEN
        	RETURN NEW;
        WHEN 'DELETE' THEN
        	RETURN OLD;
    END CASE;
  END;
$$;


ALTER FUNCTION public.cud_total_day_purchase() OWNER TO postgres;

--
-- Name: increment_or_create_shop_on_month(uuid, text, integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_or_create_shop_on_month(user_id_val uuid, shop_name_val text, count_of_orders_val integer, create_date_val date) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
  	count_of_orders_init INT = 0;
  BEGIN
	LOOP
    	UPDATE
        	total_month_shops tms
        SET count_of_orders = CASE 
             	WHEN count_of_orders + count_of_orders_val >= 0  THEN count_of_orders + count_of_orders_val
                ELSE 0
        	END
        WHERE 
        	tms.user_id = user_id_val
            AND tms.shop_name = shop_name_val
            AND EXTRACT(MONTH FROM tms.create_date) = EXTRACT(MONTH FROM create_date_val);
           
       	EXIT WHEN FOUND;
        
        IF count_of_orders_val >= 0 THEN
        	count_of_orders_init = count_of_orders_val;
        END IF;
        
        BEGIN
        	INSERT INTO 
            	total_month_shops (
                  user_id, 
                  shop_name, 
                  count_of_orders, 
                  create_date
                ) 
            VALUES(
              user_id_val, 
              shop_name_val, 
              count_of_orders_init, 
              create_date_val
            );
            EXIT;
            EXCEPTION
            	WHEN unique_violation THEN
                	CONTINUE;
        END;
    END LOOP;
  END;
$$;


ALTER FUNCTION public.increment_or_create_shop_on_month(user_id_val uuid, shop_name_val text, count_of_orders_val integer, create_date_val date) OWNER TO postgres;

--
-- Name: update_count_of_shops(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_count_of_shops() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
	CASE TG_OP 
    	WHEN 'INSERT' THEN
        	PERFORM increment_or_create_shop_on_month(NEW.user_id, NEW.shop_name, 1, NEW.modify_date::date);
        WHEN 'UPDATE' THEN
        	PERFORM increment_or_create_shop_on_month(OLD.user_id, OLD.shop_name, -1, OLD.modify_date::date);
            PERFORM increment_or_create_shop_on_month(NEW.user_id, NEW.shop_name, 1, NEW.modify_date::date);
        WHEN 'DELETE' THEN
        	PERFORM increment_or_create_shop_on_month(OLD.user_id, OLD.shop_name, -1, OLD.modify_date::date);
    END CASE;
    CASE TG_OP 
    	WHEN 'INSERT', 'UPDATE' THEN
        	RETURN NEW;
        WHEN 'DELETE' THEN
        	RETURN OLD;
    END CASE;
  END;
$$;


ALTER FUNCTION public.update_count_of_shops() OWNER TO postgres;

--
-- Name: update_or_create_total_day_consumption(uuid, text, public.barcode_kind_names, numeric, character varying, numeric, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_or_create_total_day_consumption(user_id_val uuid, barcode_code_val text, barcode_kind_val public.barcode_kind_names, cost_val numeric, currency_val character varying, quantity_val numeric, create_date_val date) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
  	cost_init numeric(10, 3) = 0;
  	quantity_init numeric(10, 3) = 0;
  BEGIN
	LOOP
    	UPDATE
        	total_day_consumption tdc
        SET cost = CASE 
             	WHEN cost + cost_val >= 0  THEN cost + cost_val
                ELSE 0
        	END,
        	quantity = CASE
        		WHEN quantity + quantity_val >= 0 THEN quantity + quantity_val
                ELSE 0
        	END
        WHERE 
        	user_id = user_id_val
            AND barcode_code = barcode_code_val
            AND barcode_kind = barcode_kind_val
            AND currency = currency_val
            AND EXTRACT(MONTH FROM create_date) = EXTRACT(MONTH FROM create_date_val);
           
       	EXIT WHEN FOUND;
        
        IF cost_val >= 0 THEN
        	cost_init = cost_val;
        END IF;
        
        IF quantity_val >= 0 THEN
        	quantity_init = quantity_val;
        END IF;
        
        BEGIN
        	INSERT INTO 
            	total_day_consumption (
                  user_id, 
                  barcode_code,
                  barcode_kind,
                  cost,
                  currency,
                  quantity,
                  create_date
                ) 
            VALUES(
              user_id_val, 
              barcode_code_val,
              barcode_kind_val,
              cost_val,
              currency_val,
              quantity_val,
              create_date_val
            );
            EXIT;
            EXCEPTION
            	WHEN unique_violation THEN
                	CONTINUE;
        END;
    END LOOP;
  END;
$$;


ALTER FUNCTION public.update_or_create_total_day_consumption(user_id_val uuid, barcode_code_val text, barcode_kind_val public.barcode_kind_names, cost_val numeric, currency_val character varying, quantity_val numeric, create_date_val date) OWNER TO postgres;

--
-- Name: update_or_create_total_day_purchase(uuid, text, public.barcode_kind_names, numeric, character varying, numeric, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_or_create_total_day_purchase(user_id_val uuid, barcode_code_val text, barcode_kind_val public.barcode_kind_names, cost_val numeric, currency_val character varying, quantity_val numeric, create_date_val date) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
  	cost_init numeric(10, 3) = 0;
  	quantity_init numeric(10, 3) = 0;
  BEGIN
	LOOP
    	UPDATE
        	total_day_purchase tdc
        SET price = CASE 
             	WHEN price + cost_val >= 0  THEN price + cost_val
                ELSE 0
        	END,
        	quantity = CASE
        		WHEN quantity + quantity_val >= 0 THEN quantity + quantity_val
                ELSE 0
        	END
        WHERE 
        	user_id = user_id_val
            AND barcode_code = barcode_code_val
            AND barcode_kind = barcode_kind_val
            AND currency = currency_val
            AND EXTRACT(MONTH FROM create_date) = EXTRACT(MONTH FROM create_date_val);
           
       	EXIT WHEN FOUND;
        
        IF cost_val >= 0 THEN
        	cost_init = cost_val;
        END IF;
        
        IF quantity_val >= 0 THEN
        	quantity_init = quantity_val;
        END IF;
        
        BEGIN
        	INSERT INTO 
            	total_day_purchase (
                  user_id, 
                  barcode_code,
                  barcode_kind,
                  price,
                  currency,
                  quantity,
                  create_date
                ) 
            VALUES(
              user_id_val, 
              barcode_code_val,
              barcode_kind_val,
              cost_val,
              currency_val,
              quantity_val,
              create_date_val
            );
            EXIT;
            EXCEPTION
            	WHEN unique_violation THEN
                	CONTINUE;
        END;
    END LOOP;
  END;
$$;


ALTER FUNCTION public.update_or_create_total_day_purchase(user_id_val uuid, barcode_code_val text, barcode_kind_val public.barcode_kind_names, cost_val numeric, currency_val character varying, quantity_val numeric, create_date_val date) OWNER TO postgres;

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
    barcode_code text NOT NULL,
    barcode_kind public.barcode_kind_names NOT NULL,
    cost public.positive_numeric,
    currency character varying(3),
    quantity public.positive_numeric
);


ALTER TABLE public.consumption_detail OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    barcode_code text NOT NULL,
    barcode_kind public.barcode_kind_names NOT NULL,
    user_id uuid NOT NULL,
    title character varying(128),
    description text,
    proteins public.energy_value,
    fats public.energy_value,
    carbohydrates public.energy_value,
    calories numeric(6,3),
    composition jsonb,
    type public.product_type NOT NULL,
    uom public.units_of_measuremen NOT NULL,
    quantity public.positive_numeric NOT NULL,
    other jsonb,
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
    barcode_code text NOT NULL,
    barcode_kind public.barcode_kind_names NOT NULL,
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
    barcode_code text NOT NULL,
    barcode_kind public.barcode_kind_names NOT NULL,
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
    barcode_code text NOT NULL,
    barcode_kind public.barcode_kind_names NOT NULL,
    price public.positive_numeric,
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
70d273d2-ce04-4ca8-8af4-83b20c0ae32f	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	purpose	2022-07-13 00:00:00+03
\.


--
-- Data for Name: consumption_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consumption_detail (id, consumption_id, barcode_code, barcode_kind, cost, currency, quantity) FROM stdin;
f69e93ad-4b17-42f0-8fbd-a4a7c1c90c13	70d273d2-ce04-4ca8-8af4-83b20c0ae32f	4602441014019	EAN13	0.000	RUB	2.000
019aafae-272a-43e0-a928-d2fae52b4083	70d273d2-ce04-4ca8-8af4-83b20c0ae32f	4602441014019	EAN13	0.000	RUB	2.000
988a214d-18a6-42fa-b9dc-8e15c1d27dc5	70d273d2-ce04-4ca8-8af4-83b20c0ae32f	4602441014019	EAN13	0.000	RUB	2.000
49b63a63-7933-47f8-9656-0ab943cc5569	70d273d2-ce04-4ca8-8af4-83b20c0ae32f	54491472	EAN8	0.000	RUB	2.000
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (barcode_code, barcode_kind, user_id, title, description, proteins, fats, carbohydrates, calories, composition, type, uom, quantity, other) FROM stdin;
54491472	EAN8	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Напиток безалкогольный газированный ТМ Coca-Cola 0,5л п/б	Вода Coca-Cola газированная 0.5л. Пейте охлаждённым. Хранить в темном, сухом и прохладном месте.	0.000	0.000	10.600	42.000	{"version": "0.0.1", "composition": "Вода, сахар, диоксид углерода, краситель (сахарный колер IV), регулятор кислотности (орто-фосфорная кислота), натуральные ароматизаторы, кофеин. Общие сахара 10,6г"}	food_and_chem	ml	500.000	\N
9S7-16R612-219	CUSTOM	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Ноутбук MSI GF63 Thin 11UC-219XRU	ThinИгровой ноутбук MSI GF63 оснащен качественным 15.6-дюймовым экраном, мощным процессором Intel Core i5 11400H (Tiger Lake) 2.7 ГГц, имеет великолепную систему охлаждения, отличную видеокарту NVIDIA GeForce® RTX 3050 для ноутбуков. Модель MSI GF63 интересна для пользователей как часто играющих за ноутбуком, так и работающих с видеомонтажом. Игровые ноутбуки MSI GF63 популярны среди покупателей благодаря широкому выбору конфигураций, высочайшему качеству техники и приемлемой цене.	\N	\N	\N	\N	\N	electronics	pcs	1.000	\N
4602441014019	EAN13	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Газированный напиток Напитки из Черноголовки Лимонад оригинальный 0,5 л	Особенностью рецептуры Лимонада является сбалансированный состав сладких и кислых компонентов, созданный на основе натуральных цитрусовых настоев. В нем и аромат цитрусовых цветов, и чай с лимоном и много-много светлого, и предвкушение чего-то хорошего, и капля беззаботности, безоблачной радости, которые оставляет легкое и приятное послевкусие.	0.000	0.000	11.500	45.000	{"version": "0.0.1", "composition": "Вода подготовленная, сахар, сок яблока концентрированный, регуляторы кислотности: кислота лимонная и цитрат натрия, ароматизаторы натуральные, стабилизаторы гуммиарабик и Е445, красители: сахарный колер IV (Е150d) и бета-каротин, антиокислитель кислота."}	food_and_chem	ml	500.000	\N
4602441014019	EAN13	c2411f06-37e6-4bac-8c3a-bbc532fe6c39	Черноголовка Лимонад 0,5 л	\N	0.000	0.000	11.500	45.000	{"version": "0.0.1", "composition": "Вода подготовленная, сахар, сок яблока концентрированный, регуляторы кислотности: кислота лимонная и цитрат натрия, ароматизаторы натуральные, стабилизаторы гуммиарабик и Е445, красители: сахарный колер IV (Е150d) и бета-каротин, антиокислитель кислота."}	food_and_chem	ml	500.000	\N
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchases (id, user_id, shop_name, modify_date) FROM stdin;
c3497b27-4a8a-4f56-b12d-f4d1f215c9a9	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Атак	2022-07-13 00:00:00+03
c29a068d-8a20-46c5-bfe1-66d80ebed12e	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Пятерочка	2022-07-13 00:00:00+03
8e2f8bb6-6a03-4921-9d32-69934b4e3cde	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Ашан	2022-07-13 00:00:00+03
5db8a190-0aab-490c-adfc-ca0a7d28c85b	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Атак	2022-07-13 00:00:00+03
1d519fd3-b393-4108-9240-bd0cf6ad79fc	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Пятерочка	2022-07-13 00:00:00+03
20f268e1-feb2-46d1-b031-1c0dbb1dedef	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Ашан	2022-07-13 00:00:00+03
78ea1a18-68a7-4ad9-930a-2245ddc1eed1	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Атак	2022-07-13 00:00:00+03
c9e085ef-ac81-44d6-b354-3accc3e6f28b	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Пятерочка	2022-07-13 00:00:00+03
14c95540-24f0-45d8-b25a-cfb0f6aadcda	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Ашан	2022-07-13 00:00:00+03
7227071d-a2b2-4297-82ed-1430f3751d01	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Атак	2022-07-13 00:00:00+03
8a669d55-0127-4039-8dbd-181a52f347f3	908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Пятерочка	2022-07-13 00:00:00+03
\.


--
-- Data for Name: purchases_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchases_detail (id, purchase_id, barcode_code, barcode_kind, price, currency, quantity) FROM stdin;
7db861ae-2195-4937-933e-85b2a7ac2864	8a669d55-0127-4039-8dbd-181a52f347f3	4602441014019	EAN13	100.000	RUB	6.000
16c1fb79-5acb-45f9-83f2-dff4ad977bdd	c3497b27-4a8a-4f56-b12d-f4d1f215c9a9	54491472	EAN8	1000.000	RUB	20.000
\.


--
-- Data for Name: total_day_consumption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.total_day_consumption (user_id, barcode_code, barcode_kind, cost, currency, quantity, create_date) FROM stdin;
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	4602441014019	EAN13	0.000	RUB	6.000	2022-07-13 00:00:00+03
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	54491472	EAN8	0.000	RUB	2.000	2022-07-13 00:00:00+03
\.


--
-- Data for Name: total_day_purchase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.total_day_purchase (user_id, barcode_code, barcode_kind, price, currency, quantity, create_date) FROM stdin;
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	4602441014019	EAN13	100.000	RUB	6.000	2022-07-13 00:00:00+03
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	54491472	EAN8	1000.000	RUB	20.000	2022-07-13 00:00:00+03
\.


--
-- Data for Name: total_month_shops; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.total_month_shops (user_id, shop_name, count_of_orders, create_date) FROM stdin;
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Пятерочка	0	2022-06-12
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Ашан	4	2022-07-13
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Атак	5	2022-07-13
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	Пятерочка	4	2022-07-13
908bfa28-cd79-4a0f-a1a0-7f900d04c3bd	purpose	0	2022-07-13
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
    ADD CONSTRAINT products_pkey PRIMARY KEY (barcode_code, barcode_kind, user_id);


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
    ADD CONSTRAINT total_day_consumption_pkey PRIMARY KEY (user_id, barcode_code, barcode_kind, currency, create_date);


--
-- Name: total_day_purchase total_day_purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.total_day_purchase
    ADD CONSTRAINT total_day_purchase_pkey PRIMARY KEY (user_id, barcode_code, barcode_kind, currency, create_date);


--
-- Name: total_month_shops total_month_shops_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.total_month_shops
    ADD CONSTRAINT total_month_shops_pkey PRIMARY KEY (user_id, shop_name, create_date);


--
-- Name: products_barcode_code_barcode_kind_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_barcode_code_barcode_kind_idx ON public.products USING btree (barcode_code, barcode_kind);


--
-- Name: consumption_detail consumption_detail_update_totat_day_consumption; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER consumption_detail_update_totat_day_consumption AFTER INSERT OR DELETE OR UPDATE ON public.consumption_detail FOR EACH ROW EXECUTE FUNCTION public.cud_total_day_consumption();


--
-- Name: purchases_detail purchases_detail_update_totat_day_purchase; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER purchases_detail_update_totat_day_purchase AFTER INSERT OR DELETE OR UPDATE ON public.purchases_detail FOR EACH ROW EXECUTE FUNCTION public.cud_total_day_purchase();


--
-- Name: purchases purchases_update_count_of_shops; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER purchases_update_count_of_shops AFTER INSERT OR DELETE OR UPDATE ON public.purchases FOR EACH ROW EXECUTE FUNCTION public.update_count_of_shops();


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

