#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

int myH2Cutter(const char *name,
	       const char *fileName="MySpectra212.root",
	       const char *myCutFileName="myCutFile.root"){
  const char *input;

  const char myCutName[50],innCutName[50];

  
  Bool_t done = kFALSE;
  char tString[50],temp[50],bName[50];
  
  TFile *f = new TFile(fileName,"update");

  // printf("Hello wonderful world\n");
  // printf("Argument is %s\n",name);

  TH2F *myH2Stuff=(TH2F *)f->Get(name);
  if (myH2Stuff == 0){
    printf("Error: histogram does not exist\n");
    return 0;
  }

  TTimer *timer = new TTimer("gSystem->ProcessEvents();", 50, kFALSE);

  TCanvas *c1 = new TCanvas("c1", "Select cut region", 900, 750);
  c1->ToggleToolBar();
  c1->ToggleEventStatus();
  
  myH2Stuff->Draw();

  TFile *myCuts = new TFile(myCutFileName,"update");
  sprintf(myCutName,"%sCUT",name);
  printf("myCutName = %s\n",myCutName);
  TCutG *oldCut=(TCutG *)myCuts->Get(myCutName);
  if (oldCut != 0){
    printf("Cut is not, new cond ;-)\n");
    oldCut->Draw("same");
  }

  do {
    timer->TurnOn();
    timer->Reset();
    // Now let's read the input, we can use here any
    // stdio or iostream reading methods. like std::cin >> myinputl;

    input = Getline("Type <return> after cut was made (x for exiting): ");
    timer->TurnOff();

    // Now usefull stuff with the input!
    // ....
    // here were are always done as soon as we get some input!
    //    printf("Stupid stuff\n");

    // cout<< "sizeof(input)" <<  sizeof(input)<<endl;
    if (input[0] == 'x'){
      FILE *f4Stat = fopen("specialLogF.txt", "w");
      /* print some text */
      const char *text = "666 status";
      fprintf(f4Stat, "Some text: %s\n", text);
      return 666;
    }
    if (input) done = kTRUE;
  } while (!done);

  cout << "input was "<< input << endl;

  // TObject *cut = gROOT->GetListOfSpecials()->FindObject("CUTG");
  TCutG *cut, *nCut;
  if (oldCut != 0){
    //Change here
    cut=oldCut;
  }

  nCut = (TCutG*)gROOT->GetListOfSpecials()->FindObject("CUTG");
  if (nCut) {
    //nCut has higher precedence in case a new cut is defined.
    cut=nCut;
  }
  // cut = (TCutG*)gROOT->GetListOfSpecials()->FindObject("CUTG");
  
  // input = Getline("Type <return> just waiting: "); 

  //Rethink this part improve!!
  if (cut){
    // printf("Inside the important if\n");
    // cout<<cut<<endl;
    cut->Print();
    // printf("After the big Print\n");
    // cut->Area();
    cut->SetName(myCutName);
    if (oldCut == 0){
      printf("Cut is new\n");
      cut->Write();
    } else {
      printf("Cut is not new, rewriting it\n");

      //Unelegant way deleting the old cut
      //myCuts->Delete(myCutName) will not work!
      
      //We need to create a string with the horrible ";1"
      sprintf(innCutName,"%s;1",myCutName);
      //And do the deleting
      myCuts->Delete(innCutName);
      
      cut->Write();
    }

  }else{
    printf("The cut was not defined\n");
  }

  myCuts->Close();
  return 0;
}
                                                                                                                                                       
