CREATE TABLE IF NOT EXISTS public.date_dim_table
(
    date_key integer PRIMARY KEY,
    full_date date,
    year integer,
    month integer,
    day integer
)