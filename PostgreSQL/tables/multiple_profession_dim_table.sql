CREATE TABLE IF NOT EXISTS public.multiple_profession_dim_table
(
    multiple_concatenate_profession_key integer NOT NULL,
    profession_key integer NOT NULL,
    PRIMARY KEY (multiple_concatenate_profession_key, profession_key)
)