CREATE VIEW public.multiple_genre_dim_view AS
SELECT
    multiple_concatenate_genre_key,
    genre_key
FROM
    public.multiple_genre_dim_table;