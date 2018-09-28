include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc 
includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib

Render proto :DWORD
LButtonDown proto :DWORD,:DWORD,:DWORD
LButtonUp proto :DWORD,:DWORD,:DWORD
MouseMove proto :DWORD,:DWORD,:DWORD

RGB macro red,green,blue 
    xor eax,eax 
    mov ah,blue 
    shl eax,8 
    mov ah,green 
    mov al,red 
endm

.data 
    ClassName db "WindowClass",0 
    AppName  db "AsmPainter",0
    MouseClick db 0

.data?
    hInstance HINSTANCE ? 
    CommandLine LPSTR ?