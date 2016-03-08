include "fontmap_6bit.asm"

empty_handler:
                rti


reset:
                init_snes()

set_up_palette:
                lda #$00
                sta io.CGADD

                lda.b #%000'00000
                sta io.CGDATA
                lda.b #%011111'00
                sta io.CGDATA
                lda.b #%111'00111
                sta io.CGDATA
                lda.b #%000111'00
                sta io.CGDATA
                lda.b #%110'01110
                sta io.CGDATA
                lda.b #%001110'01
                sta io.CGDATA
                lda.b #%111'11111
                sta io.CGDATA
                lda.b #%011111'11
                sta io.CGDATA

set_up_video:
                lda.b #(4096 & $00ff)
                sta io.VMADDL

                lda.b #((4096 & $ff00) >> 8)
                sta io.VMADDH

                lda #%00000001
                sta io.DMAP1

                lda #$18
                sta io.BBAD1

                lda.b #(font & $0000ff)
                sta io.A1T1L

                lda.b #((font & $00ff00) >> 8)
                sta io.A1T1H

                lda.b #((font & $ff0000) >> 16)
                sta io.A1B1

                stz io.DAS1L
                lda #$10
                sta io.DAS1H

                lda #%00000010
                sta io.MDMAEN

                lda #%00000001
                sta io.BG12NBA
                stz io.BG34NBA

                print8x16(2, 2, hello_world)
                print8x8(2, 5, hello_world)

                print8x8(0, 27, build_string)

                lda #%00000001
                sta io.TM

set_up_hdma:
                lda #%00000011
                sta io.DMAP0

                lda #$21
                sta io.BBAD0

                lda.b #(hdma_table & $0000ff)
                sta io.A1T0L

                lda.b #((hdma_table & $00ff00) >> 8)
                sta io.A1T0H

                lda.b #((hdma_table & $ff0000) >> 16)
                sta io.A1B0

                lda #%00000001
                sta io.HDMAEN

turn_on_screen:
                lda #$0f
                sta io.INIDISP

                lda #%10000001
                sta io.NMITIMEN
                cli

forever:
                wai
                jmp forever

vblank:
                jsr read_controllers

                rep #$20

                lda Joy1Cur
                ldx #$0002
                ldy #$0008
                jsr print8x8_bin16

                lda Joy1Prs
                ldx #$0002
                ldy #$0009
                jsr print8x8_bin16

                lda Joy1Rls
                ldx #$0002
                ldy #$000a
                jsr print8x8_bin16

                lda FrameCt
                ldx #$0002
                ldy #$000c
                jsr print8x8_bin16

                lda FrameCt
                inc
                sta FrameCt

                sep #$20

                rti

macro controller(io, cur, prs, rls) {
                ldx.w {io}
                lda.w {cur}
                stx.w {cur}
                stx.w {prs}
                sta.w {rls}
                trb.w {prs}
                txa
                trb.w {rls}
}

read_controllers:
                // make sure SNES has read from controllers
                lda #%00000001
            -
                bit io.HVBJOY
                beq -
            -
                bit io.HVBJOY
                bne -

                rep #$20
                controller(io.JOY1L, Joy1Cur, Joy1Prs, Joy1Rls)
                sep #$20

                rts

print8x8_bin16:
                pha
                tya
                asl
                asl
                asl
                asl
                asl
                stx.w $0000
                clc
                adc.w $0000
                sta.w io.VMADDL

                ldy #$0010
                pla
            -
                bmi +
                ldx #$0010
                jmp ++
            +
                ldx #$0011
            +
                stx io.VMDATAL
                dey
                beq +
                asl
                jmp -

            +
                rts

hello_world:
db "HELLO, WORLD!",$ff

build_string:
include "build/build.asm"

hdma_table:
db $ff
dw $0000,%0'11111'00000'00000
dw $0000,%0'11110'00000'00001
dw $0000,%0'11101'00000'00010
dw $0000,%0'11100'00000'00011
dw $0000,%0'11011'00000'00100
dw $0000,%0'11010'00000'00101
dw $0000,%0'11001'00000'00110
dw $0000,%0'11000'00000'00111
dw $0000,%0'10111'00000'01000
dw $0000,%0'10110'00000'01001
dw $0000,%0'10101'00000'01010
dw $0000,%0'10100'00000'01011
dw $0000,%0'10011'00000'01100
dw $0000,%0'10010'00000'01101
dw $0000,%0'10001'00000'01110
dw $0000,%0'10000'00000'01111
dw $0000,%0'01111'00000'10000
dw $0000,%0'01110'00000'10001
dw $0000,%0'01101'00000'10010
dw $0000,%0'01100'00000'10011
dw $0000,%0'01011'00000'10100
dw $0000,%0'01010'00000'10101
dw $0000,%0'01001'00000'10110
dw $0000,%0'01000'00000'10111
dw $0000,%0'00111'00000'11000
dw $0000,%0'00110'00000'11001
dw $0000,%0'00101'00000'11010
dw $0000,%0'00100'00000'11011
dw $0000,%0'00011'00000'11100
dw $0000,%0'00010'00000'11101
dw $0000,%0'00001'00000'11110
dw $0000,%0'00000'00000'11111
dw $0000,%0'00000'00001'11110
dw $0000,%0'00000'00010'11101
dw $0000,%0'00000'00011'11100
dw $0000,%0'00000'00100'11011
dw $0000,%0'00000'00101'11010
dw $0000,%0'00000'00110'11001
dw $0000,%0'00000'00111'11000
dw $0000,%0'00000'01000'10111
dw $0000,%0'00000'01001'10110
dw $0000,%0'00000'01010'10101
dw $0000,%0'00000'01011'10100
dw $0000,%0'00000'01100'10011
dw $0000,%0'00000'01101'10010
dw $0000,%0'00000'01110'10001
dw $0000,%0'00000'01111'10000
dw $0000,%0'00000'10000'01111
dw $0000,%0'00000'10001'01110
dw $0000,%0'00000'10010'01101
dw $0000,%0'00000'10011'01100
dw $0000,%0'00000'10100'01011
dw $0000,%0'00000'10101'01010
dw $0000,%0'00000'10110'01001
dw $0000,%0'00000'10111'01000
dw $0000,%0'00000'11000'00111
dw $0000,%0'00000'11001'00110
dw $0000,%0'00000'11010'00101
dw $0000,%0'00000'11011'00100
dw $0000,%0'00000'11100'00011
dw $0000,%0'00000'11101'00010
dw $0000,%0'00000'11110'00001
dw $0000,%0'00000'11111'00000
dw $0000,%0'00001'11110'00000
dw $0000,%0'00010'11101'00000
dw $0000,%0'00011'11100'00000
dw $0000,%0'00100'11011'00000
dw $0000,%0'00101'11010'00000
dw $0000,%0'00110'11001'00000
dw $0000,%0'00111'11000'00000
dw $0000,%0'01000'10111'00000
dw $0000,%0'01001'10110'00000
dw $0000,%0'01010'10101'00000
dw $0000,%0'01011'10100'00000
dw $0000,%0'01100'10011'00000
dw $0000,%0'01101'10010'00000
dw $0000,%0'01110'10001'00000
dw $0000,%0'01111'10000'00000
dw $0000,%0'10000'01111'00000
dw $0000,%0'10001'01110'00000
dw $0000,%0'10010'01101'00000
dw $0000,%0'10011'01100'00000
dw $0000,%0'10100'01011'00000
dw $0000,%0'10101'01010'00000
dw $0000,%0'10110'01001'00000
dw $0000,%0'10111'01000'00000
dw $0000,%0'11000'00111'00000
dw $0000,%0'11001'00110'00000
dw $0000,%0'11010'00101'00000
dw $0000,%0'11011'00100'00000
dw $0000,%0'11100'00011'00000
dw $0000,%0'11101'00010'00000
dw $0000,%0'11110'00001'00000
dw $0000,%0'11111'00000'00000
dw $0000,%0'11110'00000'00001
dw $0000,%0'11101'00000'00010
dw $0000,%0'11100'00000'00011
dw $0000,%0'11011'00000'00100
dw $0000,%0'11010'00000'00101
dw $0000,%0'11001'00000'00110
dw $0000,%0'11000'00000'00111
dw $0000,%0'10111'00000'01000
dw $0000,%0'10110'00000'01001
dw $0000,%0'10101'00000'01010
dw $0000,%0'10100'00000'01011
dw $0000,%0'10011'00000'01100
dw $0000,%0'10010'00000'01101
dw $0000,%0'10001'00000'01110
dw $0000,%0'10000'00000'01111
dw $0000,%0'01111'00000'10000
dw $0000,%0'01110'00000'10001
dw $0000,%0'01101'00000'10010
dw $0000,%0'01100'00000'10011
dw $0000,%0'01011'00000'10100
dw $0000,%0'01010'00000'10101
dw $0000,%0'01001'00000'10110
dw $0000,%0'01000'00000'10111
dw $0000,%0'00111'00000'11000
dw $0000,%0'00110'00000'11001
dw $0000,%0'00101'00000'11010
dw $0000,%0'00100'00000'11011
dw $0000,%0'00011'00000'11100
dw $0000,%0'00010'00000'11101
dw $0000,%0'00001'00000'11110
dw $0000,%0'00000'00000'11111
dw $0000,%0'00000'00001'11110
dw $0000,%0'00000'00010'11101
db $e1
dw $0000,%0'00000'00011'11100
dw $0000,%0'00000'00100'11011
dw $0000,%0'00000'00101'11010
dw $0000,%0'00000'00110'11001
dw $0000,%0'00000'00111'11000
dw $0000,%0'00000'01000'10111
dw $0000,%0'00000'01001'10110
dw $0000,%0'00000'01010'10101
dw $0000,%0'00000'01011'10100
dw $0000,%0'00000'01100'10011
dw $0000,%0'00000'01101'10010
dw $0000,%0'00000'01110'10001
dw $0000,%0'00000'01111'10000
dw $0000,%0'00000'10000'01111
dw $0000,%0'00000'10001'01110
dw $0000,%0'00000'10010'01101
dw $0000,%0'00000'10011'01100
dw $0000,%0'00000'10100'01011
dw $0000,%0'00000'10101'01010
dw $0000,%0'00000'10110'01001
dw $0000,%0'00000'10111'01000
dw $0000,%0'00000'11000'00111
dw $0000,%0'00000'11001'00110
dw $0000,%0'00000'11010'00101
dw $0000,%0'00000'11011'00100
dw $0000,%0'00000'11100'00011
dw $0000,%0'00000'11101'00010
dw $0000,%0'00000'11110'00001
dw $0000,%0'00000'11111'00000
dw $0000,%0'00001'11110'00000
dw $0000,%0'00010'11101'00000
dw $0000,%0'00011'11100'00000
dw $0000,%0'00100'11011'00000
dw $0000,%0'00101'11010'00000
dw $0000,%0'00110'11001'00000
dw $0000,%0'00111'11000'00000
dw $0000,%0'01000'10111'00000
dw $0000,%0'01001'10110'00000
dw $0000,%0'01010'10101'00000
dw $0000,%0'01011'10100'00000
dw $0000,%0'01100'10011'00000
dw $0000,%0'01101'10010'00000
dw $0000,%0'01110'10001'00000
dw $0000,%0'01111'10000'00000
dw $0000,%0'10000'01111'00000
dw $0000,%0'10001'01110'00000
dw $0000,%0'10010'01101'00000
dw $0000,%0'10011'01100'00000
dw $0000,%0'10100'01011'00000
dw $0000,%0'10101'01010'00000
dw $0000,%0'10110'01001'00000
dw $0000,%0'10111'01000'00000
dw $0000,%0'11000'00111'00000
dw $0000,%0'11001'00110'00000
dw $0000,%0'11010'00101'00000
dw $0000,%0'11011'00100'00000
dw $0000,%0'11100'00011'00000
dw $0000,%0'11101'00010'00000
dw $0000,%0'11110'00001'00000
dw $0000,%0'11111'00000'00000
dw $0000,%0'11110'00000'00001
dw $0000,%0'11101'00000'00010
dw $0000,%0'11100'00000'00011
dw $0000,%0'11011'00000'00100
dw $0000,%0'11010'00000'00101
dw $0000,%0'11001'00000'00110
dw $0000,%0'11000'00000'00111
dw $0000,%0'10111'00000'01000
dw $0000,%0'10110'00000'01001
dw $0000,%0'10101'00000'01010
dw $0000,%0'10100'00000'01011
dw $0000,%0'10011'00000'01100
dw $0000,%0'10010'00000'01101
dw $0000,%0'10001'00000'01110
dw $0000,%0'10000'00000'01111
dw $0000,%0'01111'00000'10000
dw $0000,%0'01110'00000'10001
dw $0000,%0'01101'00000'10010
dw $0000,%0'01100'00000'10011
dw $0000,%0'01011'00000'10100
dw $0000,%0'01010'00000'10101
dw $0000,%0'01001'00000'10110
dw $0000,%0'01000'00000'10111
dw $0000,%0'00111'00000'11000
dw $0000,%0'00110'00000'11001
dw $0000,%0'00101'00000'11010
dw $0000,%0'00100'00000'11011
dw $0000,%0'00011'00000'11100
dw $0000,%0'00010'00000'11101
dw $0000,%0'00001'00000'11110
dw $0000,%0'00000'00000'11111
dw $0000,%0'00000'00001'11110
dw $0000,%0'00000'00010'11101
dw $0000,%0'00000'00011'11100
dw $0000,%0'00000'00100'11011
dw $0000,%0'00000'00101'11010
dw $0000,%0'00000'00110'11001
db $00
