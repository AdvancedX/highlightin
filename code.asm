IOY0        EQU 0600H        ; 定义IO端口的基地址

; 定义8255芯片的端口地址
MY8255_A    EQU IOY0 + 00H * 2   ; Port A
MY8255_B    EQU IOY0 + 01H * 2   ; Port B
MY8255_C    EQU IOY0 + 02H * 2   ; Port C
MY8255_MODE EQU IOY0 + 03H * 2   ; 控制寄存器

SSTACK      SEGMENT STACK       ; 定义栈段
    DW 32 DUP(?)                ; 分配32个字节的栈空间
SSTACK ENDS

DATA SEGMENT                   ; 数据段
    DTABLE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H  ; 7段数码管显示的16进制数据表
    WEI1   DB 0                 ; 数码管的第一位
    WEI2   DB 0                 ; 数码管的第二位
    WEI3   DB 0                 ; 数码管的第三位
    RUN    DW 0                 ; 程序运行标志
    FF     DW 0                 ; 用于标志中断是否发生
DATA ENDS
CODE SEGMENT 0                   ; 代码段声明
ASSUME CS:CODE,DS:DATA,SS:SSTACK ; 段寄存器的假设

START:                           ; 程序入口
    PUSH DS                      ; 保存数据段寄存器
    MOV AX, 0000H                ; 将0赋值给AX寄存器
    MOV DS, AX                   ; 将DS寄存器设置为0

    ; 初始化MIR7向量
    MOV AX, OFFSET MIR7          ; 将MIR7的偏移地址加载到AX寄存器
    MOV SI, 003CH                 ; 设置SI寄存器，指向IDT的MIR7入口
    MOV [SI], AX                 ; 将MIR7的偏移地址写入IDT表中

    MOV AX, CS                    ; 将代码段的段地址加载到AX寄存器
    MOV SI, 003EH                 ; 设置SI寄存器，指向IDT的MIR7入口的段地址
    MOV [SI], AX                 ; 将代码段的段地址写入IDT表中

    STI                           ; 启用中断

    POP DS                       ; 恢复数据段寄存器
    MOV DX, MY8255_MODE          ; 将8255的模式寄存器地址加载到DX寄存器
    MOV AL, 81H                   ; 将81H加载到AL寄存器
    OUT DX, AL                   ; 将AL寄存器的值写入8255的模式寄存器

    ; 初始化中断控制器
    MOV AL, 11H                   ; 初始化控制字节1
    OUT 20H, AL                   ; 将AL寄存器的值写入主片的控制端口
    MOV AL, 08H                   ; 初始化控制字节2
    OUT 21H, AL                   ; 将AL寄存器的值写入主片的数据端口
    MOV AL, 04H                   ; 初始化控制字节3
    OUT 21H, AL                   ; 将AL寄存器的值写入主片的数据端口
    MOV AL, 01H                   ; 初始化控制字节4
    OUT 21H, AL                   ; 将AL寄存器的值写入主片的数据端口
    MOV AL, 6FH                   ; 屏蔽IRQ0（时钟中断）以允许中断嵌套
    OUT 21H, AL                   ; 将AL寄存器的值写入主片的数据端口

    MOV AX, DATA                 ; 将数据段地址加载到AX寄存器
    MOV DS, AX                   ; 将DS寄存器设置为数据段地址
    MOV SI, 3000H                ; 设置SI寄存器，指向数据段中的一个地址
    MOV AL, 00H                  ; 将00H加载到AL寄存器
    MOV [SI + 1], AL              ; 将AL寄存器的值写入指定地址
    MOV AL, 00H                  ; 将00H加载到AL寄存器
    MOV [SI + 2], AL              ; 将AL寄存器的值写入指定地址
    MOV [SI + 3], AL              ; 将AL寄存器的值写入指定地址
    MOV AL, 0FH                  ; 将0FH加载到AL寄存器
    MOV [SI], AL                 ; 将AL寄存器的值写入指定地址

    MOV DI, 3002H                ; 设置DI寄存器，指向数据段中的另一个地址
    CLI                           ; 关闭中断

BEGIN:
    CALL DIS            ; 调用DIS子程序
    CMP WEI3, 10H        ; 比较WEI3与10H的值
    JB CUT               ; 如果WEI3小于10H，则跳转到CUT标签
    MOV WEI3, 00H        ; 如果WEI3大于等于10H，则将WEI3重置为00H
CUT:
    CALL KEYSCAN        ; 调用KEYSCAN子程序
    JNZ GETKEY1         ; 如果ZF标志位为0，跳转到GETKEY1标签
    JMP BEGIN           ; 如果ZF标志位为1，无键按下，跳转回BEGIN标签

KEYSCAN:
    MOV AL, 01H          ; 将01H加载到AL寄存器
    MOV DX, MY8255_A     ; 将MY8255_A的地址加载到DX寄存器
    OUT DX, AL           ; 将AL寄存器的值写入MY8255_A，设置为01H
    MOV DX, MY8255_C     ; 将MY8255_C的地址加载到DX寄存器
    IN AL, DX            ; 从MY8255_C读取数据到AL寄存器
    AND AL, 0FH          ; 将AL寄存器的高四位清零
    XOR AL, 0FH          ; 将AL寄存器的低四位取反
    RET                  ; 返回到调用KEYSCAN的地址

GETKEY1:
    CALL DIS           ; 调用DIS子程序
    CALL DELAY         ; 调用DELAY子程序
    CALL KEYSCAN       ; 调用KEYSCAN子程序
    JNZ GETKEY2        ; 如果ZF标志位为0，跳转到GETKEY2标签
    RET                ; 如果ZF标志位为1，无键按下，返回

GETKEY2:
    MOV AX, 0001H      ; 将0001H加载到AX寄存器
    MOV DX, MY8255_A   ; 将MY8255_A的地址加载到DX寄存器
    OUT DX, AL         ; 将AL寄存器的值写入MY8255_A，设置为0001H
    MOV DX, MY8255_C   ; 将MY8255_C的地址加载到DX寄存器
    IN AL, DX          ; 从MY8255_C读取数据到AL寄存器

L1:
    TEST AL, 01H       ; 测试AL寄存器的最低位
    JNZ L2             ; 如果最低位为1，跳转到L2标签
    STI                ; 启用中断
    JMP KON            ; 跳转到KON标签

L2:
    TEST AL, 02H       ; 测试AL寄存器的次低位
    JNZ L3             ; 如果次低位为1，跳转到L3标签
    CLI                ; 关闭中断
    CALL KON           ; 调用KON子程序

L3:
    TEST AL, 04H       ; 测试AL寄存器的第3位
    JNZ L4             ; 如果第3位为1，跳转到L4标签
    CLI                ; 关闭中断
    JMP RESET          ; 跳转到RESET标签

L4:
    TEST AL, 08H       ; 测试AL寄存器的第4位
    CALL STOP_MOTOR    ; 调用STOP_MOTOR子程序
    JMP KON            ; 跳转到KON标签

RESET:
    PUSH AX            ; 保存AX寄存器的值
    MOV AL, 0          ; 将0加载到AL寄存器
    MOV WEI1, AL       ; 将AL寄存器的值赋给WEI1
    MOV AX, 0          ; 将0加载到AX寄存器
    MOV FF, AX         ; 将AX寄存器的值赋给FF
    MOV RUN, AX        ; 将AX寄存器的值赋给RUN
    MOV WEI2, AL       ; 将AL寄存器的值赋给WEI2
    MOV WEI3, AL       ; 将AL寄存器的值赋给WEI3
    POP AX             ; 恢复AX寄存器的值
    CALL PUTBUF        ; 调用PUTBUF子程序

KON:
    CALL DIS           ; 调用DIS子程序
    CALL CLEAR         ; 调用CLEAR子程序
    CALL KEYSCAN       ; 调用KEYSCAN子程序
    JNZ KON            ; 如果ZF标志位为0，表示有键按下，继续循环
    POP AX             ; 弹出栈中的AX寄存器的值
    JMP BEGIN          ; 跳转到BEGIN标签

PUTBUF:
    MOV SI, 3000H      ; 设置SI寄存器，指向数据段中的一个地址
    MOV AL, 00H        ; 将00H加载到AL寄存器
    MOV [SI + 1], AL    ; 将AL寄存器的值写入指定地址
    MOV AL, 00H        ; 将00H加载到AL寄存器
    MOV [SI + 2], AL    ; 将AL寄存器的值写入指定地址
    MOV [SI + 3], AL    ; 将AL寄存器的值写入指定地址
    MOV AL, 0FH        ; 将0FH加载到AL寄存器
    MOV [SI], AL       ; 将AL寄存器的值写入指定地址
    RET                ; 返回到调用PUTBUF的地址

YELLOW:
    PUSH AX            ; 保存AX寄存器的值
    PUSH DX            ; 保存DX寄存器的值
    ADD AL, 40H        ; 将AL寄存器的值加上40H
    MOV DX, MY8255_C   ; 将MY8255_C的地址加载到DX寄存器
    OUT DX, AL         ; 将AL寄存器的值写入MY8255_C，设置为黄色
    POP DX             ; 恢复DX寄存器的值
    POP AX             ; 恢复AX寄存器的值
    JMP OK             ; 跳转到OK标签

RED:
    PUSH AX            ; 保存AX寄存器的值
    PUSH DX            ; 保存DX寄存器的值
    ADD AL, 80H        ; 将AL寄存器的值加上80H
    MOV DX, MY8255_C   ; 将MY8255_C的地址加载到DX寄存器
    OUT DX, AL         ; 将AL寄存器的值写入MY8255_C，设置为红色
    POP DX             ; 恢复DX寄存器的值
    POP AX             ; 恢复AX寄存器的值

OFF:
    CMP WEI3, 1       ; 比较WEI3和1
    JNZ A1            ; 如果不等于1，跳转到A1标签
    JMP NO            ; 跳转到NO标签

A1:
    CLI               ; 关闭中断
    JMP RESET         ; 跳转到RESET标签

MIR7:
    CMP WEI1, 0       ; 比较WEI1和0
    JNL YELLOW        ; 如果不小于0，跳转到YELLOW标签
OK:
    CMP WEI3, 0       ; 比较WEI3和0
    JA RED            ; 如果大于0，跳转到RED标签
    
NO:
    PUSH  AX          ; 保存AX寄存器的值
    PUSH  SI          ; 保存SI寄存器的值
    MOV  AX,FF         ; 将FF加载到AX寄存器
    INC  AX           ; AX寄存器的值加1
    MOV  FF,AX        ; 将AX寄存器的值写入FF
    CMP  AX,300        ; 比较AX和300
    JB   BREAK        ; 如果不小于300，跳转到BREAK标签
    
    MOV  AX,RUN        ; 将RUN加载到AX寄存器
    INC  AX           ; AX寄存器的值加1
    MOV  RUN,AX       ; 将AX寄存器的值写入RUN
    CMP  AX,100        ; 比较AX和100
    JB   BREAK        ; 如果不小于100，跳转到BREAK标签
    MOV  AX,0          ; 将0加载到AX寄存器
    MOV  RUN,AX       ; 将AX寄存器的值写入RUN
    
    MOV  AL,WEI1       ; 将WEI1加载到AL寄存器
    ADD  AL,10         ; AL寄存器的值加上10
    DAA                ; 十进制调整
    MOV  WEI1,AL       ; 将AL寄存器的值写入WEI1

    CMP  AL,10H        ; 比较AL和10H
    JB   MOVEIN        ; 如果不大于等于10H，跳转到MOVEIN标签
    AND  AL,0FH        ; 将AL寄存器的高四位清零
    MOV  WEI1,AL       ; 将AL寄存器的值写入WEI1
    MOV  AL,WEI2       ; 将WEI2加载到AL寄存器
    ADD  AL,1          ; AL寄存器的值加1
    DAA                ; 十进制调整
    MOV  WEI2,AL       ; 将AL寄存器的值写入WEI2

    CMP  AL,10H        ; 比较AL和10H
    JB   MOVEIN        ; 如果不大于等于10H，跳转到MOVEIN标签
    AND  AL,0FH        ; 将AL寄存器的高四位清零
    MOV  WEI2,AL       ; 将AL寄存器的值写入WEI2
    MOV  AL,WEI3       ; 将WEI3加载到AL寄存器
    ADD  AL,1          ; AL寄存器的值加1
    DAA                ; 十进制调整
    MOV  WEI3,AL       ; 将AL寄存器的值写入WEI3

MOVEIN: 
    MOV  SI,3000H      ; 设置SI寄存器，指向数据段中的一个地址
    MOV  AL,WEI1       ; 将WEI1加载到AL寄存器
    AND  AL,0FH        ; 将AL寄存器的高四位清零
    MOV  [SI+1],AL     ; 将AL寄存器的值写入指定地址
    MOV  AL,WEI2       ; 将WEI2加载到AL寄存器
    AND  AL,0FH        ; 将AL寄存器的高四位清零
    MOV  [SI+2],AL     ; 将AL寄存器的值写入指定地址
    MOV  AL,WEI3       ; 将WEI3加载到AL寄存器
    AND  AL,0FH        ; 将AL寄存器的高四位清零
    MOV  [SI+3],AL     ; 将AL寄存器的值写入指定地址

BREAK: 
    MOV AL, 20H        ; 将20H加载到AL寄存器
    OUT 20H, AL        ; 将AL寄存器的值写入20H端口
    POP SI             ; 弹出栈中的SI寄存器的值
    POP AX             ; 弹出栈中的AX寄存器的值
    CALL DIS           ; 调用DIS子程序
    IRET               ; 中断返回

CLEAR: 
    MOV DX,MY8255_B    ; 将MY8255_B的地址加载到DX寄存器
    MOV AX,00H         ; 将00H加载到AX寄存器
    OUT DX,AX          ; 将AX寄存器的值写入MY8255_B，清空输出
    RET                ; 返回

DIS:  
    PUSH   AX          ; 保存AX寄存器的值
    MOV   SI,3000H     ; 设置SI寄存器，指向数据段中的一个地址
    MOV   DL,0DFH      ; 设置DL寄存器的值为0DFH（二进制11011111）
    MOV   AL,DL        ; 将DL寄存器的值加载到AL寄存器
AGAIN:  
    PUSH   DX          ; 保存DX寄存器的值
    MOV   DX,MY8255_A  ; 将MY8255_A的地址加载到DX寄存器
    OUT   DX,AL        ; 将AL寄存器的值写入MY8255_A，设置输出
    MOV   AL,[SI]      ; 从数据段指定地址读取数据到AL寄存器
    MOV   BX,OFFSET DTABLE  ; 设置BX寄存器，指向数据段中的DTABLE
    AND   AX,00FFH     ; 将AX寄存器的高八位清零
    ADD   BX,AX        ; 将BX寄存器的值设置为DTABLE中的偏移地址
    MOV   AL,[BX]      ; 从DTABLE读取数据到AL寄存器
    MOV   DX,MY8255_B  ; 将MY8255_B的地址加载到DX寄存器
    OUT   DX,AL        ; 将AL寄存器的值写入MY8255_B，设置显示
    CALL  DELAY        ; 调用DELAY子程序，进行延时
    INC   SI           ; SI寄存器的值加1，指向下一个数据
    POP   DX           ; 恢复DX寄存器的值
    MOV   AL,DL        ; 将DL寄存器的值加载到AL寄存器
    TEST   AL,01H      ; 测试AL寄存器的最低位
    JZ    OUT1        ; 如果最低位为0，跳转到OUT1标签
    ROR   AL,1         ; 将AL寄存器的值向右循环移动1位
    MOV   DL,AL        ; 将AL寄存器的值写入DL寄存器
    JMP   AGAIN        ; 无条件跳转到AGAIN标签
OUT1: 
    POP AX              ; 弹出栈中的AX寄存器的值
    RET                 ; 返回

DELAY:  
    PUSH   CX          ; 保存CX寄存器的值
    MOV  CX,000FH      ; 设置CX寄存器的值为15
T1: 
    MOV  AX,002FH      ; 设置AX寄存器的值为47
T2: 
    DEC   AX           ; AX寄存器的值减1
    JNZ    T2          ; 如果AX寄存器的值不为0，跳转到T2标签
    LOOP  T1           ; CX寄存器的值减1，如果不为0，跳转到T1标签
    POP  CX            ; 弹出栈中的CX寄存器的值
    RET                ; 返回

STOP_MOTOR:
    MOV  AL,00H        ; 将AL寄存器的值设置为0
    MOV  DX,MY8255_A   ; 将MY8255_A的地址加载到DX寄存器
    OUT  DX,AL         ; 将AL寄存器的值写入MY8255_A，停止电机
CODE ENDS
    END START
