.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

Render proc hWnd:HWND
    ret
Render endp

LButtonDown proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov MouseClick,TRUE 
    ret
LButtonDown endp

LButtonUp proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov MouseClick,FALSE
    ret
LButtonUp endp

MouseMove proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    local hdc:HDC
    local position:POINT
    .IF !MouseClick
        ret
    .ENDIF
    invoke GetDC,hWnd
    mov hdc,eax
    mov eax,lParam 
    and eax,0FFFFh 
    mov position.x,eax 
    mov eax,lParam 
    shr eax,16 
    mov position.y,eax 
    RGB 0,0,0
    invoke SetPixel,hdc,position.x,position.y,eax
    invoke ReleaseDC,hWnd,hdc
    ret
MouseMove endp

end