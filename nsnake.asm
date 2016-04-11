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
        ROW   DB  ? ;��
        COL   DB  ? ;��
NODE    ENDS
;��ʾSnake��ÿһ�ε�һ���ṹ��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;ջ��
stack   SEGMENT BYTE STACK
        DW  1024 DUP(0)
stack   ENDS

;main�ļ����ݶ�
data    SEGMENT
;snake�����(5,5) (194,224)
;��ôsnake����ķ�Χ��(5,5),(185,215)
        snake   NODE    <5,5>,<5,215>,<185,5>,<185,215>,<0,0>
        direc   DB      ?   ;0:��    1:��     2:��     3:��
data    ENDS

;main�ļ�����Σ�ʵ��Snake Game���е����̹���
code    SEGMENT
start:  call    WinStart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 00H
        mov     al, 0DH
        int     10H
;������ʾģʽ��Ҳ�൱������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call    WinMain             ;��ʾ������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ax, data
        mov     ds, ax
        mov     dx, OFFSET snake
        call    PaintSnake
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ah, 00H
        int     16H             ;�ȴ��û�����

        mov     ax, 4C00H
        int     21H
code    ENDS
INCLUDE assist.asm
        END start