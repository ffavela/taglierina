#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"

//The next may seem redundant but it simplyfies modifications and a
//generalization in the future, leaving the name handling to the bash
//script

void simpleTH1Mean(const char *spectFN, const char *hName,
                   float minValCut, float maxValCut) {

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

  //The means on x and y
  float meanX;
  meanX=cutSpect->GetMean(1);
  printf("%0.3f\n",meanX);
  // cut->Print();
}
