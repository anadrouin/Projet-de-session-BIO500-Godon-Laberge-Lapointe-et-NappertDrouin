# Choisir le "directory" selon l'ordinateur
setwd("C:/Users/Anne Ju/Desktop/Ann�e 2021/H21/M�thode computationnelle/Willian/Donn�es")

# Se connecter au SQLite, si ce n'est pas d�j� fait :
library(RSQLite)
con <- dbConnect(SQLite(), dbname="reseau.db")


#### 1. Injection des donn�es de la table noeuds ####

bd_noeuds <- read.csv(file="data_noeuds.csv", header =T, sep=";")
dbWriteTable(con, append = T, name = "noeuds", value = bd_noeuds, row.names = F)

#### 2. Injection des donn�es de la table cours ####

bd_cours <- read.csv(file="data_cours.csv", header =T, sep=";")
dbWriteTable(con, append = T, name = "cours", value = bd_cours, row.names = F)

#### 3. Injection des donn�es de la table collab ####

bd_collab <- read.csv(file="data_collab.csv", header = T, sep=";")
dbWriteTable(con, append = T, name = "collab", value = bd_collab, row.names = F)

#### 4. Les requ�tes ####
####  4.1 Le r�seau de collaborations ####

requete_reseau <- "
SELECT etudiant1, etudiant2, count(*) AS nb_collaborations
FROM collab 
GROUP BY etudiant1, etudiant2;"
res <- dbGetQuery(con, requete_reseau)
head(res)

####  4.2 Les collaborations pr�-covid ####

requete_pre <- "
SELECT etudiant1, etudiant2, count(*) AS nb_collaborations
FROM collab WHERE date LIKE 'H18' OR date LIKE 'A18' OR date LIKE 'H19' OR date LIKE 'A19' OR date LIKE 'H20'
GROUP BY etudiant1, etudiant2;"
pre <- dbGetQuery(con, requete_pre)
head(pre)

####  4.3 Les collaborations post-covid ####

requete_post <- "
SELECT etudiant1, etudiant2, count(*) AS nb_collaborations
FROM collab WHERE date LIKE 'E20' OR date LIKE 'A20' OR date LIKE 'H21'
GROUP BY etudiant1, etudiant2;"
post <- dbGetQuery(con, requete_post)
head(post)

####  4.4 Les collaborations de chaque �tudiant et �tudiante de BIO500 pr� et post covid

requete_tableau <- "
SELECT date, count(date) AS nb_collaborations 
FROM collab 
GROUP BY date;"
tableau <- dbGetQuery(con, requete_tableau)
head(tableau)

#### 5. Les figures et tableau ####

# Pour g�n�rer des visualisation de r�seaux, il faut installer le package igraph avec la fonction suivante 
# install.packages("igraph")
# install.packages("tidyr")
# install.packages("reshape2")

library(igraph)
library(reshape2)


####  5.1 La repr�sentation du r�seau complet ####
dev.new(width = 10, height = 7)

res2 <- subset(res, etudiant2%in%etudiant1)
res3 <- subset(res2, etudiant1%in%etudiant2)
reseau <- acast(res3, etudiant1~etudiant2, value.var='nb_collaborations')

figure_reseau<-graph.adjacency(reseau)
figure_reseau<- simplify(figure_reseau, remove.multiple = FALSE, remove.loops = TRUE)
plot(figure_reseau, vertex.size = 15*degree(figure_reseau)/max(degree(figure_reseau))+3,
                    vertex.color= as.character(factor(betweenness(figure_reseau), labels = rev(rainbow(length(unique(betweenness(figure_reseau))))))),
                    vertex.label= NA, vertex.label = NA, 
                    vertex.shape="circle", edge.arrow.size= 0,layout=layout.kamada.kawai(figure_reseau))

####  5.2 La repr�sentation des liens pr�-covid ####
dev.new(width = 10, height = 7)

pre2 <- subset(pre, etudiant2%in%etudiant1)
pre3 <- subset(pre2, etudiant1%in%etudiant2)
precovid <- acast(pre3, etudiant1~etudiant2, value.var='nb_collaborations')

figure_pre<-graph.adjacency(precovid)
figure_pre<- simplify(figure_pre, remove.multiple = FALSE, remove.loops = TRUE)
graph_pre<-plot(figure_pre, vertex.size = 15*degree(figure_pre)/max(degree(figure_pre))+3,
                vertex.color= as.character(factor(betweenness(figure_pre), labels = rev(rainbow(length(unique(betweenness(figure_pre))))))),
                vertex.label= NA, vertex.label = NA, 
                vertex.shape="circle", edge.arrow.size= 0,layout=layout.kamada.kawai(figure_pre))

####  5.3 La repr�sentation des liens post-covid ####
dev.new(width = 10, height = 7)

post2 <- subset(post, etudiant2%in%etudiant1)
post3 <- subset(post2, etudiant1%in%etudiant2)
postcovid <- acast(post3, etudiant1~etudiant2, value.var='nb_collaborations')

figure_post <- graph.adjacency(postcovid)
figure_post<- simplify(figure_post, remove.multiple = FALSE, remove.loops = TRUE)
graph_post<-plot(figure_post, vertex.size = 15*degree(figure_post)/max(degree(figure_post))+3,
                vertex.color= as.character(factor(betweenness(figure_post), labels = rev(rainbow(length(unique(betweenness(figure_post))))))),
                vertex.label= NA, vertex.label = NA, 
                vertex.shape="circle", edge.arrow.size= 0,layout=layout.kamada.kawai(figure_post))

####  5.4 Le tableau repr�sentant les liens pr� et post covid des �tudiants du cours BIO500 ####

write.csv2(tableau, "tableau.csv", row.names = F, quote = F)

#### Pour d�connecter l'objet con ####
dbDisconnect(con)

#### FIN ####