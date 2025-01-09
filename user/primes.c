#include "kernel/types.h"
#include "user/user.h"

void sieve(int p[2]) {
  int prime;
  if (read(p[0], &prime, sizeof(int)) != sizeof(int)) {
    close(p[0]);
    exit(0);
  }

  printf("prime %d\n", prime);

  int p_right[2];
  pipe(p_right);

  if (fork() == 0) {
    close(p_right[1]);
    close(p[0]);
    sieve(p_right);
  } else {
    int n;
    while (read(p[0], &n, sizeof(int))) {
      if (n % prime != 0) {
        if (write(p_right[1], &n, sizeof(int)) != sizeof(int)) {
          printf("write error\n");
          exit(1);
        }
      }
    }
    close(p[0]);
    close(p_right[1]);
    wait(0);
    exit(0);
  }
}

int main(int argc, char *argv[]) {

  int p[2];
  pipe(p);

  if (fork() == 0) {
    close(p[1]);
    sieve(p);
  } else {
    close(p[0]);
    for (int i = 2; i <= 35; i++) {
      if (write(p[1], &i, sizeof(int)) != sizeof(int)) {
        printf("write prime error\n");
        exit(1);
      }
    }
    close(p[1]);
    wait(0);
    exit(0);
  }
}