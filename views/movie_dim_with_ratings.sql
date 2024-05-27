CREATE VIEW public.movie_dim_with_ratings AS
SELECT
    m.movie_key,
    m.title,
    m.movieid,
    m.tconst,
    m.multiple_concatenate_genre_key,
    m.multiple_concatenate_professional_key,
    m.releasedate,
    m.averagerating,
    m.num_votes,
    r.total_ratings,
    r.number_of_ratings,
    (m.averagerating * m.num_votes + r.total_ratings * 2) / (m.num_votes + r.number_of_ratings) AS weighted_average_rating
FROM
    public.movie_dim_view m
LEFT JOIN
    public.movie_rating_aggregates r
ON
    m.movie_key = r.movie_key;