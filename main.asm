.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    local msg:MSG 
    local hwnd:HWND
    mov ebx,OFFSET WindowProc
    invoke GetStockObject,GRAY_BRUSH
    invoke CreateWindowClass,hInst,ebx,addr WindowClass,eax
    mov ebx,OFFSET CanvasProc
    invoke GetStockObject,WHITE_BRUSH
    invoke CreateWindowClass,hInst,ebx,addr CanvasClass,eax
    invoke CreateWindowEx,0,addr WindowClass,addr WindowName,WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_THICKFRAME,0,0,1200,800,0,0,hInst,0 
    mov   hwnd,eax 
    invoke CreateWindowEx,0,addr ButtonClass,addr PencilName,WS_CHILD or WS_VISIBLE,0,0,100,50,hwnd,PencilID,hInst,0
    invoke CreateWindowEx,0,addr ButtonClass,addr EraserName,WS_CHILD or WS_VISIBLE,0,50,100,50,hwnd,EraserID,hInst,0
    invoke CreateWindowEx,0,addr CanvasClass,addr EraserName,WS_CHILD or WS_VISIBLE,100,0,1100,800,hwnd,0,hInst,0
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



start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov commandLine,eax 
    invoke WinMain, hInstance,NULL,commandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax
end start 