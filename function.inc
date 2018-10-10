include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
include comdlg32.inc
include comctl32.inc

includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib
includelib comdlg32.lib
includelib comctl32.lib

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

PBITMAPINFO       TYPEDEF PTR BITMAPINFO
PBITMAPINFOHEADER TYPEDEF PTR BITMAPINFOHEADER

CreateWindowClass           proto :HINSTANCE,:WNDPROC,:LPCSTR,:HBRUSH,:DWORD
CreateToolbar               proto :HWND
CanvasProc                  proto :HWND,:UINT,:WPARAM,:LPARAM
WindowProc                  proto :HWND,:UINT,:WPARAM,:LPARAM

CVSInit                     proto :HWND
CVSRender                   proto :HWND
CVSSetTrack                 proto :HWND
CVSLButtonDown              proto :HWND,:WPARAM,:LPARAM
CVSLButtonUp                proto :HWND,:WPARAM,:LPARAM
CVSMouseMove                proto :HWND,:WPARAM,:LPARAM
CVSMouseLeave               proto :HWND,:WPARAM,:LPARAM
CVSVerticalScroll           proto :HWND,:WPARAM,:LPARAM
CVSHorizontalScroll         proto :HWND,:WPARAM,:LPARAM
CVSSetCursor                proto :HWND,:WPARAM,:LPARAM

WNDFileOpenMenu             proto :HWND
WNDFileSaveMenu             proto :HWND
WNDHandleCommand            proto :HWND,:WPARAM,:LPARAM
WNDLButtonUp                proto :HWND,:WPARAM,:LPARAM

.data
    WindowClass            byte          "WindowClass",0
    CanvasClass            byte          "CanvasClass",0
    ButtonClass            byte          "Button",0
    WindowName             byte          "AsmPainter",0
    CanvasName             byte          "Canvas",0
    AppIcon                byte          "app.ico",0
    NumberFormat           byte          "%d",13,10,0
    FilterString           byte          "BitMap(*.bmp)",0,"*.bmp",0
    
    PencilString           byte          "P",0,"e",0,"n",0,"c",0,"i",0,"l",0,0,0
    EraserString           byte          "E",0,"r",0,"a",0,"s",0,"e",0,"r",0,0,0
    SaveString             byte          "S",0,"a",0,"v",0,"e",0,0,0
    OpenString             byte          "O",0,"p",0,"e",0,"n",0,0,0
    
    WNDWIDTH               equ         1500
    WNDHEIGHT              equ         850
    CANVASWIDTH            equ         1200
    CANVASHEIGHT           equ         750
    SCROLLWIDTH            equ         3000
    SCROLLHEIGHT           equ         2000

    INSTRUCTION_PENCIL     equ         0
    INSTRUCTION_ERASER     equ         1

    IDI_PAINTER            equ         104
    IDI_ERASER             equ         105
    IDI_PENCIL             equ         106
    IDC_ERASER             equ         107
    IDC_PENCIL             equ         108
    IDR_TOOLBAR            equ         118
    ID_FILE_MENU           equ         40003
    ID_FILE_OPEN_MENU      equ         40004
    ID_FILE_SAVE_MENU      equ         40005
    ID_MENU_TOOLBAR_PENCIL equ         40008
    ID_MENU_TOOLBAR_ERASER equ         40009
    ID_OPEN_TOOLBAR        equ         40022
    ID_SAVE_TOOLBAR        equ         40023
    ID_PENCIL_TOOLBAR      equ         40024
    ID_ERASER_TOOLBAR      equ         40025

    TOOLBAR_BUTTON_NUM     equ         5
