#!/bin/bash

# #########CONFIGURATION PART##########
# myShift=50000
# myPrefix="h"
# #####################################

confFile="tagl.conf"

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

function printHelp {
	echo -e "usage:"
	echo -e "\t$(basename $0) -h"
  echo -e "\t$(basename $0) ${red}--sampleConf${NC}"
	echo -e "\t$(basename $0) (-t telesNum | -a goodTelFile) spectraFile"
	echo -e "\t$(basename $0) -d telesNum [rootCutFile]"
	echo -e "\t$(basename $0) -l rootCutFile"
	echo -e "\t$(basename $0) -b rootCutFile spectraFile [-t telesNum]\n"
	[ "$1" != "extra" ] && return
	echo "This program ($(basename $0)) is for making cuts on 2D histos"
	echo "it creates a cut file called myCutFile.root where"
	echo "the cuts will be stored (to be used by some other program)."
	echo ""
	echo -e "the -h syntax will print this help.\n"
	echo -e "the syntax with -d will delete the cut of telescope telesNum"
	echo -e "myCutFile.root is the default file in case rootCutFile was not"
	echo -e "specified.\n"

  echo -e "the ${red}--sampleConf${NC} option will create a sample"
	echo -e "configuration file named $confFile.\n"

	echo -e "using -t will help create a cut for the particular telescope."
 	echo -e "the -a syntax will take a set of telescopes"
	echo -e "from a file (goodTelFile), it needs to be"
	echo -e "a ${red}one column${NC} file of valid chimera telescopes."
	echo -e "typing x and then <enter> will exit inmediately.\n"

	echo "If there was already a valid cut for a particular telescope, it"
	echo "will display it. You can modify it and the cut will be updated."
	echo "You can also make a new cut and the old one will be replaced."
	echo "If you want to delete a cut that was already on the file then"
	echo "use the -d option."
	echo ""
	echo "the -l option lists the telescopes with graphical cuts in a root file."
	echo ""
	echo "the -b syntax will create cut histograms using the cuts defined in rootCutFile"
	echo "checking every element in the corresponding histogram (in spectraFile) is inside the"
	echo -e "cut. It creates the corresponding cut histograms in the file ${red}cutFileHistos.root${NC}"
	echo "the filename depends on the name of the rootCutFile. It also outputs two columns, "
	echo "one is the telescope number and the second is the median channel of the histogram."
	echo "If the -t option is used here, it will do the operation only for the selected telescope."
	echo -e "In case the histogram already exists in the ${red}cutFileHistos.root${NC} then it will"
	echo "only print out the two column."
	echo ""
}

function checkArgNum {
    if [ $# -eq 1 ] &&  [ "$1" == "-h" ]
    then
	      return
    elif [ $# -eq 1 ] &&  [ "$1" == "--sampleConf" ]
    then
        createSampConf
         return
    fi

    #The rest of the cases need the confiruration file!
    [ ! -e $confFile ] && echo "error $confFile doesn't exist" && exit 666

    if [ "$1" == "-d" ]
    then
	return
    fi

    if [ "$1" == "-l" ]
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


    if [ $# -ne 3 ]
    then
	printHelp
	exit 1
    fi
}

function doTheCut {
    magicS="(int)666"
    value=$1
    let histoNum=$myShift+$value
    histoVar=$myPrefix$histoNum
    echo -e "${red}Press enter after selecting the region${NC}"
    root -l -q myH2Cutter.C\(\"${histoVar}\",\"${2}\"\)
    [ -e $specialLogF ] && echo "exiting inmediately" && rm $specialLogF && exit 666
    echo ""
}

function doAllCuts {
    goodTelFile=$1
    spectraFile=$2
    readarray tArr < $goodTelFile
    for value in ${tArr[*]}
    do
	#Sometimes the last val is "". Make sure you dont leave empty
	#lines in between or it will exit inmediately.
	[ "$value" = "" ] && exit 0
	echo "Value - $value"

	doTheCut $value $spectraFile
    done
}

function listCutTel {
    root -l -q listRoot.C\(\"${1}\"\) | grep "KEY: TCutG" |\
         cut -f2 | cut -d";" -f1 | cut -d"$myPrefix" -f2 |\
         sed 's/CUT//g' | sort |\
         while read -r line; do echo "$line - $myShift" | bc ; done
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
    root -l -q fillCutSpectra.C\(\"${rootCutFile}\",\"${spectraFile}\",\"${cutHStrVar}\",\"${strHVar}\"\) | tail -1
}

function checkOpt {
    if [ "$1" = "-h" ]
    then
	printHelp "extra"
	exit 1
    elif [ "$1" = "-d" ]
    then
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
	    root -l -q myCutDeleter.C\(\"${histoVar}\",\"${cutFile}\"\)
	echo "Using the delete option"
	else
	    echo "error invalid syntax" >&2
	    exit 8
	fi

	exit 1
    fi
    if [ "$1" = "-l" ]
    then
	shift
	[ ! -f "$1" ] &&\
            echo "error: second argument has to be a cut file">&2 && exit 667
	listCutTel $1
    exit 0
    elif [ "$1" = "-b" ]
	then
	shift
	rootCutFile="$1"
	spectraFile="$2"
	[ ! -f "$rootCutFile" ] || [ ! -f "$spectraFile" ] &&\
            echo "error: both files have to exist">&2 && exit 888
	if [ "$3" = "-t" ]
	    then
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
	telesNum=$2
	#Then do a check if it is a valid telescope
	checkIfValidN $telesNum
	shift
	doTheCut $@
    elif [ "$1" = "-a" ]
    then
	goodTelFile=$2
	#Do a check if file exists and it is a regular file.
	[ ! -f $goodTelFile ] && echo "error: $goodTelFile is not a valid file" >&2 && exit 4
	shift
	doAllCuts $@
    else
	echo "Invalid option" >&2
	exit 2
    fi
}

function createSampConf(){
    echo "#########CONFIGURATION PART##########">$confFile
    echo "myShift=50000">>$confFile
    echo "myPrefix=\"h\"">>$confFile
    echo "#####################################">>$confFile
    echo "Created configuration file named $confFile"
    echo "Modify it accordingly to your necessities"
    exit 0
}

##########The usage!!#############################
checkArgNum $@
source $confFile
checkOpt $@

# echo -e "${red}$(basename $0) arguments are ${1} and ${2}${NC}"

exit 0
