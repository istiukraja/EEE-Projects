; ==========================================
; 8051 FREQUENCY & DUTY CYCLE MEASUREMENT
; ==========================================

; --- PIN DEFINITIONS ---
RS       EQU P2.0
RW       EQU P2.1
EN       EQU P2.2
LCD_DATA EQU P1
OUT_PIN  EQU P2.7    
SW_PIN   EQU P3.1    ; Switch
BUZZER   EQU P2.5    ; Buzzer Pin (Anode to Pin/Emitter Follower)

; --- LED DEFINITIONS ---
LED1     EQU P2.3    
LED2     EQU P2.4    

; --- INPUT PINS ---
F1_IN    EQU P3.4    
F2_IN    EQU P3.5    
F3_IN    EQU P3.2    
PW_IN    EQU P3.3    

; --- SAFE MEMORY VARIABLES ---
STATE_VAR EQU 40H    
MIN_FREQ  EQU 41H    
MAX_FREQ  EQU 42H    
STAB_FLAG EQU 43H    ; 0 = Stable, 1 = Unstable
F1_BASE   EQU 44H    ; Stores the first F1 sample for comparison
PREV_F3   BIT 20H.1  

ORG 0000H
LJMP MAIN

ORG 0030H
MAIN:
    MOV SP, #60H
    MOV STATE_VAR, #0   
    MOV MIN_FREQ, #255  
    MOV MAX_FREQ, #0    
    MOV STAB_FLAG, #0   ; Assume stable at start
    
    SETB F1_IN
    SETB F2_IN
    SETB F3_IN
    SETB PW_IN
    SETB SW_PIN
    CLR BUZZER
    
    SETB LED1           
    CLR LED2            
    
    ACALL LCD_INIT
    
MAIN_LOOP:
    ; --- 1. BUTTON POLLING ---
    JB SW_PIN, RUN_STEP     
    ACALL DELAY_SMALL       
    JB SW_PIN, RUN_STEP     
    
    ACALL LCD_CLEAR         
    INC STATE_VAR           
    
    MOV A, STATE_VAR
    CJNE A, #1, WAIT_REL
    SETB LED2               

WAIT_REL: 
    JNB SW_PIN, WAIT_REL    
    ACALL DELAY_SMALL       

RUN_STEP:
    MOV A, STATE_VAR
    CJNE A, #0, TRY_S1
    LJMP DO_S0          
TRY_S1:
    CJNE A, #1, TRY_S2
    LJMP DO_S1          
TRY_S2:
    CJNE A, #2, TRY_S3
    LJMP DO_S2          
TRY_S3:
    CJNE A, #3, TRY_S4
    LJMP DO_S3
TRY_S4:
    CJNE A, #4, TRY_S5
    LJMP DO_S4          
TRY_S5:
    CJNE A, #5, RST_STATE
    LJMP DO_S5          ; Step 5: Stability Result
RST_STATE:
    MOV STATE_VAR, #0
    LJMP MAIN_LOOP

; ==========================================
; STEP 0: F1, DUTY & STABILITY SAMPLING
; ==========================================
DO_S0:
    ; Measure F1 - Sample 1 (Base Reference)
    ACALL MEASURE_F1_SUB
    MOV F1_BASE, A
    MOV R0, A           
    ACALL CHK_MIN_MAX

    ; Measure F1 - 4 more times (5 total)
    MOV R6, #4
STAB_LOOP:
    ACALL MEASURE_F1_SUB
    MOV R7, A           
    ACALL CHK_MIN_MAX
    
    ; Logic: |Base - New| > 5
    MOV A, F1_BASE
    CLR C
    SUBB A, R7          
    JNC POS_DIFF
    CPL A               
    INC A
POS_DIFF:
    CJNE A, #6, CHK_LIM  
CHK_LIM:
    JC NEXT_SAMP        
    MOV STAB_FLAG, #1   ; Signal is unstable
    SETB BUZZER         
NEXT_SAMP:
    DJNZ R6, STAB_LOOP
    CLR BUZZER          

    ; Duty Cycle (Strictly your logic)
    CLR TR1
    MOV TMOD, #15H      
    MOV TL1, #00H
    MOV TH1, #00H
W0_L: JB PW_IN, W0_L
W0_H: JNB PW_IN, W0_H
    SETB TR1
W0_E: JB PW_IN, W0_E
    CLR TR1
    MOV R4, TH1         

    ACALL LCD_HOME
    MOV A, #'F'
    ACALL LCD_DATA_WRITE
    MOV A, #'1'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    MOV A, R0
    ACALL DISPLAY_NUMBER
    
    MOV A, #' '
    ACALL LCD_DATA_WRITE
    CJNE R0, #50, R_CHK
    ACALL MSG_OK_P
    SJMP D0_DUTY
R_CHK: 
    JC F_LO_P
    ACALL MSG_HI_P
    SJMP D0_DUTY
F_LO_P: 
    ACALL MSG_LO_P

D0_DUTY:
    MOV A, #0C0H
    ACALL LCD_CMD
    MOV A, #'D'
    ACALL LCD_DATA_WRITE
    MOV A, #'u'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    
    MOV A, R4
    MOV B, R0
    MUL AB              
    MOV R2, #0          
DIV_LOOP:               
    CLR C
    SUBB A, #39
    JNC DIV_NEXT
    DEC B               
    MOV R3, B
    CJNE R3, #0FFH, DIV_NEXT
    SJMP DIV_DONE       
DIV_NEXT:
    INC R2
    SJMP DIV_LOOP
DIV_DONE:
    MOV A, R2
    CJNE A, #101, CAP_CHK
CAP_CHK:
    JC SHOW_DUTY
    MOV A, #100         
SHOW_DUTY:
    ACALL DISPLAY_NUMBER
    MOV A, #'%'
    ACALL LCD_DATA_WRITE
    LJMP MAIN_LOOP

; ==========================================
; STEP 1: MEASURE F2
; ==========================================
DO_S1:
    CLR TR1             
    MOV TMOD, #50H      
    MOV TL1, #00H
    MOV TH1, #00H
    SETB F2_IN          
    SETB TR1            
    ACALL DELAY_1SEC
    CLR TR1             

    MOV A, TH1
    JZ SAVE_F2          
    MOV TL1, #255       
SAVE_F2:
    MOV R1, TL1
    MOV A, R1
    ACALL CHK_MIN_MAX

    ACALL LCD_HOME
    MOV A, #'F'
    ACALL LCD_DATA_WRITE
    MOV A, #'2'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    MOV A, R1
    ACALL DISPLAY_NUMBER
    LJMP MAIN_LOOP

; ==========================================
; STEP 2: MEASURE F3 & SHOW ALL
; ==========================================
DO_S2:
    MOV R2, #0
    MOV R5, #20
    CLR TR1             
    MOV TMOD, #10H      
    SETB F3_IN          
    MOV C, F3_IN
    MOV PREV_F3, C      

F3_SEC_LOOP:
    MOV TH1, #3CH       
    MOV TL1, #0B0H
    SETB TR1
F3_POLL:
    MOV C, F3_IN
    JC F3_HIGH
    CLR PREV_F3         
    SJMP F3_TMR_CHK
F3_HIGH:
    JB PREV_F3, F3_TMR_CHK 
    SETB PREV_F3        
    
    MOV A, R2
    CJNE A, #255, INC_F3
    SJMP F3_TMR_CHK     
INC_F3:
    INC R2

F3_TMR_CHK:
    JNB TF1, F3_POLL    
    CLR TR1
    CLR TF1
    DJNZ R5, F3_SEC_LOOP
    
    MOV A, R2
    ACALL CHK_MIN_MAX

    ACALL LCD_HOME
    MOV A, #'F'
    ACALL LCD_DATA_WRITE
    MOV A, #'r'
    ACALL LCD_DATA_WRITE
    MOV A, #'q'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    
    MOV A, R0
    ACALL DISP_2DIG
    MOV A, #','
    ACALL LCD_DATA_WRITE
    MOV A, R1
    ACALL DISP_2DIG
    MOV A, #','
    ACALL LCD_DATA_WRITE
    MOV A, R2
    ACALL DISP_2DIG
    LJMP MAIN_LOOP

; ==========================================
; STEP 3: DIFFERENCE & OUTPUT
; ==========================================
DO_S3:
    ACALL SORT_REGS     
    MOV A, R0
    CLR C
    SUBB A, R1
    MOV R3, A           

    ACALL LCD_HOME
    MOV A, #0C0H
    ACALL LCD_CMD
    MOV A, #'D'
    ACALL LCD_DATA_WRITE
    MOV A, #'i'
    ACALL LCD_DATA_WRITE
    MOV A, #'f'
    ACALL LCD_DATA_WRITE
    MOV A, #'f'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    MOV A, R3
    ACALL DISPLAY_NUMBER
    MOV A, #'H'
    ACALL LCD_DATA_WRITE
    MOV A, #'z'
    ACALL LCD_DATA_WRITE
    
    MOV R6, #50         
GEN_W:
    SETB OUT_PIN
    ACALL VAR_DELAY
    CLR OUT_PIN
    ACALL VAR_DELAY
    DJNZ R6, GEN_W

    LJMP MAIN_LOOP

; ==========================================
; STEP 4: MIN/MAX DISPLAY
; ==========================================
DO_S4:
    ACALL LCD_HOME
    MOV A, #'M'
    ACALL LCD_DATA_WRITE
    MOV A, #'i'
    ACALL LCD_DATA_WRITE
    MOV A, #'n'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    MOV A, MIN_FREQ
    ACALL DISPLAY_NUMBER

    MOV A, #0C0H
    ACALL LCD_CMD
    MOV A, #'M'
    ACALL LCD_DATA_WRITE
    MOV A, #'a'
    ACALL LCD_DATA_WRITE
    MOV A, #'x'
    ACALL LCD_DATA_WRITE
    MOV A, #':'
    ACALL LCD_DATA_WRITE
    MOV A, MAX_FREQ
    ACALL DISPLAY_NUMBER
    LJMP MAIN_LOOP

; ==========================================
; STEP 5: STABILITY DISPLAY + FINAL BEEP
; ==========================================
DO_S5:
    SETB BUZZER      ; Turn buzzer ON to indicate final result
    ACALL DELAY_BIG      ;
    ACALL LCD_HOME
    ; Display "1st Wave "
    MOV A, #'1'
    ACALL LCD_DATA_WRITE
    MOV A, #'s'
    ACALL LCD_DATA_WRITE
    MOV A, #'t'
    ACALL LCD_DATA_WRITE
    MOV A, #' '
    ACALL LCD_DATA_WRITE
    MOV A, #'W'
    ACALL LCD_DATA_WRITE
    MOV A, #'a'
    ACALL LCD_DATA_WRITE
    MOV A, #'v'
    ACALL LCD_DATA_WRITE
    MOV A, #'e'
    ACALL LCD_DATA_WRITE
    
    MOV A, #0C0H     ; Move to 2nd Line
    ACALL LCD_CMD
    
    MOV A, STAB_FLAG
    JZ S5_STABLE
    ; Case: Not Stable
    MOV A, #'N'
    ACALL LCD_DATA_WRITE
    MOV A, #'o'
    ACALL LCD_DATA_WRITE
    MOV A, #'t'
    ACALL LCD_DATA_WRITE
    MOV A, #' '
    ACALL LCD_DATA_WRITE
S5_STABLE:
    MOV A, #'S'
    ACALL LCD_DATA_WRITE
    MOV A, #'t'
    ACALL LCD_DATA_WRITE
    MOV A, #'a'
    ACALL LCD_DATA_WRITE
    MOV A, #'b'
    ACALL LCD_DATA_WRITE
    MOV A, #'l'
    ACALL LCD_DATA_WRITE
    MOV A, #'e'
    ACALL LCD_DATA_WRITE

    ACALL DELAY_BIG  ; Let it beep for a moment
    CLR BUZZER       ; Turn buzzer OFF
    
    LJMP MAIN_LOOP

; ==========================================
; SUBROUTINES
; ==========================================

MEASURE_F1_SUB:
    CLR TR0             
    MOV TMOD, #05H      
    MOV TL0, #00H
    MOV TH0, #00H
    SETB TR0
    ACALL DELAY_1SEC
    CLR TR0
    MOV A, TL0
    RET

CHK_MIN_MAX:
    PUSH ACC
    CLR C
    SUBB A, MAX_FREQ
    POP ACC
    JC NOT_NEW_MAX
    MOV MAX_FREQ, A
NOT_NEW_MAX:
    PUSH ACC
    CLR C
    SUBB A, MIN_FREQ
    POP ACC
    JNC NOT_NEW_MIN
    MOV MIN_FREQ, A
NOT_NEW_MIN:
    RET

SORT_REGS:
    MOV A, R0
    CLR C
    SUBB A, R1
    JNC S1
    MOV A, R0 
    XCH A, R1 
    MOV R0, A
S1: MOV A, R1
    CLR C
    SUBB A, R2
    JNC S2
    MOV A, R1 
    XCH A, R2 
    MOV R1, A
S2: MOV A, R0
    CLR C
    SUBB A, R1
    JNC S3
    MOV A, R0 
    XCH A, R1 
    MOV R0, A
S3: RET

VAR_DELAY:
    MOV A, R3
    JZ VD_END           
    MOV B, A
    MOV A, #255
    DIV AB              
    MOV R4, A
VD_1: MOV R5, #150
VD_2: DJNZ R5, VD_2
    DJNZ R4, VD_1
VD_END: RET

LCD_INIT:
    ACALL DELAY_BIG
    MOV A, #38H 
    ACALL LCD_CMD
    MOV A, #0CH 
    ACALL LCD_CMD
    MOV A, #01H 
    ACALL LCD_CMD
    RET

LCD_CMD:
    MOV LCD_DATA, A
    CLR RS 
    CLR RW 
    SETB EN
    ACALL DELAY_SMALL 
    CLR EN
    RET

LCD_DATA_WRITE:
    MOV LCD_DATA, A
    SETB RS 
    CLR RW 
    SETB EN
    ACALL DELAY_SMALL 
    CLR EN
    RET

LCD_CLEAR:
    MOV A, #01H 
    ACALL LCD_CMD 
    ACALL DELAY_BIG 
    RET

LCD_HOME:
    MOV A, #80H
    ACALL LCD_CMD
    RET

DISPLAY_NUMBER:
    MOV B, #100 
    DIV AB 
    ADD A, #48 
    ACALL LCD_DATA_WRITE
    MOV A, B 
    MOV B, #10 
    DIV AB 
    ADD A, #48 
    ACALL LCD_DATA_WRITE
    MOV A, B 
    ADD A, #48 
    ACALL LCD_DATA_WRITE
    RET

DISP_2DIG:
    MOV B, #10 
    DIV AB 
    ADD A, #48 
    ACALL LCD_DATA_WRITE
    MOV A, B 
    ADD A, #48 
    ACALL LCD_DATA_WRITE
    RET

MSG_HI_P: MOV A, #'H'
    ACALL LCD_DATA_WRITE
    MOV A, #'I'
    ACALL LCD_DATA_WRITE
    RET
MSG_LO_P: MOV A, #'L'
    ACALL LCD_DATA_WRITE
    MOV A, #'O'
    ACALL LCD_DATA_WRITE
    RET
MSG_OK_P: MOV A, #'O'
    ACALL LCD_DATA_WRITE
    MOV A, #'K'
    ACALL LCD_DATA_WRITE
    RET

DELAY_SMALL: MOV R7, #100
    DJNZ R7, $
    RET

DELAY_BIG:
    MOV R6, #100
D_B1: MOV R7, #250
    DJNZ R7, $
    DJNZ R6, D_B1
    RET

DELAY_1SEC:
    MOV R3, #17
S1_D: MOV R4, #100
S2_D: MOV R5, #255
    DJNZ R5, $
    DJNZ R4, S2_D
    DJNZ R3, S1_D
    RET

END
