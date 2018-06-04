#!/bin/bash

macrosDir="myRootMacros"
myWhich=$(which $0)
if [ ! $myWhich = "./taglierina.sh" ]
then
    #Symlink way
    linkLoc=$(readlink $myWhich)
    macrosDir="$(dirname $linkLoc)/$macrosDir"
fi

#Made this an external file, see the --sampleConf option
# #########CONFIGURATION PART##########
# myShift=50000
# myPrefix="h"
# #####################################

confFile="tagl.conf" #replacing the above

myCutFile="myCutFile.root"
specialLogF="specialLogF.txt"

[ -e $specialLogF ] && rm $specialLogF

#Defining red color for some prompts
red='\e[0;31m'
blue='\e[0;34m'
NC='\e[0m' # No Color

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
    minTeles=0
    maxTeles=1191

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

function printHelp {
    echo -e "usage:"
	  echo -e "\t$(basename $0) -h"
	  echo -e "\t$(basename $0) -n tNumOrName spectraFile rootCutFile"
    echo -e "\t$(basename $0) -a tNumFile spectraFile rootCutFile"
    echo -e "\t$(basename $0) -A histNameFile spectraFile rootCutFile"
    echo -e "\t$(basename $0) -s sTNum [-e eTNum] spectraFile rootCutFile"
	  # echo -e "\t$(basename $0) -na histoNameFile spectraFile rootCutFile"
    echo -e "\t$(basename $0) ${red}--sampleConf${NC}"
	  # echo -e "\t$(basename $0) (-t telesNum | -a goodTelFile) spectraFile [rootCutFile]"
	  # echo -e "\t$(basename $0) -d telesNum [rootCutFile]"
    echo -e "\t$(basename $0) -l rootFile [rootObject]"
    echo -e "\t$(basename $0) --lCut rootCutFile"
    echo -e "\t$(basename $0) -b spectraFile rootCutFile [-n tNumOrName] [-p partition]\n"
	  [ "$1" != "extra" ] && return

    longExtraStr="\
  This program ($(basename $0)) is for making cuts on 2D histograms\n\
and for facilitating the calibration process. Note that some of the\n\
options are intended for specific telescopes of CHIMERA. Most of\n\
the options need an existing spectraFile and a rootCutFile that\n\
gets created in case it did not previously exist. When telescope\n\
numbers are used, a configuration file is required.\n\n\
 -h will print this help.\n\
 -n needs a telescope number or a histogram name.\n\
 -a needs a file with telescope numbers as a single column.\n\
 -A needs file with histogram names as a single column.\n\
 -s needs a starting telescope number, if -e then it will stop\n\
  until the eTNum telescope, else it will continue until 1191.\n\
   ${red}--sampleConf${NC} will create a sample configuration file\n\
     named ${red}$confFile${NC}.\n\
 -l will list the contents of a root file, if rootObject is used then\n\
 it will only output those objects.\n\
 --lCut is equivalent to: $ taglierina -l rootFile TCUTG.\n
 -b will output the centroid of the histogram inside each of the cuts\n\
 inside rootCutFile. If -n is used, then it will do it just for the\n\
 specific corresponding cut. If -p is used then for every cut it will\n\
 create a partition.
"
    echo -e $longExtraStr

	  echo ""
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
    if [ $# -eq 1 ] &&  [ "$1" == "-h" ]
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
    [ ! "$3" = "" ] && rootCFile="$3"
    echo -e "${red}Press enter after selecting the region${NC}" >&2

    runDraw="true"
    while [ "$runDraw" = "true" ]
    do
	runDraw="false"
	root -l -q $macrosDir/myH2Cutter.C\(\"${histoVar}\",\"${spectraFile}\",\"${rootCFile}\"\)
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

	    rm $specialLogF
	fi
	echo ""
    done
}

function doAllCuts {
    opnionalVar=""
    if [ "$1" = "-na" ]
    then
	echo "Looping through named histograms"
	optionalVar="-n"
	shift
    fi

    goodTelFile=$1
    spectraFile=$2
    myRCFile=$3
    readarray tArr < $goodTelFile
    arrSize=${#tArr[*]}
    echo "arrSize = $arrSize"
    myIdx=0

    # for value in ${tArr[*]}
    while [ $myIdx -lt $arrSize ]
    do
	echo -e "${red}myIdx = $myIdx ${NC}"

	[ $myIdx -le 0 ] && myIdx=0
	value=${tArr[$myIdx]}
	#Sometimes the last val is "". Make sure you dont leave empty
	#lines in between or it will exit inmediately.
	[ "$value" = "" ] && exit 0
	echo "Value - $value"
	doTheCut $optionalVar $value $spectraFile $myRCFile || let myIdx=$myIdx-2
	let myIdx=$myIdx+1
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

function getMeanChans {
    rootCutFile="$1"
    spectraFile="$2"
    let finalNum=$myShift+$3
    strHVar=$myPrefix$finalNum
    cutHStrVar=$strHVar"CUT"
    # number and then ommiting new line so it will continue to be filled by root
    echo -ne "$3\t"
    # The next will print meanX, meanY
    root -l -q $macrosDir/fillCutSpectra.C\(\"${rootCutFile}\",\"${spectraFile}\",\"${cutHStrVar}\",\"${strHVar}\"\) | tail -1
}

function checkOpt {
    [ $# -eq 0 ] && printHelp && exit 0
    [ "$1" = "--test" ] && checkIfInt $2 && exit 0

    if [ "$1" = "-h" ]
    then
	      printHelp "extra"
	      exit 1
    elif [ "$1" = "-n" ]
    then
        echo "entered new cond"
        shift
        intBool=$(checkIfInt $1)
        echo "intBool = $intBool"
        if [ $intBool = "true" ]
        then
            echo "it is an integer (telescope)"
            checkIfConfFile && source $confFile
            #The conf file has to exist to reach here
            checkIfValidN "$1"
            doTheCut $@
        else
            echo "It is an histogram name"
            doTheCut -n $@
        fi
            exit 345

    elif [ "$1" = "-d" ]
    then
	      checkIfConfFile && source $confFile
	      echo "Using the delete option"
	      shift
	      if [ $# -eq 1 ] || [ $# -eq 2 ]
	      then
	          echo "deleting the cut corresponding to $1"
	          if [ $# -eq 2 ]
	          then
		            cutFile=$2
	          else
		            cutFile=$myCutFile
	          fi
	          echo "using $cutFile"
	          [ ! -f $cutFile ] && echo "$cutFile does not exist" >&2 && exit 789
	          value=$1
	          let histoNum=$myShift+$value
	          histoVar=$myPrefix$histoNum
	          root -l -q $macrosDir/myCutDeleter.C\(\"${histoVar}\",\"${cutFile}\"\)
	          echo "Using the delete option"
	      else
	          echo "error invalid syntax" >&2
	          exit 8
	      fi
	      exit 1
    fi
    if [ "$1" = "-l" ]
    then
	checkIfConfFile && source $confFile
	shift
	[ ! -f "$1" ] &&\
            echo "error: second argument has to be a cut file">&2 && exit 667
	listCutTel $1
    exit 0
    elif [ "$1" = "-ln" ]
    then
	shift
	[ ! -f "$1" ] &&\
            echo "error: second argument has to be a root file">&2 && exit 668
	listRootObjs $@
    exit 0
    elif [ "$1" = "-pc" ]
    then
	shift
	[ "$1" = "" ] && echo "Error; need a cutName" >&2 && exit 555
	[ "$2" = "" ] && echo "Error; need a cutFilename" >&2 && exit 556
	[ ! -f "$2" ] &&\
            echo "error: third argument has to be a root cut file">&2 && exit 668
	cutName=$1
	cutFN=$2

	# printCutCoords $cutName $cutFN
	axis=$3
	myMaxMinVar=$(getMaxAndMin $cutName $cutFN $axis)
	echo $myMaxMinVar

	partN=$4
	partBool=$(isNumber $partN)
	[ $partBool = "false" ] && echo "Error; enter positive integer as last arg" && exit 1234
	#remember maxMinVar are 2 values
	getPartitionDelta $myMaxMinVar $partN

	echo "The rangeArr is"
	getRangeArr $myMaxMinVar $partN

    exit 0
    elif [ "$1" = "-b" ]
    then
	checkIfConfFile && source $confFile
	shift
	rootCutFile="$1"
	spectraFile="$2"
	[ ! -f "$rootCutFile" ] || [ ! -f "$spectraFile" ] &&\
            echo "error: both files have to exist">&2 && exit 888
	if [ "$3" = "-t" ]
	then
	    checkIfConfFile && source $confFile
	    checkIfValidN "$4"
	    listCutTel "$rootCutFile" | grep "^$4$" > /dev/null
	    bFound=$?
	    [ $bFound -eq 1 ] && echo "telescope $4 not found in cut file" >&2 && exit 999
	    # echo "telescope $4 found in cut file, doing histo and stuff"
	    getMeanChans $rootCutFile $spectraFile $4
	    exit 0
	fi
	#put the values of the defined cuts in a bash array (use listcuttel function for this)
	#echo them as they come for now

	valCutTel=$(listCutTel "$rootCutFile")
	for e in ${valCutTel[*]}
	do
	    # echo "e = $e"
	    getMeanChans $rootCutFile $spectraFile $e
	done

	exit 0
    fi


    spectraFile=$3
    [ ! -e $spectraFile ] && echo "error: $spectraFile is not a valid spectraFile" && exit 5
    if [ "$1" = "-t" ]
    then
	checkIfConfFile && source $confFile
	telesNum=$2
	#Then do a check if it is a valid telescope
	checkIfValidN $telesNum
	shift
	doTheCut $@
    elif [ "$1" = "-a" ]
    then
	checkIfConfFile && source $confFile
	goodTelFile=$2
	#Do a check if file exists and it is a regular file.
	[ ! -f $goodTelFile ] && echo "error: $goodTelFile is not a valid file" >&2 && exit 4
	shift
	doAllCuts $@
    elif [ "$1" = "-na" ]
    then
	nameFile=$2
	#Do a check if file exists and it is a regular file.
	[ ! -f $nameFile ] && echo "error: $nameFile is not a valid file" >&2 && exit 4
	shift
	doAllCuts -na $@
    else
	echo "Invalid option" >&2
	exit 2
    fi
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
    myVar=($(printCutCoords $cutName $cutFN | cut -f$myColN | sort -rg))
    maxVal=${myVar[0]}
    let lastIdx=${#arr[*]}-1
    minVal=${myVar[$lastIdx]}
    echo $maxVal $minVal
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
checkOpt $@

# echo -e "${red}$(basename $0) arguments are ${1} and ${2}${NC}"

exit 0
