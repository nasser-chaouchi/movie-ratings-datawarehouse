CREATE TABLE IF NOT EXISTS public.multiple_professional_dim_table
(
    multiple_concatenate_professional_key integer NOT NULL,
    professional_key character varying COLLATE pg_catalog."default" NOT NULL,
    PRIMARY KEY (multiple_concatenate_professional_key, professional_key)
)