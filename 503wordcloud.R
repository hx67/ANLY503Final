library(tidyverse) 
library(data.table) 
library(countrycode) #Matching country names
library(plotly) #Interactive plots
library(viridis) #Color scales
library(tm) #Textmining for wordclouds
library(wordcloud) #Generation of wordclouds
library(leaflet) #Interactive maps
library(maps) #Maps generating

df <- read.csv("./data/globalterrorismdb_0718dist.csv")

descriptions <- trWW$summary[trWW$summary != ""] #Filters all filled descriptions

descriptions <- iconv(descriptions,"WINDOWS-1252","UTF-8")

words <- descriptions %>% as.character() %>%
  removePunctuation() %>% #Removes punctuation
  tolower() %>% #Converts all characters to lower case
  removeWords(stopwords()) %>% #Remove english stop words
  str_split(pattern = " ") %>% #Splits all lines into lists of words
  unlist() #converts all lists into a single concatenated vector

word_freq <- words %>% as.tibble() %>% #Converts into tibble
  filter(value != "", !str_detect(value, "^\\d*$")) %>% #Removes enpty and number-only words
  count(value)

pal <- brewer.pal(9, "BuGn")
pal <- pal[-(1:2)]

wordcloud(word_freq$value, word_freq$n, max.words = 75, colors = pal, random.order = FALSE)
