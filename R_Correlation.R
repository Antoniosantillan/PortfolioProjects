# Library Import
library(ggplot2)
library(readr)
library(dplyr)
df <- read.csv("D:\\Proyectos\\movies_Clean.csv")#-->Read the Document
###### DATAFRAME INFORMATION #####
print(df)
print(dim(df))
print(sapply(df, class))
##### DATA CLEANING #####
# Change data type
df$budget <- as.numeric(df$budget)
df$gross <- as.numeric(df$gross)
# Find missing values
print(colSums(is.na(df)))
for (col in names(df)) {
  Pct_missing <- mean(is.na(df[[col]]))
  print(paste(col, "-", Pct_missing * 100, "%"))
}
df <- df[complete.cases(df[c("budget", "gross")]), ]

# Subtract and replace year values
take_year <- function(x) {
  pattern <- "\\b\\d{4}\\b"
  coincidences <- regmatches(x, regexpr(pattern, x))
  if (length(coincidences) > 0) {
    return(coincidences[1])
  } else {
    return(NA)
  }
}
df$year <- sapply(df$released, take_year)
df <- df[order(-df$gross), ]

##### INFORMATION CORRELATION #####
df_numerized <- df
for (col_name in names(df_numerized)) {
  if (class(df_numerized[[col_name]]) == "character") {
    df_numerized[[col_name]] <- as.factor(df_numerized[[col_name]])
    df_numerized[[col_name]] <- as.numeric(df_numerized[[col_name]])
  }
}
correlation_matrix <- cor(df_numerized, use = "pairwise.complete.obs")

corr_pairs <- cor(df_numerized)
sorted_pairs <- sort(corr_pairs[upper.tri(corr_pairs)], decreasing = FALSE)
high_corr <- sorted_pairs[(sorted_pairs > 0.5) & (sorted_pairs < 1.0)]

print(sorted_pairs)

##### INFORMATION REPRESENTATION #####
ggplot(df, aes(x = budget, y = gross)) +
  geom_point() +
  labs(title = "Budget VS Gross Earnings", x = "Budget for film", y = "Gross Earnings")

# You can uncomment and run the following lines for additional plots
 ggplot(df, aes(x = budget, y = gross)) +
   geom_point(color = "red") +
   geom_smooth(method = "lm", color = "blue") +
   labs(title = "Budget VS Gross Earnings", x = "Budget for film", y = "Gross Earnings")