
VGA Signal Generation on ATmega2560
Overview

This project implements a software VGA signal generator on ATmega2560 using cycle-exact timing.

The design goal is to maximize horizontal text resolution while maintaining stable VGA timing. The system operates close to the hardware limits of the MCU and relies on strict timing guarantees.

Unlike conventional firmware, the CPU is temporarily dedicated entirely to video generation during active display periods.
Key Properties

CPU frequency: 16 MHz

Horizontal timing: ~32 µs per scanline (~512 cycles)

Rendering speed: 8 CPU cycles per character (8 pixels)

Target resolution: ~320x480 pixels (~40x60 text characters)

Font stored in FLASH (via LPM)

VRAM stored in SRAM

System Architecture

The system is driven by two hardware timers:

Timer1

- Generates horizontal sync (HSYNC) using hardware output compare
- Drives scanline rendering via compare interrupt (CT1)

Timer3

Generates vertical sync (VSYNC)

Defines visible frame boundaries using compare interrupts:

Start of visible area

End of visible area

Rendering Model

The rendering is performed per scanline using a fully unrolled loop.

Each character is rendered in exactly 8 CPU cycles:

Load character index from VRAM

Fetch font byte from FLASH (LPM)

Output to shift register

Toggle latch

This ensures constant throughput and eliminates timing variability.
Critical Design Concept

During the visible portion of the frame, the CPU is intentionally locked into a controlled execution mode:

All general-purpose registers are preloaded

User program execution is suspended

Rendering is driven exclusively by interrupts

This guarantees deterministic timing.
Entering Rendering Mode

At the start of the visible frame (Timer3 compare interrupt):

All CPU registers are saved (including SREG and RAMPZ)

Rendering state is initialized:

VRAM pointers

Font pointers

Color registers

Interrupts for Timer1 compare (CT1) are enabled

Global interrupts are enabled (sei)

CPU enters an infinite loop::

loop:
rjmp loop

This loop serves as a stable idle state with minimal and predictable timing.
Why This Works

The loop contains no state

Interrupts can safely occur at any time

No registers need to be preserved between interrupts

Interrupt latency is bounded and predictable

The CPU effectively becomes a deterministic interrupt dispatcher.
Scanline Rendering (CT1)

Each scanline is rendered inside the Timer1 compare interrupt.

Key properties:

Interrupts are disabled during execution

No registers are saved/restored

All state is already prepared

The interrupt performs:

Optional timing alignment (jitter compensation)

Fully unrolled rendering loop (fixed number of characters)

Preparation of state for next scanline

Jitter Compensation

Interrupt entry latency depends on the currently executing instruction (0–2 cycles).

To ensure stable horizontal positioning, a small alignment macro is used::

cpi r20, threshold
brlo aligned

aligned:

This introduces a controlled 0–1 cycle delay.

Multiple such constructs can be combined to compensate up to 2 cycles of jitter.
Skipping Late Scanlines

At the beginning of CT1, the current timer value is checked.

If the interrupt is delayed beyond a safe threshold:

Rendering is skipped for that scanline

Output remains black (default state)

This prevents visible distortion from late rendering.
End of Visible Area

At the end of the visible frame (Timer3 compare interrupt):

Timer1 compare interrupt is disabled

The return address on the stack is modified to exit the infinite loop

This causes execution to continue after the rendering setup code.
Rationale for Stack Modification

The infinite loop has no exit condition by design.

To resume normal execution:

The return address of the interrupted context is adjusted

The loop is exited without adding runtime checks

This approach avoids:

Additional instructions in the hot path

Register pressure

Timing variability

The technique is safe because:

Stack layout is fully controlled

No nested interrupts modify the stack during this phase

Returning to User Program

After exiting rendering mode:

Frame-level state is updated

All registers are restored

Execution returns to the interrupted user program

The user program resumes as if uninterrupted, except for the elapsed time.
Interrupt Handling Strategy

During scanline rendering (CT1):

All interrupts are disabled

Other interrupts (e.g., keyboard input) are delayed but not lost

They execute after the current scanline completes

This is acceptable because:

External inputs are significantly slower than scanline timing

Latency remains within safe bounds

Determinism Guarantees

The system relies on strict determinism:

No data-dependent branches in rendering loop

Constant instruction paths per scanline

Fixed number of cycles per character

Identical timing for all scanlines (except first, if needed)

Once a configuration works, it will remain stable.
Performance Limits

Theoretical maximum:

512 cycles per scanline / 8 cycles per character = 64 characters

Practical limit:

Reduced by:

Blanking intervals

Interrupt overhead

State preparation

Observed stable target:

~40 characters per line

Any excess results in visible corruption, which can be used as a diagnostic signal.
Conclusion

This design transforms the ATmega2560 into a cycle-accurate video generator by:

Temporarily dedicating the CPU to rendering

Eliminating runtime variability

Leveraging hardware timers for synchronization

While unconventional, the approach is robust, deterministic, and operates within well-defined timing constraints.

It represents a trade-off:

Maximum rendering performance

At the cost of temporarily suspending general-purpose computation

















-------------------------------------------




Get responses tailored to you

Log in to get answers based on saved chats, plus create images and upload files.
Programuju generovani VGA signalu pro atmega2560. Prvni testy vypadaji dobre, behem 8 taktu procesoru dokazu vystavit data pro 8 pixelu (v rozvinute smycce) což přesně stačí, ale kvuli vypoctum indexu a dalším okolo se mi daří zobrazovat jen asi 34 znaků, než to začne přetýkat do dalšího řádku a rozhodí to obraz. Ta (rozvinutá) smyčka používá text z RAM a tvar znaků hledá ve FLASH, vypadá takto a asi nejde vylepšit:

.macro ONECHAR					//  Z: address of char data (MSB is fixed, LSB depends on char), X: current VRAM position (one line)
	ld    ZL, X+				// 2CP ZL = (X), X = X + 1
	lpm   r21, Z				// 3CP get font byte from program memory for current chr on current line
	out  PORTF, r21	// 1CP put data to shift register's parallel input
	
	out   PINB, r24	// 1CP flip B7 LOW - latch shift register
	out   PINB, r24	// 1CP flip B7 HIGH
 .endm						// 

Volaná je z TIMER1_OVF, který také nastavuje Z na správnou řádku pro danou subline (jeden znak je vysoký 8 subline) a stará se o přechod na další řádek. TIMER1 se také stará o generování Horizontálního Sync Pulsu na  pinu PB6.

TIMER3 se stará o Vertikální Sync Puls na pinu PE4. Taky se stará o nastavení nového frame (přechod na řádek 0 a nastavení ukazatelů) při TIMER3_OVF

Jediná důležitější věc je INT6 od klávesnice, který se nesmí ztratit a musí se vykonat během několika dalších subřádků. Když nastane, tak se nejspíš nějaký subřádek nestihne spustit včas a pak by se neměl vykreslit vůbec (v jednom framu bude vodorovná černá čára). Nastává jednou za hrozně dlouho, protože frame je 1/60 sec a člověk na klávesnici stihne něco stisknout tak 3x za sekundu.

Naopak cokoli jiného, co běží jako obyčejný uživatelský program je mnohem méně důležité a provádí se jen během "zpětného přechodu paprsku z poslední řádky zpět na první řádku" (která je asi 50 sublines po vertikálním pulsu).

Potřebuju vymyslet, jak získat co nejvíc času pro vykreslování znaků a jak zorganizovat přerušení a všechno okolo toho.

To, co popisuješ, je přesně ten moment, kdy z AVRčka ždímáš poslední cykly – a už nejde ani tak o optimalizaci jedné smyčky, ale o architekturu celého vykreslování a přerušení. Ta makro smyčka, co máš, je už prakticky na limitu (8 pixelů / 8 taktů = ideál), takže zisky musíš hledat jinde.

Pojďme systematicky:
🔧 1. Hlavní problém: režie okolo ONECHAR

To, že dáš jen ~34 znaků místo očekávaných ~40+, znamená, že tě zabíjí:

    výpočet adres (Z)

    řízení řádků / subřádků

    ISR overhead (push/pop, skoky)

👉 Smyčka samotná už není bottleneck.
🚀 2. Klíčová strategie: přesunout práci mimo ISR

ISR musí být extrémně krátké a deterministické.
❌ Co nedělat v TIMER1_OVF:

    počítání indexů

    násobení (char * 8)

    větvení

    logika řádků

✅ Co tam nechat:

    jen:

        načti pointer

        vystřel data

        hotovo

💡 3. Předpočítané adresy (NEJVĚTŠÍ BOOST)

Místo:

Z = font_base + char * 8 + subline

udělej:
👉 VRAM nebude obsahovat znak, ale pointer do fontu

Např.:

    místo 'A' uložíš rovnou adresu font_A + subline

Konkrétně:

    pro každý znak si předpočítáš 8 pointerů (pro 8 sublines)

    VRAM pak obsahuje:

[addr_char0_line0][addr_char1_line0]...
[addr_char0_line1][addr_char1_line1]...
...

Výsledek:

    v ISR:

ld ZL, X+
ld ZH, X+
lpm r21, Z

👉 žádné násobení, žádné přičítání
⚡ 4. Ještě lepší: zdvojení VRAM (line buffer)

Místo celé obrazovky:

    máš jen buffer pro jednu scanline

    během vykreslování další připravuješ

Výhody:

    nulové výpočty v ISR

    maximální rychlost

Nevýhoda:

    víc RAM

    složitější plánování

⏱ 5. Kritická věc: ISR latency

AVR při přerušení:

    push PC

    skok do ISR

    často push registrů

👉 To tě stojí klidně 20–30 cyklů
Řešení:

Použij:

ISR(TIMER1_OVF_vect, ISR_NAKED)

a udělej si vlastní prolog/epilog:

push r21
push r30
push r31
; ...

👉 ušetříš hodně cyklů
🧠 6. INT6 (klávesnice) – správná strategie

Tohle máš dobře navržené, jen to dotáhnout:
❗ Nikdy neobsluhuj klávesnici hned

Místo toho:

volatile uint8_t key_pending;

ISR INT6:

key_pending = 1;

A zpracování:

    v vertical blankingu

👉 přesně jak plánuješ
🧱 7. Přerušení: priority a kolize

Na AVR:

    není prioritní systém

    běží to, co přijde první

    ostatní čekají

👉 Kritické pravidlo:

Během vykreslování:

cli

a:

    povolit jen TIMER1 (nebo ho vůbec nevypínat)

INT6:

    buď:

        krátký flag (OK)

        nebo úplně zakázat během aktivní části řádku

🎯 8. Extrémní optimalizace: odstranění lpm

lpm je 3 cykly → drahé.
Varianta:

    font přesunout do RAM

👉 pak:

ld r21, Z   ; 2 cykly místo 3

Zisk:

    ~12–15 % výkonu navíc

🧩 9. Alternativa: SPI jako shift register

Pokud používáš shift register:

👉 zvaž:

    použít SPI hardware

out SPDR, r21

a mezitím počítat další znak
🧮 10. Reality check (proč to padá na 34 znaků)

Typicky:

    1 znak = ~8 cyklů (data)

        overhead = ~4–6 cyklů

→ ~12–14 cyklů / znak

Při 16 MHz:

    horizontální čas ~52 µs

    ~832 cyklů

832 / 14 ≈ 59 znaků max (teorie)

→ ty máš 34 → polovina padá na režii
🏁 Doporučené řešení (prakticky)
Minimum změn, max efekt:

    ✅ VRAM = pointery do fontu (ne znaky)

    ✅ ISR_NAKED

    ✅ žádné výpočty v ISR

    ✅ INT6 jen flag

    ✅ ideálně font do RAM

💬 Pokud chceš jít ještě dál

Můžeme spolu:

    rozpočítat cykly přesně na tvoji frekvenci

    navrhnout layout VRAM

    přepsat ISR na cycle-perfect

    nebo to celé překlopit na scanline renderer

Stačí poslat:

    frekvenci CPU

    kolik pixelů/znaků chceš horizontálně

    jaký máš shift register

Tady už jsi fakt na hraně možností AVR — ale pořád se z toho dá dostat víc 🙂

Zkritizuj svou odpověď, co zlepšit?

Dobrá otázka — tady je upřímná sebekritika, co bych na té odpovědi zlepšil a kde má slabiny:
🧨 1. Málo respektuju tvoje konkrétní omezení

Ty už máš:

    přesně načasovanou smyčku (8 cyklů = 8 pixelů)

    běžící VGA timing (to je samo o sobě dost hardcore)

    konkrétní ISR architekturu

👉 Já jsem ale navrhoval věci jako:

    kompletní změnu VRAM na pointery

    line buffer

    přesun fontu do RAM

To jsou:

    architektonické změny, ne optimalizace

⚠️ Problém:
Neřeší to nutně tvoji aktuální chybu (rozpad po ~34 znacích), ale spíš redesign.
🎯 2. Neidentifikoval jsem přesně bottleneck

Řekl jsem:

    „režie okolo“

ale:

❌ Nedal jsem:

    přesný cycle breakdown

    kolik cyklů žere ISR vstup/výstup

    kolik stojí ld, lpm, out

👉 Bez toho jen hádám.

Tohle je zásadní chyba — u VGA na AVR:

    každý cyklus musí být spočítaný, ne odhadnutý

⚠️ 3. Návrh s pointer VRAM je možná nepraktický

Tohle:

    VRAM obsahuje pointery místo znaků

má problémy:

    2 bajty místo 1 → poloviční kapacita RAM

    složitější zápis textu

    horší cache locality (na AVR to sice není cache, ale i tak)

👉 Měl jsem dodat:

    kdy se to vyplatí

    kdy je to overkill

🧱 4. Ignoroval jsem tvoji makro smyčku detailně

Tvoje makro:

ld    ZL, X+
lpm   r21, Z
out   PORTF, r21
out   PINB, r24
out   PINB, r24

👉 Já jsem ji jen okomentoval, ale:

❌ neřešil jsem:

    že ZH je fixní (to je důležité!)

    že ld ZL, X+ přepisuje jen low byte → chytré!

    že latch toggle stojí 2 cykly → možná bottleneck

Tohle je promarněná příležitost.
🔥 5. Úplně jsem minul klíčový symptom

Tvoje hlavní věta:

    „po ~34 znacích to přeteče do dalšího řádku a rozhodí obraz“

Tohle silně naznačuje:

👉 timing overflow scanline
ne:
👉 „nestíhám výpočty obecně“

Možné skutečné příčiny:

    ISR trvá moc dlouho → přetáhne do HSync

    Timer overflow přijde dřív než skončíš

    jitter kvůli jinému přerušení

👉 Já jsem to měl analyzovat jako časový problém jedné scanline, ne obecný výkon.
⏱ 6. ISR_NAKED jsem doporučil bez varování

Tohle:

ISR(..., ISR_NAKED)

je sice správný směr, ale:

⚠️ neřekl jsem:

    že si musíš ručně hlídat SREG

    že můžeš rozbít návrat

    že compiler ti nepomůže

👉 pro méně zkušeného je to past
🔌 7. SPI návrh byl slabý

Navrhl jsem SPI, ale:

    neřešil jsem timing VGA (ten je brutálně přesný)

    SPI by mohlo být:

        moc pomalé

        nebo naopak špatně zarovnané

👉 tohle bylo spíš „nápad“, ne řešení
📉 8. Chybí konkrétní „low-risk“ optimalizace

Měl jsem dát něco jako:
malé, bezpečné kroky:

    unroll na přesný počet znaků (žádný loop)

    fixní počet znaků → žádné podmínky

    zarovnání ISR na přesný počet cyklů

    padding pomocí nop

👉 místo toho jsem šel rovnou do velkých změn
🧠 9. Neptal jsem se na klíčové parametry

Chybí:

    CPU frekvence (16 MHz?)

    rozlišení (např. 640×480? 320×240?)

    kolik pixelů na znak

    kolik znaků chceš cílit

👉 bez toho optimalizuju naslepo
🏁 Jak by měla vypadat lepší odpověď

Měla by:

    Spočítat cykly přesně

    Identifikovat:

        kolik máš cyklů na scanline

        kolik bere ONECHAR

        kolik overhead

    Najít:

        „chybí ti X cyklů po 34 znacích“

    Navrhnout:

        konkrétní úsporu těch X cyklů

👍 Co bylo naopak správně

Aby to nebylo jen negativní:

✔ správně jsem trefil:

    že smyčka je už near-optimal

    že ISR musí být minimální

    že INT6 má být deferred

    že precompute je silná technika

💬 Shrnutí jednou větou

Moje odpověď byla:

    „dobrý seznam optimalizačních technik“

ale měla být:

    „přesná forenzní analýza, proč se to rozbije po 34 znacích“

👉 Jestli chceš, pojďme to udělat pořádně

Pošli mi:

    F_CPU

    kolik znaků chceš na řádek

    kolik cyklů má scanline (nebo timer nastavení)

A já ti to:

    rozepíšu na cyklus přesně

    najdu, kde to přetéká

    navrhnu fix, který ti dá třeba +5 až +10 znaků bez redesignu


Mám takový nápad, který by mohl umožnit výstup mnohem více znaků, za cenu hodně silného redesignu a částečného zneužití omezení atmegy2560:

* Nechat TIMER1 a TIMER3 generovat HW sync pulsy jako dosud (to funguje a nepotřebuje takty procesoru), jakmile jsou sync pulsy správně, je potřeba jen generovat pixely ve správném časovém okně.
* Použít dva COMPARE z TIMER3, jeden pro přípravu těsně před první viditelnou scanline, druhý pro ukončení po poslední viditelné scanline. To ušetří práci se zjišťováním kdy začít a kdy skončit.
* Začáteční COMPARE jako klasický ISR uloží všechny registry, včetně stavového a RAMPZ, pak načte všechna konfigurační data do registrů a otevře potřebné porty, POTOM povolí interrupty od TIMER1 COMPARE  a POTOM povolí interrupty globálně (sei) a přejde do nekonečné smyčky ( loop: rjmp loop; )
** od téhle chvíle, dokud neskončí, tak jiný ISR nemůže rozbít registry uživatelskému prostoru, protože jsou všechny uložené
** protože je povolené přerušení globálně (sei), tak všechny interrupty ho mohou přerušit kdykoli. A protože v té nekonečné smyčce nic nedělá, tak nemusí uchovávat nic (jen adresu přerušení kvůli návratu).
** Zejména interrupt od COMPARE pro TIMER1 (CT1) takto získá naplněné registry aktuálními daty a po skončení nemusí data ukládat, protože se vrátí do oné nekonečné smyčky, kde se nic nemění, takže při dalším vyvolání ta data bude mít stejná
** uživatelský prostor se k procesoru nedostane po celou dobu zobrazování (to je záměr) a nebude nic ovlivňovat.
** jitter v nekonečné smyčce je jen o jeden takt, protože ten rjmp trvá dva takty a ISR (CT1) čeká na dokončení instrukce = je potřeba zahladit jen 1 takt mcu.
** Zároveň protože COMPARE jde nastavit na libovolnou hodnotu, jde začátkem posunout tak, aby výstup znaků uvnitř CT1 začal právě ve chvíli, kdy je začátek viditelné scanline
** CT1 díky předvyplněným registrům může začít zobrazovat prakticky hned , až skončí scanline, tak připraví data pro další scanline.
** CT1 jako první věc zjistí hodnotu timeru a pokud bude vyšší, než dolní mez+jitter(=1), tak přeskočí zobrazování, neboť byl odsunut jiným přerušením a nemůže začít včas
*** hlavní rozdíl je tu, že
**** podmíněné příkazy a různé cesty neovlivní začátek, který bude přesně (až na ten 1T jitter od rjmp, který se dá zahladit snadno)
**** mezi jednotlivými scanline se nemusí ukládat a načítat žádné data a vše je v registrech
**** BLANK před a za scanline se využije pro přípravu dalšího řádku (pokud bude příprava trvat dlouho, )
**** místo násobení se budou jen přičítat meziřádkové rozdíly (spočtené při kompilaci)
* Na konci viditelné části nastane druhý COMPARE od TIMER3 a udělá
** zakáže interrupty pro CT1 (tím ho zastaví mimo videtelnou oblast)
** na zásobníku přepíše návratovou adresu na adresu o jedna vyšší (tím způsobí, že první COMPARE vyskočí z nekonečné smyčky)
* první COMPARE vyskočí z nekonečné smyčky, přepočte údaje pro začátek dalšího frame a uloží je, zavře příslušné porty, pak obnoví všechny registry a skončí
** to je za koncem viditelné části, kdy je vše vykresleno
** výpočet se vrátí do uživatelského prostoru (kde se nic nezměnilo, jen ten interrupt trval převelice dlouho)
** uživatelský prostor bude pokračovat v tom, co dělal - a po celou dobu zatmění pod a nad framem ho nebude nic rušit.

Jeden subline trvá 32 uS, teoreticky by se za tu dobu dalo vyslat až 64 znaků (=512 pixelů) - kdyby z jedné strany nebylo potřeba předpočítat nový řádek a z druhé strany monit povolil zobrazování i "před a za" viditelným scanlinem - v reálném světě je tu režie interruptu (asi 4+4 takty), a výpočtu dalšího řádku (posun ukazatele subliny fontu, na konci řádku taky posun ukazatele do VRAM a CRAM a výstup nových barev), takže se nejspíš většina BLANK oblasti využije.
s taktem 16MHz se budu pohybovat někde kolem poloviny 640x480 (což mi ukazuje realný monitor), takže moje (maximální) rozlišení bude 320x480, tedy asi tak 40x60 znaků. Na obrazovce teď (se starým systémem) vidím 56 řádků po 29 znacích, asi dva řádky by se ještě vešly a dvacet sloupců taky, takže to není zcela nereálný cíl

Tohle je hodně dobrý nápad — a hlavně: tentokrát už to není „optimalizace“, ale skutečný posun architektury směrem k cycle-exact rendereru, což je přesně to, co VGA na AVR chce.

Ale má to pár ostrých hran. Pojďme to rozebrat férově:
🧠 Co je na tom fakt silné
1. „Zamknutí CPU“ během aktivního obrazu

Tohle je klíčová myšlenka:

    CPU přestane existovat pro user-space a stane se čistě video generátorem

👉 To je správně. Přesně tak fungují:

    demoscéna na AVR

    ZX Spectrum (ULA vs CPU contention)

    různé bitbanging VGA projekty

✔ Výhoda:

    žádný jitter z běžného kódu

    deterministické chování

    registry jako „persistent state“

2. Nekonečná smyčka + sei

Tohle je hodně chytré:

loop: rjmp loop

👉 tím získáš:

    minimální jitter (1 instrukce)

    žádný stav, který bys musel chránit

A hlavně:

    ISR (TIMER1 COMPARE) běží vždy nad „čistým“ stavem

✔ To je přesně to, co jsi chtěl.
3. „Warm ISR“ (registry už připravené)

Tohle je největší win:

    ISR nemusí push/pop → protože se nemá kam vrátit (jen do loopu)

👉 efektivně:

    ISR = téměř „funkce bez prologu“

To je obrovské — ušetříš klidně 20+ cyklů na scanline
4. Hard start pomocí COMPARE

Tohle řeší tvůj původní problém:

    „začátek se rozhodí“

👉 tímhle:

    start je dán HW compare

    ne ovlivněn větvením

✔ správný směr
⚠️ Kritické problémy (tady to začne být zajímavé)
🧨 1. Přepis návratové adresy na stacku

Tohle:

    „přepíšu návratovou adresu“

👉 je funkční, ale:

⚠️ extrémně křehké

Problémy:

    závislé na přesném layoutu stacku

    rozbije se při:

        jiné optimalizaci compileru

        jiné ISR kombinaci

    špatně se debuguje (ghost bugy)

👉 Lepší varianta:

Použij flag:

volatile uint8_t render_active;

a v té smyčce:

loop:
    tst render_active
    brne loop
    ret

✔ bezpečnější než hackování stacku
⏱ 2. Jitter 1 takt není úplně pravda

Tvoje úvaha:

    „ISR čeká na dokončení instrukce → 1T jitter“

👉 skoro pravda, ALE:

    rjmp = 2 cykly

    interrupt se obslouží po dokončení instrukce

→ jitter = 0 až 1 instrukce, tj. 0–2 cykly

⚠️ To už je dost na VGA pixel clock

👉 řešení:

    zarovnat pomocí nop

    nebo použít dvoufázový start (viz níže)

🔥 3. „Když to nestihnu, tak přeskočím scanline“

Tohle:

    „když jsem pozdě, nevykreslím řádek“

👉 je dobré jako fail-safe, ale:

⚠️ vizuálně:

    budeš mít blikající čáry

    ne jen občas → může se kumulovat

👉 lepší:

    garantovat, že se to nikdy nestane

    nebo fallback:

        vykreslit černou deterministicky (ne skip)

🧱 4. Příprava dalšího řádku v blankingu

Tohle je správné, ale:

👉 riziko:

    blanking nemusí stačit na:

        posun pointerů

        změnu barvy

        logiku

⚠️ pokud to přeteče:
→ rozbiješ další scanline

👉 doporučení:

    rozdělit práci:

        část během vykreslování (interleaving)

        část v blankingu

🧮 5. Teoretických 64 znaků je optimistických

Počítáš:

    32 µs → 512 cyklů → 64 znaků

ALE:

Chybí:

    ISR latency (~4–8 cyklů)

    latch toggle (2 cykly / znak)

    load (LD + LPM = 5 cyklů)

    OUT (1 cyklus)

Reálně:

👉 ~10–12 cyklů / znak

→ 512 / 12 ≈ 42 znaků max

✔ což sedí na tvůj cíl (~40)
⚠️ 6. Povolení všech interruptů (sei)

Tohle je potenciální killer:

    „všechny interrupty ho mohou přerušit kdykoli“

👉 NE.

Pokud:

    INT6 přijde uprostřed scanline

→ rozbije timing

👉 správně:

    během aktivní oblasti:

    cli

    povolit jen:

        TIMER1 (video)

INT6:

    jen flag

    obsluha mimo aktivní oblast

💡 Co bych upravil (bez změny konceptu)
✅ 1. Dvoufázový start scanline

Místo:

    rovnou render

udělej:

    COMPARE → vstup do ISR

    krátký delay (zarovnání)

    render

in r0, TCNT1
sub r0, OFFSET
brcs ok
nop ; align
ok:

✅ 2. Odstranit stack hack

Místo toho:

    render_active = 1

    loop běží dokud:

    tst render_active
    brne loop

✅ 3. Zakázat ostatní IRQ během renderu

Klíčové:

    povolit jen TIMER1

    ostatní až ve vertical blank

✅ 4. Minimal ISR pro TIMER1

Ideálně:

ISR_NAKED:
    ; žádný push
    ; render
    reti

🏁 Verdikt

👉 Tvůj návrh je:

✔ architektonicky správný
✔ odpovídá tomu, jak se to dělá „na hraně železa“
✔ realisticky tě dostane z ~29 znaků → ~40+

ALE:

⚠️ musíš ošetřit:

    jitter (není jen 1 takt)

    zakázání ostatních IRQ

    stack hack (doporučuji odstranit)

💬 Jednou větou

Tohle už není „AVR program“, ale softwarová grafická karta běžící na AVR — a jsi velmi blízko tomu, aby to fungovalo stabilně.

Jestli chceš, můžeme příště:

    spočítat přesně cykly na scanline

    navrhnout konkrétní ISR (cycle-perfect)

    nebo doladit layout VRAM, aby ses dostal na těch ~40×60 znaků stabilně


* 1. píšu to v asembleru, takže mi compiler nic nezoptimalizuje. Naopak testování flagu ve smyčce znamená nutnost chránit příznaky + chránit render_active = spoustu instrukcí navíc.

* 2. To máš pravdu, jitter nebude 1-2, ale 0-2, takže vyhlazování bude potřebovat o jeden stupeň víc (= 2 instrukce navíc)

* 3. černou vykresluju automaticky kdykoli nevykresluju nic, protože je tam 74HC logika, která zná jen nuly a jedničky a mezi sublines nastavuju barvu popředí=barvě pozadí = 0, tedy černou. Pokud to nepřepnu a nezačnu kreslit, tak tam bude černá i při vynechaném výstupu.

* 4. během vykreslování mi nezbývají žádné takty  (nemůžu font dát do RAM, protože ji potřebuju i pro jiné účely), takže pokud blanking nevystačí (ale vystačit by měl), tak budu muset obětovat zobrazení několika znaků (zkrátit řádku). Naštěstí přecho na další řádek, nebo další subline je deterministicky vždy stejně dlouhý (pro řádek nebo pro subline), takže jakmile to projde jednou, projde to vždy.

* 5. protože používám rozbalenou smyčku, tak během ní nevznikají pauzy vlivem ISR latency, ta se odehraje na začátku řádky jednou a budu ji offsetovat tím vyhlazením jitteru (makro check, které se  projde o takt rychleji, pokud nedojde ke skoku
.macro check number	
	cpi r20, \number
	brlo 1f
1:
.endm
Takže je to opravdu 8 taktů na znak a potvrzuje to i osciloskop, i monitor
64 znaků je jen teorie, kvůli BLANK a synchronizačním pulzám je 40 zobrazitelné maximum dané monitorem. pro mě to znamená těch zbylých 24*8=192 taktů na režii a vše okolo

* 6. Pokud INT6 přijde uprostřed scanline, tak CT1 je interrupt, tedy zakázané všechny ostatní interrupty, tedy INT6 se zaznamená a provede se až CT1 skončí (teda ještě asi o instrukci později)
Což nevadí, protože další scancode (11 pulzů na asi 11kHz) přijde nejdřív až o několik scanlines později, takže času na přečtení je dost.

* Dvoufázový start scanline - ano, tohle podobně řeší to makro check
* stack hack mi přijde nejjednodušší a nejstabilnější, viz dříve
* render je formálně uvnitř interruptu CT1 (který interrupty nepovoluje), tedy jsou zakázány všechny interrupty

Tady už je vidět, že o tom přemýšlíš přesně „na úrovni hodinového signálu“, ne jen kódu 👍
A většinu mých předchozích výtek jsi dost dobře rozstřelil – takže spíš doladím jemné hrany, než abych ti to boural.
🧠 1. Flag vs. stack hack — tady máš pravdu

    testování flagu = spousta instrukcí navíc

✔ Souhlas. V assembleru je to jiná liga než v C.

Konkrétně:

    tst/brne + ochrana SREG = reálně 3–5 cyklů navíc v kritické smyčce

    navíc bys musel řešit, že flag mění jiný ISR → potenciální jitter

👉 V tvém modelu:

    „CPU je zamknuté a nic jiného neexistuje“

je stack hack:

✔ rychlejší
✔ determinističtější
✔ vlastně i čistší (v tomhle konkrétním případě)

💡 Verdikt:

    Tady je stack hack legitimní low-level technika, ne prasárna.

⏱ 2. Jitter a tvoje check makro

Tohle je hodně dobré:

cpi r20, number
brlo 1f
1:

👉 přesně tohle je:

    branch s rozdílnou délkou

    použité jako „cycle aligner“

✔ Výhoda:

    žádné NOPy natvrdo

    adaptivní zarovnání

⚠️ Jediná věc na pozor:

brlo:

    skok: 2 cykly

    neskok: 1 cyklus

→ rozdíl = 1 cyklus

👉 Ty ale potřebuješ vyhladit až 0–2 cykly jitter

Takže:

✔ buď:

    použít 2× check

nebo:

✔ kombinaci:

nop
check X

⚡ 3. Klíčové potvrzení: 8 taktů na znak

Tohle je zásadní:

    „ověřeno osciloskopem“

👉 tím pádem:

    žádný skrytý bottleneck ve smyčce

    limit je čistě:

        horizontální timing

            režie mimo smyčku

A to krásně sedí:

    40 znaků reálně vs 64 teoreticky

🧮 4. Tvých ~192 cyklů režie

Tohle je nejdůležitější číslo celé diskuze:

    24 znaků * 8 cyklů = 192 cyklů „navíc“

👉 to je přesně prostor, kde se rozhoduje všechno

A tvoje architektura:

✔ přesouvá režii:

    mimo aktivní část

    do blankingu

👉 což je přesně správně
🧱 5. Determinismus mezi řádky

    „jakmile to projde jednou, projde to vždy“

✔ Ano — a to je strašně důležité

To znamená:

    žádné datově závislé větvení

    konstantní path length

👉 tím pádem:

    můžeš optimalizovat „na krev“ bez safety marginu

🔥 6. INT6 — tady je to fakt dobře

Tvoje úvaha:

    CT1 běží → ostatní IRQ čekají

✔ přesně tak funguje AVR

A navíc:

    PS/2 timing je pomalý (~11 kHz)

    máš několik scanlines rezervu

👉 Verdikt:

    Bezpečné. Tady není co řešit.

⚠️ Jediné 2 věci, kde bych byl pořád opatrný
🧨 A) Stack hack — ale z jiného důvodu

Ne kvůli „prasárně“, ale:

👉 nested interrupts edge case

Scénář:

    jsi v „nekonečné smyčce“

    přijde CT1

    CT1 běží dlouho

    TIMER3 COMPARE zasáhne během CT1

→ přepisuje stack, který už obsahuje návrat z CT1

👉 tohle může:

    rozhodit návrat

    nebo skočit jinam

💡 Řešení:

    zajistit, že:

        TIMER3 COMPARE nemůže přijít během CT1

např.:

    časově (mimo scanline)

    nebo ho krátce zakázat

⏱ B) Start scanline vs. HW compare

Tohle je jemná, ale důležitá věc:

    ISR start není přesně v compare okamžiku

je tam:

    dokončení instrukce

    skok do ISR

👉 ty to řešíš check → OK

ALE:

💡 ještě přesnější varianta:

    compare nastav o pár cyklů dřív

    a zarovnávej „dopředu“

→ menší jitter než „dohánět zpoždění“
💡 Jeden nápad navíc (malý, ale silný)
👉 „Dual-purpose registry“

Když máš registry „persistent“ mezi scanlines:

zkus:

    držet:

        pointer do fontu

        pointer do VRAM

        subline offset

a místo:

add ZL, 1

použít:

adiw ZL, CONST

nebo:

    předpočítané inkrementy mezi sublines

👉 můžeš tím ušetřit pár cyklů v blankingu
🏁 Finální verdikt

👉 Tvůj návrh:

✔ je konzistentní
✔ je cycle-accurate
✔ eliminuje hlavní bottleneck (ISR overhead)
✔ realisticky ti dá těch ~40 znaků

A hlavně:

    už to není „hack“, ale regulérní scanline engine

💬 Jednou větou

Teď už nejsi limitovaný AVRkem — ale jen tím, kolik cyklů má jedna scanline. A to je přesně stav, kam ses chtěl dostat.

Jestli chceš jít ještě o level dál, můžeme:

    spočítat přesný timing pro 320px vs 400px šířku

    nebo navrhnout layout VRAM/CRAM tak, aby ses dostal na těch ~40×60 znaků bez kompromisů v barvách nebo rychlosti


A. Jak jsme si řekli, CT1 je interrupt, takže i CT3 musí počkat na jeho dokončení a pak už běží přímo nad "nekonečnou smyčkou" - dokonce to zamýčlím načasovat, aby právš k tomuto došlo, protože to bude víc deterministické i vzhledem k vlivu klávesnice (ale zase se interrupty prostě naskládají za sebe, protože jinak to v AVR nejde)

Ano, Dual-purpose registry mám přesně v úmyslu

Timing zařídím tak, že si zadám, kolik znaků má řádka (40), tolikrát se mi rozvine makro a ten zbytek do opakování COMPARE vyplyne sám jako zbytek. A pokud se tam vše vejde, tak na monitoru bude stabilní obraz (a zbytek se protočí v nekonečné smyčce), zatímco pokud se nevejde, tak se mi rozpadnou budˇvšechny řádky, nebo všechny první sublines (výpočet nového řádku je delší) a tím uvidím, že se to nevchází a o kolik asi :)

Tohle už je fakt „na krev“ návrh — a upřímně: dává to smysl a je vnitřně konzistentní. Už tam nevidím žádnou zásadní logickou chybu, spíš jen pár jemných míst, kde tě realita AVR může ještě kousnout.
🧠 1. Řetězení interruptů (CT1 → CT3)

Tohle jsi teď popsal správně a přesně:

    CT1 doběhne → pak se odbaví CT3 → a to už běží nad prázdnou smyčkou

✔ To je ideální stav:

    žádné rozbité registry

    žádný jitter z user-space

    deterministický stack

👉 Tohle je vlastně „ručně řízený interrupt scheduler“ — a funguje.
⚠️ Jediný edge case

Pozor na:

    CT3 přijde těsně před koncem CT1

Pak:

    CT3 začne o pár cyklů později

    ale tobě to nevadí, protože:

        jsi už mimo aktivní video

        timing není kritický

✔ takže OK
⏱ 2. Autokalibrace přes „rozpad obrazu“

Tohle je výborný přístup:

    „když se to nevejde, obraz se rozpadne → vidím o kolik“

👉 tohle je přesně:

    hardware-assisted profiling 😄

A má to výhodu:

    měříš reálný timing, ne teoretický

    zahrnuješ:

        ISR latency

        větvení

        skutečné instrukce

✔ Lepší než jakýkoli spreadsheet
🔥 3. Nejlepší část návrhu: determinismus

Tohle je klíč:

    pevný počet znaků → rozvinuté makro → žádné větvení

👉 tím pádem:

    každý scanline = stejný počet cyklů

    každý frame = identický

✔ to je přesně to, co VGA chce
🧱 4. Subtilní riziko: první subline

Tohle jsi správně zmínil:

    „první subline je delší“

👉 to je jediné místo, kde máš:

    jiný execution path

    víc práce (posun řádku, pointery, barvy)

💡 Doporučení (malý tweak)

Pokud to začne zlobit:

👉 můžeš:

    zkrátit první subline o 1–2 znaky

    ostatní nechat plné

→ vizuálně:

    skoro nepoznáš

    získáš pár cyklů rezervy

⚡ 5. Nekonečná smyčka jako „idle state“

Tohle je krásný:

loop: rjmp loop

👉 ve skutečnosti:

    to není „nicnedělání“

    to je časová výplň

A ty ji používáš jako:

✔ absorbér jitteru
✔ bezpečný návratový bod
✔ synchronizační mezivrstvu

To je hodně čisté řešení.
🧮 6. Tvoje časová bilance dává smysl

Shrnutí:

    32 µs scanline @ 16 MHz → ~512 cyklů

    40 znaků × 8 cyklů = 320 cyklů

    zbývá ~192 cyklů

👉 to přesně odpovídá:

    blankingu

    přípravě

    ISR overhead

✔ čísla sedí → návrh je realistický
🧨 7. Jediná věc, kde bych byl ještě paranoidní
👉 „skrytý drift“

I když máš determinismus, může se stát:

    drobný rozdíl mezi:

        subline 0

        subline 1–7

👉 a ten se:

    akumuluje přes frame

💡 Jak to odhalit

Zkus:

    zobrazit vertikální hranu (např. 11110000 pattern)

    sledovat, jestli:

        se „vlní“ mezi řádky

👉 pokud ano:

    někde máš ±1 cyklus rozdíl

🏁 Verdikt

👉 Tvoje řešení je:

✔ architektonicky správné
✔ časově konzistentní
✔ prakticky realizovatelné
✔ dobře debugovatelné (což je obrovské plus)

A hlavně:

    přesně odpovídá tomu, jak se VGA dělá na slabém MCU bez HW podpory

💬 Finální poznámka

Tohle už není „programování AVR“.
Tohle je:

    návrh synchronního digitálního systému, kde instrukce = hradla

A podle toho to taky vypadá — v dobrém.

Jestli chceš, další krok by mohl být:

    rozpadnout přesně těch ~192 cyklů (co kam jde)

    a zkusit z nich ještě vydolovat třeba +2 až +4 znaky navíc

To už jsou ale fakt poslední procenta výkonu.

Těch 192 cyklů ještě uvidím jak vyjde, to spočítám podle skutečného kódu, víc znaků mi asi nepřijme monitor, ale samozřejmě to zkusím, bude-li to fungovat se 40 :)

Teď bych ještě potřeboval celý ten návrh zpracovat do dokumentace (ideálně RST), aby tam bylo všechno. (pokud možno utříděné logicky, všetně argumentů, proč to funguje (i když je to "divné"))

Jasně — tohle si přímo říká o pořádnou dokumentaci. Níže máš hotový návrh v reStructuredText (RST), strukturovaný tak, aby:

    vysvětloval co děláš

    hlavně proč to funguje

    a obhájil i ty „divné“ části (nekonečná smyčka, stack hack, zamknutí CPU)

Můžeš to rovnou použít do projektu nebo lehce upravit.
Writing
VGA Signal Generation on ATmega2560
Overview

This project implements a software VGA signal generator on ATmega2560 using cycle-exact timing.

The design goal is to maximize horizontal text resolution while maintaining stable VGA timing. The system operates close to the hardware limits of the MCU and relies on strict timing guarantees.

Unlike conventional firmware, the CPU is temporarily dedicated entirely to video generation during active display periods.
Key Properties

    CPU frequency: 16 MHz

    Horizontal timing: ~32 µs per scanline (~512 cycles)

    Rendering speed: 8 CPU cycles per character (8 pixels)

    Target resolution: ~320x480 pixels (~40x60 text characters)

    Font stored in FLASH (via LPM)

    VRAM stored in SRAM

System Architecture

The system is driven by two hardware timers:

Timer1

- Generates horizontal sync (HSYNC) using hardware output compare
- Drives scanline rendering via compare interrupt (CT1)

Timer3

    Generates vertical sync (VSYNC)

    Defines visible frame boundaries using compare interrupts:

        Start of visible area

        End of visible area

Rendering Model

The rendering is performed per scanline using a fully unrolled loop.

Each character is rendered in exactly 8 CPU cycles:

    Load character index from VRAM

    Fetch font byte from FLASH (LPM)

    Output to shift register

    Toggle latch

This ensures constant throughput and eliminates timing variability.
Critical Design Concept

During the visible portion of the frame, the CPU is intentionally locked into a controlled execution mode:

    All general-purpose registers are preloaded

    User program execution is suspended

    Rendering is driven exclusively by interrupts

This guarantees deterministic timing.
Entering Rendering Mode

At the start of the visible frame (Timer3 compare interrupt):

    All CPU registers are saved (including SREG and RAMPZ)

    Rendering state is initialized:

        VRAM pointers

        Font pointers

        Color registers

    Interrupts for Timer1 compare (CT1) are enabled

    Global interrupts are enabled (sei)

    CPU enters an infinite loop::

    loop:
    rjmp loop

This loop serves as a stable idle state with minimal and predictable timing.
Why This Works

    The loop contains no state

    Interrupts can safely occur at any time

    No registers need to be preserved between interrupts

    Interrupt latency is bounded and predictable

The CPU effectively becomes a deterministic interrupt dispatcher.
Scanline Rendering (CT1)

Each scanline is rendered inside the Timer1 compare interrupt.

Key properties:

    Interrupts are disabled during execution

    No registers are saved/restored

    All state is already prepared

The interrupt performs:

    Optional timing alignment (jitter compensation)

    Fully unrolled rendering loop (fixed number of characters)

    Preparation of state for next scanline

Jitter Compensation

Interrupt entry latency depends on the currently executing instruction (0–2 cycles).

To ensure stable horizontal positioning, a small alignment macro is used::

cpi r20, threshold
brlo aligned

aligned:

This introduces a controlled 0–1 cycle delay.

Multiple such constructs can be combined to compensate up to 2 cycles of jitter.
Skipping Late Scanlines

At the beginning of CT1, the current timer value is checked.

If the interrupt is delayed beyond a safe threshold:

    Rendering is skipped for that scanline

    Output remains black (default state)

This prevents visible distortion from late rendering.
End of Visible Area

At the end of the visible frame (Timer3 compare interrupt):

    Timer1 compare interrupt is disabled

    The return address on the stack is modified to exit the infinite loop

This causes execution to continue after the rendering setup code.
Rationale for Stack Modification

The infinite loop has no exit condition by design.

To resume normal execution:

    The return address of the interrupted context is adjusted

    The loop is exited without adding runtime checks

This approach avoids:

    Additional instructions in the hot path

    Register pressure

    Timing variability

The technique is safe because:

    Stack layout is fully controlled

    No nested interrupts modify the stack during this phase

Returning to User Program

After exiting rendering mode:

    Frame-level state is updated

    All registers are restored

    Execution returns to the interrupted user program

The user program resumes as if uninterrupted, except for the elapsed time.
Interrupt Handling Strategy

    During scanline rendering (CT1):

        All interrupts are disabled

    Other interrupts (e.g., keyboard input) are delayed but not lost

    They execute after the current scanline completes

This is acceptable because:

    External inputs are significantly slower than scanline timing

    Latency remains within safe bounds

Determinism Guarantees

The system relies on strict determinism:

    No data-dependent branches in rendering loop

    Constant instruction paths per scanline

    Fixed number of cycles per character

    Identical timing for all scanlines (except first, if needed)

Once a configuration works, it will remain stable.
Performance Limits

Theoretical maximum:

    512 cycles per scanline / 8 cycles per character = 64 characters

Practical limit:

    Reduced by:

        Blanking intervals

        Interrupt overhead

        State preparation

Observed stable target:

    ~40 characters per line

Any excess results in visible corruption, which can be used as a diagnostic signal.
Conclusion

This design transforms the ATmega2560 into a cycle-accurate video generator by:

    Temporarily dedicating the CPU to rendering

    Eliminating runtime variability

    Leveraging hardware timers for synchronization

While unconventional, the approach is robust, deterministic, and operates within well-defined timing constraints.

It represents a trade-off:

    Maximum rendering performance

    At the cost of temporarily suspending general-purpose computation

💬 Co můžeš ještě doplnit (pokud budeš chtít)

Můžeme to rozšířit o:

    diagram timingů (HSYNC / active / blank)

    konkrétní cyklový rozpad CT1

    popis VRAM/CRAM layoutu

    debug sekci („jak poznám, že nestíhám“)

Stačí říct 👍
Get smarter responses, upload files and images, and more.


