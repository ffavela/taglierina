A simple program for doing cuts in 2d root histograms and getting the
mean value in X and Y. This information is usefull for calibration.


Please see INSTALL, for installing instructions.

To run simply do a:

$ taglierina

usage:

	taglierina [-h|--help]
	
	taglierina -n tNumOrName spectraFile rootCutFile
	
	taglierina -a tNumOrNameFile spectraFile rootCutFile
	
	taglierina -s sTNum [-e eTNum] spectraFile rootCutFile
	
	taglierina --sampleConf
	
	taglierina -d tNumOrName rootCutFile
	
	taglierina -l rootFile [rootObject]
	
	taglierina --lCut rootCutFile
	
	taglierina -b spectraFile rootCutFile [-n tNumOrName] [-p partition [--axis (x|y)]] [--hMean]
	
	taglierina --TH spectraFile rootCutFile outFile [--yCut]
	
	taglierina --PT0 cuttedSpectraFile [-n hName] [--axis (x|y)]
	
	taglierina --draw (-n|-s) tNumOrName cuttedSpectraFiles ...
	
	taglierina --ascii

The -h option will show some help text explaining each of the options.

An example to make the cut and inmediately get the means:

teles=698

taglierina -t $teles MySpectra212.root ground3HeCuts.cut && taglierina -b ground3HeCuts.cut MySpectra212.root -t $teles
