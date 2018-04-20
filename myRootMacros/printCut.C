#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

void printCut(const char *cutName,
	       const char *myCutFileName="myCutFile.root"){

  TFile *myCuts = new TFile(myCutFileName,"update");

  TCutG *myCut=(TCutG *)myCuts->Get(cutName);
  if (myCut != 0){
    myCut->Print();
  }

  myCuts->Close();
  return;
}
