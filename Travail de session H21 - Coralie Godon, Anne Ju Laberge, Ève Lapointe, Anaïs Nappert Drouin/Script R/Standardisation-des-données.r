# changer directory pour l'endroit où on veut aller chercher les données
# setwd("~/Desktop/BIO500") 
setwd("C:/Users/Anne Ju/Desktop/Ann�e 2021/H21/M�thode computationnelle/Willian/Donn�es")
library(dplyr)


################################################## 1. Noeuds ###########################################################
################################################# 1.1 Importation des données ########################################

# On importe les fichiers csv dans Rstudio sous forme de liste
# Utilisation de fileEncoding = 'UTF-8-BOM', sinon il peut y avoir des erreurs inattendues dans les noms de colonnes 
List_noeuds1 <- read.csv("AABBB_noeuds.csv", sep=";", fileEncoding = 'UTF-8-BOM')
List_noeuds2 <- read.csv("Auger_etal_noeuds.csv", sep=";", fileEncoding = 'UTF-8-BOM')
List_noeuds3 <- read.csv("Drouin_etal_noeuds.csv", sep=";", fileEncoding = 'UTF-8-BOM')
List_noeuds4 <- read.csv("Meriel_etal_noeuds.csv", sep=";", fileEncoding = 'UTF-8-BOM')
List_noeuds5 <- read.csv("Teamdefeu_noeuds.csv", sep=";", fileEncoding = 'UTF-8-BOM')
List_noeuds6 <- read.csv("Vachon_etal_noeuds.csv", sep=";", fileEncoding = 'UTF-8-BOM')

########################################## 1.2 Uniformisation des données ##############################################
############################################### Renommer les colonnes #################################################

# Les colonnes sont nom_prenom, session_debut, programme, coop, BIO500
# On renomme les colonnes qui ne sont pas bien ?crites dans chaque liste: nom->nom_prenom et session->session_debut
List_noeuds3.1 <- rename(List_noeuds3, session_debut=session)
List_noeuds4.1 <- rename(List_noeuds4, nom_prenom=nom)

############################################## Ajout de colonnes #####################################################
#Ajout d'une colonne pour le document de "Auger_etal_noeuds.csv" car il manque la colonne BIO500 pour cette liste
#Creation d'un vecteur pour la nouvelle colonne
colonne <- c(1,1,1,1)
#Verification du format de la colonne. On le veut en integer c'est le cas pour cette colonne de toutes les autres listes
is.integer(colonne)
#Tranforme la nouvelle colonne en format integer
colonne_BIO500 <- as.integer(colonne)
#On verifie si le format est bien integer maintenant
is.integer(colonne_BIO500)
#On renomme le titre de la colonne pour BIO500
names(colonne_BIO500)<- c("BIO500")
#On integre la nouvelle colonne dans la liste
List_noeuds2.1<-cbind(List_noeuds2, colonne_BIO500)
#On renomme la colonne BIO500
List_noeuds2.2 <- rename(List_noeuds2.1, BIO500=colonne_BIO500)

#Modifier le format de List_noeuds5 colonne "coop" (passer de character ? integer), car c'est le format pour cette colonne dans les autres listes
List_noeuds5.1 <- transform(List_noeuds5, coop = as.integer(coop))

############################################## 1.3 Mise en commun des liste ##############################################
#Combiner les diff?rentes listes ensemble
data_noeuds <- bind_rows(List_noeuds1, List_noeuds2.2, List_noeuds3.1, List_noeuds4.1, List_noeuds5.1, List_noeuds6)

############################################ 1.4 Vérification des erreurs ##############################################
#Sortir tous les ?l?ments uniques pour voir s'il y a des erreurs dans l'?criture des noms ou des programmes ou autre
sort(unique(data_noeuds[,1]))
sort(unique(data_noeuds[,2]))
sort(unique(data_noeuds[,3]))
sort(unique(data_noeuds[,4]))
sort(unique(data_noeuds[,5]))

########################################### 1.5 Correction des erreurs #################################################

#Il y a pr?sence d'erreurs dans l'?criture des noms et des programmes
#Il y avait lesperance_laurie et lesperance_laurie, micrbiologie et microbiologie, moleculaire et biologie_moleculaire, biologie et general
#?crire tout de la m?me fa?on
data_noeuds$nom_prenom[data_noeuds$nom_prenom=="lesp?rance_laurie"]<-"lesperance_laurie"
data_noeuds$programme[data_noeuds$programme=="micrbiologie"]<-"microbiologie"
data_noeuds$programme[data_noeuds$programme=="moleculaire"]<-"biologie_moleculaire"
data_noeuds$programme[data_noeuds$programme=="biologie"]<-"general"

############################################## 1.6 Enlever les doublons ##################################################
noeuds_unique<- data_noeuds[!duplicated(data_noeuds$nom_prenom),]

############################################# 1.7 Enregistrement #########################################################
write.csv2(noeuds_unique,'data_noeuds.csv', row.names=FALSE, quote=FALSE)


#################################################### 2. Cours ########################################################
############################################ 2.1 Importer données #######################################################

# Utilisation de fileEncoding = 'UTF-8-BOM', sinon il peut y avoir des erreurs inattendues dans les noms de colonnes 
liste_cours1 <- read.csv("Drouin_etal_cours.csv",header=TRUE, sep=';', fileEncoding = 'UTF-8-BOM')
liste_cours2 <- read.csv("Auger_etal_cours.csv", header=TRUE,sep=';', fileEncoding = 'UTF-8-BOM')
liste_cours3 <- read.csv("AABBB_cours.csv", header=TRUE,sep=';', fileEncoding = 'UTF-8-BOM')
liste_cours4 <- read.csv("Meriel_etal_cours.csv", header=TRUE,sep=';', fileEncoding = 'UTF-8-BOM')
liste_cours5 <- read.csv("Teamdefeu_cours.csv", header=TRUE,sep=';', fileEncoding = 'UTF-8-BOM')
liste_cours6 <- read.csv("Vachon_etal_cours.csv", header=TRUE,sep=';', fileEncoding = 'UTF-8-BOM')

############################################# 2.2 Changer noms colonnes ##################################################
# nous avons remarqué que les noms des colonnes ne sont pas tous pareils et que dans les fichiers pour "cours" certain 
#ont nommé la colonne "credits" credit ou credits, nous allons donc l'uniformiser pour credits avec le package dplyr

liste_cours1.2<-rename(liste_cours1,credits=credit)

############################################ 2.3 Mise en commun des listes ################################################

data_cours<- bind_rows(liste_cours1.2,liste_cours2,liste_cours3,liste_cours4,liste_cours5,liste_cours6)

########################################### 2.4 Retirer des lignes ######################################################
# Certaines entrées au sigle identique mais réalisés à des sessions différentes font qu'on pouvait retrouver deux fois 
# le même cours suivi en présentiel et à distance simultanément, la formule avec laquelle la majorité des gens 
# participant à BIO500 ont suivi le cours (présentiel ou à distance) a été choisie et les lignes comportant 
# l'alternative éliminées. Nous devions donc éliminer les lignes 9,10,84,142,143,107

cours_nd<-data_cours[-c(9,10,84,107,142,143),]

############################################ 2.5 Enlever doublons ########################################################

cours_unique <- cours_nd[!duplicated(cours_nd$sigle),]

############################################# 2.6 Enregistrement #########################################################
write.csv2(cours_unique,'data_cours.csv',row.names=FALSE, quote=FALSE)


########################################### 3. Collaboration #########################################################
########## 3.1 Importation des fichiers Excel de chaque ?quipe dans R ? l'aide de listes #############################

# Utilisation de fileEncoding = 'UTF-8-BOM', sinon il peut y avoir des erreurs inattendues dans les noms de colonnes 
# La fonction stringsAsFactors est utilisée pour indiquer que le datafram devrait être considéré en facteurs sinon il y a erreur lors de la correction de certaines erreurs de frappe
liste_collab1 <- read.csv("AABBB_collaborations.csv", sep=';', stringsAsFactors=FALSE, fileEncoding = 'UTF-8-BOM')
liste_collab2 <- read.csv("Drouin_etal_collaborations.csv", sep=';', stringsAsFactors=FALSE, fileEncoding = 'UTF-8-BOM')
liste_collab3 <- read.csv("Teamdefeu_collaborations.csv", sep=';', stringsAsFactors=FALSE, fileEncoding = 'UTF-8-BOM') 
liste_collab4 <- read.csv("Auger_etal_collaborations.csv", sep=';', stringsAsFactors=FALSE, fileEncoding = 'UTF-8-BOM')
liste_collab5 <- read.csv("Meriel_etal_collaborations.csv", sep=';', stringsAsFactors=FALSE, fileEncoding="UTF-8-BOM") 
liste_collab6 <- read.csv("Vachon_etal_collaborations.csv",sep=';', stringsAsFactors=FALSE, fileEncoding = 'UTF-8-BOM')

head(liste_collab1) # Cette fonction permet de visualiser les 6 premi?res lignes des donn?es de liste_collab1

######################################## 3.2 Uniformisation des colonnes #################################################
# Les colonnes n?cessaires dans cette base de donn?es soit : 
# - etudiant1
# - etudiant2
# - cours
# - date
# Afin de v?rifier s'il y a des erreurs dans les colonnes des bases de donn?es de chaque ?quipe, nous avons proc?d? ? la fonciton head().
# head(liste_collab1) # Pas de probl?me
# head(liste_collab2) # Colonne date nomm?e session 
# head(liste_collab3) # Pas de probl?me 
# head(liste_collab4) # Pas de probl?me avec les 4 colonnes n?cessaires, pr?sence de 2 colonnes pas n?cessaires (Participation Bio500)
# head(liste_collab5) # Colonne date nomm?e session
# head(liste_collab6) # Pas de probl?me 

# Pour changer les titres de colonnes "session" pour "date" :
liste_collab2_rn <- rename(liste_collab2, date=session)
liste_collab5_rn <- rename(liste_collab5, date=session)

# Pour enlever les 2 colonnes de trop dans la base liste_collab4 :

liste_collab4_sd <- liste_collab4[,-c(2,4)]

##############################  3.3 Mise en commun des bases de donn?es ##########################################

data_collab <- bind_rows(liste_collab1, liste_collab2_rn, liste_collab3, liste_collab4_sd, liste_collab5_rn, liste_collab6)

##############################  3.4 ?limination des doublons dans la base de donn?es ######################################

collab_unique <- data_collab[!duplicated(data_collab),]

############################  3.5 Corrections des erreurs du type erreur de frappe ########################################

# Les erreurs dans la base de donn?es sont regard?es une ? une afin de s'assurer que tout concorde. 
# Les informations sont ajust?es au meilleur des connaissances des membres de cette ?quipe sur les gens de la cohorte et sur les cours 

# Afin de v?rifier s'il y a des erreurs de frappes dans les noms de la colonne etudiant1, utiliser la fonction suivante :
# sort(unique(collab_unique[,1]))

# Les erreurs sont les suivantes pour la colonne etudiant1 :
#   - "johannie_gagnon" au lieu de gagnon_joannie
#   - "lesp?rance_laurie" au lieu de lesperance_laurie
#   - "michaudleblanc_ester" au lieu de michaudleblanc_esther
#   - "ouelette_laury" au lieu de ouellet_laury
#   - "pelletier_karlphillippe" au lieu de pelletier_karlphilippe

collab_unique$etudiant1[collab_unique$etudiant1 == "johannie_gagnon"] <- "gagnon_joannie"
collab_unique$etudiant1[collab_unique$etudiant1 == "lesp?rance_laurie"] <- "lesperance_laurie"
collab_unique$etudiant1[collab_unique$etudiant1 == "michaudleblanc_ester"] <- "michaudleblanc_esther"
collab_unique$etudiant1[collab_unique$etudiant1 == "ouelette_laury"] <- "ouellet_laury"
collab_unique$etudiant1[collab_unique$etudiant1 == "pelletier_karlphillipe"] <- "pelletier_karlphilippe"
# sort(unique(collab_unique[,1])) # L'utilisation de cette fonction est simplement pour v?rifier si les bons changements ont ?t? faits

# Afin de v?rifier s'il y a des erreurs de frappes dans les noms de la colonne etudiant2, utiliser la fonction suivante :
# sort(unique(collab_unique[,2]))
# Les erreurs sont les suivantes pour la colonne etudiant2 :
#   - "johannie_gagnon" au lieu de gagnon_joannie
#   - "lesp?rance_laurie" au lieu de lesperance_laurie
#   - "michaudleblanc_ester" au lieu de michaudleblanc_esther
#   - "pelletier_karlphillippe" au lieu de pelletier_karlphilippe

collab_unique$etudiant2[collab_unique$etudiant2 == "johannie_gagnon"] <- "gagnon_joannie"
collab_unique$etudiant2[collab_unique$etudiant2 == "lesp�rance_laurie"] <- "lesperance_laurie"
collab_unique$etudiant2[collab_unique$etudiant2 == "michaudleblanc_ester"] <- "michaudleblanc_esther"
collab_unique$etudiant2[collab_unique$etudiant2 == "pelletier_karlphillipe"] <- "pelletier_karlphilippe"
# sort(unique(collab_unique[,2])) # L'utilisation de cette fonction est simplement pour v?rifier si les bons changements ont ?t? faits

# Pr�sence de deux lignes dans la base de donn�es o� le nom de etudiant1 = le nom de etudiant2
collab_unique <- subset(collab_unique, !(etudiant1 == "bernier_raphael" & etudiant2 == "bernier_raphael"))
collab_unique <- subset(collab_unique, !(etudiant1 == "chiasson_jessica" & etudiant2 == "chiasson_jessica"))

# Afin de v?rifier s'il y a des erreurs de frappes dans les noms de la colonne cours, utiliser la fonction suivante :
# sort(unique(collab_unique[,3]))
# Les erreurs sont les suivantes pour la colonne cours :
#   - "BIO110" au lieu de BIO101
#   - Cours ECL604 -> pas de travail d'?quipe dans ce cours, donc nous enlevons la ligne au complet

collab_unique$cours[collab_unique$cours == "BIO110"] <- "BIO101"
collab_unique <- subset(collab_unique, cours != "ECL604")
# sort(unique(collab_unique[,3])) # L'utilisation de cette fonction est simplement pour v?rifier si les bons changements ont ?t? faits

# Afin de v?rifier s'il y a des erreurs de frappes dans les noms de la colonne date, utiliser la fonction suivante :
# sort(unique(collab_unique[,4]))
# Les erreurs sont les suivantes pour la colonne date :
#   - "E19" au lieu de E20
#   - "H1" au lieu de H19
#   - "A21" au lieu de A20

collab_unique$date[collab_unique$date == "E19"] <- "E20"
collab_unique$date[collab_unique$date == "H1"] <- "H19"
collab_unique$date[collab_unique$date == "A21"] <- "A20"

# Afin de s'assurer de bien n'avoir plus de doublons
collab_unique <- collab_unique[!duplicated(collab_unique),]

# sort(unique(collab_unique[,4])) # L'utilisation de cette fonction est simplement pour v?rifier si les bons changements ont ?t? faits

################################### Enregistrement de la base de donn?es ###############################################

# Fonction pour enregistrer la base de donn?es de collaborations, soit les liens entre chaque ?tudiant

write.csv2(collab_unique, 'data_collab.csv', row.names = F, quote=FALSE)

#### FIN ####