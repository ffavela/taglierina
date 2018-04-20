#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

void getAxName(const char *hName,
	       const char *myRootFName,
	       const char *xOrY="x",){

  TFile *f = new TFile(myRootFName,"update");

  TH2F *myH=(TH2F *)f->Get(hName);
  if (myH != 0){
    myCut->Print();
  }

  myCuts->Close();
  return;
}
