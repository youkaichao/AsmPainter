.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    extern hWndMainWindow:HWND
    extern hWndCanvas:HWND
    local msg:MSG
    local hWndPencil:HWND
    local hWndEraser:HWND
    mov ebx,OFFSET WindowProc
    invoke GetStockObject,GRAY_BRUSH
    invoke CreateWindowClass,hInst,ebx,addr WindowClass,eax,ID_FILE_MENU
    mov ebx,OFFSET CanvasProc
    invoke GetStockObject,WHITE_BRUSH
    invoke CreateWindowClass,hInst,ebx,addr CanvasClass,eax,0
    invoke CreateWindowEx,0,addr WindowClass,addr WindowName,WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_THICKFRAME,0,0,1200,800,0,0,hInst,0  
    mov hWndMainWindow,eax
    invoke CreateWindowEx,0,addr ButtonClass,addr PencilName,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON or BS_ICON,0,0,50,50,hWndMainWindow,PencilID,hInst,0
    mov hWndPencil,eax
    MAKEINTRESOURCE IDI_PENCIL
    invoke LoadIcon,hInst,eax
    invoke SendMessage,hWndPencil,BM_SETIMAGE,IMAGE_ICON,eax
    invoke CreateWindowEx,0,addr ButtonClass,addr EraserName,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON or BS_ICON,0,50,50,50,hWndMainWindow,EraserID,hInst,0
    mov hWndEraser,eax
    MAKEINTRESOURCE IDI_ERASER
    invoke LoadIcon,hInst,eax
    invoke SendMessage,hWndEraser,BM_SETIMAGE,IMAGE_ICON,eax
    invoke CreateWindowEx,0,addr CanvasClass,addr EraserName,WS_CHILD or WS_VISIBLE,50,0,1150,800,hWndMainWindow,0,hInst,0
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