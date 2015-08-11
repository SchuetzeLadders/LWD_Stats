##Brendan Schuetze
##LWD Stats
##Started July 22, 2015

library(ggplot2)
library(dplyr)
library(broom)
library(reshape2)
library(stringr)

printStats <- function(df, mean.Length, mean.Diameter) { #Basic Stats about Data Collected So far
    print("================================================================")
    cat("\n")
    print("Stream Stats Metric")
    print(paste("Total Number of LWD Pieces:", nrow(df)))
    print(paste("Mean Length", mean.Length / 100, "meters"))
    print(paste("Mean Diameter", mean.Diameter, "cm"))
    print(paste("Mean Volume", (pi / 4) * ((mean.Diameter / 100) ^ 2) * (mean.Length / 100), "m^3"))
    cat("\n")
    print("================================================================")
    cat("\n")
    print("Distribution of Factor Variables")
    print(paste("Ratio of Coniferous to Deciduous to Unknown: ", nrow(filter(df, Species..C.D.U.== "C")), ":", nrow(filter(df, Species..C.D.U.== "D")), ":", nrow(filter(df, Species..C.D.U.== "U"))))
    df <- df %>% mutate(Bank = str_sub(df$ID.Number, -1))
    print(paste("Ratio of L/R/U Bank Placement: ", table(df$Bank)[1], ":", table(df$Bank)[2], ":", table(df$Bank)[3]))
    print(paste("Number of Tagged Pieces:", nrow(filter(df, Tagged == "Y"))))
}

orientChi <- function(df) {
    temp <- list()
    df$Channel.Orientation <- factor(df$Channel.Orientation)
    for(i in 2:5) { ##Split By Quantiles, in order to find distribution percentages for Chi Square
        if(i == 2) {
            df.temp <- df %>%
                filter(Diameter..cm. <= quantile(df$Diameter..cm.)[[i]] & Diameter..cm. >= quantile(df$Diameter..cm.)[[i - 1]]) %>%
                    select(Channel.Orientation)
        }
        else {
        df.temp <- df %>%
            filter(Diameter..cm. <= quantile(df$Diameter..cm.)[[i]] & Diameter..cm. > quantile(df$Diameter..cm.)[[i - 1]]) %>%
                select(Channel.Orientation)
        }
        temp[i-1] <- df.temp
    }
    temp.first  <- table(temp[1])
    temp.second <- table(temp[2])
    temp.third  <- table(temp[3])
    temp.fourth <- table(temp[4])
    A <- c(temp.first[[1]], temp.second[[1]], temp.third[[1]], temp.fourth[[1]])
    B <- c(temp.first[[2]], temp.second[[2]], temp.third[[2]], temp.fourth[[2]])
    C <- c(temp.first[[3]], temp.second[[3]], temp.third[[3]], temp.fourth[[3]])
    D <- c(temp.first[[4]], temp.second[[4]], temp.third[[4]], temp.fourth[[4]])
    temp.dist <- data.frame(A, B, C, D)

    ##Print Results of Chi Square Analysis
    cat("\n")
    print("Relationship Between Orientation and Diameter")
    ##print(temp.dist) 
    c <- chisq.test(temp.dist)
    #print(c) #Print Chi Square Full Results
    hypothesisTest(c$p.value)

    for(i in 2:5) { ##Split By Quantiles, in order to find distribution percentages for Chi Square
        if(i == 2) {
            df.temp <- df %>%
                filter(Length..cm. <= quantile(df$Length..cm.)[[i]] & Length..cm. >= quantile(df$Length..cm.)[[i - 1]]) %>%
                    select(Channel.Orientation)
        }
        else {
        df.temp <- df %>%
            filter(Length..cm. <= quantile(df$Length..cm.)[[i]] & Length..cm. > quantile(df$Length..cm.)[[i - 1]]) %>%
                select(Channel.Orientation)
        }
        temp[i-1] <- df.temp
    }
    temp.first  <- table(temp[1])
    temp.second <- table(temp[2])
    temp.third  <- table(temp[3])
    temp.fourth <- table(temp[4])
    A <- c(temp.first[[1]], temp.second[[1]], temp.third[[1]], temp.fourth[[1]])
    B <- c(temp.first[[2]], temp.second[[2]], temp.third[[2]], temp.fourth[[2]])
    C <- c(temp.first[[3]], temp.second[[3]], temp.third[[3]], temp.fourth[[3]])
    D <- c(temp.first[[4]], temp.second[[4]], temp.third[[4]], temp.fourth[[4]])
    temp.dist <- data.frame(A, B, C, D)

    ##Print Results of Chi Square Analysis
    cat("\n")
    print("Relationship Between Orientation and Length")
    ##print(temp.dist) 
    c <- chisq.test(temp.dist)
    ##print(c) #Print Chi Square Full Results
    hypothesisTest(c$p.value)

}

updateOrient <- function(df) {
    cat("\n")
    print("================================================================")
    cat("\n")
    print("Orientation Statistics")
    cat("\n")
    print("Percentages")
    orient <- (table(factor(df$Channel.Orientation)))
    print(orient/sum(orient) * 100)
    
    ##Chi-Square Test for Orientation versus Diameter and Length
    orientChi(df)
    cat("\n")
    
    ##Distribution of Channel Orientations Graph By Diameter
    Channel.Orientation.Graph <- ggplot(data = df) + geom_density(aes(x = Diameter..cm.)) + facet_wrap( ~ Channel.Orientation)
    ggsave("Output/Channel.Orientation.Diameter.jpg")

    ##Distribution of Channel Orientations By Length
    Channel.Orientation.Graph <- ggplot(data = df) + geom_density(aes(x = Length..cm.)) + facet_wrap( ~ Channel.Orientation) + xlim(200, 1800)
    ggsave("Output/Channel.Orientation.Length.jpg")
    dev.off()
}

lengthVersusDiameterGraph <- function(df){ ##Graph Length versus Diameter
    ggplot() + geom_point(data = df, aes(x = Diameter..cm., y = Length..cm.)) + ylim(0, 5000)
    ggsave("Output/Length.Diameter.Scatterplot.jpg")
    dev.off()
}

updateSed <- function(df) {
    print("================================================================")
    cat("\n")
    print("Sedimentation & Pool Statistics")
    print(paste("Sediment Storage Y/N", table(factor(df$Sediment.Storage..Y.N.))[2], ":", table(factor(df$Sediment.Storage..Y.N.))[1]))
    print(paste("Pool Formation Y/N", table(factor(df$Pool.FF..Y.N.))[2], ":", table(factor(df$Pool.FF..Y.N.))[1]))
    cat("\n")
    
    temp.dist <- data.frame(c(table(filter(df, Channel.Orientation == "A")$Sediment.Storage..Y.N.)[2], table(filter(df, Channel.Orientation == "B")$Sediment.Storage..Y.N.)[2], table(filter(df, Channel.Orientation == "C")$Sediment.Storage..Y.N.)[2], table(filter(df, Channel.Orientation == "D")$Sediment.Storage..Y.N.)[2]), c(table(filter(df, Channel.Orientation == "A")$Sediment.Storage..Y.N.)[1], table(filter(df, Channel.Orientation == "B")$Sediment.Storage..Y.N.)[1], table(filter(df, Channel.Orientation == "C")$Sediment.Storage..Y.N.)[1], table(filter(df, Channel.Orientation == "D")$Sediment.Storage..Y.N.)[1])) #Create Dataframe for Sed
    
    colnames(temp.dist) <- c("Yes", "No")
    cat("\n")
    print("Relationship Between Sedimentation and Orientation")
    c <- chisq.test(temp.dist)
    ##print(c) #Print Chi Square Full Results
    hypothesisTest(c$p.value)

    rm(temp.dist)
    temp.dist <- data.frame(c(table(filter(df, Channel.Orientation == "A")$Pool.FF..Y.N.)[2], table(filter(df, Channel.Orientation == "B")$Pool.FF..Y.N.)[2], table(filter(df, Channel.Orientation == "C")$Pool.FF..Y.N.)[2], table(filter(df, Channel.Orientation == "D")$Pool.FF..Y.N.)[2]), c(table(filter(df, Channel.Orientation == "A")$Pool.FF..Y.N.)[1], table(filter(df, Channel.Orientation == "B")$Pool.FF..Y.N.)[1], table(filter(df, Channel.Orientation == "C")$Pool.FF..Y.N.)[1], table(filter(df, Channel.Orientation == "D")$Pool.FF..Y.N.)[1])) #Create Dataframe for Pool Formation
    colnames(temp.dist) <- c("Yes", "No")
    cat("\n")
    print("Relationship Between Pool Formation and Orientation")
    c <- chisq.test(temp.dist)
    ##print(c) #Print Chi Square Full Results
    hypothesisTest(c$p.value)
    
     
}

smallLWD <- function(bad) { ##Identify LWD that do not meet minimum requirements
    bad <- df %>% 
        filter(Length..cm. < 200 | Diameter..cm. < 10)
    
    if(nrow(bad) > 0) {
        print("================================================================")
        cat("\n")
        print(paste("WARNING:", nrow(bad), "Piece(s) of LWD are Below Minimum Requirements. They will be excluded from all statistics."))
        print("Their ID(s) are shown below")
        print(bad$ID.Number)
        cat("\n")
    }
}

largeLWD <- function(df) { #Display IDs of LWD > 50cm in diameter
    LargeLWD <- df %>%
        filter(Diameter..cm. > 50)
    
    if(nrow(LargeLWD) > 0) {
        print(paste(nrow(LargeLWD), "pieces of *Large* LWD found"))
        print("Their ID(s) are shown below")
        print(LargeLWD$ID.Number)
        cat("\n")
    }
}

hypothesisTest <- function(p) { ##Check if P values are significant
    print(paste("P Value:", p))
    if(p < 0.05) {
        print("#!#     Reject Null Hypothesis     #!#")
        return(TRUE)
    } else{
        print("### Fail to Reject Null Hypothesis ###")
        return(FALSE)
    }
}

startUpdate <- function(df) {
    df <- df %>% ##Exclude any LWD that do not meet minimum requirements
        filter(Length..cm. > 200 & Diameter..cm. > 10)

    mean.Length = mean(as.numeric((df$Length..cm.)))
    mean.Length.ft = mean(as.numeric((df$Length..ft.)))
    mean.Diameter = mean(as.numeric((df$Diameter..cm.)))
    
    sink("Output/LWD_Stats.txt")
    smallLWD(df) ##Identify Insufficiently Sized LWD Pieces
    largeLWD(df) ##Identify Large LWD
    printStats(df, mean.Length, mean.Diameter) ##Calculate Basic Statistics
    updateOrient(df) ##Calculate Orientation Chi^2 and graph
    updateSed(df)
    lengthVersusDiameterGraph(df)
    print("================================================================")
    sink()
}

##Startup, Import and Scrub Dataframe
df <- read.csv("lwd.csv", stringsAsFactors = FALSE) %>%
    select(-Long, -Lat, -Jam.ID, -Notes) %>%
        na.omit() ##Scrub NAs

##Launch Main Program
startUpdate(df)