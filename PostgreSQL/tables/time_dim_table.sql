CREATE TABLE IF NOT EXISTS public.time_dim_table
(
    time_key integer PRIMARY KEY,
    time_value character(8) NOT NULL,
    hours_24 character(2) NOT NULL,
    hours_12 character(2) NOT NULL,
    hour_minutes character(2) NOT NULL,
    day_minutes integer NOT NULL,
    seconds character(2) NOT NULL
);