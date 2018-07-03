#include "TObject.h"

void probeObj(const char *fileName, const char *objName){
  TFile *f = new TFile(fileName,"update");

  TObject *obj;
  TKey *key;
  TIter next(f->GetListOfKeys());

  while ((key = (TKey *) next())) {
    obj = f->Get(key->GetName()); // copy object to memory
    // do something with obj
    if ( ! strcmp(objName,key->GetName())){
      // printf("found object: %s\n",key->GetName());
      printf("%s\n", key->GetClassName());
      f->Close();
      return;
    }
  }
  printf("%s\n","None");

  f->Close();
  return;
}
