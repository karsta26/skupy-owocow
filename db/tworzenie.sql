CREATE TABLE logowanie (
  id_logowanie INTEGER NOT NULL,
  uprawnienia INTEGER NOT NULL,
  login VARCHAR NOT NULL,
  haslo VARCHAR NOT NULL,
  PRIMARY KEY(id_logowanie)
);

CREATE TABLE owoc (
  id_owoc INTEGER NOT NULL,
  nazwa_owoc VARCHAR NOT NULL,
  PRIMARY KEY(id_owoc)
);

CREATE TABLE dane_dostawca (
  id_dane INTEGER NOT NULL,
  adres VARCHAR NOT NULL,
  pesel VARCHAR NOT NULL,
  nr_konta VARCHAR NOT NULL,
  PRIMARY KEY(id_dane)
);

CREATE TABLE wlasciciel (
  id_wlasciciel INTEGER NOT NULL,
  id_logowanie INTEGER NOT NULL,
  PRIMARY KEY(id_wlasciciel),
  FOREIGN KEY(id_logowanie)
    REFERENCES logowanie(id_logowanie)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

CREATE TABLE skup (
  id_skup INTEGER NOT NULL,
  id_wlasciciel INTEGER NOT NULL,
  nazwa_skup VARCHAR NOT NULL,
  PRIMARY KEY(id_skup),
  FOREIGN KEY(id_wlasciciel)
    REFERENCES wlasciciel(id_wlasciciel)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

CREATE TABLE dostawca (
  id_dostawca INTEGER NOT NULL,
  id_logowanie INTEGER NOT NULL,
  id_dane INTEGER NULL,
  imie VARCHAR NOT NULL,
  nazwisko VARCHAR NOT NULL,
  PRIMARY KEY(id_dostawca),
  FOREIGN KEY(id_dane)
    REFERENCES dane_dostawca(id_dane)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(id_logowanie)
    REFERENCES logowanie(id_logowanie)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

CREATE TABLE zamowienie (
  id_zamowienie INTEGER NOT NULL,
  id_owoc INTEGER NOT NULL,
  id_skup INTEGER NOT NULL,
  data_pocz DATE NOT NULL,
  data_kon DATE NOT NULL,
  ilosc_kilo INTEGER NOT NULL,
  PRIMARY KEY(id_zamowienie, id_owoc, id_skup),
  FOREIGN KEY(id_owoc)
    REFERENCES owoc(id_owoc)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(id_skup)
    REFERENCES skup(id_skup)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

CREATE TABLE transakcja (
  id_transakcja INTEGER NOT NULL,
  id_skup INTEGER NOT NULL,
  id_owoc INTEGER NOT NULL,
  id_dostawca INTEGER NOT NULL,
  id_zamowienie INTEGER NOT NULL,
  data_tran DATE NOT NULL,
  kilo_towar INTEGER NOT NULL,
  cena_za_towar DECIMAL NOT NULL,
  przelane BOOL NOT NULL,
  PRIMARY KEY(id_transakcja, id_skup, id_owoc, id_dostawca, id_zamowienie),
  FOREIGN KEY(id_dostawca)
    REFERENCES dostawca(id_dostawca)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(id_owoc, id_skup, id_zamowienie)
    REFERENCES zamowienie(id_owoc, id_skup, id_zamowienie)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

CREATE TABLE skup_dostawca (
  id_skup INTEGER NOT NULL,
  id_dostawca INTEGER NOT NULL,
  PRIMARY KEY(id_skup, id_dostawca),
  FOREIGN KEY(id_skup)
    REFERENCES skup(id_skup)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(id_dostawca)
    REFERENCES dostawca(id_dostawca)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

CREATE TABLE skup_owoc (
  id_skup INTEGER NOT NULL,
  id_owoc INTEGER NOT NULL,
  cena DECIMAL NOT NULL,
  PRIMARY KEY(id_skup, id_owoc),
  FOREIGN KEY(id_skup)
    REFERENCES skup(id_skup)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(id_owoc)
    REFERENCES owoc(id_owoc)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
);

