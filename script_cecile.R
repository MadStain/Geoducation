# Initialisation du r�pertoire courant et importation des donn�es
chemin <- getwd()
setwd(chemin)
bdd_complet <- read.csv2(file="geoducation-data2_cecile.csv", sep=";", header=TRUE, na.strings = "")
#names(bdd_complet)

#affichage des donn�es
#summary(bdd_complet)
#bdd_complet

#####################
# R�gression simple #
#####################

# [1] Extraction des champs qui nous interessent
chu_reg_simple_extrac_data = bdd_complet[, c('Etablissement','Code.Etablissement','Effectif.Pr�sents.Total.s�ries','Taux.Brut.de.r�ussite.Total.s�ries')]

# [2] Renommage des colonnes
names(chu_reg_simple_extrac_data)[names(chu_reg_simple_extrac_data)=="Etablissement"] <- "Nom_lycee"
names(chu_reg_simple_extrac_data)[names(chu_reg_simple_extrac_data)=="Code.Etablissement"] <- "Code_lycee"
names(chu_reg_simple_extrac_data)[names(chu_reg_simple_extrac_data)=="Effectif.Pr�sents.Total.s�ries"] <- "Effectif_lycee"
names(chu_reg_simple_extrac_data)[names(chu_reg_simple_extrac_data)=="Taux.Brut.de.r�ussite.Total.s�ries"] <- "Taux_reussite"

# [3] Copie de l'extraction pour travailler dessus
chu_reg_simple_bdd = chu_reg_simple_extrac_data 

# [4] Nettoyage des donn�es
# suppression des lignes contenant des NA
chu_reg_simple_bdd <- na.omit(chu_reg_simple_bdd)
# conversion pour la reconnaissance des variables QUANTI
for (i in 3:ncol(chu_reg_simple_bdd)) {
  chu_reg_simple_bdd[, i] <- as.numeric(as.character(chu_reg_simple_bdd[, i]))
}
# visualisation g�n�rale des donn�es
str(chu_reg_simple_bdd)
summary(chu_reg_simple_bdd)
plot(Taux_reussite ~ Effectif_lycee, data=chu_reg_simple_bdd)
# Chaque point repr�sente pour un lyc�e donn�, l'effectif de l'�tablissement et son taux de r�ussite au baccalaur�at
# On remarque que la liaison entre les effectifs et le taux de r�ussite ne semble pas �tre lin�aire

# [5] Estimation du param�tre Effectif_lycee
# regression lin�aire : nuage de points + droite de regression
chu_reg_simple <- lm(Taux_reussite ~ Effectif_lycee, data=chu_reg_simple_bdd)
summary(chu_reg_simple)
chu_reg_simple
abline(chu_reg_simple, col = 'red')
# affichage de l'�quation de la droite de r�gression
title("Nuage de points & droite de regression")
text(400, 50, as.expression(substitute(y==b+a*x, list(
  a=round(chu_reg_simple$coefficients[2],3),
  b=round(chu_reg_simple$coefficients[1],3)
))), col = 'red')

# [6] Conclusion

# R�daction � revoir

# Std.Error = 0.251276 : Ecart-type associ� � l'estimation des effectifs est petite, ce qui signifie un gage de stabilit� du mod�le et donc du pouvoir pr�dictif (valeur de b stable)
# Residual standard error = 6.122 : Estimateur de l'�cart-type r�siduel est faible donc bon pouvoir pr�dictif mais DDL � 2286
# Multiple R-squared = 0.007084 : coeff de corr�lation (% de variations expliqu�es par le mod�le), R� doit �tre proche de 1 pour bon pouvoir explicatif

# le mod�le n'a pas un bon pouvoir explicatif sur les donn�es : R�=0.007084
# le pouvoir pr�dictif risque d'�tre entach� par l'instabilit� du coefficient b et une variance r�siduelle importante

#############################################################################


#######################
# R�gression multiple #
#######################

# [1] Extraction des champs qui nous interessent
chu_reg_multi_extrac_data = bdd_complet[, c(
  'Secteur.Public.PU.Priv�.PR',
  'Sructure.p.dagogique.en.7.groupes',
  'Effectif.Pr�sents.s�rie.L',
  'Effectif.Pr�sents.s�rie.ES', 
  'Effectif.Pr�sents.s�rie.S', 
  'Taux.Brut.de.r�ussite.s�rie.L', 
  'Taux.Brut.de.r�ussite.s�rie.ES',
  'Taux.Brut.de.r�ussite.s�rie.S',
  'Taux.Brut.de.r�ussite.Total.s�ries',
  'Taux.acc�s.Brut.premi.re.BAC',
  'Taux.acc�s.Brut.terminale.BAC'
)]

# [2] Renommage des colonnes
names(chu_reg_multi_extrac_data) <- c(
  'Secteur_lycee',
  'Sructure_lycee',
  'Effectif_L',
  'Effectif_ES', 
  'Effectif_S', 
  'Reussite_L', 
  'Reussite_ES',
  'Reussite_S',
  'Reussite_Total',
  'Acces_prem_BAC',
  'Acces_term_BAC'
)

# [3] Copie de l'extraction pour travailler dessus
chu_reg_multi_bdd = chu_reg_multi_extrac_data
str(chu_reg_multi_bdd)

# [4] Nettoyage des donn�es
# on ne s'interesse que aux donn�es des �tablissements avec uniquement des fili�res g�n�raux
chu_reg_multi_bdd <- subset(chu_reg_multi_bdd, Sructure_lycee == "A")
# suppression des lignes contenant des NA
chu_reg_multi_bdd <- na.omit(chu_reg_multi_bdd)
# suppression des colonnes non utilis�es pour la regression
chu_reg_multi_bdd <- chu_reg_multi_bdd[,-2]
# conversion pour la reconnaissance des variables QUANTI
for (i in 2:ncol(chu_reg_multi_bdd)) {
  chu_reg_multi_bdd[, i] <- as.numeric(as.character(chu_reg_multi_bdd[, i]))
}
# remplacement de la variable quali en quanti
chu_reg_multi_bdd[, 1] <- as.character(chu_reg_multi_bdd[, 1])
chu_reg_multi_bdd$Secteur_lycee[chu_reg_multi_bdd$Secteur_lycee=="PR"]<-"1"
chu_reg_multi_bdd$Secteur_lycee[chu_reg_multi_bdd$Secteur_lycee=="PU"]<-"0"
chu_reg_multi_bdd[, 1] <- as.numeric(chu_reg_multi_bdd[, 1])

# [5] Estimation des param�tres explicatives
chu_reg_multi <- lm(Reussite_Total ~ ., data=chu_reg_multi_bdd)
summary(chu_reg_multi)
chu_reg_multi
hist(resid(chu_reg_multi), col="grey", main="")

# exclure les param�tres 

# [6] Conclusion

# R� = 97% donc le mod�le est pr�cis
# Nous avons 97% de la variance du taux de r�ussite qui peut �tre expliqu�e par les variations de ... 

#############################################################################



