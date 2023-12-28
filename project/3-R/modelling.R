library(caret)
library(h2o)

#factors
df$y <- as.factor(df$y)
df$term <- as.factor(df$term)
df$credit_score <- as.factor(df$credit_score)
df$loan_purpose <- as.factor(df$loan_purpose)
df$home_ownership <- as.factor(df$home_ownership)


# Create a train split
index <- createDataPartition(df$y, p = 0.7, list = FALSE) #split 70, 15, 15

# Create the training set
training_set <- df[index, ]

# Create the test/validation set
test_validation_set <- df[-index, ]

# Further split the test/validation set into test and validation sets
index_validation <- createDataPartition(test_validation_set$y, p = 0.5, list = FALSE)

validation_set <- test_validation_set[index_validation, ]
test_set <- test_validation_set[-index_validation, ]





rm(list=c("dfdata","additional_data","dfaddit","dfsample", "additional_features", "dffeatures", "sample", "df","index","index_validation", "test_validation_set")) #remove unnecessary data


#Start classification

#autoML
h2o.init(max_mem_size="8g")
h2o_trainset_frame <- as.h2o(training_set, destination_frame = "h2o_trainset_frame")
h2o_testset_frame <- as.h2o(test_set, destination_frame = "h2o_testset_frame")
h2o_validationset_frame <- as.h2o(validation_set, destination_frame = "h2o_validationset_frame")

rm(test_set,training_set,validation_set)
response_variable <- "y"
#prisidėt xus ir factorint kategorinius
aml <- h2o.automl(x = 2:16, y=1,
  seed = 99,
  nfolds = 0,
  include_algos=c("GBM"),
  training_frame = h2o_trainset_frame,
  validation_frame = h2o_validationset_frame,
  leaderboard_frame = h2o_testset_frame,
  sort_metric="AUC",
  stopping_metric="AUC",
  #max_models = 200,  # Set the maximum models
  max_runtime_secs = 3600 #max runtime
)


leaderboard <- aml@leaderboard
summary(leaderboard)
print(leaderboard, n=nrow(leaderboard))
best_model <- aml@leader
best_model
testdata = read.csv("test_data.csv")
df <- data.frame(testdata)
df$term <- as.factor(df$term)
df$credit_score <- as.factor(df$credit_score)
df$loan_purpose <- as.factor(df$loan_purpose)
df$home_ownership <- as.factor(df$home_ownership)
testset <- as.h2o(df, destination_frame = "testset")


#model1
predictions <- h2o.predict(best_model, newdata = testset)
df<-data.frame(as.vector(predictions$p0))
dfout <- data.frame("p0"=df[,1])
write.csv(dfout, "result1.csv")
