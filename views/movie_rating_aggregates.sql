CREATE VIEW public.movie_rating_aggregates AS
SELECT
    movie_key,
    SUM(rating) AS total_ratings,
    COUNT(rating) AS number_of_ratings
FROM
    public.rating_fact_table
GROUP BY
    movie_key;