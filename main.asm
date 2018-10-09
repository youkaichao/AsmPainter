.386 
.model flat,stdcall 
option casemap:none

include function.inc

public hInstance

.data?
    hInstance   HINSTANCE ?
    commandLine LPSTR     ?

.code 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    extern hWndMainWindow:HWND
    extern hWndCanvas:HWND
    local msg:MSG
    mov ebx,OFFSET WindowProc
    invoke GetStockObject,GRAY_BRUSH
    invoke CreateWindowClass,hInst,ebx,addr WindowClass,eax,ID_FILE_MENU
    mov ebx,OFFSET CanvasProc
    invoke GetStockObject,WHITE_BRUSH
    invoke CreateWindowClass,hInst,ebx,addr CanvasClass,eax,0
    invoke CreateWindowEx,0,addr WindowClass,addr WindowName,WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_THICKFRAME,0,0,WNDWIDTH,WNDHEIGHT,0,0,hInst,0  
    mov hWndMainWindow,eax
    invoke CreateWindowEx,0,addr CanvasClass,addr EraserName,WS_CHILD or WS_VISIBLE,0,0,CANVASWIDTH,CANVASHEIGHT,hWndMainWindow,0,hInst,0
    mov hWndCanvas,eax
    invoke ShowWindow,hWndMainWindow,SW_SHOWNORMAL 
    invoke UpdateWindow,hWndMainWindow
    .WHILE TRUE 
        invoke GetMessage,addr msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke DispatchMessage,addr msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp



start: 
    invoke GetModuleHandle,NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov commandLine,eax 
    invoke WinMain,hInstance,NULL,commandLine,SW_SHOWDEFAULT 
    invoke ExitProcess,eax
end start 