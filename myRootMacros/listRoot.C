#include "TH1.h"
#include "TCutG.h"
#include "TSystem.h"
#include "TObject.h"

int listRoot(const char *fileName){
  TFile *f = new TFile(fileName,"read");

  f->ls();
  f->Close();
  // printf("Hello wonderful world\n");
  // printf("Argument is %s\n",name);
  return 0;
}
                                                                                                                                                       
