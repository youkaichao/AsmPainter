include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
include comdlg32.inc
includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib
includelib comdlg32.lib

CreateWindowClass proto :HINSTANCE,:WNDPROC,:LPCSTR,:HBRUSH,:DWORD
CanvasProc proto :HWND,:UINT,:WPARAM,:LPARAM
WindowProc proto :HWND,:UINT,:WPARAM,:LPARAM

CVSRender proto :HWND
CVSLButtonDown proto :HWND,:WPARAM,:LPARAM
CVSLButtonUp proto :HWND,:WPARAM,:LPARAM
CVSMouseMove proto :HWND,:WPARAM,:LPARAM
CVSSetTrack proto :HWND
CVSMouseLeave proto :HWND,:WPARAM,:LPARAM
CVSVerticalScroll proto :HWND,:WPARAM,:LPARAM
CVSHorizontalScroll proto :HWND,:WPARAM,:LPARAM
CVSInit proto :HWND

WNDHandleCommand proto :HWND,:WPARAM,:LPARAM
WNDFileOpenMenu proto :HWND
WNDFileSaveMenu proto :HWND
WNDLButtonUp proto :HWND,:WPARAM,:LPARAM

RGB macro red,green,blue 
    xor eax,eax 
    mov ah,blue 
    shl eax,8 
    mov ah,green 
    mov al,red
endm

MAKEINTRESOURCE macro id
    mov eax,id
    and eax,0ffffh
endm

.data

    WindowClass            byte          "WindowClass",0
    CanvasClass            byte          "CanvasClass",0
    ButtonClass            byte          "Button",0
    WindowName             byte          "AsmPainter",0
    PencilName             byte          "Pencil",0
    EraserName             byte          "Eraser",0
    AppIcon                byte          "app.ico",0
    NumberFormat           byte          "%d",13,10,0
    FilterString           byte          "BitMap(*.bmp)",0,"*.bmp",0
    
    WNDWIDTH               dword         1500
    WNDHEIGHT              dword         850
    CANVASWIDTH            dword         1200
    CANVASHEIGHT           dword         750

    SCROLLWIDTH            dword         3000
    SCROLLHEIGHT           dword         2000

    PencilID               dword         1000
    EraserID               dword         1001
    IDI_PAINTER            dword         104
    IDI_ERASER             dword         105
    IDI_PENCIL             dword         106
    ID_FILE_MENU           dword         40003
    ID_FILE_OPEN_MENU      dword         40004
    ID_FILE_SAVE_MENU      dword         40005
    ID_MENU_TOOLBAR_PENCIL dword         40008
    ID_MENU_TOOLBAR_ERASER dword         40009

    buffer                 HDC           NULL

.data?
    mousePosition POINT <?,?>
    hInstance HINSTANCE ?
    commandLine LPSTR ?
    fileNameBuffer BYTE 1000 DUP(?)
    ofn OPENFILENAME <>