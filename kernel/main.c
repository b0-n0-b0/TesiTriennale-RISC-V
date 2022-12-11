#include "types.h"
#include "uart.h"

__attribute__ ((aligned (16))) char stack0[4096];
int main();

int main(){

  char* message = "Running in S-Mode\n\r";
  printf(message);
  pci_init();
  message = "PCI initialized\n\r";
  printf(message);
  message = "VGA inizialized\n\r";
  printf(message);
  return 0;
}
