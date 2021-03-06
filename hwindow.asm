.386 
.model flat,stdcall 
option casemap:none

include function.inc

public fgColor
public bgColor
public currentFont

.data
    fgColor      dword        0
    bgColor      dword        0ffffffh
    acrCustClr   dword        16 dup(0)
    ofn          OPENFILENAME <>
    logicFont    LOGFONT      <> 
    currentFont  HFONT        0

.data?
    fileNameBuffer byte 1000 DUP(?)

.code


WNDDrawTextOnStatusBar proc text:dword,iPart:dword
    local hMain:HWND
    local hdc:HDC
    local rectangle:RECT
    extern hInstance:HINSTANCE
    extern hWndStatus:HWND
    extern eachStatusBarWidth:dword

    invoke GetParent,hWndStatus
    mov hMain,eax
    invoke GetDC,hMain
    mov hdc,eax
    invoke GetClientRect,hWndStatus,addr rectangle
    mov eax,iPart
    imul eachStatusBarWidth
    mov rectangle.right,eax
    sub eax,eachStatusBarWidth
    mov rectangle.left,eax
    invoke MapWindowPoints,hWndStatus,hMain,addr rectangle,2
    invoke DrawStatusText,hdc,addr rectangle,text,NULL
    ret
WNDDrawTextOnStatusBar endp

WNDLButtonUp proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    extern mouseClick:dword
    mov mouseClick,FALSE
    ret
WNDLButtonUp endp

WNDOpenFile proc hWnd:HWND
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
WNDOpenFile endp

WNDSaveFile proc USES edx ebx hWnd:HWND
    local hdc:HDC
    local hdcBmp:HDC
    local hBmpBuffer:HBITMAP
    local bmfHeader:BITMAPFILEHEADER   
    local bi:BITMAPINFOHEADER   
    local bmpScreen:BITMAP
    local dwBmpSize:dword
    local hDIB:HANDLE
    local lpbitmap:PTR byte
    local hFile:HANDLE  
    local dwSizeofDIB:dword
    local dwBytesWritten:dword
    local rcClient:RECT
    local filenameLen:dword
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

    invoke crt_strlen, offset fileNameBuffer
    mov filenameLen, eax
    mov ebx, offset fileNameBuffer
    add ebx, filenameLen
    sub  ebx, 4
    invoke crt_strcmp, ebx, offset BmpExtension
    .if eax != 0
    add ebx, 4
    invoke crt_strcpy, ebx, offset BmpExtension
    .endif

    invoke GetDC,hWndCanvas
    mov hdc,eax
    invoke CreateCompatibleDC,hdc
    mov hdcBmp,eax
    invoke SetStretchBltMode,hdc,HALFTONE
    invoke CreateCompatibleBitmap,hdc,SCROLLWIDTH,SCROLLHEIGHT
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
WNDSaveFile endp

WNDSelectColor proc hWnd:HWND,command:dword
    local cc:CHOOSECOLOR
    extern hInstance:HINSTANCE

    mov cc.lStructSize,sizeof cc
    mov eax,hWnd
    mov cc.hwndOwner,eax
    mov eax,hInstance
    mov cc.hInstance,eax
    mov cc.rgbResult,0
    mov eax,offset acrCustClr
    mov cc.lpCustColors,eax
    mov cc.Flags,CC_FULLOPEN or CC_RGBINIT
    mov cc.lCustData,0
    mov cc.lpfnHook,0
    mov cc.lpTemplateName,0
    invoke ChooseColor,addr cc
    mov eax,cc.rgbResult
    .IF command==0
        mov fgColor,eax
    .ELSEIF command==1
        mov bgColor,eax
    .ENDIF
    ret
WNDSelectColor endp

WNDSelectFont proc hWnd:HWND
    local cc:CHOOSEFONT
    extern hInstance:HINSTANCE

    mov cc.lStructSize,sizeof cc
    mov eax,hWnd
    mov cc.hwndOwner,eax
    mov cc.hDC, 0
    push offset logicFont
    pop cc.lpLogFont
    mov cc.Flags, 0
    mov cc.rgbColors, 0
    mov cc.lCustData, 0
    mov cc.lpfnHook, 0
    mov cc.lpTemplateName, 0
    mov eax,hInstance
    mov cc.hInstance,eax
    mov cc.lpszStyle, 0
    mov cc.nFontType, 0
    mov cc.nSizeMin, 0
    mov cc.nSizeMax, 0
    
    invoke ChooseFont,addr cc
    invoke CreateFontIndirect, offset logicFont
    mov currentFont, eax
    ret
WNDSelectFont endp

WNDHandleCommand proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    extern instruction:dword
    extern hInstance:HINSTANCE
    mov ebx,wParam
    and ebx,0000ffffh
    .IF ebx==ID_MENU_TOOLBAR_PENCIL || ebx==ID_PENCIL_TOOLBAR
        invoke WNDDrawTextOnStatusBar,offset PencilStatus,STATUSBAR_TOOL_ID
        mov instruction,INSTRUCTION_PENCIL
    .ELSEIF ebx==ID_MENU_TOOLBAR_ERASER || ebx==ID_ERASER_TOOLBAR
        invoke WNDDrawTextOnStatusBar,offset EraserStatus,STATUSBAR_TOOL_ID
        mov instruction,INSTRUCTION_ERASER
    .ELSEIF ebx==ID_MENU_TOOLBAR_TEXT || ebx==ID_TEXT_TOOLBAR
        invoke WNDDrawTextOnStatusBar,offset TextStatus,STATUSBAR_TOOL_ID
        mov instruction,INSTRUCTION_TEXT
    .ELSEIF ebx==ID_MENU_TOOLBAR_PALETTE_FOREGROUND || ebx==ID_FOREGROUND_TOOLBAR
        invoke WNDSelectColor,hWnd,0
    .ELSEIF ebx==ID_MENU_TOOLBAR_PALETTE_BACKGROUND || ebx==ID_BACKGROUND_TOOLBAR
        invoke WNDSelectColor,hWnd,1
    .ELSEIF ebx==ID_MENU_FILE_OPEN || ebx==ID_OPEN_TOOLBAR
        invoke WNDOpenFile,hWnd
    .ELSEIF ebx==ID_MENU_FILE_SAVE || ebx==ID_SAVE_TOOLBAR
        invoke WNDSaveFile,hWnd
    .ELSEIF ebx==ID_MENU_TOOLBAR_FONT
        invoke WNDSelectFont,hWnd
    .ENDIF
    mov eax,TRUE
    ret
WNDHandleCommand endp

end
