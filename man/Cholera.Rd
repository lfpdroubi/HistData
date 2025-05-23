\name{Cholera}
\alias{Cholera}
\docType{data}
\title{
William Farr's Data on Cholera in London, 1849
}
\description{
In 1852, William Farr, published a report of the Registrar-General on mortality
due to cholera in England in the years 1848-1849, during which there was a
large epidemic throughout the country.  Farr initially believed that cholera
arose from bad air ("miasma") associated with low elevation above the
River Thames. John Snow (1855) later showed that the disease was principally
spread by contaminated water.

This data set comes from a paper by Brigham et al. (2003) that analyses some
tables from Farr's report to examine the prevalence of death from cholera
in the districts of London in relation to the available predictors from
Farr's table.
}
\usage{data("Cholera")}
\format{
  A data frame with 38 observations on the following 15 variables.
  \describe{
    \item{\code{district}}{name of the district in London, a character vector}
    \item{\code{cholera_drate}}{deaths from cholera in 1849 per 10,000 inhabitants, a numeric vector}
    \item{\code{cholera_deaths}}{number of deaths registered from cholera in 1849, a numeric vector}
    \item{\code{popn}}{population, in the middle of 1849, a numeric vector}
    \item{\code{elevation}}{elevation, in feet above the high water mark, a numeric vector}
    \item{\code{region}}{a grouping of the London districts, a factor with levels \code{West} \code{North} \code{Central} \code{South} \code{Kent}}
    \item{\code{water}}{water supply region, a factor with levels \code{Battersea} \code{New River} \code{Kew}; see Details}
    \item{\code{annual_deaths}}{annual deaths from all causes, 1838-1844, a numeric vector}
    \item{\code{pop_dens}}{population density (persons per acre), a numeric vector}
    \item{\code{persons_house}}{persons per inhabited house, a numeric vector}
    \item{\code{house_valpp}}{average annual value of house, per person (pounds), a numeric vector}
    \item{\code{poor_rate}}{poor rate precept per pound of house value, a numeric vector}
    \item{\code{area}}{district area, a numeric vector}
    \item{\code{houses}}{number of houses, a numeric vector}
    \item{\code{house_val}}{total house values, a numeric vector}
  }
}
\details{
The supply of \code{water} was classified as \dQuote{Thames, between Battersea and Waterloo Bridges}
(central London),
\dQuote{New River, Rivers Lea and Ravensbourne}, and \dQuote{Thames, at Kew and Hammersmith}
(western London).
The factor levels use abbreviations for these.

The data frame is sorted by increasing elevation above the high water mark.
}
\source{
Bingham P., Verlander, N. Q., Cheal M. J. (2004).
John Snow, William Farr and the 1849 outbreak of cholera that affected London:
a reworking of the data highlights the importance of the water supply.
\emph{Public Health}, 118(6), 387-394, Table 2.
(The data was kindly supplied by Neville Verlander, including additional variables
not shown in their Table 2.)
}
\references{
Registrar-General (1852). \emph{Report on the Mortality of Cholera in England 1848-49},
W. Clowes and Sons, for Her Majesty's Stationary Office.
Written by William Farr.
\url{https://ia600208.us.archive.org/11/items/b24751297/b24751297.pdf}
The relevant tables are at pages clii -- clvii.
}
\seealso{\code{\link{CholeraDeaths1849}}, \code{\link{Snow.deaths}}}
\examples{
data(Cholera)

# plot cholera deaths vs. elevation
plot(cholera_drate ~ elevation, data=Cholera,
	pch=16, cex.lab=1.2, cex=1.2,
	xlab="Elevation above high water mark (ft)",
	ylab="Deaths from cholera in 1849 per 10,000")

# Farr's mortality ~ 1/ elevation law
elev <- c(0, 10, 30, 50, 70, 90, 100, 350)
mort <- c(174, 99, 53, 34, 27, 22, 20, 6)
lines(mort ~ elev, lwd=2, col="blue")

# better plots, using car::scatterplot

if(require("car", quietly=TRUE)) {
# show separate regression lines for each water supply
  scatterplot(cholera_drate ~ elevation | water, data=Cholera,
              smooth=FALSE, pch=15:17,
              id=list(n=2, labels=sub(",.*", "", Cholera$district)),
              col=c("red", "darkgreen", "blue"),
              legend=list(coords="topleft", title="Water supply"),
              xlab="Elevation above high water mark (ft)",
              ylab="Deaths from cholera in 1849 per 10,000")

  scatterplot(cholera_drate ~ poor_rate | water, data=Cholera,
              smooth=FALSE, pch=15:17,
              id=list(n=2, labels=sub(",.*", "", Cholera$district)),
              col=c("red", "darkgreen", "blue"),
              legend=list(coords="topleft", title="Water supply"),
              xlab="Poor rate per pound of house value",
              ylab="Deaths from cholera in 1849 per 10,000")
  }

# fit a logistic regression model a la Bingham etal.
fit <- glm( cbind(cholera_deaths, popn) ~
            water + elevation + poor_rate + annual_deaths +
            pop_dens + persons_house,
            data=Cholera, family=binomial)
summary(fit)

# odds ratios
cbind( OR = exp(coef(fit))[-1], exp(confint(fit))[-1,] )

if (require(effects)) {
  eff <- allEffects(fit)
  plot(eff)
}

###########################################################################
# Challenge 01: Dr. John Russell
# github.com/drjohnrussell/30DayChartChallenge/blob/main/2025/Challenge01.R
# Hint: It works better if emojifont package is installed!
###########################################################################

if (require("emojifont")) {
  load.fontawesome()
}

require(ggplot2)
plot1 <- Cholera |>
  ggplot(aes(x=elevation, y=cholera_drate,color=water)) +
  geom_point() +
  theme_bw() +
  labs(y="Cholera Death Rate per 10000 citizens (log)",
       x="Elevation (log)",
       color="Water Source") +
  theme(legend.position="bottom") +
  scale_y_log10() +
  scale_x_log10() +
  scale_color_brewer(palette="Dark2")

plot1

if (require("waffle")) {
  day1 <- Cholera |>
    transform(newcholeradeaths = cholera_deaths/40) |>
    sort_by(~water) |>
    ggplot(aes(fill=water,values=newcholeradeaths)) +
    geom_waffle(radius=grid::unit(0.4,"npc"),
                size=.25) +
    theme_void() +
    labs(title="Deaths from Cholera in London in 1849",
         subtitle="40 Deaths per Square",
         caption="Data from William Farr's initial report, where he concluded
         elevation \nwas the factor in the spread of plague",
         fill="Water Source") +
    scale_fill_brewer(palette="Dark2") +
    theme(legend.position="bottom",
          panel.background=element_rect(color="white"))

day1
}

}
\keyword{datasets}
