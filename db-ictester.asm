;------------------------------------------------
; 
;  IC-Tester TTL Database Source 
;  update: 13. April 2016
;  Assembler: ACME, release 0.94.12 ("Zarquon")
; 
;------------------------------------------------
!to"db-ictester",cbm
*=$2000
TTL_7400: 
!scr "7400  4*2-input nand gates     "
de00_modeconfig: !byte 0b10000000
df00_modeconfig: !byte 0b10010011 
de00_portc_hi:   !byte 0b00000000  ; not used
df00_portc_hi:   !byte 0b01010000  ; VCC Pin 20, GND Pin 7
;diag-table: 0,1,2 equals to port A,B,C
;
; port analyse Byte:%rwrw + 4 Byte portbits
diagdata: 
!byte 0b00000000,$1b,$1b,$00,$24
!byte 0b00000000,$09,$2d,$12,$36
!byte 0b00000000,$10,$34,$01,$25
!byte 0b00000000,$03,$23,$19,$1d
!byte 0b01010101,$36,$37,$00,$49
!byte 0b01010101,$12,$5b,$27,$67
!byte 0b01010101,$20,$69,$02,$4b
!byte 0b01010101,$16,$57,$32,$3b
!byte 0b00000011
*=$2080
TTL_7402: 
!scr "7402  4*2-input nor gates      "
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,9,48,49
!byte 0b00000000,6,14,54,54
!byte 0b01010101,0,19,96,99
!byte 0b01010101,12,29,106,105
!byte 0b00000011
*=$2100
TTL_7404: 
!scr "7404  6*inverter               "
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,42,1,41
!byte 0b00000000,4,38,16,26
!byte 0b00000000,21,21,20,22
!byte 0b01010101,0,85,2,83
!byte 0b01010101,8,77,32,53
!byte 0b01010101,42,43,34,51
!byte 0b00000011
*=$2180
TTL_7406: 
!scr "7406  6*inverter             oc"
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,0,3,3
!byte 0b00000000,12,12,48,48
!byte 0b00000000,21,21,42,42
!byte 0b01010101,6,7,2,3          ; exclude 7412  
!byte 0b01010101,0,1,6,7  
!byte 0b01010101,24,25,96,97
!byte 0b01010101,42,43,84,85
!byte 0b00000011
*=$2200
TTL_7407: 
!scr "7407  6*buffer               oc"
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,0,3,3
!byte 0b00000000,1,1,2,0
!byte 0b00000000,4,4,8,0           
!byte 0b00000000,12,12,16,16  
!byte 0b00000000,32,0,48,48  
!byte 0b00000000,51,51,7,7   
!byte 0b01010101,2,3,4,1
!byte 0b01010101,6,7,8,9    
!byte 0b01010101,16,1,24,25
!byte 0b01010101,32,33,64,1      
!byte 0b01010101,96,97,0,1       
!byte 0b01010101,30,31,120,121   
!byte 0b00000011
*=$2280
TTL_7408: 
!scr "7408  4*2 input and gates      "
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,0,3,7
!byte 0b00000000,24,56,27,63
!byte 0b00000000,25,57,19,23
!byte 0b01010101,6,15,48,113
!byte 0b01010101,54,127,38,47
!byte 0b01010101,2,3,0,1      
!byte 0b00000011
*=$2300
TTL_7410: 
!scr "7410  3*3 nand gates           "
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,28,28,24,56
!byte 0b00000000,12,44,8,40 
!byte 0b01010100,3,69,2,67
!byte 0b01000100,1,71,2,71
!byte 0b01010101,56,61,48,117
!byte 0b00000011
*=$2380
TTL_7411: 
!scr "7411  3*3 and gates            "
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,0,28,60
!byte 0b00000000,40,8,3,3 
!byte 0b01010100,2,1,56,121
!byte 0b01010100,48,121,10,11
!byte 0b00000011
*=$2400
TTL_7412: 
!scr "7412  3*3 nand gates         oc"
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,0,127,127
!byte 0b00000000,3,3,56,56  
!byte 0b00000000,60,28,15,15
!byte 0b01010100,6,7,2,3
!byte 0b01010100,127,63,56,57
!byte 0b01010100,58,59,64,65
!byte 0b00000011
*=$2480
TTL_7417: 
!scr "7417  6*buffer               oc"
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,0,0,3,3
!byte 0b00000000,1,1,2,0
!byte 0b00000000,4,4,8,0           
!byte 0b00000000,12,12,16,16  
!byte 0b00000000,32,0,48,48  
!byte 0b00000000,51,51,7,7   
!byte 0b01010101,2,3,4,1
!byte 0b01010101,6,7,8,9    
!byte 0b01010101,16,1,24,25
!byte 0b01010101,32,33,64,1      
!byte 0b01010101,96,97,0,1       
!byte 0b01010101,30,31,120,121   
!byte 0b00000011
*=$2500
TTL_74132:
!scr "74134 4*2-input nand trigger   "
!byte 0b10000000
!byte 0b10010011 
!byte 0b00000000  ; not used
!byte 0b01010000  ; VCC Pin 20, GND Pin 7
!byte 0b00000000,$1b,$1b,$00,$24
!byte 0b00000000,$09,$2d,$12,$36
!byte 0b00000000,$10,$34,$01,$25
!byte 0b00000000,$03,$23,$19,$1d
!byte 0b01010101,$36,$37,$00,$49
!byte 0b01010101,$12,$5b,$27,$67
!byte 0b01010101,$20,$69,$02,$4b
!byte 0b01010101,$16,$57,$32,$3b
!byte 0b00000011
*=$2580
!byte $00 ; database end-marker




















