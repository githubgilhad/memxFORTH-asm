CPU Board GLUE Logic Specification
HD6309 + SysBus + MHF SharedRAM System
Verze návrhu

Tento dokument popisuje výslednou architekturu logiky implementované pomocí dvou CPLD typu ATF1504AS.

Logika zajišťuje:

dekódování adresového prostoru HD6309,
řízení systémové RAM,
mapování EMS oken,
správu vlastnictví SharedRAM mezi CPU a MHF,
řízení přístupu MHF k systémové RAM během HALT.
1. Architektura systému

Systém obsahuje:

CPU HD6309
systémovou RAM 128 kB
VIA
ACIA
dvě MHF desky

Označení:

MHF_A
MHF_B

Každá MHF obsahuje:

ATmega2560
SharedRAM 128 kB
video subsystem
PS/2
SD card
2. Rozdělení CPLD
ATF1

ATF1 je čistě kombinační logika.

Vstupy:

CA[0..15]
E
R/W
RESET
HALT

Výstupy:

MR[0..3]

DEV_1..DEV_7

ReadEnable
WriteEnable

ATF1 dekóduje adresový prostor CPU.

ATF2

ATF2 obsahuje:

EMS registry
ownership registry
DIRTY registry

a generuje:

GA[12..16]

Dev_0

Read
Write

A/B SHARE_GRANTED
A/B SHARE_DIRTY

A/B SharedRAM control
3. Paměťový prostor CPU
MR	Adresa	Obsah
0000	0000-7FFF	Native RAM
0001	8000-8FFF	EMS1
0010	9000-9FFF	EMS2
1000	A000	EMS1.Page
1001	A001	EMS1.Status
1010	A002	EMS2.Page
1011	A003	EMS2.Status
1100	A004	Chip_A.Status
1101	A005	Chip_B.Status
1111	A006-A01F	Reserved
0100	A020-A0FF	Devices
0011	A100-FFFF	ROM area

Poznámka:

oblast ROM je fyzicky RAM.

Zápis je povolen pouze během HALT režimu.

4. Device dekódování

Oblast:

A020-A0FF

obsahuje osm 32B slotů.

Device	Význam
Dev_0	System RAM (EMS)
Dev_1	Onboard VIA
Dev_2	Onboard ACIA
Dev_3	SysBus device
Dev_4	SysBus device
Dev_5	SysBus device
Dev_6	SysBus device
Dev_7	rezerva
5. EMS okna

Existují dvě nezávislá EMS okna:

EMS1 = 8000-8FFF
EMS2 = 9000-9FFF

Velikost:

4 kB

Každé okno může mapovat:

SystemRAM
MHF_A SharedRAM
MHF_B SharedRAM
6. EMS Page Registry
EMS1

Adresa:

A000
EMS2

Adresa:

A002

Formát:

AAxBBBBB
AA

Zdroj:

00 = SystemRAM
01 = MHF_A
10 = MHF_B
11 = undefined
BBBBB

Číslo 4k stránky.

Výsledná adresa:

BBBBB xxxx xxxx xxxx

Dolních 12 bitů adresy přichází přímo z CPU.

7. EMS Status Registry
EMS1
A001
EMS2
A003

Formát:

xxxxxxWC
C

Mapování je použitelné.

SystemRAM -> vždy 1

MHF_A -> A_CPU_OWN

MHF_B -> B_CPU_OWN
W

Protistrana žádá o převzetí SharedRAM.

MHF_A -> A_SHARE_REQUEST

MHF_B -> B_SHARE_REQUEST
8. Chip Status Registry
A004

Chip_A

A005

Chip_B

Formát:

xxxxDWAC
C

CPU vlastní SharedRAM.

A

MHF vlastní SharedRAM.

W

MHF požaduje SharedRAM.

Odpovídá:

SHARE_REQUEST
D

DIRTY flag.

Znamená, že MHF od posledního převzetí CPU mělo možnost SharedRAM použít.

9. Ownership model

Každý SharedRAM chip má stav:

00 NONE
01 CPU
10 MHF
11 RESERVED
CPU žádá o vlastnictví

CPU žádá o SharedRAM tím, že některé EMS okno nastaví na:

AA = 01

nebo

AA = 10
MHF žádá o vlastnictví

MHF nastaví:

SHARE_REQUEST = 1
Priorita

Pokud současně žádají CPU i MHF:

CPU vítězí.
Uvolnění CPU

CPU SharedRAM automaticky uvolní, pokud již žádné EMS okno neodkazuje na daný chip.

Uvolnění MHF

MHF uvolní SharedRAM:

SHARE_REQUEST = 0
10. SHARE_GRANTED

Výstup generovaný ATF2.

SHARE_GRANTED = 1

znamená:

SharedRAM vlastní MHF.
11. DIRTY

DIRTY je interní stav ATF2.

Nastavení

DIRTY se nastaví při přechodu:

NONE -> MHF

nebo

CPU -> MHF
Vymazání

DIRTY se maže při přechodu:

NONE -> CPU

nebo

MHF -> CPU

Význam:

DIRTY=1

MHF již mělo možnost zpracovat obsah SharedRAM.

12. SHARE_DIRTY

Výstup směrem k MHF.

Pokud SharedRAM nevlastní MHF:

SHARE_DIRTY = DIRTY

Pokud SharedRAM vlastní MHF:

SHARE_DIRTY = CPU_WANTS

Význam:

mimo vlastnictví informuje o nových datech,
během vlastnictví informuje MHF, že CPU chce SharedRAM zpět.
13. Generování GA[12..16]
Native RAM
GA[12..16] = CPU address
ROM
GA[12..16] = CPU address
EMS1
GA[12..16] = EMS1.BBBBB
EMS2
GA[12..16] = EMS2.BBBBB
HALT režim

ATF2 GA linky neřídí.

GA[12..16] = Hi-Z

Řídí je MHF.

14. Normální běh CPU
HALT = inactive

ATF2 řídí:

Read
Write
GA
EMS mapping

MHF má odpojené brány.

G_ENABLE = inactive
15. HALT režim

HALT vyžaduje MHF_A.

Po zastavení CPU:

BA = 1

CPU sběrnice přechází do Hi-Z.

ATF2 povolí přístup MHF k systémové RAM.

MHF může:

číst systémovou RAM,
zapisovat systémovou RAM,
zapisovat ROM oblast.

ATF2 generuje:

READ
WRITE

podle:

A_READ

a synchronizuje je na E.

16. Reset

Po resetu:

EMS registry:

EMS1 = SystemRAM page 08000
EMS2 = SystemRAM page 09000

pokud se podaří implementovat bez dodatečných makrocell.

Jinak:

0

Ownership:

A = NONE
B = NONE

DIRTY:

0

CPU po resetu nevlastní žádnou SharedRAM.

Tohle už je podle mě dostatečně kompaktní a konzistentní specifikace, podle které lze psát CPLD kód bez neustálého vracení se do původních poznámek. Největší otevřená otázka, kterou bych si do dokumentu ještě doplnil, je přesná definice všech signálů MHF_A/MHF_B (směr, aktivní úroveň, stav při resetu) v jedné samostatné kapitole, protože ty budou přímo určovat polovinu rovnic v ATF2.
