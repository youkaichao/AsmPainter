.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

CreateWindowClass proc hInst:HINSTANCE,wndProc:WNDPROC,className:LPCSTR,brush:HBRUSH
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
    mov   wc.lpszMenuName,NULL
    push  className
    pop   wc.lpszClassName
    invoke LoadIcon,NULL,IDI_APPLICATION 
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
        invoke HandleCommand,hWnd,wParam,lParam
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WindowProc endp

CanvasProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_LBUTTONDOWN
        invoke LButtonDown,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_LBUTTONUP
        invoke LButtonUp,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_MOUSEMOVE
        invoke MouseMove,hWnd,wParam,lParam
    .ELSEIF uMsg==WM_PAINT
        invoke Render,hWnd
    .ELSEIF uMsg==WM_MOUSELEAVE
        invoke MouseLeave,hWnd,wParam,lParam 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
CanvasProc endp

end