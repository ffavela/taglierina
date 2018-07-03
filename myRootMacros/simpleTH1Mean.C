#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//The next may seem redundant but it simplyfies modifications and a
//generalization in the future, leaving the name handling to the bash
//script

void simpleTH1Mean(const char *spectFN, const char *hName,
                   float minValCut, float maxValCut,
		   bool saveBool=false,
		   const char *saveFile="cutH.root",
		   const char *cutHistName="hCuttedHisto") {

  printf("Hello fantastic amazing world\n");

  TFile *fHistos = new TFile(spectFN,"update");

  TH1F *myH1Stuff=(TH1F *)fHistos->Get(hName);

  int nbinsx = myH1Stuff->GetXaxis()->GetNbins();
  int maxXVal=myH1Stuff->GetXaxis()->GetBinCenter(nbinsx);
  int minXVal=myH1Stuff->GetXaxis()->GetBinCenter(0);

  TH1F *cutSpect = new TH1F("myAwesomeName","ciao",nbinsx,minXVal,maxXVal);

  float xCenter;
  int xBinNum;

  int iCont=myH1Stuff->GetBinContent(xCenter);
  int iContCut=0;
  // fHistos->Close();
  for (xBinNum=0;xBinNum < nbinsx;xBinNum++){
    xCenter=myH1Stuff->GetXaxis()->GetBinCenter(xBinNum);
    iCont=myH1Stuff->GetBinContent(xBinNum);

    if( minValCut <= xCenter && xCenter < maxValCut && iCont > 0){
      cutSpect->Fill(xCenter,iCont);
      iContCut=cutSpect->GetBinContent(xBinNum);
      if (iContCut != iCont){
        printf("This should never happen!\n");
        printf("iContCut = %d != iCont = %d\n",iContCut, iCont);
      }
    }
  }
  // TCanvas *c2 = new TCanvas("c2","c2");
  // c2->ToggleEventStatus();
  // cutSpect->Draw();
  // cut->Draw("same");

  //Put the saveBool condition here!!
  if (saveBool==true){
    TFile *fOut = new TFile(saveFile,"update");

    TH2F *oldHisto=(TH2F *)fOut->Get(cutHistName);
    if (oldHisto == 0){
      printf("The spectra did not previosuly exist, creating it.\n");
    } else {
      printf("Rewriting histo\n");
      //Horrible way of deleting the old histo
      const char inCutHName[50];
      sprintf(inCutHName,"%s;1",cutHistName);
      fOut->Delete(inCutHName);
    }
    cutSpect->SetName(cutHistName);
    cutSpect->Write();

    return;
  }

  //The means on x and y
  float meanX;
  meanX=cutSpect->GetMean(1);
  printf("%0.3f\n",meanX);
  // cut->Print();
}
