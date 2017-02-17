#include <sys/select.h>

// read
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#include "common.h"
#include "debug.h"

const char * c_str(Message msg) {
    switch (msg) {
        case START_COLLECT: return "START_COLLECT";
        case STOP_COLLECT:  return "STOP_COLLECT";
        case CLOSE_SOCKET:    return "CLOSE_SOCKET";
        default:
                            LOG("Bad message recieved: %d.", msg);
                            exit(1);
    }
}

void read_message(int fd, Message *msg) {
    check_or_exit(read(fd, (char *)msg, sizeof(*msg)) < 0, "read");
    LOG("read %s", c_str(*msg));
}

// TODO: (joshpfosi) I am not convinced that this properly exits if the other
// end closes the TCP connection. To demonstrate it simply run `collect 5555 x
// y` and `client localhost 5555`.
void write_message(int fd, Message msg) {
    check_or_exit(write(fd, (char *)&msg, sizeof(msg)) < 0, "write");
    LOG("wrote %s", c_str(msg));
}

// Blocks until `msg` is received on `fd`
void wait_for(int fd, Message msg) {
    Message read_msg;
    LOG("waiting for %s", c_str(msg));
    do { read_message(fd, &read_msg); } while (msg != read_msg);
}

// Returns true if `msg` is received on `fd`, false otherwise
bool check_for(int fd, Message msg) {
    fd_set select_set;
    timeval tv = { 0, 0 }; // timeout instantly
    Message read_msg;

    FD_ZERO(&select_set);
    FD_SET(fd, &select_set);

    // TODO: (joshpfosi) `select` may be too slow for our application
    // TODO: (joshpfosi) We should check `select`s return value
    select(fd + 1, &select_set, nullptr, nullptr, &tv);

    if (FD_ISSET(fd, &select_set)) {
        read_message(fd, &read_msg);
        return msg == read_msg;
    }

    return false;
}
