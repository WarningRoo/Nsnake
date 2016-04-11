;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;name:Nsnake.asm
;Main file of the Snake Game assisted by "assist.asm"
;date: 2015.10.01
;author:NewPrO
;snake game start from here to go(.time 2015-9-20 21:23:27)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ASSUME  cs:code, ds:data, ss:stack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NODE    STRUC
        ROW   DB  ? ;行
        COL   DB  ? ;列
NODE    ENDS
;表示Snake的每一段的一个结构体
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;栈段
stack   SEGMENT BYTE STACK
        DW  1024 DUP(0)
stack   ENDS

;main文件数据段
data    SEGMENT
;snake活动区域：(5,5) (194,224)
;那么snake坐标的范围：(5,5),(185,215)
        snake   NODE    <5,5>,<5,215>,<185,5>,<185,215>,<0,0>
        direc   DB      ?   ;0:上    1:下     2:左     3:右
data    ENDS

;main文件代码段，实现Snake Game运行的流程管理
code    SEGMENT
start:  call    WinStart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 00H
        mov     al, 0DH
        int     10H
;设置显示模式，也相当于清屏
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call    WinMain             ;显示主界面
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ax, data
        mov     ds, ax
        mov     dx, OFFSET snake
        call    PaintSnake
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 00H
        int     16H             ;等待用户按键

        mov     ax, 4C00H
        int     21H
code    ENDS
INCLUDE assist.asm
        END start