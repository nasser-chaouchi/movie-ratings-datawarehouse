CREATE TABLE IF NOT EXISTS public.professional_dim_table
(
    professional_key serial PRIMARY KEY,
    nconst character varying(255),
    name character varying(255),
    multiple_concatenate_profession_key integer,
    birthyear integer,
    deathyear integer
);
