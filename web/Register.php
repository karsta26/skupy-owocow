<?php
	// klasa zajmująca sie wyglądem strony i obsługująca zapytania
	class Register {
		// start sesji
		function __construct () {
			session_start();
		}

		// funkcja loguje użytkownika łącząc się z bazą danych i sprawdzając czy taki użytkownik istnieje
		// ustawia zmienne sesji: autoryzacje, id_log oraz uprawnienia
		function _login() {
			$login = $_POST['login'] ;
			$pass  = $_POST['pass'] ;

			$dbconn = new Connection;
			$dbconn->connect();
			$dbdata = $dbconn->perform_query("SELECT * FROM logowanie_fun('$login','$pass');");
			if(count($dbdata) == 2 )
			{
				$_SESSION['auth'] = 'OK';
				$_SESSION['id_log'] = $dbdata[0];
				$_SESSION['upr'] = $dbdata[1];
			}
			$dbconn->disconnect();
			$text = ( $access ? '<h1 style="color: red">Użytkownik zalogowany</h1>' : '<h1 style="color: red">Błędne login lub hasło!</h1>' ) ;
			return $text ;
		}

		// sprawdza czy użytkownik jest zalogowany
		function _is_logged() {
			if ( isset( $_SESSION['auth'] ) ) { 
				$ret = $_SESSION['auth'] == 'OK' ? true : false ;
			} else { $ret = false ; }
			return $ret ;
		} 
			
		// wylogowywuje niszczac sesje	
		function _logout() {
			unset($_SESSION); 
			session_destroy();   
			$text =  'Uzytkownik wylogowany' ;
			return $text ;
		}

		// dodaje nowego właściciela do bazy
		function _add_user() {
			$login = $_POST['login_rej'] ;
			$pass  = $_POST['pass_rej'] ;

			$dbconn = new Connection;
			$dbconn->connect();
			$dbdata = $dbconn->perform_query("SELECT nowy_wlasciciel('$login','$pass');");
			$dbconn->disconnect();
		}

		// generuje element menu
		function generate_menu_item($action, $name, $value)
		{
			echo "\n<li><form action=\"$action\" method=\"post\">
				  <input type=\"submit\" name=\"$name\" value=\"$value\">
				</form></li>";
		}

		// generuje element grupujący do menu
		function generate_menu_item_normal($name)
		{
			echo "<li class=\"nav_info\">$name</li>";
		}

		// tworzy menu ze względu na to jakie uprawnienia ma użytkownik
		function generate_menu()
		{
			echo "<ul>";
			if(isset($_SESSION['upr']) and $_SESSION['upr'] == '2')
			{
				$this->generate_menu_item_normal('Raporty:');
				$this->generate_menu_item('baza.php', 'ZAMOWIENIA', 'Zamówienia');
				$this->generate_menu_item('baza.php', 'OWOCE', 'Owoce - Skup');
				$this->generate_menu_item('baza.php', 'SKUPY', 'Skupy');
				$this->generate_menu_item('baza.php', 'CENY', 'Ceny owoców');
				$this->generate_menu_item('baza.php', 'TRANSAKCJE', 'Transakcje');
				$this->generate_menu_item('baza.php', 'DOSTAWCY', 'Dostawcy');
				$this->generate_menu_item('baza.php', 'NAJLEPSI', 'Najlepsi dostawcy');
				$this->generate_menu_item_normal('Dodawanie:');
				$this->generate_menu_item('baza.php', 'NOWY_SKUP', 'Nowy skup');
				$this->generate_menu_item('baza.php', 'NOWY_OWOC', 'Nowy owoc');
				$this->generate_menu_item('baza.php', 'NOWY_SKUP_OWOC', 'Obsługa owocu');
				$this->generate_menu_item('baza.php', 'NOWE_ZAM', 'Nowe zamówienie');
				$this->generate_menu_item('baza.php', 'NOWY_DOST', 'Nowy dostawca');
				$this->generate_menu_item('baza.php', 'NOWA_TRAN', 'Nowa transakcja');
				$this->generate_menu_item('baza.php', 'PRZELEJ', 'Przelej pieniądze');
				$this->generate_menu_item('baza.php', 'HASLO', 'Zmień hasło');
				$this->generate_menu_item('index.php', 'logout', 'Wyloguj');
			}
			else if (isset($_SESSION['upr']) and $_SESSION['upr'] == '1')
			{
				$this->generate_menu_item_normal('Raporty:');
				$this->generate_menu_item('baza.php', 'DANE', 'Moje dane');
				$this->generate_menu_item('baza.php', 'ZAMOWIENIA', 'Zamówienia');
				$this->generate_menu_item('baza.php', 'CENY', 'Ceny owoców');
				$this->generate_menu_item('baza.php', 'TRANSAKCJE', 'Moje transakcje');
				$this->generate_menu_item_normal('Zmiana:');
				$this->generate_menu_item('baza.php', 'HASLO', 'Zmień hasło');
				$this->generate_menu_item('index.php', 'logout', 'Wyloguj');
			}
			echo "</ul>";
		}

		// obsługuje zapytania post 
		// ze względu na to jakie dane są przesyłane postem, generowana jest inna zawartość strony
		// np. tabele z bazy, formularze wprowadzające dane, obsługa formularzy
		function get_post_request($dbconn)
		{
			if($_SERVER['REQUEST_METHOD'] == "POST")
			{
				if(isset($_POST['ZAMOWIENIA']))
				{
					// uprawnienie typu 1 to użytkownik - dostawca
					if($_SESSION['upr'] == '1'){
						echo "<h2>Wszystkie zamówienia na owoce</h2>";
				    	$dbconn->generate_table('SELECT * from wszystkie_zamowienia;'); 
					}
					// uprawnienie typu 2 to użytkownik - wlaściciel
					if($_SESSION['upr'] == '2'){
						echo "<h2>Zamówienia na owoce dla Twoich skupów</h2>";
				    	$dbconn->generate_table('SELECT * from wszystkie_zamowienia_fun('.$_SESSION['id_log'].');'); 
					}

				}

				if(isset($_POST['OWOCE']))
				{
					echo "<h2>Raport zbiorczy dla owoców w Twoich skupach</h2>";
				    $dbconn->generate_table('SELECT * from wszystkie_owoce_fun('.$_SESSION['id_log'].');'); 
				}

				if(isset($_POST['SKUPY']))
				{
					echo "<h2>Wszystkie Twoje skupy</h2>";
					echo "<h4>Tabela zawiera informację o ilości zakupionych owoców [kg] i ich wartości [zł]</h4>";
				    $dbconn->generate_table('SELECT * from wszystkie_skupy_fun('.$_SESSION['id_log'].');'); 
				}

				if(isset($_POST['CENY']))
				{
					if($_SESSION['upr'] == 2)
					{
						echo "<h2>Podstawowe ceny owoców w Twoich skupach</h2>";
				    	$dbconn->generate_table('SELECT * from ceny_owocow_fun('.$_SESSION['id_log'].');'); 
					}
					else
					{
						echo "<h2>Podstawowe ceny owoców</h2>";
				    	$dbconn->generate_table('SELECT * from ceny_owocow;'); 
					}
				}

				if(isset($_POST['NAJLEPSI']))
				{
					echo "<h2>Najlepsi dostawcy, którzy dostraczyli min. 1000 kg danego owocu</h2>";
				    $dbconn->generate_table('SELECT * from najlepsi_dostawcy;'); 
				}

				if(isset($_POST['DOSTAWCY']))
				{
					echo "<h2>Wszyscy dostawcy w bazie</h2>";
				    $dbconn->generate_table('SELECT * from wszystkie_dane;'); 
				}

				if(isset($_POST['NOWY_SKUP']))
				{
				    $this->generate_form_nowy_skup($dbconn);
				}

				// obsługa formularza - dodanie nowego skupu do bazy
				if(isset($_POST['nazwa_skup']))
				{
					$resp =  $dbconn->perform_query('SELECT nowy_skup('.$_SESSION['id_log'].',\''.$_POST['nazwa_skup']."');");
					$resp = implode(",", $resp);
					if($resp == '1')
						echo "<p>Operacja się udała!</p>";
					else
						echo "<p>Wystąpił błąd</p>";
				}

				if(isset($_POST['PRZELEJ']))
				{
				    $this->generate_form_przelej($dbconn);
				}

				// obsługa formularza - przelewanie pieniędzy
				// wyświetla także tabelkę z danymi dostawcy
				if(isset($_POST['id_tran']))
				{
					$resp =  $dbconn->perform_query('SELECT przelej_pieniadze('.$_POST['id_tran'].");");
					$resp = implode(",", $resp);
					if($resp == '1')
					{
						echo "<p>Dane dostawcy:</p>";
						$dbconn->generate_table("SELECT imie AS \"Imie\", nazwisko AS \"Nazwisko\", adres AS \"Adres\", 
							pesel AS \"Pesel\", nr_konta AS \"Nr konta\" from dostawca join dane_dostawca on 
							dostawca.id_dane=dane_dostawca.id_dane 
							join transakcja using(id_dostawca) WHERE id_transakcja='".$_POST['id_tran']."';");
					}
					else
						echo "<p>Wystąpił błąd</p>";
				}

				if(isset($_POST['NOWA_TRAN']))
				{
				    $this->generate_form_nowa_tran($dbconn);
				}

				// obsługa formularza - nowa transakcja
				if(isset($_POST['skup']) and isset($_POST['owoc']) and isset($_POST['dostawca']) and isset($_POST['data'])
					 and isset($_POST['kilo']) and isset($_POST['cena']))
				{
					$resp =  $dbconn->perform_query('SELECT id_skup FROM skup WHERE nazwa_skup=\''.$_POST['skup']."';");
					$resp = implode(",", $resp);
					$id_skup = $resp;

					$resp =  $dbconn->perform_query('SELECT id_owoc FROM owoc WHERE nazwa_owoc=\''.$_POST['owoc']."';");
					$resp = implode(",", $resp);
					$id_owoc = $resp;

					$resp =  $dbconn->perform_query("SELECT nowa_transakcja($id_skup, $id_owoc, ".$_POST['dostawca'].", '"
						.$_POST['data']."', ".$_POST['kilo'].", ".$_POST['cena'].");");
					$resp = implode(",", $resp);
					if($resp == '1')
					{
						echo "<p>Operacja się udała!</p>";
					}
					else
						echo "<p>Wystąpił błąd</p>";
				}

				if(isset($_POST['NOWE_ZAM']))
				{
				    $this->generate_form_nowe_zam($dbconn);
				}

				// obsługa formularza - nowe zamówienie
				if(isset($_POST['skup']) and isset($_POST['owoc']) and isset($_POST['data_pocz']) and isset($_POST['data_kon'])
					 and isset($_POST['kilo']))
				{
					$resp =  $dbconn->perform_query('SELECT id_skup FROM skup WHERE nazwa_skup=\''.$_POST['skup']."';");
					$resp = implode(",", $resp);
					$id_skup = $resp;

					$resp =  $dbconn->perform_query('SELECT id_owoc FROM owoc WHERE nazwa_owoc=\''.$_POST['owoc']."';");
					$resp = implode(",", $resp);
					$id_owoc = $resp;

					$resp =  $dbconn->perform_query("SELECT nowe_zamowienie($id_skup, $id_owoc, '".$_POST['data_pocz']."', '"
						.$_POST['data_kon']."', ".$_POST['kilo'].");");
					$resp = implode(",", $resp);
					if($resp == '1')
					{
						echo "<p>Operacja się udała!</p>";
					}
					else
						echo "<p>Wystąpił błąd</p>";
				}

				if(isset($_POST['NOWY_SKUP_OWOC']))
				{
				    $this->generate_form_nowy_skup_owoc($dbconn);
				}

				// obsługa formularza - obsługa owocu przez skup
				if(isset($_POST['skup']) and isset($_POST['owoc']) and isset($_POST['cena_podst']))
				{
					$resp =  $dbconn->perform_query('SELECT id_skup FROM skup WHERE nazwa_skup=\''.$_POST['skup']."';");
					$resp = implode(",", $resp);
					$id_skup = $resp;

					$resp =  $dbconn->perform_query('SELECT id_owoc FROM owoc WHERE nazwa_owoc=\''.$_POST['owoc']."';");
					$resp = implode(",", $resp);
					$id_owoc = $resp;

					$resp =  $dbconn->perform_query("SELECT nowy_skup_owoc($id_skup, $id_owoc, ".$_POST['cena_podst'].");");
					$resp = implode(",", $resp);
					if($resp == '1')
					{
						echo "<p>Operacja się udała!</p>";
					}
					else
						echo "<p>Wystąpił błąd</p>";
				}

				if(isset($_POST['NOWY_OWOC']))
				{
				    $this->generate_form_nowy_owoc($dbconn);
				}

				// obsługa formularza - dodanie owocu
				if(isset($_POST['nazwa_owoc']))
				{
					$resp =  $dbconn->perform_query('SELECT nowy_owoc(\''.$_POST['nazwa_owoc']."');");
					$resp = implode(",", $resp);
					if($resp == '1')
					{
						echo "<p>Operacja się udała!</p>";
						$dbconn->generate_table("SELECT id_owoc AS \"Nr\", nazwa_owoc AS \"Nazwa\" from owoc 
							WHERE nazwa_owoc='".$_POST['nazwa_owoc']."';");
					}
					else
						echo "<p>Wystąpił błąd</p>";
				}

				if(isset($_POST['NOWY_DOST']))
				{
				    $this->generate_form_nowy_dost($dbconn);
				}

				// obsługa formularza - nowy dostawca
				if(isset($_POST['imie']) and isset($_POST['nazwisko']) and isset($_POST['adres'])
					and isset($_POST['pesel']) and isset($_POST['nr']))
				{
					$resp =  $dbconn->perform_query('SELECT nowy_dostawca(\''.$_POST['imie']."','".$_POST['nazwisko']."','".$_POST['adres']."','".$_POST['pesel']."','".$_POST['nr']."');");
					$resp = implode(",", $resp);
					if($resp == '1')
						echo "<p>Operacja się udała!</p>";
					else
						echo "<p>Wystąpił błąd</p>";
				}

				// obsługa formularza - lista transakcji
				if(isset($_POST['TRANSAKCJE']))
				{
					if($_SESSION['upr'] == 1)
					{
						echo "<h2>Twoje transakcje</h2>";
				    	$dbconn->generate_table('SELECT * from lista_transakcje('.$_SESSION['id_log'].');'); 
					}
				    else
				    {
						echo "<h2>Wszystkie transakcje w Twoich skupach</h2>";
				    	$dbconn->generate_table('SELECT * from lista_transakcje_fun('.$_SESSION['id_log'].');'); 
				    }
				}

				// wyświetlenie danych dostawcy
				if(isset($_POST['DANE']))
				{
					echo "<h2>Twoje dane</h2>";
				    $dbconn->generate_table('SELECT * from lista_dane('.$_SESSION['id_log'].');'); 
				}

				if(isset($_POST['HASLO']))
				{
				    $this->generate_form_haslo($dbconn);
				}

				// obsługa formularza - zmiana hasła
				if(isset($_POST['nowe_haslo']))
				{
				    $resp =  $dbconn->perform_query('SELECT zmien_haslo('.$_SESSION['id_log'].',\''.$_POST['nowe_haslo'].'\');'); 
					$resp = implode(",", $resp);
					if($resp == '1')
						echo "<p>Operacja się udała!</p>";
					else
						echo "<p>Wystąpił błąd</p>";
				}
			}
			else
			{
				echo "<h2>Wybierz z menu co chcesz robić</h2>";
			}
		}

		// generuje formularz obsługujący wprowadzanie nowego skupu do bazy
		function generate_form_nowy_skup($dbconn)
		{
			echo "<h2>Nowy skup</h2>\n";
			echo "<form name=\"nowy_skup\" method=\"post\" action=\"baza.php\">
				Podaj nazwę skupu:<input type=\"text\" name=\"nazwa_skup\" required><br/>
				<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">
			</form>";  
		}

		// generuje formularz obsługujący przelewanie pieniędzy
		function generate_form_przelej($dbconn)
		{
			echo "\n<h2>Przelewanie pieniędzy</h2>\n";
			echo "<form name=\"do_przelania\" method=\"post\" action=\"baza.php\">
				Podaj numer transakcji:<input type=\"text\" name=\"id_tran\" required><br/>
				<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">
			</form>";
			echo "\n<br/>\n";
			$dbconn->generate_table('SELECT * from do_przelania_fun('.$_SESSION['id_log'].');'); 
		}

		// generuje formularz obsługujący tworzenie nowej transakcji
		function generate_form_nowa_tran($dbconn)
		{
			echo "<h2>Nowa transakcja</h2>\n";
			echo "<form name=\"nowa_tran\" method=\"post\" action=\"baza.php\">
				Skup:"; 
			$resp = $dbconn->generate_select('skup','SELECT nazwa_skup from skup JOIN wlasciciel USING(id_wlasciciel) WHERE id_logowanie='.$_SESSION['id_log'].' ORDER BY 1;');
			echo "<br/>";
			echo "Owoc:";
			$resp = $dbconn->generate_select('owoc','SELECT nazwa_owoc from owoc ORDER BY 1;');
			echo "<br/>";
			echo "Dostawca (nr id):";
			$resp = $dbconn->generate_select('dostawca','SELECT id_dostawca from dostawca ORDER BY 1;');
			echo "<br/>";
			echo "Data:";
			echo "<input type=\"date\" name=\"data\" style=\"margin-top: 10px\" required>";
			echo "<br/>";
			echo "Kilogramy:";
			echo "<input type=\"number\" name=\"kilo\" style=\"margin-top: 10px\" required>";
			echo "<br/>";
			echo "Cena:";
			echo "<input type=\"number\" name=\"cena\" min=\"0\" max=\"100\" style=\"margin-top: 10px\" value=\"0\" required>";
			echo "<br/>";
			echo "<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">";
			echo "</form>";
			echo "<br/>";
			echo "<p>Pole cena wymaga liczb z zakresu 0-100. Są to procenty dodawane do podstawowej ceny za owoc.</p>";
			echo "<p>0 - normalna cena</p>";
			echo "<p>40 - cena podniesiona o 40%</p>";
		}

		// generuje formularz obsługujący tworzenie nowego owocu
		function generate_form_nowy_owoc($dbconn)
		{
			echo "<h2>Nowy owoc w bazie</h2>\n";
			echo "<form name=\"nowy_owoc\" method=\"post\" action=\"baza.php\">
				Podaj nazwę owocu:<input type=\"text\" name=\"nazwa_owoc\" required><br/>
				<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">
			</form>";
		}

		// generuje formularz obsługujący dodawanie do bazy nowego dostawcy
		function generate_form_nowy_dost($dbconn)
		{
			echo "<h2>Nowy dostawca</h2>\n";
			echo "<form name=\"nowy_dost\" method=\"post\" action=\"baza.php\">
				Imię:<input type=\"text\" name=\"imie\" required><br/>
				Nazwisko:<input type=\"text\" name=\"nazwisko\" style=\"margin-top: 10px\" required><br/>
				Adres:<input type=\"text\" name=\"adres\" style=\"margin-top: 10px\" required><br/>
				Pesel:<input type=\"number\" name=\"pesel\" style=\"margin-top: 10px\" required><br/>
				Numer konta:<input type=\"number\" name=\"nr\" style=\"margin-top: 10px\" required><br/>
				<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">
			</form>";
		}

		// generuje formularz obsługujący dodanie nowego zamówienia
		function generate_form_nowe_zam($dbconn)
		{
			echo "<h2>Nowe zamówienie</h2>\n";
			echo "<form name=\"nowe_zam\" method=\"post\" action=\"baza.php\">
				Skup:"; 
			$resp = $dbconn->generate_select('skup','SELECT nazwa_skup from skup JOIN wlasciciel USING(id_wlasciciel) WHERE id_logowanie='.$_SESSION['id_log'].' ORDER BY 1;');
			echo "<br/>";
			echo "Owoc:";
			$resp = $dbconn->generate_select('owoc','SELECT nazwa_owoc from owoc ORDER BY 1;');
			echo "<br/>";
			echo "Data początek:";
			echo "<input type=\"date\" name=\"data_pocz\" style=\"margin-top: 10px\" required>";
			echo "<br/>";
			echo "Data koniec:";
			echo "<input type=\"date\" name=\"data_kon\" style=\"margin-top: 10px\" required>";
			echo "<br/>";
			echo "Kilogramy:";
			echo "<input type=\"number\" name=\"kilo\" style=\"margin-top: 10px\" required>";
			echo "<br/>";
			echo "<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">";
			echo "</form>";
		}

		// generuje formularz dodający obsługę owocu przez skup
		function generate_form_nowy_skup_owoc($dbconn)
		{
			echo "<h2>Dodaj obsługę owocu przez skup</h2>\n";
			echo "<form name=\"nowy_skup_owoc\" method=\"post\" action=\"baza.php\">
				Skup:"; 
			$resp = $dbconn->generate_select('skup','SELECT nazwa_skup from skup JOIN wlasciciel USING(id_wlasciciel) WHERE id_logowanie='.$_SESSION['id_log'].' ORDER BY 1;');
			echo "<br/>";
			echo "Owoc:";
			$resp = $dbconn->generate_select('owoc','SELECT nazwa_owoc from owoc ORDER BY 1;');
			echo "<br/>";
			echo "Cena podstawowa:";
			echo "<input type=\"text\" name=\"cena_podst\" style=\"margin-top: 10px\" required>";
			echo "<br/>";
			echo "<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">";
			echo "</form>";
		}

		// generuje formularz obsługujący zmianę hasła
		function generate_form_haslo($dbconn)
		{
			echo "<h2>Zmiana hasła</h2>\n";
			echo "<form name=\"zmiana_hasla\" method=\"post\" action=\"baza.php\">
				Podaj nowe hasło:<input type=\"text\" name=\"nowe_haslo\" required><br/>
				<input type=\"submit\" value=\"Potwierdź\" style=\"margin-top: 10px\">
			</form>";  
		}
	}
?>