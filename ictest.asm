!to"ictester",cbm

;----------------------------------------------------------
; Dela IC-Tester Software
;
; [/] 7.March 2016 M. Sachse http://www.cbmhardware.de  
;----------------------------------------------------------


 

 s_lo         = $fa
 s_hi         = $fb
 t_lo         = $fc
 t_hi         = $fd 

 b_l_bottom   = $0e
 b_h_bottom   = $0f 
 b_lo         = $0a
 b_hi         = $0b



bsout        = $ffd2
get          = $ffe4 
wport        = $de00
wconf        = $de03
rport        = $df00
rconf        = $df03
os_message   = $ff90
file_params  = $ffba
set_filename = $ffbd
load         = $ffd5
getin        = $ffe4

*= $0800
!byte $00,$0c,$08,$0a,$00,$9e,$32,$30,$36,$33,$00,$00,$00,$00
*=$080f 
start:        

              lda #$08
              sta drive    
              ldx #$00 
              stx dmode  
              stx dbcount_lo
              stx dbcount_hi
              stx count
              stx menuline
              lda #$c2
              sta b_hi
              lda #$c9
              sta b_lo                

              lda #$c0
              sta b_h_bottom
              lda #$00                       
              sta b_l_bottom              


              lda #$06
              sta $d020
              sta $d021
              lda #$00
              sta menuline 
              lda #$93
              jsr $ffd2
              lda #$07
-             sta $d800,x
              sta $d900,x
              sta $da00,x
              sta $db00,x
              inx
              bne -  
              jsr buildscreen
              ldy #$00            ; invert first menu line
              lda #$06
              sta s_hi
              lda #$5f
              sta s_lo
-             lda (s_lo),y
              ora #%10000000   
              sta (s_lo),y
              iny
              cpy #$19 
              bne -
              jsr load_ttldata    ; load default ttl-database
              jsr count_db 

              ldx #$00
-             lda startup_db,x  ; "Dateiname"
              sta $0608,x
              inx
              cpx #$28
              bne -
              ldx #$00 
-             lda default_db,x
              sta $0619,x
              inx  
              cpx #$0b
              bne -       
              jsr load_help 
              jsr selftest  
              jsr found
             


default_db: !scr "db-ictester"
startup_db: !scr "      datenbank:                        "   

;-----------------------------------------------------------
; load db manually
;-----------------------------------------------------------
counter: !by $00
m_filename: !tx "                      "
max:       !by $10
load_db_manual:


              lda #$05            ; $0575 for known TTLs
              sta t_hi 
              lda #$70
              sta t_lo
              clc  
              ldy #$00            ; $1f and two lines                
-             lda #$20
              sta (t_lo),y 
              iny
              cpy #$6f   
              bne -

+
              clc
              ldx #$0d          ; row
              ldy #$11          ; collumn    
              jsr $fff0         ; set cursor                
              ldx #$27
-             lda ask_filename,x
              sta $0608,x
              dex
              bpl -
              ldx #$00
              stx matched_ttl     ; erase match_counter
              lda #"?"
              sta $0619,x 
              stx counter
-             jsr getin
              beq -
              cmp #$0d            ; return to load
              beq load_mdb
              cmp #$14            ; del
              bne +
              ldx counter
              beq -  
              dec counter
              jsr bsout 
              jmp -
+             ldx counter
              cpx max             ; 16 chars allowed
              bcs -   
              inc counter
              sta m_filename,x 
              jsr bsout 
              lda #"R"
              sta $061a,x 
              jmp -  
              jsr bsout
              bne -
load_mdb:
         
              ldx counter  
              lda #" "
              sta $0619,x 
              lda counter    
              beq load_db_manual
              ldx #$00
--            lda ldb1_txt,x
              sta $0777,x
              inx
              cpx #$22 
              bne --
              ldx #$00
              ldy #$00
              lda #$20            ; delete TTL-Database at $2000- 
              sta t_hi
              lda #$00
              sta t_lo
              lda #$00
-             sta (t_lo),y  
              iny
              bne - 
              inc t_hi
              inx
              cpx #$80
              bne -
              ldx #$00
              stx dbcount_lo
              sta dbcount_hi
              sta s_lo            
              lda #$20         
              sta s_hi
              clc
              ldx #$17            ; row
              ldy #$1e            ; collumn    
              jsr $fff0           ; set cursor 
              lda #" "
              jsr bsout  
              jsr endcount
              ldx #$00            ; erase temp. TTL-List at $c000-
              ldy #$00
              lda #$c0            
              sta t_hi
              lda #$00
              sta t_lo
              lda #$00
-             sta (t_lo),y  
              iny
              bne - 
              inc t_hi
              inx
              cpx #$10
              bne -
              ldx #$00
--            lda ldb2_txt,x
              sta $0777,x
              inx
              cpx #$22 
              bne --
              ldx #$00 
              lda #$00            ; disable os-messages
              jsr os_message        
              lda fnnumb
              ldx drive
              ldy fn_sec  
              jsr file_params
              lda counter
              ldx #<(m_filename)
              ldy #>(m_filename)
              jsr set_filename
              ldy #$20 
              ldx #$00            ; load to $2000               
              lda #$00
              jsr load       
              bcs load_error
              ldx #$00
--            lda ldb3_txt,x
              sta $0777,x
              inx
              cpx #$22 
              bne --
              jsr count_db 
              jmp keyboard

load_error:   cmp #04             ; file not found
              beq fnf
              cmp #05
              beq dnr
              jmp keyboard
fnf:          ldx #$00
--            lda ldb_fnf,x
              sta $0777,x
              inx
              cpx #$22 
              bne --
              ldx #$27
-             lda ask_filename,x
              sta $0608,x
              dex
              bpl -
              jmp keyboard
dnr:          ldx #$00
--            lda ldb_dnr,x
              sta $0777,x
              inx
              cpx #$22 
              bne --
              ldx #$27
-             lda ask_filename,x
              sta $0608,x
              dex
              bpl -
              jmp keyboard    


;-----------------------------------------------------------
; Keyboard
;-----------------------------------------------------------
keyboard:
              jsr get             ; get keyboard
              cmp #$0d            ; enter
              beq mainmenu_work  
              cmp #$11            ; cursor down for setup
              beq _mainmenu_down
              cmp #$91            ; cursor up
              beq mainmenu_up
              cmp #$13            ; re-start
              beq _start
              cmp #"D"            ; (D)ebugmode
              beq _debug
              cmp #"H"            ; (H)elp
              beq _show_help
              cmp #"F"            ; (H)elp
              beq _toggle_drive
              cmp #"L"            ; (H)elp
              beq _load_content



              bne keyboard
_show_help:     jmp show_help
_debug:         jmp debugmode
end:            jmp ($a000)
_mainmenu_down: jmp mainmenu_down
_start:         jmp start
_load_db_manual:jmp load_db_manual
_smon:          jmp $c000
_toggle_drive:  jmp toggle_drive 
_load_content   jmp load_content

;-----------------------------------------------------------
; lightbar row-decoding
;-----------------------------------------------------------
mainmenu_work:
              lda menuline
              beq _selftest  
              cmp #$01
              beq _load_db_manual
              cmp #$02
              beq _chiplist  
              cmp #$03
              beq _diagnostic
              cmp #$04
              beq _ttl_cycler
              cmp #$05
              beq end                
              jmp keyboard

_selftest:    jmp selftest
_chiplist:    jmp chiplist
_diagnostic:  jmp diagnostic
_ttl_cycler:  jmp ttl_cycler   

mainmenu_up:  ldy menuline              
              tya
              pha
              lda line_ofs_hi,y         
              sta s_hi
              lda line_ofs_lo,y         
              sta s_lo
              ldy #$00 
-             lda (s_lo),y
              and #%01111111 
              sta (s_lo),y
              iny
              cpy #$19 
              bne -
              pla 
              tay  
              bne +
              ldy #$06
              sty menuline  
              beq ++  
+             dey   
++            sty menuline 
              lda line_ofs_hi,y         
              sta s_hi
              lda line_ofs_lo,y         
              sta s_lo
              ldy #$00 
-             lda (s_lo),y
              ora #%10000000   
              sta (s_lo),y
              iny
              cpy #$19 
              bne -
              jmp keyboard

mainmenu_down:ldy menuline              
              tya
              pha
              lda line_ofs_hi,y         
              sta s_hi
              lda line_ofs_lo,y         
              sta s_lo
              ldy #$00 
-             lda (s_lo),y
              and #%01111111 
              sta (s_lo),y
              iny
              cpy #$19 
              bne -
              pla 
              tay  
              cpy #$05  
              bne +
              ldy #$00
              sty menuline  
              beq ++  
+             iny   
++            sty menuline 
              lda line_ofs_hi,y         
              sta s_hi
              lda line_ofs_lo,y         
              sta s_lo
              ldy #$00 
-             lda (s_lo),y
              ora #%10000000   
              sta (s_lo),y
              iny
              cpy #$19 
              bne -
              jmp keyboard
line_ofs_lo: !byte $5f,$87,$af,$d7,$ff,$27
line_ofs_hi: !byte $06,$06,$06,$06,$06,$07



selftest:     
              lda #$93            ; port configs
              sta $df03
              lda #$80            
              sta $de03
              lda #$00            ; led off
              sta $de02
              lda #$ff
              sta $df00           ; read port A     
              sta $df01           ; read port B 
              lda #$00              
              sta $de00           ; set port A to output
              sta $de01           ; set port B to output
              sta $df02           ; set port C to output
              sta $de02           ; set port C to output
              lda #$08            ; led on
              sta $de02              
              inc $d020
              ldx #%10101010
              stx $de00
              cpx $df00
              bne fault
--            inc $d020  
              ldx #%10101010
              stx $de01
              cpx $df01
              bne port_B_fault
---           inc $d020
              ldx #%00001010
              stx $de02
              cpx $df02
              beq found
              bne port_C_fault
              jmp keyboard

fault:        ldx #$00
-             lda fault_txt,x
              sta $0777,x
              inx
              cpx #$22 
              bne -
              lda #$00            ; led off
              sta $de02
              lda #$02
              sta $d020   
port_A_fault: ldx #$00   
-             lda fault_port_A,x
              sta $04a4,x
              inx
              cpx #$20 
              bne -
              jmp -- 

port_B_fault: ldx #$00   
-             lda fault_port_B,x
              sta $04a4+40,x
              inx
              cpx #$20 
              bne -
              jmp ---

port_C_fault: ldx #$00   
-             lda fault_port_C,x
              sta $04a4+80,x
              inx
              cpx #$20 
              bne -
              lda #$06
              sta $d020
              jmp keyboard



found:        ldx #$00
-             lda ok_txt,x
              sta $0777,x
              inx
              cpx #$20 
              bne -
              lda #$00            ; led off
              sta $de02
              lda #$06
              sta $d020
              ldx #$00   
-             lda ok_message,x
              sta $04a0,x
              inx
              cpx #$50 
              bne -
              lda #$06
              sta $d020
              jmp keyboard

menuline: !by $00


load_ttldata:
              ldx #$00
--            lda ldb2_txt,x
              sta $0777,x
              inx
              cpx #$22 
              bne --


              ldx #$00 
              lda #$00            ; disable os-messages
              jsr os_message        
              lda fnnumb
              ldx drive
              ldy fn_sec  
              jsr file_params
              lda fnchars
              ldx #<(filename)
              ldy #>(filename)
              jsr set_filename
              ldy #$20 
              ldx #$00            ; load to $2000               
              lda #$00
              jsr load       
              rts



drive:   !byte  $08 
fnchars: !byte  $0b
fnnumb:  !byte  $0F
fn_sec:  !byte  $00
filename: !tx "DB-ICTESTER"  


count_db:
              ldx #$00
;              ldy #$00
              lda #$c0
              sta t_hi
              lda #$20
              sta s_hi
              lda #$00
              sta s_lo
              sta t_lo 
-             ldy #$00 
              lda (s_lo),y
              beq endcount
              inc dbcount_lo
;--------------------------------------
; write temp ic-list to $c000
l0:           clc
              lda (s_lo),y
              sta (t_lo),y 
              iny
              cpy #$1f
              bne l0  
              clc 
              lda t_lo 
              adc #$1f
              sta t_lo
              bcc ++
              inc t_hi 
;--------------------------------------
++            clc 
              lda s_lo 
              adc #$80 
              sta s_lo
              lda dbcount_lo
              bne +  
              inc dbcount_hi
+             bcc -  
              inc s_hi
              jmp -
endcount:     
              lda #$07          ; yellow 
              sta $0286         ; text-color  
              clc
              ldx #$17          ; row
              ldy #$1d          ; collumn    
ec:           jsr $fff0         ; set cursor 
              lda dbcount_hi    ; hi-byte
              ldx dbcount_lo    ; low byte

              jsr $bdcd         ; show decimal value
              clc  
              ldx #$17          ; row
              ldy #$20          ; collumn    
              jsr $fff0         ; set cursor 
              lda #">"
              jsr bsout
              lda #"$"
              jsr bsout
show_hex:     lda s_hi
              and #%11110000    ; first upper nibble
              lsr
              lsr
              lsr
              lsr
              jsr add1          ; show upper nibble  
              lda s_hi
              jsr add1          ; show lower nibble 
              lda s_lo
              and #%11110000
              lsr 
              lsr
              lsr
              lsr 
              jsr add1
              lda s_lo
add1          and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout
              rts 
;-----------------------------------------------------------------------
; (re)build mainscreen
;-----------------------------------------------------------------------


buildscreen:
              ldy #$00   
              lda #>mainscreen    ; Build main-screen
              sta s_hi
              lda #<mainscreen 
              sta s_lo 
              lda #$04
              sta t_hi
bs:           lda #$00 
              sta t_lo 
-             lda (s_lo),y
              sta (t_lo),y
              iny
              bne -
              inc s_hi
              inc t_hi
              inx
              cpx #$04
              bne -
              rts 

;-----------------------------------------------------------------------
; show chip-list
;-----------------------------------------------------------------------

chipcount: !by $00

chiplist:     lda dbcount_lo
              beq nottl
              cmp #$18  
              bcc somettl
              jmp fullscroll       
nottl:        jmp keyboard

somettl:      lda dbcount_lo
              sta chipcount
             
              jmp +



fullscroll:  
              lda #$18
              sta chipcount 
+             lda #$04            ; buffer 1K screen ram
              sta s_hi
              lda #$00
              sta s_lo
              tay
              tax   
              lda #$a0
              sta t_hi
              jsr bs
              lda #147
              jsr bsout
;------------------------------------------------
; chiplist: build first screen

              ldx #$00
              ldy #$00
              lda #$04            ; screen ram
              sta t_hi
              lda #$03
              sta t_lo
              lda #$c0            ; chiplist-buffer
              sta s_hi
              lda #$00
              sta s_lo
-             lda (s_lo),y        ; list chip-data 
              sta (t_lo),y  
              iny
              cpy #$1f
              bne - 

              clc
              lda t_lo
              adc #$28
              sta t_lo
              bcc +
              inc t_hi
+             clc
              lda s_lo
              adc #$1f
              sta s_lo
              bcc ++
              inc s_hi
++            ldy #$00
              inx
              cpx chipcount 
              bne - 

              lda dbcount_lo
              cmp #$18  
              bcc noscroll:

              ldx #$28
-             lda navline,x
              ora #$80
              sta $07c0,x
              dex
              bpl -   
              bmi keys   

noscroll:
              ldx #$28
-             lda navline1,x
              ora #$80
              sta $07c0,x
              dex
              bpl -   


            
                             
keys:         jsr get             ; get keyboard
              cmp #$11            ; cursor down 
              beq down
              cmp #$20             
              beq listexit
              cmp #$91            ; cursor up
              beq _up

              jmp keys
_mainmenu:    jmp keyboard
_up:          jmp up

count: !by $00
;-----------------------------------------------------------------------
; rebuild mainscreen-snapshot and exit

listexit:
              sei
              lda $01
              and #$fe            ; $a000-$bfff to ram
              sta $01 

              lda #$a0            ; buffer 1K screen ram
              sta s_hi
              lda #$00
              sta s_lo
              tay
              tax   
              lda #$04
              sta t_hi
              jsr bs
              lda $01
              ora #$01            ; $a000-$bfff to Basic-ROM
              sta $01
              cli
              jmp keyboard



;-----------------------------------------------------------------------
; scroll down
;-----------------------------------------------------------------------
temp_count: !by $00
down:       

              lda dbcount_lo
              cmp #$18  
              bcc ex_down


              lda dbcount_lo
              sbc #$18
              sta temp_count

              lda count
              cmp temp_count
              beq ex_down
+             ldx #$17            ; 23 lines
              lda #$04                            
              sta s_hi
              lda #$2c  ;#$28            ; first line to read
              sta s_lo 
              lda #$04            ; new place for first line
              sta t_hi
              lda #$04  ;#$00 
              sta t_lo 
--            ldy #$1e  ;#$27
-             lda (s_lo),y        ; scroll one line 
              sta (t_lo),y
              dey
              bpl -
              clc
              lda s_lo
              sta t_lo
              adc #$28
              sta s_lo
              lda s_hi
              sta t_hi
              adc #$00
              sta s_hi
              clc   
nc:           dex 
              bne -- 
;-----------------------------------------------------------------------
; calculate new buffer offsets and insert line 25

              clc
              lda b_lo            ; top-offset buffer  
              adc #$1f
              sta b_lo
              bcc +
              inc b_hi


+
              clc                 
              lda b_l_bottom
              adc #$1f
              sta b_l_bottom
              bcc bufferline
              inc b_h_bottom



bufferline:  



              dec t_lo
              ldy #$1e
bl:           lda (b_lo),y        ; insert buffer-line
              sta (t_lo),y
              dey             
              bpl bl
              inc count
ex_down:      jmp keys

;-----------------------------------------------------------------------
; scroll up
;-----------------------------------------------------------------------

up:           
              lda dbcount_lo
              cmp #$18  
              bcc ex_up

              lda count
              beq ex_up
+             ldx #$17
              lda #$07                            
              sta s_hi
              lda #$74  ;#$70
              sta s_lo 
              lda #$07
              sta t_hi
              lda #$9c  ;#$98 
              sta t_lo 
u_nl:         ldy #$1e
u_nc:         lda (s_lo),y        ; scroll one line up
              sta (t_lo),y
              dey  
              bpl u_nc:
              sec   
              lda s_lo
              sta t_lo
              sbc #$28
              sta s_lo
              lda s_hi
              sta t_hi
              sbc #$00
              sta s_hi
              sec   
++            dex 
              bne u_nl 
;-----------------------------------------------------------------------
; calculate new buffer offsets and insert line 24

              sec                 
              lda b_lo
              sbc #$1f
              sta b_lo
              bcs bl1
              dec b_hi
              sec                 
bl1:          lda b_l_bottom
              sbc #$1f
              sta b_l_bottom
              bcs bl2
              dec b_h_bottom
bl2:

              dec t_lo      
              sec
              ldy #$1e
bl_up:        lda (b_l_bottom),y        ; insert buffer-line
              sta (t_lo),y
              dey
              bcs +
              dec b_h_bottom  
+             bpl bl_up                           
              dec count
ex_up:        jmp keys


hi_byte: !by $00
temp:    !by $00



dbcount_lo: !by $00
dbcount_hi: !by $00
add:        !by $00
;-----------------------------------------------------------------------
; diagnostic
;
; 
;
;
;-----------------------------------------------------------------------
-             jmp keyboard 
diagnostic:
              lda dbcount_lo
              beq - 
              lda #$00
              sta matched_ttl  
              sta found_ttl  
              sta ttl_clc 
              lda #$05            ; $0575 for known TTLs
              sta t_hi 
              lda #$70
              sta t_lo
              ldx #$9f ;#$c7   
-             lda #$20
              sta $04a0,x         ; erase text
              sta $0568,x 
              dex
              bne -
              ldx #$27
-             lda diag_message,x  ; "ic-analyse" 
              sta $0540,x
              dex
              bpl - 
              lda #$00
              sta match
              sta s_lo
              lda #$20
              sta s_hi 
nxt_ttl:      inc ttl_clc  

              lda #$00
              sta $de00
              sta $de01
              sta $de02



              ldy #$04            ; get TTL-Typ 74xxx  
-             lda (s_lo),y
              sta $054d,y 
              dey
              bpl -               
              clc
              lda s_lo
              adc #$1f
              sta s_lo  
              bcc +
              inc s_hi

;---------------------------------
; port setups
+             ldy #$00
              sty rw_count 
              lda (s_lo),y
              sta $de03           ; set write-port modeconfig  
            sta de_modeconf
              iny 
              lda (s_lo),y
              sta $df03           ; set read-port modeconfig  
            sta df_modeconf
              iny
              lda (s_lo),y
              sta $de02           ; set PortC (write) highbits 
           sta de_portc        
              iny
              lda (s_lo),y
              sta $df02           ; set PortC (read) highbits
           sta df_portc                       

              lda #$08            ; led on 
              sta $de02 

;---------------------------------
;diagnostic data
diagttl:
;
              iny
              lda (s_lo),y
              sta diag_port       ; get first write-port
              and #%00000011
              sta diag_w
              iny
              lda (s_lo),y        ; get byte to write 
              sta diagbyte                    
              tax
              lda diag_w
              beq w0_a
              cmp #$01
              beq w0_b
              cmp #$02    
              beq w0_c
              jmp known_ttl
w0_a:         stx $de00
              bpl +   
w0_b:         stx $de01
              bpl + 
w0_c:         stx $de02
+             lda diag_port
              lsr                 ; shift down read-port
              lsr
              and #%00000011
              sta diag_r
              iny
              lda (s_lo),y         
              sta diagbyte                                           
              lda diag_r
              beq r0_a
              cmp #$01
              beq r0_b
              cmp #$02    
              beq r0_c
              jmp known_ttl
r0_a:         ldx $df00
              bpl +   
r0_b:         ldx $df01
              bpl +
r0_c:         ldx $df02
+             cpx diagbyte
              bne diag_skip
              lda diag_port
              lsr                 ; shift down write-port
              lsr
              lsr                 ; shift down write-port
              lsr
              and #%00000011
              sta diag_w
              iny
              lda (s_lo),y        ; get byte to write 
              sta diagbyte                    
              tax
              lda diag_w 
              beq w1_a
              cmp #$01
              beq w1_b
              cmp #$02    
              beq w1_c
              jmp known_ttl
w1_a:         stx $de00
              bpl +   
w1_b:         stx $de01
              bpl + 
w1_c:         stx $de02
+             lda diag_port
              lsr                 ; shift down read-port
              lsr
              lsr                 ; shift down write-port
              lsr
              lsr                 ; shift down write-port
              lsr
              and #%00000011
              sta diag_r
              iny
              lda (s_lo),y         
              sta diagbyte                    
              lda diag_r
              beq r1_a
              cmp #$01
              bpl r1_b
              cmp #$02    
              beq r1_c
              jmp known_ttl
r1_a:         ldx $df00
              bpl +   
r1_b:         ldx $df01
              jmp +
r1_c:         ldx $df02
+             cpx diagbyte
              bne diag_skip 
              jmp diagttl

diag_skip:   
;------------------------------------------------
; debugmode-handling


              lda dmode
              bne +
              jmp ++
+             tya
              sta add
              txa
              pha

               



              clc
              ldx #$10          ; row
              ldy #$00          ; collumn    
              jsr $fff0         ; set cursor                
              lda #"P"
              jsr bsout
              lda #"T"
              jsr bsout
              lda #" "
              jsr bsout
              lda #"$"
              jsr bsout
              lda diag_r
              sta temp  
              lsr 
              lsr
              lsr
              lsr 
              and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout
              lda temp
              and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout








 


              clc
              ldx #$11          ; row
              ldy #$00          ; collumn    
              jsr $fff0         ; set cursor                
              lda #"R"
              jsr bsout
              lda #"D"
              jsr bsout
              lda #" "
              jsr bsout
              lda #"$"
              jsr bsout
              pla    
              sta temp  
              lsr 
              lsr
              lsr
              lsr 
              and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout
              lda temp
              and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout
              clc
              ldx #$12          ; row
              ldy #$00          ; collumn    
              jsr $fff0         ; set cursor                
              lda #"D"
              jsr bsout
              lda #"B"
              jsr bsout
              lda #" "
              jsr bsout
              lda #"$"
              jsr bsout
              lda diagbyte   
              lsr 
              lsr
              lsr
              lsr 
              and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout
              lda diagbyte
              and #$0f            ; calculate to hex
              cmp #$0a
              clc
              bmi +     
              adc #$07
+             adc #$30              
              jsr bsout
              clc
              ldx #$13          ; row
              ldy #$00          ; collumn    
              jsr $fff0         ; set cursor                
              lda #"$"
              jsr bsout
              clc
              lda s_lo  
              adc add  
              sta s_lo   
              bcc + 
              inc s_hi
+             jsr show_hex
              sec           
              lda s_lo  
              sbc add  
              sta s_lo   
              bcs ++
              dec s_hi
;------------------------------------------------
++
              clc                 ; seek to next entry  
              lda s_lo
              adc #$61
              sta s_lo   
              bcc +
              inc s_hi
+             ldy #$00
              lda (s_lo),y
              beq enddiag
              ldy #$00
              jmp nxt_ttl

enddiag:      jmp _enddiag
;------------------------------------------------
;------------------------------------------------
known_ttl:    
;              lda found_ttl
;              beq +
;              inc found_ttl 
              lda ttl_clc  
              sta match
+             inc matched_ttl
              lda dbcount_lo

              lda s_lo
              sbc #$1f
              sta s_lo

              ldy #$1e
-             lda (s_lo),y     
              sta (t_lo),y
              dey
              bpl -
              
              lda t_lo     
              adc #$27
              sta t_lo 

              clc  
              lda s_lo
              adc #$80
              sta s_lo  
              bcc +
              inc s_hi
+             ldy #$00
              lda (s_lo),y 
              beq _enddiag    
;              inc rw_count 
              jmp nxt_ttl  

_enddiag:     
              lda #$00
              sta $de02 
              sta $df02
              lda matched_ttl
              beq diag_fault
              bne +
              jmp keyboard
+             ldy #$0b  
-             lda ic_known,y      ; "erfolgreich"
              sta $054d,y
              dey
              bpl - 
              dec match                 
              jmp keyboard




diag_fault:  
              ldy #$04            ;  unk: "?????"  
-             lda ic_unk,y
              sta $054d,y 
              dey
              bpl -               
              ldx #$4f
-             lda diag_fault_txt,x  ; 
              sta $0590,x
              dex
              bpl - 
              jmp keyboard



diag_port: !by $00
diag_r:    !by $00 ; port and read
diag_w:    !by $00 ; write-port
diagbyte:  !by $00 ; byte to write and read
rw_count:  !by $00 ; r-w cycles
found_ttl: !by $00

de_modeconf: !by $00
df_modeconf: !by $00

de_portc: !by $00
df_portc: !by $00
match:    !by $00  
matched_ttl: !by $00
ttl_clc: !by $00

;-----------------------------------------------------------------------
; 
;
; 
;
;
;-----------------------------------------------------------------------

--            jmp keyboard

ttl_cycler: 
              lda matched_ttl
              beq --

 
              sei 

              lda #$00
              sta cycle_hi
              sta cycle_lo
              sta error_hi
              sta error_lo
              ldx #$27
-             lda cycle_txt,x     ; 
              sta $04a0,x
              lda #$20
              sta $04c8,x 
              lda cycle_info,x
              sta $04f0,x             
              dex
              bpl - 
               
              lda #$04
              sta t_hi 
  
              lda #$20
              sta s_hi
              lda #$1f 
              sta s_lo 

              ldx match    
              beq ++
               
              ldx #$00
-             clc
              adc #$80
              sta s_lo
              bcc +
              inc s_hi
+             inx 
              cpx match
              bne -
++          



;---------------------------------
; port setups
newcycle:    

              lda #$08
              sta $de02           ; led on    
              
              inc cycle_lo 
              lda cycle_lo
              bne + 
              inc cycle_hi

+             
              tya
              pha    
              ldy #$11 
              lda #$a0
              sta t_lo
              lda cycle_lo
              jsr show_number
              pla 
              tay

              tya
              pha    
              ldy #$0f 
              lda #$a0
              sta t_lo
              lda cycle_hi
              jsr show_number
              pla 
              tay
              tya
              pha    
              ldy #$20 
              lda #$a0
              sta t_lo
              lda error_lo
              jsr show_number
              pla 
              tay
              tya
              pha    
              ldy #$1e 
              lda #$a0
              sta t_lo
              lda error_hi
              jsr show_number
              pla 
              tay
              ldy #$00
              lda (s_lo),y
              sta $de03           ; set write-port modeconfig  
              iny 
              lda (s_lo),y
              sta $df03           ; set read-port modeconfig  
              iny
              lda (s_lo),y
              sta $de02           ; set PortC (write) highbits 
              iny
              lda (s_lo),y
              sta $df02           ; set PortC (read) highbits




;---------------------------------
;                  
cycle:         



              inc rw_count 
              iny
              lda (s_lo),y
              sta diag_port       ; get first write-port
              and #%00000011
              sta diag_w 
              iny
              lda (s_lo),y        ; get byte to write 
              sta diagbyte                    
              tax
              jsr cycle_write                               

              lda diag_port
              lsr                 ; shift down read-port
              lsr
              and #%00000011
              sta diag_r
              iny
              lda (s_lo),y         
              sta diagbyte                    
              jsr cycle_read    ; get byte from port                            
              cpx diagbyte

              beq nxtbyte

              inc error_lo
              lda error_lo
              beq +
              bne nxtbyte  
+             inc error_hi
nxtbyte:  
              lda diag_port
              lsr                 ; shift down write-port
              lsr
              and #%00000011
              sta diag_w
              iny
              lda (s_lo),y        ; get byte to write 
              sta diagbyte                    
              tax
              jsr cycle_write                               
              
              lda diag_port
              lsr                 ; shift down read-port
              lsr
              and #%00000011
              sta diag_r
              iny
              lda (s_lo),y         
              sta diagbyte                    
              jsr cycle_read    ; get byte from port                            
              cpx diagbyte
              beq ++  
              inc error_lo
              lda error_lo
              beq +
              bne nxtbyte  
+             inc error_hi
++            lda #%01111111  
              sta $dc00                  
              lda $dc01       
              and #%00010000  ; space pressed ?  
              beq cycle_end        
              jmp cycle       
cycle_end:    lda #$00
              sta $de02           ; led off    
              sta $df02 
              ldx #$27
              lda #$20               
-             sta $04f0,x             
              dex
              bpl - 
              cli
              jmp keyboard               
cycle_write:  lda diag_w   
              beq portA_wc
              cmp #$01
              beq portB_wc
              cmp #$02
              beq portC_wc   
              cmp #$03
              beq end_wc

portA_wc:     stx $de00
              rts
portB_wc:     stx $de01
              rts
portC_wc:     stx $de02
              rts
end_wc:       jmp newcycle


cycle_read:   lda diag_r
              beq portA_rc
              cmp #$01
              beq portB_rc
              cmp #$02
              beq portC_rc  
portA_rc:     ldx $df00
              stx diag_r
              rts 
portB_rc:     ldx $df01
              stx diag_r
              rts
portC_rc:     ldx $df02
              stx diag_r
              rts

ytemp: !by $00

cycle_hi: !by $00
cycle_lo: !by $00

error_hi: !by $00
error_lo: !by $00

div_hi: !by $00
div_lo: !by $00

;------------------------------------------------
;A: Number
;
;------------------------------------------------
show_number:
            

             pha
             lsr
             lsr
             lsr
             lsr
             tax
             lda convtable,x
             sta (t_lo),y
             pla
             and #$0f
             tax
             lda convtable,x
             iny
             sta (t_lo),y
             rts

convtable:   !byte $30,$31,$32,$33,$34,$35,$36,$37
             !byte $38,$39,$01,$02,$03,$04,$05,$06 

dmode: !by $00
dmode_txt: !scr "debug"


debugmode:   lda dmode
             beq +
             dec dmode
             beq ++             
+            inc dmode  
             ldx #$04 
-            lda dmode_txt,x   
             sta $0658,x 
             dex
             bpl -    
             jmp keyboard
++           ldx #$05 
             lda #$20
-            sta $0658,x
             sta $0658+40,x
             sta $0658+80,x
             sta $0658+120,x
             sta $0658+160,x
             dex
             bpl -    
             jmp keyboard



load_help:    ldx #$00 
              lda #$00            ; disable os-messages
              jsr os_message        
              lda fnnumb
              ldx drive
              ldy fn_sec  
              jsr file_params
              lda fnchars
              ldx #<(help_filename)
              ldy #>(help_filename)
              jsr set_filename
              ldy #$a4 
              ldx #$00            ; load to $2000               
              lda #$00
              jsr load       
              rts
help_filename: !tx "IT-HELPFILE"  


load_content: ldx #$00 
              lda #$00            ; disable os-messages
              jsr os_message        
              lda fnnumb
              ldx drive
              ldy fn_sec  
              jsr file_params
              lda fnchars
              ldx #<(cont_filename)
              ldy #>(cont_filename)
              jsr set_filename
              ldy #$19 
              ldx #$00            ; load to $2000               
              lda #$00
              jsr load       
              rts
cont_filename: !tx "IT-CONTENTX"  



show_help:    lda #$04            ; buffer 1K screen ram
              sta s_hi
              lda #$00
              sta s_lo
              tay
              tax   
              lda #$a0
              sta t_hi
              jsr bs
              lda $01
              ora #$01            ; $a000-$bfff to Basic-ROM
              sta $01
              cli
              lda #147
              jsr bsout

              sei
              lda $01
              and #$fe            ; $a000-$bfff to ram
              sta $01 

              lda #$a4            ; show help
              sta s_hi
              lda #$00
              sta s_lo
              tay
              tax   
              lda #$04
              sta t_hi
              jsr bs
              lda $01
              ora #$01            ; $a000-$bfff to Basic-ROM
              sta $01
              cli
-             jsr get
              cmp #$20
              beq +
              bne -                
+             jsr listexit
              jmp keyboard



toggle_drive: 

              lda drive   
              cmp #$08
              beq drv9
              cmp #$09
              beq drv10
              cmp #$0a
              beq drv11
              cmp #$0b
              beq drv8

drv9:         inc drive
              lda #$20
              sta $06a6
              lda #$1f
              sta $06a6+40
              jmp keyboard

drv10:        inc drive
              lda #$20
              sta $06a6+40
              lda #$1f
              sta $06a6+80
              jmp keyboard



drv11:        inc drive
              lda #$20
              sta $06a6+80
              lda #$1f
              sta $06a6+120
              jmp keyboard

drv8:         lda #$08
              sta drive
              lda #$20
              sta $06a6+120
              lda #$1f
              sta $06a6
              jmp keyboard




*=$1900
ask_filename: !scr "      dateiname:                        "
ldb1_txt:     !scr " loesche den datenspeicher        "
ldb2_txt:     !scr " lade datenbank in den speicher   "
ldb3_txt:     !scr " neue datenbank im speicher       "
ldb_fnf:      !scr " dos error - file not found !     "
ldb_dnr:      !scr " dos error - device not present ! "
ok_message:              
!scr "       ic-tester einsatzbereit          "
!scr "       release : 10.april 2016          "
mainscreen:
!scr "      dela ic-tester software 2016      "
!scr "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "                                        "
!scr "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
!scr "      B selbsttest              B "
!by $86  ; inverted "F"
!scr "loppy"
!scr "      B datenbank manuell laden B   8 "
!by $1f  ; arrow
!scr" "
!scr "      B bauteile auflisten      B   9   "
!scr "      B ic-erkennung starten    B   10  "
!scr "      B ic-dauertest            B   11  "
!scr " v0.1 B programm beenden        B "
!by $88 ; inverted "H"
!scr "ilfe "
!scr "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
!scr "status:                                 "
!scr "  bauteile in der datenbank: 0          "
!scr "cursor = auswahl   return = ausfuehren  "
diag_message:!scr " ic-analyse:                            "
diag_fault_txt:
!scr "  das ic konnte nicht erkannt werden !  "
!scr "        defekt oder unbekannt !         "
ic_unk:     !scr "?????"
ic_known:   !scr "erfolgreich !"
navline:    !scr " cursor: up and down       space to exit"
navline1:   !scr "                           space to exit"
cycle_txt:  !scr "     testlauf: 0000   fehler: 0000      "
cycle_info: !scr "        leertaste zum beenden !         "
fault_txt:  !scr " ic-tester wurde nicht erkannt ! "             
ok_txt:     !scr " ic-tester wurde erkannt !       "             
fault_port_A: !scr "port a nicht korrekt gelesen !  "
fault_port_B: !scr "port b nicht korrekt gelesen !  "
fault_port_C: !scr "port c nicht korrekt gelesen !  "



;*=$1ffb
;match: !by $00
;diag_r: !by $00
;diag_w: !by $00
;diag_port: !by $00 
;diagbyte:  !by $00 ; byte to write and read
