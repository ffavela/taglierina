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
		    const char *cutName, const char *hName) {
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

  int maxXVal=myH2Stuff->GetXaxis()->GetBinCenter(nbinsx);
  int maxYVal=myH2Stuff->GetYaxis()->GetBinCenter(nbinsy);
  TH2F *cutSpect = new TH2F("myAwesomeName","ciao",nbinsx,0,maxXVal,nbinsy,0,maxYVal);

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

  //The means on x and y
  float meanX,meanY;
  meanX=cutSpect->GetMean(1);
  meanY=cutSpect->GetMean(2);
  printf("%f\t%f\n",meanX,meanY);
  // cut->Print();
}
