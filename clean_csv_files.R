# Clean up csv files for Task 2

#Load necessary packages
library(tidyverse)

# Read in csv files, fix header values and replace missing values with NA
existing <- read.csv("existingProductAttributes.csv", header = TRUE, na.strings = c("", "NA"))
newProds <- read.csv("newProductAttributes.csv", header = TRUE, na.strings = c("", "NA"))

#Changes name of second column b/c r handles # differently, then assign column names to second file so that they match
colnames(existing)[2] <- "Product.Number" 
colnames(newProds) <- colnames(existing)


#Save csv files
write.csv(existing, file = "existingProductAttributes_clean.csv", row.names = FALSE)
write.csv(newProds, file = "newProductAttributes_clean.csv", row.names = FALSE)


## read in model data and profitiabilty data then select the columns of importance
model_df <- read.csv("model_data.csv", header = TRUE, sep = ";")
model_volume <- model_df %>%
  select(tail(names(.), 2))

profit_df <- readxl::read_xlsx("profitability.xlsx", sheet = 1, col_names = TRUE, skip = 1, 
                               .name_repair = "universal")
profit_margin <- profit_df %>%
  select(1, 2, 3, 4, 19)
colnames(profit_margin)[2] <- "Product.Number"

#join two df together and mutate for the profit margin column and sort by predicted profit margin
profit_final <- merge(model_volume, profit_margin, by = "Product.Number")
profit_final <- profit_final %>%
  mutate(pred_profit = prediction.Volume.* Price * Profit.margin)
profit_final <- profit_final[order(profit_final$pred_profit, decreasing = TRUE),]
profit_final <- profit_final[, c(1, 3, 4, 5, 6, 2, 7)]


#write the output to xlsx for further formatting
colnames(profit_final) <- c("Product.Number", "Type", "Brand", "Price", "Profit.Margin", "Predicted.Volume", "Predicted.Profit")
write_csv(profit_final, "Profit_Final.csv")

#clean up envirnoment
rm(model_df, model_volume, profit_df, profit_margin)
