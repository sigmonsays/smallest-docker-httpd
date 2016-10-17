section .text
global _start

_start:
  xor eax, eax              ; init eax 0
  xor ebx, ebx              ; init ebx 0
  xor esi, esi              ; init esi 0
  jmp _socket               ; jmp to _socket

_socket_call:
  mov al, 0x66              ; invoke SYS_SOCKET (kernel opcode 102)
  inc byte bl               ; increment bl (1=socket, 2=bind, 3=listen, 4=accept)
  mov ecx, esp              ; move address arguments struct into ecx
  int 0x80                  ; call SYS_SOCKET
  jmp esi                   ; esi is loaded with a return address each call to _socket_call

_socket:
  push byte 6               ; push 6 onto the stack (IPPROTO_TCP)
  push byte 1               ; push 1 onto the stack (SOCK_STREAM)
  push byte 2               ; push 2 onto the stack (PF_INET)
  mov esi, _bind            ; move address of _bind into ESI
  jmp _socket_call          ; jmp to _socket_call

_bind:
  mov edi, eax              ; move return value of SYS_SOCKET into edi (file descriptor for new socket, or -1 on error)
  xor edx, edx              ; init edx 0
  push dword edx            ; end struct on stack (arguments get pushed in reverse order)
  push word 0x6022          ; move 24610 dec onto stack
  push word bx              ; move 1 dec onto stack AF_FILE
  mov ecx, esp              ; move address of stack pointer into ecx
  push byte 0x10            ; move 16 dec onto stack
  push ecx                  ; push the address of arguments onto stack
  push edi                  ; push the file descriptor onto stack

  mov esi, _listen          ; move address of _listen onto stack
  jmp _socket_call          ; jmp to _socket_call

_listen:
  inc bl                    ; bl = 3
  push byte 0x01            ; move 1 onto stack (max queue length argument)
  push edi                  ; push the file descriptor onto stack
  mov esi, _accept          ; move address of _accept onto stack
  jmp _socket_call          ; jmp to socket call

_accept:
  push edx                  ; push 0 dec onto stack (address length argument)
  push edx                  ; push 0 dec onto stack (address argument)
  push edi                  ; push the file descriptor onto stack
  mov esi, _fork            ; move address of _fork onto stack
  jmp _socket_call          ; jmp to _socket_call

_fork:
  mov esi, eax              ; move return value of SYS_SOCKET into esi (file descriptor for accepted socket, or -1 on error)
  mov al, 0x02              ; invoke SYS_FORK (kernel opcode 2)
  int 0x80                  ; call SYS_FORK
  test eax, eax             ; if return value of SYS_FORK in eax is zero we are in the child process
  jz _write                 ; jmp in child process to _write

  xor eax, eax              ; init eax 0
  xor ebx, ebx              ; init ebx 0
  mov bl, 0x02              ; move 2 dec in ebx lower bits
  jmp _listen               ; jmp in parent process to _listen

_write:
  mov ebx, esi              ; move file descriptor into ebx (accepted socket id)
  push edx                  ; push 0 dec onto stack then push a bunch of ascii (http headers & reponse body)
  push dword 0x0a0d3e31     ; [\n][\r]>1
  push dword 0x682f3c21     ; h/<!
  push dword 0x6f6c6c65     ; ello
  push dword 0x683e3148     ; H<1h
  push dword 0x3c0a0d0a     ; >[\n][\r][\n]
  push dword 0x0d6c6d74     ; [\r]lmt
  push dword 0x682f7478     ; h/tx
  push dword 0x6574203a     ; et :
  push dword 0x65707954     ; epyT
  push dword 0x2d746e65     ; -tne
  push dword 0x746e6f43     ; tnoC
  push dword 0x0a4b4f20     ; \nKO
  push dword 0x30303220     ; 002
  push dword 0x302e312f     ; 0.1/
  push dword 0x50545448     ; PTTH
  mov al, 0x04              ; invoke SYS_WRITE (kernel opcode 4)
  mov ecx, esp              ; move address of stack arguments into ecx
  mov dl, 64                ; move 64 dec into edx lower bits (length in bytes to write)
  int 0x80                  ; call SYS_WRITE

_close:
  mov al, 6                 ; invoke SYS_CLOSE (kernel opcode 6)
  mov ebx, esi              ; move esi into ebx (accepted socket file descriptor)
  int 0x80                  ; call SYS_CLOSE
  mov al, 6                 ; invoke SYS_CLOSE (kernel opcode 6)
  mov ebx, edi              ; move edi into ebx (new socket file descriptor)
  int 0x80                  ; call SYS_CLOSE

_exit:
  mov eax, 0x01             ; invoke SYS_EXIT (kernel opcode 1)
  xor ebx, ebx              ; 0 errors
  int 0x80                  ; call SYS_EXIT
