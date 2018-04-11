#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

void checkHistExist(const char *name,
	       const char *fileName="MySpectra212.root"){

  TFile *f = new TFile(fileName,"update");

  TH2F *myH2Stuff=(TH2F *)f->Get(name);
  if (myH2Stuff == 0){
    printf("False\n");
  } else {
    printf("True\n");
  }
}
                                                                                                                                                       
