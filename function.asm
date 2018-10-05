.386 
.model flat,stdcall 
option casemap:none

include function.inc

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
    .IF !mouseClick
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
    mov eax,lParam 
    and eax,0FFFFh 
    mov position.x,eax 
    mov eax,lParam 
    shr eax,16 
    mov position.y,eax
    push position.x
    push position.y
    invoke MoveToEx,buffer,mousePosition.x,mousePosition.y,0
    invoke LineTo,buffer,position.x,position.y
    pop mousePosition.y
    pop mousePosition.x
    invoke ReleaseDC,hWnd,hdc
    invoke InvalidateRect,hWnd,0,FALSE
    invoke UpdateWindow,hWnd
    ret
MouseMove endp

HandleCommand proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov ebx,wParam
    .IF ebx==PencilID
        mov eax,PencilID
    .ELSEIF ebx==EraserID
        mov eax,EraserID
    .ENDIF
    mov instruction,eax
    ret
HandleCommand endp

end