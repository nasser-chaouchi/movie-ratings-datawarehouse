COPY (SELECT * FROM public.date_dim_view) TO 'D:\MAGVD\view\date_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.time_dim_view) TO 'D:\MAGVD\view\time_dim_view.csv' WITH CSV HEADER;

COPY (SELECT * FROM user_dim_view) TO 'D:\MAGVD\view\user_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.professional_dim_view) TO 'D:\MAGVD\view\professional_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.profession_dim_view) TO 'D:\MAGVD\view\profession_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.genre_dim_view) TO 'D:\MAGVD\view\genre_dim_view.csv' WITH CSV HEADER;

COPY (SELECT * FROM public.multiple_professional_dim_view) TO 'D:\MAGVD\view\multiple_professional_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.multiple_profession_dim_view) TO 'D:\MAGVD\view\multiple_profession_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.multiple_genre_dim_view) TO 'D:\MAGVD\view\multiple_genre_dim_view.csv' WITH CSV HEADER;

COPY (SELECT * FROM public.multiple_concatenate_profession_dim_view) TO 'D:\MAGVD\view\multiple_concatenate_profession_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.multiple_concatenate_professional_dim_view) TO 'D:\MAGVD\view\multiple_concatenate_professional_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.multiple_concatenate_genre_dim_view) TO 'D:\MAGVD\view\multiple_concatenate_genre_dim_view.csv' WITH CSV HEADER;

COPY (SELECT * FROM public.movie_dim_view) TO 'D:\MAGVD\view\movie_dim_view.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.movie_rating_aggregates) TO 'D:\MAGVD\view\movie_rating_aggregates.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.movie_dim_with_ratings) TO 'D:\MAGVD\view\movie_dim_with_ratings.csv' WITH CSV HEADER;
COPY (SELECT * FROM public.rating_fact_view) TO 'D:\MAGVD\view\rating_fact_view.csv' WITH CSV HEADER;