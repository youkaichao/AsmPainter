.386 
.model flat,stdcall 
option casemap:none

include function.inc

public partRightEdge
public eachStatusBarWidth

.data
    stringBuffer byte 1000 DUP(?)
    canvasSizeFormat byte "Canvas size: %d(w) x %d(h)", 0

.data?
    buttonList TBBUTTON TOOLBAR_BUTTON_NUM DUP(<?,?,?,?,?>)
    partRightEdge dword 256 DUP(0)
    eachStatusBarWidth dword ?

.code 

CreateWindowClass proc hInst:HINSTANCE,wndProc:WNDPROC,className:LPCSTR,brush:HBRUSH,menu:dword
    local wc:WNDCLASSEX 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    push  wndProc
    pop   wc.lpfnWndProc
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    push  brush
    pop   wc.hbrBackground
    MAKEINTRESOURCE menu
    mov   wc.lpszMenuName,eax
    push  className
    pop   wc.lpszClassName
    MAKEINTRESOURCE IDI_PAINTER
    invoke LoadIcon,hInst,eax
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc
    ret
CreateWindowClass endp

CreateToolbar proc hWnd:HWND
    local button:TBBUTTON
    local initCtrl:INITCOMMONCONTROLSEX
    extern hInstance:HINSTANCE
    assume eax:PTR TBBUTTON

    mov initCtrl.dwSize,sizeof INITCOMMONCONTROLSEX
    mov initCtrl.dwICC,ICC_BAR_CLASSES
    invoke InitCommonControlsEx,addr initCtrl

    mov eax,offset buttonList
    mov [eax].iBitmap,0
    mov [eax].idCommand,ID_OPEN_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset OpenString
    
    add eax,sizeof TBBUTTON
    
    mov [eax].iBitmap,1
    mov [eax].idCommand,ID_SAVE_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset SaveString

    add eax,sizeof TBBUTTON

    mov [eax].iBitmap,0
    mov [eax].idCommand,0
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_SEP
    mov [eax].dwData,0
    mov [eax].iString,0

    add eax,sizeof TBBUTTON

    mov [eax].iBitmap,2
    mov [eax].idCommand,ID_PENCIL_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset PencilString

    add eax,sizeof TBBUTTON
    
    mov [eax].iBitmap,3
    mov [eax].idCommand,ID_ERASER_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset EraserString

    add eax,sizeof TBBUTTON

    mov [eax].iBitmap,0
    mov [eax].idCommand,0
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_SEP
    mov [eax].dwData,0
    mov [eax].iString,0

    add eax,sizeof TBBUTTON
    
    mov [eax].iBitmap,4
    mov [eax].idCommand,ID_FOREGROUND_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset ForegroundString

    add eax,sizeof TBBUTTON
    
    mov [eax].iBitmap,5
    mov [eax].idCommand,ID_BACKGROUND_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset BackgroundString
    
    add eax,sizeof TBBUTTON
    
    mov [eax].iBitmap,6
    mov [eax].idCommand,ID_TEXT_TOOLBAR
    mov [eax].fsState,TBSTATE_ENABLED
    mov [eax].fsStyle,TBSTYLE_BUTTON
    mov [eax].dwData,0
    mov [eax].iString,offset TextString


    invoke CreateToolbarEx,hWnd,WS_VISIBLE or WS_BORDER or TBSTYLE_TOOLTIPS ,IDR_TOOLBAR,TOOLBAR_BUTTON_NUM,hInstance,IDR_TOOLBAR,addr buttonList,TOOLBAR_BUTTON_NUM,16,16,16,16,sizeof TBBUTTON
    invoke SendMessage,eax,TB_SETMAXTEXTROWS,0,0
    ret
CreateToolbar endp

CreateStatusbar proc hWnd:HWND
    local initCtrl:INITCOMMONCONTROLSEX
    local rectangle:RECT
    extern hInstance:HINSTANCE
    extern hWndStatus:HWND

    invoke crt_sprintf,offset stringBuffer,offset canvasSizeFormat,SCROLLWIDTH,SCROLLHEIGHT
    mov initCtrl.dwSize,sizeof INITCOMMONCONTROLSEX
    mov initCtrl.dwICC,ICC_BAR_CLASSES
    invoke InitCommonControlsEx,addr initCtrl
    invoke CreateStatusWindow,WS_CHILD or WS_VISIBLE,offset stringBuffer,hWnd,NULL
    mov hWndStatus, eax
    invoke GetClientRect,hWndStatus,addr rectangle
    mov eax, rectangle.right
    cdq
    mov ebx,STATBAR_BUTTON_NUM
    idiv ebx
    mov eachStatusBarWidth, eax
    mov eax,eachStatusBarWidth
    mov ebx,0
    mov ecx,STATBAR_BUTTON_NUM
    sub ecx,1
    tag:
        mov partRightEdge[ebx],eax
        add eax,eachStatusBarWidth
        add ebx,sizeof dword
        loop tag
    invoke SendMessage,hWndStatus,SB_SETPARTS,STATBAR_BUTTON_NUM,offset partRightEdge
    ret
CreateStatusbar endp

WindowProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM 
    .IF uMsg==WM_CREATE
        mov eax, hWnd
    .ELSEIF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_COMMAND
        invoke WNDHandleCommand,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_LBUTTONUP
        invoke WNDLButtonUp,hWnd,wParam,lParam
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WindowProc endp

CanvasProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM 
    .IF uMsg==WM_CREATE
        invoke CVSInit,hWnd
    .ELSEIF uMsg==WM_LBUTTONDOWN
        invoke CVSLButtonDown,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_LBUTTONUP
        invoke CVSLButtonUp,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_MOUSEMOVE
        invoke CVSMouseMove,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_PAINT
        invoke CVSRender,hWnd
    .ELSEIF uMsg==WM_MOUSELEAVE
        invoke CVSMouseLeave,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_VSCROLL
        invoke CVSVerticalScroll,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_HSCROLL
        invoke CVSHorizontalScroll,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_SETCURSOR
        invoke CVSSetCursor,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret 
CanvasProc endp

DialogProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx==WM_COMMAND
        invoke DLGHandleCommand,hWnd,wParam,lParam
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret
DialogProc endp

end