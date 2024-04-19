import mysql.connector
import pandas as pd

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="Z6NV)4uf65^kc=",
        database="mydb",
        allow_local_infile=True  # Activer le chargement de données locales côté client
    )

    cursor = conn.cursor()
    load_data_sql = """
        LOAD DATA LOCAL INFILE '../imdb_dataset/data_name_basics.tsv'
        INTO TABLE data_name_basics
        FIELDS TERMINATED BY '\t'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (nconst, primaryName, birthYear, deathYear, @primaryProfession, @knownForTitles)
        SET primaryProfession = JSON_ARRAY(@primaryProfession),
            knownForTitles = JSON_ARRAY(@knownForTitles);
    """

    cursor.execute(load_data_sql)

    conn.commit()

except mysql.connector.Error as err:
    print("Erreur lors de la connexion à MySQL:", err)

finally:
    if 'conn' in locals() and conn.is_connected():
        cursor.close()
        conn.close()
        print("Connexion MySQL fermée.")
