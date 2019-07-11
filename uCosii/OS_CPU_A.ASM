/*
*********************************************************************************************************
*                                               uC/OS-II
*                                               ʵʱ�ں�
*
*                        (c) Copyright 1992-1998, Jean J. Labrosse, Plantation, FL
*                                               ��Ȩ����
*
*                                            MCU-51 ר�ô���
*                                           KEIL C51��ģʽ����
*
* �ļ��� : OS_CPU_A.ASM
* ����   : Jean J. Labrosse
*********************************************************************************************************
*/

;αָ����ϸ�÷����A51.PDF�ļ�
;����ṹ�����uC/OS-II��193-198ҳ

;���ô���䣡���� $CASE    ;��źͱ��������ִ�Сд

$NOMOD51
EA	BIT	0A8H.7
SP	DATA	081H
B	DATA	0F0H
ACC	DATA	0E0H
DPH	DATA	083H
DPL	DATA	082H
PSW	DATA	0D0H
TR0	BIT	088H.4
TH0	DATA	08CH
TL0	DATA	08AH

        NAME OS_CPU_A    ;ģ����
        
;�����ض�λ��
?PR?OSStartHighRdy?OS_CPU_A    SEGMENT CODE
?PR?OSCtxSw?OS_CPU_A           SEGMENT CODE
?PR?OSIntCtxSw?OS_CPU_A        SEGMENT CODE
?PR?OSTickISR?OS_CPU_A         SEGMENT CODE
?PR?_?serial?OS_CPU_A          SEGMENT CODE
        
;��������ȫ�ֱ������ⲿ�ӳ���
        EXTRN DATA  (?C_XBP)           ;�����ջָ����������ֲ���������,ΪV2.51�ܱ�Cʹ�ö����ڱ�ģ����

        EXTRN IDATA (OSTCBCur)		   ;ָ����������������ƿ��ָ��
        EXTRN IDATA (OSTCBHighRdy)	   ;ָ��������ȼ�����������ָ��
        EXTRN IDATA (OSRunning)		   ;ϵͳ�Ƿ����б�־
        EXTRN IDATA (OSPrioCur)		   ;����������������ȼ�
        EXTRN IDATA (OSPrioHighRdy)	   ;����������ȼ���ľ�����������ȼ�
  
        EXTRN CODE  (_?OSTaskSwHook)   ;ϵͳ�����л�����
        EXTRN CODE  (_?OSIntEnter)	   ;�����жϺ���
        EXTRN CODE  (_?OSIntExit)	   ;�˳��жϺ���
        EXTRN CODE  (_?OSTimeTick)     ;�ں�ϵͳ���ĺ���      
        EXTRN CODE  (_?serial)		   ;�����жϺ���
            
;��������4���������뺯��   �ⲿ��ʹ��
        PUBLIC OSStartHighRdy	  ;����
        PUBLIC OSCtxSw			  ;����
        PUBLIC OSIntCtxSw		  ;����
        PUBLIC OSTickISR		  ;����
        PUBLIC SerialISR          ;����


;�����ջ�ռ䡣ֻ���Ĵ�С����ջ�����keil������ͨ����ſ��Ի��keil�����SP��㡣
?STACK SEGMENT IDATA
        RSEG ?STACK
OSStack:
        DS 30H
OSStkStart IDATA OSStack-1

;����ѹջ��  �ӳ������
PUSHALL     MACRO	
        	PUSH ACC
        	PUSH B
        	PUSH DPH
        	PUSH DPL
        	PUSH PSW
        	MOV  A,R0   ;R0-R7��ջ
        	PUSH ACC
        	MOV  A,R1
       	 	PUSH ACC
        	MOV  A,R2
        	PUSH ACC
        	MOV  A,R3
        	PUSH ACC
        	MOV  A,R4
        	PUSH ACC
        	MOV  A,R5
        	PUSH ACC
        	MOV  A,R6
        	PUSH ACC
        	MOV  A,R7
        	PUSH ACC
        	;PUSH SP    ;���ر���SP�������л�ʱ����Ӧ�������
        	ENDM
;�����ջ��  �ӳ������   
POPALL  	MACRO			 ;���ر���SP�������л�ʱ����Ӧ�������	 R0-R7��ջ   
        	POP  ACC    
        	MOV  R7,A
        	POP  ACC
        	MOV  R6,A
        	POP  ACC
        	MOV  R5,A
        	POP  ACC
        	MOV  R4,A
        	POP  ACC
        	MOV  R3,A
      	 	POP  ACC
       	 	MOV  R2,A
        	POP  ACC
        	MOV  R1,A
        	POP  ACC
        	MOV  R0,A
        	POP  PSW
        	POP  DPL
        	POP  DPH
        	POP  B
        	POP  ACC
        	ENDM
    
;�ӳ���
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OSStart()�е��ã���Զִֻ��һ��
        RSEG ?PR?OSStartHighRdy?OS_CPU_A
OSStartHighRdy:
        USING 0    ; (1) �ϵ��51�Զ����жϣ��˴�������CLR EAָ���Ϊ���˴���δ���жϣ��������˳��󣬿��ж�; ʹ�üĴ�����0
        LCALL _?OSTaskSwHook    ; (2) ���������ӣ������ǿյ�

OSCtxSw_in:		   ;�ӳ���ģ�����ж�
    
        ;OSTCBCur -> DPTR  ��õ�ǰTCBָ�룬���C51.PDF��178ҳ
        MOV  R0,#LOW (OSTCBCur) ; (3) ���OSTCBCurָ��͵�ַ��ָ��ռ3�ֽڡ�+0����+1��8λ����+2��8λ����
        INC  R0					; ʹ��OSSTartHighRdy��OSTCBCurЧ��һ��
        MOV  DPH,@R0            ; ��ȡ��Ҫ�ָ���������ȼ�����Ķ�ջָ��
        INC  R0
        MOV  DPL,@R0			;DPTR 16����ָ�� ���⹦�ܼĴ���  = DPH + DPL
    	
        ;OSTCBCur -> OSTCBStkPtr -> DPTR  ���������ȼ�����Ķ�ջָ��	ָ��ռ3�ֽڡ�+0����+1��8λ����+2��8λ����
        INC  DPTR        		; (5)
        MOVX A,@DPTR            ; OSTCBStkPtr��voidָ��
        MOV  R0,A
        INC  DPTR
        MOVX A,@DPTR
        MOV  R1,A
        MOV  DPH,R0				 
        MOV  DPL,R1				 ;ȡ��OSTCB�е��û���ջָ���ַ��DPTR
    
        ;*UserStkPtr -> R5  �û���ջ��ʼ��ַ����(���û���ջ���ȷ��ڴ˴�)  
        MOVX A,@DPTR             ;(6) �û���ջ����unsigned char��������	 
        MOV  R5,A                ;R5 = �û���ջ����
    
        ;�ָ��ֳ���ջ����
        MOV  R0,#OSStkStart		 ;(7)  ϵͳ��ջ��ʼ��ַ	 R0 = OSStkStart
        
restore_stack: 					 ;���û���ջ�еļĴ���ֵ����ϵͳջ
        INC  DPTR				 ;�ƶ�2�ֽڳ���
        INC  R0
        MOVX A,@DPTR
        MOV  @R0,A
        DJNZ R5,restore_stack	 ;R5 = �û���ջ����
    
        ;�ָ���ջָ��SP			 ָ��ϵͳջջ��
        MOV  SP,R0				 ;ϵͳ��ջ�ռ��С = �����ջ�ռ��С = SP - OSStkStart
    
        ;�ָ������ջָ��?C_XBP        
        INC  DPTR
        MOVX A,@DPTR
        MOV  ?C_XBP,A    ;?C_XBP �����ջָ���8λ
        INC  DPTR
        MOVX A,@DPTR
        MOV  ?C_XBP+1,A  ;?C_XBP �����ջָ���8λ
    
        ;ϵͳ���б�־ OSRunning = TRUE
        MOV  R0,#LOW (OSRunning)	;ȫ�ֱ���
        MOV  @R0,#01
    
        POPALL	   ;ִ�г�ջ�꣬��ϵͳջ�д洢�����ݻָ����Ĵ������ͺ���շ������ж�һ��
        SETB EA    ;���ж�
        RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;����ʵ�����������л�,1,�ֶ�����CPU���ж�����ʱ�Զ�����ļĴ���(PC)��2������ļĴ���
        RSEG ?PR?OSCtxSw?OS_CPU_A
OSCtxSw:    
        USING 0            ;Ĭ��ʹ��R0~R7
		PUSHALL			   ;PCֵ�Ѿ�ѹ��ϵͳ��ջ����ʣ��ļĴ�����ѹ��ϵͳջ
    
OSIntCtxSw_in:
    
        ;��ö�ջ���Ⱥ���ַ
        MOV  A,SP
        CLR  C
        SUBB A,#OSStkStart
        MOV  R5,A     	   ;��ö�ջ����   R5 = SP - OSStkStart   
    
        ;OSTCBCur -> DPTR  ��õ�ǰTCBָ��
        MOV  R0,#LOW (OSTCBCur) ;���OSTCBCurָ��͵�ַ��ָ��ռ3�ֽڡ�+0����+1��8λ����+2��8λ���� u_COS_II.H������
        INC  R0
        MOV  DPH,@R0       ;ȫ�ֱ���OSTCBCur��IDATA��
        INC  R0
        MOV  DPL,@R0
    
        ;OSTCBCur->OSTCBStkPtr -> DPTR  ����û������񣩶�ջָ��
        INC  DPTR        ;ָ��ռ3�ֽڡ�+0����+1��8λ����+2��8λ����
        MOVX A,@DPTR     ;.OSTCBStkPtr��voidָ��
        MOV  R0,A
        INC  DPTR
        MOVX A,@DPTR
        MOV  R1,A
        MOV  DPH,R0
        MOV  DPL,R1
        
        ;�����ջ����
        MOV  A,R5
        MOVX @DPTR,A
    
        MOV  R0,#OSStkStart  ;��ö�ջ��ַ
save_stack:					 ;���浱ǰϵͳ��ջ���ݵ��û���ջ 
        INC  DPTR
        INC  R0
        MOV  A,@R0
        MOVX @DPTR,A
        DJNZ R5,save_stack
        
        ;��������ջָ��?C_XBP
        INC  DPTR					   ;(9)
        MOV  A,?C_XBP    ;?C_XBP �����ջָ���8λ
        MOVX @DPTR,A
        INC  DPTR
        MOV  A,?C_XBP+1  ;?C_XBP �����ջָ���8λ
        MOVX @DPTR,A        
    
        LCALL _?OSTaskSwHook			;(10)  ���񽻻�����
        
        ;OSTCBCur = OSTCBHighRdy  ����ǰ�����ָ��ָ��Ҫ�ָ����е�����(���ȼ���ߵ�����)
        MOV  R0,#OSTCBCur				;(11)
		MOV  R1,#OSTCBHighRdy
		MOV  A,@R1
        MOV  @R0,A
        INC  R0
		INC  R1
		MOV  A,@R1
        MOV  @R0,A
        INC  R0
		INC  R1
		MOV  A,@R1
        MOV  @R0,A					   ;ָ��3���ֽ� ����3��
                
        ;OSPrioCur = OSPrioHighRdy 
        MOV  R0,#OSPrioCur			   ;(12)
		MOV  R1,#OSPrioHighRdy
		MOV  A,@R1
        MOV  @R0,A
        
        LJMP OSCtxSw_in					;ģ���ж����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        RSEG ?PR?OSIntCtxSw?OS_CPU_A
        
OSIntCtxSw:

        ;����SPָ��ȥ���ڵ���OSIntExit(),OSIntCtxSw()������ѹ���ջ�Ķ�������
        ;SP=SP-4

        MOV  A,SP
        CLR  C
        SUBB A,#4
        MOV  SP,A
        
        LJMP OSIntCtxSw_in			    ;ģ���ж����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ϵͳ���Ĵ���
        CSEG AT 000BH    ;OSTickISR
        LJMP OSTickISR   ;ʹ�ö�ʱ��0
        RSEG ?PR?OSTickISR?OS_CPU_A

OSTickISR:        
        USING 0        
        PUSHALL
        
        CLR  TR0		 ;ֹͣ��ʱ��0
        MOV  TH0,#0DCH   ;��ʼ����ʱ����Tick=100��/��
        MOV  TL0,#00H    ;
        SETB TR0		 ;������ʱ��0
        
        LCALL _?OSIntEnter   ;�жϺ�������ִ��
        LCALL _?OSTimeTick	 ;����
        LCALL _?OSIntExit	 ;�жϺ����Ѿ��˳�

        POPALL        
        RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�����жϴ���
        CSEG AT 0023H    
        LJMP SerialISR   ;����ϵͳ���ܲ���
        RSEG ?PR?_?serial?OS_CPU_A
        
SerialISR:
        
        USING 0   
		CLR  EA        ;�ȹ��жϣ��Է��ж�Ƕ��
        PUSHALL	       ;�������мĴ���
   		LCALL _?OSIntEnter
        LCALL _?serial   ;�����жϴ���   
		LCALL _?OSIntExit
        POPALL        ;�ָ����мĴ���
		SETB EA
        RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        END