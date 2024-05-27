CREATE TABLE IF NOT EXISTS public.multiple_genre_dim_table
(
    multiple_concatenate_genre_key integer NOT NULL,
    genre_key integer NOT NULL,
    PRIMARY KEY (multiple_concatenate_genre_key, genre_key)
);
