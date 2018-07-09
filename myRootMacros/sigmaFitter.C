#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"
#include "TMath.h"

//For fitting a sigmoid to an histogram (useful for punch through
//analisys)

Double_t sigmaFun(Double_t *x, Double_t *params){
  return params[2]*(1-1/(1-Exp(-params[1]*(x[0]-params[0]))));
}

//The function that calls it should previously set up a Double_t
//params[3]

void sigmaFitter(TH1F *myHToFit, Double_t minVal,
		 Double_t maxVal, Double_t *params) {

  int npar=3; //Number of paramenters

  //Q means quiet, 0 means don't do a plot
  // myHToFit->Fit("gaus","Q0");
  TF1 *func = new TF1("fit",sigmaFun,minVal,maxVal,npar);

  // TF1 *fit = myHToFit->GetFunction("gaus");

  // func->SetParameters[];
  
  fit->SetParameters(params);
  Double_t p0 = fit->GetParameter(0);
  Double_t p1 = fit->GetParameter(1);
  Double_t p2 = fit->GetParameter(2);
  // printf("The parameters are\n");
  printf("%0.4f\t%0.4f\t%0.4f\n",p0,p1,p2);
  Double_t pars[3];
  pars[0]=p0;
  pars[1]=p1;
  pars[2]=p2;
  return pars;
}
