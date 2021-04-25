# Choisir le "working directory" selon où sont les données dans l'ordinateur 
setwd("C:/Users/Anne Ju/Desktop/Année 2021/H21/Méthode computationnelle/Willian/Données")

# Installation du package RSQLite pour créer la base de donnée, avec la fonction :
# install.packages('RSQLite')
library(RSQLite)

con <- dbConnect(SQLite(), dbname="reseau.db")

#### 1. Création de la table noeuds ####

noeuds <- '
CREATE TABLE noeuds 
(nom_prenom VARCHAR (50),
session_debut CHAR (3),
programme VARCHAR (20),
coop BOLEAN (1),
BIO500 BOLEAN (1),
PRIMARY KEY (nom_prenom)
);'
dbSendQuery(con, noeuds)


#### 2. Création de la table cours ####

cours <- '
CREATE TABLE cours 
(sigle VARCHAR (6),
credits INTEGER (1),
presentiel BOLEAN (1),
libre BOLEAN (1),
PRIMARY KEY (sigle)
);'
dbSendQuery(con, cours)

#### 3. Création de la table collaborations ####

collab <- '
CREATE TABLE collab 
(etudiant1 VARCHAR (100),
etudiant2 VARCHAR (100),
cours VARCHAR (6),
date CHAR (3),
PRIMARY KEY (etudiant1, etudiant2, cours, date)
FOREIGN KEY (etudiant1) REFERENCES noeuds(nom_prenom),
FOREIGN KEY (etudiant2) REFERENCES noeuds(nom_prenom),
FOREIGN KEY (cours) REFERENCES cours(sigle)
);'
dbSendQuery(con, collab)

# La fonction suivante est utilisée afin de bien vérifier si les trois tables créer se trouve dans l'objet con
dbListTables(con)

# Afin de déconnecter l'objet con
dbDisconnect(con)

#### FIN ####
