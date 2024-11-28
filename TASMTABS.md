# TASM TABLE SYNTAX DESCRIPTION

The tables that control TASM's interpretation of the source file are read from a file at run time. The table file name is determined by taking the numeric option field specified on the TASM command line and appending it to the string "TASM", then a ".TAB" extension is added. Thus, if the following command line is entered:

        tasm -51  test.asm

then TASM would read the table file named "TASM51.TAB".

The following rules apply to the structure of the table file:

*   The first line of the file should contain a string surrounded by double quotes that should identify the version of the assembler table. This string will appear at the top of each page in the list file. It should be limited to 24 characters.
*   Any line that starts with a '.' is considered a directive. Directives should preceed instruction defintion lines. The following directives are available:

|     |     |
| --- | --- |
| **DIRECTIVE** | **DESCRIPTION** |
| MSFIRST | Generate opcodes MS byte first. Useful for tables with multibyte opcodes. |
| ALTWILD | Use '@' instead of '\*' as the wild card in the table. Useful if the instruction syntax uses '\*' to denote certain addressing modes. |
| NOARGSHIFT | Suppress the shift/or operation that applies if the optional SHIFT and OR fields are provided. Some RULEs use the SHIFT/OR fields for other purposes. |
| REGSET | Define a register mnemonic and associated bit field. See example below. |
| WORDADDRS | Set word addressing mode (one word = 2 bytes) |

*   Any line whose first character is not a '.' and is not alphabetic is considered to be a comment and is discarded.
*   Any line that has an alphabetic character as the first character is assumed to be an instruction definition record and is parsed to build the internal representation of the instruction set tables. Eight fields (separated by white space) are expected, as follows:

|     |     |
| --- | --- |
| **Field Name** | **Description** |
| INSTRUCTION | Instruction Mnemonic |
| ARGS | Argument definition |
| OPCODE | Opcode value |
| NBYTES | Number of bytes |
| RULE | Modifier operation |
| CLASS | Instruction class |
| SHIFT | Argument left shift count |
| OR  | Argument bitwise OR mask |

The fields are further defined below:

**INSTRUCTION**

The INSTRUCTION field should contain the string to be used as the mnemonic for this instruction. Upper case letters should be used (the source statements are converted to upper case before comparison).

**ARGS.**

The ARGS field should contain a string describing the format of the operand field. All characters are taken literally except the '\*' which denotes the presence of a valid TASM expression. Multiple '\*'s can be used, but all but the last one must be followed by a comma, '\[', or '\]'. If a single '\*' appears in the ARGS field, then the default action of TASM will be to determine the value of the expression that matches the field and insert one or two bytes of it into the object file depending on the NBYTES field. If multiple '\*'s are used, then special operators (RULE) must be used to take advantage of them (see the examples below). An ARGS field of a pair of double quotes means that no arguments are expected.

**OPCODE.**

The OPCODE field should contain the opcode value (two to six hex digits) for this instruction and address mode. Each pair of hex digits represent a single byte of the opcode, ordered with the right most pair being placed in the lowest memory location.

**NBYTES.**

The NBYTES field should specify the number of bytes this instruction is to occupy (a single decimal digit). This number includes both opcode bytes and argument bytes, thus, the number of bytes of argument is computed by subtracting the number of bytes of opcode (dictated by the length of the OPCODE field) from NBYTES.

**RULE.**

The RULE field determines if any special operations need to be performed on the code generated for this instruction. For example, the zero-page addressing mode of the 6502 is a special case of the absolute addressing mode, and is handled by a special RULE code. See the **Encoding Rules** below.

**CLASS.**

The CLASS field is used to specify whether this instruction is part of the standard instruction set or a member of a set of extended instructions. Bit 0 of this field should be set to denote a member of the standard instruction set. Other bits can be used as needed to establish several classes (or sets) of instructions that can be enabled or disabled via the '-x' command line option.

**SHIFT** (optional).

The SHIFT field is used to cause the first argument of the given instruction to be shifted left the specified number of bits. (Except T1, TDMA, TAR RULES as noted below).

**OR** (optional).

The OR field is used to perform a bitwise OR with the first argument of the given instruction. Specified as hex digits. (Except T1, TDMA, TAR RULES as noted below).

Note that the SHIFT/OR fields are used somewhat differently for T1, TDMA, and TAR RULES. In those cases, the SHIFT and OR fields are used but the OR field is really an AND mask and the result is OR'd with the opcode.

## Encoding Rules

The following encoding rules are available:

**NOTOUCH or NOP**

Do nothing to instruction or args

**JMPPAGE**

Put bits 8-10 of first arg into bits 5-7 of opcode (8048 JMP)

**ZPAGE**

If arg < 256 then use zero-page (6502)

**R1**

Make arg relative to PC (single byte)

**R2**

Make arg relative to PC (two byte)

**CREL**

Combine LS bytes of first two args making the second one relative to PC

**SWAP**

Swap bytes of first arg

**COMBINE**

Combine LS bytes of first two args into first arg (arg1 -> LSB, arg2 ->MSB).

**CSWAP**

Combine LS bytes of first two args into first arg and swap.

**ZBIT**

Z80 bit instructions.

**ZIDX**

Z80 Indexed Instructions (e.g. ADC A,(IX+x))

**MBIT**

Motorola (6805) bit instructions

**MZERO**

Motorola (6805) zero page (direct)

**3ARG**

Three args, one byte each.

**3REL**

Three args, one byte each, last one relative

**T1**

TMS320 instruction with one arg. Shift according to SHIFT and mask with OR and OR into opcode. If a second arg exists assume it is an arp and OR intoLSB of opcode.

**TDMA**

TMS320 instruction with first arg dma. Second arg gets shift/and/or treatment as with T1.

**TAR**

TMS320 instruction with first arg ar. Second arg gets shift/and/or treatment as with T1.

**I1**

I8096 Combine

**I2**

I8096 two far args

**I3**

I8096 three far args

**I4**

I8096 Jump with bit mask

**I5**

I8096 Relative

**I6**

I8096 Indirect

**I7**

I8096 One far arg

**I8**

I8096 Jump

## Encoding Examples

Note that the reason for the combining of arguments (COMBINE and CSWAP) is that TASM assumes that all object bytes to be inserted in the object file are derived from a variable representing the value of the first argument (argval). If two arguments are in the ARGS field, then one of the previously mentioned RULE\`s must be used. They have the effect of combining the low bytes of the first two arguments into the variable (argval) from which the object code will be generated. TASM\`s argument parsing routine can handle a large number of arguments, but the code that generates the object code is less capable.

The following table shows possible instruction definition records, followed by possible source statements that would match it, followed by the resulting object code that would be generated (in hex):

                                          EXAMPLE         EXAMPLE
INSTRUCTION DEFINITION                    SOURCE          OBJECT
-------------------------------------------------------------------
XYZ  \*      FF   3  NOTOUCH 1             xyz 1234h       FF 34 12
XYZ  \*      FF   2  NOTOUCH 1             xyz 1234h       FF 34
ZYX  \*      FE   3  SWAP    1             zyx 1234h       FE 12 34
ZYX  \*      FE   3  R2      1             zyx $+4         FE 01 00
ABC  \*,\*    FD   3  COMBINE 1             abc 45h,67h     FD 45 67
ABC  \*,\*    FD   3  CSWAP   1             abc 45h,67h     FD 67 45
ADD  A,#\*   FC   2  NOTOUCH 1             add A,#'B'      FC 42
RET  ""     FB   1  NOTOUCH 1             ret             FB
LD   IX,\*   21DD 4  NOTOUCH 1             ld  IX,1234h    DD 21 34 12
LD   IX,\*   21DD 4  NOTOUCH 1 1 0         ld  IX,1234h    DD 21 68 24
LD   IX,\*   21DD 4  NOTOUCH 1 0 1         ld  IX,1234h    DD 21 35 12
LD   IX,\*   21DD 4  NOTOUCH 1 1 1         ld  IX,1234h    DD 21 69 24
LD   IX,\*   21DD 4  NOTOUCH 1 8 12        ld  IX,34h      DD 21 12 34

The order of the entries for various addressing modes of a given instruction is important. Since the wild card matches anything, it is important to specify the ARGS for the addressing modes that have the most qualifying characters first. For example, if an instruction had two addressing modes, one that accepted any expression, and another that required a pound sign in front of an expression, the pound sign entry should go first otherwise all occurrences of the instruction would match the more general ARGS expression that it encountered first. The following entries illustrate the proper sequencing:

        ADD #\*  12 3 NOTOUCH 1
        ADD \*   13 3 NOTOUCH 1

## Table Lookup Method

The current version of TASM uses a very simple hashing method based on the first character of the nmemonic. A search is begun at the first table entry that starts with that letter. Thus, the table should be sorted alphabetically for optimum lookup speed. If the table is not sorted in this way it will not break anything, but just slow it down a bit.

## REGSET Directive

For instruction sets that have a well defined set of registers that map to a bit field in the opcode it may be convenient to use the REGSET directive. The value field following each register definition is OR'd into the opcode when a match is found. The '!' character is used to indicate the expected occurance of a register. Consider the following example:

.REGSET R0  00 1
.REGSET R1  01 1
.REGSET R2  02 1
.REGSET R3  03 1
.REGSET R4  04 1
.REGSET R5  05 1
.REGSET R6  06 1
.REGSET R7  07 1

...
INC !  E0  1 NOP
...

A source instruction INC R3 would be encoded by ORing E0 with 03 resulting in E3.

- - -

# 6502 INSTRUCTIONS AND ADDRESSING MODES

The acceptable 6502 opcode mnemonics for TASM are as follows:

 ADC  AND  ASL  BCC  BCS  BEQ  BNE  BMI  BPL  BVC  BVS  BIT
 BRK  CLC  CLD  CLI  CLV  CMP  CPX  CPY  DEC  DEX  DEY  EOR
 INC  INX  INY  JMP  JSR  LDA  LDX  LDY  LSR  NOP  ORA  PHA
 PHP  PLA  PLP  ROL  ROR  RTI  RTS  SBC  SEC  SED  SEI  STA
 STX  STY  TAX  TAY  TSX  TXA  TXS  TYA

TASM also supports the following instructions that are part of the Rockwell R65C02 and R65C00/21 microprocessor instruction sets. Those that are marked as set A are applicable to the R65C02 and those marked as set B are applicable to the R65C00/21 (A+B for both):

        Mnemonic        Description                Address Mode  Set
        ---------------------------------------------------------------
        ADC             Add with carry             (IND)         A
        AND             And memory with A          (IND)         A
        BIT             Test memory bits with A    ABS,X         A
        BIT             Test memory bits with A    ZP,X          A
        BIT             Test memory bits with A    IMM           A
        CMP             Compare memory with A      (IND)         A
        DEC             Decrement A                A             A
        EOR             Exclusive OR memory with A (IND)         A
        INC             Increment A                A             A
        JMP             Jump                       (ABS,X)       A
        LDA             Load A with memory         (IND)         A
        ORA             OR A with memory           (IND)         A
        SBC             Subtract memory form A     (IND)         A
        STA             Store A in memory          (IND)         A
        STZ             Store zero                 ABS           A
        STZ             Store zero                 ABS,X         A
        STZ             Store zero                 ZP            A
        STZ             Store zero                 ZP,X          A
        TRB             Test and reset memory bit  ABS           A
        TRB             Test and reset memory bit  ZP            A
        TSB             Test and set memory bit    ABS           A
        TSB             Test and set memory bit    ZP            A

        BRA             Branch Always              REL           A+B

        BBR0            Branch on Bit 0 Reset      ZP,REL        A+B
        BBR1            Branch on Bit 1 Reset      ZP,REL        A+B
        BBR2            Branch on Bit 2 Reset      ZP,REL        A+B
        BBR3            Branch on Bit 3 Reset      ZP,REL        A+B
        BBR4            Branch on Bit 4 Reset      ZP,REL        A+B
        BBR5            Branch on Bit 5 Reset      ZP,REL        A+B
        BBR6            Branch on Bit 6 Reset      ZP,REL        A+B
        BBR7            Branch on Bit 7 Reset      ZP,REL        A+B

        BBS0            Branch on Bit 0 Set        ZP,REL        A+B
        BBS1            Branch on Bit 1 Set        ZP,REL        A+B
        BBS2            Branch on Bit 2 Set        ZP,REL        A+B
        BBS3            Branch on Bit 3 Set        ZP,REL        A+B
        BBS4            Branch on Bit 4 Set        ZP,REL        A+B
        BBS5            Branch on Bit 5 Set        ZP,REL        A+B
        BBS6            Branch on Bit 6 Set        ZP,REL        A+B
        BBS7            Branch on Bit 7 Set        ZP,REL        A+B

        MUL             Multiply                   Implied       B

        PHX             Push Index X               Implied       A+B
        PHY             Push Index Y               Implied       A+B
        PLX             Pull Index X               Implied       A+B
        PLY             Pull Index Y               Implied       A+B

        RMB0            Reset Memory Bit 0         ZP            A+B
        RMB1            Reset Memory Bit 1         ZP            A+B
        RMB2            Reset Memory Bit 2         ZP            A+B
        RMB3            Reset Memory Bit 3         ZP            A+B
        RMB4            Reset Memory Bit 4         ZP            A+B
        RMB5            Reset Memory Bit 5         ZP            A+B
        RMB6            Reset Memory Bit 6         ZP            A+B
        RMB7            Reset Memory Bit 7         ZP            A+B

        SMB0            Set   Memory Bit 0         ZP            A+B
        SMB1            Set   Memory Bit 1         ZP            A+B
        SMB2            Set   Memory Bit 2         ZP            A+B
        SMB3            Set   Memory Bit 3         ZP            A+B
        SMB4            Set   Memory Bit 4         ZP            A+B
        SMB5            Set   Memory Bit 5         ZP            A+B
        SMB6            Set   Memory Bit 6         ZP            A+B
        SMB7            Set   Memory Bit 7         ZP            A+B

Addressing modes are denoted as follows:

ABS               Absolute
ZP                Zero Page
ABS,X             Absolute X
ZP,X              Zero Page X
ABS,Y             Absolute Y
ZP,Y              Zero Page Y
A                 Accumulator
(IND,X)           Indirect X
(IND),Y           Indirect Y
(IND)             Indirect
#IMM              Immediate
REL               Relative (Branch instructions only)
ZP,REL            Zero Page, Relative
Implied           Implied

Note that Zero Page addressing can not be explicitly requested. It is used if the value of the operand is representable in a single byte for the applicable statements.

The '-x' command line option can be used to enable the extended instructions. A '-x' with no digit following will enable the standard set plus both extended sets. The 6502 version of TASM uses three bits in the instruction class mask to determine whether a given instruction is enabled or not. Bit 0 enables the basic set, bit 1 enables set A (R65C02) and bit 2 enables set B (R65C00/21). The following table shows various options:

Class Mask        Enabled Instructions
                BASIC   R65C02  R65C00/21
--------------------------------------------
1               yes     no      no
2               no      yes     no
3               yes     yes     no
4               no      no      yes
5               yes     no      yes
6               no      yes     yes
7               yes     yes     yes

Thus, to enable the basic set plus the R65C02 instructions, invoke the '-x3' command line option.

See manufacturer's data for a more complete description of the meaning of the mnemonics and addressing modes.

- - -

# 68xx INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the 6800/68HC11 version of TASM. Symbolic fields are defined as follows:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_addr8\_             Absolute address (8 bits)
\_addr16\_            Absolute address (16 bits)
                      Values that can fit in 8 bits can
                      result in the DIRECT addressing mode.
\_addr16\_no8\_        Absolute address (16 bits)
                      DIRECT addressing not applicable.
\_bmsk\_              Bit mask (8 bits)
\_rel8\_              Relative address (8 bit signed)
\_immed8\_            Immediate data (8 bits)
\_immed16\_           Immediate data (16 bits)

Any valid TASM expression can appear in the place of any of the above symbolics.

The lines that are marked with an 'a' or 'b' are extended instructions that are available only if a -x option has been invoked on the command line. The classes of instructions (and their bit assignment in the class mask) are shown below:

BIT     PROCESSOR      EXT LABEL     COMMAND LINE OPTION
--------------------------------------------------------
0       6800
1       6801/6803       a            -x3
2       68HC11          b            -x7

Thus, to enable the 68HC11 instructions, a -x7 could be used on the command line.

TASM deviates from standard Motorola syntax for the BSET, BRSET, BCLR, and BRCLR instructions. TASM requires commas separating all arguments. Motorola assemblers use white space to separate the last one or two arguments for these instructions. Here are examples of each applicable instruction:

TASM                                MOTOROLA
----------------------              --------------------
BCLR    \_addr8\_,Y,\_bmsk\_            BCLR    \_addr8\_,Y \_bmsk\_
BCLR    \_addr8\_,X,\_bmsk\_            BCLR    \_addr8\_,X \_bmsk\_
BCLR    \_addr8\_  ,\_bmsk\_            BCLR    \_addr8\_   \_bmsk\_
BSET    \_addr8\_,Y,\_bmsk\_            BSET    \_addr8\_,Y \_bmsk\_
BSET    \_addr8\_,X,\_bmsk\_            BSET    \_addr8\_,X \_bmsk\_
BSET    \_addr8\_  ,\_bmsk\_            BSET    \_addr8\_   \_bmsk\_
BRCLR   \_addr8\_,Y,\_bmsk\_,\_rel8\_     BRCLR   \_addr8\_,Y \_bmsk\_ \_rel8\_
BRCLR   \_addr8\_,X,\_bmsk\_,\_rel8\_     BRCLR   \_addr8\_,X \_bmsk\_ \_rel8\_
BRCLR   \_addr8\_  ,\_bmsk\_,\_rel8\_     BRCLR   \_addr8\_   \_bmsk\_ \_rel8\_
BRSET   \_addr8\_,Y,\_bmsk\_,\_rel8\_     BRSET   \_addr8\_,Y \_bmsk\_ \_rel8\_
BRSET   \_addr8\_,X,\_bmsk\_,\_rel8\_     BRSET   \_addr8\_,X \_bmsk\_ \_rel8\_
BRSET   \_addr8\_  ,\_bmsk\_,\_rel8\_     BRSET   \_addr8\_   \_bmsk\_ \_rel8\_

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
ABA                          Add Accumulator B to Accumulator A
ABX                     a    Add Accumulator B to Index Reg X
ABY                     b    Add Accumulator B to Index reg Y

ADCA    #\_immed8\_            Add with carry immediate  to Reg A
ADCA    \_addr8\_,X            Add with carry indirect,X to Reg A
ADCA    \_addr8\_,Y       b    Add with carry indirect,Y to Reg A
ADCA    \_addr16\_             Add with carry extended   to Reg A

ADCB    #\_immed8\_            Add with carry immediate  to Reg B
ADCB    \_addr8\_,X            Add with carry indirect,X to Reg B
ADCB    \_addr8\_,Y       b    Add with carry indirect,Y to Reg B
ADCB    \_addr16\_             Add with carry extended   to Reg B

ADDA    #\_immed8\_            Add w/o  carry immediate  to Reg A
ADDA    \_addr8\_,X            Add w/o  carry indirect,X to Reg A
ADDA    \_addr8\_,Y       b    Add w/o  carry indirect,Y to Reg A
ADDA    \_addr16\_             Add w/o  carry extended   to Reg A

ADDB    #\_immed8\_            Add w/o  carry immediate  to Reg B
ADDB    \_addr8\_,X            Add w/o  carry indirect,X to Reg B
ADDB    \_addr8\_,Y       b    Add w/o  carry indirect,Y to Reg B
ADDB    \_addr16\_             Add w/o  carry extended   to Reg B

ADDD    #\_immed8\_       a    Add double immediate  to Reg D
ADDD    \_addr8\_,X       a    Add double indirect,X to Reg D
ADDD    \_addr8\_,Y       b    Add double indirect,Y to Reg D
ADDD    \_addr16\_        a    Add double extended   to Reg D

ANDA    #\_immed8\_            AND immediate  to Reg A
ANDA    \_addr8\_,X            AND indirect,X to Reg A
ANDA    \_addr8\_,Y       b    AND indirect,Y to Reg A
ANDA    \_addr16\_             AND extended   to Reg A

ANDB    #\_immed8\_            AND immediate  to Reg B
ANDB    \_addr8\_,X            AND indirect,X to Reg B
ANDB    \_addr8\_,Y       b    AND indirect,Y to Reg B
ANDB    \_addr16\_             AND extended   to Reg B

ASL     \_addr8\_,X            Arithmetic shift left indirect,X
ASL     \_addr8\_,Y       b    Arithmetic shift left indirect,Y
ASL     \_addr16\_             Arithmetic shift left extended
ASLA                         Arithmetic shift left Reg A
ASLB                         Arithmetic shift left Reg B
ASLD                    a    Arithmetic shift left double Reg D

ASR     \_addr8\_,X            Arithmetic shift right indirect,X
ASR     \_addr8\_,Y       b    Arithmetic shift right indirect,Y
ASR     \_addr16\_             Arithmetic shift right extended
ASRA                         Arithmetic shift right Reg A
ASRB                         Arithmetic shift right Reg B

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
BCC     \_rel8\_               Branch if carry clear
BCS     \_rel8\_               Branch if carry set
BEQ     \_rel8\_               Branch if equal
BGE     \_rel8\_               Branch if greater or equal
BGT     \_rel8\_               Branch if greater
BHI     \_rel8\_               Branch if higher
BHS     \_rel8\_               Branch if higher or same
BRA     \_rel8\_               Branch always

BITA    #\_immed8\_            AND immediate  with Reg A (set condition codes)
BITA    \_addr8\_,X            AND indirect,X with Reg A (set condition codes)
BITA    \_addr8\_,Y       b    AND indirect,Y with Reg A (set condition codes)
BITA    \_addr16\_             AND extended   with Reg A (set condition codes)

BITB    #\_immed8\_            AND immediate  with Reg B (set condition codes)
BITB    \_addr8\_,X            AND indirect,X with Reg B (set condition codes)
BITB    \_addr8\_,Y       b    AND indirect,Y with Reg B (set condition codes)
BITB    \_addr16\_             AND extended   with Reg B (set condition codes)

BLE     \_rel8\_               Branch if less than or equal
BLO     \_rel8\_               Branch if lower (same as BCS)
BLS     \_rel8\_               Branch if lower or same
BLT     \_rel8\_               Branch if less than zero
BMI     \_rel8\_               Branch if minus
BNE     \_rel8\_               Branch if not equal
BPL     \_rel8\_               Branch if plus
BRA     \_rel8\_               Branch always

BRCLR \_addr8\_,X,\_bmsk\_,\_rel8\_  b Branch if bits clear indirect X
BRCLR \_addr8\_,Y,\_bmsk\_,\_rel8\_  b Branch if bits clear indirect Y
BRCLR \_addr8\_,\_bmsk\_,  \_rel8\_  b Branch if bits clear direct

BRN     \_rel8\_               Branch never

BRSET \_addr8\_,X,\_bmsk\_,\_rel8\_  b Branch if bits set indirect X
BRSET \_addr8\_,Y,\_bmsk\_,\_rel8\_  b Branch if bits set indirect Y
BRSET \_addr8\_,\_bmsk\_,  \_rel8\_  b Branch if bits set direct

BSET    \_addr8\_,X,\_bmsk\_ b   Bit set indirect X
BSET    \_addr8\_,Y,\_bmsk\_ b   Bit set indirect Y
BSET    \_addr8\_,\_bmsk\_   b   Bit set direct
BSET    \_addr8\_,#\_bmsk\_  b   Bit set direct (alternate form)

BSR     \_rel8\_               Branch subroutine
BVC     \_rel8\_               Branch if overflow clear
BVS     \_rel8\_               Branch if overflow set

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
CBA                          Compare registers A & B
CLC                          Clear Carry
CLI                          Clear Interrupt Mask

CLR     \_addr8\_,X            Arithmetic shift right indirect,X
CLR     \_addr8\_,Y       b    Arithmetic shift right indirect,Y
CLR     \_addr16\_             Arithmetic shift right extended
CLRA                         Arithmetic shift right Reg A
CLRB                         Arithmetic shift right Reg B

CLV                          Clear Overflow Bit

CMPA    #\_immed8\_            Compare immediate  with Reg A
CMPA    \_addr8\_,X            Compare indirect,X with Reg A
CMPA    \_addr8\_,Y       b    Compare indirect,Y with Reg A
CMPA    \_addr16\_             Compare extended   with Reg A

CMPB    #\_immed8\_            Compare immediate  with Reg B
CMPB    \_addr8\_,X            Compare indirect,X with Reg B
CMPB    \_addr8\_,Y       b    Compare indirect,Y with Reg B
CMPB    \_addr16\_             Compare extended   with Reg B

COM     \_addr8\_,X            Complement indirect,X
COM     \_addr8\_,Y       b    Complement indirect,Y
COM     \_addr16\_             Complement extended
COMA                         Complement Reg A
COMB                         Complement Reg B

CPD     #\_immed16\_      b    Compare double immediate  to Reg D
CPD     \_addr8\_,X       b    Compare double indirect,X to Reg D
CPD     \_addr8\_,Y       b    Compare double indirect,Y to Reg D
CPD     \_addr16\_        b    Compare double extended   to Reg D

CPX     #\_immed8\_            Compare double immediate  to Reg X
CPX     \_addr8\_,X            Compare double indirect,X to Reg X
CPX     \_addr8\_,Y       b    Compare double indirect,Y to Reg X
CPX     \_addr16\_             Compare double extended   to Reg X

CPY     #\_immed8\_       b    Compare double immediate  to Reg Y
CPY     \_addr8\_,X       b    Compare double indirect,X to Reg Y
CPY     \_addr8\_,Y       b    Compare double indirect,Y to Reg Y
CPY     \_addr16\_        b    Compare double extended   to Reg Y

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
DAA                          Decimal Adjust Reg A

DEC     \_addr8\_,X            Decrement indirect,X
DEC     \_addr8\_,Y            Decrement indirect,Y
DEC     \_addr16\_no8\_         Decrement extended
DECA                         Decrement Reg A
DECB                         Decrement Reg B
DES                          Decrement stack pointer
DEX                          Decrement Reg X
DEY                     b    Decrement Reg Y

EORA    #\_immed8\_            Exclusive OR immediate  with Reg A
EORA    \_addr8\_,X            Exclusive OR indirect,X with Reg A
EORA    \_addr8\_,Y       b    Exclusive OR indirect,Y with Reg A
EORA    \_addr16\_             Exclusive OR extended   with Reg A

EORB    #\_immed8\_            Exclusive OR immediate  with Reg B
EORB    \_addr8\_,X            Exclusive OR indirect,X with Reg B
EORB    \_addr8\_,Y       b    Exclusive OR indirect,Y with Reg B
EORB    \_addr16\_             Exclusive OR extended   with Reg B

FDIV                    b    Fractional Divide (ACCD/IX)
IDIV                    b    Integer Divide (ACCD/IX)

INC     \_addr8\_,X            Increment indirect,X
INC     \_addr8\_,Y            Increment indirect,Y
INC     \_addr16\_no8\_         Increment extended
INCA                         Increment Reg A
INCB                         Increment Reg B
INS                          Increment stack pointer
INX                          Increment Reg X
INY                     b    Increment Reg Y

JMP     \_addr8\_,X            Jump indirect,X
JMP     \_addr8\_,Y       b    Jump indirect,Y
JMP     \_addr16\_no8\_         Jump extended

JSR     \_addr8\_,X            Jump Subroutine indirect,X
JSR     \_addr8\_,Y       b    Jump Subroutine indirect,Y
JSR     \_addr16\_             Jump Subroutine extended

LDAA    #\_immed8\_            Load Accumulator immediate  with Reg A
LDAA    \_addr8\_,X            Load Accumulator indirect,X with Reg A
LDAA    \_addr8\_,Y       b    Load Accumulator indirect,Y with Reg A
LDAA    \_addr16\_             Load Accumulator extended   with Reg A

LDAB    #\_immed8\_            Load Accumulator immediate  with Reg B
LDAB    \_addr8\_,X            Load Accumulator indirect,X with Reg B
LDAB    \_addr8\_,Y       b    Load Accumulator indirect,Y with Reg B
LDAB    \_addr16\_             Load Accumulator extended   with Reg B

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
LDD     #\_immed16\_      a    Load double immediate  to Reg D
LDD     \_addr8\_,X       a    Load double indirect,X to Reg D
LDD     \_addr8\_,Y       b    Load double indirect,Y to Reg D
LDD     \_addr16\_        a    Load double extended   to Reg D

LDS     #\_immed16\_           Load double immediate  to Reg D
LDS     \_addr8\_,X            Load double indirect,X to Reg D
LDS     \_addr8\_,Y       b    Load double indirect,Y to Reg D
LDS     \_addr16\_             Load double extended   to Reg D

LDX     #\_immed16\_           Load immediate  to Reg X
LDX     \_addr8\_,X            Load indirect,X to Reg X
LDX     \_addr8\_,Y       b    Load indirect,Y to Reg X
LDX     \_addr16\_             Load extended   to Reg X

LDY     #\_immed16\_      b    Load immediate  to Reg Y
LDY     \_addr8\_,X       b    Load indirect,X to Reg Y
LDY     \_addr8\_,Y       b    Load indirect,Y to Reg Y
LDY     \_addr16\_        b    Load extended   to Reg Y

LSL     \_addr8\_,X            Logical Shift Left indirect,X
LSL     \_addr8\_,Y       b    Logical Shift Left indirect,Y
LSL     \_addr16\_no8\_         Logical Shift Left extended
LSLA                         Logical Shift Left Reg A
LSLB                         Logical Shift Left Reg B
LSLD                         Logical Shift Left Double Reg D

LSR     \_addr8\_,X            Logical Shift Right indirect,X
LSR     \_addr8\_,Y       b    Logical Shift Right indirect,Y
LSR     \_addr16\_no8\_         Logical Shift Right extended
LSRA                         Logical Shift Right Reg A
LSRB                         Logical Shift Right Reg B
LSRD                         Logical Shift Right Double Reg D

MUL                          Multiply Unsigned

NEG     \_addr8\_,X            Negate indirect,X
NEG     \_addr8\_,Y       b    Negate indirect,Y
NEG     \_addr16\_no8\_         Negate extended
NEGA                         Negate Reg A
NEGB                         Negate Reg B

NOP                          No Operation

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
ORAA    #\_immed8\_            Inclusive OR immediate  with Reg A
ORAA    \_addr8\_,X            Inclusive OR indirect,X with Reg A
ORAA    \_addr8\_,Y       b    Inclusive OR indirect,Y with Reg A
ORAA    \_addr16\_             Inclusive OR extended   with Reg A

ORAB    #\_immed8\_            Inclusive OR immediate  with Reg B
ORAB    \_addr8\_,X            Inclusive OR indirect,X with Reg B
ORAB    \_addr8\_,Y       b    Inclusive OR indirect,Y with Reg B
ORAB    \_addr16\_             Inclusive OR extended   with Reg B

PSHA                         Push Reg A onto stack
PSHB                         Push Reg B onto stack
PSHX                         Push Reg X onto stack
PSHY                         Push Reg Y onto stack

PULA                         Pull Reg A from stack
PULB                         Pull Reg B from stack
PULX                         Pull Reg X from stack
PULY                         Pull Reg Y from stack

ROL     \_addr8\_,X            Rotate Left indirect,X
ROL     \_addr8\_,Y            Rotate Left indirect,Y
ROL     \_addr16\_no8\_         Rotate Left extended
ROLA                         Rotate Left Reg A
ROLB                         Rotate Left Reg B

ROR     \_addr8\_,X            Rotate Right indirect,X
ROR     \_addr8\_,Y            Rotate Right indirect,Y
ROR     \_addr16\_no8\_         Rotate Right extended
RORA                         Rotate Right Reg A
RORB                         Rotate Right Reg B
RTI                          Return from Interrupt
RTS                          Return from subroutine

SBA                          Subtract Accumulators
SBCA    #\_immed8\_            Subtract with Carry immediate  with Reg A
SBCA    \_addr8\_,X            Subtract with Carry indirect,X with Reg A
SBCA    \_addr8\_,Y       b    Subtract with Carry indirect,Y with Reg A
SBCA    \_addr16\_             Subtract with Carry extended   with Reg A
SBCB    #\_immed8\_            Subtract with Carry immediate  with Reg B
SBCB    \_addr8\_,X            Subtract with Carry indirect,X with Reg B
SBCB    \_addr8\_,Y       b    Subtract with Carry indirect,Y with Reg B
SBCB    \_addr16\_             Subtract with Carry extended   with Reg B
SEC                          Set Carry
SEI                          Set Interrupt Mask
SEV                          Set Twos Complement Overflow Bit
STAA    \_addr8\_,X            Store Reg A indirect,X
STAA    \_addr8\_,Y       b    Store Reg A indirect,Y
STAA    \_addr16\_             Store Reg A extended

STAB    \_addr8\_,X            Store Reg B indirect,X
STAB    \_addr8\_,Y       b    Store Reg B indirect,Y
STAB    \_addr16\_             Store Reg B extended

OPCODE  OPERANDS       EXT   DESCRIPTION
--------------------------------------------------------------
STD     \_addr8\_,X            Store Double Acc indirect,X to Reg B
STD     \_addr8\_,Y       b    Store Double Acc indirect,Y to Reg B
STD     \_addr16\_             Store Double Acc extended   to Reg B

STOP                         Stop Processing

STS     \_addr8\_,X            Store Accumulator indirect,X
STS     \_addr8\_,Y       b    Store Accumulator indirect,Y
STS     \_addr16\_             Store Accumulator extended

STX     \_addr8\_,X            Store Index Reg X indirect,X
STX     \_addr8\_,Y       b    Store Index Reg X indirect,Y
STX     \_addr16\_             Store Index Reg X extended

STY     \_addr8\_,X       b    Store Index Reg Y indirect,X
STY     \_addr8\_,Y       b    Store Index Reg Y indirect,Y
STY     \_addr16\_        b    Store Index Reg Y extended

SUBA    #\_immed8\_            Subtract immediate  from Reg A
SUBA    \_addr8\_,X            Subtract indirect,X from Reg A
SUBA    \_addr8\_,Y       b    Subtract indirect,Y from Reg A
SUBA    \_addr16\_             Subtract extended   from Reg A

SUBB    #\_immed8\_            Subtract immediate  from Reg B
SUBB    \_addr8\_,X            Subtract indirect,X from Reg B
SUBB    \_addr8\_,Y       b    Subtract indirect,Y from Reg B
SUBB    \_addr16\_             Subtract extended   from Reg B

SUBD    #\_immed16\_      b    Subtract double immediate  from Reg D
SUBD    \_addr8\_,X       b    Subtract double indirect,X from Reg D
SUBD    \_addr8\_,Y       b    Subtract double indirect,Y from Reg D
SUBD    \_addr16\_        b    Subtract double extended   from Reg D

SWI                          Software Interrupt

TAB                          Transfer Reg A to Reg B
TAP                          Transfer Reg A to Condition Code Reg
TPA                          Transfer Condition Code Reg to Reg A
TBA                          Transfer Reg B to Reg A

TST     \_addr8\_,X            Test indirect,X
TST     \_addr8\_,Y            Test indirect,Y
TST     \_addr16\_no8\_         Test extended
TSTA                         Test Reg A
TSTB                         Test Reg B

TSX                          Transfer Stack Pointer to Reg X
TSY                     b    Transfer Stack Pointer to Reg Y
TXS                          Transfer Reg X to Stack Pointer
TYS                     b    Transfer Reg Y to Stack Pointer

WAI                          Wait for Interrupt
XGDX                    b    Exchange Double Reg D and Reg X
XGDY                    b    Exchange Double Reg D and Reg Y

- - -

# 8048 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the 8048 version of TASM. Where 'Rn' is seen, R0 through R7 may be substituted. Other symbolic fields are as follows:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_addr8\_             Absolute address (8 bits)
\_addr11\_            Absolute address (11 bits)
\_immed\_             Immediate data

Any valid TASM expression can appear in the place of any of the above symbolics.

The lines that are marked with an (8041), (8022), or (8021) on the far right are extended instructions that are available only if a -x option has been invoked on the command line. The classes of instructions (and their bit assignment in the class mask) are shown below:

BIT     PROCESSOR
-------------------------------
0       8X48, 8035, 8039, 8049
1       8X41A
2       8022
3       8021

Thus, to enable the basic 8048 set plus the 8022 set, a -x5 could be used on the command line.

Note that some of the base instructions should be disabled for the 8041, 8022, and 8021, but are not.

OPCODE  OPERANDS        DESCRIPTION
-------------------------------------------------------------------
ADD     A,Rn            Add Register to Acc
ADD     A,@R0           Add Indirect RAM to Acc
ADD     A,@R1           Add Indirect RAM to Acc
ADD     A,#\_immed\_      Add Immediate data to Acc

ADDC    A,Rn            Add Register to Acc with carry
ADDC    A,@R0           Add Indirect RAM to Acc with carry
ADDC    A,@R1           Add Indirect RAM to Acc with carry
ADDC    A,#\_immed\_      Add Immediate data to Acc with carry

ANL     A,Rn            AND Register to Acc
ANL     A,@R0           AND Indirect RAM to Acc
ANL     A,@R1           AND Indirect RAM to Acc
ANL     A,#\_immed\_      AND Immediate data to Acc
ANL     BUS,#\_immed\_    AND Immediate data to BUS
ANL     P1,#\_immed\_     AND Immediate data to port P1
ANL     P2,#\_immed\_     AND Immediate data to port P2

ANLD    P4,A            AND Acc to Expander port P4
ANLD    P5,A            AND Acc to Expander port P5
ANLD    P6,A            AND Acc to Expander port P6
ANLD    P7,A            AND Acc to Expander port P7

CALL    \_addr11\_        Call subroutine

CLR     A               Clear Acc
CLR     C               Clear Carry
CLR     F0              Clear Flag 0
CLR     F1              Clear Flag 1

CPL     A               Complement Acc
CPL     C               Complement Carry
CPL     F0              Complement Flag F0
CPL     F1              Complement Flag F1

DA      A               Decimal adjust Acc

DEC     A               Decrement Acc
DEC     Rn              Decrement Register

DIS     I               Disable Interrupts
DIS     TCNTI           Disable Timer/Counter Interrupt

DJNZ    Rn,\_addr8\_      Decrement Register and Jump if nonzero

EN      DMA             Enable DMA                           (8041)
EN      FLAGS           Enable Flags                         (8041)
EN      I               Enable External Interrupt
EN      TCNTI           Enable Timer/Counter Interrupt
ENT0    CLK             Enable Clock Output

IN      A,DBB           Input Data Bus to Acc                (8041)
IN      A,P0            Input Port 0 to Acc                  (8021)
IN      A,P1            Input Port 1 to Acc
IN      A,P2            Input Port 2 to Acc

INC     A               Increment Acc
INC     Rn              Increment Register
INC     @R0             Increment Indirect RAM
INC     @R1             Increment Indirect RAM

INS     A,BUS           Strobed Input of Bus to Acc

JB0     \_addr8\_         Jump if Acc bit 0 is set
JB1     \_addr8\_         Jump if Acc bit 1 is set
JB2     \_addr8\_         Jump if Acc bit 2 is set
JB3     \_addr8\_         Jump if Acc bit 3 is set
JB4     \_addr8\_         Jump if Acc bit 4 is set
JB5     \_addr8\_         Jump if Acc bit 5 is set
JB6     \_addr8\_         Jump if Acc bit 6 is set
JB7     \_addr8\_         Jump if Acc bit 7 is set
JMP     \_addr11\_        Jump
JC      \_addr8\_         Jump if Carry is set
JF0     \_addr8\_         Jump if Flag F0 is set
JF1     \_addr8\_         Jump if Flag F1 is set
JNC     \_addr8\_         Jump if Carry is clear
JNI     \_addr8\_         Jump if Interrupt input is clear
JNIBF   \_addr8\_         Jump if IBF is clear                 (8041)
JNT0    \_addr8\_         Jump if T0 is clear
JNT1    \_addr8\_         Jump if T1 is clear
JNZ     \_addr8\_         Jump if Acc is not zero
JOBF    \_addr8\_         Jump if OBF is set                   (8041)
JTF     \_addr8\_         Jump if Timer Flag is set
JT0     \_addr8\_         Jump if T0 pin is high
JT1     \_addr8\_         Jump if T1 pin is high
JZ      \_addr8\_         Jump if Acc is zero
JMPP    @A              Jump Indirect (current page)

MOV     A,PSW           Move PSW to Acc
MOV     A,Rn            Move Register to Acc
MOV     A,T             Move Timer/Counter to Acc
MOV     A,@R0           Move Indirect RAM to Acc
MOV     A,@R1           Move Indirect RAM to Acc
MOV     A,#\_immed\_      Move Immediate data to Acc
MOV     PSW,A           Move Acc to PSW
MOV     Rn,A            Move Acc to Register
MOV     Rn,#\_immed\_     Move Immediate data to Register
MOV     STS,A           Move Acc to STS                      (8041)
MOV     T,A             Move Acc to Timer/Counter
MOV     @R0,A           Move Acc to Indirect RAM
MOV     @R1,A           Move Acc to Indirect RAM
MOV     @R0,#\_immed\_    Move Immediate data to Indirect RAM
MOV     @R1,#\_immed\_    Move Immediate data to Indirect RAM

MOVD    A,P4            Move half-byte Port 4 to Acc (lower nibble)
MOVD    A,P5            Move half-byte Port 5 to Acc (lower nibble)
MOVD    A,P6            Move half-byte Port 6 to Acc (lower nibble)
MOVD    A,P7            Move half-byte Port 7 to Acc (lower nibble)
MOVD    P4,A            Move lower nibble of Acc to Port 4
MOVD    P5,A            Move lower nibble of Acc to Port 5
MOVD    P6,A            Move lower nibble of Acc to Port 6
MOVD    P7,A            Move lower nibble of Acc to Port 7

MOVP    A,@A            Move Indirect Program data to Acc
MOVP3   A,@A            Move Indirect Program data to Acc (page 3)

MOVX    A,@R0           Move Indirect External RAM to Acc
MOVX    A,@R1           Move Indirect External RAM to Acc
MOVX    @R0,A           Move Acc to Indirect External RAM
MOVX    @R1,A           Move Acc to Indirect External RAM

NOP                     No operation

ORL     A,Rn            OR Register to Acc
ORL     A,@R0           OR Indirect RAM to Acc
ORL     A,@R1           OR Indirect RAM to Acc
ORL     A,#\_immed\_      OR Immediate data to Acc
ORL     BUS,#\_immed\_    OR Immediate data to BUS
ORL     P1,#\_immed\_     OR Immediate data to port P1
ORL     P2,#\_immed\_     OR Immediate data to port P2

ORLD    P4,A            OR lower nibble of Acc with P4
ORLD    P5,A            OR lower nibble of Acc with P5
ORLD    P6,A            OR lower nibble of Acc with P6
ORLD    P7,A            OR lower nibble of Acc with P7

OUTL    BUS,A           Output Acc to Bus
OUT     DBB,A           Output Acc to DBB                    (8041)
OUTL    P0,A            Output Acc to Port P0                (8021)
OUTL    P1,A            Output Acc to Port P1
OUTL    P2,A            Output Acc to Port P2

RAD                     Move A/D Converter to Acc            (8022)

RET                     Return from subroutine
RETI                    Return from Interrupt w/o PSW restore(8022)
RETR                    Return from Interrupt w/  PSW restore

RL      A               Rotate Acc Left
RLC     A               Rotate Acc Left through Carry
RR      A               Rotate Acc Right
RRC     A               Rotate Acc Right through Carry

SEL     AN0             Select Analog Input 0                (8022)
SEL     AN1             Select Analog Input 1                (8022)
SEL     MB0             Select Memory Bank 0
SEL     MB1             Select Memory Bank 1
SEL     RB0             Select Register Bank 0
SEL     RB1             Select Register Bank 1

STOP    TCNT            Stop Timer/Counter
STRT    CNT             Start Counter
STRT    T               Start Timer

SWAP    A               Swap nibbles of Acc

XCH     A,Rn            Exchange Register with Acc
XCH     A,@R0           Exchange Indirect RAM with Acc
XCH     A,@R1           Exchange Indirect RAM with Acc

XCHD    A,@R0           Exchange lower nibble of Indirect RAM w/ Acc
XCHD    A,@R1           Exchange lower nibble of Indirect RAM w/ Acc

XRL     A,Rn            Exclusive OR Register to Acc
XRL     A,@R0           Exclusive OR Indirect RAM to Acc
XRL     A,@R1           Exclusive OR Indirect RAM to Acc
XRL     A,#\_immed\_      Exclusive OR Immediate data to Acc

See manufacturer's data for a more complete description of the meaning of the mnemonics and addressing modes.

- - -

# 8051 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the 8051 version of TASM. Where 'Rn' is seen, R0 through R7 may be substituted. Other symbolic fields are as follows:

        
SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_addr11\_            Absolute address (11 bits)
\_addr16\_            Absolute address (16 bits)
\_bit\_               Bit address
\_immed\_             Immediate data
\_direct\_            Direct RAM address
\_rel\_               Relative address

Any valid TASM expression can appear in the place of any of the above symbolics.

OPCODE  OPERAND             DESCRIPTION
--------------------------------------------------------------------
ACALL   \_addr11\_            Absolute Call
ADD     A,Rn                Add Register to Acc
ADD     A,@R0               Add Indirect RAM to Acc
ADD     A,@R1               Add Indirect RAM to Acc
ADD     A,#\_immed\_          Add Immediate data to Acc
ADD     A,\_direct\_          Add Direct RAM to Acc
ADDC    A,Rn                Add Register to Acc with carry
ADDC    A,@R0               Add Indirect RAM to Acc with carry
ADDC    A,@R1               Add Indirect RAM to Acc with carry
ADDC    A,#\_immed\_          Add Immediate data to Acc with carry
ADDC    A,\_direct\_          Add Direct RAM to Acc with carry

AJMP    \_addr11\_            Absolute Jump

ANL     A,Rn                AND Register and Acc
ANL     A,@R0               AND Indirect RAM and Acc
ANL     A,@R1               AND Indirect RAM and Acc
ANL     A,#\_immed\_          AND Immediate data and Acc
ANL     A,\_direct\_          AND Direct RAM and Acc
ANL     C,/\_bit\_            AND Complement of direct bit to Carry
ANL     C,bit>              AND direct bit to Carry
ANL     \_direct\_,A          AND Acc to direct RAM
ANL     \_direct\_,#\_immed\_   AND Immediate data and direct RAM

CJNE    A,#\_immed\_,\_rel\_    Compare Immediate to Acc   and JNE
CJNE    A,\_direct\_,\_rel\_    Compare direct RAM to Acc and JNE
CJNE    Rn,#\_immed\_,\_rel\_   Compare Immediate to Register and JNE
CJNE    @R0,#\_immed\_,\_rel\_  Compare Immediate to Indirect RAM and JNE
CJNE    @R1,#\_immed\_,\_rel\_  Compare Immediate to Indirect RAM and JNE

CLR     A                   Clear Accumulator
CLR     C                   Clear Carry
CLR     \_bit\_               Clear Bit

CPL     A                   Complement Accumulator
CPL     C                   Complement Carry
CPL     \_bit\_               Complement Bit

DA      A                   Decimal Adjust Accumulator
DEC     A                   Decrement Acc
DEC     Rn                  Decrement Register
DEC     @R0                 Decrement Indirect RAM
DEC     @R1                 Decrement Indirect RAM
DEC     \_direct\_            Decrement Direct RAM

DIV     AB                  Divide Acc by B

DJNZ    Rn,\_rel\_            Decrement Register and JNZ
DJNZ    \_direct\_,\_rel\_      Decrement Direct RAM and JNZ

INC     A                   Increment Acc
INC     Rn                  Increment Register
INC     @R0                 Increment Indirect RAM
INC     @R1                 Increment Indirect RAM
INC     DPTR                Increment Data Pointer
INC     \_direct\_            Increment Direct RAM

JB      \_bit\_,\_rel\_         Jump if Bit is set
JBC     \_bit\_,\_rel\_         Jump if Bit is set & clear Bit
JC      \_rel\_               Jump if Carry is set
JMP     @A+DPTR             Jump indirect relative to Data Pointer
JNB     \_bit\_,\_rel\_         Jump if Bit is clear
JNC     \_rel\_               Jump if Carry is clear
JNZ     \_rel\_               Jump if Acc is not zero
JZ      \_rel\_               Jump if Acc is zero

LCALL   \_addr16\_            Long Subroutine Call
LJMP    \_addr16\_            Long Jump

MOV     A,Rn                Move Register to Acc
MOV     A,@R0               Move Indirect RAM to Acc
MOV     A,@R1               Move Indirect RAM to Acc
MOV     A,#\_immed\_          Move Immediate data to Acc
MOV     A,\_direct\_          Move direct RAM to Acc
MOV     C,\_bit\_             Move bit to Acc
MOV     DPTR,#\_immed\_       Move immediate data to Data Pointer
MOV     Rn,A                Move Acc to Register
MOV     Rn,#\_immed\_         Move Immediate data to Register
MOV     Rn,\_direct\_         Move Direct RAM to Register
MOV     @R0,A               Move Acc to Indirect RAM
MOV     @R1,A               Move Acc to Indirect RAM
MOV     @R0,#\_immed\_        Move Immediate data to Indirect RAM
MOV     @R1,#\_immed\_        Move Immediate data to Indirect RAM
MOV     @R0,\_direct\_        Move Direct RAM to Indirect RAM
MOV     @R1,\_direct\_        Move Direct RAM to Indirect RAM
MOV     \_direct\_,A          Move Acc to Direct RAM
MOV     \_bit\_,C             Move Carry to Bit
MOV     \_direct\_,Rn         Move Register to Direct RAM
MOV     \_direct\_,@R0        Move Indirect RAM to Direct RAM
MOV     \_direct\_,@R1        Move Indirect RAM to Direct RAM
MOV     \_direct\_,#\_immed\_   Move Immediate data to Direct RAM
MOV     \_direct\_,\_direct\_   Move Direct RAM to Direct RAM
MOVC    A,@A+DPTR           Move code byte relative to DPTR to Acc
MOVC    A,@A+PC             Move code byte relative to PC to Acc

MOVX    A,@R0               Move external RAM to Acc
MOVX    A,@R1               Move external RAM to Acc
MOVX    A,@DPTR             Move external RAM to Acc (16 bit addr)
MOVX    @R0,A               Move Acc to external RAM
MOVX    @R1,A               Move Acc to external RAM
MOVX    @DPTR,A             Move Acc to external RAM (16 bit addr)

MUL     AB                  Multiply Acc by B

NOP                         No operation

ORL     A,Rn                OR Register and Acc
ORL     A,@R0               OR Indirect RAM and Acc
ORL     A,@R1               OR Indirect RAM and Acc
ORL     A,#\_immed\_          OR Immediate data and Acc
ORL     A,\_direct\_          OR Direct RAM and Acc
ORL     C,/\_bit\_            OR Complement of direct bit to Carry
ORL     C,\_bit\_             OR direct bit to Carry
ORL     \_direct\_,A          OR Acc to direct RAM
ORL     \_direct\_,#\_immed\_   OR Immediate data and direct RAM

POP     \_direct\_            Pop  from Stack and put in Direct RAM
PUSH    \_direct\_            Push from Direct RAM to Stack

RET                         Return from subroutine
RETI                        Return from Interrupt

RL      A                   Rotate Acc left
RLC     A                   Rotate Acc left through Carry
RR      A                   Rotate Acc right
RRC     A                   Rotate Acc right through Carry

SETB    C                   Set the Carry Bit
SETB    \_bit\_               Set Direct Bit

SJMP    \_rel\_               Short jump

SUBB    A,Rn                Subtract Register from Acc with Borrow
SUBB    A,@R0               Subtract Indirect RAM from Acc w/ Borrow
SUBB    A,@R1               Subtract Indirect RAM from Acc w/ Borrow
SUBB    A,#\_immed\_          Subtract Immediate data from Acc w/ Borrow
SUBB    A,\_direct\_          Subtract Direct RAM from Acc w/ Borrow

SWAP    A                   Swap nibbles of Acc

XCH     A,Rn                Exchange Acc with Register
XCH     A,@R0               Exchange Acc with Indirect RAM
XCH     A,@R1               Exchange Acc with Indirect RAM
XCH     A,\_direct\_          Exchange Acc with Direct RAM

XCHD    A,@R0               Exchange Digit in Acc with Indirect RAM
XCHD    A,@R1               Exchange Digit in Acc with Indirect RAM

XRL     A,Rn                Exclusive OR Register and Acc
XRL     A,@R0               Exclusive OR Indirect RAM and Acc
XRL     A,@R1               Exclusive OR Indirect RAM and Acc
XRL     A,#\_immed\_          Exclusive OR Immediate data and Acc
XRL     A,\_direct\_          Exclusive OR Direct RAM and Acc
XRL     \_direct\_,A          Exclusive OR Acc to direct RAM
XRL     \_direct\_,#\_immed\_   Exclusive OR Immediate data and direct RAM

Note that the above tables do not automatically define the various mnemonics that may be used for addressing the special function registers of the 8051. The user may wish to set up a file of equates (EQU's) that can be included in the source file for this purpose. The following illustrates some of the appropriate equates:

P0      .equ    080H    ;Port 0
SP      .equ    081H    ;Stack pointer
DPL     .equ    082H
DPH     .equ    083H
PCON    .equ    087H
TCON    .equ    088H
TMOD    .equ    089H
TL0     .equ    08AH
TL1     .equ    08BH
TH0     .equ    08CH
TH1     .equ    08DH
P1      .equ    090H    ;Port 1
SCON    .equ    098H
SBUF    .equ    099H
P2      .equ    0A0H    ;Port 2
IEC     .equ    0A8H
P3      .equ    0B0H    ;Port 3
IPC     .equ    0B8H
PSW     .equ    0D0H
ACC     .equ    0E0H    ;Accumulator
B       .equ    0F0H    ;Secondary Accumulator
;Now some bit addresses
P0.0    .equ    080H    ;Port 0 bit 0
P0.1    .equ    081H    ;Port 0 bit 1
P0.2    .equ    082H    ;Port 0 bit 2
P0.3    .equ    083H    ;Port 0 bit 3
P0.4    .equ    084H    ;Port 0 bit 4
P0.5    .equ    085H    ;Port 0 bit 5
P0.6    .equ    086H    ;Port 0 bit 6
P0.7    .equ    087H    ;Port 0 bit 7
ACC.0   .equ    0E0H    ;Acc bit 0
ACC.1   .equ    0E1H    ;Acc bit 1
ACC.2   .equ    0E2H    ;Acc bit 2
ACC.3   .equ    0E3H    ;Acc bit 3
ACC.4   .equ    0E4H    ;Acc bit 4
ACC.5   .equ    0E5H    ;Acc bit 5
ACC.6   .equ    0E6H    ;Acc bit 6
ACC.7   .equ    0E7H    ;Acc bit 7

See the manufacturer's data sheets for more information.

- - -

# 8085 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the 8085 version of TASM. The following symbols are used in the table:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_addr\_              Absolute address (16 bits)
\_data\_              Immediate data (8 bits)
\_data16\_            Immediate data (16 bits)
\_reg\_               Register (A,B,C,D,E,H,L)
\_rp\_                Register pair (B,D,H,SP)
\_port\_              Port address (0-255)
\_int\_               Interrupt level (0 - 7)

Any valid TASM expression can appear in the place of any of the above symbolics except \_reg\_, \_rp\_ and \_int\_.

OPCODE  OPERAND        DESCRIPTION
--------------------------------------------------------------------
ACI      \_data\_         Add immediate to A with carry
ADC      \_reg\_          Add \_reg\_ to A with carry
ADC      M              Add indirect memory (HL) with carry
ADD      \_reg\_          Add \_reg\_ to A
ADD      M              Add indirect memory (HL) to A
ADI      \_data\_         Add immediate to A

ANA      \_reg\_          And register with A
ANA      M              And indirect memory (HL) to A
ANI      \_data\_         And immediate to A

CALL     \_addr\_         Call subroutine at \_addr\_
CC       \_addr\_         Call subroutine if carry set
CNC      \_addr\_         Call subroutine if carry clear
CZ       \_addr\_         Call subroutine if zero
CNZ      \_addr\_         Call subroutine if non zero
CP       \_addr\_         Call subroutine if positive
CM       \_addr\_         Call subroutine if negative
CPE      \_addr\_         Call subroutine if even parity
CPO      \_addr\_         Call subroutine if odd  parity
CMA                     Complement A
CMC                     Complemennt carry
CMP      \_reg\_          Compare register with A
CMP      M              Compare indirect memory (HL) with A
CPI      \_data\_         Compare immediate data with A

DAA                     Decimal adjust A
DAD      \_rp\_           Add register pair to HL
DCR      \_reg\_          Decrement register
DCR      M              Decrement indirect memory (HL)
DCX      \_rp\_           Decrement register pair

DI                      Disable interrupts
EI                      Enable interrupts
HLT                     Halt

IN       \_port\_         Input on port
INR      \_reg\_          Increment register
INR      M              Increment indirect memory (HL)
INX      \_rp\_           Increment register pair

JMP      \_addr\_         Jump
JC       \_addr\_         Jump if carry set
JNC      \_addr\_         Jump if carry clear
JZ       \_addr\_         Jump if zero
JNZ      \_addr\_         Jump if not zero
JM       \_addr\_         Jump if minus
JP       \_addr\_         Jump if plus
JPE      \_addr\_         Jump if parity even
JPO      \_addr\_         Jump if parity odd

LDA      \_addr\_         Load A direct from memory
LDAX     B              Load A indirect from memory using BC
LDAX     D              Load A indirect from memory using DE
LHLD     \_addr\_         Load HL direct from memory
LXI      \_rp\_,\_data16\_  Load register pair with immediate data

MOV      \_reg\_,\_reg\_    Move register to register
MOV      \_reg\_,M        Move indirect memory (HL) to register
MVI      \_reg\_,\_data\_   Move immediate data to register

NOP                     No operation

ORA      \_reg\_          Or register with A
ORA      M              Or indirect memory (HL) with A
ORI      \_data\_         Or immediate data to A
OUT      \_port\_         Ouput to port

PCHL                    Jump to instruction at (HL)
POP      \_rp\_           Pop  register pair (excluding SP) from stack
PUSH     \_rp\_           Push register pair (excluding SP) onto stack
POP      PSW            Pop  PSW from stack
PUSH     PSW            Pop  PSW onto stack

RAL                     Rotate A left  with carry
RAR                     Rotate A right with carry
RLC                     Rotate A left  with branch carry
RRC                     Rotate A right with branch carry

RET                     Return from subroutine
RZ                      Return if zero
RNZ                     Return if non zero
RC                      Return if carry set
RNC                     Return if carry clear
RM                      Return if minus
RP                      Return if plus
RPE                     Return if parity even
RPO                     Return if parity odd

RIM                     Read interrupt mask
RST      \_int\_          Restart at vector \_int\_

SBB      \_reg\_          Subtract \_reg\_ from A         with borrow
SBB      M              Subtract indirect memory (HL) with borrow
SBI      \_data\_         Subtract immediate from A     with borrow
SUB      \_reg\_          Subtract \_reg\_ from A
SUB      M              Subtract indirect memory (HL) from A
SUI      \_data\_         Subtract immediate from A

SHLD     \_addr\_         Store HL
SIM                     Store Interrupt mask
SPHL                    Exchange SP with HL

STA      \_addr\_         Store A direct memory
STAX     B              Store A indirect using BC
STAX     D              Store A indirect using DE

STC                     Set carry

XRA      \_reg\_          Exclusive OR A with register
XRA      M              Exclusive Or A with indirect memory (HL)
XRI      \_data\_         Exclusive Or A with immediate data
XCHG                    Exchange DE with HL
XTHL                    Exchange HL with top of stack

See the manufacturer's data sheets for more information.

- - -

# Z80 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the Z80 version of TASM. The following symbols are used in the table:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_addr\_              Absolute address (16 bits)
\_bit\_               Bit address
\_data\_              Immediate data (8 bits)
\_data16\_            Immediate data (16 bits)
\_disp\_              Relative address
\_reg\_               Register (A, B, C, D, E, H, or L)
\_rp\_                Register pair (BC, DE, HL, or SP)
\_port\_              Port (0 - 255)
\_cond\_              Condition
			NZ - not zero
			Z  - zero
			NC - not carry
			C  - carry
			PO - parity odd
			PE - parity even
			P  - positive
			M  - minus

Any valid TASM expression can appear in the place of the \_addr\_, \_bit\_, \_data\_, \_data16\_, or \_disp\_ symbolics.

OPCODE  OPERAND         DESCRIPTION
--------------------------------------------------------------------
ADC  A,\_data\_           Add immediate with carry to accumulator
ADC  A,\_reg\_            Add register with carry to accumulator
ADC  A,(HL)             Add indirect memory with carry to accumulator
ADC  A,(IX+\_disp\_)      Add indirect memory with carry to accumulator
ADC  A,(IY+\_disp\_)      Add indirect memory with carry to accumulator
ADC  HL,\_rp\_            Add register pair with carry to HL

ADD  A,\_data\_           Add immediate to accumulator
ADD  A,\_reg\_            Add register to accumulator
ADD  A,(HL)             Add indirect memory to accumulator
ADD  A,(IX+\_disp\_)      Add indirect memory to accumulator
ADD  A,(IY+\_disp\_)      Add indirect memory to accumulator
ADD  HL,\_rp\_            Add register pair to HL
ADD  IX,\_rp\_            Add register pair to index register
ADD  IY,\_rp\_            Add register pair to index register

AND  \_data\_             And immediate with accumulator
AND  \_reg\_              And register  with accumulator
AND  (HL)               And memory with accumulator
AND  (IX+\_disp\_)        And memory with accumulator
AND  (IY+\_disp\_)        And memory with accumulator

BIT  \_bit\_,\_reg\_        Test \_bit\_ in register
BIT  \_bit\_,(HL)         Test \_bit\_ in indirect memory
BIT  \_bit\_,(IY+\_disp\_)  Test \_bit\_ in indirect memory
BIT  \_bit\_,(IX+\_disp\_)  Test \_bit\_ in indirect memory

CALL \_addr\_             Call the routine at \_addr\_
CALL \_cond\_,\_addr\_      Call the routine if \_cond\_ is satisfied

CCF                     Complement carry flag

CP   \_data\_             Compare immediate data with accumulator
CP   \_reg\_              Compare register with accumulator
CP   (HL)               Compare indirect memory with accumulator
CP   (IX+\_disp\_)        Compare indirect memory with accumulator
CP   (IY+\_disp\_)        Compare indirect memory with accumulator
CPD                     Compare accumulator with memory and
                            decrement address and byte counters
CPDR                    Compare accumulator with memory and
                            decrement address and byte counter,
                            continue until match is found or
                            byte counter is zero

CPI                     Compare accumulator with memory and
                            increment address and byte counters
CPIR                    Compare accumulator with memory and
                            increment address and byte counter,
                            continue until match is found or
                            byte counter is zero
CPL                     Complement the accumulator
DAA                     Decimal adjust accumulator
DEC  \_reg\_              Decrement register contents
DI                      Disable interrupts
DJNZ \_disp\_             Decrement reg B and jump relative if zero
EI                      Enable interrupts
EX   AF,AF'             Exchange program status and alt program stat
EX   DE,HL              Exchange DE and HL contents
EX   (SP),HL            Exchange contents of HL and top of stack
EX   (SP),IX            Exchange contents of IX and top of stack
EX   (SP),IY            Exchange contents of IY and top of stack
EXX                     Exchange register pairs and alt reg pairs
HALT                    Program execution stops
IM   0                  Interrupt mode 0
IM   1                  Interrupt mode 1
IM   2                  Interrupt mode 2
IN   A,\_port\_           Input port to accumulator
INC  \_reg\_              Increment contents of register
INC  \_rp\_               Increment contents of register pair
INC  IX                 Increment IX
INC  IY                 Increment IY
INC  (HL)               Increment indirect memory
INC  (IX+\_disp\_)        Increment indirect memory
INC  (IY+\_disp\_)        Increment indirect memory
IND                     Input to memory and decrement pointer
INDR                    Input to memory and decrement pointer until
                            byte counter is zero
INI                     Input to memory and increment pointer
INIR                    Input to memory and increment pointer until
                            byte counter is zero
IN   \_reg\_,(C)          Input to register

JP   \_addr\_             Jump to location
JP   \_cond\_,\_addr\_      Jump to location if condition satisifed
JP   (HL)               Jump to location pointed to by HL
JP   (IX)               Jump to location pointed to by IX
JP   (IY)               Jump to location pointed to by IY

JR   \_disp\_             Jump relative
JR   C,\_disp\_           Jump relative if carry is set
JR   NC,\_disp\_          Jump relative if carry bit is reset
JR   NZ,\_disp\_          Jump relative if zero flag is reset
JR   Z,\_disp\_           Jump relative if zero flag is set

LD   A,I                Move interrupt vector contents to accumulator
LD   A,R                Move refresh reg contents to accumulator
LD   A,(\_addr\_)         Load accumulator indirect from memory
LD   A,(\_rp\_)           Load accumulator indirect from memory by \_rp\_
LD   \_reg\_,\_reg\_        Load source register to destination register
LD   \_rp\_,(\_addr\_)      Load register pair indirect from memory
LD   IX,(\_addr\_)        Load IX indirect from memory
LD   IY,(\_addr\_)        Load IY indirect from memory
LD   I,A                Load interrup vector from accumulator
LD   R,A                Load refresh register from accumulator
LD   \_reg\_,\_data\_       Load register with immediate data
LD   \_rp\_,\_data16\_      Load register pair with immediate data
LD   IX,\_data16\_        Load  IX  with immediate data
LD   IY,\_data16\_        Load  IY  with immediate data
LD   \_reg\_,(HL)         Load register indirect from memory
LD   \_reg\_,(IX+\_disp\_)  Load register indirect from memory
LD   \_reg\_,(IY+\_disp\_)  Load register indirect from memory
LD   SP,HL              Load contents of HL to stack pointer
LD   SP,IX              Load contents of IX to stack pointer
LD   SP,IY              Load contents of IY to stack pointer
LD   (addr),A           Load contents of A to memory
LD   (\_addr\_),HL        Load contents of HL to memory
LD   (\_addr\_),\_rp\_      Load contents of register pair to memory
LD   (\_addr\_),IX        Load contents of IX to memory
LD   (\_addr\_),IY        Load contents of IY to memory
LD   (HL),\_data\_        Load immediate into indirect memory
LD   (IX+\_disp\_),\_data\_ Load immediate into indirect memory
LD   (IY+\_disp\_),\_data\_ Load immediate into indirect memory
LD   (HL),\_reg\_         Load register  into indirect memory
LD   (IX+\_disp\_),\_reg\_  Load register  into indirect memory
LD   (IY+\_disp\_),\_reg\_  Load register  into indirect memory
LD   (\_rp\_),A           Load accumulator into indirect memory
LDD                     Transfer data between memory and decrement
                            destination and source addresses
LDDR                    Transfer data between memory until byte
                            counter is zero, decrement destintation
                            and source addresses
LDI                     Transfer data between memory and increment
                            destination and source addresses
LDIR                    Transfer data between memory until byte
                            counter is zero, increment destination
                            and source addresses
NEG                     Negate contents of accumulator
NOP                     No operation
OR   \_data\_             Or immediate with accumulator
OR   \_reg\_              Or register with accumulator
OR   (HL)               Or indirect memory with accumulator
OR   (IX+\_disp\_)        Or indirect memory with accumulator
OR   (IY+\_disp\_)        Or indirect memory with accumulator
OUT  (C),\_reg\_          Output from registor
OUTD                    Output from memory, decrement address
OTDR                    Output from memory, decrement address
                            continue until reg B is zero
OUTI                    Output from memory, increment address
OTIR                    Output from memory, increment address
                            continue until reg B is zero
OUT  \_port\_,A           Output from accumulator
POP  \_rp\_               Load register pair from top of stack
POP  IX                 Load IX from top of stack
POP  IY                 Load IY from top of stack
PUSH \_rp\_               Store resister pair on top of stack
PUSH IX                 Store IX on top of stack
PUSH IY                 Store IY on top of stack
RES  \_bit\_,\_reg\_        Reset register bit
RES  \_bit\_,(HL)         Reset bit at indirect memory location
RES  \_bit\_,(IX+disp)    Reset bit at indirect memory location
RES  \_bit\_,(IY+\_disp\_)  Reset bit at indirect memory location
RET                     Return from subroutine
RET  \_cond\_             Return from subroutine if condition true
RETI                    Return from interrupt
RETN                    Return from non-maskable interrupt
RL   \_reg\_              Rotate left through carry register contents
RL   (HL)               Rotate left through carry indirect memory
RL   (IX+\_disp\_)        Rotate left through carry indirect memory
RL   (IY+\_disp\_)        Rotate left through carry indirect memory
RLA                     Rotate left through carry accumulator
RLC  \_reg\_              Rotate left branch  carry register contents
RLC  (HL)               Rotate left branch  carry indirect memory
RLC  (IX+\_disp\_)        Rotate left branch  carry indirect memory
RLC  (IY+\_disp\_)        Rotate left branch  carry indirect memory
RLCA                    Rotate left accumulator
RLD                     Rotate one BCD digit left between the
                            accumulator and memory
RR   \_reg\_              Rotate right through carry register contents
RR   (HL)               Rotate right through carry indirect memory
RR   (IX+\_disp\_)        Rotate right through carry indirect memory
RR   (IY+\_disp\_)        Rotate right through carry indirect memory
RRA                     Rotate right through carry accumulator
RRC  \_reg\_              Rotate right branch  carry register contents
RRC  (HL)               Rotate right branch  carry indirect memory
RRC  (IX+\_disp\_)        Rotate right branch  carry indirect memory
RRC  (IY+\_disp\_)        Rotate right branch  carry indirect memory
RRCA                    Rotate right branch  carry accumulator
RRD                     Rotate one BCD digit right between the
                            accumulator and memory
RST                     Restart
SBC  A,\_data\_           Subtract data            from A with borrow
SBC  A,\_reg\_            Subtract register        from A with borrow
SBC  A,(HL)             Subtract indirect memory from A with borrow
SBC  A,(IX+\_disp\_)      Subtract indirect memory from A with borrow
SBC  A,(IY+\_disp\_)      Subtract indirect memory from A with borrow
SBC  HL,\_rp\_            Subtract register pair from HL with borrow
SCF                     Set carry flag
SET  \_bit\_,\_reg\_        Set register bit
SET  \_bit\_,(HL)         Set indirect memory bit
SET  \_bit\_,(IX+\_disp\_)  Set indirect memory bit
SET  \_bit\_,(IY+\_disp\_)  Set indirect memory bit
SLA  \_reg\_              Shift register left arithmetic
SLA  (HL)               Shift indirect memory left arithmetic
SLA  (IX+\_disp\_)        Shift indirect memory left arithmetic
SLA  (IY+\_disp\_)        Shift indirect memory left arithmetic
SRA  \_reg\_              Shift register right arithmetic
SRA  (HL)               Shift indirect memory right arithmetic
SRA  (IX+\_disp\_)        Shift indirect memory right arithmetic
SRA  (IY+\_disp\_)        Shift indirect memory right arithmetic
SRL  \_reg\_              Shift register right logical
SRL  (HL)               Shift indirect memory right logical
SRL  (IX+\_disp\_)        Shift indirect memory right logical
SRL  (IY+\_disp\_)        Shift indirect memory right logical
SUB  \_data\_             Subtract immediate from accumulator
SUB  \_reg\_              Subtract register from accumulator
SUB  (HL)               Subtract indirect memory from accumulator
SUB  (IX+\_disp\_)        Subtract indirect memory from accumulator
SUB  (IY+\_disp\_)        Subtract indirect memory from accumulator
XOR  \_data\_             Exclusive or immediate with accumulator
XOR  \_reg\_              Exclusive or register with accumulator
XOR  (HL)               Exclusive or indirect memory with accumulator
XOR  (IX+\_disp\_)        Exclusive or indirect memory with accumulator
XOR  (IY+\_disp\_)        Exclusive or indirect memory with accumulator

See the manufacturer's data sheets for more information.

- - -

# 6805 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the 6805 version of TASM. The following symbols are used in the table:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_addr\_              Absolute address (16 bits)
\_addr8\_             Absolute address (8 bits)
\_bit\_               Bit address
\_data\_              Immediate data (8 bits)
\_rel\_               Relative address

Any valid TASM expression can appear in the place of the \_addr\_, \_addr8\_, \_bit\_, \_data\_, or \_rel\_ symbolics.

OPCODE  OPERAND         DESCRIPTION
--------------------------------------------------------------
ADC     #\_data\_         Add with carry, immediate
ADC     ,X              Add with carry, indexed, no offset
ADC     \_addr8\_,X       Add with carry, indexed, 1 byte offset
ADC     \_addr\_,X        Add with carry, indexed, 2 byte offset
ADC     \_addr8\_         Add with carry, direct
ADC     \_addr\_          Add with carry, extended

ADD     #\_data\_         Add, immediate
ADD     ,X              Add, indexed, no offset
ADD     \_addr8\_,X       Add, indexed, 1 byte offset
ADD     \_addr\_,X        Add, indexed, 2 byte offset
ADD     \_addr8\_         Add, direct
ADD     \_addr\_          Add, extended

AND     #\_data\_         And, immediate
AND     ,X              And, indexed, no offset
AND     \_addr8\_,X       And, indexed, 1 byte offset
AND     \_addr\_,X        And, indexed, 2 byte offset
AND     \_addr8\_         And, direct
AND     \_addr\_          And, extended

ASLA                    Arithmetic Shift Left, accumulator
ASLX                    Arithmetic Shift Left, index register
ASL     \_addr8\_         Arithmetic Shift Left, direct
ASL     ,X              Arithmetic Shift Left, indexed, no offset
ASL     \_addr8\_,X       Arithmetic Shift Left, indexed, 1 byte offset

ASRA                    Arithmetic Shift Right, accumulator
ASRX                    Arithmetic Shift Right, index register
ASR     \_addr8\_         Arithmetic Shift Right, direct
ASR     ,X              Arithmetic Shift Right, indexed, no offset
ASR     \_addr8\_,X       Arithmetic Shift Right, indexed, 1 byte offset

BCC     \_rel\_           Branch if carry clear
BCLR    \_bit\_,\_addr8\_   Bit Clear in memory
BCS     \_rel\_           Branch if carry set
BEQ     \_rel\_           Branch if equal
BHCC    \_rel\_           Branch if half carry clear
BHCS    \_rel\_           Branch if half carry set
BHI     \_rel\_           Branch if higher
BHS     \_rel\_           Branch if higher or same
BIH     \_rel\_           Branch if interrupt line is high
BIL     \_rel\_           Branch if interrupt is low

BIT     #\_data\_         Bit test, immediate
BIT     ,X              Bit test, indexed, no offset
BIT     \_addr8\_,X       Bit test, indexed, 1 byte offset
BIT     \_addr\_,X        Bit test, indexed, 2 byte offset
BIT     \_addr8\_         Bit test, direct
BIT     \_addr\_          Bit test, extended

BLO     \_rel\_           Branch if lower
BLS     \_rel\_           Branch if lower or same
BMC     \_rel\_           Branch if interrupt mask is clear
BMI     \_rel\_           Branch if minus
BMS     \_rel\_           Branch if interuupt mask bit is set
BNE     \_rel\_           Branch if not equal
BPL     \_rel\_           Branch if plus
BRA     \_rel\_           Branch always
BRCLR   \_bit\_,\_addr8\_,\_rel\_     Branch if bit is clear
BRN     \_rel\_           Branch never
BRSET   \_bit\_,\_addr8\_,\_rel\_     Branch if bit is set
BSET    \_bit\_,\_addr8\_   Bit set in memory
BSR     \_rel\_           Branch to subroutine

CLC                     Clear carry bit
CLI                     Clear interuupt mask bit

CLRA                    Clear, accumulator
CLRX                    Clear, index register
CLR     \_addr8\_         Clear, direct
CLR     ,X              Clear, indexed, no offset
CLR     \_addr8\_,X       Clear, indexed, 1 byte offset

CMP     #\_data\_         Compare Acc, immediate
CMP     ,X              Compare Acc, indexed, no offset
CMP     \_addr8\_,X       Compare Acc, indexed, 1 byte offset
CMP     \_addr\_,X        Compare Acc, indexed, 2 byte offset
CMP     \_addr8\_         Compare Acc, direct
CMP     \_addr\_          Compare Acc, extended

COMA                    Complement, accumulator
COMX                    Complement, index register
COM     \_addr8\_         Complement, direct
COM     ,X              Complement, indexed, no offset
COM     \_addr8\_,X       Complement, indexed, 1 byte offset

CPX     #\_data\_         Compare Index, immediate
CPX     ,X              Compare Index, indexed, no offset
CPX     \_addr8\_,X       Compare Index, indexed, 1 byte offset
CPX     \_addr\_,X        Compare Index, indexed, 2 byte offset
CPX     \_addr8\_         Compare Index, direct
CPX     \_addr\_          Compare Index, extended

DECA                    Decrement, accumulator
DECX                    Decrement, index register
DEX                     Decrement, index register (alternate of DECX)
DEC     \_addr8\_         Decrement, direct
DEC     ,X              Decrement, indexed, no offset
DEC     \_addr8\_,X       Decrement, indexed, 1 byte offset

EOR     #\_data\_         Exclusive OR, immediate
EOR     ,X              Exclusive OR, indexed, no offset
EOR     \_addr8\_,X       Exclusive OR, indexed, 1 byte offset
EOR     \_addr\_,X        Exclusive OR, indexed, 2 byte offset
EOR     \_addr8\_         Exclusive OR, direct
EOR     \_addr\_          Exclusive OR, extended

INCA                    Increment, accumulator
INCX                    Increment, index register
INX                     Increment, index register (alternate of INCX)
INC     \_addr8\_         Increment, direct
INC     ,X              Increment, indexed, no offset
INC     \_addr8\_,X       Increment, indexed, 1 byte offset

JMP     ,X              Jump, indexed, no offset
JMP     \_addr8\_,X       Jump, indexed, 1 byte offset
JMP     \_addr\_,X        Jump, indexed, 2 byte offset
JMP     \_addr8\_         Jump, direct
JMP     \_addr\_          Jump, extended

JSR     ,X              Jump Subroutine, indexed, no offset
JSR     \_addr8\_,X       Jump Subroutine, indexed, 1 byte offset
JSR     \_addr\_,X        Jump Subroutine, indexed, 2 byte offset
JSR     \_addr8\_         Jump Subroutine, direct
JSR     \_addr\_          Jump Subroutine, extended

LDA     #\_data\_         Load Acc, immediate
LDA     ,X              Load Acc, indexed, no offset
LDA     \_addr8\_,X       Load Acc, indexed, 1 byte offset
LDA     \_addr\_,X        Load Acc, indexed, 2 byte offset
LDA     \_addr8\_         Load Acc, direct
LDA     \_addr\_          Load Acc, extended

LDX     #\_data\_         Load Index, immediate
LDX     ,X              Load Index, indexed, no offset
LDX     \_addr8\_,X       Load Index, indexed, 1 byte offset
LDX     \_addr\_,X        Load Index, indexed, 2 byte offset
LDX     \_addr8\_         Load Index, direct
LDX     \_addr\_          Load Index, extended

LSLA                    Logical Shift Left, accumulator
LSLX                    Logical Shift Left, index register
LSL     \_addr8\_         Logical Shift Left, direct
LSL     ,X              Logical Shift Left, indexed, no offset
LSL     \_addr8\_,X       Logical Shift Left, indexed, 1 byte offset

LSRA                    Logical Shift Right, accumulator
LSRX                    Logical Shift Right, index register
LSR     \_addr8\_         Logical Shift Right, direct
LSR     ,X              Logical Shift Right, indexed, no offset
LSR     \_addr8\_,X       Logical Shift Right, indexed, 1 byte offset

NEGA                    Negate, accumulator
NEGX                    Negate, index register
NEG     \_addr8\_         Negate, direct
NEG     ,X              Negate, indexed, no offset
NEG     \_addr8\_,X       Negate, indexed, 1 byte offset

NOP                     No Operation

ORA     #\_data\_         Inclusive OR Acc, immediate
ORA     ,X              Inclusive OR Acc, indexed, no offset
ORA     \_addr8\_,X       Inclusive OR Acc, indexed, 1 byte offset
ORA     \_addr\_,X        Inclusive OR Acc, indexed, 2 byte offset
ORA     \_addr8\_         Inclusive OR Acc, direct
ORA     \_addr\_          Inclusive OR Acc, extended

ROLA                    Rotate Left thru Carry, accumulator
ROLX                    Rotate Left thru Carry, index register
ROL     \_addr8\_         Rotate Left thru Carry, direct
ROL     ,X              Rotate Left thru Carry, indexed, no offset
ROL     \_addr8\_,X       Rotate Left thru Carry, indexed, 1 byte offset

RORA                    Rotate Right thru Carry, accumulator
RORX                    Rotate Right thru Carry, index register
ROR     \_addr8\_         Rotate Right thru Carry, direct
ROR     ,X              Rotate Right thru Carry, indexed, no offset
ROR     \_addr8\_,X       Rotate Right thru Carry, indexed, 1 byte offset

RSP                     Reset Stack Pointer
RTI                     Return from Interrupt
RTS                     Return from Subroutine

SBC     #\_data\_         Subtract with Carry, immediate
SBC     ,X              Subtract with Carry, indexed, no offset
SBC     \_addr8\_,X       Subtract with Carry, indexed, 1 byte offset
SBC     \_addr\_,X        Subtract with Carry, indexed, 2 byte offset
SBC     \_addr8\_         Subtract with Carry, direct
SBC     \_addr\_          Subtract with Carry, extended

SEC                     Set carry bit
SEI                     Set interrupt Mask bit

STA     #\_data\_         Store Acc, immediate
STA     ,X              Store Acc, indexed, no offset
STA     \_addr8\_,X       Store Acc, indexed, 1 byte offset
STA     \_addr\_,X        Store Acc, indexed, 2 byte offset
STA     \_addr8\_         Store Acc, direct
STA     \_addr\_          Store Acc, extended

STOP                    Enable IRQ, Stop Oscillator

STX     #\_data\_         Store Index, immediate
STX     ,X              Store Index, indexed, no offset
STX     \_addr8\_,X       Store Index, indexed, 1 byte offset
STX     \_addr\_,X        Store Index, indexed, 2 byte offset
STX     \_addr8\_         Store Index, direct
STX     \_addr\_          Store Index, extended

SUB     #\_data\_         Subtract, immediate
SUB     ,X              Subtract, indexed, no offset
SUB     \_addr8\_,X       Subtract, indexed, 1 byte offset
SUB     \_addr\_,X        Subtract, indexed, 2 byte offset
SUB     \_addr8\_         Subtract, direct
SUB     \_addr\_          Subtract, extended

SWI                     Software Interrupt

TAX                     Transfer Acc to Index

TSTA                    Test for neg or zero, accumulator
TSTX                    Test for neg or zero, index register
TST     \_addr8\_         Test for neg or zero, direct
TST     ,X              Test for neg or zero, indexed, no offset
TST     \_addr8\_,X       Test for neg or zero, indexed, 1 byte offset

TXA                     Transfer Index to Acc

WAIT                    Enable Interrupt, Stop Processor

See the manufacturer's data sheets for more information.

- - -

# TMS32010 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the TMS32010 version of TASM. The following symbols are used in the table:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_ar\_                Auxiliary register (AR0, AR1)
\_arp\_               Auxiliary register pointer
\_dma\_               Direct memory address
\_pma\_               Program memory address
\_port\_              Port address (0 - 7)
\_shift\_             Shift count  (0 - 15)
\_const1\_            Constant (1 bit)
\_const8\_            Constant (8 bit)
\_const13\_           Constant (13 bit)

Any valid TASM expression can appear in the place of any of the above symbolics.

OPCODE   OPERAND            DESCRIPTION
--------------------------------------------------------------------
ABS                         Absolute value of ACC

ADD      \*+,\_shift\_,\_arp\_   Add to ACC with shift
ADD      \*-,\_shift\_,\_arp\_
ADD      \*, \_shift\_,\_arp\_
ADD      \*+,\_shift\_
ADD      \*-,\_shift\_
ADD      \*, \_shift\_
ADD      \*+
ADD      \*-
ADD      \*
ADD      \_dma\_,\_shift\_
ADD      \_dma\_

ADDH     \*+,\_arp\_           Add to high-order ACC bits
ADDH     \*-,\_arp\_
ADDH     \*, \_arp\_
ADDH     \*+
ADDH     \*-
ADDH     \*
ADDH     \_dma\_

ADDS     \*+,\_arp\_           Add to ACC with no sign extension
ADDS     \*-,\_arp\_
ADDS     \*, \_arp\_
ADDS     \*+
ADDS     \*-
ADDS     \*
ADDS     \_dma\_

AND      \*+,\_arp\_           AND with ACC
AND      \*-,\_arp\_
AND      \*, \_arp\_
AND      \*+
AND      \*-
AND      \*
AND      \_dma\_

APAC                        Add P register to ACC

B        \_pma\_              Branch unconditionally
BANZ     \_pma\_              Branch on auxiliary register not zero
BGEZ     \_pma\_              Branch if ACC >= 0
BGZ      \_pma\_              Branch if ACC >  0
BIOZ     \_pma\_              Branch on BIO- = 0
BLEZ     \_pma\_              Branch if ACC <= 0
BLZ      \_pma\_              Branch if ACC <  0
BNZ      \_pma\_              Branch if ACC 

 0
BV       \_pma\_              Branch on overflow
BZ       \_pma\_              Branch if ACC =  0

CALA                        Call subroutine from ACC
CALL     \_pma\_              Call subroutine at \_pma\_

DINT                        Disable interrupt

DMOV     \*+,\_arp\_           Data move in memory
DMOV     \*-,\_arp\_
DMOV     \*, \_arp\_
DMOV     \*+
DMOV     \*-
DMOV     \*
DMOV     \_dma\_

EINT                        Enable Interrupt

IN       \*+,\_port\_ ,\_arp\_   Input data from port
IN       \*-,\_port\_ ,\_arp\_
IN       \* ,\_port\_ ,\_arp\_
IN       \*+,\_port\_
IN       \*-,\_port\_
IN       \* ,\_port\_
IN       \_dma\_,\_port\_

LAC      \*+,\_shift\_,\_arp\_   Load ACC with shift
LAC      \*-,\_shift\_,\_arp\_
LAC      \*, \_shift\_,\_arp\_
LAC      \*+,\_shift\_
LAC      \*-,\_shift\_
LAC      \*, \_shift\_
LAC      \*+
LAC      \*-
LAC      \*
LAC      \_dma\_,\_shift\_
LAC      \_dma\_

LACK     \_const8\_                   Load ACC with 8 bit constant

LAR      \_ar\_,\*+,\_arp\_              Load auxiliary Register
LAR      \_ar\_,\*-,\_arp\_
LAR      \_ar\_,\*, \_arp\_
LAR      \_ar\_,\*+
LAR      \_ar\_,\*-
LAR      \_ar\_,\*
LAR      \_ar\_,\_dma\_

LARK     \_ar\_,\_const8\_              Load aux register with constant
LARP     \_const1\_                   Load aux register pointer immed

LDP      \*+,\_arp\_                   Load data memory page pointer
LDP      \*-,\_arp\_
LDP      \*, \_arp\_
LDP      \*+
LDP      \*-
LDP      \*
LDP      \_dma\_

LDPK     \_const1\_                   Load data page pointer immediate

LST      \*+,\_arp\_                   Load status from data memory
LST      \*-,\_arp\_
LST      \*, \_arp\_
LST      \*+
LST      \*-
LST      \*
LST      \_dma\_

LT       \*+,\_arp\_                   Load T register
LT       \*-,\_arp\_
LT       \*, \_arp\_
LT       \*+
LT       \*-
LT       \*
LT       \_dma\_

LTA      \*+,\_arp\_                   Load T register and accumulate
LTA      \*-,\_arp\_                     product
LTA      \*, \_arp\_
LTA      \*+
LTA      \*-
LTA      \*
LTA      \_dma\_

LTD      \*+,\_arp\_                   Load T reg, accumulate product,
LTD      \*-,\_arp\_                     and move
LTD      \*, \_arp\_
LTD      \*+
LTD      \*-
LTD      \*
LTD      \_dma\_

MAR      \*+,\_arp\_                   Modify auxiliary register
MAR      \*-,\_arp\_
MAR      \*, \_arp\_
MAR      \*+
MAR      \*-
MAR      \*
MAR      \_dma\_

MPY      \*+,\_arp\_                   Multiply
MPY      \*-,\_arp\_
MPY      \*, \_arp\_
MPY      \*+
MPY      \*-
MPY      \*
MPY      \_dma\_

MPYK     \_const13\_                  Multiply immediate

NOP                                 No Operation

OR       \*+,\_arp\_                   OR  with low order bits of ACC
OR       \*-,\_arp\_
OR       \*, \_arp\_
OR       \*+
OR       \*-
OR       \*
OR       \_dma\_

OUT      \*+,\_port\_,\_arp\_            Output data to port
OUT      \*-,\_port\_,\_arp\_
OUT      \*, \_port\_,\_arp\_
OUT      \*+,\_port\_
OUT      \*-,\_port\_
OUT      \*, \_port\_
OUT      \_dma\_,\_port\_

PAC                                 Load ACC with P register
POP                                 Pop top of stack to ACC
PUSH                                Push ACC onto stack
RET                                 Return from subroutine
ROVM                                Reset overflow mode register

SACH     \*+,\_shift\_,\_arp\_           Store ACC high with shift
SACH     \*-,\_shift\_,\_arp\_             Note: shift can only be 0, 1,
SACH     \*, \_shift\_,\_arp\_                   or 4
SACH     \*+,\_shift\_
SACH     \*-,\_shift\_
SACH     \*, \_shift\_
SACH     \*+
SACH     \*-
SACH     \*
SACH     \_dma\_,\_shift\_
SACH     \_dma\_

SACL     \*+,\_arp\_                   Store ACC low
SACL     \*-,\_arp\_
SACL     \*, \_arp\_
SACL     \*+
SACL     \*-
SACL     \*
SACL     \_dma\_

SAR      \_ar\_,\*+,\_arp\_              Store auxiliary Register
SAR      \_ar\_,\*-,\_arp\_
SAR      \_ar\_,\*, \_arp\_
SAR      \_ar\_,\*+
SAR      \_ar\_,\*-
SAR      \_ar\_,\*
SAR      \_ar\_,\_dma\_

SOVM                                Set overflow mode register
SPAC                                Subtract P register from ACC

SST      \*+,\_arp\_                   Store status
SST      \*-,\_arp\_
SST      \*, \_arp\_
SST      \*+
SST      \*-
SST      \*
SST      \_dma\_

SUB      \*+,\_shift\_,\_arp\_           Subtract from ACC with shift
SUB      \*-,\_shift\_,\_arp\_
SUB      \*, \_shift\_,\_arp\_
SUB      \*+,\_shift\_
SUB      \*-,\_shift\_
SUB      \*, \_shift\_
SUB      \*+
SUB      \*-
SUB      \*
SUB      \_dma\_,\_shift\_
SUB      \_dma\_

SUBC     \*+,\_arp\_                   Conditional subtract
SUBC     \*-,\_arp\_
SUBC     \*, \_arp\_
SUBC     \*+
SUBC     \*-
SUBC     \*
SUBC     \_dma\_

SUBH     \*+,\_arp\_                   Subtract from high-order ACC
SUBH     \*-,\_arp\_
SUBH     \*, \_arp\_
SUBH     \*+
SUBH     \*-
SUBH     \*
SUBH     \_dma\_

SUBS     \*+,\_arp\_                   Subtract from low ACC with
SUBS     \*-,\_arp\_                     sign-extension suppressed
SUBS     \*, \_arp\_
SUBS     \*+
SUBS     \*-
SUBS     \*
SUBS     \_dma\_

TBLR     \*+,\_arp\_                   Table Read
TBLR     \*-,\_arp\_
TBLR     \*, \_arp\_
TBLR     \*+
TBLR     \*-
TBLR     \*
TBLR     \_dma\_

TBLW     \*+,\_arp\_                   Table Write
TBLW     \*-,\_arp\_
TBLW     \*, \_arp\_
TBLW     \*+
TBLW     \*-
TBLW     \*
TBLW     \_dma\_

XOR      \*+,\_arp\_                   Exclusive OR with low bits of ACC
XOR      \*-,\_arp\_
XOR      \*, \_arp\_
XOR      \*+
XOR      \*-
XOR      \*
XOR      \_dma\_

ZAC                                 Zero the ACC

ZALH     \*+,\_arp\_                   Zero ACC and load high
ZALH     \*-,\_arp\_
ZALH     \*, \_arp\_
ZALH     \*+
ZALH     \*-
ZALH     \*
ZALH     \_dma\_

ZALS     \*+,\_arp\_                   Zero ACC and load low with
ZALS     \*-,\_arp\_                     sign extension suppressed
ZALS     \*, \_arp\_
ZALS     \*+
ZALS     \*-
ZALS     \*
ZALS     \_dma\_

See manufacturer's data for more information.

- - -

# TMS32025 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the TMS32025 version of TASM. The following symbols are used in the table:

SYMBOLIC            DESCRIPTION
-----------------------------------------------
\_ar\_                Auxiliary register (AR0, AR1, ...)
\_arp\_               Auxiliary register pointer
\_nextarp\_           Auxiliary register pointer (for next operation)
\_dma\_               Direct memory address
\_pma\_               Program memory address
\_port\_              Port address (0 - 7)
\_shift\_             Shift count  (0 - 15)
\_const1\_            Constant (1 bit)
\_const2\_            Constant (2 bit)
\_const8\_            Constant (8 bit)
\_const13\_           Constant (13 bit)
\_ind\_               Indirect addressing mode indicator
                      (see following table)

Any valid TASM expression can appear in the place of any of the above symbolics except for \_ind\_. The \_ind\_ symbolic must be one of the following:

        
\_ind\_
-------
\*BR0+
\*BR0-
\*0+
\*0-
\*+
\*-
\*

OPCODE   OPERAND                DESCRIPTION
--------------------------------------------------------------------
ABS                             Absolute value of ACC

ADD  \_ind\_,\_shift\_,\_nextarp\_    Add to ACC with shift
ADD  \_ind\_,\_shift\_
ADD  \_ind\_
ADD  \_dma\_,\_shift\_
ADD  \_dma\_

ADDC \_ind\_,\_nextarp\_            Add to ACC with carry
ADDC \_ind\_
ADDC \_dma\_

ADDH \_ind\_,\_nextarp\_            Add to high ACC
ADDH \_ind\_
ADDH \_dma\_

ADDK \_const8\_                   Add to ACC short immediate
ADDS \_ind\_,\_nextarp\_            Add to ACC with sign-extension suppressed
ADDS \_ind\_
ADDS \_dma\_

ADDT \_ind\_,\_nextarp\_            Add to ACC with shift specified by T reg
ADDT \_ind\_
ADDT \_dma\_

ADLK \_const8\_,\_shift\_           Add to ACC long immediate with shift
ADLK \_const8\_

ADRK \_const8\_                   Add to aux register short immediate

AND  \_ind\_,\_nextarp\_            And with ACC
AND  \_ind\_
AND  \_dma\_

ANDK \_const8\_,\_shift\_           And immediate with ACC with shift
ANDK \_const8\_

APAC                            Add P register to ACC

B    \_pma\_,\_ind\_,\_nextarp\_      Branch unconditionally
B    \_pma\_,\_ind\_
B    \_pma\_

BACC                            Branch to address specified by ACC

BANZ \_pma\_,\_ind\_,\_nextarp\_      Branch on Aux register not zero
BANZ \_pma\_,\_ind\_
BANZ \_pma\_

BBNZ \_pma\_,\_ind\_,\_nextarp\_      Branch on TC bit not zero
BBNZ \_pma\_,\_ind\_
BBNZ \_pma\_

BBZ  \_pma\_,\_ind\_,\_nextarp\_      Branch on TC bit equal to zero
BBZ  \_pma\_,\_ind\_
BBZ  \_pma\_

BC   \_pma\_,\_ind\_,\_nextarp\_      Branch on carry
BC   \_pma\_,\_ind\_
BC   \_pma\_

BGEZ \_pma\_,\_ind\_,\_nextarp\_      Branch if ACC >= zero
BGEZ \_pma\_,\_ind\_
BGEZ \_pma\_

BGZ  \_pma\_,\_ind\_,\_nextarp\_      Branch if ACC > zero
BGZ  \_pma\_,\_ind\_
BGZ  \_pma\_

BIOZ \_pma\_,\_ind\_,\_nextarp\_      Branch on I/O status = zero
BIOZ \_pma\_,\_ind\_
BIOZ \_pma\_

BIT  \_ind\_,\_bitcode\_,\_nextarp\_  Test bit
BIT  \_ind\_,\_bitcode\_
BIT  \_dma\_,\_bitcode\_

BITT \_ind\_,\_nextarp\_            Test bit specified by T register
BITT \_ind\_
BITT \_dma\_

BLEZ \_pma\_,\_ind\_,\_nextarp\_      Branch if ACC <= zero
BLEZ \_pma\_,\_ind\_
BLEZ \_pma\_

BLKD \_dma\_,\_ind\_,\_nextarp\_      Block move from data mem to data mem
BLKD \_dma\_,\_ind\_
BLKD \_dma\_,\_dma\_

BLKP \_pma\_,\_ind\_,\_nextarp\_      Block move from prog mem to data mem
BLKP \_pma\_,\_ind\_
BLKP \_pma\_,\_dma\_

BLZ  \_pma\_,\_ind\_,\_nextarp\_      Branch if ACC < zero
BLZ  \_pma\_,\_ind\_
BLZ  \_pma\_

BNC  \_pma\_,\_ind\_,\_nextarp\_      Branch on no carry
BNC  \_pma\_,\_ind\_
BNC  \_pma\_

BNV  \_pma\_,\_ind\_,\_nextarp\_      Branch if no overflow
BNV  \_pma\_,\_ind\_
BNV  \_pma\_

BNZ  \_pma\_,\_ind\_,\_nextarp\_      Branch if ACC 

 zero
BNZ  \_pma\_,\_ind\_
BNZ  \_pma\_

BV   \_pma\_,\_ind\_,\_nextarp\_      Branch on overflow
BV   \_pma\_,\_ind\_
BV   \_pma\_

BZ   \_pma\_,\_ind\_,\_nextarp\_      Branch if ACC = zero
BZ   \_pma\_,\_ind\_
BZ   \_pma\_

CALA                            Call subroutine indirect

CALL \_pma\_,\_ind\_,\_nextarp\_      Call subroutine
CALL \_pma\_,\_ind\_
CALL \_pma\_

CMPL                            Complement ACC
CMPR \_const2\_                   Compare Aux reg with Aux AR0
CNFD                            Configure block as data memory
CNFP                            Configure block as program memory
CONF \_const2\_                   Configure block as data/prog memory
DINT                            Disable interrupt

DMOV \_ind\_,\_nextarp\_            Data move in data memory
DMOV \_ind\_
DMOV \_dma\_

EINT                            Enable interrupt

FORT \_const1\_                   Format serial port registers

IDLE                            Idle until interrupt

IN   \_ind\_,\_port\_,\_nextarp\_     Input data from port
IN   \_ind\_,\_port\_
IN   \_dma\_,\_port\_

LAC  \_ind\_,\_shift\_,\_nextarp\_    Load ACC with shift
LAC  \_ind\_,\_shift\_
LAC  \_ind\_
LAC  \_dma\_,\_shift\_
LAC  \_dma\_

LACK \_const8\_                   Load ACC immediate short

LACT \_ind\_,\_nextarp\_            Load ACC with shift specified by T reg
LACT \_ind\_
LACT \_dma\_

LALK \_const16\_,\_shift\_          Load ACC long immediate with shift
LALK \_const16\_

LAR  \_ar\_,\_ind\_,\_nextarp\_       Load auxilary register
LAR  \_ar\_,\_ind\_
LAR  \_ar\_,\_dma\_

LARK \_ar\_,\_const8\_              Load auxilary register immediate short

LARP \_arp\_                      Load auxilary register pointer

LDP  \_ind\_,\_nextarp\_            Load data memory page pointer
LDP  \_ind\_
LDP  \_dma\_

LDPK \_const8\_                   Load data memory page pointer immediate

LPH  \_ind\_,\_nextarp\_            Load high P register
LPH  \_ind\_
LPH  \_dma\_

LRLK \_ar\_,\_const16\_             Load auxilary register long immediate

LST  \_ind\_,\_nextarp\_            Load status register ST0
LST  \_ind\_
LST  \_dma\_

LST1 \_ind\_,\_nextarp\_            Load status register ST1
LST1 \_ind\_
LST1 \_dma\_

LT   \_ind\_,\_nextarp\_            Load T register
LT   \_ind\_
LT   \_dma\_

LTA  \_ind\_,\_nextarp\_            Load T reg and accumulate prev product
LTA  \_ind\_
LTA  \_dma\_

LTD  \_ind\_,\_nextarp\_            Load T reg, accum prev product & move
LTD  \_ind\_
LTD  \_dma\_

LTP  \_ind\_,\_nextarp\_            Load T reg and store P in ACC
LTP  \_ind\_
LTP  \_dma\_

LTS  \_ind\_,\_nextarp\_            Load T reg, subract previous product
LTS  \_ind\_
LTS  \_dma\_

MAC  \_pma\_,\_ind\_,\_nextarp\_      Multiply and accumulate
MAC  \_pma\_,\_ind\_
MAC  \_pma\_,\_dma\_

MACD \_pma\_,\_ind\_,\_nextarp\_      Multiply and accumulate with data move
MACD \_pma\_,\_ind\_
MACD \_pma\_,\_dma\_

MAR  \_ind\_,\_nextarp\_            Modify auxiliary register
MAR  \_ind\_
MAR  \_dma\_

MPY  \_ind\_,\_nextarp\_            Multiply
MPY  \_ind\_
MPY  \_dma\_

MPYA \_ind\_,\_nextarp\_            Multiply and accum previous product
MPYA \_ind\_
MPYA \_dma\_

MPYK \_const13\_                  Multiply immediate

MPYS \_ind\_,\_nextarp\_            Multiply and subtract previous product
MPYS \_ind\_
MPYS \_dma\_

MPYU \_ind\_,\_nextarp\_            Multiply unsigned
MPYU \_ind\_
MPYU \_dma\_

NEG                             Negate ACC

NOP                             No operation

NORM \_ind\_                      Normalize contents of ACC
NORM

OR   \_ind\_,\_nextarp\_            Or with ACC
OR   \_ind\_
OR   \_dma\_

ORK  \_dma\_,\_shift\_              Or immediate with ACC with shift
ORK  \_dma\_

OUT  \_ind\_,\_shift\_,\_nextarp\_    Output data to port
OUT  \_ind\_,\_shift\_
OUT  \_dma\_,\_shift\_

PAC                             Load ACC with P register

POP                             Pop top of stack to low ACC

POPD \_ind\_,\_nextarp\_            Pop top of stack to data memory
POPD \_ind\_
POPD \_dma\_

PSHD \_ind\_,\_nextarp\_            Push data memory value onto stack
PSHD \_ind\_
PSHD \_dma\_

PUSH                            Push low ACC onto stack
RC                              Reset carry bit
RET                             Return from subroutine
RFSM                            Reset serial port frame syn mode
RHM                             Reset hold mode
ROL                             Rotate ACC left
ROR                             Rotate ACC right
ROVM                            Reset overflow mode

RPT  \_ind\_,\_nextarp\_            Repeat instructions as per data mem
RPT  \_ind\_
RPT  \_dma\_

RPTK \_const8\_                   Repeat instructions as per immediate

RSXM                            Reset sign extension mode
RTC                             Reset test control flag
RTXM                            Reset serial port transmit mode
RXF                             Reset external flag

SACH \_ind\_,\_shift\_,\_nextarp\_    Store high ACC with shift
SACH \_ind\_,\_shift\_
SACH \_ind\_
SACH \_dma\_,\_shift\_
SACH \_dma\_

SACL \_ind\_,\_shift\_,\_nextarp\_    Store low ACC with shift
SACL \_ind\_,\_shift\_
SACL \_ind\_
SACL \_dma\_,\_shift\_
SACL \_dma\_

SAR  \_ar\_,\_ind\_,\_nextarp\_       Store AUX register
SAR  \_ar\_,\_ind\_
SAR  \_ar\_,\_dma\_

SBLK \_const16\_,\_shift\_          Subtract from ACC long immediate with shift
SBLK \_const16\_

SBRK \_const8\_                   Subtract from AUX register short immediate

SC                              Set carry bit
SFL                             Shift ACC left
SFR                             Shift ACC right
SFSM                            Set serial port frame sync mode
SHM                             Set hold mode
SOVM                            Set overflow mode
SPAC                            Subtract P register from ACC

SPH  \_ind\_,\_nextarp\_            Store high P register
SPH  \_ind\_
SPH  \_dma\_

SPL  \_ind\_,\_nextarp\_            Store low P register
SPL  \_ind\_
SPL  \_dma\_

SPM  \_dma\_                      Set P register output shift mode

SQRA \_ind\_,\_nextarp\_            Square and accumulate previous product
SQRA \_ind\_
SQRA \_dma\_

SQRS \_ind\_,\_nextarp\_            Square and subtract previous product
SQRS \_ind\_
SQRS \_dma\_

SST  \_ind\_,\_nextarp\_            Store status register ST0
SST  \_ind\_
SST  \_dma\_

SST1 \_ind\_,\_nextarp\_            Store status register ST1
SST1 \_ind\_
SST1 \_dma\_

SSXM                            Set sign extension mode
STC                             Set test/control flag
STXM                            Set serial port transmit mode


SUB  \_ind\_,\_shift\_,\_nextarp\_    Subtract from ACC with shift
SUB  \_ind\_,\_shift\_
SUB  \_ind\_
SUB  \_dma\_,\_shift\_
SUB  \_dma\_

SUBB \_ind\_,\_nextarp\_            Subtract from ACC with borrow
SUBB \_ind\_
SUBB \_dma\_
SUBC \_ind\_,\_nextarp\_            Subtract conditional
SUBC \_ind\_
SUBC \_dma\_

SUBH \_ind\_,\_nextarp\_            Subtract from high ACC
SUBH \_ind\_
SUBH \_dma\_

SUBK \_const8\_                   Subtract from ACC short immediate

SUBS \_ind\_,\_nextarp\_            Subtract from low ACC without sign-extension
SUBS \_ind\_
SUBS \_dma\_

SUBT \_ind\_,\_nextarp\_            Subtract from ACC with shift as per T reg
SUBT \_ind\_
SUBT \_dma\_

SXF                             Set external flag

TBLR \_ind\_,\_nextarp\_            Table read
TBLR \_ind\_
TBLR \_dma\_

TBLW \_ind\_,\_nextarp\_            Table write
TBLW \_ind\_
TBLW \_dma\_

TRAP                            Software interrupt

XOR  \_ind\_,\_nextarp\_            Exclusive OR with ACC
XOR  \_ind\_
XOR  \_dma\_

XORK\_dma\_,\_shift\_               Exclusive OR immediate ACC with shift
XORK \_dma\_

ZAC                             Zero ACC

ZALH \_ind\_,\_nextarp\_            Zero low ACC and load high ACC
ZALH \_ind\_
ZALH \_dma\_

ZALR \_ind\_,\_nextarp\_            Zero low ACC, load high ACC with rounding
ZALR \_ind\_
ZALR \_dma\_

ZALS \_ind\_,\_nextarp\_            Zero ACC, load low ACC without sign-extension
ZALS \_ind\_
ZALS \_dma\_

- - -

# TMS7000 INSTRUCTIONS AND ADDRESSING MODES

The following list shows the acceptable opcode mnemonics and their corresponding operand formats for the TMS7000 version of TASM. The following symbolic fields used in the table:

SYMBOLIC        DESCRIPTION
-------------------------------------------
\_iop\_           Immediate data (8 bits)
\_Rn\_            Register file (memory locations 0 to 127 or
                   0 to 255 depending on on-chip RAM)
\_Pn\_            Peripheral file (0-255)
\_rel\_           Program address (relative)
\_addr\_          Program address (16 bit)
\_trap\_          Trap number (0-23)

Any valid TASM expression can appear in the place of any of the above symbolics.

Note that TASM allows an alternate syntax for expressing indirection. Parenthesis can be replaced with brackets (which are less ambiguous because they do not occur in expressions). Thus, the following are equivalent:

    BR      @addr1(B)
    BR      @addr1\[B\]

OPCODE  OPERANDS
---------------------------------------
ADC    B,A
ADC    %\_iop\_,A
ADC    %\_iop\_,B
ADC    %\_iop\_,\_Rn\_
ADC    \_Rn\_,A
ADC    \_Rn\_,B
ADC    \_Rn\_,\_Rn\_

ADD    B,A
ADD    %\_iop\_,A
ADD    %\_iop\_,B
ADD    %\_iop\_,\_Rn\_
ADD    \_Rn\_,A
ADD    \_Rn\_,B
ADD    \_Rn\_,\_Rn\_

AND    B,A
AND    %\_iop\_,A
AND    %\_iop\_,B
AND    %\_iop\_,\_Rn\_
AND    \_Rn\_,A
AND    \_Rn\_,B
AND    \_Rn\_,\_Rn\_

ANDP   A,\_Pn\_
ANDP   B,\_Pn\_
ANDP   %\_iop\_,\_Pn\_

BTJO   B,A,\_rel\_
BTJO   %\_iop\_,A,\_rel\_
BTJO   %\_iop\_,B,\_rel\_
BTJO   %\_iop\_,\_Rn\_,\_rel\_
BTJO   \_Rn\_,A,\_rel\_
BTJO   \_Rn\_,B,\_rel\_
BTJO   \_Rn\_,\_Rn\_,\_rel\_

BTJOP  A,\_Pn\_,\_rel\_
BTJOP  B,\_Pn\_,\_rel\_
BTJOP  %\_iop\_,\_Pn\_,\_rel\_

BTJZ   B,A,\_rel\_
BTJZ   %\_iop\_,A,\_rel\_
BTJZ   %\_iop\_,B,\_rel\_
BTJZ   %\_iop\_,\_Rn\_,\_rel\_
BTJZ   \_Rn\_,A,\_rel\_
BTJZ   \_Rn\_,B,\_rel\_
BTJZ   \_Rn\_,\_Rn\_,\_rel\_

BTJZP  A,\_Pn\_,\_rel\_
BTJZP  B,\_Pn\_,\_rel\_
BTJZP  %\_iop\_,\_Pn\_,\_rel\_

BR      @\_addr\_(B)
BR      @\_addr\_\[B\]
BR      @\_addr\_
BR      \*\_Rn\_

CALL    @\_addr\_(B)
CALL    @\_addr\_\[B\]
CALL    @\_addr\_
CALL    \*\_Rn\_

CLR     A
CLR     B
CLR     \_Rn\_
CLRC

CMP     B,A
CMP     %\_iop\_,A
CMP     %\_iop\_,B
CMP     %\_iop\_,\_Rn\_
CMP     \_Rn\_,A
CMP     \_Rn\_,B
CMP     \_Rn\_,\_Rn\_

CMPA    @\_addr\_(B)
CMPA    @\_addr\_\[B\]
CMPA    @\_addr\_
CMPA    \*\_Rn\_

DAC     B,A
DAC     %\_iop\_,A
DAC     %\_iop\_,B
DAC     %\_iop\_,\_Rn\_
DAC     \_Rn\_,A
DAC     \_Rn\_,B
DAC     \_Rn\_,\_Rn\_

DEC     A
DEC     B
DEC     \_Rn\_

DECD    A
DECD    B
DECD    \_Rn\_

DINT

DJNZ    A,\_rel\_
DJNZ    B,\_rel\_
DJNZ    \_Rn\_,\_rel\_

DSB     B,A
DSB     %\_iop\_,A
DSB     %\_iop\_,B
DSB     %\_iop\_,\_Rn\_
DSB     \_Rn\_,A
DSB     \_Rn\_,B
DSB     \_Rn\_,\_Rn\_

EINT
IDLE

INC     A
INC     B
INC     \_Rn\_

INV     A
INV     B
INV     \_Rn\_

JMP     \_rel\_

JC      \_rel\_
JEQ     \_rel\_
JGE     \_rel\_
JGT     \_rel\_
JHS     \_rel\_
JL      \_rel\_
JN      \_rel\_
JNC     \_rel\_
JNE     \_rel\_
JNZ     \_rel\_
JP      \_rel\_
JPZ     \_rel\_
JZ      \_rel\_

LDA     @\_addr\_(B)
LDA     @\_addr\_\[B\]
LDA     @\_addr\_
LDA     \*\_Rn\_

LDSP

MOV     A,B
MOV     B,A
MOV     A,\_Rn\_
MOV     B,\_Rn\_
MOV     %\_iop\_,A
MOV     %\_iop\_,B
MOV     %\_iop\_,\_Rn\_
MOV     \_Rn\_,A
MOV     \_Rn\_,B
MOV     \_Rn\_,\_Rn\_

MOVD    %\_iop\_\[B\],\_Rn\_
MOVD    %\_iop\_,\_Rn\_
MOVD    \_Rn\_,\_Rn\_

MOVP    A,\_Pn\_
MOVP    B,\_Pn\_
MOVP    %\_iop\_,\_Pn\_
MOVP    \_Pn\_,A
MOVP    \_Pn\_,B

MPY     B,A
MPY     %\_iop\_,A
MPY     %\_iop\_,B
MPY     %\_iop\_,\_Rn\_
MPY     \_Rn\_,A
MPY     \_Rn\_,B
MPY     \_Rn\_,\_Rn\_

NOP

OR      B,A
OR      %\_iop\_,A
OR      %\_iop\_,B
OR      %\_iop\_,\_Rn\_
OR      \_Rn\_,A
OR      \_Rn\_,B
OR      \_Rn\_,\_Rn\_

ORP     A,\_Pn\_
ORP     B,\_Pn\_
ORP     %\_iop\_,\_Pn\_

POP     A
POP     B
POP     ST
POP     \_Rn\_
POPST

PUSH    A
PUSH    B
PUSH    ST
PUSH    \_Rn\_
PUSHST

RETI

RETS

RL      A
RL      B
RL      \_Rn\_

RLC     A
RLC     B
RLC     \_Rn\_

RR      A
RR      B
RR      \_Rn\_

RRC     A
RRC     B
RRC     \_Rn\_

SBB     B,A
SBB     %\_iop\_,A
SBB     %\_iop\_,B
SBB     %\_iop\_,\_Rn\_
SBB     \_Rn\_,A
SBB     \_Rn\_,B
SBB     \_Rn\_,\_Rn\_

SETC

STA     @\_addr\_(B)
STA     @\_addr\_\[B\]
STA     @\_addr\_
STA     \*\_Rn\_

STSP

SUB     B,A
SUB     %\_iop\_,A
SUB     %\_iop\_,B
SUB     %\_iop\_,\_Rn\_
SUB     \_Rn\_,A
SUB     \_Rn\_,B
SUB     \_Rn\_,\_Rn\_

SWAP    A
SWAP    B
SWAP    \_Rn\_

TRAP    \_trap\_

TST     A
TSTA
TST     B
TSTB

XCHB    A
XCHB    \_Rn\_

XOR     B,A
XOR     %\_iop\_,A
XOR     %\_iop\_,B
XOR     %\_iop\_,\_Rn\_
XOR     \_Rn\_,A
XOR     \_Rn\_,B
XOR     \_Rn\_,\_Rn\_

XORP    A,\_Pn\_
XORP    B,\_Pn\_
XORP    %\_iop\_,\_Pn\_

- - -