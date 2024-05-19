Vad är EOS?
Enemy Occupation System (EOS) gör det enkelt för missionsdesigners att fylla sina scenarier med enheter. Placera helt enkelt markörer som täcker områden på kartan så tar EOS hand om resten.

•	Funktioner:
    - Spawn av defensivt infanteri, dykare, båtar, fordon, helikoptrar och statiska vapen.
    - Spara serverresurser genom att cacha enheter:
        - Enheter spawnar när spelaren är nära.
        - Enheter som dödats i tidigare strider spawnar inte igen.
        - Enheter raderas när spelaren inte är nära.

    - Avancerade funktioner:
        - Sätt enheters färdigheter.
        - Skademultiplikator/neutralisering.
        - Dödsräknare.
        - Lägg till fler moddade enheter i EOS.
        - Göm/visa EOS-markörer i uppdrag.
        - Sannolikhet för att enheter ska dyka upp.

EOS & BASTION krav
•	Arma 3.
•	Inga mods eller tillägg behövs för att använda EOS.

Installera EOS
1. Ladda ner den senaste versionen av EOS.
2. Extrahera till skrivbordet.
3. Kopiera EOS-mappen till Arma 3 missionskatalogen: Documents\Arma 3 – Other profiles\USERNAME\missions.
4. Öppna Arma 3 editor. Öppna EOS-uppdraget.
5. Öppna EOS-mappen. Dubbelklicka på EOS och dubbelklicka sedan på OpenMe.sqf. Detta är var du kommer att starta EOS-zonerna.

Komma igång
1. Placera en markör (rektangel eller ellips) över området där du vill spawna enheter. Namnge den EOSzone1.
2. Öppna OpenMe.sqf som finns inuti ‘eos’ mappen: Missions\Missionname\eos\OpenMe.sqf.
3. Scrolla till botten. Kopiera och klistra in denna kod i OpenMe.sqf:
null = [["EOSzone1"],[2,1],[2,2],[1,3],[1],[2],[1,2],[1,0,35,WEST,FALSE,FALSE]] call EOS_Spawn;
4. Spara OpenMe.sqf.
5. Förhandsgranska uppdraget.

Förstå EOS
•	Exempel på EOS-spawn-kod:
        - null = [["EOSinf_1", "EOSinf_2"], [2,1],   [0,0],   [0,0],  [0], [0],  [0, 0], [0,  0, 250, EAST, FALSE, FALSE]] call EOS_Spawn;
        - null = [["a1", "a2"],            [b1,b2], [c1,c2], [d1,d2], [e], [f], [g1,g2], [h1, h2, h3,  h4,   h5,     h6]] call EOS_Spawn;

•	Beskrivning av parametrar:
        - a1, a2: Markörens variabelnamn.
        - b1, b2: Antal grupper och storlek på varje grupp för huspatruller.
        - c1, c2: Antal grupper och storlek på varje grupp för patrullerande infanteri.
        - d1, d2: Antal grupper och storlek på varje grupp för motoriserat infanteri.
        - e: Antal bepansrade fordon.
        - f: Antal grupper av statiska vapen.
        - g1, g2: Antal fordon och cargo för helikoptrar.
        - h1: Fraktion.
        - h2: Markörtyp.
        - h3: Spawn-avstånd.
        - h4: Enhetens sida.
        - h5: Höjdbegränsning.
        - h6: Debug-läge.

Vad är en EOS-zon?
När en markör blir en EOS-zon kommer enheter att spawna när spelaren är inom spawn-avståndet, och enheterna raderas när spelaren är utanför spawn-avståndet. Som standard kommer en EOS-zon att:

- Visa sig som röd på kartan.
- Glöda röd när spelaren är inom spawn-avstånd.
- Bli grön när zonen är rensad.

Gruppstorleksnyckel
0 = 1

1 = 2,4

2 = 4,8

3 = 8,12

4 = 12,16

5 = 16,20

Notera: För 100% sannolikhet att enheter spawnar, sätt tredje parametern till 100 eller lämna den tom.

•	Exempel på spawn av huspatruller
Huspatruller spawnar i byggnader inom markören. Efter att de spawnat stannar varje grupp inuti byggnaderna.
Spawna 1 huspatrullgrupp: [1,2]
Spawna 3 huspatrullgrupper med 50% sannolikhet att spawnas: [3,2,50]
Spawna en grupp med mellan 2 och 4 enheter: [1,1]
Spawna tre grupper med mellan 16 och 20 enheter och 70% sannolikhet att spawnas: [3,5,70]

•	Exempel på spawn av patrullerande infanteri
Patrullerande infanteri spawnar var som helst inom markören. Efter att de spawnat får varje grupp waypoints och patrullerar markören.
Spawna 1 grupp infanteri: [1,2]
Spawna 3 patrullgrupper med 50% sannolikhet att spawnas: [3,2,50]
Spawna en grupp med mellan 2 och 4 enheter: [1,1]
Spawna tre grupper med mellan 16 och 20 enheter och 70% sannolikhet att spawnas: [3,5,70]

•	Exempel på spawn av motoriserat infanteri
Motoriserat infanteri spawnar var som helst inom markören. Efter att de spawnat får varje grupp waypoints och patrullerar markören. Motoriserat infanteri är lätta fordon som transporterar enheter i de fria sätena.
Spawna 1 motoriserat infanteri: [1,2]
Spawna 3 motoriserade infanterigrupper med 50% sannolikhet att spawnas: [3,2,50]
Cargo med mellan 2 och 4 enheter: [1,1]
Cargo med mellan 16 och 20 enheter: [3,5]

•	Exempel på spawn av bepansrade fordon
Bepansrade fordon spawnar inom markören. Liknande motoriserat infanteri men de transporterar inte cargo.
Spawna 3 bepansrade fordon med 50% sannolikhet att spawnas: [3,50]
Spawna 3 bepansrade fordon med 100% sannolikhet att spawnas: [3]

•	Exempel på spawn av helikoptrar
Helikoptrar spawnar utanför markören och flyger mot zonen. Om helikopterns cargo är 0, spawnas en attackhelikopter. Om cargo är över 0, bär en transporthelikopter enheter in i markören och landar.
Spawna 1 transporthelikopter med cargo och 75% sannolikhet att spawnas: [1,3,75]
Spawna 1 attackhelikopter med 15% sannolikhet att spawnas: [1,0,15]

•	Fraktionsklasser
Struktur:
null = [["EOSinf_1","EOSinf_2"],[2,1],[0,0],[0,0],[0],[0],[0,0],[0,0,250,EAST,TRUE,FALSE]] call EOS_Spawn;
Fraktionskoder:
0 = EAST CSAT FACTION
1 = WEST NATO FACTION
2 = INDEPENDENT AAF FACTION
3 = CIVILIAN
4 = WEST FIA FACTION
5,6,7 = Anpassade klasser. Lägg till mod-fraktioner, etc.

•	Markörinställning
Struktur:
null = [["EOSinf_1","EOSinf_2"],[2,1],[0,0],[0,0],[0],[0],[0,0],[0,0,250,EAST,TRUE,FALSE]] call EOS_Spawn;
Inställningar:
0 = Standard. Markörer visas som röda och glöder rött när aktiva, och blir gröna när de är rensade.
1 = Markörer kommer att vara osynliga.
2 = Markörer kommer att visas som röda och bli gröna när de är rensade.

•	Spawn-avstånd
Struktur:
null = [["EOSinf_1","EOSinf_2"],[2,1],[0,0],[0,0],[0],[0],[0,0],[0,0, * ,EAST,TRUE,FALSE]] call EOS_Spawn;
När en spelare är inom *m från markören kommer alla enheter att spawna. Om spelaren lämnar *m radien kommer enheterna att raderas.
Ytterligare funktioner (för avancerade användare)

•	Radera EOS-zon:
Att manuellt deaktivera en zon kommer att radera alla aktiva enheter i området, och enheter kommer inte längre att spawnas i framtiden. Markören blir osynlig men finns fortfarande i uppdraget.
Placera följande kod i en trigger eller skript för att manuellt deaktivera en zon:
[["BAS_zone_1","EOSinf_1","EOSinf_2","EOSmot_1","EOSmot_2"]] call EOS_deactivate;

OBS: Denna funktion är endast för avancerade användare.

•	EOS dödsräknare:
EOS dödsräknare kommer att räkna antalet dödade EOS-enheter. Som standard visar dödsräknaren en hint som visar antalet dödade enheter varje gång en enhet dödas.
Du kan anpassa dödsräknaren med din egen kod genom att redigera eos\functions\EOS_KillCounter.sqf.
För att aktivera dödsräknaren, öppna openMe.sqf och ändra EOS_KILLCOUNTER=false till EOS_KILLCOUNTER=true.

•	Skademultiplikator:
Skademultiplikatorn gör enheter som spawnas av EOS lättare (eller svårare) att döda.
För att ändra skademultiplikatorn, öppna openMe.sqf. Hitta EOS_DAMAGE_MULTIPLIER=1.
Som standard är skademultiplikatorn satt till 1. För att göra enheter lättare att döda, öka siffran till 2 (detta gör att enheter tar 2x skada). Alternativt, sätt till en decimal för att göra enheter svårare att döda, t.ex. 0.5 (detta gör att enheter tar endast 50% av skadan).

•	AI-färdigheter:
Du kan anpassa färdighetsnivåerna för varje typ av enhet som spawnas.
För att ändra färdighetsinställningarna, öppna eos\AI_Skill.sqf.
Inuti hittar du detaljer som förklarar varje färdighet såsom noggrannhet, spot-avstånd, mod, uthållighet och sikhastighet.

•	Lägga till mods:
För att använda enheter från mods, öppna eos\unitpools.sqf. Bläddra till rad 67. Lägg till enhetsklassnamn i de relevanta arrayerna. Fraktioner 5,6,7 är reserverade för anpassade fraktioner.
_InfPool = Infanteriklassnamn
_ArmPool = Klassnamn för bepansrade fordon
_MotPool = Klassnamn för lätta fordon
_ACHPool = Klassnamn för attackhelikoptrar
_CHPool = Klassnamn för transporthelikoptrar
_stPool = Klassnamn för statiska vapen
_shipPool = Klassnamn för båtar
_diverPool = Klassnamn för dykare
_crewPool = Klassnamn för fordonsbesättningar
_heliCrew = Klassnamn för helikopterbesättningar

•	Höjdbegränsning:
En höjdbegränsning kommer att förhindra flygande enheter från att aktivera EOS-zoner. För att använda denna funktion (Boolean).
null = [["EOSinf_1","EOSinf_2"],[2,1],[0,0],[0,0],[0],[0],[0,0],[0,0,250,EAST, * ,FALSE]] call EOS_Spawn;

•	Debug-läge:
Debug-läget kommer att visa EOS-enheter på kartan och visa information om EOS. (Boolean).
null = [["EOSinf_1","EOSinf_2"],[2,1],[0,0],[0,0],[0],[0],[0,0],[0,0,250,EAST,false, * ]] call EOS_Spawn;
