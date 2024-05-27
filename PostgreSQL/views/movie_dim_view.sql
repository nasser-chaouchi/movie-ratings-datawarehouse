CREATE VIEW public.movie_dim_view AS
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
    t.runtimeminutes
FROM
    public.movie_dim_table m
LEFT JOIN
    public.title_basics t
ON
    m.tconst = t.tconst;