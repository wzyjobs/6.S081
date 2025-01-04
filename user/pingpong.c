#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  char buf[5];
  int p[2];
  pipe(p);
  int pid = fork();
  if (pid == 0) {
    if (read(p[0], buf, sizeof(buf)) != 4) {
      printf("pid:%d,read error\n", getpid());
    }
    printf("%d: received %s\n", getpid(), buf);
    if (write(p[1], "pong", 4) != 4)
      printf("pid:%d,write error\n", getpid());
    close(p[1]);
  } else {
    if (write(p[1], "ping", 4) != 4)
      printf("pid:%d,write error\n", getpid());
    wait(0);
    if (read(p[0], buf, sizeof(buf)) != 4) {
      printf("pid:%d,read error\n", getpid());
    }
    close(p[0]);
    printf("%d: received %s\n", getpid(), buf);
  }

  exit(0);
}