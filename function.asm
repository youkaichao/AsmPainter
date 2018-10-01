.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code 

Render proc hWnd:HWND
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
    local hpen:HPEN
    local position:POINT
    .IF !mouseClick
        ret
    .ENDIF
    invoke GetDC,hWnd
    mov hdc,eax
    mov eax,instruction
    .IF eax==PencilID
        RGB 0,0,0
        invoke CreatePen,PS_SOLID,1,eax
    .ELSEIF eax==EraserID
        RGB 255,255,255
        invoke CreatePen,PS_SOLID,10,eax
    .ENDIF
    mov hpen,eax
    invoke SelectObject,hdc,hpen
    mov eax,lParam 
    and eax,0FFFFh 
    mov position.x,eax 
    mov eax,lParam 
    shr eax,16 
    mov position.y,eax
    push position.x
    push position.y
    invoke MoveToEx,hdc,mousePosition.x,mousePosition.y,0
    invoke LineTo,hdc,position.x,position.y
    invoke ReleaseDC,hWnd,hdc
    pop mousePosition.y
    pop mousePosition.x
    ret
MouseMove endp

HandleCommand proc hWnd:HWND,wParam:WPARAM
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