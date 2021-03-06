#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//For fitting a sigmoid to an histogram (useful for punch through
//analisys)

Double_t sigmoidFun(Double_t *x, Double_t *params){
  return params[2]*(1-1/(1+exp(-(x[0]-params[0])/params[1])));
}

//The function that calls it should previously set up a Double_t
//params[3]

void sigmoidFitter(TH1D *myHToFit, Double_t *params) {
  
  printf("Hello world\n");

  int npar=3; //Number of paramenters

  int maxBin=myHToFit->GetMaximumBin();
  int nBins=myHToFit->GetXaxis()->GetNbins();
  myHToFit->GetXaxis()->SetRange(maxBin,nBins);
  int minBin=myHToFit->GetMinimumBin();//gets the min in the range (after the max)

  myHToFit->GetXaxis()->SetRange(maxBin,minBin);//Improving the range for
  					  //the histogram
  int infl_bin=(maxBin+minBin)/2;//guess of the inflection bin

  Double_t a,b,c,minVal;
  minVal=myHToFit->GetBinContent(minBin);//4 the skin thickness

  a=myHToFit->GetXaxis()->GetBinCenter(infl_bin);//inflection
  c=myHToFit->GetBinContent(maxBin);//height

  Double_t cXPos=myHToFit->GetXaxis()->GetBinCenter(maxBin);
  Double_t minValXPos=myHToFit->GetXaxis()->GetBinCenter(minBin);

  b=(minValXPos-cXPos);//"skin thickness" guess

  TF1 *func = new TF1("fitFunc",sigmoidFun,cXPos,minValXPos,npar);

  //putting my initial guesses in the params array
  params[0]=a;//"inflection"
  params[1]=b;//"skin thickness"
  params[2]=c;//"height"

  printf("the initial guessed values are:\n");
  printf("%0.4f\t%0.4f\t%0.4f\n\n",params[0],params[1],params[2]);
  func->SetParameters(params);

  // myHToFit->Fit("fitFunc","Q0");//to suppress the plot and printout
  myHToFit->Fit("fitFunc","");
  Double_t p0 = func->GetParameter(0);
  Double_t p1 = func->GetParameter(1);
  Double_t p2 = func->GetParameter(2);

  printf("the final values are:\n");
  printf("%0.4f\t%0.4f\t%0.4f\n",p0,p1,p2);

  return;
}
