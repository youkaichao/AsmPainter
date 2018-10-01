include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib

Render proto :DWORD
LButtonDown proto :DWORD,:DWORD,:DWORD
LButtonUp proto :DWORD,:DWORD,:DWORD
MouseMove proto :DWORD,:DWORD,:DWORD
HandleCommand proto :DWORD,:DWORD

RGB macro red,green,blue 
    xor eax,eax 
    mov ah,blue 
    shl eax,8 
    mov ah,green 
    mov al,red 
endm

.data

    WindowClass byte "WindowClass",0 
    ButtonClass byte "button",0
    WindowName  byte "AsmPainter",0
    PencilName byte "Pencil",0
    EraserName byte "Eraser",0
    NumberFormat byte "%d",13,10,0
    PencilID dword 1000
    EraserID dword 1001

    mouseClick dword 0
    instruction dword 1000

.data?
    mousePosition POINT <?,?>
    hInstance HINSTANCE ? 
    commandLine LPSTR ?