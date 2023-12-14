IOY0        EQU 0600H        ; ����IO�˿ڵĻ���ַ

; ����8255оƬ�Ķ˿ڵ�ַ
MY8255_A    EQU IOY0 + 00H * 2   ; Port A
MY8255_B    EQU IOY0 + 01H * 2   ; Port B
MY8255_C    EQU IOY0 + 02H * 2   ; Port C
MY8255_MODE EQU IOY0 + 03H * 2   ; ���ƼĴ���

SSTACK      SEGMENT STACK       ; ����ջ��
    DW 32 DUP(?)                ; ����32���ֽڵ�ջ�ռ�
SSTACK ENDS

DATA SEGMENT                   ; ���ݶ�
    DTABLE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H  ; 7���������ʾ��16�������ݱ�
    WEI1   DB 0                 ; ����ܵĵ�һλ
    WEI2   DB 0                 ; ����ܵĵڶ�λ
    WEI3   DB 0                 ; ����ܵĵ���λ
    RUN    DW 0                 ; �������б�־
    FF     DW 0                 ; ���ڱ�־�ж��Ƿ���
DATA ENDS
CODE SEGMENT 0                   ; ���������
ASSUME CS:CODE,DS:DATA,SS:SSTACK ; �μĴ����ļ���

START:                           ; �������
    PUSH DS                      ; �������ݶμĴ���
    MOV AX, 0000H                ; ��0��ֵ��AX�Ĵ���
    MOV DS, AX                   ; ��DS�Ĵ�������Ϊ0

    ; ��ʼ��MIR7����
    MOV AX, OFFSET MIR7          ; ��MIR7��ƫ�Ƶ�ַ���ص�AX�Ĵ���
    MOV SI, 003CH                 ; ����SI�Ĵ�����ָ��IDT��MIR7���
    MOV [SI], AX                 ; ��MIR7��ƫ�Ƶ�ַд��IDT����

    MOV AX, CS                    ; ������εĶε�ַ���ص�AX�Ĵ���
    MOV SI, 003EH                 ; ����SI�Ĵ�����ָ��IDT��MIR7��ڵĶε�ַ
    MOV [SI], AX                 ; ������εĶε�ַд��IDT����

    STI                           ; �����ж�

    POP DS                       ; �ָ����ݶμĴ���
    MOV DX, MY8255_MODE          ; ��8255��ģʽ�Ĵ�����ַ���ص�DX�Ĵ���
    MOV AL, 81H                   ; ��81H���ص�AL�Ĵ���
    OUT DX, AL                   ; ��AL�Ĵ�����ֵд��8255��ģʽ�Ĵ���

    ; ��ʼ���жϿ�����
    MOV AL, 11H                   ; ��ʼ�������ֽ�1
    OUT 20H, AL                   ; ��AL�Ĵ�����ֵд����Ƭ�Ŀ��ƶ˿�
    MOV AL, 08H                   ; ��ʼ�������ֽ�2
    OUT 21H, AL                   ; ��AL�Ĵ�����ֵд����Ƭ�����ݶ˿�
    MOV AL, 04H                   ; ��ʼ�������ֽ�3
    OUT 21H, AL                   ; ��AL�Ĵ�����ֵд����Ƭ�����ݶ˿�
    MOV AL, 01H                   ; ��ʼ�������ֽ�4
    OUT 21H, AL                   ; ��AL�Ĵ�����ֵд����Ƭ�����ݶ˿�
    MOV AL, 6FH                   ; ����IRQ0��ʱ���жϣ��������ж�Ƕ��
    OUT 21H, AL                   ; ��AL�Ĵ�����ֵд����Ƭ�����ݶ˿�

    MOV AX, DATA                 ; �����ݶε�ַ���ص�AX�Ĵ���
    MOV DS, AX                   ; ��DS�Ĵ�������Ϊ���ݶε�ַ
    MOV SI, 3000H                ; ����SI�Ĵ�����ָ�����ݶ��е�һ����ַ
    MOV AL, 00H                  ; ��00H���ص�AL�Ĵ���
    MOV [SI + 1], AL              ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV AL, 00H                  ; ��00H���ص�AL�Ĵ���
    MOV [SI + 2], AL              ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV [SI + 3], AL              ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV AL, 0FH                  ; ��0FH���ص�AL�Ĵ���
    MOV [SI], AL                 ; ��AL�Ĵ�����ֵд��ָ����ַ

    MOV DI, 3002H                ; ����DI�Ĵ�����ָ�����ݶ��е���һ����ַ
    CLI                           ; �ر��ж�

BEGIN:
    CALL DIS            ; ����DIS�ӳ���
    CMP WEI3, 10H        ; �Ƚ�WEI3��10H��ֵ
    JB CUT               ; ���WEI3С��10H������ת��CUT��ǩ
    MOV WEI3, 00H        ; ���WEI3���ڵ���10H����WEI3����Ϊ00H
CUT:
    CALL KEYSCAN        ; ����KEYSCAN�ӳ���
    JNZ GETKEY1         ; ���ZF��־λΪ0����ת��GETKEY1��ǩ
    JMP BEGIN           ; ���ZF��־λΪ1���޼����£���ת��BEGIN��ǩ

KEYSCAN:
    MOV AL, 01H          ; ��01H���ص�AL�Ĵ���
    MOV DX, MY8255_A     ; ��MY8255_A�ĵ�ַ���ص�DX�Ĵ���
    OUT DX, AL           ; ��AL�Ĵ�����ֵд��MY8255_A������Ϊ01H
    MOV DX, MY8255_C     ; ��MY8255_C�ĵ�ַ���ص�DX�Ĵ���
    IN AL, DX            ; ��MY8255_C��ȡ���ݵ�AL�Ĵ���
    AND AL, 0FH          ; ��AL�Ĵ����ĸ���λ����
    XOR AL, 0FH          ; ��AL�Ĵ����ĵ���λȡ��
    RET                  ; ���ص�����KEYSCAN�ĵ�ַ

GETKEY1:
    CALL DIS           ; ����DIS�ӳ���
    CALL DELAY         ; ����DELAY�ӳ���
    CALL KEYSCAN       ; ����KEYSCAN�ӳ���
    JNZ GETKEY2        ; ���ZF��־λΪ0����ת��GETKEY2��ǩ
    RET                ; ���ZF��־λΪ1���޼����£�����

GETKEY2:
    MOV AX, 0001H      ; ��0001H���ص�AX�Ĵ���
    MOV DX, MY8255_A   ; ��MY8255_A�ĵ�ַ���ص�DX�Ĵ���
    OUT DX, AL         ; ��AL�Ĵ�����ֵд��MY8255_A������Ϊ0001H
    MOV DX, MY8255_C   ; ��MY8255_C�ĵ�ַ���ص�DX�Ĵ���
    IN AL, DX          ; ��MY8255_C��ȡ���ݵ�AL�Ĵ���

L1:
    TEST AL, 01H       ; ����AL�Ĵ��������λ
    JNZ L2             ; ������λΪ1����ת��L2��ǩ
    STI                ; �����ж�
    JMP KON            ; ��ת��KON��ǩ

L2:
    TEST AL, 02H       ; ����AL�Ĵ����Ĵε�λ
    JNZ L3             ; ����ε�λΪ1����ת��L3��ǩ
    CLI                ; �ر��ж�
    CALL KON           ; ����KON�ӳ���

L3:
    TEST AL, 04H       ; ����AL�Ĵ����ĵ�3λ
    JNZ L4             ; �����3λΪ1����ת��L4��ǩ
    CLI                ; �ر��ж�
    JMP RESET          ; ��ת��RESET��ǩ

L4:
    TEST AL, 08H       ; ����AL�Ĵ����ĵ�4λ
    CALL STOP_MOTOR    ; ����STOP_MOTOR�ӳ���
    JMP KON            ; ��ת��KON��ǩ

RESET:
    PUSH AX            ; ����AX�Ĵ�����ֵ
    MOV AL, 0          ; ��0���ص�AL�Ĵ���
    MOV WEI1, AL       ; ��AL�Ĵ�����ֵ����WEI1
    MOV AX, 0          ; ��0���ص�AX�Ĵ���
    MOV FF, AX         ; ��AX�Ĵ�����ֵ����FF
    MOV RUN, AX        ; ��AX�Ĵ�����ֵ����RUN
    MOV WEI2, AL       ; ��AL�Ĵ�����ֵ����WEI2
    MOV WEI3, AL       ; ��AL�Ĵ�����ֵ����WEI3
    POP AX             ; �ָ�AX�Ĵ�����ֵ
    CALL PUTBUF        ; ����PUTBUF�ӳ���

KON:
    CALL DIS           ; ����DIS�ӳ���
    CALL CLEAR         ; ����CLEAR�ӳ���
    CALL KEYSCAN       ; ����KEYSCAN�ӳ���
    JNZ KON            ; ���ZF��־λΪ0����ʾ�м����£�����ѭ��
    POP AX             ; ����ջ�е�AX�Ĵ�����ֵ
    JMP BEGIN          ; ��ת��BEGIN��ǩ

PUTBUF:
    MOV SI, 3000H      ; ����SI�Ĵ�����ָ�����ݶ��е�һ����ַ
    MOV AL, 00H        ; ��00H���ص�AL�Ĵ���
    MOV [SI + 1], AL    ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV AL, 00H        ; ��00H���ص�AL�Ĵ���
    MOV [SI + 2], AL    ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV [SI + 3], AL    ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV AL, 0FH        ; ��0FH���ص�AL�Ĵ���
    MOV [SI], AL       ; ��AL�Ĵ�����ֵд��ָ����ַ
    RET                ; ���ص�����PUTBUF�ĵ�ַ

YELLOW:
    PUSH AX            ; ����AX�Ĵ�����ֵ
    PUSH DX            ; ����DX�Ĵ�����ֵ
    ADD AL, 40H        ; ��AL�Ĵ�����ֵ����40H
    MOV DX, MY8255_C   ; ��MY8255_C�ĵ�ַ���ص�DX�Ĵ���
    OUT DX, AL         ; ��AL�Ĵ�����ֵд��MY8255_C������Ϊ��ɫ
    POP DX             ; �ָ�DX�Ĵ�����ֵ
    POP AX             ; �ָ�AX�Ĵ�����ֵ
    JMP OK             ; ��ת��OK��ǩ

RED:
    PUSH AX            ; ����AX�Ĵ�����ֵ
    PUSH DX            ; ����DX�Ĵ�����ֵ
    ADD AL, 80H        ; ��AL�Ĵ�����ֵ����80H
    MOV DX, MY8255_C   ; ��MY8255_C�ĵ�ַ���ص�DX�Ĵ���
    OUT DX, AL         ; ��AL�Ĵ�����ֵд��MY8255_C������Ϊ��ɫ
    POP DX             ; �ָ�DX�Ĵ�����ֵ
    POP AX             ; �ָ�AX�Ĵ�����ֵ

OFF:
    CMP WEI3, 1       ; �Ƚ�WEI3��1
    JNZ A1            ; ���������1����ת��A1��ǩ
    JMP NO            ; ��ת��NO��ǩ

A1:
    CLI               ; �ر��ж�
    JMP RESET         ; ��ת��RESET��ǩ

MIR7:
    CMP WEI1, 0       ; �Ƚ�WEI1��0
    JNL YELLOW        ; �����С��0����ת��YELLOW��ǩ
OK:
    CMP WEI3, 0       ; �Ƚ�WEI3��0
    JA RED            ; �������0����ת��RED��ǩ
    
NO:
    PUSH  AX          ; ����AX�Ĵ�����ֵ
    PUSH  SI          ; ����SI�Ĵ�����ֵ
    MOV  AX,FF         ; ��FF���ص�AX�Ĵ���
    INC  AX           ; AX�Ĵ�����ֵ��1
    MOV  FF,AX        ; ��AX�Ĵ�����ֵд��FF
    CMP  AX,300        ; �Ƚ�AX��300
    JB   BREAK        ; �����С��300����ת��BREAK��ǩ
    
    MOV  AX,RUN        ; ��RUN���ص�AX�Ĵ���
    INC  AX           ; AX�Ĵ�����ֵ��1
    MOV  RUN,AX       ; ��AX�Ĵ�����ֵд��RUN
    CMP  AX,100        ; �Ƚ�AX��100
    JB   BREAK        ; �����С��100����ת��BREAK��ǩ
    MOV  AX,0          ; ��0���ص�AX�Ĵ���
    MOV  RUN,AX       ; ��AX�Ĵ�����ֵд��RUN
    
    MOV  AL,WEI1       ; ��WEI1���ص�AL�Ĵ���
    ADD  AL,10         ; AL�Ĵ�����ֵ����10
    DAA                ; ʮ���Ƶ���
    MOV  WEI1,AL       ; ��AL�Ĵ�����ֵд��WEI1

    CMP  AL,10H        ; �Ƚ�AL��10H
    JB   MOVEIN        ; ��������ڵ���10H����ת��MOVEIN��ǩ
    AND  AL,0FH        ; ��AL�Ĵ����ĸ���λ����
    MOV  WEI1,AL       ; ��AL�Ĵ�����ֵд��WEI1
    MOV  AL,WEI2       ; ��WEI2���ص�AL�Ĵ���
    ADD  AL,1          ; AL�Ĵ�����ֵ��1
    DAA                ; ʮ���Ƶ���
    MOV  WEI2,AL       ; ��AL�Ĵ�����ֵд��WEI2

    CMP  AL,10H        ; �Ƚ�AL��10H
    JB   MOVEIN        ; ��������ڵ���10H����ת��MOVEIN��ǩ
    AND  AL,0FH        ; ��AL�Ĵ����ĸ���λ����
    MOV  WEI2,AL       ; ��AL�Ĵ�����ֵд��WEI2
    MOV  AL,WEI3       ; ��WEI3���ص�AL�Ĵ���
    ADD  AL,1          ; AL�Ĵ�����ֵ��1
    DAA                ; ʮ���Ƶ���
    MOV  WEI3,AL       ; ��AL�Ĵ�����ֵд��WEI3

MOVEIN: 
    MOV  SI,3000H      ; ����SI�Ĵ�����ָ�����ݶ��е�һ����ַ
    MOV  AL,WEI1       ; ��WEI1���ص�AL�Ĵ���
    AND  AL,0FH        ; ��AL�Ĵ����ĸ���λ����
    MOV  [SI+1],AL     ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV  AL,WEI2       ; ��WEI2���ص�AL�Ĵ���
    AND  AL,0FH        ; ��AL�Ĵ����ĸ���λ����
    MOV  [SI+2],AL     ; ��AL�Ĵ�����ֵд��ָ����ַ
    MOV  AL,WEI3       ; ��WEI3���ص�AL�Ĵ���
    AND  AL,0FH        ; ��AL�Ĵ����ĸ���λ����
    MOV  [SI+3],AL     ; ��AL�Ĵ�����ֵд��ָ����ַ

BREAK: 
    MOV AL, 20H        ; ��20H���ص�AL�Ĵ���
    OUT 20H, AL        ; ��AL�Ĵ�����ֵд��20H�˿�
    POP SI             ; ����ջ�е�SI�Ĵ�����ֵ
    POP AX             ; ����ջ�е�AX�Ĵ�����ֵ
    CALL DIS           ; ����DIS�ӳ���
    IRET               ; �жϷ���

CLEAR: 
    MOV DX,MY8255_B    ; ��MY8255_B�ĵ�ַ���ص�DX�Ĵ���
    MOV AX,00H         ; ��00H���ص�AX�Ĵ���
    OUT DX,AX          ; ��AX�Ĵ�����ֵд��MY8255_B��������
    RET                ; ����

DIS:  
    PUSH   AX          ; ����AX�Ĵ�����ֵ
    MOV   SI,3000H     ; ����SI�Ĵ�����ָ�����ݶ��е�һ����ַ
    MOV   DL,0DFH      ; ����DL�Ĵ�����ֵΪ0DFH��������11011111��
    MOV   AL,DL        ; ��DL�Ĵ�����ֵ���ص�AL�Ĵ���
AGAIN:  
    PUSH   DX          ; ����DX�Ĵ�����ֵ
    MOV   DX,MY8255_A  ; ��MY8255_A�ĵ�ַ���ص�DX�Ĵ���
    OUT   DX,AL        ; ��AL�Ĵ�����ֵд��MY8255_A���������
    MOV   AL,[SI]      ; �����ݶ�ָ����ַ��ȡ���ݵ�AL�Ĵ���
    MOV   BX,OFFSET DTABLE  ; ����BX�Ĵ�����ָ�����ݶ��е�DTABLE
    AND   AX,00FFH     ; ��AX�Ĵ����ĸ߰�λ����
    ADD   BX,AX        ; ��BX�Ĵ�����ֵ����ΪDTABLE�е�ƫ�Ƶ�ַ
    MOV   AL,[BX]      ; ��DTABLE��ȡ���ݵ�AL�Ĵ���
    MOV   DX,MY8255_B  ; ��MY8255_B�ĵ�ַ���ص�DX�Ĵ���
    OUT   DX,AL        ; ��AL�Ĵ�����ֵд��MY8255_B��������ʾ
    CALL  DELAY        ; ����DELAY�ӳ��򣬽�����ʱ
    INC   SI           ; SI�Ĵ�����ֵ��1��ָ����һ������
    POP   DX           ; �ָ�DX�Ĵ�����ֵ
    MOV   AL,DL        ; ��DL�Ĵ�����ֵ���ص�AL�Ĵ���
    TEST   AL,01H      ; ����AL�Ĵ��������λ
    JZ    OUT1        ; ������λΪ0����ת��OUT1��ǩ
    ROR   AL,1         ; ��AL�Ĵ�����ֵ����ѭ���ƶ�1λ
    MOV   DL,AL        ; ��AL�Ĵ�����ֵд��DL�Ĵ���
    JMP   AGAIN        ; ��������ת��AGAIN��ǩ
OUT1: 
    POP AX              ; ����ջ�е�AX�Ĵ�����ֵ
    RET                 ; ����

DELAY:  
    PUSH   CX          ; ����CX�Ĵ�����ֵ
    MOV  CX,000FH      ; ����CX�Ĵ�����ֵΪ15
T1: 
    MOV  AX,002FH      ; ����AX�Ĵ�����ֵΪ47
T2: 
    DEC   AX           ; AX�Ĵ�����ֵ��1
    JNZ    T2          ; ���AX�Ĵ�����ֵ��Ϊ0����ת��T2��ǩ
    LOOP  T1           ; CX�Ĵ�����ֵ��1�������Ϊ0����ת��T1��ǩ
    POP  CX            ; ����ջ�е�CX�Ĵ�����ֵ
    RET                ; ����

STOP_MOTOR:
    MOV  AL,00H        ; ��AL�Ĵ�����ֵ����Ϊ0
    MOV  DX,MY8255_A   ; ��MY8255_A�ĵ�ַ���ص�DX�Ĵ���
    OUT  DX,AL         ; ��AL�Ĵ�����ֵд��MY8255_A��ֹͣ���
CODE ENDS
    END START
