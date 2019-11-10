;--------------------------------------------------------------------
; File name	: Nsnake.asm
; 		  	  Main file of the Snake Game assisted by "assist.asm"
; date		: 2015.10.01
; author	: NewPrO
;--------------------------------------------------------------------

ASSUME  cs:code, ds:data, ss:stack

;-------------------------------
NODE    STRUC
        ROW   DB  ? ;行
        COL   DB  ? ;列
NODE    ENDS
; 表示Snake的每一段的一个结构体
;-------------------------------

; segment stack
stack   SEGMENT BYTE STACK
        DW  1024 DUP(0)
stack   ENDS

; segment data
data    SEGMENT
; snake活动区域：(5,5) (194,224)
; 那么snake坐标的范围：(5,5),(185,215)
        snake   NODE    <5,5>,<5,215>,<185,5>,<185,215>,<0,0>
        direc   DB      ?   ;0:上    1:下     2:左     3:右
data    ENDS

; main
code    SEGMENT
start:  call    WinStart
;------------------------------------------------
        mov     ah, 00H
        mov     al, 0DH
        int     10H
; Set the display mode and clear the screen
;------------------------------------------------
        call    WinMain			; Draw the GAME window
;------------------------------------------------
        mov     ax, data
        mov     ds, ax
        mov     dx, OFFSET snake
        call    PaintSnake
;------------------------------------------------
        mov     ah, 00H
        int     16H				; Wait for User input

        mov     ax, 4C00H
        int     21H
code    ENDS
INCLUDE assist.asm
        END start
