

CREATE OR REPLACE FUNCTION nowy_dostawca(im VARCHAR, naz VARCHAR, adr VARCHAR, pes VARCHAR, kon VARCHAR) 
RETURNS INTEGER AS $$
DECLARE
	id_log INTEGER := 0;
	id_dan INTEGER := 0;
	id_dos INTEGER := 0;
BEGIN
	IF length(pes) != 11 THEN
		RAISE EXCEPTION 'Pesel musi mieć 11 znaków';
	END IF;
	IF length(kon) != 26 THEN
		RAISE EXCEPTION 'Konto musi mieć 26 znaków';
	END IF;
	IF length(im) < 2 OR length(naz) < 2 OR length(adr) < 3 THEN
		RAISE EXCEPTION 'Długośc pola imie, nazwisko lub adres jast za krótka';
	END IF;
	SELECT INTO id_log MAX(id_logowanie) FROM logowanie;
	IF id_log IS NULL THEN id_log := 0; END IF;
	id_log := id_log + 1;
	INSERT INTO logowanie (id_logowanie, uprawnienia, login, haslo) VALUES (id_log, 1, im, naz);

	SELECT INTO id_dan MAX(id_dane) FROM dane_dostawca;
	IF id_dan IS NULL THEN id_dan := 0; END IF;
	id_dan := id_dan + 1;
	INSERT INTO dane_dostawca (id_dane, adres, pesel, nr_konta) VALUES (id_dan, adr, pes, kon);

	SELECT INTO id_dos MAX(id_dostawca) FROM dostawca;
	IF id_dos IS NULL THEN id_dos := 0; END IF;
	id_dos := id_dos + 1;
	INSERT INTO dostawca (id_dostawca, id_logowanie, id_dane, imie, nazwisko) VALUES
	(id_dos, id_log, id_dan, im, naz);

	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION zmien_haslo(id INTEGER, noweHaslo VARCHAR) 
RETURNS INTEGER AS $$
BEGIN
	IF length(noweHaslo) < 3 THEN
		RAISE EXCEPTION 'Nowe hasło powinno mieć min 3 znaki';
	END IF;
	UPDATE logowanie SET haslo=noweHaslo WHERE id_logowanie=id;
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION nowy_owoc(naz VARCHAR) 
RETURNS INTEGER AS $$
DECLARE
	id INTEGER := 0;
	test VARCHAR;
BEGIN
	IF length(naz) < 3 THEN
		RAISE EXCEPTION 'Nowy owoc powinien mieć min 3 znaki';
	END IF;
	SELECT INTO test nazwa_owoc FROM owoc WHERE nazwa_owoc=naz;
	IF test IS NOT NULL THEN 
		RAISE EXCEPTION 'Podany owoc już istnieje';
	END IF;
	SELECT INTO id MAX(id_owoc) FROM owoc;
	IF id IS NULL THEN id := 0; END IF;
	id := id + 1;
	INSERT INTO owoc (id_owoc, nazwa_owoc) VALUES (id, naz);

	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION nowy_skup(id_log_wl INTEGER, nazwa VARCHAR) 
RETURNS INTEGER AS $$
DECLARE
	id INTEGER := 0;
	id_wl INTEGER := 0;
	test VARCHAR;
BEGIN
	IF length(nazwa) < 3 THEN
		RAISE EXCEPTION 'Nowy skup powinnien mieć min 3 znaki';
	END IF;
	SELECT INTO test nazwa_skup FROM skup WHERE nazwa_skup=nazwa;
	IF test IS NOT NULL THEN 
		RAISE EXCEPTION 'Podana nazwa już istnieje';
	END IF;
	SELECT INTO id MAX(id_skup) FROM skup;
	IF id IS NULL THEN id := 0; END IF;
	id := id + 1;
	SELECT INTO id_wl id_wlasciciel FROM wlasciciel JOIN logowanie USING(id_logowanie) WHERE id_logowanie=id_log_wl;
	INSERT INTO skup (id_skup, id_wlasciciel, nazwa_skup) VALUES (id, id_wl, nazwa);

	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION nowy_wlasciciel(log VARCHAR, has VARCHAR) 
RETURNS INTEGER AS $$
DECLARE
	id INTEGER := 0;
	id_log INTEGER := 0;
BEGIN
	IF length(log) < 3 THEN
		RAISE EXCEPTION 'Nowy login powinnien mieć min 3 znaki';
	END IF;
	IF length(has) < 3 THEN
		RAISE EXCEPTION 'Nowe hasło powinno mieć min 3 znaki';
	END IF;
	SELECT INTO id_log MAX(id_logowanie) FROM logowanie;
	IF id_log IS NULL THEN id_log := 0; END IF;
	id_log := id_log + 1;
	INSERT INTO logowanie (id_logowanie, uprawnienia, login, haslo) VALUES (id_log, 2, log, has);

	SELECT INTO id MAX(id_wlasciciel) FROM wlasciciel;
	IF id IS NULL THEN id := 0; END IF;
	id := id + 1;
	INSERT INTO wlasciciel (id_wlasciciel, id_logowanie) VALUES (id, id_log);

	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION nowy_skup_owoc(skupArg INTEGER, owocArg INTEGER, cenaArg DECIMAL) 
RETURNS INTEGER AS $$
BEGIN
	IF cenaArg <= 0 THEN
		RAISE EXCEPTION 'Cena nie może być mniejsza od 0';
	END IF;
	INSERT INTO skup_owoc (id_skup, id_owoc, cena) VALUES (skupArg, owocArg, cenaArg);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION nowy_skup_dostawca(skupArg INTEGER, dostawcaArg INTEGER) 
RETURNS INTEGER AS $$
BEGIN
	INSERT INTO skup_dostawca (id_skup, id_dostawca) VALUES (skupArg, dostawcaArg);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION nowe_zamowienie(skupArg INTEGER, owocArg INTEGER, poczArg DATE, konArg DATE, kiloArg INTEGER) 
RETURNS INTEGER AS $$
DECLARE
	id INTEGER := 0;
	test DECIMAL;
BEGIN
	IF kiloArg <= 0 THEN
		RAISE EXCEPTION 'Kilogramy nie mogą być mniejsze od 0';
	END IF;
	IF poczArg > konArg THEN
		RAISE EXCEPTION 'Daty są nieprawidłowe';
	END IF;
	SELECT INTO test cena FROM skup JOIN skup_owoc USING(id_skup) JOIN owoc USING(id_owoc) WHERE id_skup=skupArg AND id_owoc=owocArg;
	
	IF test IS NULL THEN
		RAISE EXCEPTION 'Skup % nie obsługuje danego owocu % ', skupArg, owocArg;
	END IF;
	SELECT INTO id MAX(id_zamowienie) FROM zamowienie;
	IF id IS NULL THEN id := 0; END IF;
	id := id + 1;
	INSERT INTO zamowienie (id_zamowienie, id_owoc, id_skup, data_pocz, data_kon, ilosc_kilo) VALUES (id, owocArg, skupArg, poczArg, konArg, kiloArg);

	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION jest_zamowienie() RETURNS TRIGGER AS $$
	DECLARE
		moja_data DATE;
		data_od DATE;
		data_do DATE;
		suma INTEGER := 0;
		max INTEGER := 0;
		r zamowienie%rowtype;
		test VARCHAR;
		nowaCena DECIMAL;
    BEGIN
        moja_data := NEW.data_tran;
        -- znajdowanie odpowiedniego zamowienia
        FOR r IN SELECT * FROM zamowienie WHERE id_skup=NEW.id_skup AND id_owoc=NEW.id_owoc
		LOOP
	        SELECT INTO data_od data_pocz FROM zamowienie WHERE id_zamowienie=r.id_zamowienie;
	        SELECT INTO data_do data_kon FROM zamowienie WHERE id_zamowienie=r.id_zamowienie;

	        IF moja_data >= data_od AND moja_data < data_do THEN
	        	SELECT INTO suma SUM(kilo_towar) FROM transakcja JOIN zamowienie USING(id_zamowienie) WHERE id_zamowienie=r.id_zamowienie;
	        	SELECT INTO max ilosc_kilo FROM zamowienie WHERE id_zamowienie=r.id_zamowienie;
	        	IF suma IS NULL THEN suma := 0; END IF;
	        	suma := suma + NEW.kilo_towar;
	        	IF suma < max THEN 
	        		-- znaleziono
	        		NEW.id_zamowienie := r.id_zamowienie;
	        		-- tworzenie polaczenia skup - dostawca
	        		SELECT INTO test imie FROM skup JOIN skup_dostawca using(id_skup) JOIN dostawca using(id_dostawca) 
	        		WHERE id_dostawca=NEW.id_dostawca and id_skup=NEW.id_skup;
	        		IF test IS NULL THEN
	        			PERFORM nowy_skup_dostawca(NEW.id_skup, NEW.id_dostawca);
	        		END IF;
	        		-- sprawdzanie ceny
	        		SELECT INTO nowaCena cena FROM skup_owoc WHERE id_skup=NEW.id_skup AND id_owoc=NEW.id_owoc;
	        		IF NEW.cena_za_towar > 100 OR NEW.cena_za_towar < 0 THEN
	        			RAISE 'Cena za towar jest nieprawidlowa';
	        		ELSIF NEW.cena_za_towar = 0 THEN
	        			NEW.cena_za_towar = nowaCena;
	        		ELSE
	        			NEW.cena_za_towar = nowaCena * (NEW.cena_za_towar/100 + 1);
	        		END IF;
	        		RETURN NEW;
	        	END IF;
	        END IF;
	    END LOOP;
	    RAISE 'Brak aktywnego zamowienia skup=%, owoc=%, data=%',NEW.id_skup, NEW.id_owoc, moja_data;
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER czy_jest_zamowienie
BEFORE INSERT
    ON transakcja
   FOR EACH ROW
EXECUTE PROCEDURE jest_zamowienie();


CREATE OR REPLACE FUNCTION nowa_transakcja(skupArg INTEGER, owocArg INTEGER, dostArg INTEGER, dataArg DATE,
 kiloArg INTEGER, cenaArg DECIMAL) 
RETURNS INTEGER AS $$
DECLARE
	id INTEGER := 0;
BEGIN
	IF kiloArg <= 0 THEN
		RAISE EXCEPTION 'Kilogramy nie mogą być mniejsze od 0';
	END IF;
	SELECT INTO id MAX(id_transakcja) FROM transakcja;
	IF id IS NULL THEN id := 0; END IF;
	id := id + 1;
	INSERT INTO transakcja (id_transakcja, id_skup, id_owoc, id_dostawca, id_zamowienie, data_tran, kilo_towar, cena_za_towar, przelane) 
	VALUES (id, skupArg, owocArg, dostArg, 0, dataArg, kiloArg, cenaArg, 'FALSE');

	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION przelej_pieniadze(tranArg INTEGER)
RETURNS INTEGER AS $$
BEGIN
	UPDATE transakcja SET przelane='TRUE' WHERE id_transakcja=tranArg;
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION wszystkie_skupy_fun (id_log INTEGER) 
RETURNS TABLE ("Skup" VARCHAR, "Kilogramy" BIGINT, "Wartość" DECIMAL) 
AS $$
BEGIN
	RETURN QUERY SELECT nazwa_skup, CASE WHEN SUM(kilo_towar) > 0 THEN SUM(kilo_towar) ELSE 0 END, 
    CASE WHEN ROUND(SUM(kilo_towar*cena_za_towar), 2) > 0 THEN ROUND(SUM(kilo_towar*cena_za_towar),2) ELSE '0' END
    FROM skup JOIN wlasciciel USING(id_wlasciciel) LEFT JOIN transakcja USING(id_skup) WHERE id_logowanie=id_log 
    GROUP BY 1 ORDER BY 2 DESC;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION wszystkie_owoce_fun (id_log INTEGER) 
RETURNS TABLE ("Owoc" VARCHAR, "Skup" VARCHAR, "Kilogramy" BIGINT, "Wartość" DECIMAL) 
AS $$
BEGIN
	RETURN QUERY SELECT nazwa_owoc, nazwa_skup, CASE WHEN SUM(kilo_towar) > 0 THEN SUM(kilo_towar) ELSE '0' END 
	, CASE WHEN ROUND(SUM(kilo_towar*cena_za_towar), 2) > 0 THEN ROUND(SUM(kilo_towar*cena_za_towar),2) ELSE '0' END
	FROM skup JOIN wlasciciel USING(id_wlasciciel) JOIN transakcja USING(id_skup) RIGHT JOIN owoc USING(id_owoc) WHERE id_logowanie=id_log
	GROUP BY rollup(nazwa_owoc, nazwa_skup)
	ORDER BY nazwa_owoc, nazwa_skup;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION wszystkie_zamowienia_fun (id_log INTEGER) 
RETURNS TABLE ("Nr" INTEGER, "Skup" VARCHAR, "Owoc" VARCHAR,  "Kilogramy" INTEGER, "Początek" DATE, "Koniec" DATE) 
AS $$
BEGIN
	RETURN QUERY SELECT id_zamowienie, nazwa_skup, nazwa_owoc, ilosc_kilo, 
	data_pocz, data_kon
	FROM zamowienie JOIN skup USING(id_skup) JOIN owoc USING(id_owoc) JOIN wlasciciel USING(id_wlasciciel) WHERE id_logowanie=id_log
	ORDER BY 1,2,3,4,5,6;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE VIEW wszystkie_zamowienia AS
	SELECT id_zamowienie AS "Nr", nazwa_skup AS "Skup", nazwa_owoc AS "Owoc", ilosc_kilo as "Kilogramy", data_pocz AS "Początek", 
	data_kon as "Koniec"
	FROM zamowienie JOIN skup USING(id_skup) JOIN owoc USING(id_owoc)
	ORDER BY 1,2,3,4,5,6;


CREATE OR REPLACE VIEW wszystkie_dane AS
	SELECT id_dostawca AS "Nr", imie AS "Imię", nazwisko AS "Nazwisko", adres AS "Adres", pesel AS "Pesel", nr_konta AS "Nr konta"
	FROM dostawca JOIN dane_dostawca ON dostawca.id_dane=dane_dostawca.id_dane
	ORDER BY 1,3,2;


CREATE OR REPLACE FUNCTION do_przelania_fun (id_log INTEGER) 
RETURNS TABLE ("Nr" INTEGER, "Data" DATE, "Skup" VARCHAR, "Owoc" VARCHAR, "Nazwisko" VARCHAR, "Imię" VARCHAR, "Kilogramy" INTEGER, 
	"Cena" DECIMAL, "Wartość" DECIMAL) 
AS $$
BEGIN
	RETURN QUERY SELECT id_transakcja, data_tran, nazwa_skup, nazwa_owoc, dostawca.nazwisko, dostawca.imie,
	kilo_towar, ROUND(cena_za_towar, 2), ROUND(kilo_towar*cena_za_towar, 2)
	FROM dostawca JOIN transakcja USING(id_dostawca) JOIN owoc USING(id_owoc) JOIN zamowienie USING(id_zamowienie) JOIN skup ON 
	transakcja.id_skup=skup.id_skup JOIN wlasciciel USING(id_wlasciciel) 
	WHERE przelane='FALSE' AND wlasciciel.id_logowanie=id_log
	ORDER BY 1,2,3,4,5;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION logowanie_fun (log VARCHAR, has VARCHAR) 
RETURNS TABLE (id_log INTEGER,upr INTEGER) 
AS $$
BEGIN
	RETURN QUERY SELECT id_logowanie, uprawnienia FROM 
	logowanie WHERE login=log AND haslo=has;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION lista_transakcje (id_log INTEGER) 
RETURNS TABLE ("Skup" VARCHAR, "Owoc" VARCHAR, "Data" DATE, "Kilogramy" INTEGER, "Cena" DECIMAL, "Wartość" DECIMAL, "Przelane" TEXT) 
AS $$
BEGIN
	RETURN QUERY SELECT nazwa_skup, nazwa_owoc, data_tran, kilo_towar, ROUND(cena_za_towar, 2),
		ROUND(kilo_towar*cena_za_towar, 2), CASE transakcja.przelane WHEN 'f' THEN 'Nie' WHEN 't' THEN 'Tak' END 
		FROM skup JOIN transakcja USING(id_skup) JOIN owoc USING(id_owoc) JOIN dostawca USING(id_dostawca) 
		WHERE id_logowanie=id_log ORDER BY 3,1,2,4,5;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION lista_transakcje_fun(id_log INTEGER) 
RETURNS TABLE ("Nr" INTEGER, "Skup" VARCHAR, "Owoc" VARCHAR, "Dostawca" INTEGER, "Data" DATE, "Kilogramy" INTEGER, "Cena" DECIMAL, 
	"Wartość" DECIMAL, "Przelane" TEXT) 
AS $$
BEGIN
	RETURN QUERY SELECT id_transakcja, nazwa_skup, nazwa_owoc, id_dostawca, data_tran, kilo_towar, ROUND(cena_za_towar, 2),
		ROUND(kilo_towar*cena_za_towar, 2), CASE transakcja.przelane WHEN 'f' THEN 'Nie' WHEN 't' THEN 'Tak' END 
		FROM skup JOIN transakcja USING(id_skup) JOIN owoc USING(id_owoc) JOIN dostawca USING(id_dostawca)
		JOIN wlasciciel USING(id_wlasciciel) 
		WHERE wlasciciel.id_logowanie=id_log ORDER BY 3,1,2,4,5;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION lista_dane (id_log INTEGER) 
RETURNS TABLE ("Nr" INTEGER, "Imię" VARCHAR, "Nazwisko" VARCHAR, "Adres" VARCHAR, "Pesel" VARCHAR, "Nr konta" VARCHAR) 
AS $$
BEGIN
	RETURN QUERY SELECT dostawca.id_dostawca, dostawca.imie, dostawca.nazwisko, dane_dostawca.adres, dane_dostawca.pesel, dane_dostawca.nr_konta
	FROM dostawca JOIN dane_dostawca ON dostawca.id_dane=dane_dostawca.id_dane JOIN logowanie USING(id_logowanie)
	WHERE id_logowanie=id_log;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION ceny_owocow_fun (id_log INTEGER) 
RETURNS TABLE ("Skup" VARCHAR, "Owoc" VARCHAR, "Cena" DECIMAL) 
AS $$
BEGIN
	RETURN QUERY SELECT nazwa_skup, nazwa_owoc, cena
	FROM skup JOIN wlasciciel USING(id_wlasciciel) JOIN skup_owoc USING(id_skup) JOIN owoc USING(id_owoc)
	WHERE id_logowanie=id_log ORDER BY 1,2,3;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE VIEW ceny_owocow AS
SELECT nazwa_skup AS "Skup", nazwa_owoc AS "Owoc", cena AS "Cena"
	FROM skup JOIN wlasciciel USING(id_wlasciciel) JOIN skup_owoc USING(id_skup) JOIN owoc USING(id_owoc)
	ORDER BY 1,2,3;


CREATE OR REPLACE VIEW najlepsi_dostawcy AS
	SELECT id_dostawca AS "Nr", imie AS "Imię", nazwisko AS "Nazwisko", nazwa_owoc AS "Owoc", sum(kilo_towar) AS "Suma[kg]", 
	ROUND(min(cena_za_towar),2) AS "Cena min", ROUND(max(cena_za_towar),2) AS "Cena max", 
	ROUND(avg(cena_za_towar),2) AS "Cena średnia" FROM dostawca JOIN transakcja using(id_dostawca) 
	JOIN owoc using(id_owoc) GROUP BY 1,2,3,4 HAVING sum(kilo_towar) > 1000 ORDER BY 1,3,2,4,5;