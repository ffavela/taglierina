#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//As an example
//cutFN = "myCutFile.root", spectFN = "MySpectra212.root"

//The next may seem redundant but it simplyfies modifications and a
//generalization in the future, leaving the name handling to the bash
//script

//cutName = "h50768CUT", hName = "h50768"

void fillCutSpectra(const char *cutFN, const char *spectFN,
                    const char *cutName, const char *hName,
                    bool myBoolX=false,
                    float minXR=0, float maxXR=1024,
                    bool myBoolY=false,
                    float minYR=0, float maxYR=1024,
		    bool saveBool=false,
		    const char *saveFile="cutH.root",
		    const char *cutHistName="hCuttedHisto") {

  TFile *myCuts = new TFile(cutFN,"update");
  TCutG *cut=(TCutG *)myCuts->Get(cutName);
  TFile *fHistos = new TFile(spectFN,"update");

  // fHistos->ls();
  // TCanvas *c1 = new TCanvas("c1","c1");
  // c1->ToggleEventStatus();
  // fHistos->ls();
  TH2F *myH2Stuff=(TH2F *)fHistos->Get(hName);
  // myH2Stuff->Draw();
  // cut->Draw("same");

  int nbinsx = myH2Stuff->GetXaxis()->GetNbins();
  int nbinsy = myH2Stuff->GetYaxis()->GetNbins();

  float maxXVal=myH2Stuff->GetXaxis()->GetBinCenter(nbinsx);
  float maxYVal=myH2Stuff->GetYaxis()->GetBinCenter(nbinsy);

  float minXVal=myH2Stuff->GetXaxis()->GetBinCenter(0);
  float minYVal=myH2Stuff->GetYaxis()->GetBinCenter(0);

  if (myBoolX){
    minXVal=minXR;
    maxXVal=maxXR;
  }

  if (myBoolY){
    minYVal=minYR;
    maxYVal=maxYR;
  }

  minXR=0;
  TH2F *cutSpect = new TH2F("myAwesomeName","ciao",nbinsx,minXVal,maxXVal,nbinsy,minYVal,maxYVal);

  float xCenter, yCenter;
  int xBinNum,yBinNum;

  int iCont=myH2Stuff->GetBinContent(xCenter,yCenter);
  int iContCut=0;
  // fHistos->Close();
  for (xBinNum=0;xBinNum < nbinsx;xBinNum++){
    for (yBinNum=0;yBinNum < nbinsy;yBinNum++){
      xCenter=myH2Stuff->GetXaxis()->GetBinCenter(xBinNum);
      yCenter=myH2Stuff->GetYaxis()->GetBinCenter(yBinNum);
      iCont=myH2Stuff->GetBinContent(xBinNum,yBinNum);

      if(cut->IsInside(xCenter,yCenter) && iCont > 0){
        cutSpect->Fill(xCenter,yCenter,iCont);
        iContCut=cutSpect->GetBinContent(xBinNum,yBinNum);
        if (iContCut != iCont){
	  //Oddly it happens but I ignore it anyway ;-P
          printf("This should never happen!\n");
          printf("iContCut = %d != iCont = %d\n",iContCut, iCont);
        }
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
  float meanX,meanY;
  meanX=cutSpect->GetMean(1);
  meanY=cutSpect->GetMean(2);
  if (meanX == 0 && meanY == 0)
    printf("None\tNone\n");
  else
    printf("%0.3f\t%0.3f\n",meanX,meanY);
  // cut->Print();
}
