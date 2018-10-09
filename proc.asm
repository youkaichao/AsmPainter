.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

CreateWindowClass proc hInst:HINSTANCE,wndProc:WNDPROC,className:LPCSTR,brush:HBRUSH,menu:DWORD
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

WindowProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
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

CanvasProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
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
    xor    eax,eax 
    ret 
CanvasProc endp

end