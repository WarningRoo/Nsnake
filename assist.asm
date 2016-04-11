;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;File name:assist.asm
;该文件中定义了Nsnake.asm所需要的宏定义，子程序定义，特别是对于辅助功能的子程序的定义
;date:2015.10.01
;author:NewPrO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;辅助模块数据段，考虑是否与主模块的数据段合并？（2015-10-1 18:44:09）
;data    SEGMENT
;data    ENDS

code    SEGMENT
;***************************************************************************
;子程序名：WinStart
;功能：显示最初的游戏进入界面，获取用户按键以进入主游戏界面
;入口参数：无
;出口参数：无
;说明： 制作后期，可以自由添加一些可以使得界面更加漂亮的元素
;       2015-10-31 22:24:00更新：更换snake的显示方式，使用从文件中读取数据画字符的方式！
;***************************************************************************
WinStart    PROC    NEAR
        jmp     WinStartBegin
WinStartFile:   DB  "snake3.txt",0
WinStartFileLen EQU 1108
WinStartBuffer: DB  1200 DUP(0)
WinStartMsg0:   DB  "Press any key to start the game!"
WinStartMsg0Len EQU $-WinStartMsg0
WinStartBegin:
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    bp
        pushf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 00H
        mov     al, 03H
        int     10H             ;设置视频模式，相当于清屏

        push    cs
        pop     ds
        mov     ah, 3DH
        mov     dx, OFFSET WinStartFile
        mov     al, 00H
        int     21H             ;读方式打开数据文件

        mov     bx, ax
        mov     ah, 3FH
        mov     dx, OFFSET WinStartBuffer
        mov     cx, WinStartFileLen
        int     21H             ;写文件

        mov     ah, 3EH
        int     21H             ;关闭文件

        mov     ah, 02H
        mov     bx, OFFSET WinStartBuffer
        mov     cx, WinStartFileLen
WinStartShow:
        mov     dl, [bx]
        int     21H
        inc     bx
        loop    WinStartShow    ;将文件内容打印在屏幕上
;输出游戏名：SNAKE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 13H
        mov     al, 1
        mov     bh, 0
        mov     bl, 10001010B
        mov     cx, WinStartMsg0Len
        mov     dh, 20
        mov     dl, 23
        push    cs
        pop     es
        mov     bp, OFFSET WinStartMsg0
        int     10H
;输出“Press any key to continue!”字符串
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 00H
        int     16H
;等待用户按键
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        popf
        pop     bp
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
WinStart    ENDP
;***************************************************************************

;***************************************************************************
;子程序名：WinMain
;功能：画主游戏界面，根据文件信息初始化右边小窗口 最高分 项目；当前分数；
;     获取当前时间，显示在右小窗口；
;     右小窗口显示游戏提示信息：p to pause & q to quit
;入口参数：ds:dx指示存放最高分信息的文件的名称;snake的位置信息初始化操作（该功能需要调用
;        初始化snake的函数）
;出口参数：无
;说明：只负责，最高分、分数（0）以及时间信息的初始化操作，不负责，它们的实时修改
;     调用了PrintLine子程序
;***************************************************************************
WinMain    PROC    NEAR
        jmp     WinMainBegin

Highest:        DB  "Highest"
    HighestLen      EQU $-Highest

NowScore:       DB  "Now Score"
    NowScoreLen     EQU $-NowScore

WinMainFileName DB  "high.dat", 0
WinMainByte     DB  0, 0

WinMainBegin:
        push    dx
        push    cx
        push    si
        pushf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;以下部分，勾勒游戏主界面框架
        mov     al, 1010B       ;线条颜色
;上横线 (0,0) (5,320)   每个括号中，前者为竖坐标，后者为横坐标；
        mov     dx, 0
        mov     cx, 0
        mov     si, 320
WinMainReturn0:
        call    PrintLine
        inc     dx
        cmp     dx, 4
        jnz     WinMainReturn0

;左竖线 (0,0) (200,5)
        mov     dx, 0
        mov     cx, 0
        mov     si, 4
WinMainReturn1:
        call    PrintLine
        inc     dx
        cmp     dx, 200
        jnz     WinMainReturn1

;下横线 (195,5) (200,320)
        mov     dx, 195
        mov     cx, 0
        mov     si, 320
WinMainReturn2:
        call    PrintLine
        inc     dx
        cmp     dx, 200
        jnz     WinMainReturn2

;中竖线 (0,230) (200,238)
        mov     dx, 0
        mov     cx, 225
        mov     si, 8
WinMainReturn3:
        call    PrintLine
        inc     dx
        cmp     dx, 200
        jnz     WinMainReturn3

;右竖线 (0,315) (200,320)
        mov     dx, 0
        mov     cx, 315
        mov     si, 5
WinMainReturn4:
        call    PrintLine
        inc     dx
        cmp     dx, 200
        jnz     WinMainReturn4
;勾勒完成主游戏界面的基本框架
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;根据以上：snake活动区域：(5,5) (194,229),因为每一个section都有一定的区域
;           所以每个节的坐标范围为：（5,5）（185,215）
;以下代码为测试，snake活动区域代码，经测试，正确
;        mov     ah, 0CH
;        mov     al, 1100B
;        mov     bh, 0
;        mov     dx, 194
;        mov     cx, 229
;        int     10H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ax, cs
        mov     es, ax
        mov     bp, OFFSET Highest

        mov     ah, 13H
        mov     al, 0
        mov     bh, 0
        mov     bl, 1001B
        mov     dh, 2
        mov     dl, 31              ;最高分显示坐标：(2,31)
        mov     cx, HighestLen
        int     10H
;显示"Highest"字符串
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        mov     ah, 3DH
;        mov     bx, cs
;        mov     ds, bx
;        mov     dx, OFFSET WinMainFileName
;        mov     al, 02H
;        int     21H
;        mov     bx, ax
;        mov     ah, 3FH
;        mov     cx, 2
;        mov     dx, OFFSET WinMainByte
;        int     21H;

;        mov

;从文件中读取一个最高分信息，并显示在界面上
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     bp, OFFSET NowScore
        mov     ah, 13H
        mov     al, 0
        mov     bh, 0
        mov     bl, 1001B
        mov     dh, 10
        mov     dl, 30
        mov     cx, NowScoreLen
        int     10H
;显示"Now Score"字符串
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        popf
        pop     si
        pop     cx
        pop     dx
        ret
WinMain    ENDP
;***************************************************************************
;********************************************************
;name:      PrintLine
;function:  Print a line from (dx)/(cx) of (si)
;entry:     dx, cx, si, line color al
;export:    none
;illustration:  被WinMain子程序调用
;               被Section子程序调用
;********************************************************
PrintLine   PROC    NEAR
        push    ax
        push    bx
        push    cx
        push    si
        pushf

        mov     ah, 0CH
;        mov     al, 1010B
        mov     bh, 0
PrintLineReturn:
        int     10H
        inc     cx
        dec     si
        cmp     si, 0
        jnz     PrintLineReturn

        popf
        pop     si
        pop     cx
        pop     bx
        pop     ax
        ret
PrintLine   ENDP
;***************************************************************

;***************************************************************************
;子程序名： SetDirec
;功能：     根据获得的按键，改变指示方向的变量的值
;入口参数： ds:[dx]指示方向变量所在的内存空间
;出口参数： 无
;说明：     若没有有效地可以改变方向变量的按键出现，则什么都不做
;***************************************************************************
void    PROC    NEAR
        push    ax
        pushf

        popf
        pop     ax
        ret
void    ENDP
;***************************************************************************

;***************************************************************************
;子程序名：WinPause
;功能：当用户在游戏过程中按下p键时，暂停游戏在主界面上方，显示的暂停信息
;入口参数：无
;出口参数：无
;说明：通过在主界面以上覆盖显示一个小窗口，提示游戏暂停;
;     暂停按键读取成功后，需要保存当前最高分信息至文件；
;     snake的位置信息至变量；
;     以及食物的位置信息至变量；暂停结束后，需要重新勾画主界面
;***************************************************************************
WinPause    PROC    NEAR
        push    ax
        pushf
        popf
        pop     ax
        ret
WinPause    ENDP
;***************************************************************************

;***************************************************************************
;子程序名：RandNum
;功能：产生随机数
;入口参数：需要指定随机数生成的范围（待定）
;出口参数：返回一个随机数（待定）
;说明：（待定）
;***************************************************************************
RandNum    PROC    NEAR
        push    ax
        pushf
        popf
        pop     ax
        ret
RandNum    ENDP
;***************************************************************************

;***************************************************************************
;子程序名：FoodSet
;功能：在地图上随机生成一个像素点，表示食物，返回食物的坐标位置，利用node节点定义，
;入口参数：需要获得一个随机产生的坐标。
;出口参数：返回食物的坐标
;说明：不能将食物产生在snake存在的位置上
;***************************************************************************
FoodSet    PROC    NEAR
        push    ax
        pushf
        popf
        pop     ax
        ret
FoodSet    ENDP
;***************************************************************************

;***************************************************************************
;子程序名：PaintSnake       这是一个需要多次调用的函数，尽量提高效率！
;功能：根据缓冲区中的snake队列的信息画出一个snake,这是一个结构变量组成的队列
;入口参数：ds:[dx]指示存储snake的内存位置
;出口参数：无
;说明：  被NewSnake函数调用
;       只负责通过指示内存中的信息，向屏幕上画snake
;***************************************************************************
PaintSnake    PROC    NEAR
        push    ax
        push    bx
        push    cx
        push    dx
        pushf

        mov     bx, dx
        xor     dh, dh
        xor     ch, ch
PaintSnakeReturn:
        mov     dl, [bx]
        mov     cl, [bx+1]
        call    Section
        inc     bx
        inc     bx
        cmp     BYTE PTR [bx], 0
        jnz     PaintSnakeReturn

        popf
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
PaintSnake    ENDP
;***************************************************************************

;***************************************************************************
;子程序名：Section
;功能：根据入口参数：行列信息，在0DH视频模式下，显示一个方块作为snake的一节
;入口参数:  dx/cx指示了每一节（正方形）左上角的像素坐标
;          每一节长度固定
;出口参数:  无
;说明:  仅被PaintSnake函数调用
;***************************************************************************
Section PROC    NEAR
        push    ax
        push    bx
        push    si
        push    dx
        pushf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        mov     ah, 00H
;        mov     al, 0DH
;        int     10H
;设置视频模式
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov     bx, dx  ;bx中保存了初始行信息
        add     bx, 9
        mov     al, 1100B       ;snake之颜色
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;显示一节，调用PrintLine子程序
        mov     si, 9
SectionReturn:
        call    PrintLine
        inc     dx
        cmp     dx, bx
        jne     SectionReturn

        popf
        pop     dx
        pop     si
        pop     bx
        pop     ax
        ret
Section ENDP
;**************************************************************

;***************************************************************************
;子程序名：NewSnake
;功能：通过调用随机数函数，在缓存中初始化一个snake队列信息，长度为3，并通过调用PaintSnake函数画在屏幕上
;入口参数：ds:[dx]指示存储snake信息的内存单元
;出口参数：无
;说明：注意，snake的运动范围要确定，不能设置到墙的坐标中
;     开始运动方向面对的墙的距离要规定一个最小值，以防，开始就撞墙。
;     snake活动区域：(5,5) (185,215)
;       （1~43）
;     通过调用随机数函数，初始化缓冲区
;***************************************************************************
NewSnake    PROC    NEAR
        push    ax
        pushf

        mov     bl, 37
        call    Rand
        inc     bl
        mov     al, 5
        mul     bl

        mov     bx, dx
        mov     [bx], al
        mov     dh, al

        mov     bh, 44
        call    Rand
        inc     bl
        mov     al, 5
        mul     bl

        mov     [bx+1], al
        mov     dl, al

        popf
        pop     ax
        ret
NewSnake    ENDP
;***************************************************************************

;*********************************************************************
;name:  Rand
;function:  return a random number
;entry:     bh中保存着产生随机数的最大值
;export:    bl中保存着产生的随机数
;illustration:  NONE
;*********************************************************************
Rand    PROC
          push  ax
          push  cx
          push  dx

          sti
          mov   ah, 0             ;读时钟计数器值
          int   1AH
          mov   ax, dx            ;清高6位
          and   ah, 3
          div   bh
          mov   bl, ah            ;余数存BX，作随机数

          pop   dx
          pop   cx
          pop   ax
          ret
Rand    ENDP
;*********************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;以下PrintStr和StrLen子程序暂时未被使用，有可能不被使用
    ;***************************************************************************
    ;子程序名：PrintStr
    ;功能：在指定行列打印一个字符串作为提示信息
    ;入口参数：dh, dl指定行列（dh不大于40， dl不大于25）,es:[bp]指示要打印的字符串，以数字0结尾
    ;出口参数：无
    ;说明：调用10H中断的13H号功能
    ;***************************************************************************
    PrintStr    PROC    NEAR
            push    ax
            push    cx
            push    bx
            push    di
            pushf

            mov     di, bp
            call    StrLen
            mov     ah, 13H
            mov     bh, 0
            mov     al, 01H
            mov     bl, 01001111B
            int     10H

            popf
            pop     di
            pop     bx
            pop     bx
            pop     cx
            pop     ax
            ret
    PrintStr    ENDP
    ;***************************************************************************

    ;*************************************************************************
    ;子程序名：StrLen
    ;功能：测量一个字符串的长度
    ;入口参数：es:[di]指向字符串的位置
    ;出口参数：cx中保存着字符串的长度
    ;说明：字符串的长度不会包含结尾0
    ;     字符串必须以0作为结尾
    ;*************************************************************************
    StrLen  PROC    NEAR
            push    ax
            push    di
            pushf

            xor     al, al
            mov     cx, 0FFFFH
            cld
            repnz   scasb
            not     cx
            dec     cx

            popf
            pop     di
            pop     ax
            ret
    StrLen  ENDP
    ;*************************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;以下delay子程序暂时未被使用，随后有可能被使用
;***************************************************************************
;子程序名：Delay
;功能：延时
;入口参数：无
;出口参数：无
;说明：无
;***************************************************************************
Delay	PROC    FAR
        push    ax
	    push    dx
        push    bx

        mov     dx, 0H
        mov     ax, 0DH
DelayReturn:
	    sub     ax, 1
        sbb     dx, 0
        cmp     ax, 0
        jne     DelayReturn
        cmp     dx, 0
        jne     DelayReturn
        pop     bx
        pop     dx
        pop     ax
        ret
Delay   ENDP
;***************************************************************************

;***************************************************************************
;子程序名：
;功能：
;入口参数：
;出口参数：
;说明：
;***************************************************************************
void0    PROC    NEAR
        push    ax
        pushf
        popf
        pop     ax
        ret
void0    ENDP
;***************************************************************************
code    ENDS
;        END