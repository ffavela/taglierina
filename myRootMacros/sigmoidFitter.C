#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//For fitting a sigmoid to an histogram (useful for punch through
//analisys)
// Double_t sigmoidFun(Double_t *x, Double_t *params);

Double_t sigmoidFun(Double_t *x, Double_t *params){
  return params[2]*(1-1/(1+exp(-(x[0]-params[0])/params[1])));
}

//The function that calls it should previously set up a Double_t
//params[3]

void sigmoidFitter(TH1D *myHToFit, Double_t minVal,
		 Double_t maxVal, Double_t *params) {

// void sigmoidFitter(TH1D *myHToFit){
// void sigmoidFitter() {

  printf("Hello world\n");
  // return;

		 //   , Double_t minVal,
		 // Double_t maxVal, Double_t *params) {


  int npar=3; //Number of paramenters

  //Q means quiet, 0 means don't do a plot
  // myHToFit->Fit("gaus","Q0");

  // TF1 *fit = myHToFit->GetFunction("gaus");

  // TF1 *func = new TF1("fitFunc",sigmoidFun,minVal,maxVal,npar);

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

  b=(minValXPos-cXPos)*10;//"skin thickness" guess

  TF1 *func = new TF1("fitFunc",sigmoidFun,cXPos,minValXPos,npar);

  //putting my initial guesses in the params array
  params[0]=a;//"inflection"
  params[1]=b;//"skin thickness"
  params[2]=c;//"height"

  printf("the initial guessed values are:\n");
  printf("%0.4f\t%0.4f\t%0.4f\n\n",params[0],params[1],params[2]);
  func->SetParameters(params);

  // myHToFit->Fit("fitFunc","Q0");
  myHToFit->Fit("fitFunc","");
  Double_t p0 = func->GetParameter(0);
  Double_t p1 = func->GetParameter(1);
  Double_t p2 = func->GetParameter(2);
  // printf("The parameters are\n");
  printf("the final values are:\n");
  printf("%0.4f\t%0.4f\t%0.4f\n",p0,p1,p2);
  // Double_t pars[3];
  // pars[0]=p0;
  // pars[1]=p1;
  // pars[2]=p2;
  // return pars;
  return;
}
