#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(2, "Usage: sleep should have one value\n");
    exit(1);
  }

  if (sleep(atoi(argv[1])) < 0) {
    fprintf(2, "sleep: %s failed to exec sleep\n", argv[0]);
  }

  exit(0);
}