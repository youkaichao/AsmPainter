include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
include comdlg32.inc
include comctl32.inc
include msvcrt.inc

includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib
includelib comdlg32.lib
includelib comctl32.lib
includelib msvcrt.lib

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

CreateWindowClass           proto :HINSTANCE,:WNDPROC,:LPCSTR,:HBRUSH,:dword
CreateToolbar               proto :HWND
CreateStatusbar             proto :HWND
CanvasProc                  proto :HWND,:UINT,:WPARAM,:LPARAM
WindowProc                  proto :HWND,:UINT,:WPARAM,:LPARAM
DialogProc                  proto :HWND,:UINT,:WPARAM,:LPARAM

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

WNDFileOpen                 proto :HWND
WNDFileSave                 proto :HWND
WNDSelectColor              proto :HWND,:dword
WNDHandleCommand            proto :HWND,:WPARAM,:LPARAM
WNDLButtonUp                proto :HWND,:WPARAM,:LPARAM
WNDDrawTextOnStatusBar      proto :dword, :dword

DLGHandleCommand            proto :HWND,:WPARAM,:LPARAM

.data
    WindowClass                byte          "WindowClass",0
    CanvasClass                byte          "CanvasClass",0
    ButtonClass                byte          "Button",0
    WindowName                 byte          "AsmPainter",0
    CanvasName                 byte          "Canvas",0
    AppIcon                    byte          "app.ico",0
    NumberFormat               byte          "%d",13,10,0
    PositionFormat             byte          "Mouse Position: %d(w) x %d(h)",0
    FilterString               byte          "BitMap(*.bmp)",0,"*.bmp",0

    PencilStatus               byte          "Pencil",0
    EraserStatus               byte          "Eraser",0
    TextStatus                 byte          "Text",0

    PencilString               byte          "P",0,"e",0,"n",0,"c",0,"i",0,"l",0,0,0
    EraserString               byte          "E",0,"r",0,"a",0,"s",0,"e",0,"r",0,0,0
    SaveString                 byte          "S",0,"a",0,"v",0,"e",0,0,0
    OpenString                 byte          "O",0,"p",0,"e",0,"n",0,0,0
    ForegroundString           byte          "F",0,"o",0,"r",0,"e",0,"g",0,"r",0,"o",0,"u",0,"n",0,"d",0," ",0,"C",0,"o",0,"l",0,"o",0,"r",0,0,0
    BackgroundString           byte          "B",0,"a",0,"c",0,"k",0,"g",0,"r",0,"o",0,"u",0,"n",0,"d",0," ",0,"C",0,"o",0,"l",0,"o",0,"r",0,0,0
    TextString                 byte          "T",0,"e",0,"x",0,"t",0,0,0

    WNDWIDTH                   equ         1500
    WNDHEIGHT                  equ         700
    CANVASWIDTH                equ         1200
    CANVASHEIGHT               equ         500
    SCROLLWIDTH                equ         3000
    SCROLLHEIGHT               equ         2000

    INSTRUCTION_PENCIL         equ         0
    INSTRUCTION_ERASER         equ         1
    INSTRUCTION_TEXT           equ         2

    IDI_PAINTER                equ         104
    IDI_ERASER                 equ         105
    IDI_PENCIL                 equ         106
    IDC_ERASER                 equ         107
    IDC_PENCIL                 equ         108
    IDB_OPEN                   equ         114
    IDB_SAVE                   equ         115
    IDB_ERASER                 equ         116
    IDB_PENCIL                 equ         117
    IDR_TOOLBAR                equ         118
    IDR_ACCELERATOR            equ         120
    IDD_DIALOG                 equ         121
    IDC_TEXT                   equ         124
    IDC_EDIT                   equ         1003
    ID_MENU                    equ         40003
    ID_MENU_TOOLBAR_PENCIL     equ         40008
    ID_MENU_TOOLBAR_ERASER     equ         40009
    ID_OPEN_TOOLBAR            equ         40022
    ID_SAVE_TOOLBAR            equ         40023
    ID_PENCIL_TOOLBAR          equ         40024
    ID_ERASER_TOOLBAR          equ         40025
    ID_MENU_FILE_OPEN          equ         40029
    ID_MENU_FILE_SAVE          equ         40030
    ID_MENU_TOOLBAR_PALETTE_FOREGROUND equ 40036
    ID_MENU_TOOLBAR_PALETTE_BACKGROUND equ 40037
    ID_FOREGROUND_TOOLBAR      equ         40038
    ID_BACKGROUND_TOOLBAR      equ         40039
    ID_MENU_TOOLBAR_TEXT       equ         40049
    ID_TEXT_TOOLBAR            equ         40050

    STATUSBAR_SIZE_ID          equ         1
    STATUSBAR_TOOL_ID          equ         2
    STATUSBAR_POSITION_ID      equ         3
    
    TEXT_MAX_LENGTH            equ         80
    TOOLBAR_BUTTON_NUM         equ         9
    STATBAR_BUTTON_NUM         equ         4
