include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib

CreateWindowClass proto :HINSTANCE,:WNDPROC,:LPCSTR,:HBRUSH
CanvasProc proto :HWND,:UINT,:WPARAM,:LPARAM
WindowProc proto :HWND,:UINT,:WPARAM,:LPARAM

Render proto :HWND
LButtonDown proto :HWND,:WPARAM,:LPARAM
LButtonUp proto :HWND,:WPARAM,:LPARAM
MouseMove proto :HWND,:WPARAM,:LPARAM
SetTrack proto :HWND
HandleCommand proto :HWND,:WPARAM,:LPARAM
MouseLeave proto :HWND,:WPARAM,:LPARAM

RGB macro red,green,blue 
    xor eax,eax 
    mov ah,blue 
    shl eax,8 
    mov ah,green 
    mov al,red 
endm

.data

    WindowClass byte "WindowClass",0
    CanvasClass byte "CanvasClass",0
    ButtonClass byte "Button",0
    WindowName  byte "AsmPainter",0
    PencilName byte "Pencil",0
    EraserName byte "Eraser",0
    NumberFormat byte "%d",13,10,0
    PencilID dword 1000
    EraserID dword 1001

    mouseClick dword 0
    mouseBlur dword 0
    instruction dword 1000

.data?
    mousePosition POINT <?,?>
    hInstance HINSTANCE ? 
    commandLine LPSTR ?
    buffer HDC ?