library(ggplot2)
library(reshape2)

#the data have the Accessions names of protiens 
# 1 control cancer group 
# 1 traetment group 
data<-read.csv("gNSAF2.csv" )
#remove row that have T C groups
data <- data.frame (data[-1,])
#covert data to numeric 
data[,-1] <- sapply(data[,-1], function(x) as.numeric(as.character(x))) 

################boxplot for the original data#######################
#to know the distribution of every group in every protien 

#transpose the data 
data_transposed <- data.frame(t(data))
#make names of columns to be Accessions names
names(data_transposed) <- data_transposed[1,]
#remove Accessions columns
data_transposed <- data_transposed[-1,]
#covert data to numeric 
data_transposed[,-1]<- sapply(data_transposed[,-1], function(x) as.numeric(as.character(x)))
#add group column to identify data
data_transposed$group <- c("C","C","T","T","T","T","C","C")
#Accessions names of protiens
protiens <- colnames(data_transposed)

# a simple example for the boxplot for one of the protiens 
ggplot(data_transposed, aes(x = group , y = data_transposed[,4] , fill=group )) +
  geom_boxplot() +
  labs(x = "groups",y="value")+
  ggtitle(protiens[4])

#show the first 5 protiens
for (i in 1:5){
    plt<-ggplot(data_transposed, aes(x = group , y = data_transposed[,i] , fill=group )) +
    geom_boxplot() +
    labs(x = "groups",y="value")+
    ggtitle(proteins[i])
    print(plt)
}
##########################################################


#############preprocessing#####################

# PQN normalizarion
data_norm <- data
ref_median= median(data[,2],na.rm = T)
for(i in 2:ncol(data)){

  data_norm[,i]=data[,i]/ median(data[,i]/ref_median,na.rm = T)

}

#filtration 

#divid tha data to 2 groups ( control , treatment )
df1 <-data.frame(data_norm$Accessions,data_norm$X10C,data_norm$X18C,data_norm$X5C,data_norm$X8C)
df2 <-data.frame(data_norm$Accessions,data_norm$X18T,data_norm$X19T,data_norm$X3T,data_norm$X4T)
names(df1) <- gsub("data_norm.", "", names(df1), fixed = TRUE)
names(df2) <- gsub("data_norm.", "", names(df2), fixed = TRUE)

#removing that have more than or equal 3 NAs
na_count <- rowSums(is.na(df1))
keep_rows <- na_count < 3
df1 <- df1[keep_rows, ] 
na_count <- rowSums(is.na(df2))
keep_rows <- na_count < 3
df2 <- df2[keep_rows, ] 

#imputation
#by median of each row
# Loop through rows
for(i in rownames(df1)) {
  
  row_median <- median(as.numeric(df1[i,-1]), na.rm = TRUE) 
  #loop through columns
  for(j in colnames(df1)) {
    
    if(is.na(df1[i,j])) {
      df1[i,j] <- row_median
    }
    
  }
}
for(i in rownames(df2)) {
  
  row_median <- median(as.numeric(df2[i,-1]), na.rm = TRUE) 
  #loop through columns
  for(j in colnames(df2)) {
    
    if(is.na(df2[i,j])) {
      df2[i,j] <- row_median
    }
    
  }
}

#########################################################################
#using joins
library(dplyr)
# full join to show unique protiens that appear in one of the groups
full_join_df <- full_join(df1, df2, by = "Accessions") 

#inner join to take common protiens 
inner_join_df <-inner_join(df1, df2, by = "Accessions")

####################Statistical Analysis###############################################

rows_mean <- rowMeans(inner_join_df[,-1])
shapiro.test(rows_mean) # p < 0.05   so it is non parametric 

#scale data (optinal)
#inner_join_df[,-1] = scale(inner_join_df[,-1])


#non paired test
#ptable has p value , p adjacent , fold change
ptable<-data.frame(inner_join_df[,1])
colnames(ptable)[1] ="Accessions"
#calculate means for each row
group_c = apply(inner_join_df[,2:5], 1, mean)
group_T = apply(inner_join_df[,6:9], 1, mean) 
#calculate the fold change 
foldchange <- group_T / group_c
# make table have p values , p adjacent , FC
for (i in rownames(inner_join_df)) {
  ptable[i,2]<-wilcox.test(as.numeric(inner_join_df[i,2:5]),as.numeric(inner_join_df[i,6:9]),paired = FALSE ,exact = FALSE)$p.value
  ptable[i,3]<-p.adjust(ptable[i,2],method="BH")
  ptable[i,4]<-foldchange[as.numeric(i)]
}  
colnames(ptable)[2] ="pvalue"
colnames(ptable)[3] ="p-adj"
colnames(ptable)[4] ="FC"
###################################################################################

############# volcano plot for p table to show significant proteins ###################
p <-ggplot(ptable, aes(x = log2(FC), y = -log10(`p-adj`))) +
  geom_point() +
  labs(x = "Fold change (log2)", y = "-log10(p-adj)") +
  theme_minimal()
p2 <- p + geom_vline(xintercept=c(-1, 1), col="red") +
  geom_hline(yintercept=-log10(0.05), col="red")

ptable$diffexpressed <- "NO"
# if log2Foldchange > 0.6 and pvalue < 0.05, set as "UP" 
ptable$diffexpressed[log2(ptable$FC) > 1 & ptable$`p-adj` < 0.05] <- "UP"
# if log2Foldchange < -0.6 and pvalue < 0.05, set as "DOWN"
ptable$diffexpressed[log2(ptable$FC) < -1 & ptable$`p-adj` < 0.05] <- "DOWN"

p <- ggplot(data=ptable, aes(x=log2(ptable$FC), y=-log10(`p-adj`), col=diffexpressed)) + geom_point() + theme_minimal()
p2 <- p + geom_vline(xintercept=c(-1, 1), col="red") +
  geom_hline(yintercept=-log10(0.05), col="red")

p3 <- p2 + scale_color_manual(values=c("blue", "black", "red"))
mycolors <- c("blue", "red", "black")
names(mycolors) <- c("DOWN", "UP", "NO")
p3 <- p2 + scale_colour_manual(values = mycolors)

ptable$ptablelabel <- NA
ptable$ptablelabel[ptable$diffexpressed != "NO"] <- ptable$Accessions[ptable$diffexpressed != "NO"]

ggplot(data=ptable, aes(x=log2(ptable$FC), y=-log10(`p-adj`), col=diffexpressed, label=ptablelabel)) + 
  geom_point() + 
  theme_minimal() +
  geom_text()

library(ggrepel)
# plot adding up all layers we have seen so far
ggplot(data=ptable, aes(x=log2(FC), y=-log10(`p-adj`), col=diffexpressed)) +
  geom_point() + 
  theme_minimal() +
  scale_color_manual(values=c("blue", "black", "red")) +
  geom_vline(xintercept=c(-1, 1), col="red") +
  geom_hline(yintercept=-log10(0.05), col="red") +
  labs(x = "Fold change (log2)", y = "-log10(p-adj)")

#######################################################################################

######### heatmap for significant protiens per groups ####################

significant_proteins <- ptable[ptable$`p-adj` < 0.05,]
sig_data <- inner_join_df[inner_join_df$Accessions %in% significant_proteins$Accessions,]
# plotting the Heatmap
# Transpose the sig_data dataframe
library(pheatmap)
data_trans <- data.frame(t(sig_data))
names(data_trans) <- data_trans[1,]
data_trans <- data_trans[-1,]
data_trans[] <- lapply(data_trans, function(x) as.numeric(as.character(x))) 

data_trans = scale(data_trans)
pheatmap(data_trans , main = "significant proteins heatmap" )

############################################################

#colleration

group_C_colmeans <-colMeans(inner_join_df[,2:5])
group_T_colmeans <-colMeans(inner_join_df[,6:9])

res <- cor.test(group_C_colmeans, group_T_colmeans,method = "pearson")
res # the output is positive colleration


################### biological analysis #############################

#for the protien that is the output from inner join

data2<-read.csv("gProfiler_hsapiens.csv",fileEncoding = "UTF-8" )
#take significant from the data2 
significant <- data2[data2$adjusted_p_value < 0.05,]

#choose the GO pathways only from data2 
GO_pathes <- data2[grepl('^GO', data2$source), ]

proteins_list <- strsplit(GO_pathes$intersections, ",")
pathway_proteins <- data.frame(term_id = rep(GO_pathes$term_id, lengths(proteins_list)),
                                proteins = unlist(proteins_list))
#digram 1
ggplot(pathway_proteins, aes(x = term_id, y = proteins)) +
  geom_point() +
  xlab("Pathways") +
  ylab("Proteins") +
  ggtitle("Proteins in Each Pathway") +
  theme(axis.text.x =element_text(angle = 90 ,hjust=1))


#digram 2
library(ggsankey)

data_pathway <- pathway_proteins%>%
  make_long(proteins, 
            term_id)
ggplot(tail(data_pathway,n=60), aes(x = x, next_x = next_x, node = node, next_node = next_node, fill = factor(node), label = node)) +
  geom_sankey(flow.alpha = 0.75, node.color = 1,
              ,space = 70 ) +
  geom_sankey_label(size = 6, color = "white" ,space = 70 ) +
  scale_fill_viridis_d(option = "H", alpha = 0.95) +
  theme_sankey(base_size = 20) +
  labs(x = NULL) +
  theme(legend.position = "none",
        plot.title = element_text(hjust = .5)) +
  ggtitle("pathways of proteins")


#digram 3
library(networkD3)

links <- data.frame(source = paste0(pathway_proteins$proteins),
                    target   = paste0(pathway_proteins$term_id))

# now convert as character
links$source <- as.character(links$source)
links$target<- as.character(links$target)

nodes <- data.frame(name = unique(c(links$source, links$target)))
links$source <- match(links$source, nodes$name) - 1
links$target <- match(links$target, nodes$name) - 1
links$value <- 1 # add also a value
graph <- sankeyNetwork(Links = links, Nodes = nodes, Source = 'source',
              Target = 'target', Value = 'value', NodeID = 'name',fontSize = 12, nodeWidth = 30 )

graph

