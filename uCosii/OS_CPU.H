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
* �ļ��� : OS_CPU.H
* ����   : Jean J. Labrosse
*********************************************************************************************************
*/

#ifndef __OS_CPU_H
#define __OS_CPU_H

#ifdef  OS_CPU_GLOBALS
#define OS_CPU_EXT
#else
#define OS_CPU_EXT  extern
#endif

/*
*********************************************************************************************************
*                                       ��������
*                                     (���������)
*********************************************************************************************************
*/

//���C51.PDF��176ҳ
typedef unsigned char  BOOLEAN;       //ע�⣺��Ҫʹ��bit���壬��Ϊ�ڽṹ�����޷�ʹ��
typedef unsigned char  INT8U;         //�޷���8λ��
typedef signed   char  INT8S;         //�з���8λ��
typedef unsigned int   INT16U;        //�޷���16λ��
typedef signed   int   INT16S;        //�з���16λ��
typedef unsigned long  INT32U;        //�޷���32λ��
typedef signed   long  INT32S;        //�з���32λ��
typedef float          FP32;          //�����ȸ�����
typedef double         FP64;          //˫���ȸ�����

typedef unsigned char  OS_STK;        //ջ��Ԫ����Ϊ8����
typedef unsigned char  OS_CPU_SR;     /* Define size of CPU status register (PSW = 8 bits)  */

#define BYTE           INT8S          //������ǰ�汾����������
#define UBYTE          INT8U          //uC/OS-II���Բ�����Щ��������
#define WORD           INT16S
#define UWORD          INT16U
#define LONG           INT32S
#define ULONG          INT32U

/* 
*********************************************************************************************************
*                              ��������ش��� MCU-51 (��ģʽ)
* ���51��Ƭ����ֻʹ�÷���1(ֱ�ӿ����ж�)
*********************************************************************************************************
*/

#define  OS_CRITICAL_METHOD    1

#if      OS_CRITICAL_METHOD == 1
#define  OS_ENTER_CRITICAL()  EA=0    //���ж�
#define  OS_EXIT_CRITICAL()   EA=1    //���ж�
#endif

#if      OS_CRITICAL_METHOD == 2
/* As an undocumented keyword of keil c. __asm is supported in Keil C v6.20.
. No other means to define assemble language code in a macro, I have to use it here. If your compiler does not support __asm, use method 1 or 3 then. */
/* A2 AF MOV C, EA*/
/* C2 AF CLR EA   */
/* C0 D0 PUSH PSW */
#define  OS_ENTER_CRITICAL()    __asm DB 0A2H, 0AFH, 0C2H, 0AFH, 0C0H, 0D0H
/* D0 D0 POP PSW   */
/* 92 AF MOV EA, C */
#define  OS_EXIT_CRITICAL()     __asm DB 0D0H, 0D0H, 092H, 0AFH
#endif

#if      OS_CRITICAL_METHOD == 3
#define  OS_ENTER_CRITICAL()  (cpu_sr = EA, EA=0)   /* Disable interrupts  */
#define  OS_EXIT_CRITICAL()   (EA=cpu_sr)    		/* Enable  interrupts  */
#endif


#define  OS_STK_GROWTH    0           //MCU-51��ջ������������  1=���£�0=����

#define  OS_TASK_SW()     OSCtxSw()   //��ΪMCU-51û�����ж�ָ������ó�����ô��档���ߵĶ�ջ��ʽ��ͬ��
                                      //RETIָ�λ�ж�ϵͳ��RET��û�С�ʵ������������MCU-51�����ӳ����
                                      //����ջ�����жϷ���ָ��RETI��ջ��û������ģ���֮�ж���ջRET��ջ��
                                      //���С���֮��������ջ���ӳ���������жϵ���Ч����һ���ģ����Ի��á�
                                      //��û���жϷ���������¸�λ�ж�ϵͳҲ����Ӱ��ϵͳ�������С�
                                      //�����uC/OS-II���ڰ���193ҳ��12��
                                      
#define OS_ISR_PROTO_EXT	1
void OSCtxSw(void);

void InitHardware(void) reentrant;    //��ʼ��Ӳ��ʱ���жϵȣ�ϵͳ��ʼ������

#endif //_OS_CPU_H