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

void simpleTH1Mean(const char *spectFN, const char *hName
                   float minValCut, float maxValCut) {


  TFile *fHistos = new TFile(spectFN,"update");

  TH1F *myH1Stuff=(TH1F *)fHistos->Get(hName);

  int nbinsx = myH1Stuff->GetXaxis()->GetNbins();
  int maxXVal=myH1Stuff->GetXaxis()->GetBinCenter(nbinsx);
  int minXVal=myH1Stuff->GetXaxis()->GetBinCenter(0);

  TH1F *cutSpect = new TH1F("myAwesomeName","ciao",nbinsx,minXVal,maxXVal);

  minXR=0;

  float xCenter;
  int xBinNum;

  int iCont=myH1Stuff->GetBinContent(xCenter);
  int iContCut=0;
  // fHistos->Close();
  for (xBinNum=0;xBinNum < nbinsx;xBinNum++){
    xCenter=myH1Stuff->GetXaxis()->GetBinCenter(xBinNum);
    iCont=myH1Stuff->GetBinContent(xBinNum);

    if(cut->IsInside(xCenter,yCenter) && iCont > 0){
      cutSpect->Fill(xCenter,iCont);
      iContCut=cutSpect->GetBinContent(xBinNum,yBinNum);
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
