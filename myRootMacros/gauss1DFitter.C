#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//Decided to implement the function directly on the other scripts. So
//this is not being used at the moment.
Double_t *gauss1DFitter(TH1F *myH2Fit) {
  //Q means quiet, 0 means don't do a plot
  myH2Fit->Fit("gaus","Q0");
  TF1 *fit = myH2Fit->GetFunction("gaus");
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
