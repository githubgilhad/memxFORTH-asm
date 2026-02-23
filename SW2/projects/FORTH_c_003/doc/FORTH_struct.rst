.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

:date: 2026.01.28 10:35:41
:_modified: 1970.01.01 00:00:00
:tags: FORTH,AI
:authors: Gilhad
:summary: FORTH_struct
:title: FORTH_struct
:nice_title: |logo| %title% |logo|

%HEADER%

FORTH_struct
--------------------------------------------------------------------------------


Jak se ve FORTH dela, kdyz chci mit spoustu objektu (treba jednotky v Civilisation 1), ktere maji kazdy nekolik (potencialne hodne) datovych polozek (souradnice X Y, typ, pocet, zdravi, mesto, ...) a tyto objekty budu vytvaret dynamicky dle potreby. (o vytvareni mi nejde, jen ze to nebude proste nekde v poli)

Jde mi o to, jak takovy objekt popsat a pristupovat k polozkam, obdoba C struktury
typedef struct {int X,Y; int typ; String mesto; ...} jednotka;
jednotka p1; p1.X = 12;


Dobrá otázka – tohle je přesně místo, kde si člověk u FORTHu uvědomí, že **myslí jinak než C**, ale zároveň se k „structům“ dostaneš 😄

Níže ti ukážu **několik běžných přístupů**, od „klasiky“ až po praktičtější moderní styl (GForth apod.). Princip je vždy stejný:
➡ **objekt = kus paměti, pole = offsety do té paměti**

---

## 1️⃣ Základní princip ve FORTHu

FORTH **nemá struktury jako jazykový prvek**, ale má:

* adresy
* offsety
* slova, která s nimi pracují

Takže:

* objekt = adresa
* položka = `adresa + offset`

---

## 2️⃣ Nejjednodušší ruční „struct“ (core FORTH)

```forth
\ definice offsetů
0 CONSTANT unit.x
1 CELLS CONSTANT unit.y
2 CELLS CONSTANT unit.typ
3 CELLS CONSTANT unit.hp
4 CELLS CONSTANT unit.city
5 CELLS CONSTANT /unit   \ velikost celé struktury
```

### Vytvoření objektu

```forth
CREATE u1 /unit ALLOT
```

### Přístup k položkám

```forth
\ zápis
12 u1 unit.x + !
34 u1 unit.y + !

\ čtení
u1 unit.hp + @
```

📌 **Myšlenkový model**:

```text
u1  ---> [ x ][ y ][ typ ][ hp ][ city ]
          0   4    8     12    16
```

Tohle je 100% přenositelné, ale dost ukecané.

---

## 3️⃣ Hezčí varianta: „field words“ (idiomatický FORTH)

Běžný trik:

```forth
: field: ( offset size "name" -- offset' )
  CREATE OVER , +
  DOES> ( base -- addr ) @ + ;
```

Použití:

```forth
0
CELL field: x
CELL field: y
CELL field: typ
CELL field: hp
CELL field: city
CONSTANT /unit
```

### Použití objektu

```forth
CREATE u1 /unit ALLOT

12 u1 x !
34 u1 y !
u1 hp @ .
```

✨ Už se to **chová skoro jako `p1.x` v C**.

---

## 4️⃣ GForth / moderní FORTH: `struct`

Pokud používáš **GForth**, máš přímo podporu struktur:

```forth
struct
  cell% field x
  cell% field y
  cell% field typ
  cell% field hp
  cell% field city
end-struct jednotka%
```

### Vytvoření objektu

```forth
jednotka% %alloc constant u1
```

### Přístup

```forth
12 u1 x !
34 u1 y !
u1 hp @ .
```

🔥 To je asi **nejbližší C strukturám**, co ve FORTHu dostaneš.

---

## 5️⃣ Dynamická tvorba mnoha objektů (Civilization styl)

Typicky:

* vlastní **heap / pool**
* nebo prostě `ALLOCATE`

```forth
jednotka% %alloc constant unit1
jednotka% %alloc constant unit2
```

Nebo pole pointerů:

```forth
CREATE units 100 CELLS ALLOT
```

Každá buňka = adresa jedné jednotky.

---

## 6️⃣ Strings, reference, složitější věci

FORTH styl:

* string = `( addr len )`
* ve struktuře **ukládáš pointer**, ne string

```forth
cell% field city-name   \ ukazatel na string
cell% field city-len
```

---

## 7️⃣ Shrnutí (mentální model)

| C           | FORTH                 |
| ----------- | --------------------- |
| `struct`    | kus paměti            |
| `obj.x`     | `obj x @`             |
| `obj.x = 5` | `5 obj x !`           |
| `malloc`    | `ALLOCATE` / `%alloc` |

FORTH tě nutí:

* **explicitně myslet na paměť**
* ale na oplátku máš **extrémní flexibilitu** (žádné typové klece)

---

Jestli chceš, můžeme:

* navrhnout **celý model jednotek Civ 1**
* ukázat **objektový styl FORTHu**
* nebo **jak to zrychlit / zmenšit paměť**

Stačí říct, v jakém FORTHu (GForth? retro? vlastní VM?) 👀
