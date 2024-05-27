CREATE VIEW public.genre_dim_view AS
SELECT
    genre_key,
    genre_name
FROM
    public.genre_dim_table;