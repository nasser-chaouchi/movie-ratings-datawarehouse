CREATE TABLE IF NOT EXISTS public.rating_fact_table
(
    user_key integer NOT NULL,
    movie_key integer NOT NULL,
    date_key integer NOT NULL,
    time_key integer NOT NULL,
    rating integer,
    PRIMARY KEY (user_key, movie_key, date_key, time_key)
);
