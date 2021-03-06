#!/bin/bash

macrosDir="myRootMacros"
myWhich=$(which $0)
if [ ! $myWhich = "./taglierina.sh" ]
then
    #Symlink way
    linkLoc=$(readlink $myWhich)
    myDir="$(dirname $linkLoc)/"
    macrosDir="$(dirname $linkLoc)/$macrosDir"
fi

#Made this an external file, see the --sampleConf option
# #########CONFIGURATION PART##########
# myShift=50000
# myPrefix="h"
# #####################################

minTeles=0
maxTeles=1191

confFile="tagl.conf" #replacing the above

myCutFile="myCutFile.root"
specialLogF="specialLogF.txt"

[ -e $specialLogF ] && rm $specialLogF

#Defining red color for some prompts
red='\e[0;31m'
blue='\e[0;34m'
NC='\e[0m' # No Color

function getPTVal0 {
    spectraFile="$1"
    [ ! -f "$spectraFile" ] &&\
        existFileErr cuttedSpectraFile $spectraFile
    axis=$(getAxisOrFalse $@)
    [ "$axis" = "false" ]  &&\
	echo "error: axis is invalid" >&2 &&\
	exit 6567

    nVar=""
    nBool=$(findOptVar "-n" "$@")
    if [ "$nBool" = "true" ]
    then
	nVar=$(getOptVar "-n" "$@")
	probeVal=$(bashProbeObj $spectraFile $nVar)
	getPTVal0Base $nVar $probeVal $axis $@
	exit 0
    fi

    echo -e "#hitogramName\tPTVal"
    listRootTHs $spectraFile | while read myStr;
    do
	testVar=$(echo "$myStr" | grep "^[ ]*TH")
	[ "$testVar" = "" ] && continue
    	nVar=$(echo "$myStr" | cut -f2)
    	probeVal=$(echo "$myStr" | cut -f1)
	echo -ne "$nVar\t"
    	getPTVal0Base $nVar $probeVal $axis $@
    done
}

function getPTVal0Base {
    nVar=$1
    probeVal=$2
    axis=$3
    shift 3

    [ $probeVal = "None" ] &&\
	echo "histo $nVar not found">&2 && exit 783
    myHLet="${probeVal:1:1}"
	[ ! "$myHLet" = "H" ] &&\
	    echo "error $nVar is not an histogram" >&2 &&\
	    exit 783
    douVal="${probeVal:2:1}"

    [ "$douVal" = "1" ] && [ "$axis" = "y" ] &&\
	echo -e "${red}warning:${NC} y axis is invalid for 1D histograms using x axis" >&2

    if [ "$douVal" = "1" ] || [ "$douVal" = "2" ]
    then
	root -l -q $macrosDir/printPTParams.C\(\"$spectraFile\",\"$nVar\",$douVal,\"$axis\"\) | tail -1
    else
	echo "Don't know what I'm doing" >&2
	exit 79797
    fi
}
#Checks if a cut was defined, exits in case it wasn't
function checkCut {
    echo "$1" | grep "The cut was not defined" > /dev/null
    if [ $? -eq 0 ]
    then
	echo -e "${red}The cut was not defined!!${NC}"
	exit 1
    fi
}

function minMaxAv {
    echo "$1" | cut -d',' -f "$2" | tr -d ");" |\
    awk '{if(min==""){min=max=$1};
         if($1>max) {max=$1};
         if($1<min) {min=$1};
         total+=$1; count+=1}
         END {print min,max,total/count}'
}

function checkIfValidN {
    if ! [[ $1 =~ ^-?[0-9]+$ ]]
    then
	echo -e "${red}error:${NC} $1 not a valid telescope number" >&2
	echo "valid range is within $minTeles and $maxTeles" >&2
	exit 3
    elif [ $1 -lt $minTeles ] || [ $1 -gt $maxTeles ]
    then
	echo "error: $1 not a valid telescope number" >&2
	echo "valid range is within $minTeles and $maxTeles" >&2
	exit 4
    fi
}

function checkIfInt {
    if [[ $1 =~ ^-?[0-9]+$ ]]
    then
	      echo "true"
    else
        echo "false"
    fi
}

function intError {
    varN=$1
    echo "error: $varN needs to be a number ">&2
    exit 8912
}

function printHelp {
    echo -e "usage:"
	  echo -e "\t$(basename $0) [-h|--help]"
	  echo -e "\t$(basename $0) -n tNumOrName spectraFile rootCutFile [--fitGauss]"
    echo -e "\t$(basename $0) -a tNumOrNameFile spectraFile\
 rootCutFile [--fitGauss]"
    echo -e "\t$(basename $0) -s sTNum [-e eTNum] spectraFile rootCutFile [--fitGauss]"
	  # echo -e "\t$(basename $0) -na histoNameFile spectraFile rootCutFile"
    echo -e "\t$(basename $0) ${red}--sampleConf${NC}"
	  # echo -e "\t$(basename $0) (-t telesNum | -a goodTelFile) spectraFile [rootCutFile]"
	  echo -e "\t$(basename $0) -d tNumOrName rootCutFile"
    echo -e "\t$(basename $0) -l rootFile [rootObject]"
    echo -e "\t$(basename $0) --lCut rootCutFile"
    echo -e "\t$(basename $0) -b spectraFile rootCutFile [-n tNumOrName] [-p partition [--axis (x|y)]] [--hMean]"
    echo -e "\t$(basename $0) --TH spectraFile rootCutFile outFile [--yCut]"
    echo -e "\t$(basename $0) --PT0 ${red}cutted${NC}SpectraFile [-n hName] [--axis (x|y)]"
    echo -e "\t$(basename $0) --draw (-n|-s) tNumOrName ${red}cutted${NC}SpectraFiles ..."
    echo -e "\t$(basename $0) --ascii\n"
    [ "$1" != "extra" ] && return

    longExtraStr="\
  This program ($(basename $0)) is for making cuts on 2D (and 1D) histograms\n\
and for facilitating the calibration process. Note that some of the\n\
options are intended for specific telescopes of CHIMERA. Most of\n\
the options need an existing spectraFile and a rootCutFile that\n\
gets created in case it did not previously exist. When telescope\n\
numbers are used, a configuration file is required.\n\n\
 -h or --help will print this help.\n\
 -n needs a telescope number or a histogram name.\n\
 -a needs a file with telescope numbers or names as a single column.\n\
 -s needs a starting telescope number, if -e then it will stop\n\
  until the eTNum telescope, else it will continue until 1191.\n\
   ${red}--sampleConf${NC} will create a sample configuration file\n\
     named ${red}$confFile${NC}.\n\
 -d deletes the specified cut.\n\
 -l will list the contents of a root file, if rootObject is used then\n\
 it will only output those objects.\n\
 --lCut will list the telescope numbers that have cuts.\n
 -b will output the centroid of a fitted gaussian to the histograms inside\n\
each of the cuts inside rootCutFile. If -n is used, then it will do it\n\
just for the specific corresponding cut. If -p is used then for every cut\n\
it will create a partition on the y axis by default. If --axis option is used\n\
then you can explicitly choose either x or y axis. If --hMean flag\n\
is used, then it will print the histogram mean and the stdDev.\n\
--TH will update an outFile with TH histograms from spectraFile that\n\
satisfy the cuts inside rootCutFile. If --yCut is used, then it will\n\
use the y component of the cut (instead of the x) for a TH1. This is\n\
useful when using cuts made from a TH2 in a TH1.\n\
--PT0  will make an attempt to give a punch through value.\n\
By default the used axis will be x. ${red}Make sure the file is already cutted.${NC}\n\
--draw will simply draw the histograms corresponding to tNumOrName.\n\
--ascii --8<--\n\
"
    echo -e $longExtraStr

	  echo ""
}

function syntaxErrF {
    echo -e "${red}Syntax error${NC}" >&2
    printHelp
    exit 555
}

function existFileErr {
    if [ "$2" = "" ]
    then
        echo -e "Parameter ${red}$1${NC} can't be empty" >&2
    else
        echo -e "File ${red}$1 = $2${NC} has to exist" >&2
    fi
    printHelp
    exit 555
}

function existFileErr2 {
    if [ "$2" = "" ]
    then
        echo -e "Parameter ${red}$1${NC} can't be empty" >&2
    fi
    printHelp
    exit 555
}

function checkTypErr {
    tNumOrName="$1"
    spectraFile="$2"
    rootCutFile="$3"
    [ "$tNumOrName" = "" ] && syntaxErrF
    [ ! -f "$spectraFile" ] &&\
        existFileErr spectraFile $spectraFile
    [ "$rootCutFile" = "" ] &&\
        existFileErr2 rootCutFile
}

function checkTypErr2 {
    tNumOrNameFile="$1"
    spectraFile="$2"
    rootCutFile="$3"
    [ "$tNumOrNameFile" = "" ] && syntaxErrF
    [ ! -f "$spectraFile" ] &&\
        existFileErr spectraFile $spectraFile
    [ "$rootCutFile" = "" ] &&\
        existFileErr2 rootCutFile
}

function checkTypErr3 {
    spectraFile="$1"
    rootCutFile="$2"
    [ ! -f "$spectraFile" ] &&\
        existFileErr spectraFile $spectraFile
    [ "$rootCutFile" = "" ] &&\
        existFileErr2 rootCutFile
}

function checkTypErr4 {
    spectraFile="$1"
    rootCutFile="$2"
    outFile="$3"
    [ ! -f "$spectraFile" ] &&\
        existFileErr spectraFile $spectraFile
    [ ! -f "$rootCutFile" ] &&\
        existFileErr rootCutFile $rootCutFile
    [ "$outFile" = "" ] &&\
        existFileErr2 outFile
}

function getOptVar {
    opt2Look="$1"
    shift
    optVar=""

    while [[ $# -gt 0 ]]
    do
        key="$1"
        if [ "$key" = "$opt2Look" ]
        then
            optVar="$2"
            echo "$optVar"
            return
        fi
        shift
    done
    echo ""
}

function findOptVar {
    opt2Look="$1"
    shift

    while [[ $# -gt 0 ]]
    do
        key="$1"
        if [ "$key" = "$opt2Look" ]
        then
            echo "true"
            return
        fi
        shift
    done
    echo "false"
}

function getAxisOrFalse {
    axis="x"
    axBool=$(findOptVar "--axis" "$@")
    if [ "$axBool" = "true" ]
    then
	axVar=$(getOptVar "--axis" "$@")
	if [ "$axVar" = "x" ] || [ "$axVar" = "X" ]
	then
	    axis="x"
	elif [ "$axVar" = "y" ] || [ "$axVar" = "Y" ]
	then
	    axis="y"
	else
	    axis="false"
	fi
    fi
    echo "$axis"
}

function checkIfConfFile {
    if [ ! -e $confFile ]
    then
	echo -e "${red}error:${NC} $confFile doesn't exist." >&2
	echo -e "use the ${red}--sampleConf${NC} option to generate one" >&2
	exit 666
    fi
}

function checkArgNum {
    [ $# -eq 0 ] && printHelp && exit 0
    [ "$1" = "--test" ] && checkIfInt $2 && exit 0
    if [[ $# -eq 1  && ( "$1" == "-h" || "$1" = "--help" ) ]]
    then
	return
    elif [ $# -eq 4 ] &&  [ "$1" == "-n" ]
    then
	shift
	checkHistStuff  $@
	exit 0
    elif [ $# -eq 1 ] &&  [ "$1" == "--sampleConf" ]
    then
        createSampConf
        return
    fi

    if [ "$1" == "-d" ]
    then
	return
    fi

    if [ "$1" == "-l" ]
    then
	return
    fi

    if [ "$1" == "-ln" ]
    then
	return
    fi

    if [ "$1" == "-pc" ]
    then
	return
    fi

    if [ "$1" == "-b" ]
    then
	if [ $# -lt 3 ]
	    then
	    echo "Need more arguments" >&2
	    exit 777
	fi
	return
    fi


    if [ $# -eq 3 ] || [ $# -eq 4 ]
    then
	return
    fi

    printHelp
    exit 1
}

function doThePlot {
    magicS="(int)666"
    value=$1
    if [ $value = "-n" ]
    then
        echo "name option is used" >&2
        shift
        histoVar=$1
    else
	      let histoNum=$myShift+$value
	      histoVar=$myPrefix$histoNum
    fi
    spectraFiles="$2"

    echo -e "${red}Press enter to continue${NC}" >&2

    runDraw="true"
    while [ "$runDraw" = "true" ]
    do
	runDraw="false"
	root -l -q $macrosDir/multiDraw.C\(\"$histoVar\",\"$spectraFiles\"\)
	if [ -e $specialLogF ]
	then
	    echo "specialLogF contents are" >&2
	    cat $specialLogF
	    grep -s "exit" $specialLogF >/dev/null &&\
		echo "was ordered to exit" >&2&&\
		rm $specialLogF && exit 666

	    grep -s "back" $specialLogF >/dev/null &&\
		echo "was ordered to go backward">&2 &&\
		echo "going back">&2 && runDraw="true" && rm $specialLogF && return 1

	    rm $specialLogF
	fi
	echo ""
    done
}


function doTheCut {
    magicS="(int)666"
    value=$1
    if [ $value = "-n" ]
    then
        echo "name option is used" >&2
        shift
        histoVar=$1
    else
	      let histoNum=$myShift+$value
	      histoVar=$myPrefix$histoNum
    fi
    spectraFile="$2"
    rootCFile=$myCutFile
    myC2Fit=""
    # gBool=$(findOptVar "--fitGauss" "$@")
    [ "$gBool" = "true" ] && myC2Fit="gauss"

    [ ! "$3" = "" ] && rootCFile="$3"
    echo -e "${red}Press enter after selecting the region${NC}" >&2

    runDraw="true"
    myColB="False"
    while [ "$runDraw" = "true" ]
    do
	      runDraw="false"
	      root -l -q $macrosDir/myH2Cutter.C\(\"${histoVar}\",\"${spectraFile}\",\"${rootCFile}\",\"${myColB}\",\"${myC2Fit}\",\"${logy4H1}\"\)
	if [ -e $specialLogF ]
	then
	    echo "specialLogF contents are" >&2
	    cat $specialLogF
	    grep -s "exit" $specialLogF >/dev/null &&\
		echo "was ordered to exit" >&2&&\
		rm $specialLogF && exit 666

	    grep -s "back" $specialLogF >/dev/null &&\
		echo "was ordered to go backward">&2 &&\
		echo "going back">&2 && runDraw="true" && rm $specialLogF && return 1

	    grep -s "delete cut" $specialLogF >/dev/null &&\
		echo "was ordered to delete cut">&2 &&\
		root -l -q $macrosDir/myCutDeleter.C\(\"${histoVar}\",\"${rootCFile}\"\) &&\
		echo "redrawing">&2 && runDraw="true"

	    grep -s "color" $specialLogF >/dev/null &&\
		echo "was ordered to toggle color">&2 &&\
		myColB=$(toggleString $myColB)
		echo "redrawing">&2 && runDraw="true"

	    rm $specialLogF
	fi
	echo ""
    done
}

function toggleString {
    myStr="$1"
    if [ "$myStr" = "False" ]
    then
	echo "True"
    else
	echo "False"
    fi
}

function doAllCuts {
    if [ "$1" = "-na" ]
    then
	      echo "Looping through named histograms"
        optionalVar="-n"
	      shift
    fi
    #For the eventual array
    myIdx=0

    if [ "$1" = "-sE" ] #Start and end opt
    then
	      echo "Looping through command line range"
        checkIfConfFile && source $confFile
        sTNum=$2
        eTNum=$3
        tArr=($(seq 0 $eTNum))
        myIdx=$sTNum
	      shift 2 #See comment below for why it is not 3
    else
        goodTelFile=$1
        # readarray tArr < $goodTelFile
        while read line
        do
            #Ignoring lines with "#"
            echo "Current line $line" >&2
            echo "$line" | grep "#" && continue
            tArr+=("$line")
        done < $goodTelFile
    fi
    #In either case it will take starting from second position
    spectraFile=$2
    myRCFile=$3
    arrSize=${#tArr[*]}
    echo "arrSize = $arrSize"

    # for value in ${tArr[*]}
    while [ $myIdx -lt $arrSize ]
    do
        opnionalVar=""
        echo -e "${red}myIdx = $myIdx ${NC}"

        [ $myIdx -le 0 ] && myIdx=0
	      value=${tArr[$myIdx]}
	      #Sometimes the last val is "". Make sure you dont leave empty
	      #lines in between or it will exit inmediately.
	      [ "$value" = "" ] && exit 0
	      echo "Value - $value"
        intBool=$(checkIfInt $value)

        if [ "$intBool" = "false" ]
        then
            echo "it's a named histo">&2
            optionalVar="-n"
        else
            echo "it's an int">&2
            checkIfConfFile && source $confFile
            optionalVar=""
            echo "optionalVar=$optionalVar" >&2
        fi
        fOpt=""
        fBool=$(findOptVar "--fitGauss" "$@")
        [ "$fBool" = "true" ] && fOpt="--fitGauss"
	      doTheCut $optionalVar $value $spectraFile $myRCFile $fOpt||\
            let myIdx=$myIdx-2
	      let myIdx=$myIdx+1
    done
}

function doAllPlots {
    if [ "$1" = "-na" ]
    then
	      echo "Looping through named histograms"
        optionalVar="-n"
	      shift
    fi
    #For the eventual array
    myIdx=0

    if [ "$1" = "-sE" ] #Start and end opt
    then
	      echo "Looping through command line range"
        checkIfConfFile && source $confFile
        sTNum=$2
        eTNum=$3
        tArr=($(seq 0 $eTNum))
        myIdx=$sTNum
	      shift 2 #See comment below for why it is not 3
    else
        goodTelFile=$1
        # readarray tArr < $goodTelFile
        while read line
        do
            #Ignoring lines with "#"
            echo "Current line $line" >&2
            echo "$line" | grep "#" && continue
            tArr+=("$line")
        done < $goodTelFile
    fi
    #In either case it will take starting from second position
    spectraFiles=$2
    arrSize=${#tArr[*]}
    echo "arrSize = $arrSize"

    # for value in ${tArr[*]}
    while [ $myIdx -lt $arrSize ]
    do
        opnionalVar=""
        echo -e "${red}myIdx = $myIdx ${NC}"

        [ $myIdx -le 0 ] && myIdx=0
	      value=${tArr[$myIdx]}
	      #Sometimes the last val is "". Make sure you dont leave empty
	      #lines in between or it will exit inmediately.
	      [ "$value" = "" ] && exit 0
	      echo "Value - $value"
        intBool=$(checkIfInt $value)

        if [ "$intBool" = "false" ]
        then
            echo "it's a named histo">&2
            optionalVar="-n"
        else
            echo "it's an int">&2
            checkIfConfFile && source $confFile
            optionalVar=""
            echo "optionalVar=$optionalVar" >&2
        fi

	      doThePlot $optionalVar $value "$spectraFiles" ||\
            let myIdx=$myIdx-2
	      let myIdx=$myIdx+1
    done
}


function getMeanPartData {
    rootCutFile=$1
    spectraFile=$2

    nVar=$3
    axVar=$4

    pVar=$5

    hMeanBool=$6

    #remember maxMinVar are 2 values
    maxMinVar=$(getMaxAndMin $nVar $rootCutFile $axVar)
    maxVar=$(echo -e "$maxMinVar" | cut -d' ' -f1)
    minVar=$(echo -e "$maxMinVar" | cut -d' ' -f2)

    pDelta=$(getPartitionDelta $maxMinVar $pVar)
    myRangeArr=($(getRangeArr $maxMinVar $pVar))
    let finVar=$pVar-1

    locMin=${myRangeArr[0]}
    for mRIdx in $(seq 1 $finVar)
    do
        locMax=${myRangeArr[$mRIdx]}

        # impVar=$(getMeanChansPartition $rootCutFile $spectraFile\
                                       # $nVar $axVar $locMin $locMax)

	impVar=($(getMeanChansPartition $rootCutFile $spectraFile\
                                       $nVar $axVar $locMin $locMax $hMeanBool))

        let mRIdxMin=mRIdx-1
        # hInfo=$(echo $impVar | cut -d' ' -f1 )".$mRIdxMin"
        # xMean=$(echo $impVar | cut -d' ' -f2 )
        # yMean=$(echo $impVar | cut -d' ' -f3 )
        hInfo=${impVar[0]}".$mRIdxMin"
        xMean=${impVar[1]}
	xSig=${impVar[2]}
	xCte=${impVar[3]}

        yMean=${impVar[4]}
	ySig=${impVar[5]}
	yCte=${impVar[6]}

        echo -e "$hInfo\t$xMean\t$xSig\t$xCte\t$yMean\t$ySig\t$yCte"

        locMin=$locMax
	impVar=""
    done
}

function listCutTel {
    root -l -q $macrosDir/listRoot.C\(\"${1}\"\) | grep "KEY: TCutG" |\
         cut -f2 | cut -d";" -f1 | cut -d"$myPrefix" -f2 |\
         sed 's/CUT//g' | sort |\
         while read -r line; do echo "$line - $myShift" | bc ; done
}

function listRootObjs {
    myFile=$1

    if [ "$2" = "" ]
    then
	root -l -q $macrosDir/listRoot.C\(\"${1}\"\)
    else
	rootObj="KEY: $2"
	root -l -q $macrosDir/listRoot.C\(\"${1}\"\) | grep "$rootObj" |\
            cut -f2 | cut -d";" -f1
    fi
}

function listRootTHs {
    myFile=$1
    rootObj="KEY: $2"
    root -l -q $macrosDir/listRoot.C\(\"${1}\"\) | grep "TH"|\
        cut -f1,2 | cut -d":" -f2 |\
	cut -d";" -f1 | tr -d " "
}


function getMeanChans {
    rootCutFile="$1"
    spectraFile="$2"
    histVar="$3"
    intBool=$(checkIfInt $histVar)
    if [ "$intBool" = "true" ]
    then
        let finalNum=$myShift+$histVar
        strHVar=$myPrefix$finalNum
    else
        strHVar=$histVar
    fi
    hMeanBool="$4"
    cutHStrVar=$strHVar"CUT"
    echo -ne "$histVar\t"
    # number and then ommiting new line so it will continue to be filled by root
    myGreatV=$(root -l -q $macrosDir/probeObj.C\(\"${spectraFile}\"\,\"${strHVar}\"\)| tail -1)
    if [[ "$myGreatV"  =~ "TH2" ]]
    then
	# The next will print meanX, meanY
	root -l -q $macrosDir/fillCutSpectra.C\(\"${rootCutFile}\",\"${spectraFile}\",\"${cutHStrVar}\",\"${strHVar}\",${hMeanBool}\) | tail -1
    elif [[ "$myGreatV" =~ "TH1" ]]
    then
	maxMinVar=($(getMaxAndMin $strHVar $rootCutFile "x"))
	maxX=${maxMinVar[0]}
	minX=${maxMinVar[1]}
	root -l -q $macrosDir/simpleTH1Mean.C\(\"${spectraFile}\",\"${strHVar}\",$minX,$maxX,$hMeanBool\) | tail -1
    else
	echo "unsuported type"
    fi
}

function bashProbeObj {
    spectraFile="$1"
    strHVar="$2"
    probeVal=$(root -l -q $macrosDir/probeObj.C\(\"${spectraFile}\"\,\"${strHVar}\"\)| tail -1)
    echo "$probeVal"
}
function getMeanChansPartition {
    boolX="false"
    boolY="false"

    xMin=0
    xMax=1024

    yMin=0
    yMax=1024

    rootCutFile="$1"
    spectraFile="$2"
    histVar="$3"
    axisVar="$4"
    axisMin="$5"
    axisMax="$6"

    hMeanBool="$7"

    intBool=$(checkIfInt $histVar)
    if [ "$intBool" = "true" ]
    then
        let finalNum=$myShift+$histVar
        strHVar=$myPrefix$finalNum
    else
        strHVar=$histVar
    fi
    cutHStrVar=$strHVar"CUT"
    # number and then ommiting new line so it will continue to be filled by root
    echo -ne "$histVar\t"
    if [ "$axisVar"  = "y" ]
    then
        boolY="true"
        yMin=$axisMin
        yMax=$axisMax
    else
        boolX="true"
        xMin=$axisMin
        xMax=$axisMax
    fi
    myGreatV=$(root -l -q $macrosDir/probeObj.C\(\"${spectraFile}\"\,\"${strHVar}\"\)| tail -1)
    if [[ "$myGreatV"  =~ "TH2" ]]
    then
	# The next will print meanX, meanY
	root -l -q $macrosDir/fillCutSpectra.C\(\"${rootCutFile}\",\"${spectraFile}\",\"${cutHStrVar}\",\"${strHVar}\",$hMeanBool,$boolX,$xMin,$xMax,$boolY,$yMin,$yMax\) | tail -1
    elif [[ "$myGreatV" =~ "TH1" ]]
    then
	# maxMinVar=($(getMaxAndMin $strHVar $rootCutFile "x"))
	# maxX=${maxMinVar[0]}
	# minX=${maxMinVar[1]}
	# root -l -q $macrosDir/simpleTH1Mean.C\(\"${spectraFile}\",\"${strHVar}\",$minX,$maxX\) | tail -1
	echo "echo partition unimplemented on TH1" >&2
	echo "do a control C to stop this madness" >&2
	exit 342
    else
	echo "unsuported type"
    fi
}

function checkOpt {
    [ $# -eq 0 ] && printHelp && exit 0
    # [ "$1" = "--test" ] && checkIfInt $2 && exit 0

    if [[ $# -eq 1  && ( "$1" == "-h" || "$1" = "--help" ) ]]
    then
	      printHelp "extra"
	      exit 1
    elif [ "$1" = "--test" ]
    then
	echo "Using the testing option"


	# echo "using the getMaxAndMin function"
	# maxMinVar=($(getMaxAndMin "h10745" "my1DCuts.cut" "x"))
	# maxX=${maxMinVar[0]}
	# minX=${maxMinVar[1]}
	# echo "maxX=$maxX"
	# echo "minX=$minX"

	# root -l -q $macrosDir/simpleTH1Mean.C\(\"MySpectra212.root\",\"h10745\",$minX,$maxX\) | tail -1
	listRootTHs $2
	exit 8990
    elif [ "$1" = "-n" ]
    then
        shift
        tNumOrName="$1"
        spectraFile="$2"
        rootCutFile="$3"
        checkTypErr $tNumOrName $spectraFile $rootCutFile

        intBool=$(checkIfInt $tNumOrName)
        echo "intBool = $intBool"
        if [ $intBool = "true" ]
        then
            echo "it is an integer (telescope)"
            checkIfConfFile && source $confFile
            #The conf file has to exist to reach here
            checkIfValidN "$tNumOrName"
            doTheCut $@
        else
            echo "It is an histogram name (maybe)"
            doTheCut -n $@
        fi
    elif [ "$1" = "-a" ]
    then
        echo "Using the tNumOrNameFile option"
        shift
        tNumOrNameFile="$1"
        spectraFile="$2"
        rootCutFile="$3"

        checkTypErr2 $tNumOrNameFile $spectraFile $rootCutFile
        doAllCuts $tNumOrNameFile $spectraFile $rootCutFile
    elif [ "$1" = "-s" ]
    then
        echo "Using the sTNum option"
        shift
        sTNum="$1"
        intBool=$(checkIfInt $sTNum)
        [ "$intBool" = "false" ] && intError sTNum
	#Here you must also check if the corresponding telescope has
	#an histogram in the file

        eTNum=$maxTeles
        [ "$2" = "-e" ] && eTNum="$3" &&\
            shift 2 &&\
            [ "$eTNum" = "" ] &&\
            syntaxErrF

        intBool=$(checkIfInt $eTNum)
        [ "$intBool" = "false" ] && intError eTNum
        [ $eTNum -gt $maxTeles ] &&\
            echo "error: eTNum needs to be <= $maxTeles"

        [ $eTNum -lt $sTNum ] &&\
            echo "error: eTNum has to be >= sTNum">&2 && exit 999

        echo "Finished here"
        # tNumOrNameFile="$1"
        spectraFile="$2"
        rootCutFile="$3"

        checkTypErr3 $spectraFile $rootCutFile
        checkIfConfFile && source $confFile
        doAllCuts -sE $sTNum $eTNum $spectraFile $rootCutFile
    elif [ $# -eq 1 ] &&  [ "$1" == "--sampleConf" ]
    then
        createSampConf
        exit 0
    elif [ "$1" = "-d" ]
    then
	      echo "Using the delete option"
	      shift
        thing2Cut="$1"
        [ "$thing2Cut" = "" ] && syntaxErrF
	      echo "deleting the cut corresponding to $thing2Cut"
        intBool=$(checkIfInt $thing2Cut)

        if [ "$intBool" = "true" ]
        then
            echo "It is an integer"
            checkIfConfFile && source $confFile
            let histoNum=$myShift+$thing2Cut
	          histoVar=$myPrefix$histoNum
        else
            echo "It is a histoName (maybe)"
            histoVar=$thing2Cut
        fi

        echo "using $cutFile"
		    cutFile=$2
        [ ! -f "$cutFile" ] &&\
            existFileErr cutFile $cutFile

	      root -l -q $macrosDir/myCutDeleter.C\(\"${histoVar}\",\"${cutFile}\"\)
    elif [ "$1" = "-l" ]
    then
	      checkIfConfFile && source $confFile
	      shift
	      [ ! -f "$1" ] &&\
            echo "error: second argument\
 has to be a cut file">&2 && printHelp && exit 667
	      # listCutTel $1
        listRootObjs $@
    elif [ "$1" = "--lCut" ]
    then
	      checkIfConfFile && source $confFile
	      shift
	      [ ! -f "$1" ] &&\
            echo "error: second argument\
 has to be a cut file">&2 && printHelp && exit 667
	      listCutTel $1
    elif [ "$1" = "-b" ]
    then
	      shift
	      spectraFile="$1"
	      rootCutFile="$2"

        checkTypErr3 $spectraFile $rootCutFile
	      # checkIfConfFile && source $confFile
	      # [ ! -f "$rootCutFile" ] || [ ! -f "$spectraFile" ] &&\
        #     echo "error: both files have to exist">&2 && exit 888
        echo -e "#histogram\tmeanX\t[meanY]\tsigmaX\tcteX\t[sigmaY\tcteY]"

        hMeanBool=$(findOptVar "--hMean" "$@")
        # [ "$hMeanBool" = "true" ] && echo "DOING THE OLD H-MEAN"

        nVar=""
        nBool=$(findOptVar "-n" "$@")
        [ "$nBool" = "true" ] && nVar=$(getOptVar "-n" "$@")

        # if [ "$nBool" = "true" ]
        # then
        #     nVar=$(getOptVar "-n" "$@")
        #     [ "$nVar" = "" ] &&\
        #         echo "error: tNumOrName can't be empty" &&\
        #         printHelp &&\
        #         exit 593
        #     intBool=$(checkIfInt $nVar)
	      #     if [ "$intBool" = "true" ]
        #     then
        #         checkIfConfFile && source $confFile
	      #         listCutTel "$rootCutFile" |\
        #             grep "^$nVar$" > /dev/null
        #     else
        #         nVar=$(basename "$nVar" "CUT")
	      #         listRootObjs "$rootCutFile" "TCutG" |\
        #             grep "^$nVar""CUT$" > /dev/null
        #     fi
        # fi

        axVar="y"
        pVar=""
        pDelta=""
        pBool=$(findOptVar "-p" "$@")
        if [ "$pBool" = "true" ]
        then
            pVar=$(getOptVar "-p" "$@")
            pIntBool=$(checkIfInt $pVar)
            [ "$pIntBool" = "false" ] &&\
                intError "partition"
            [ $pVar -le 1 ] &&\
                echo "error: partition has to be > 1" &&\
                exit 7803
            axBool=$(findOptVar "--axis" "$@")
            if [ "$axBool" = "true" ]
            then
                axVar=$(getOptVar "--axis" "$@")
                if [[  ! (("$axVar" = "x"   ||  "$axVar" = "X") ||\
                              ("$axVar" = "y"   ||  "$axVar" = "Y")) ]]
                then
                    echo -e "error: ${red}$axVar${NC} invalid axis">&2 &&\
                        exit 7803
                fi
            fi
        fi

        if [ ! "$nVar" = "" ]
	      then
            intBool=$(checkIfInt $nVar)
	          if [ "$intBool" = "true" ]
            then
                checkIfConfFile && source $confFile
	              listCutTel "$rootCutFile" |\
                    grep "^$nVar$" > /dev/null
            else
                nVar=$(basename "$nVar" "CUT")
	              listRootObjs "$rootCutFile" "TCutG" |\
                    grep "^$nVar""CUT$" > /dev/null
            fi
            bFound=$?
	          [ $bFound -eq 1 ] && echo "histoCut\
 $nVar not found in cut file" >&2 && exit 999

            if [ ! "$pVar" = "" ]
            then
                getMeanPartData $rootCutFile $spectraFile $nVar $axVar $pVar $hMeanBool
            else
                getMeanChans $rootCutFile $spectraFile $nVar $hMeanBool
            fi
	          exit 0
	      fi
	      #put the values of the defined cuts in a bash array (use
	      #listcuttel function for this) echo them as they come for now
	      valCutTel=($(listRootObjs "$rootCutFile" "TCutG"))
	      for ee in ${valCutTel[*]}
	      do
            e=$(basename $ee CUT)
            if [ ! "$pVar" = "" ]
            then
                getMeanPartData $rootCutFile $spectraFile $e $axVar $pVar $hMeanBool
            else
                getMeanChans $rootCutFile $spectraFile $e $hMeanBool
            fi
            #Putting 2 spaces for easier analysis with plotting groups
            #with gnuplot but only when using partitions
            [ ! "$pVar" = "" ] && echo -e "\n"
	      done

	      exit 0
    elif [ "$1" = "--TH" ]
    then
	shift
	checkTypErr4 $@
	createTHFile $@
    elif [ "$1" = "--PT0" ]
    then
	shift
	getPTVal0 $@
	exit 892
    elif [ "$1" = "--draw" ]
    then
	echo "entered the draw option"
	[ ! "$2" =  "-n" ] && [ ! "$2" =  "-s" ] && echo "error: need -n or -s option" && exit 783
	sOrN="$2"
	[ "$3" =  "" ]  && echo "error: need a number or valid histogram name" && exit 785
	tNumOrName="$3"
	intBool=$(checkIfInt $tNumOrName)
	echo "intBool = $intBool"
	shift 3
	[ "$1" = "" ] && echo "error: at least one root file has to be given" && exit 788
	# echo "$1"
	array=( "$@" )
	arraylength=${#array[@]}
	echo arraylength = $arraylength
	for (( i=1; i<${arraylength}+1; i++ ));
	do
	    echo "checking if valid root file ${array[$i-1]}"
	    [ ! -f "${array[$i-1]}" ] &&\
		existFileErr spectraFile "${array[$i-1]}"
	done
	wholeArr=$(echo ${array[@]} | tr ' ' ',')
	echo the whole array is $wholeArr
	echo calling the root macro

	echo Doing it through the new func
	intBool=$(checkIfInt $tNumOrName)

        if [ "$intBool" = "false" ]
        then
            echo "it's a named histo">&2
            optionalVar="-n"
        else
            echo "it's an int">&2
            checkIfConfFile && source $confFile
            optionalVar=""
            echo "optionalVar=$optionalVar" >&2
        fi

	#Put conditional here if -s option was used and send the right option
	if [ "$sOrN" = "-n" ]
	then
	    doThePlot $optionalVar $tNumOrName "$wholeArr"
	else
	    echo "Using the other case"
	    [ "$intBool" = "false" ] && echo "Unimplemented" >&2 && exit 236
	    doAllPlots "-sE" $tNumOrName $maxTeles "$wholeArr"

	fi


    elif [ "$1" = "--ascii" ]
    then
	cat $myDir/asciiLogo.ascii
    else
	echo "error: \"$1\" unkown option" >&2
    fi

    exit 999
}

function createTHFile {
    spectraFile="$1"
    rootCutFile="$2"
    outFile="$3"
    myOption="$4"

    myAxVar="x"
    if [ "$myOption" = "--yCut" ]
    then
	echo "--yCut option being used"
	myAxVar="y"
    fi

    myTHSuffix=$(basename $rootCutFile .cut)
    myTHSuffix=$(basename $myTHSuffix .root) #Just in case
    myTHSuffix=$(echo $myTHSuffix | tr '.' 'p' ) #Worst case scenario
    hCArray=($(listRootObjs $rootCutFile TCutG))
    echo "Be patient, root file with cutted histograms"
    for hCV in ${hCArray[*]}
    do
	hVBase=$(basename $hCV CUT)
	hV=$hVBase"_$myTHSuffix"
	echo $hV
	myGreatV=$(root -l -q $macrosDir/probeObj.C\(\"${spectraFile}\"\,\"${hVBase}\"\)| tail -1)
	if [[ "$myGreatV"  =~ "TH2" ]]
	then
	    # The next will save the cut histo in a file
	    root -l -q $macrosDir/fillCutSpectra.C\(\"${rootCutFile}\",\"${spectraFile}\",\"${hCV}\",\"${hVBase}\","false","false",0,1024,"false",0,1024,"true",\"$outFile\",\"$hV\"\) > /dev/null
	elif [[ "$myGreatV" =~ "TH1" ]]
	then
	    maxMinVar=($(getMaxAndMin $hVBase $rootCutFile "$myAxVar"))
	    maxX=${maxMinVar[0]}
	    minX=${maxMinVar[1]}
	    root -l -q $macrosDir/simpleTH1Mean.C\(\"${spectraFile}\",\"${hVBase}\",$minX,$maxX,"false","true",\"$outFile\",\"$hV\"\) | tail -1
	else
	    echo "unsuported type"
	fi
    done
}

function checkHistStuff {
    histName="$1"
    spectraFile="$2"

    [ ! -e "$spectraFile" ] && echo "Error: $spectraFile doesn't exist" >&2 && exit 666
    myBoolV=$(root -l -q $macrosDir/checkHistExist.C\(\"${histName}\",\"${spectraFile}\) | tail -1)
    echo $myBoolV
    if [ $myBoolV = "True" ]
    then
	echo "made it"
	doTheCut "-n" $@
    fi
}

function createSampConf(){
    echo "#########CONFIGURATION PART##########">$confFile
    echo "myShift=50000">>$confFile
    echo "myPrefix=\"h\"">>$confFile
    echo "logy4H1=\"False\" #for TH1">>$confFile
    echo "#####################################">>$confFile
    echo -e "Created configuration file named ${red}$confFile${NC}."
    echo -e "The content is:\n"
    cat $confFile
    echo ""
    echo "Modify it accordingly to your necessities"
    exit 0
}

function printCutCoords {
    cutName=$1
    cutFN=$2
    root -l -q $macrosDir/printCut.C\(\"$cutName\",\"$cutFN\"\) | grep "x\[.*\]=.*, y\[.*\]=.*" |\
	sed 's/[x|y]\[[0-9]*\]=//g' | sed 's/, /\t/g' | head -n -1
}

function getMaxAndMin {
    cutName=$1
    cutFN=$2
    axVar=$3

    # echo axVar = $axVar >&2
    intBool=$(checkIfInt $cutName)
    if [ "$intBool" = "true" ]
    then
        let finalNum=$myShift+$cutName
        strHVar=$myPrefix$finalNum
    else
        strHVar=$cutName
    fi
    cutHStrVar=$strHVar"CUT"

    if [ "$3" = "x" ] || [ "$3" = "X" ]
    then
        myColN=1
    elif [ "$3" = "y" ] || [ "$3" = "Y" ]
    then
	      myColN=2
    else
	      echo "Error; argument has to be an axis (x or y)" >&2
	      exit 890
    fi
    myVar=($(printCutCoords $cutHStrVar $cutFN |\
                 cut -f$myColN | sort -rg))
    maxVal=${myVar[0]}
    let lastIdx=${#myVar[*]}-1
    minVal=${myVar[$lastIdx]}

    #using printf for rounding. In bash the behaviour is ideal but not
    #in (for example) zshell. Decimal parts under .5 are "grounded"and
    #over are "ceiled".
    # printf "%.0f %.0f\n" $maxVal $minVal

    echo "$maxVal $minVal"
}

function isNumber {
    myNum=$1
    re='^[0-9]+$'
    if ! [[ $myNum =~ $re ]] ; then
	echo "false"
    else
	echo "true"
    fi
}

function getPartitionDelta {
    maxVal=$1
    minVal=$2
    partN=$3
    diff=$(echo "scale=3;$maxVal-$minVal" | bc)
    delta=$(echo "scale=3;$diff/$partN" | bc)
    echo $delta
}

# function getAxisName {

# }

function getRangeArr {
    maxVal=$1
    minVal=$2
    partN=$3
    delta=$(getPartitionDelta $maxVal $minVal $partN)
    arrStr="$minVal"
    newMax=$minVal
    for myFVar in $(seq 1 $partN)
    do
	      newMax=$(echo "scale=3;$newMax+$delta" | bc)
	      arrStr=$arrStr" $newMax"
    done
    echo "$arrStr"
}

##########The usage!!#############################
# checkArgNum $@
# source $confFile

export gBool=$(findOptVar "--fitGauss" "$@")

checkOpt $@

# echo -e "${red}$(basename $0) arguments are ${1} and ${2}${NC}"

exit 0
