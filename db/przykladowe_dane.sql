
SELECT nowy_owoc('jabłko');
SELECT nowy_owoc('wiśnia');
SELECT nowy_owoc('morela');
SELECT nowy_owoc('jagoda');
SELECT nowy_owoc('porzeczka');
SELECT nowy_owoc('truskawka');
SELECT nowy_owoc('brzoskwinia');
SELECT nowy_owoc('czereśnia');

SELECT nowy_wlasciciel('admin','admin');
SELECT nowy_wlasciciel('admin2','admin2');

SELECT nowy_dostawca('Dariusz', 'Wilk', 'ul. Dębowa 145 Dobrzany', '81664079192', '88443010053309297001745012');
SELECT nowy_dostawca('Władysław', 'Jaworski', 'ul. Duńska 144 Strzelce Krajeńskie', '47148009687', '53726303603434680882363932');
SELECT nowy_dostawca('Andrzej', 'Malinowski', 'ul. Góreckiego Józefa 16 Szczawno-Zdrój', '82750148405', '20225483184787005326036655');
SELECT nowy_dostawca('Jerzy', 'Wójcik', 'ul. Bracka 105 Radzionków', '74982213695', '99656448885603471729228063');
SELECT nowy_dostawca('Mariusz', 'Sawicki', 'ul. Janickiego Klemensa 23 Sławków', '37793073696', '72005061429255922744017723');
SELECT nowy_dostawca('Wiesław', 'Szczepański', 'ul. Dekana Jana 39 Bielsk Podlaski', '55744066545', '93650094134680341030119432');
SELECT nowy_dostawca('Tomasz', 'Szczepański', 'ul. Cicha 199 Strzelin', '41193638353', '27778667310680239887212828');
SELECT nowy_dostawca('Roman', 'Pietrzak', 'ul. Findera Pawła 200 Wojnicz', '99400553022', '37432781275102405943741974');
SELECT nowy_dostawca('Karolina', 'Malinowski', 'ul. Holenderska 125 Rumia', '81764354129', '89508267161722167108580755');
SELECT nowy_dostawca('Monika', 'Kozłowski', 'ul. Czarnieckiego Stefana 169 Wieleń', '58333767994', '34367932926724811928412343');
SELECT nowy_dostawca('Janusz', 'Ziółkowski', 'ul. Dubois Stanisława 196 Orneta', '84029957773', '65121561633883354672639624');
SELECT nowy_dostawca('Jakub', 'Ziółkowski', 'ul. Bogusławskiego Wojciecha 110 Sulęcin', '87820388727', '91852868508522069362389776');
SELECT nowy_dostawca('Ewa', 'Baran', 'ul. Asnyka Adama 37 Knurów', '06879874527', '82460125731479133688826943');
SELECT nowy_dostawca('Izabela', 'Makowski', 'ul.Andersena Hansa Chrystiana 111 Głubczyce', '91089424509', '72310451660024197360804425');
SELECT nowy_dostawca('Marzena', 'Maciejewski', 'ul. Czarnieckiego Stefana 86 Piotrków Kujawski', '44206146705', '39194789187900692197489247');

SELECT nowy_skup(1, 'Abar');
SELECT nowy_skup(1, 'Bacpol');
SELECT nowy_skup(1, 'Cedral');
SELECT nowy_skup(1, 'Jelonek');
SELECT nowy_skup(1, 'Aqua');
SELECT nowy_skup(2, 'Momento');

SELECT nowy_skup_owoc(1, 1, 1.1);
SELECT nowy_skup_owoc(1, 2, 5.0);
SELECT nowy_skup_owoc(1, 5, 4.3);
SELECT nowy_skup_owoc(2, 2, 5.3);
SELECT nowy_skup_owoc(2, 1, 0.9);
SELECT nowy_skup_owoc(2, 5, 5.3);
SELECT nowy_skup_owoc(2, 3, 3.3);
SELECT nowy_skup_owoc(3, 8, 7.7);
SELECT nowy_skup_owoc(3, 7, 3.2);
SELECT nowy_skup_owoc(4, 1, 1.2);
SELECT nowy_skup_owoc(4, 2, 5.2);
SELECT nowy_skup_owoc(4, 3, 3.2);
SELECT nowy_skup_owoc(4, 4, 9.1);
SELECT nowy_skup_owoc(4, 6, 5.2);
SELECT nowy_skup_owoc(5, 7, 3.3);
SELECT nowy_skup_owoc(4, 7, 2.3);

SELECT nowe_zamowienie(1, 1, '01-01-2018', '13-02-2018', 120000);
SELECT nowe_zamowienie(1, 5, '03-01-2018', '13-01-2018', 12000);
SELECT nowe_zamowienie(2, 3, '01-01-2018', '13-01-2018', 18000);
SELECT nowe_zamowienie(3, 7, '01-01-2018', '13-01-2018', 18000);
SELECT nowe_zamowienie(4, 1, '01-01-2018', '13-01-2018', 18000);
SELECT nowe_zamowienie(4, 7, '01-01-2018', '13-01-2018', 18000);
SELECT nowe_zamowienie(4, 3, '01-01-2018', '13-01-2018', 18000);
SELECT nowe_zamowienie(5, 7, '01-01-2018', '03-01-2018', 1800);
SELECT nowe_zamowienie(3, 8, '01-01-2018', '03-01-2018', 1800);

SELECT nowa_transakcja(1,1,1,'14-01-2018',2000,12);
SELECT nowa_transakcja(1,1,1,'14-01-2018',2000,15);
SELECT nowa_transakcja(1,1,1,'14-01-2018',2000,12);
SELECT nowa_transakcja(1,1,7,'02-01-2018',852,84);
SELECT nowa_transakcja(5,7,1,'02-01-2018',1546,84);
SELECT nowa_transakcja(4,3,5,'02-01-2018',3645,64);
SELECT nowa_transakcja(1,1,10,'02-01-2018',5486,15);
SELECT nowa_transakcja(4,7,8,'02-01-2018',2157,93);
SELECT nowa_transakcja(4,7,8,'02-01-2018',1030,0);