A simple program for doing cuts in 2d root histograms and getting the
mean value in X and Y. This information is usefull for calibration.

Please see INSTALL, for installing instructions.

An example to make the cut and inmediately get the means:

teles=698
taglierina -t $teles MySpectra212.root ground3HeCuts.cut && taglierina -b ground3HeCuts.cut MySpectra212.root -t $teles
