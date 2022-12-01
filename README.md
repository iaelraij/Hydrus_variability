# Hydrus_variability
The files in this directory were used to create the simulations in the Spatial Variability chapter in the manuscript "Modeling of Irrigation and Related Processes with HYDRUS"

Irrigation variability: one Matlab script with the irrigation variabilty file creation and running, the "Results" Matlab function, a function that reads the Hdyrus results and saves them into one MAtlab structure that can be then used to create graphs and do data analysis.

HydraulicProperties_review.m is the Matlab function used to run a series of simulations with hydraulic properties (in this case Ks) changing according to a defined distribution (in this case with an STDEV as calculated in Rosetta3).
