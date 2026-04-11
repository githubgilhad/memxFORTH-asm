.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.04.10 16:41:38
:_modified: 1970.01.01 00:00:00
:tags: MHF-002
:authors: Gilhad
:summary: VGA2video
:title: VGA2video
:nice_title: |logo| %title% |logo|

%HEADER%

VGA2video
--------------------------------------------------------------------------------


Lorem ipsum ...

Mam problem s prerusenim na atmega2560 - vykresluju VGA obrazovku a normalne to funguje, ale pri volani nekterych funkci obrazovka blikne a ja nevim proc (a nechci to).

Pisu si grafickou kartu (primarne) a FORTH (jako pomocny nastroj) pro atmega2560 (a pouzivam avr-gcc toolchan a vetsinu pisu v asembleru, ale cast taky v C, zejmena ruzne podpurne funkce).
Mam vlastni PCB board, ktery umoznuje pouzit vsechny piny, VGA signal generuju v interruptu, aby casovani sedelo.
Protoze chci podporovat vic grafickych rezimu (a tedy i vic ovladacu), zakladni interrupty volaji handlery, jejich adresy jsou ulozene v promennych v RAM.

Pouzivam Timer3 pro generovani VSYNC pulzu a Timer1 pro HSYNC pulzy.
Dale Timer3 generuje interrupt kdyz zacina viditelna cast obrazu (vertical_start_handler). Ten ulozi vsechny registry, nacte do nich spravne hodnoty, povoli generovani interruptu od Timer1, povoli interrupty a ve smycce ceka, po skonceni smycky zase zakaze interrupty, zakaze generovani interruptu od Timer1, provede potrebnou udrzbu, obnovi registry a skonci. Jeho ukol je zablokovat hlavni vlakno a umoznit dalsimu interruptu/handleru presny start nebrzdeny zadnymi kritickymi sekcemi v kodu a usetrit mu rezii s nacitam/ukladanim registru. Behem viditelne casti se tedy vuci ostatnim interruptum chova jako velmi jednoduchy uzivatelsky kod ve smycce.
Timer1 generuje (behem viditelne casti obrazu) interrupt pro kazdy zobrazovaci radek (horizontal_line_handler). Ten vi, ze bezi v kontextu smycky vertical_start_handler, takze s minimalni rezii a kratkou synchronizaci zacne zobrazovat body na VGA konektor a neresi prakticky nic jineho (ma 8 taktu procesoru pro vystup 8 pixelu).
Nakonec Timer3 generuje interrupt kdyz konci viditelna cast obrazu (vertical_end_handler). Ten primeje vertical_start_handler ukoncit smycku a zakazat horizontal_line_handler.
