#include "TH1.h"
#include "TCutG.h"
#include "TTimer.h"
#include "TSystem.h"
#include "TObject.h"
#include "string.h"

using namespace std;

vector<string> mySplit(string str, string token){
    vector<string>result;
    while(str.size()){
        int index = str.find(token);
        if(index!=string::npos){
	  result.push_back(str.substr(0,index));
	  str = str.substr(index+token.size());
	  if(str.size()==0)
	    result.push_back(str);
        }else{
            result.push_back(str);
            str = "";
        }
    }
    return result;
}

void myPrint( vector <string> & v )
{
  for (size_t n = 0; n < v.size(); n++)
    cout << "\"" << v[ n ] << "\"\n";
  cout << endl;
}

void multiDraw(const char *hName, std::string spectFNames) {
  printf("Hello fantastic amazing world\n");
  printf("hName = %s\n",hName);
  cout<<spectFNames<<endl;

  std::vector<std::string> myResults=mySplit(spectFNames,",");
  // cout<<myResults[2]<<endl;

  cout<<"Doing myPrint"<<endl;
  myPrint(myResults);

  TCanvas *c1 = new TCanvas("c1", "My C1 canvas", 900, 750);
  c1->ToggleToolBar();
  c1->ToggleEventStatus();

  int myCounter=1;
  for (size_t n = 0; n < myResults.size(); n++){
    TFile *f = new TFile(myResults[n].c_str(),"read");
    TH1F *myHStuff=(TH1F *)f->Get(hName);
    if (myHStuff == 0){
      printf("Error: histogram does not exist\n");
      return;
    }

    // TColor *myColor = gROOT->GetColor(10);
    cout<<kGreen<<endl;
    myHStuff->SetLineColor(myCounter);
    if (myCounter==1){
      cout<<"Hello amazing fantastic marvelous WORLD!"<<endl;
    }

    myCounter+=1;
    myCounter%=50;
    myHStuff->Draw("same");
    cout << "\"" << myResults[ n ] << "\"\n";

  }

  const char *input;
  TTimer *timer = new TTimer("gSystem->ProcessEvents();", 50, kFALSE);
  Bool_t done = kFALSE;
  do {
    timer->TurnOn();
    timer->Reset();
    // Now let's read the input, we can use here any
    // stdio or iostream reading methods. like std::cin >> myinputl;

    printf("Input d for deleting the cut\n");
    printf("Input b (or p) for going backward (in case of looping)\n");
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
    }

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
    }

    if (input) done = kTRUE;
  } while (!done);


  return;

}

void write2File(const char *text,
		const char *logFileN="specialLogF.txt"){
  FILE *f4Stat = fopen(logFileN, "w");
  /* print some text */
  fprintf(f4Stat, "%s\n", text);
  return;
}
