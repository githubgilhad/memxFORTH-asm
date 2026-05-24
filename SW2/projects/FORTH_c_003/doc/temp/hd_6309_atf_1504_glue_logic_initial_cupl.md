# HD6309 SysBus GLUE – první návrh CUPL pro ATF1504AS



D:2026.05.23 03:08 

Toto je první pracovní návrh logiky pro:

- ATF1 = adresový dekodér + region decode
- ATF2 = EMS + MHF arbitration + RAM steering

Není to finální produkční verze.

Cíle první verze:

1. Boot pseudo-ROM z MHF_A
2. Native RAM funguje
3. VIA + ACIA decode funguje
4. CPU běží po release HALT
5. EMS zatím disabled

Neřeší:

- wait states
- DMA
- EMS paging
- dual ownership edge cases
- timing optimization
- product term optimization

--------------------------------------------------------------------------------
# ATF1 – address decoder
--------------------------------------------------------------------------------

## Předpoklady

Memory map:

0000-7FFF = native RAM
8000-8FFF = EMS1
9000-9FFF = EMS2
A000-A003 = GLUE regs
A004-A0FF = devices
A100-FFFF = ROM/RAM

Device map:

Dev0 = RAM
Dev1 = VIA
Dev2 = ACIA
Dev3..5 = SysBus
Dev6..7 = reserved

--------------------------------------------------------------------------------
## atf1.pld

```cupl
Name     ATF1;
PartNo   00;
Date     2026-05-23;
Revision 01;
Designer GPT;
Company  Retro6309;
Assembly None;
Location None;
Device   g22v10;

/*
NOTE:
Pin numbers are placeholders.
Adjust for real ATF1504 pinout.
*/

PIN 1   = CA0;
PIN 2   = CA1;
PIN 3   = CA2;
PIN 4   = CA3;
PIN 5   = CA4;
PIN 6   = CA5;
PIN 7   = CA6;
PIN 8   = CA7;
PIN 9   = CA8;
PIN 10  = CA9;
PIN 11  = CA10;
PIN 13  = CA11;
PIN 14  = CA12;
PIN 15  = CA13;
PIN 16  = CA14;
PIN 17  = CA15;

PIN 18  = E;
PIN 19  = RW;
PIN 20  = RESET;
PIN 21  = HALT;

PIN 23  = READ_N;
PIN 24  = WRITE_N;

PIN 25  = DEV0_N;
PIN 26  = DEV1_N;
PIN 27  = DEV2_N;
PIN 28  = DEV3_N;
PIN 29  = DEV4_N;
PIN 30  = DEV5_N;
PIN 31  = DEV6_N;
PIN 32  = DEV7_N;

PIN 33  = MR0;
PIN 34  = MR1;
PIN 35  = MR2;
PIN 36  = MR3;

FIELD ADDR = [CA15..CA0];

/*
Memory regions
*/

EMS1      = !CA15 &  CA14 &  CA13 & !CA12;
EMS2      = !CA15 &  CA14 &  CA13 &  CA12;

GLUE_REG  =  CA15 & !CA14 &  CA13 & !CA12
           & !CA11 & !CA10 & !CA9 & !CA8
           & !CA7  & !CA6  & !CA5 & !CA4
           & !CA3  & !CA2;

DEV_AREA  =  CA15 & !CA14 &  CA13 & !CA12
           & !CA11 & !CA10 & !CA9 & !CA8
           & !( !CA7 & !CA6 & !CA5 & !CA4
               & !CA3 & !CA2 );

/*
Memory region outputs
*/

MR0 = EMS1;
MR1 = EMS2;
MR2 = GLUE_REG;
MR3 = DEV_AREA;

/*
Read / Write strobes
*/

READ_N  = !(E & RW);
WRITE_N = !(E & !RW);

/*
Default inactive
*/

DEV0_N = 'b'1;
DEV1_N = 'b'1;
DEV2_N = 'b'1;
DEV3_N = 'b'1;
DEV4_N = 'b'1;
DEV5_N = 'b'1;
DEV6_N = 'b'1;
DEV7_N = 'b'1;

/*
Device decode only inside DEV_AREA
*/

IF DEV_AREA THEN {

    /*
    A004-A00F = VIA
    */

    IF !CA7 & !CA6 & !CA5 & !CA4 THEN
        DEV1_N = 'b'0;

    /*
    A010-A01F = ACIA
    */

    IF !CA7 & !CA6 & !CA5 & CA4 THEN
        DEV2_N = 'b'0;

    /*
    A020-A02F = SYSBUS DEV3
    */

    IF !CA7 & !CA6 & CA5 & !CA4 THEN
        DEV3_N = 'b'0;

    /*
    A030-A03F = SYSBUS DEV4
    */

    IF !CA7 & !CA6 & CA5 & CA4 THEN
        DEV4_N = 'b'0;

    /*
    A040-A04F = SYSBUS DEV5
    */

    IF !CA7 & CA6 & !CA5 & !CA4 THEN
        DEV5_N = 'b'0;
}

/*
RAM always enabled outside DEV_AREA.
ATF2 may override later.
*/

IF !DEV_AREA THEN
    DEV0_N = 'b'0;

```

--------------------------------------------------------------------------------
# ATF2 – MHF arbitration + RAM steering
--------------------------------------------------------------------------------

## Funkce

ATF2 řeší:

- HALT ownership
- MHF_A takeover
- gate enable
- gate direction
- GA16
- shared RAM steering

EMS zatím disabled.

--------------------------------------------------------------------------------
## atf2.pld

```cupl
Name     ATF2;
PartNo   00;
Date     2026-05-23;
Revision 01;
Designer GPT;
Company  Retro6309;
Assembly None;
Location None;
Device   g22v10;

/*
Placeholder pinout.
Adjust later.
*/

PIN 1  = BA;
PIN 2  = E;
PIN 3  = RW;
PIN 4  = RESET;
PIN 5  = HALT_CPU_N;

PIN 6  = A_HALT_N;
PIN 7  = A_READ;
PIN 8  = A_SHARED_SELECT_N;
PIN 9  = A_S16;

PIN 10 = MR0;
PIN 11 = MR1;
PIN 13 = MR2;
PIN 14 = MR3;

PIN 15 = CA12;
PIN 16 = CA13;
PIN 17 = CA14;
PIN 18 = CA15;

PIN 19 = G_ENABLE_N;
PIN 20 = G_A_DIR;
PIN 21 = G_D_DIR;

PIN 23 = RAM_READ_N;
PIN 24 = RAM_WRITE_N;

PIN 25 = GA12;
PIN 26 = GA13;
PIN 27 = GA14;
PIN 28 = GA15;
PIN 29 = GA16;

/*
Ownership logic
*/

MHF_MASTER = !A_HALT_N & BA;

/*
Default gate state
*/

G_ENABLE_N = 'b'1;
G_A_DIR    = 'b'0;
G_D_DIR    = 'b'0;

/*
MHF owns bus
*/

IF MHF_MASTER THEN {

    G_ENABLE_N = 'b'0;

    /*
    Address direction:
    MHF -> CPU/RAM
    */

    G_A_DIR = 'b'1;

    /*
    Data direction:
    A_READ=1 => RAM -> MHF
    A_READ=0 => MHF -> RAM
    */

    G_D_DIR = !A_READ;
}

/*
RAM strobes
*/

IF MHF_MASTER THEN {

    RAM_READ_N  = !(E & A_READ);
    RAM_WRITE_N = !(E & !A_READ);

} ELSE {

    RAM_READ_N  = !(E & RW);
    RAM_WRITE_N = !(E & !RW);
}

/*
Upper RAM address bits.
Currently simple linear mapping.
*/

GA12 = CA12;
GA13 = CA13;
GA14 = CA14;
GA15 = CA15;

/*
GA16:
0 = lower 64K
1 = upper 64K

During bootstrap MHF controls it.
*/

IF MHF_MASTER THEN
    GA16 = A_S16;
ELSE
    GA16 = 'b'0;

```

--------------------------------------------------------------------------------
# Důležité poznámky
--------------------------------------------------------------------------------

## 1. Device type

V příkladu je použito:

```cupl
Device g22v10
```

protože syntax highlighting CUPL editorů bývá stabilnější.

Pro reálný build změň na konkrétní:

```cupl
Device f1504as;
```

nebo dle WinCUPL device databáze.

--------------------------------------------------------------------------------
## 2. Product terms

Tohle pravděpodobně NEPROJDE fittingem v aktuální podobě.

Je to funkční návrh logiky.

Bude potřeba:

- redukovat decode
- sdílet termy
- zjednodušit expressions
- možná registrovat některé výstupy

--------------------------------------------------------------------------------
## 3. BA signal

Doporučené.

Nepřipojuj MHF na bus pouze podle HALT.

Používej:

```text
MHF_MASTER = !A_HALT_N & BA
```

To je bezpečnější.

--------------------------------------------------------------------------------
## 4. EMS

EMS ještě není implementováno.

Další krok:

- registry v A000-A003
- EMS1 page register
- EMS2 page register
- source select
- RAM/shared select
- ownership logic

--------------------------------------------------------------------------------
## 5. Doporučený další krok

Nejdřív rozběhni:

- reset
- HALT
- pseudo-ROM upload
- CPU fetch z RAM
- jednoduchý monitor přes ACIA

Teprve pak:

- EMS
- shared RAM
- dual MHF
- arbitration edge cases

--------------------------------------------------------------------------------
# Doporučení pro debug
--------------------------------------------------------------------------------

Vyveď si na testpointy:

- BA
- HALT
- E
- RAM_READ_N
- RAM_WRITE_N
- G_ENABLE_N
- G_D_DIR
- G_A_DIR

Bez logického analyzátoru bude debug velmi těžký.

