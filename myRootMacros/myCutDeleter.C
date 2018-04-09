#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

void myCutDeleter(const char *name,
		  const char *fileCUT="myCutFile.root"){
  const char myCutName[50],innCutName[50];

  TFile *fCUT = new TFile(fileCUT,"update");


  sprintf(myCutName,"%sCUT",name);
  printf("looking for %s\n",myCutName);
  TCutG *oldCut=(TCutG *)fCUT->Get(myCutName);
  if (oldCut == 0){
    printf("Cut did not exist\n");
    return;
  }

  //If we reached here then it did exist so we need to remove it.

  //Unelegant way deleting the old cut
  //myCuts->Delete(myCutName) will not work!

  //We need to create a string with the horrible ";1"
  sprintf(innCutName,"%s;1",myCutName);
  //And do the deleting
  fCUT->Delete(innCutName);

  cout<<innCutName<<" has been deleted"<<endl;
  fCUT->Close();
}
