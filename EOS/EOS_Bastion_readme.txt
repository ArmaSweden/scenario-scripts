Vad är BASTION?
Bastion placerar spelare i ett defensivt scenario. Efter att en BASTION-zon aktiverats kommer vågor av enheter att attackera tills de besegras eller zonen blir övermannad.

- Funktioner:
    - Spawna attackerande infanteri, dykare, båtar, fordon och helikoptrar.
    - Spara serverresurser.
    - Ställ in fördröjning mellan vågor.
    - Ställ in initial pausperiod.
    - Ställ in antal vågor.
    - Integrerat med EOS för förlorade zoner.

EOS & BASTION krav
- Arma 3.
- Inga mods eller tillägg behövs för att använda EOS.

Installera BASTION
1. Ladda ner den senaste versionen av EOS.
2. Extrahera till skrivbordet.
3. Kopiera EOS-mappen till Arma 3 missionskatalogen: Documents\Arma 3 – Other profiles\USERNAME\missions.
4. Öppna Arma 3 editor. Öppna EOS-uppdraget.
5. Öppna EOS-mappen. Dubbelklicka på EOS och dubbelklicka sedan på OpenMe.sqf. Detta är var du kommer att starta EOS-zonerna.

Komma igång med BASTION
1. Placera en markör (rektangel eller ellips) över området där du vill försvara. Namnge den BAS_zone_1.
2. Öppna OpenMe.sqf som finns inuti ‘eos’ mappen: Missions\Missionname\eos\OpenMe.sqf.
3. Scrolla till botten. Kopiera och klistra in denna kod i OpenMe.sqf: 
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,0,EAST],[10,2,120,FALSE,true]] call Bastion_Spawn;
4. Spara OpenMe.sqf.
5. Förhandsgranska uppdraget.

Förstå BASTION
- Exempel på BASTION-spawn-kod:
    null = [["BAS_zone_1"],  [3,1],   [2,1],  [2],   [0,0],  [0,  0,EAST], [10,2,120,FALSE,true]] call Bastion_Spawn;
    null = [   ["a1"],      [b1,b2], [c1,c2], [d1], [e1,e2], [f1,f2,f3],   [g1,g2,g3, g4,    g5]] call Bastion_Spawn;
Beskrivning av parametrar:
a1: Markörens namn
b1, b2: Antal och storlek på infanterigrupper.
c1, c2: Antal och storlek på motoriserat infanteri.
d1: Antal bepansrade fordon.
e1, e2: Antal fordon och cargo för helikoptrar.
f1: Fraktion.
f2: Markörtyp.
f3: Enhetens sida.
g1: Initial tid innan första vågen.
g2: Antal vågor.
g3: Sekunder mellan vågor.
g4: EOS övertagande PÅ/AV.
g5: Visa BASTION statusinformation.

Vad är en Bastion-zon?
Vid inträde i en markör som aktiverats av Bastion kommer vågor av enheter att spawnas. De spawnade enheterna kommer att attackera markörens område tills spelarna lämnar området eller alla vågor besegrats.
Som standard kommer en BASTION-zon att:

Visa sig som orange på kartan.
- Glöda starkt orange när den aktiveras.
- Bli grön när den är slutförd.

Gruppstorleksnyckel
0 = 1
1 = 2,4
2 = 4,8
3 = 8,12
4 = 12,16
5 = 16,20

Exempel på spawn av anfallsinfanteri
Anfallsinfanteri spawnar 500m från markörens kant. Efter att de spawnat får varje grupp waypoints och attackerar markören.
För att spawna 1 grupp infanteri: [1,2]
För att spawna 3 grupper infanteri: [3,2]
För att spawna en grupp med mellan 2 och 4 enheter: [1,1]
För att spawna tre grupper med mellan 16 och 20 enheter: [3,5]

Exempel på spawn av motoriserat infanteri
Motoriserat infanteri spawnar 700m från markörens kant. Efter att de spawnat får varje grupp waypoints och attackerar markören. Motoriserat infanteri är lätta fordon och transporterar enheter i de fria sätena.
För att spawna 1 motoriserat infanteri: [1,2]
För att spawna 3 motoriserade infanterigrupper: [3,2]
Cargo med mellan 2 och 4 enheter: [1,1]
Cargo med mellan 16 och 20 enheter: [3,5]

Exempel på spawn av bepansrade fordon
Bepansrade fordon spawnar 500m från markörens kant. Efter att de spawnat får varje fordon waypoints och attackerar markören.

Exempel på spawn av helikoptrar
Helikoptrar spawnar utanför markören och flyger mot zonen. Om helikopterns cargo är 0, spawnas en attackhelikopter. Om cargo är över 0, bär en transporthelikopter enheter in i markören och landar.

Fraktionsklasser
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[*,0,EAST],[10,2,120,FALSE,true]] call Bastion_Spawn;

Fraktionskoder:
0 = EAST CSAT FACTION
1 = WEST NATO FACTION
2 = INDEPENDENT AAF FACTION
3 = CIVILIAN
4 = WEST FIA FACTION
5,6,7 = Anpassade klasser. Lägg till mod-fraktioner, etc.

Markörinställning
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,*,EAST],[10,2,120,FALSE,true]] call Bastion_Spawn;

Inställningar:
0 = Standard. Markörer visas som röda och glöder rött när aktiva, och blir gröna när de är rensade.
1 = Markörer kommer att vara osynliga.

BASTION specifika parametrar
Initial pausperiod:
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,0,EAST],[*,2,120,FALSE,true]] call Bastion_Spawn;

När bastion-zonen aktiveras av att en spelare går in i markörzonen kommer EOS att vänta * sekunder innan enheter spawnas.
Antal vågor:
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,0,EAST],[10,*,120,FALSE,true]] call Bastion_Spawn;
Varje våg spawnar de enheter som definieras i kallet. Sätt detta nummer till det antal vågor som kommer att attackera innan zonen är framgångsrikt försvarad.

Fördröjning mellan vågor:
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,0,EAST],[10,2,*,FALSE,true]] call Bastion_Spawn;
EOS kommer att vänta * sekunder innan nästa våg av enheter spawnas.

Aktivera EOS-integration:
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,0,EAST],[10,2,20,*,TRUE]] call Bastion_Spawn;
Simulerar att områden erövras.
Om TRUE kommer markören att fungera som en vanlig EOS-zon om spelaren lämnar bastion-zonen. Om FALSE kommer bastion-zonen att bli röd på kartan men inte innehålla några enheter.

Aktivera hints:
Struktur:
null = [["BAS_zone_1"],[3,1],[2,1],[2],[0,0],[0,0,EAST],[10,2,20,FALSE,*]] call Bastion_Spawn;
EOS kommer att visa hints med den återstående tiden innan nästa våg och meddela spelaren om de har förlorat bastion-zonen.
