#file import
sample = read.csv("1-sample_data.csv")
additional_data = read.csv("2-additional_data.csv")
additional_features = read.csv("3-additional_features.csv")

#Merge files
set.seed(99)
dfsample <- data.frame(sample)
dfaddit <- data.frame(additional_data)
dffeatures <- data.frame(additional_features)
dfdata <- rbind(dfsample, dfaddit)

df <- merge(dfdata, dffeatures, by = "id")
df<-subset(df, select = -c(id))
