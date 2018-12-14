library(threejs)
library(htmlwidgets)

df = read.csv("./Data/country_data.csv")

MyJ3=scatterplot3js(df$counts,df$nkill,df$nwound,
                    axisLabels=c("Count", "Death","Wound"), labels=df$country_txt)
saveWidget(MyJ3, file="3D.html", selfcontained = TRUE, libdir = NULL,background = "white")
