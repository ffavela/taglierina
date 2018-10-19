#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"


//Somehow put here the header for the #include "getPTAttempt0.C" or
//something, for now function  is defined down.
void getPTAttempt0(TH1D *myHToFit, Double_t *params);
Int_t getMaxPopBin(TH1D *myTH1);
Int_t getLiftBin(TH1D *myTH1, Int_t maxPopBin);

void printPTParams(const char *cuttedSpeFN, const char *hName,
                    int type,const char *axis="x") {
  // printf("Hello fantastic world\n");

  TFile *fHistos = new TFile(cuttedSpeFN,"update");
  Int_t maxPopBin, liftBin;

  if (type == 2) {
    TH2D *myH2Stuff=(TH2D *)fHistos->Get(hName);
    if ( axis == "x" )
      TH1D *projSpect = (TH1D *) myH2Stuff->ProjectionX();
    else //it was "y"
      TH1D *projSpect = (TH1D *) myH2Stuff->ProjectionY();
  } else if (type == 1) {
    TH1D *projSpect = (TH1D *) fHistos->Get(hName);
  }

  //Now call the function somehow
  // Double_t params[3];
  // getPTAttempt0(projSpect,params);
  // printf("%0.3f\t%0.3f\t%0.3f\n",params[0],params[1],params[2]);

  // printf("%0.3f\n",params[0]);

  maxPopBin=getMaxPopBin(projSpect);
  liftBin=getLiftBin(projSpect, maxPopBin);
  printf("%d\n",liftBin);
  return;
}

// putting this here until I figure how to do it with the include
void getPTAttempt0(TH1D *myHToFit, Double_t *params) {
  int maxBin=myHToFit->GetMaximumBin();
  int nBins=myHToFit->GetXaxis()->GetNbins();
  myHToFit->GetXaxis()->SetRange(maxBin,nBins);
  int minBin=myHToFit->GetMinimumBin();//gets the min in the range (after the max)

  // myHToFit->GetXaxis()->SetRange(maxBin,minBin);//Improving the range for
  					  //the histogram

  int infl_bin=(maxBin+minBin)/2;//guess of the inflection bin

  Double_t a,b,c,minVal;
  minVal=myHToFit->GetBinContent(minBin);//4 the skin thickness

  a=myHToFit->GetXaxis()->GetBinCenter(infl_bin);//inflection
  c=myHToFit->GetBinContent(maxBin);//height

  Double_t cXPos=myHToFit->GetXaxis()->GetBinCenter(maxBin);
  Double_t minValXPos=myHToFit->GetXaxis()->GetBinCenter(minBin);

  b=(minValXPos-cXPos);//"skin thickness" guess

  //putting my initial guesses in the params array
  params[0]=a;//"inflection"
  params[1]=b;//"skin thickness"
  params[2]=c;//"height"

  // printf("the initial guessed values are:\n");
  // printf("%0.4f\t%0.4f\t%0.4f\n\n",params[0],params[1],params[2]);

  //the params values can now be accesed from outside the function
  return;
}

Int_t getMaxPopBin(TH1D *myTH1){
  Int_t nCells = myTH1->GetSize();
  Int_t maxPopBin=nCells; //Worst case scenario we return this

  for (int myBin=nCells;myBin>0;myBin--){
    if (myTH1->GetBinContent(myBin) > 0)
      return myBin;
  }
  return -1;
}

Int_t getLiftBin(TH1D *myTH1,Int_t maxPopBin){
  Double_t myAverage, mySqrAverage;
  Double_t myVariance, myAvVariance;
  Double_t myVarianceSum=0;
  Int_t mySum=0;
  Int_t mySqrSum=0;
  Int_t N=0;
  Int_t myBin=maxPopBin;
  Int_t myInitSampl=5; //Number of bins for init average etc.

  while(myInitSampl > 0){
    mySum+=myTH1->GetBinContent(myBin);
    mySqrSum+=(myTH1->GetBinContent(myBin))**2;
    myBin-=1;
    N+=1;
    myInitSampl-=1;
  }

  myAverage=(1.0*mySum)/N;
  mySqrAverage=(1.0*mySqrSum)/N;

  myVariance=sqrt(mySqrAverage-myAverage**2);
  myVarianceSum=myVariance*N;
  myAvVariance=myVarianceSum/N;//For obviousness

  while (myBin > 0){
    mySum+=myTH1->GetBinContent(myBin);
    mySqrSum+=(myTH1->GetBinContent(myBin))**2;
    N+=1;

    myAverage=(1.0*mySum)/N;
    mySqrAverage=(1.0*mySqrSum)/N;
    myVariance=sqrt(mySqrAverage-myAverage**2);
    myVarianceSum+=myVariance;
    myAvVariance=myVarianceSum/N;
    if (myVariance/myAvVariance > 1.5)
      return myBin;
    myBin-=1;
  }
  return -1;
}
