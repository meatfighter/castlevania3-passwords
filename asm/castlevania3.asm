; Segments of "Castlevania III: Dracula's Curse" related to password encoding and decoding.

; RAM map
;
; Addr Size Description
; ---- ---- -----------------------------------------------------------------------------------------------------------
; 0004      toggleMask (50 or A0)
; 0008    9 _unscrambledPassword
; 0010      _nameHash (00--07)
; 001A      frameCounter (00--FF)
; 002E      savePoint (00--11)
; 002F      escapedClockTower (00 = no, 01 = yes)
; 0032      block (00--0E)
; 0032      subBlock (zero-indexed)
; 0035      lives
; 003A      partner (FF = none, 01 = Sypha, 02 = Grant, 03 = Alucard)
; 003C      playerEnergy (00--40)
; 003D      bossEnergy (00--40)
; 00FF      hud (B0 = visible, B1 = hidden)
; 0084      hearts
; 0400   16 SPRITE_0
; 041C   16 MARK_YS
; 0438   16 MARK_XS
; 0454   16 MARK_ATTRIBS
; 048C   16 SPRITE_1
; 0788      payload (b765 = name hash, b4 = savePoint.0, b3 = frameCounter.0, b21 = partner, b0 = mode)
; 0789      payloadHash
; 078A      nameHash (00--07)
; 078B      badPasswordReason
; 078F      scramblesRowIndex (00--02)
; 0790   16 password (b54 = row, b32 = column, b10 = mark [0 = none, 1 = whip, 2 = rosary, 3 = heart])
; 07A0    9 unscrambledPassword
; 07F6      mode (00 = normal, 01 = hard)
; 07F8    8 name ([ ] = 00, [.] = 4B, [A-Z!?] = 50--6B)

; ROM map
;
; bk:addr Description
; ------- -------------------------------------------------------------------------------------------------------------
; 00:8FB0 convertBlockSubBlockToSavePoint()
; 00:8FD1 BLOCK_SUB_BLOCK_TO_SAVE_POINT (45 bytes)
; 00:8FFE checkForSpecialNames()
; 00:9005 checkForSomeSpecialNames()
; 00:9031 isSpecialName()
; 00:904D SPECIAL_NAME_ADDRESSES (5 words)
; 00:9057 SPECIAL_NAMES (40 bytes)
; 00:90C0 resetHeartsAndEnergy()
; 00:90CD reset4Aand4D()
;
; 03:B2F8 submitPassword()
; 03:B339 handleValidPassword:
; 03:B5AF showPassword()
; 03:B647 _drawPassword()
; 03:B64A encode()
; 03:B656 decode()
; 03:B675 resetPasswordVars()
; 03:B682 clearPassword()
; 03:B68F unscramblePassword()
; 03:B6B2 SCRAMBLES (27 bytes)
; 03:B6CD hashName()
; 03:B6E6 NAME_HASH_SEEDS (8 bytes)
; 03:B6EE encodePayload()
; 03:B756 extractPayloadVarsAndVerifyNameHash()
; 03:B79A findScrambles()
; 03:B72A hashPayload()
; 03:B7D6 throwDefaultBadPassword:
; 03:B7D8 throwBadPassword:
; 03:B7DF LEADERS (3 bytes)
; 03:B7E2 squeezeRowCol()
; 03:B7F0 verifyAllNonblanksInScrambles()
; 03:B82C decodePayloadAndPayloadHash()
; 03:B865 verifyPayloadHash()
; 03:B87F isValidSavePoint()
; 03:B8B6 VALID_SAVE_POINTS (6 bytes)
; 03:B8BC BIT_MASKS (8 bytes)
; 03:B8C4 createUnscrambledPassword:
; 03:B940 drawPassword()
; 03:B937 SELECTORS (9 bytes)
; 03:B97E SPRITE_B (4 bytes)
; 03:B982 SPRITE_A (4 bytes)
; 03:B986 MATRIX_COORDINATES (32 bytes)
;
; 7F:E2E6 switchBanks()
; 7F:E593 _checkForSomeSpecialNames()


; convertBlockSubBlockToSavePoint()
00:8FB0  LDA $0032
00:8FB2  ASL A
00:8FB3  CLC
00:8FB4  ADC $0032
00:8FB6  TAY          ; Y = 3 * block;
00:8FB7  LDA $8FD1,Y  ; if (subBlock > BLOCK_SUB_BLOCK_TO_SAVE_POINT[Y]) {
00:8FBA  CMP $0033    ;     ++Y;
00:8FBC  BCS $8FBF    ; }
00:8FBE  INY
00:8FBF  LDA $8FD2,Y
00:8FC2  CMP #$03
00:8FC4  BEQ $8FC9
00:8FC6  STA $002E    ; savePoint = (BLOCK_SUB_BLOCK_TO_SAVE_POINT[Y + 1] != 3 || escapedClockTower == 0)
                      ;         ? BLOCK_SUB_BLOCK_TO_SAVE_POINT[Y + 1] : 4;
00:8FC8  RTS
00:8FC9  LDY $002F
00:8FCB  BEQ $8FC6
00:8FCD  LDA #$04
00:8FCF  BNE $8FC6    ; return;

; BLOCK_SUB_BLOCK_TO_SAVE_POINT
; Each row corresponds to a block. Each block contains 1 or 2 save points. If a block contains 1 save point, the first
; column contains $10 and the second and third columns both contain its save point. Otherwise, if the sub-block exceeds
; the value in the first column, then the save point in the third column is used; else, the save point in the second
; column is used.
00:8FD1  .byte $10, $00, $00 ; 0: 1-1
00:8FD4  .byte $02, $01, $02 ; 1: 2-1, 2-4
00:8FD7  .byte $10, $03, $04 ; 2: 3-0, 3-1
00:8FDA  .byte $10, $05, $05 ; 3: 4-A
00:8FDD  .byte $10, $06, $06 ; 4: 5-A
00:8FE0  .byte $10, $07, $07 ; 5: 6-A
00:8FE3  .byte $10, $08, $08 ; 6: 4-1
00:8FE6  .byte $04, $09, $0A ; 7: 5-1, 5-6
00:8FE9  .byte $10, $0B, $0B ; 8: 6-1
00:8FEC  .byte $10, $0C, $0C ; 9: 6-1'
00:8FEF  .byte $10, $0D, $0D ; A: 7-1
00:8FF2  .byte $10, $0E, $0E ; B: 7-A
00:8FF5  .byte $10, $0F, $0F ; C: 8-1
00:8FF8  .byte $10, $10, $10 ; D: 9-1
00:8FFB  .byte $10, $11, $11 ; E: A-1

; checkForSpecialNames()
; out: carry (false = no, true = yes)
;      Y (1 = "HELP ME ", 2 = "AKAMA   ", 3 = "OKUDA   ", 4, = "URATA   ", 5 = "FUJIMOTO")
00:8FFE  LDY #$00     ; Y = 0;
00:9000  JSR $9031    ; if (isSpecialName()) {
00:9003  BCS $902E    ;     Y = 1;
                      ;     return;
                      ; }

; checkForSomeSpecialNames()
; out: carry (false = no, true = yes)
;      Y (2 = "AKAMA   ", 3 = "OKUDA   ", 4, = "URATA   ", 5 = "FUJIMOTO")
00:9005  LDY #$02     ; Y = 2;
00:9007  JSR $9031    ; if (isSpecialName()) {
00:900A  BCS $902B    ;     Y = 2;
                      ;     return;
                      ; }

00:900C  LDY #$04     ; Y = 4;
00:900E  JSR $9031    ; if (isSpecialName()) {
00:9011  BCS $9022    ;     Y = 3;
                      ;     return;
                      ; }

00:9013  LDY #$06     ; Y = 6;
00:9015  JSR $9031    ; if (isSpecialName()) {
00:9018  BCS $9025    ;     Y = 4;
                      ;     return;
                      ; }

00:901A  LDY #$08     ; Y = 8;
00:901C  JSR $9031    ; if (isSpecialName()) {
00:901F  BCS $9028    ;     Y = 5;
                      ;     return;
                      ; }

00:9021  RTS

00:9022  LDY #$03
00:9024  RTS

00:9025  LDY #$04
00:9027  RTS

00:9028  LDY #$05
00:902A  RTS

00:902B  LDY #$02
00:902D  RTS

00:902E  LDY #$01
00:9030  RTS

; isSpecialName()
;  in: Y (2 * special name index)
; out: carry (false = no, true = yes)
00:9031  LDA $904D,Y
00:9034  STA $0008
00:9036  LDA $904E,Y
00:9039  STA $0009    ; specialName = *SPECIAL_NAME_ADDRESSES[Y / 2];
00:903B  LDY #$00     ;
00:903D  LDA $07F8,Y  ; for (Y = 0; Y < 8; ++Y) {
00:9040  CMP ($08),Y  ;     if (name[Y] != specialName[Y]) {
00:9042  BNE $904B    ;         carry = false;
00:9044  INY          ;         return;
00:9045  CPY #$08     ;     }
00:9047  BNE $903D    ; }

00:9049  SEC          ; carry = true;
00:904A  RTS          ; return;

00:904B  CLC
00:904C  RTS

; SPECIAL_NAME_ADDRESSES
00:904D  .word $9057, $905F, $9067, $906F, $9077

; SPECIAL_NAMES
00:9057  .byte $57, $54, $5B, $5F, $00, $5C, $54, $00  ; "HELP ME " // Start and continue with 10 lives.
00:905F  .byte $50, $5A, $50, $5C, $50, $00, $00, $00  ; "AKAMA   " // Start in Hard Mode alone.
00:9067  .byte $5E, $5A, $64, $53, $50, $00, $00, $00  ; "OKUDA   " // Start in Normal Mode with Alucard.
00:096F  .byte $64, $61, $50, $63, $50, $00, $00, $00  ; "URATA   " // Start in Normal Mode with Sypha.
00:0977  .byte $55, $64, $59, $58, $5C, $5E, $63, $5E  ; "FUJIMOTO" // Start in Normal Mode with Grant.


00:907F  LDA #$B0
00:9081  STA $00FF    ; hud = 0xB0; // visible
00:9083  JSR $90CD    ; reset4Aand4D();
00:9086  JSR $90C0    ; resetHeartsAndEnergy();
00:9089  LDA #$02
00:908B  STA $003E    ; mem[$003E] = 0x02;
00:908D  JSR $8FFE    ; checkForSpecialNames(); // results in carry and Y
00:9090  BCC $90B7    ; if (carry == 1) { // if special name
00:9092  DEY          ;     if (--Y == 0) {
00:9093  BEQ $90BC    ;         lives = 10;
                      ;         return; // "HELP ME ": start/continue with 10 lives
                      ;     }
00:9095  DEY          ;     if (--Y == 0) {
00:9096  BEQ $90B2    ;         lives = 2;
                      ;         mode = 1;
                      ;         return; // "AKAMA   ": start/continue in Hard Mode alone
                      ;     }
00:9098  LDA $003A    ;     if (partner != 0xFF) { // if (partner != none)
00:909A  CMP #$FF     ;         lives = 2;
00:909C  BNE $90B7    ;         return; // continue in Normal Mode with a partner
                      ;     }
00:909E  DEY          ;     if (--Y == 0) {
00:909F  BEQ $90AC    ;         partner = 0x03;
                      ;         lives = 2;
                      ;         return; // "OKUDA   ": start/continue in Normal Mode with Alucard
                      ;     }
00:90A1  DEY          ;     if (--Y == 0) {
00:90A2  BEQ $90A8    ;         partner = 0x01;
                      ;         lives = 2;
                      ;         return; ; "URATA   ": start/continue in Normal Mode with Sypha.
                      ;     }
00:90A4  LDA #$02
00:90A6  BNE $90AE
00:90A8  LDA #$01
00:90AA  BNE $90AE
00:90AC  LDA #$03
00:90AE  STA $003A    ;     partner = 0x02;
00:90B0  BNE $90B7    ; }
00:90B2  LDA #$01
00:90B4  STA $07F6
00:90B7  LDA #$02
00:90B9  STA $0035    ; lives = 2;
00:90BB  RTS          ; return;
00:90BC  LDA #$10
00:90BE  BNE $90B9

; resetHeartsAndEnergy()
00:90C0  LDA #$05
00:90C2  STA $0084    ; hearts = 5;
00:90C4  LDA #$40
00:90C6  STA $003C    ; playerEnergy = 0x40; // full energy
00:90C8  LDA #$40
00:90CA  STA $003D    ; bossEnergy = 0x40; // full energy
00:90CC  RTS          ; return;

; reset4Aand4D()
00:90CD  LDA #$40
00:90CF  STA $004A    ; mem[0x004A] = 0x40;
00:90D1  LDA #$43
00:90D3  STA $004D    ; mem[0x004D] = 0x43;
00:90D5  RTS          ; return;

; submitPassword()
03:B2F8  INC $0019
03:B2FA  JSR $B48D
03:B2FD  JMP $B471
03:B300  JSR $B3DB
03:B303  JSR $B50C
03:B306  JSR $B3B9
03:B309  LDA $0026
03:B30B  AND #$30
03:B30D  BNE $B313
03:B30F  LDA $002D
03:B311  BEQ $B338
03:B313  LDA $0026
03:B315  AND #$20
03:B317  BNE $B349
03:B319  JSR $B656    ; decode();
03:B31C  LDX #$05
03:B31E  JSR $B627
03:B321  LDA $078B    ; if (badPasswordReason == 0) {
03:B324  BEQ $B339    ;     goto handleValidPassword;
03:B326  LDA #$40     ; }
03:B328  JSR $E25F
03:B32B  LDA #$09
03:B32D  STA $0019
03:B32F  LDA #$23
03:B331  JSR $ECE9
03:B334  LDA #$78
03:B336  STA $0030
03:B338  RTS          ; return;

; handleValidPassword:
03:B339  LDA #$78
03:B33B  STA $0030
03:B33D  LDA #$07
03:B33F  STA $0160
03:B342  LDA #$0A
03:B344  STA $0019
03:B346  JMP $B066
03:B349  JSR $B066
03:B34C  LDA #$0B
03:B34E  STA $0019
03:B350  RTS          ; return;

; showPassword()
03:B5AF  STA $0025
03:B5B1  STA $5105
03:B5B4  JSR $EBFD
03:B5B7  LDA #$98
03:B5B9  LDX #$1A
03:B5BB  JSR $EBD5
03:B5BE  JSR $E2D6
03:B5C1  LDA #$62
03:B5C3  JSR $E25F
03:B5C6  INC $0019
03:B5C8  JSR $B1C7
03:B5CB  JSR $B625
03:B5CE  JSR $B675    ; resetPasswordVars();
03:B5D1  JSR $B64A    ; encode();
03:B5D4  JSR $B28B
03:B5D7  JSR $B647    ; _drawPassword();
03:B5DA  JSR $B066
03:B5DD  LDA #$03
03:B5DF  STA $001C
03:B5E1  JMP $B3FB
03:B5E4  LDA $00B4
03:B5E6  CMP #$FF
03:B5E8  BEQ $B604
03:B5EA  LDA $001D
03:B5EC  STA $0015
03:B5EE  JSR $B598
03:B5F1  JSR $FBA4
03:B5F4  LDA $00B4
03:B5F6  CMP #$FF
03:B5F8  BNE $B60F
03:B5FA  LDA #$00
03:B5FC  LDX $0015
03:B5FE  STX $001D
03:B600  STA $0300,X
03:B603  RTS          ; return;

; _drawPassword()
03:B647  JMP $B940    ; drawPassword();

; encode()
03:B64A  JSR $B6CD    ; hashName(); // result in A
03:B64D  STA $078A    ; nameHash = A;
03:B650  JSR $B6EE    ; encodePayload();
03:B653  JMP $B8C4    ; goto createUnscrambledPassword;

; decode()
03:B656  JSR $B6CD    ; hashName(); // result in A
03:B659  STA $0010    ; _nameHash = A;
03:B65B  JSR $B79A    ; findScrambles();
03:B65E  JSR $B7F0    ; verifyAllNonblanksInScrambles();
03:B661  JSR $B68F    ; unscramblePassword();
03:B664  JSR $B82C    ; decodePayloadAndPayloadHash();
03:B667  JSR $E593    ; _checkForSomeSpecialNames(); // results in carry and Y
03:B66A  BCS $B66F    ; if (carry == 1) {
03:B66C  JSR $B87F    ;     isValidSavePoint(); // name is special
                      ; }
03:B66F  JSR $B756    ; extractPayloadVarsAndVerifyNameHash();
03:B672  JMP $B865    ; verifyPayloadHash();

; resetPasswordVars()
03:B675  LDA #$00
03:B677  LDX #$00     ; for (X = 0; X < 0x10; ++X) {
03:B679  STA $0780,X  ;     mem[0x0780 + X] = 0;
03:B67C  INX
03:B67D  CPX #$10
03:B67F  BCC $B679    ; }
03:B681  RTS          ; return;

; clearPassword()
03:B682  LDY #$00
03:B684  LDA #$00     ; for (Y = 0; Y < 0x10; ++Y) {
03:B686  STA $0790,Y  ;     password[Y] = 0; // no mark
03:B689  INY
03:B68A  CPY #$10
03:B68C  BCC $B686    ; }
03:B68E  RTS          ; return;

; unscramblePassword()
; Copies 9 marks from password to unscrambledPassword based on the SCRAMBLES[9 * scramblesRowIndex] sequence.
03:B68F  LDX #$00
03:B691  LDA $078F
03:B694  ASL A
03:B695  ASL A
03:B696  ASL A
03:B697  ADC $078F
03:B69A  STA $0000
03:B69C  LDY $0000    ; for (X = 0; X < 9; ++X, ++v0000) {
03:B69E  LDA $B6B2,Y  ;     A = SCRAMBLES[9 * scramblesRowIndex + X];
03:B6A1  JSR $B7E2    ;     squeezeRowCol(); // result in Y
03:B6A4  LDA $0790,Y
03:B6A7  STA $07A0,X  ;     unscrambledPassword[X] = password[Y];
03:B6AA  INC $0000
03:B6AC  INX
03:B6AD  CPX #$09
03:B6AF  BCC $B69C    ; }
03:B6B1  RTS          ; return;

; SCRAMBLES
; This table contains 3 sequences of matrix elements used to encode the game state. The row and column are stored in
; the high and low nibbles, respectively.
03:B6B2  .byte $00, $33, $20, $13, $22, $01, $11, $03, $32  ; 0
03:B6BB  .byte $12, $10, $02, $32, $23, $13, $30, $21, $01  ; 1
03:B6C4  .byte $31, $13, $01, $22, $10, $30, $33, $03, $21  ; 2

; hashName()
; out: A = name hash (0--7)
03:B6CD  LDA #$00
03:B6CF  STA $0000    ; sum = 0;
03:B6D1  TAX
03:B6D2  LDA $07F8,X  ; for (X = 0; X < 8; ++X) {
03:B6D5  CLC
03:B6D6  ADC $B6E6,X
03:B6D9  CLC
03:B6DA  ADC $0000
03:B6DC  STA $0000    ;     sum += name[X] + NAME_HASH_SEEDS[X];
03:B6DE  INX
03:B6DF  CPX #$08
03:B6E1  BNE $B6D2    ; }
03:B6E3  AND #$07     ; A = sum % 8;
03:B6E5  RTS          ; return;

; NAME_HASH_SEEDS
; Due to the modulo operation, this table is pointless; the values can be tallied ahead of time. However, the
; intention may have been to apply this table only to the nonblank characters. But that check is not there.
03:B6E6  .byte $07, $03, $01, $06, $02, $04, $05, $00

; encodePayload()
03:B6EE  LDA $078A
03:B6F1  STA $0000    ; payload = nameHash;
03:B6F3  LDA $002E    ; if (savePoint >= 0x11) {
03:B6F5  CMP #$11     ;     savePoint = 0x11;
03:B6F7  BCC $B6FB    ; }
03:B6F9  LDA #$11
03:B6FB  STA $002E
03:B6FD  LSR A
03:B6FE  ROL $0000    ; payload = (payload << 1) | (savePoint & 1);
03:B700  LDA $001A
03:B702  LSR A
03:B703  ROL $0000    ; payload = (payload << 1) | (frameCounter & 1);
03:B705  ROL $0000
03:B707  ROL $0000
03:B709  LDA $003A
03:B70B  BPL $B70F
03:B70D  LDA #$00
03:B70F  ORA $0000    ; payload = (payload << 2) | (partner == 0xFF ? 0 : partner);
03:B711  ASL A
03:B712  ORA $07F6
03:B715  STA $0788    ; payload = (payload << 1) | mode;
03:B718  LDA $001A
03:B71A  LSR A
03:B71B  LDA #$50
03:B71D  BCC $B721
03:B71F  LDA #$A0
03:B721  STA $0004    ; toggleMask = (frameCounter & 1) == 0 ? 0xA0 : 0x50;
03:B723  JSR $B72A    ; hashPayload(payload); // result in A
03:B726  STA $0789    ; payloadHash = A;
03:B729  RTS          ; return;

; hashPayload()
03:B72A  LDA $0788
03:B72D  AND #$F0
03:B72F  STA $0002    ; highNibble = payload & 0xF0;
03:B731  LDA $0788
03:B734  ASL A
03:B735  ASL A
03:B736  ASL A
03:B737  ASL A
03:B738  STA $0003    ; lowNibble = payload << 4;
03:B73A  CLC
03:B73B  ADC $0002
03:B73D  STA $0001    ; nibbleSum = highNibble + lowNibble;
03:B73F  LDA $0004
03:B741  EOR $0002
03:B743  STA $0000    ; toggledHighNibble = highNibble ^ toggleMask;
03:B745  LDA $0004
03:B747  EOR $0003
03:B749  CLC
03:B74A  ADC $0000
03:B74C  LSR A
03:B74D  LSR A
03:B74E  LSR A
03:B74F  LSR A
03:B750  ORA $0001
03:B752  CLC
03:B753  ADC $002E    ; A = savePoint + (nibbleSum | ((toggledHighNibble + (lowNibble ^ toggleMask)) >> 4));
03:B755  RTS          ; return;

; extractPayloadVarsAndVerifyNameHash()
03:B756  LDA $0788
03:B759  AND #$01
03:B75B  STA $07F6    ; mode = payload & 1;
03:B75E  LDA $0788
03:B761  LSR A
03:B762  AND #$03     ; A = (payload >> 1) & 3;
03:B764  BNE $B768    ; if (A == 0) {
03:B766  LDA #$FF     ;     A = 0xFF; // no partner
                      ; }
03:B768  STA $003A    ; partner = A;
03:B76A  LDA $0788
03:B76D  AND #$10
03:B76F  BEQ $B777
03:B771  LDA $002E
03:B773  ORA #$01     ; if ((payload & 0x10) != 0) {
03:B775  STA $002E    ;     savePoint |= 1;
03:B777  LDA $0788    ; }
03:B77A  LSR A
03:B77B  LSR A
03:B77C  LSR A
03:B77D  LSR A
03:B77E  LSR A
03:B77F  STA $078A    ; nameHash = payload >> 5;
03:B782  CMP $0010    ; if (nameHash != _nameHash) {
03:B784  BEQ $B78B    ;     A = 0x10;
03:B786  LDA #$10     ;     goto throwBadPassword;
03:B788  JMP $B7D8    ; }
03:B78B  LDA $002E    ; if (savePoint == 2 || savePoint == 4) {
03:B78D  CMP #$02     ;     escapedClockTower = 1;
03:B78F  BEQ $B795    ; }
03:B791  CMP #$04
03:B793  BNE $B799
03:B795  LDA #$01
03:B797  STA $002F
03:B799  RTS          ; return;

; findScrambles()
03:B79A  LDA #$02
03:B79C  STA $0000
03:B79E  LDA #$00
03:B7A0  STA $0001    ; markCount = 0;
03:B7A2  LDY $0000    ; for (i = 2; i >= 0; --i) {
03:B7A4  LDA $B7DF,Y  ;     Y = LEADERS[i];
03:B7A7  JSR $B7E2    ;     squeezeRowCol(); // result in Y
03:B7AA  LDA $0790,Y  ;     if ((password[Y] & 3) == 0) {
03:B7AD  AND #$03     ;         continue; // if blank, continue
03:B7AF  BEQ $B7CB    ;     }
03:B7B1  LDA $0000
03:B7B3  STA $078F    ;     scramblesRowIndex = i;
03:B7B6  INC $0001    ;     ++markCount;
03:B7B8  LDX #$00     ;     for (X = 0; X < 9; ++X) {
03:B7BA  LDA $0790,Y  ;
03:B7BD  CMP $B937,X  ;         if (password[Y] == SELECTORS[X]) {
03:B7C0  BEQ $B7C7    ;             break;
03:B7C2  INX          ;         }
03:B7C3  CPX #$09
03:B7C5  BNE $B7BD    ;     }
03:B7C7  TXA
03:B7C8  ASL A
03:B7C9  STA $002E    ;     savePoint = X << 1;
03:B7CB  DEC $0000
03:B7CD  BPL $B7A2    ; }
03:B7CF  LDA $0001    ; if (markCount != 1) {
03:B7D1  CMP #$01     ;     goto throwDefaultBadPassword;
03:B7D3  BNE $B7D6    ; }
03:B7D5  RTS          ; return;

throwDefaultBadPassword:
03:B7D6  LDA #$01     ; A = 1;

throwBadPassword:
;  in: A = bad password reason
03:B7D8  ORA $078B
03:B7DB  STA $078B    ; badPasswordReason |= A;
03:B7DE  RTS          ; return;

; LEADERS
; Exactly one of the elements at (0, 0), (1, 2), and (3, 1) is marked nonblank. The index of the element of this table
; corresponding to that nonblank mark determines which of the 3 scramble sequences is used (scramblesRowIndex).
03:B7DF  .byte $00, $12, $31

; squeezeRowCol()
;  in: A = ..rr..cc
; out: Y = ....rrcc
03:B7E2  PHA
03:B7E3  AND #$30
03:B7E5  LSR A
03:B7E6  LSR A
03:B7E7  STA $0007
03:B7E9  PLA
03:B7EA  AND #$03
03:B7EC  ORA $0007
03:B7EE  TAY          ; Y = ((A & 0x30) >> 2) | (A & 0x03);
03:B7EF  RTS          ; return;

; verifyAllNonblanksInScrambles()
03:B7F0  LDA $078F
03:B7F3  ASL A
03:B7F4  ASL A
03:B7F5  ASL A
03:B7F6  ADC $078F
03:B7F9  STA $0000    ; scramblesRowOffset = 9 * scramblesRowIndex;
03:B7FB  LDA #$0F
03:B7FD  STA $0001
03:B7FF  LDY $0001    ; outer: for (rowCol = 0x0F; rowCol >= 0; --rowCol) { // ....rrcc
03:B801  LDA $0790,Y
03:B804  AND #$03
03:B806  BEQ $B827    ;     if ((password[rowCol] & 0x03) == 0) { // if blank, continue
                      ;         continue;
                      ;     }
03:B808  LDA $0000
03:B80A  STA $0002    ;     offset = scramblesRowOffset;
03:B80C  LDA #$09
03:B80E  STA $0003    ;     for (i = 9; i > 0; --i, ++offset) {
03:B810  LDY $0002
03:B812  LDA $B6B2,Y  ;         A = SCRAMBLES[offset];
03:B815  JSR $B7E2    ;         squeezeRowCol(); // result in Y
03:B818  CPY $0001    ;         if (Y == rowCol) {
03:B81A  BEQ $B827    ;             continue outer;
                      ;         }
03:B81C  INC $0002
03:B81E  DEC $0003
03:B820  BNE $B810    ;     }
03:B822  LDA #$02     ;     A = 2;
03:B824  JMP $B7D8    ;     goto throwBadPassword; // nonblank element not in scramble row
03:B827  DEC $0001
03:B829  BPL $B7FF    ; }
03:B82B  RTS          ; return;

; decodePayloadAndPayloadHash()
03:B82C  LDX #$00
03:B82E  LDA $07A1,X  ; for (X = 0; X < 8; ++X) {
03:B831  STA $08,X    ;     _unscrambledPassword[X] = unscrambledPassword[X + 1];
03:B833  INX
03:B834  CPX #$08
03:B836  BCC $B82E    ; }
03:B838  LDA #$00
03:B83A  STA $0000
03:B83C  STA $0001
03:B83E  LDY #$00     ; payloadHash = payload = 0;
03:B840  LDX #$00
03:B842  LSR $08,X    ; for (X = Y = 0; Y < 8; ++Y, ++X) {
03:B844  ROR $0001    ;     payloadHash = ((_unscrambledPassword[X] & 1)) << 7) | (payloadHash >> 1);
03:B846  LSR $08,X    ;     _unscrambledPassword[X] >>= 1;
03:B848  ROR $0000    ;     payload = ((_unscrambledPassword[X] & 1) << 7) | (payload >> 1);
03:B84A  INX          ;     _unscrambledPassword[X] >>= 1;
03:B84B  INY
03:B84C  CPY #$08
03:B84E  BCC $B842    ; }
03:B850  LDA $0001
03:B852  STA $0789
03:B855  LDA $0000
03:B857  STA $0788
03:B85A  AND #$10
03:B85C  LSR A
03:B85D  LSR A
03:B85E  LSR A
03:B85F  LSR A
03:B860  ORA $002E
03:B862  STA $002E    ; savePoint |= (payload & 0x10) >> 4;
03:B864  RTS          ; return;

; verifyPayloadHash()
03:B865  LDY #$50
03:B867  LDA $0788
03:B86A  AND #$08
03:B86C  BEQ $B870
03:B86E  LDY #$A0
03:B870  STY $0004    ; toggleMask = ((payload & 0x08) != 0) ? 0xA0 : 0x50;
03:B872  JSR $B72A    ; hashPayload(); // result in A
03:B875  CMP $0789    ; if (A == payloadHash) {
03:B878  BEQ $B864    ;     return;
                      ; }
03:B87A  LDA #$04     ; A = 4;
03:B87C  JMP $B7D8    ; goto throwBadPassword;

; isValidSavePoint()
03:B87F  LDA $0788    ; if ((payload & 1) != 0) {
03:B882  AND #$01     ;     return; // Hard Mode
03:B884  BNE $B8B5    ; }
03:B886  LDA $002E    ; if (savePoint >= 0x12) {
03:B888  CMP #$12     ;     A = 8;
03:B88A  BCS $B8B0    ;     goto throwBadPassword; // Invalid savePoint
                      ; }
03:B88C  CMP #$10     ; if (savePoint >= 0x10) {
03:B88E  BCS $B8B5    ;     return; // final 2 blocks
                      ; }
03:B890  LDA $0788
03:B893  AND #$06
03:B895  STA $0000    ; _partner = payload & 0x06;
03:B897  BEQ $B8B5    ; if (_partner == 0) {
                      ;     return; // no partner
                      ; }
03:B899  LDA $002E
03:B89B  AND #$08
03:B89D  LSR A
03:B89E  LSR A
03:B89F  LSR A
03:B8A0  ORA $0000
03:B8A2  TAY
03:B8A3  LDA $002E
03:B8A5  AND #$07
03:B8A7  TAX
03:B8A8  LDA $B8B4,Y
03:B8AB  AND $B8BC,X
03:B8AE  BNE $B8B5    ; if ((VALID_SAVE_POINTS[(_partner | ((savePoint & 0x08) >> 3)) - 2]
                      ;         & BIT_MASKS[savePoint & 0x07]) != 0) {
                      ;     return;
                      ; }
03:B8B0  LDA #$08
03:B8B2  JMP $B7D8
03:B8B5  RTS

; VALID_SAVE_POINTS
; In normal mode, a partner may only be used along pathway of save points which starts when the partner was first
; encountered in the game. Each bit of the elements of this table correspond to a save point. A partner may only be
; used in a save point where the associated bit is 1. Each pair of elements maps to a different partner. Within the
; pair, the bits correspond to the following save points:
; 0: (1-1, 2-1, 2-4, 3-0, 3-1, 4-A, 5-A, 6-A)
; 1: (4-1, 5-1, 5-6, 6-1, 6-1', 7-1, 7-A, 8-1)
; All partners may be used in save points 9-1 and A-1.
03:B8B6  .byte $07  ;   Sypha (4-A, 5-A, 6-A)
03:B8B7  .byte $03  ;   Sypha (7-A, 8-1)
03:B8B8  .byte $2F  ;   Grant (2-4, 3-1, 4-A, 5-A, 6-A)
03:B8B9  .byte $FF  ;   Grant (4-1, 5-1, 5-6, 6-1, 6-1', 7-1, 7-A, 8-1)
03:B8BA  .byte $00  ; Alucard ()
03:B8BB  .byte $3D  ; Alucard (5-6, 6-1, 6-1', 7-1, 8-1)

; BIT_MASKS
; This is used to extract bits from the elements of VALID_SAVE_POINTS.
03:B8BC  .byte $80, $40, $20, $10, $08, $04, $02, $01

createUnscrambledPassword:
03:B8C4  LDA $0788
03:B8C7  STA $0000    ; _payload = payload;
03:B8C9  LDA $0789
03:B8CC  STA $0001    ; _payloadHash = payloadHash;
03:B8CE  LDX #$08
03:B8D0  LDA #$00
03:B8D2  STA $08,X    ; for (X = 8; X >= 0; --X) {
03:B8D4  DEX          ;     _unscrambledPassword[X] = 0;
03:B8D5  BPL $B8D2    ; }
03:B8D7  LDX #$00
03:B8D9  LSR $0000    ; for (X = 0; X < 8; ++X) {
03:B8DB  ROL $08,X    ;     _unscrambledPassword[X] = (_unscrambledPassword[X] << 1) | (_payload & 1);
03:B8DD  LSR $0001    ;     _payload >>= 1;
03:B8DF  ROL $08,X    ;     _unscrambledPassword[X] = (_unscrambledPassword[X] << 1) | (_payloadHash & 1);
03:B8E1  INX          ;     _payloadHash >>= 1;
03:B8E2  CPX #$08
03:B8E4  BCC $B8D9    ; }
03:B8E6  LDA $002E
03:B8E8  LSR A
03:B8E9  TAY          ; Y = savePoint >> 1;
03:B8EA  LDX #$02
03:B8EC  LDA $B937,Y  ; for (X = 2; X >= 0; --X) {
03:B8EF  AND #$0C
03:B8F1  LSR A
03:B8F2  LSR A
03:B8F3  STA $0000
03:B8F5  LDA $B937,Y
03:B8F8  AND #$30
03:B8FA  ORA $0000    ;
03:B8FC  CMP $B7DF,X  ;     if (LEADERS[X] == ((SELECTORS[Y] & 0x30) | ((SELECTORS[Y] & 0x0C) >> 2))) {
03:B8FF  BEQ $B904    ;         break;
03:B901  DEX          ;     }
03:B902  BPL $B8EC    ; }
03:B904  STX $078F    ; scramblesRowIndex = X;
03:B907  TXA
03:B908  ASL A
03:B909  ASL A
03:B90A  ASL A
03:B90B  ADC $078F
03:B90E  TAY          ; Y = 9 * scramblesRowIndex;
03:B90F  LDX #$00
03:B911  LDA $B6B3,Y  ; for (X = 0; X < 9; ++X, ++Y) { // one too many iterations?
03:B914  AND #$30
03:B916  STA $0001
03:B918  LDA $B6B3,Y
03:B91B  AND #$03
03:B91D  ASL A
03:B91E  ASL A
03:B91F  ORA $0001
03:B921  ORA $08,X
03:B923  STA $07A1,X  ;     unscrambledPassword[X + 1] = ((SCRAMBLES[Y + 1] & 0x03)) << 2) | (SCRAMBLES[Y + 1] & 0x30)
03:B926  INY          ;             | _unscrambledPassword[X]; // ..rrccmm
03:B927  INX
03:B928  CPX #$09     ;
03:B92A  BCC $B911    ; }
03:B92C  LDA $002E
03:B92E  LSR A
03:B92F  TAY
03:B930  LDA $B937,Y
03:B933  STA $07A0    ; unscrambledPassword[0] = SELECTORS[savePoint >> 1];
03:B936  RTS          ; return;

; SELECTORS
; Exactly one of the elements at (0, 0), (1, 2), and (3, 1) is marked nonblank. This table contains the 9 possible ways
; to achieve that. The element to mark is determined by bits 1--4 of savePoint, which is used as the index into this
; table. Since savePoint cannot exceed $11, the index covers 0--8.
;              W00, H12, R00, W31, W12, H00, H31, R12, R31
03:B937  .byte $01, $1B, $02, $35, $19, $03, $37, $1A, $36

; drawPassword()
03:B940  LDA #$00
03:B942  STA $0000
03:B944  LDX #$05
03:B946  LDY $0000    ; for(X = 5, markIndex = 0; markIndex < 9; ++markIndex, ++X) {
03:B948  LDA $07A0,Y
03:B94B  AND #$03
03:B94D  TAY          ;     Y = unscrambledPassword[markIndex] & 0x03; // ......mm
03:B94E  LDA $B982,Y
03:B951  STA $0400,X  ;     SPRITE_0[X] = SPRITE_A[Y];
03:B954  LDA $B97E,Y
03:B957  STA $048C,X  ;     SPRITE_1[X] = SPRITE_B[Y];
03:B95A  LDY $0000
03:B95C  LDA $07A0,Y
03:B95F  AND #$3C
03:B961  LSR A
03:B962  TAY          ;     Y = (0x3C & unscrambledPassword[markIndex]) >> 1; // ...rrcc.
03:B963  LDA $B986,Y
03:B966  STA $041C,X  ;     MARK_YS[X] = MATRIX_COORDINATES[Y];
03:B969  LDA $B987,Y
03:B96C  STA $0438,X  ;     MARK_XS[X] = MATRIX_COORDINATES[Y + 1];
03:B96F  LDA #$00
03:B971  STA $0454,X  ;     MARK_ATTRIBS[X] = 0;
03:B974  INX
03:B975  INC $0000
03:B977  LDA $0000
03:B979  CMP #$09
03:B97B  BCC $B946    ; }
03:B97D  RTS          ; return;

; SPRITE_B
03:B97E  .byte $00, $14, $0C, $0C  ; blank, whip, rosary, heart

; SPRITE_A
03:B982  .byte $00, $42, $FC, $F4  ; blank, whip, rosary, heart

; MATRIX_COORDINATES
; These are (y, x)-coordinates corresponding to positions within the password matrix.
03:B986  .byte $7A, $5D, $7A, $75, $7A, $8D, $7A, $A5, $92, $5D, $92, $75, $92, $8D, $92, $A5
03:B996  .byte $AA, $5D, $AA, $75, $AA, $8D, $AA, $A5, $C2, $5D, $C2, $75, $C2, $8D, $C2, $A5

; switchBanks()
7F:E2E6  STA $0021
7F:E2E8  STA $5115
7F:E2EB  RTS          ; return;

; _checkForSomeSpecialNames()
; out: carry (false = no, true = yes)
;      Y (2 = "AKAMA   ", 3 = "OKUDA   ", 4, = "URATA   ", 5 = "FUJIMOTO")
7F:E593  LDA #$80     ; A = 0x80;
7F:E595  JSR $E2E6    ; switchBanks();
7F:E598  JSR $9005    ; checkForSomeSpecialNames();
7F:E59B  LDA #$82     ; A = 0x82;
7F:E59D  JMP $E2E6    ; switchBanks();