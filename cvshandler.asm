.386 
.model flat,stdcall 
option casemap:none

include function.inc

public hWndMainWindow
public hWndCanvas
public scrollPosX
public scrollPosY
public mouseClick
public mouseBlur
public instruction
public buffer

.data
    scrollPosX  dword 0
    scrollPosY  dword 0
    mouseClick  dword 0
    mouseBlur   dword 0
    instruction dword 40008
    buffer      HDC   NULL

.data?
    hWndMainWindow HWND  ?
    hWndCanvas     HWND  ?
    mousePosition  POINT <?,?>

.code 

CVSInit proc hWnd:HWND
    local info:SCROLLINFO
    local hdc:HDC
    local hBmp:HBITMAP
    local hBrush:HBRUSH
    push sizeof SCROLLINFO
    pop info.cbSize
    mov info.fMask,SIF_RANGE or SIF_PAGE or SIF_POS
    mov info.nMin,0
    mov eax,SCROLLWIDTH
    mov info.nMax,eax
    push CANVASWIDTH
    pop info.nPage
    mov info.nPos,0
    invoke SetScrollInfo,hWnd,SB_HORZ,addr info,TRUE
    mov eax,SCROLLHEIGHT
    mov info.nMax,eax
    push CANVASHEIGHT
    pop info.nPage
    invoke SetScrollInfo,hWnd,SB_VERT,addr info,TRUE
    
    invoke GetDC,hWnd
    mov hdc,eax
    invoke CreateCompatibleDC,hdc
    mov buffer,eax
    invoke CreateCompatibleBitmap,hdc,SCROLLWIDTH,SCROLLHEIGHT
    mov hBmp,eax
    invoke SelectObject,buffer,hBmp
    RGB 255,255,255
    invoke CreateSolidBrush,eax
    mov hBrush,eax
    invoke SelectObject,buffer,hBrush
    invoke Rectangle,buffer,0,0,SCROLLWIDTH,SCROLLHEIGHT
    invoke DeleteObject,hBrush
    invoke ReleaseDC,hWnd,hdc
    ret
CVSInit endp

CVSRender proc hWnd:HWND
    local hdc:HDC
    local ps:PAINTSTRUCT
    invoke BeginPaint,hWnd,addr ps
    mov hdc,eax
    invoke BitBlt,hdc,0,0,CANVASWIDTH,CANVASHEIGHT,buffer,scrollPosX,scrollPosY,SRCCOPY
    invoke EndPaint,hWnd,addr ps
    ret
CVSRender endp

CVSLButtonDown proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov mouseClick,TRUE
    mov eax,lParam 
    and eax,0FFFFh 
    mov mousePosition.x,eax 
    mov eax,lParam 
    shr eax,16 
    mov mousePosition.y,eax
    ret
CVSLButtonDown endp

CVSLButtonUp proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov mouseClick,FALSE
    ret
CVSLButtonUp endp

CVSMouseMove proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    local hdc:HDC
    local hPen:HPEN
    local position:POINT
    local tempDC:HDC
    local tempBitmap:HBITMAP
    extern currentColor:dword

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
    mov tempDC,eax
    invoke CreateCompatibleBitmap,hdc,SCROLLWIDTH,SCROLLHEIGHT
    mov tempBitmap,eax
    invoke SelectObject,tempDC,tempBitmap
    invoke BitBlt,tempDC,0,0,SCROLLWIDTH,SCROLLHEIGHT,buffer,0,0,SRCCOPY
    mov eax,instruction
    mov ebx,currentColor
    .IF eax==ID_MENU_TOOLBAR_PENCIL
        invoke CreatePen,PS_SOLID,1,ebx
    .ELSEIF eax==ID_MENU_TOOLBAR_ERASER
        invoke CreatePen,PS_SOLID,10,ebx
    .ENDIF
    mov hPen,eax
    invoke SelectObject,tempDC,hPen
    mov eax,mousePosition.x
    mov ebx,mousePosition.y
    add eax,scrollPosX
    add ebx,scrollPosY
    invoke MoveToEx,tempDC,eax,ebx,0
    mov eax,position.x
    mov ebx,position.y
    push eax
    push ebx
    add eax,scrollPosX
    add ebx,scrollPosY
    invoke LineTo,tempDC,eax,ebx
    pop mousePosition.y
    pop mousePosition.x
    invoke BitBlt,buffer,0,0,SCROLLWIDTH,SCROLLHEIGHT,tempDC,0,0,SRCCOPY

    invoke DeleteObject,hPen
    invoke DeleteObject,tempBitmap
    invoke DeleteDC,tempDC
    invoke ReleaseDC,hWnd,hdc

    invoke InvalidateRect,hWnd,0,FALSE
    invoke UpdateWindow,hWnd
    invoke CVSSetTrack,hWnd
    ret
CVSMouseMove endp

CVSSetTrack proc hWnd:HWND
    local event:TRACKMOUSEEVENT
    mov  event.cbSize,sizeof TRACKMOUSEEVENT
    mov  event.dwFlags,TME_LEAVE
    push hWnd
    pop  event.hwndTrack
    invoke TrackMouseEvent,addr event
    ret
CVSSetTrack endp

CVSMouseLeave proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov mouseBlur,TRUE
    ret
CVSMouseLeave endp

CVSHorizontalScroll proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    local posX:dword
    local info:SCROLLINFO
    mov eax,wParam
    and eax,0ffffh
    mov ebx,scrollPosX
    .IF eax==SB_PAGEUP
        .IF ebx<50
            mov ebx,0
        .ELSE
            sub ebx,50
        .ENDIF
    .ELSEIF eax==SB_PAGEDOWN
        add ebx,50
    .ELSEIF eax==SB_LINEUP
        .IF ebx<5
            mov ebx,0
        .ELSE
            sub ebx,5
        .ENDIF
    .ELSEIF eax==SB_LINEDOWN
        add ebx,5
    .ELSEIF eax==SB_THUMBPOSITION
        mov ebx,wParam
        shr ebx,16
    .ENDIF
    mov eax,SCROLLWIDTH
    sub eax,CANVASWIDTH
    .IF ebx>eax
        mov ebx,eax
    .ENDIF
    .IF ebx==scrollPosX
        ret
    .ENDIF
    mov eax,ebx
    sub eax,scrollPosX
    neg eax
    mov scrollPosX,ebx
    invoke ScrollWindowEx,hWnd,eax,0,NULL,NULL,NULL,NULL,SW_INVALIDATE
    invoke UpdateWindow,hWnd
    push sizeof SCROLLINFO
    pop info.cbSize
    mov info.fMask,SIF_POS
    push scrollPosX
    pop info.nPos
    invoke SetScrollInfo,hWnd,SB_HORZ,addr info,TRUE
    ret
CVSHorizontalScroll endp

CVSVerticalScroll proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    local posY:dword
    local info:SCROLLINFO
    mov eax,wParam
    and eax,0ffffh
    mov ebx,scrollPosY
    .IF eax==SB_PAGEUP
        .IF ebx<50
            mov ebx,0
        .ELSE
            sub ebx,50
        .ENDIF
    .ELSEIF eax==SB_PAGEDOWN
        add ebx,50
    .ELSEIF eax==SB_LINEUP
        .IF ebx<5
            mov ebx,0
        .ELSE
            sub ebx,5
        .ENDIF
    .ELSEIF eax==SB_LINEDOWN
        add ebx,5
    .ELSEIF eax==SB_THUMBPOSITION
        mov ebx,wParam
        shr ebx,16
    .ENDIF
    mov eax,SCROLLHEIGHT
    sub eax,CANVASHEIGHT
    .IF ebx>eax
        mov ebx,eax
    .ENDIF
    .IF ebx==scrollPosY
        ret
    .ENDIF
    mov eax,ebx
    sub eax,scrollPosY
    neg eax
    mov scrollPosY,ebx
    invoke ScrollWindowEx,hWnd,0,eax,NULL,NULL,NULL,NULL,SW_INVALIDATE
    invoke UpdateWindow,hWnd
    push sizeof SCROLLINFO
    pop info.cbSize
    mov info.fMask,SIF_POS
    push scrollPosY
    pop info.nPos
    invoke SetScrollInfo,hWnd,SB_VERT,addr info,TRUE
    ret
CVSVerticalScroll endp

end