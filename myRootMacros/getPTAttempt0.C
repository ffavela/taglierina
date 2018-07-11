#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//Useful for punch through analisys, for now it is not being called

//The function that calls it should previously set up a Double_t
//params[3]

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
