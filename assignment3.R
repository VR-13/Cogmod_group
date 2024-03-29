
library(ggplot2)

# we will work with points 1 to 250 (cm)
scale.points <- c(1:250) 

# we create a dataframe for plotting
example.height <- data.frame(x=scale.points) 

# we use sapply, which is a vectorized function application; see help if you don't understand it

# we add y, which is just the probability density function described above (normal distribution)
example.height$y <- sapply(example.height$x, function(x) {dnorm(x, mean=180, sd=10)}) 

# this starts the plot creation
g1 <- ggplot(example.height, aes(x=x, y=y)) 

# we make the plot more pretty: we specify it should fill in area and add labels
g1 <- g1 + geom_area(fill="green", alpha=.4)  + xlab("height") + ylab("P") + theme_gray(20) 

g1

literal.listener <- function(x, threshold, densityf, cumulativef) {

                ifelse(
                     x>=threshold,
                     densityf(x)/(1-cumulativef(threshold)),
                     0
                              )

}

threshold <- 170

example.height$updated <- sapply(example.height$x, function(x) {literal.listener(x=x, threshold=threshold, densityf=function(x) {dnorm(x, 180, 10)}, cumulativef=function(x) {pnorm(x, 180, 10)} )}) 

# this starts the plot creation
g1 <- ggplot(example.height, aes(x=x, y=y)) 
g1 <- g1 + geom_area(fill="green", alpha=.4) 

# we add the result of updated belief
g1 <- g1 + geom_area(aes(y=updated),fill="steelblue", alpha=.4) 
g1 <- g1 + xlab("height") + ylab("P") + theme_gray(20) 


g1

expected.success <- function(threshold, scale.points, densityf, cumulativef) {

    ifelse(threshold>min(scale.points), sum(sapply(scale.points[scale.points<threshold], function(x) {densityf(x) * densityf(x)})), 0) + 
        sum(sapply(scale.points[scale.points>=threshold], function(x) {densityf(x) * literal.listener(x, threshold, densityf, cumulativef)}))

}


#Task 1

utility <- function(threshold, scale.points, coverage.parameter, densityf, cumulativef) {
  expected.success(threshold, scale.points, densityf, cumulativef) + coverage.parameter * (1 - cumulativef(threshold))
}


probability.threshold <- function(threshold, scale.points, lambda, coverage.parameter, densityf, cumulativef) {

  exp(lambda * utility(threshold, scale.points, coverage.parameter, densityf, cumulativef)) / 
    sum(sapply(scale.points, function(x){exp(lambda * utility(x, scale.points, coverage.parameter, densityf, cumulativef))}))
}


use.adjective <- function(degree, scale.points, lambda, coverage.parameter, densityf, cumulativef) {
  denom <- sum(sapply(scale.points, function(x){
    exp(lambda * utility(x, scale.points, coverage.parameter, densityf, cumulativef))}))
  
  sum(sapply(scale.points[scale.points <= degree], 
             function(x){exp(lambda * 
                               utility(x, scale.points, coverage.parameter, 
                                       densityf, cumulativef))})) / denom 

}

# Help - tests you should pass

#probability.threshold is a probability, so if you sum up all values it generates, the result should be 1
round(sum(sapply(1:10, function(x) {probability.threshold(x, 1:10, 50, 0, function(x) {dnorm(x, 5, 1)}, function(x) {pnorm(x, 5, 1)})}))) == 1

#for narrow normal distribution, prob. threshold should be max just one value above the average
which(sapply(1:10, function(x) {probability.threshold(x, 1:10, 50, 0, function(x) {dnorm(x, 5, 1)}, function(x) {pnorm(x, 5, 1)})})==max(sapply(1:10, function(x) {probability.threshold(x, 1:10, 50, 0, function(x) {dnorm(x, 5, 1)}, function(x) {pnorm(x, 5, 1)})}))) == 6

#use.adjective should be very unlikely on values 5 and smaller and very likely afterwards
round(sapply(1:10, function(x) {use.adjective(x, 1:10, 50, 0, function(x) {dnorm(x, 5, 1)}, function(x) {pnorm(x, 5, 1)})})[5], 3) == 0.005
round(sapply(1:10, function(x) {use.adjective(x, 1:10, 50, 0, function(x) {dnorm(x, 5, 1)}, function(x) {pnorm(x, 5, 1)})})[6], 3) == 1

#plot for the probability threshold
thres <- sapply(1:250, function(x){probability.threshold(x, scale.points, 50, 0, function(x) {dnorm(x, 180, 10)}, function(x) {pnorm(x, 180, 10)})})

Threshold_calculated <- thres

Threshold_calculated.data <- data.frame()
Threshold_calculated.data <- as.data.frame(cbind(scale.points, Threshold_calculated))
names(Threshold_calculated.data)[names(Threshold_calculated.data) == "scale.points"] <- "x"
names(Threshold_calculated.data)[names(Threshold_calculated.data) == "Threshold_calculated"] <- "y"
max.Threshold_calculated <- max(Threshold_calculated.data$y)
Threshold_calculated.value <- Threshold_calculated.data$x[Threshold_calculated.data$y == max.Threshold_calculated]
# this starts the plot creation
g1 <- ggplot(Threshold_calculated.data, aes(x=x, y=y)) 

# we make the plot more pretty: we specify it should fill in area and add labels
g1 <- g1 + geom_area(fill="green", alpha=.4)  + xlab("height") + ylab("P") + theme_gray(20) 

g1

#Adjective function
adjective <- sapply(1:250, function(x){use.adjective(x, scale.points, 50, 0, function(x) {dnorm(x, 180, 10)}, function(x) {pnorm(x, 180, 10)})})
adjective.data <- data.frame()
adjective.data <- as.data.frame(cbind(scale.points, adjective))
names(adjective.data)[names(adjective.data) == "scale.points"] <- "x"
names(adjective.data)[names(adjective.data) == "adjective"] <- "y"
# find the right degree
max.degree <- max(adjective.data$y)
degree.value <- adjective.data$x[adjective.data$y == max.degree]
# PLOT
g2 <- ggplot(adjective.data, aes(x=x, y=y)) 
g2 <- g2 + geom_area(fill="blue", alpha=.4)  + xlab("height") + ylab("probability")  + ggtitle("Use adjective")+ theme_gray(20) 
g2

# Task 2:
# Explore expected.success and use.adjective for various prior distribution functions.
# For this, assume that coverage.parameter $c$ is at 0 and lambda is at 50.

###IQ
scale.points <- c(50:150)
## expected succes
iq.Expected_succes <- sapply(50:150, function(x){expected.success(x, scale.points, function(x) {dnorm(x, 100, 15)}, function(x) {pnorm(x, 100, 15)})})
iq.Expected_succes.data <- data.frame()
iq.Expected_succes.data <- as.data.frame(cbind(scale.points, iq.Expected_succes))
names(iq.Expected_succes.data)[names(iq.Expected_succes.data) == "scale.points"] <- "x"
names(iq.Expected_succes.data)[names(iq.Expected_succes.data) == "iq.Expected_succes"] <- "y"
iq.Expected_succes.max.degree <- max(iq.Expected_succes.data$y) #0.02960823
iq.Expected_succes.degree.value <- iq.Expected_succes.data$x[iq.Expected_succes.data$y == iq.Expected_succes.max.degree]
ggplot(iq.Expected_succes.data, aes(x = x, y = y)) + geom_area(fill="steelblue", alpha=.4)  + xlab("IQ") + ylab("P") + theme_gray(20)


# probability function
iq.adjective <- sapply(50:150, function(x){use.adjective(x, scale.points, 50, 0, function(x) {dnorm(x, 100, 15)}, function(x) {pnorm(x, 100, 15)})})
iq.adjective.data <- data.frame()
iq.adjective.data <- as.data.frame(cbind(scale.points, iq.adjective))
names(iq.adjective.data)[names(iq.adjective.data) == "scale.points"] <- "x"
names(iq.adjective.data)[names(iq.adjective.data) == "iq.adjective"] <- "y"
iq.adjective.max.degree <- max(iq.adjective.data$y)
iq.adjective.degree.value <- iq.adjective.data$x[iq.adjective.data$y == iq.adjective.max.degree]
ggplot(iq.adjective.data, aes(x = x, y = y)) + geom_area(fill="steelblue", alpha=.4)  + xlab("IQ") + ylab("P") + theme_gray(20)


###Waiting times
scale.points <- c(1:30)
## expected succes
wt.Expected_succes <- sapply(1:30, function(x){expected.success(x, scale.points, function(x) {dgamma(x, 2,2)}, function(x) {pgamma(x, 2,2)})})
wt.Expected_succes.data <- data.frame()
wt.Expected_succes.data <- as.data.frame(cbind(scale.points, wt.Expected_succes))
names(wt.Expected_succes.data)[names(wt.Expected_succes.data) == "scale.points"] <- "x"
names(wt.Expected_succes.data)[names(wt.Expected_succes.data) == "wt.Expected_succes"] <- "y"
wt.Expected_succes.max.degree <- max(wt.Expected_succes.data$y)
wt.Expected_succes.degree.value <- wt.Expected_succes.data$x[wt.Expected_succes.data$y == wt.Expected_succes.max.degree]
ggplot(wt.Expected_succes.data, aes(x = x, y = y)) + geom_area(fill="green", alpha=.4)  + xlab("wt") + ylab("Probability") + ggtitle("Threshold probability")+ theme_gray(20)

# probability function
wt.adjective <- sapply(1:30, function(x){use.adjective(x, scale.points, 50, 0, function(x) {dgamma(x, 2,2)}, function(x) {pgamma(x, 2,2)})})
wt.adjective.data <- data.frame()
wt.adjective.data <- as.data.frame(cbind(scale.points, wt.adjective))
names(wt.adjective.data)[names(wt.adjective.data) == "scale.points"] <- "x"
names(wt.adjective.data)[names(wt.adjective.data) == "wt.adjective"] <- "y"
wt.adjective.max.degree <- max(wt.adjective.data$y)
wt.adjective.degree.value <- wt.adjective.data$x[wt.adjective.data$y == wt.adjective.max.degree]
ggplot(wt.adjective.data, aes(x = x, y = y)) + geom_area(fill="blue", alpha=.4)  + xlab("wt") + ylab("Probability")+ ggtitle("Adjective function") + theme_gray(20)


###End written code 2

data.adjective <- read.csv(file="adjective-data.csv", header=TRUE)

gaussian.dist <-   c(1,2,3,4,5,6,5,4,3,2,1,0,0,0)
left.skew.dist <-  c(2,5,6,6,5,4,3,2,1,1,1,0,0,0)
moved.dist <-      c(0,0,0,1,2,3,4,5,6,5,4,3,2,1)
right.skew.dist <- c(1,1,1,2,3,4,5,6,6,5,2,0,0,0)

sapply(1:14, function(x) {round(length(rgamma(360, shape=1, scale=100)[which(round(rgamma(360, shape=4, scale=1.5)) == x)])/10)})


data.gaus <- data.adjective[data.adjective$Distribution=="gaussian",]
data.left <- data.adjective[data.adjective$Distribution=="left",]
data.moved <- data.adjective[data.adjective$Distribution=="moved",]

library(gridExtra)
p.g <- ggplot(data.gaus,aes(x=Stimulus,y=100*percentage,colour=Adjective))+geom_line()+ ylab("P") +ggtitle("gaussian")
p.l <- ggplot(data.left,aes(x=Stimulus,y=100*percentage,colour=Adjective))+geom_line()+ggtitle("left skewed")
p.m <- ggplot(data.moved,aes(x=Stimulus,y=100*percentage,colour=Adjective))+geom_line()+ggtitle("moved")

grid.arrange(p.g,p.l,p.m,ncol=2)

# Task 3:
# check cor between predicted and observed data
cor(..., ..., method="pearson")

#install.packages("BayesianTools")
library(BayesianTools)

prior <- createUniformPrior(lower=c(0,0.1), upper=c(0.1,1), best=NULL)

data.gaus.big <- subset(data.gaus, Adjective == "big")

likelihood <- function(param1) {

    collect <- 0
    
    for (i in 1:14) {
        collect  <- collect + dnorm(data.gaus.big$percentage[i], mean=param1[1]+param1[2], sd=0.1, log=TRUE)

    }

    return(collect)
} 

bayesianSetup <- createBayesianSetup(likelihood = likelihood, prior = prior)

iter = 6000
settings = list(iterations = iter, nrChains=3, message = FALSE)
out <- runMCMC(bayesianSetup = bayesianSetup, settings = settings)

gelmanDiagnostics(out, plot=T)

summary(out)
plot(out)

marginalPlot(out)

# Task 4

prior <- createUniformPrior(lower=c(-1,1), upper=c(1,50), best=NULL)

likelihood <- function(param1) {

    collect <- 0
    
    for (i in 1:14) {
        collect  <- collect + dnorm(data.gaus.big$percentage[i], mean=..., sd=0.1, log=TRUE)

    }

    return(collect)
} 

#set.seed(123)
#bayesianSetup <- createBayesianSetup(likelihood = likelihood, prior = prior)

#iter = 10000

#settings = list(iterations = iter, nrChains=3, message = FALSE)

#out <- runMCMC(bayesianSetup = bayesianSetup, settings = settings)


# Task 5, 6, 7

