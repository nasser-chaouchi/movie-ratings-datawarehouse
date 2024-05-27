CREATE TABLE IF NOT EXISTS public.movie_dim_table
(
    movie_key SERIAL PRIMARY KEY,
    title text,
    movieid integer,
    tconst character varying(255),
    multiple_concatenate_genre_key integer,
    multiple_concatenate_professional_key integer,
    releasedate integer,
    averagerating integer,
    num_votes integer
);