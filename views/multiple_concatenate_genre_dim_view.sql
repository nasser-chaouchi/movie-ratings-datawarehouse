CREATE VIEW public.multiple_concatenate_genre_dim_view AS
SELECT
    multiple_concatenate_genre_key,
    multiple_concatenate_genre_name
FROM
    public.multiple_concatenate_genre_dim_table;