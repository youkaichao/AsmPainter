.386 
.model flat,stdcall 
option casemap:none

include function.inc

public hWndMainWindow
public hWndCanvas

.data?
    hWndMainWindow HWND ?
    hWndCanvas HWND ?

.code 

Render proc hWnd:HWND
    local hdc:HDC
    local ps:PAINTSTRUCT
    invoke BeginPaint,hWnd,addr ps
    mov hdc,eax
    invoke BitBlt,hdc,0,0,1200,800,buffer,0,0,SRCCOPY
    invoke EndPaint,hWnd,addr ps
    ret
Render endp

LButtonDown proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov mouseClick,TRUE
    mov eax,lParam 
    and eax,0FFFFh 
    mov mousePosition.x,eax 
    mov eax,lParam 
    shr eax,16 
    mov mousePosition.y,eax
    ret
LButtonDown endp

LButtonUp proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov mouseClick,FALSE
    ret
LButtonUp endp

MouseMove proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    local hdc:HDC
    local rect:RECT
    local hpen:HPEN
    local position:POINT
    local bitmap:HBITMAP

    mov eax,lParam 
    and eax,0FFFFh 
    mov position.x,eax 
    mov eax,lParam 
    shr eax,16 
    mov position.y,eax

    .IF !mouseClick
        ret
    .ENDIF
    .IF mouseBlur
        mov mouseBlur,FALSE
        push position.x
        push position.y
        pop mousePosition.y
        pop mousePosition.x
        ret
    .ENDIF
    invoke GetDC,hWnd
    mov hdc,eax
    invoke CreateCompatibleDC,hdc
    mov buffer,eax
    invoke GetClientRect,hWnd,addr rect
    invoke CreateCompatibleBitmap,hdc,rect.right,rect.bottom
    mov bitmap,eax
    invoke SelectObject,buffer,bitmap
    invoke BitBlt,buffer,0,0,rect.right,rect.bottom,hdc,0,0,SRCCOPY
    mov eax,instruction
    .IF eax==PencilID
        RGB 0,0,0
        invoke CreatePen,PS_SOLID,1,eax
    .ELSEIF eax==EraserID
        RGB 255,255,255
        invoke CreatePen,PS_SOLID,10,eax
    .ENDIF
    mov hpen,eax
    invoke SelectObject,buffer,hpen
    push position.x
    push position.y
    invoke MoveToEx,buffer,mousePosition.x,mousePosition.y,0
    invoke LineTo,buffer,position.x,position.y
    pop mousePosition.y
    pop mousePosition.x
    invoke DeleteObject,bitmap
    invoke ReleaseDC,hWnd,hdc
    invoke InvalidateRect,hWnd,0,FALSE
    invoke UpdateWindow,hWnd
    invoke SetTrack,hWnd
    ret
MouseMove endp

SetTrack proc hWnd:HWND
    local event:TRACKMOUSEEVENT
    mov  event.cbSize,sizeof TRACKMOUSEEVENT
    mov  event.dwFlags,TME_LEAVE
    push hWnd
    pop  event.hwndTrack
    invoke TrackMouseEvent,addr event
    ret
SetTrack endp

MouseLeave proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov mouseBlur,TRUE
    ret
MouseLeave endp

FileOpenMenu proc hWnd:HWND
    local hdc:HDC
    local hdcBmp:HDC
    local hBmpBuffer:HBITMAP
    local hBmp:HBITMAP
    local rect:RECT
    
    invoke GetDC,hWndCanvas
    mov hdc,eax
    invoke CreateCompatibleDC,hdc
    mov buffer,eax
    invoke CreateCompatibleDC,hdc
    mov hdcBmp,eax
    invoke CreateCompatibleBitmap,hdc,1150,800
    mov hBmpBuffer,eax
    invoke SelectObject,buffer,hBmpBuffer
    invoke BitBlt,buffer,0,0,1150,800,hdc,0,0,SRCCOPY

    mov  ofn.lStructSize,sizeof ofn
    mov  ofn.hwndOwner,NULL 
    push hInstance 
    pop  ofn.hInstance 
    mov  ofn.lpstrFilter,OFFSET FilterString 
    mov  ofn.lpstrFile,OFFSET fileNameBuffer 
    mov  ofn.nMaxFile,sizeof fileNameBuffer 
    mov  ofn.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
    invoke GetOpenFileName,ADDR ofn
    .IF (!eax)
        ret
    .ENDIF
    invoke LoadImage,hInstance,addr fileNameBuffer,IMAGE_BITMAP,0,0,LR_LOADFROMFILE 
    .IF (!eax)
        ret
    .ENDIF

    mov hBmp,HBITMAP PTR eax
    invoke SelectObject,hdcBmp,hBmp
    invoke BitBlt,buffer,0,0,1150,800,hdcBmp,0,0,SRCCOPY
    invoke InvalidateRect,hWndCanvas,0,FALSE
    invoke UpdateWindow,hWndCanvas
    invoke DeleteDC,hdcBmp
    invoke DeleteObject,hBmp
    invoke DeleteObject,hBmpBuffer
    invoke ReleaseDC,hWndCanvas,hdc
    ret
FileOpenMenu endp

FileSaveMenu proc hWnd:HWND
    ret
FileSaveMenu endp

HandleCommand proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov ebx,wParam
    .IF ebx==PencilID
        mov eax,PencilID
        mov instruction,eax
    .ELSEIF ebx==EraserID
        mov eax,EraserID
        mov instruction,eax
    .ELSEIF ebx==ID_FILE_OPEN_MENU
        invoke FileOpenMenu,hWnd
    .ELSEIF ebx==ID_FILE_SAVE_MENU
        invoke FileSaveMenu,hWnd
    .ENDIF
    ret
HandleCommand endp

end