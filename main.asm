.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    local wc:WNDCLASSEX 
    local msg:MSG 
    local hwnd:HWND
    local hbutton:HWND
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET WindowClass 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,0,addr WindowClass,addr WindowName,WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_THICKFRAME,0,0,1200,800,0,0,hInst,0 
    mov   hwnd,eax 
    invoke CreateWindowEx,0,addr ButtonClass,addr PencilName,WS_CHILD or WS_VISIBLE,0,0,100,100,hwnd,PencilID,hInst,0
    invoke CreateWindowEx,0,addr ButtonClass,addr EraserName,WS_CHILD or WS_VISIBLE,0,100,100,100,hwnd,EraserID,hInst,0
    mov   hbutton,eax
    invoke ShowWindow,hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow,hwnd
    .WHILE TRUE 
        invoke GetMessage, addr msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke DispatchMessage, addr msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
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
    .ELSEIF uMsg==WM_COMMAND
        invoke HandleCommand,hWnd,wParam
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp

start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov commandLine,eax 
    invoke WinMain, hInstance,NULL,commandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax
end start 