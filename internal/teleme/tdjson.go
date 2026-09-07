package teleme

/*
// Debian 13's libtd-dev has versioned paths and a broken tdjson pkg-config file.
#cgo linux CFLAGS: -I/usr/include/TDLib1.8.38
#cgo linux LDFLAGS: -l:libtdjson.so.1.8.38
#cgo !linux pkg-config: tdjson
#include <stdlib.h>
#include <termios.h>
#include <td/telegram/td_json_client.h>
*/
import "C"

import (
	"encoding/json"
	"fmt"
	"os"
	"unsafe"
)

func createClientID() int { return int(C.td_create_client_id()) }

func sendJSON(id int, value any) error {
	b, err := json.Marshal(value)
	if err != nil {
		return err
	}
	s := C.CString(string(b))
	defer C.free(unsafe.Pointer(s))
	C.td_send(C.int(id), s)
	return nil
}

// Called only by client.receive. No td_execute calls race with this copy.
func receiveJSON() json.RawMessage {
	p := C.td_receive(0.5)
	if p == nil {
		return nil
	}
	return json.RawMessage(C.GoString(p))
}

// Use the existing C bridge and POSIX terminal API; no extra dependency.
func hideInput() (func(), error) {
	fd := C.int(os.Stdin.Fd())
	var saved C.struct_termios
	if result, err := C.tcgetattr(fd, &saved); result != 0 {
		return nil, fmt.Errorf("password input requires a terminal: %w", err)
	}
	quiet := saved
	quiet.c_lflag &^= C.ECHO | C.ECHONL
	if result, err := C.tcsetattr(fd, C.TCSANOW, &quiet); result != 0 {
		return nil, fmt.Errorf("disable terminal echo: %w", err)
	}
	return func() {
		if result, err := C.tcsetattr(fd, C.TCSANOW, &saved); result != 0 {
			fmt.Fprintln(os.Stderr, "restore terminal echo:", err)
		}
		fmt.Fprintln(os.Stderr)
	}, nil
}
