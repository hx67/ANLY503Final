############################################################################################
############################################################################################
# This code in its raw form
# comes from 
# https://www.r-bloggers.com/network-visualization-part-6-d3-and-r-networkd3/
# Additional Comments and code have been added by Ami Gates
# Plotting networks in R - an example how to plot a network and 
# customize its appearance using networkD3 library
############################################################################################
############################################################################################
#
library(igraph)
# Read a data set. 
# Data format: dataframe with 3 variables; variables 1 & 2 correspond to interactions; variable 3 is weight of interaction
edgeList <- read.csv("./Data/network_data.csv", header = TRUE)

colnames(edgeList) <- c("X","SourceName", "TargetName", "Weight")
drops <- c("X")
edgeList = edgeList[ , !(names(edgeList) %in% drops)]
(head(edgeList))

# Create a graph. Use simplyfy to ensure that there are no duplicated edges or self loops
gD <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=FALSE))
#plot(gD)
##V(igraph)$name returns the names of the verticesss
#(V(gD)$name)

# Create a node list object (actually a data frame object) that will contain information about nodes
nodeList <- data.frame(ID = c(0:(igraph::vcount(gD) - 1)), # because networkD3 library requires IDs to start at 0
                       nName = igraph::V(gD)$name)

(head(nodeList))

# Map node names from the edge list to node IDs
##which() function gives you the position of elements of a logical vector that are TRUE
## Given any vertex name, its position is a row number which goes to getNodeID
## getNodeID is a function that takes a name and returns a row location -1
getNodeID <- function(x){
  which(x == igraph::V(gD)$name) - 1 # to ensure that IDs start at 0
}

(getNodeID("Joly")) 
## This returns "2" 
# And add them to the edge list
# package plyr is used to perform, split-apply-combine procedures
# ddply is a plyr function that takes a df and variables to retain
## and then a function for adding new variables and data
## Here we use edgeList. We keep variables: SourceName and TargetName and weight
## Then we add on new variables SourceID and TargetID
## The new variables are created by applying a function that takes x
## and returns a df of the Source and Target for that x
(head(edgeList)) #This shows that currently, the vars in edgeList are
## SourceName, TargetName, and Weight
##Next - we keep all three current variables and we add two more
## SourceID  - the node ID for SourceName and
## TargetID - the node ID for Target name
edgeList <- plyr::ddply(edgeList, .variables = c("SourceName", "TargetName" , "Weight"), 
                        function (x) data.frame(SourceID = getNodeID(x$SourceName), 
                                                TargetID = getNodeID(x$TargetName)))

(head(edgeList))

############################################################################################
# Calculate some node properties and node similarities that will be used to illustrate 
# different plotting abilities and add them to the edge and node lists

# Calculate degree for all nodes
# recall that cbind is column bind 
# Node degree: number of links/edges associated with a node/vertex.
# Degree per node: edges entering the node ("in degree"), or exiting the node ("out degree"), or both.
# The degree() function: takes a graph input and returns the degree of specified nodes.
# v = igraph::V(gD): return the degree of all nodes in the graph gD,
# "mode" argument: can be in, out, or all
#(head(nodeList))
nodeList <- cbind(nodeList, nodeDegree=igraph::degree(gD, v = igraph::V(gD), mode = "all"))
#(head(nodeList))


# Calculate betweenness for all nodes
#The betweenness value for each node n is normalized 
#by dividing by the number of node pairs excluding n: (N-1)(N-2)/2, 
# RE: (((igraph::vcount(gD) - 1) * (igraph::vcount(gD)-2)) / 2)
#where N is the total number of nodes in the connected component that n belongs to. 
#Thus, the betweenness centrality of each node is a number between 0 and 1.
betAll <- igraph::betweenness(gD, v = igraph::V(gD), directed = FALSE) / (((igraph::vcount(gD) - 1) * (igraph::vcount(gD)-2)) / 2)
betAll.norm <- (betAll - min(betAll))/(max(betAll) - min(betAll))
nodeList <- cbind(nodeList, nodeBetweenness=100*betAll.norm) # We are scaling the value by multiplying it by 100 for visualization purposes only (to create larger nodes)
rm(betAll, betAll.norm)
(head(nodeList))


#Calculate Dice similarities between all pairs of nodes
#The Dice similarity coefficient of two vertices is twice 
#the number of common neighbors divided by the sum of the degrees 
#of the vertices. Method dice calculates the pairwise Dice similarities 
#for some (or all) of the vertices. 
dsAll <- igraph::similarity.dice(gD, vids = igraph::V(gD), mode = "all")
(head(dsAll))

#Create  data frame that contains the Dice similarity between any two vertices
F1 <- function(x) {data.frame(diceSim = dsAll[x$SourceID +1, x$TargetID + 1])}
#Place a new column in edgeList with the Dice Sim
(head(edgeList))
edgeList <- plyr::ddply(edgeList, .variables=c("SourceName", "TargetName", "Weight", "SourceID", "TargetID"), 
                        function(x) data.frame(F1(x)))
(head(edgeList))
rm(dsAll, F1, getNodeID, gD)

############################################################################################
# We will also create a set of colors for each edge, based on their dice similarity values
# We'll interpolate edge colors based on using the "colorRampPalette" function, that 
# returns a function corresponding to a color palette of "bias" number of elements (in our case, that
# will be a total number of edges, i.e., number of rows in the edgeList data frame)
F2 <- colorRampPalette(c("#FFFF00", "#FF0000"), bias = nrow(edgeList), space = "rgb", interpolate = "linear")
colCodes <- F2(length(unique(edgeList$diceSim)))
edges_col <- sapply(edgeList$diceSim, function(x) colCodes[which(sort(unique(edgeList$diceSim)) == x)])

rm(colCodes, F2)
############################################################################################
# Create a networkD3

D3_network_LM <- networkD3::forceNetwork(Links = edgeList, # data frame that contains info about edges
                                         Nodes = nodeList, # data frame that contains info about nodes
                                         Source = "SourceID", # ID of source node 
                                         Target = "TargetID", # ID of target node
                                         Value = "Weight", # value from the edge list (data frame) that will be used to value/weight relationship amongst nodes
                                         NodeID = "nName", # value from the node list (data frame) that contains node description we want to use (e.g., node name)
                                         Nodesize = "nodeBetweenness",  # value from the node list (data frame) that contains value we want to use for a node size
                                         Group = "nodeDegree",  # value from the node list (data frame) that contains value we want to use for node color
                                         height = 1000, # Size of the plot (vertical)
                                         width = 1000,  # Size of the plot (horizontal)
                                         fontSize = 40, # Font size
                                         linkDistance = networkD3::JS("function(d) { return d.value/80; }"), # Function to determine distance between any two nodes, uses variables already defined in forceNetwork function (not variables from a data frame)
                                         linkWidth = networkD3::JS("function(d) { return d.value/800; }"),# Function to determine link/edge thickness, uses variables already defined in forceNetwork function (not variables from a data frame)
                                         opacity = 0.8, # opacity
                                         zoom = TRUE, # ability to zoom when click on the node
                                         opacityNoHover = 0.1, # opacity of labels when static
                                         linkColour = edges_col) # edge colors

# Plot network
D3_network_LM 

# Save network as html file
networkD3::saveNetwork(D3_network_LM, "D3_Hong.html", selfcontained = TRUE)

################################################################################
# sessionInfo()
#
# R version 3.3.1 (2016-06-21)
# Platform: x86_64-redhat-linux-gnu (64-bit)
# Running under: Fedora 24 (Workstation Edition)
# 
# locale:
#   [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8       
# [4] LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
# [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C              
# [10] LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
# 
# attached base packages:
#   [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# loaded via a namespace (and not attached):
#   [1] htmlwidgets_0.7  plyr_1.8.4       magrittr_1.5     htmltools_0.3.5  tools_3.3.1      igraph_1.0.1    
# [7] yaml_2.1.13      Rcpp_0.12.7      jsonlite_1.1     digest_0.6.10    networkD3_0.2.13