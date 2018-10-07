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
    invoke BitBlt,hdc,0,0,WNDWIDTH,WNDHEIGHT,buffer,0,0,SRCCOPY
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

PBITMAPINFO       TYPEDEF PTR BITMAPINFO
PBITMAPINFOHEADER TYPEDEF PTR BITMAPINFOHEADER

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
    invoke CreateCompatibleBitmap,hdc,CANVASWIDTH,WNDHEIGHT
    mov hBmpBuffer,eax
    invoke SelectObject,buffer,hBmpBuffer
    invoke BitBlt,buffer,0,0,CANVASWIDTH,WNDHEIGHT,hdc,0,0,SRCCOPY

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
    invoke BitBlt,buffer,0,0,CANVASWIDTH,WNDHEIGHT,hdcBmp,0,0,SRCCOPY
    invoke InvalidateRect,hWndCanvas,0,FALSE
    invoke UpdateWindow,hWndCanvas
    invoke DeleteDC,hdcBmp
    invoke DeleteObject,hBmp
    invoke DeleteObject,hBmpBuffer
    invoke ReleaseDC,hWndCanvas,hdc
    ret
FileOpenMenu endp

FileSaveMenu proc USES edx ebx  hWnd:HWND
    local hdc:HDC
    local hdcBmp:HDC
    local hBmpBuffer:HBITMAP
    local pbi:PBITMAPINFO
    local bmfHeader:BITMAPFILEHEADER   
    local bi:BITMAPINFOHEADER   
    local bmpScreen:BITMAP
    local dwBmpSize:DWORD
    local hDIB: HANDLE
    local lpbitmap : PTR BYTE
    local hFile:HANDLE  
    local dwSizeofDIB:DWORD
    local dwBytesWritten:DWORD
    local rcClient:RECT

    mov  ofn.lStructSize,SIZEOF ofn
    mov  ofn.hwndOwner,NULL 
    push hInstance 
    pop  ofn.hInstance 
    mov  ofn.lpstrFilter,OFFSET FilterString 
    mov  ofn.lpstrFile,OFFSET fileNameBuffer 
    mov  ofn.nMaxFile,SIZEOF fileNameBuffer 
    mov  ofn.Flags,OFN_PATHMUSTEXIST
    invoke GetSaveFileName,ADDR ofn
    .IF (!eax)
        ret
    .ENDIF

    invoke GetDC,hWndCanvas
    mov hdc,eax
    invoke CreateCompatibleDC,hdc
    mov hdcBmp,eax
    invoke GetClientRect,hWndCanvas,addr rcClient
    invoke SetStretchBltMode,hdc,HALFTONE

    mov ebx,rcClient.right
    sub ebx,rcClient.left
    mov edx,rcClient.bottom
    sub edx,rcClient.top
    invoke CreateCompatibleBitmap,hdc,ebx,edx
    mov hBmpBuffer,eax
    invoke SelectObject,hdcBmp,hBmpBuffer
    invoke BitBlt,hdcBmp,0,0,ebx,edx,hdc,0,0,SRCCOPY
    invoke GetObject,hBmpBuffer,SIZEOF BITMAP,addr bmpScreen
    push sizeof BITMAPINFOHEADER
    pop bi.biSize
    push bmpScreen.bmWidth
    pop bi.biWidth
    push bmpScreen.bmHeight
    pop bi.biHeight
    mov bi.biPlanes,1
    mov bi.biBitCount,32
    mov bi.biCompression,BI_RGB
    mov bi.biSizeImage,0
    mov bi.biXPelsPerMeter,0
    mov bi.biYPelsPerMeter,0
    mov bi.biClrUsed,0
    mov bi.biClrImportant,0

    movzx eax,bi.biBitCount
    mul bmpScreen.bmWidth
    add eax,31
    mov ebx,32
    cdq
    div ebx
    mov edx,4
    mul edx
    mul bmpScreen.bmHeight
    mov dwBmpSize,eax
    invoke GlobalAlloc,GHND,dwBmpSize
    mov hDIB,eax
    invoke GlobalLock,hDIB
    mov lpbitmap,eax

    invoke GetDIBits,hdc,hBmpBuffer,0,bmpScreen.bmHeight,lpbitmap,addr bi,DIB_RGB_COLORS
    invoke CreateFile,addr fileNameBuffer,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile,eax
    mov eax,dwBmpSize 
    add eax,sizeof BITMAPFILEHEADER
    add eax,sizeof BITMAPINFOHEADER
    mov dwSizeofDIB,eax

    mov eax,sizeof BITMAPFILEHEADER
    add eax,sizeof BITMAPINFOHEADER
    mov bmfHeader.bfOffBits,eax
    push dwSizeofDIB
    pop bmfHeader.bfSize
    mov bmfHeader.bfType,4D42h

    invoke WriteFile,hFile,addr bmfHeader,sizeof BITMAPFILEHEADER,addr dwBytesWritten,NULL
    invoke WriteFile,hFile,addr bi,sizeof BITMAPINFOHEADER,addr dwBytesWritten,NULL
    invoke WriteFile,hFile,lpbitmap,dwBmpSize,addr dwBytesWritten,NULL

    invoke GlobalUnlock,hDIB
    invoke GlobalFree,hDIB
    invoke CloseHandle,hFile

    invoke DeleteDC,hdcBmp
    invoke DeleteObject,hBmpBuffer
    invoke ReleaseDC,hWndCanvas,hdc
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