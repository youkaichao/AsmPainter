.386 
.model flat,stdcall 
option casemap:none

include function.inc

public currentColor

.data
    currentColor dword        0
    ofn          OPENFILENAME <>

.data?
    fileNameBuffer byte 1000 DUP(?)

.code

WNDLButtonUp proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    extern mouseClick:dword
    mov mouseClick,FALSE
    ret
WNDLButtonUp endp

WNDFileOpenMenu proc hWnd:HWND
    local hdc:HDC
    local hdcBmp:HDC
    local hBmp:HBITMAP
    local tempDC:HDC
    local tempBmp:HBITMAP
    extern scrollPosX:dword
    extern scrollPosY:dword
    extern hWndCanvas:HWND
    extern hInstance:HINSTANCE
    extern buffer:HDC

    invoke GetDC,hWndCanvas
    mov hdc,eax
    invoke CreateCompatibleDC,hdc
    mov tempDC,eax
    invoke CreateCompatibleDC,hdc
    mov hdcBmp,eax
    invoke CreateCompatibleBitmap,hdc,SCROLLWIDTH,SCROLLHEIGHT
    mov tempBmp,eax
    invoke SelectObject,tempDC,tempBmp
    invoke BitBlt,tempDC,0,0,SCROLLWIDTH,SCROLLHEIGHT,buffer,0,0,SRCCOPY

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
    invoke BitBlt,tempDC,0,0,SCROLLWIDTH,SCROLLHEIGHT,hdcBmp,0,0,SRCCOPY
    invoke BitBlt,buffer,0,0,SCROLLWIDTH,SCROLLHEIGHT,tempDC,0,0,SRCCOPY
    
    invoke DeleteDC,hdcBmp
    invoke DeleteDC,tempDC
    invoke DeleteObject,tempBmp
    invoke ReleaseDC,hWndCanvas,hdc

    invoke InvalidateRect,hWndCanvas,0,FALSE
    invoke UpdateWindow,hWndCanvas
    ret
WNDFileOpenMenu endp

WNDFileSaveMenu proc USES edx ebx hWnd:HWND
    local hdc:HDC
    local hdcBmp:HDC
    local hBmpBuffer:HBITMAP
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
    extern hInstance:HINSTANCE

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
    invoke SetStretchBltMode,hdc,HALFTONE
    invoke CreateCompatibleBitmap,hdc,SCROLLHEIGHT,SCROLLWIDTH
    mov hBmpBuffer,eax
    invoke SelectObject,hdcBmp,hBmpBuffer
    invoke BitBlt,hdcBmp,0,0,SCROLLWIDTH,SCROLLHEIGHT,buffer,0,0,SRCCOPY
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
WNDFileSaveMenu endp

WNDHandleCommand proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    extern instruction:dword
    mov ebx,wParam
    .IF ebx==ID_MENU_TOOLBAR_PENCIL
        mov eax,ID_MENU_TOOLBAR_PENCIL
        mov instruction,eax
        RGB 0,0,0
        mov currentColor,eax
    .ELSEIF ebx==ID_MENU_TOOLBAR_ERASER
        mov eax,ID_MENU_TOOLBAR_ERASER
        mov instruction,eax
        RGB 255,255,255
        mov currentColor,eax
    .ELSEIF ebx==ID_FILE_OPEN_MENU
        invoke WNDFileOpenMenu,hWnd
    .ELSEIF ebx==ID_FILE_SAVE_MENU
        invoke WNDFileSaveMenu,hWnd
    .ENDIF
    ret
WNDHandleCommand endp

end
