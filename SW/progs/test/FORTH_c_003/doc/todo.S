TODO funkce Read a Write jako TCB promenne
TODO konverze ESC sekveni, nebo PS/2 scan kodu na pismena/K_xxx konstanty

v ASM.S na atmega2560 bych potreboval udelat kus kodu, ktery secte dve hodnoty a pokud vysledek prekroci treti hodnotu, tak provede jeden kus kodu, zatimco pokud neprekroci, tak jiny kus kodu. Prekrocenim je mysleno jak prekroceni smerem nahoru, tak prekroceni smerem dolu. 
pracuju s 3 bytovymi signed hodnotami a potrebuju detekovat jak pripad kdy plati A<limit && A+B>=limit, tak pripad kdy A>limit && A+B<= limit
