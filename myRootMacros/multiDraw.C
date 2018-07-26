#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"
#include "string.h"

// char *myStrSplit(const char *myStr, const char *myDelim, int instNum=0)
// {

//     char* token_pointer;
//     token_pointer = strtok(myStr, myDelim);
//    // return token_pointer;
//     while(NULL != token_pointer)
//     {
//         printf("%s \n", token_pointer);
//         token_pointer = strtok(NULL, myDelim);    
//     }

//     return 0;
// }

char *myStrSplit(const char *myStr, const char *myDelim, int instNum=0)
{
    char* token_pointer=NULL;
    token_pointer = strtok(myStr, myDelim);
    // while(instNum >= 0 )
    while(NULL != token_pointer)
    {
      printf("myStrSplit instNum = %d\n",instNum);
      printf("%s \n", token_pointer);
      instNum -= 1;
      token_pointer = strtok(NULL, myDelim);    
    }
    return token_pointer;
}

int countInstances(const char *myStr,const char *myDelim) {
  int count=0;
  char* token_pointer=NULL;
  token_pointer = strtok(myStr, myDelim);
  while(NULL != token_pointer)
    {
      count+=1;
      //handle your token
      token_pointer = strtok(NULL, myDelim);    
    }
  return count;
}

void multiDraw(const char *hName, const char *spectFNames) {
  printf("Hello fantastic amazing world\n");
  printf("hName = %s\n",hName);
  printf("specFN = %s\n",spectFNames);
  // std::vector<std::string> myTokens=split(spectFN,",");

  char *myAwesomeChar;
  char *betterVar=*spectFNames;
  printf("B4 myCount specFN = %s\n",spectFNames);
  int myCount=countInstances(spectFNames,",");
  printf("After myCount specFN = %s\n",spectFNames);
  
  myAwesomeChar=myStrSplit(spectFNames,",");
  // printf("number of instances are %d\n", myCount);

  printf("A simple test print %s\n", myAwesomeChar);
  // myAwesomeChar=myStrSplit(spectFNames,",",2);
  // printf("something random");
  // printf("A simple test print again print something!! %s\n", myAwesomeChar);
  //  printf("something random again\n");
  // printf("A simple test print again %s\n", myAwesomeChar[1]);
  // simpleHello();
}
  // TFile *fHistos = new TFile(spectFN,"update");

  // TH1F *myH1Stuff=(TH1F *)fHistos->Get(hName);

  // int nbinsx = myH1Stuff->GetXaxis()->GetNbins();
  // int maxXVal=myH1Stuff->GetXaxis()->GetBinCenter(nbinsx);
  // int minXVal=myH1Stuff->GetXaxis()->GetBinCenter(0);

  // //Cloning the histo
  // TH1F *cutSpect = (TH1F *) myH1Stuff->Clone();
  // //Zeroing it
  // cutSpect->Add(cutSpect,-1);

  // float xCenter;
  // int xBinNum;

  // int iCont=myH1Stuff->GetBinContent(xCenter);
  // int iContCut=0;
  // // fHistos->Close();
  // for (xBinNum=0;xBinNum < nbinsx;xBinNum++){
  //   xCenter=myH1Stuff->GetXaxis()->GetBinCenter(xBinNum);
  //   iCont=myH1Stuff->GetBinContent(xBinNum);

  //   if( minValCut <= xCenter && xCenter < maxValCut && iCont > 0){
  //     cutSpect->Fill(xCenter,iCont);
  //     iContCut=cutSpect->GetBinContent(xBinNum);
  //     if (iContCut != iCont){
  //       printf("This should never happen!\n");
  //       printf("iContCut = %d != iCont = %d\n",iContCut, iCont);
  //     }
  //   }
  // }
  // // TCanvas *c2 = new TCanvas("c2","c2");
  // // c2->ToggleEventStatus();
  // // cutSpect->Draw();
  // // cut->Draw("same");

  // //Put the saveBool condition here!!
  // if (saveBool==true){
  //   TFile *fOut = new TFile(saveFile,"update");

  //   TH2F *oldHisto=(TH2F *)fOut->Get(cutHistName);
  //   if (oldHisto == 0){
  //     printf("The spectra did not previosuly exist, creating it.\n");
  //   } else {
  //     printf("Rewriting histo\n");
  //     //Horrible way of deleting the old histo
  //     const char inCutHName[50];
  //     sprintf(inCutHName,"%s;1",cutHistName);
  //     fOut->Delete(inCutHName);
  //   }
  //   cutSpect->SetName(cutHistName);
  //   cutSpect->Write();

  //   return;
  // }

  // //The means on x and y
  // float meanX,stdDevX;
  // meanX=cutSpect->GetMean(1); //The old way
  // stdDevX=cutSpect->GetStdDev(1);

  // if (hMeanB){
  //   printf("%0.3f\t%0.3f\t%0.3f\n",meanX,stdDevX,0.0);
  //   return;
  // }

  // //Fitting a gaussian
  // //Q means quiet, 0 means don't do a plot
  // cutSpect->Fit("gaus","Q0");
  // TF1 *fit = cutSpect->GetFunction("gaus");
  // Double_t p0 = fit->GetParameter(0);//Constant
  // Double_t p1 = fit->GetParameter(1);//Mean
  // Double_t p2 = fit->GetParameter(2);//Sigma

  // // printf("%0.3f\n",meanX);
  // printf("%0.3f\t%0.3f\t%0.3f\n",p1,p2,p0);
// }
