# MM50 Protein
# The purpose of this file is to merge & tidy 4 excel files. 
# These will then go into a Tableau workbook and merged with another 2 files.

library(readxl)
library(dplyr)
library(stringi)
library(tidyr)
library(openxlsx)

# Read in the data sets
df1       <- read_xlsx("C:/Users/OConnor Analytics/Working Files/MakeoverMonday/Makeover.Monday/mm50.land.use.per.oz.protein/USDA.Isoleucine.Leucine.Lysine..xlsx")     
df2       <- read_xlsx("C:/Users/OConnor Analytics/Working Files/MakeoverMonday/Makeover.Monday/mm50.land.use.per.oz.protein/USDA.Methionine.Cysteine.Tryptophan.xlsx")     
df3       <- read_xlsx("C:/Users/OConnor Analytics/Working Files/MakeoverMonday/Makeover.Monday/mm50.land.use.per.oz.protein/USDA.Phenylalanine.Tyrosine.Threonine.xlsx")     
df4       <- read_xlsx("C:/Users/OConnor Analytics/Working Files/MakeoverMonday/Makeover.Monday/mm50.land.use.per.oz.protein/USDA.Valine.Histidine.Protein.xlsx")     

# Merge
df5 <-  merge(df1,df2)
df6 <-  merge(df5, df3)
df7 <-  merge(df6, df4)

# mutate & tidy
df8 <- df7 %>%
  mutate(Methionine.Cysteine = `Methionine(g)Per 100 g` +`Cystine(g)Per 100 g` )%>%
  mutate(Phenylalanine.Tyrosine = `Phenylalanine(g)Per 100 g` + `Tyrosine(g)Per 100 g`) %>%
  select(NDB_NO:`Leucine(g)Per 100 g`, `Tryptophan(g)Per 100 g`,`Threonine(g)Per 100 g`:`Histidine(g)Per 100 g`, Methionine.Cysteine:Phenylalanine.Tyrosine, `Protein(g)Per 100 g`)
names(df8)[3:9] <- c("Isoleucine", "Lysine", "Leucine", "Tryptophan", "Threonine", "Valine", "Histidine")
names(df8)[12]  <- "Protein"

#this code calculates the Amino Acid grams per 100 grams of protein for each food item
#then removes the original metric of AA grams per 100 grams of food item
df9 <- cbind(df8, apply(df8[,3:11], 2, function(x) x*100/df8$Protein))
names(df9)[13:21] <- paste0(names(df9)[3:11], 'P100GP')
df10  <- df9 %>%
  select(NDB_NO:Description, Protein:Phenylalanine.TyrosineP100GP)
names(df10)[4:12] <- gsub('P100GP', "", names(df10)[4:12])
  
df11 <- gather(df10, key=AminoAcid, value=g.per.100g.prot, Isoleucine:Phenylalanine.Tyrosine)



#output
dest.file       <- "C:/Users/OConnor Analytics/Working Files/MakeoverMonday/Makeover.Monday/mm50.land.use.per.oz.protein/proteins.xlsx"

write.xlsx(df11, dest.file)
