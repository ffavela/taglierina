#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"
#include <iostream>

int myH2Cutter(const char *name,
               const char *fileName="MySpectra212.root",
               const char *myCutFileName="myCutFile.root",
               const char *colorB="False",
               const char *curve2Fit="nogauss",
               const char *logyB="False"){
  const char *input;

  const char myCutName[50],innCutName[50];

  Bool_t done = kFALSE;
  char tString[50],temp[50],bName[50];

  TFile *f = new TFile(fileName,"read");

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

  if (logyB == "True")
    c1->SetLogy();

  if (colorB == "False")
    myH2Stuff->Draw();
  else:
    myH2Stuff->Draw("col");

  TFile *myCuts = new TFile(myCutFileName,"update");
  sprintf(myCutName,"%sCUT",name);
  printf("myCutName = %s\n",myCutName);
  TCutG *oldCut=(TCutG *)myCuts->Get(myCutName);
  if (oldCut != 0){
    printf("Cut is not new cond ;-)\n");
    oldCut->Draw("same");
    Double_t minXVal=oldCut->GetXaxis()->GetXmin();
    Double_t maxXVal=oldCut->GetXaxis()->GetXmax();
    //Note: root annoyingly gives always a slightly lower and upper
    //value for the respective min and max values!

    // printf("minXVal, maxXVal = %0.3f, %0.3f\n",minXVal,maxXVal);
    // oldCut->Print();
    // printf("The value of the new variable is %s\n",curve2Fit);
    if (curve2Fit == "gauss"){
      // printf("Made it inside the newest condition\n");
      // myH2Stuff->Fit("gaus","Q0");
      myH2Stuff->Fit("gaus","","",minXVal,maxXVal);
      TF1 *fit = myH2Stuff->GetFunction("gaus");
      Double_t p0 = fit->GetParameter(0);//Constant
      Double_t p1 = fit->GetParameter(1);//Mean
      Double_t p2 = fit->GetParameter(2);//Sigma

      printf("Gauss Mean\tSigma\tConstant\n");
      printf("%0.3f\t%0.3f\t%0.3f\n",p1,p2,p0);//Nicer print
      fit->Draw("same");
    }

  }

  do {
    timer->TurnOn();
    timer->Reset();
    // Now let's read the input, we can use here any
    // stdio or iostream reading methods. like std::cin >> myinputl;

    printf("Input d for deleting the cut\n");
    printf("Input b (or p) for going backward (in case of looping)\n");
    printf("Input c for toggling the color (for 2D histo)\n");
    input = Getline("Type <return> after cut was made (x (or q) for exiting): ");
    timer->TurnOff();

    // Now usefull stuff with the input!
    // ....
    // here were are always done as soon as we get some input!
    //    printf("Stupid stuff\n");

    // cout<< "sizeof(input)" <<  sizeof(input)<<endl;
    if (input[0] == 'x' || input[0] == 'q'){
      write2File("exit");
      return 666;
    } else if (input[0] == 'd'){
      printf("Deleting the cut & redrawing\n");
      write2File("delete cut");
      return 667;
    } else if (input[0] == 'b' || input[0] == 'p'){
      printf("Going backward\n");
      write2File("back");
      return 668;
    } else if (input[0] == 'c'){
      //Still unimplemented
      printf("Toggling color\n");
      write2File("color");
      return 668;
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

void write2File(const char *text,
		const char *logFileN="specialLogF.txt"){
  FILE *f4Stat = fopen(logFileN, "w");
  /* print some text */
  fprintf(f4Stat, "%s\n", text);
  return;
}
