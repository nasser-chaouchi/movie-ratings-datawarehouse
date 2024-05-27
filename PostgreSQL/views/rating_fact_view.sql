CREATE VIEW public.rating_fact_view AS
SELECT
    user_key,
    movie_key,
    date_key,
    time_key,
    rating
FROM
    public.rating_fact_table;