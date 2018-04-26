<?php
	// klasa zajmująca się dostępem do bazy danych
	class Connection {
		private $dbconn;
		// nawiązanie połączenia z bazą
		function connect()
		{
			$this->dbconn = pg_connect(getenv("DATABASE_URL"))
	    		or die('Nie można nawiązać połączenia: ' . pg_last_error());
		}

		// genruje tabelę z danych zwróconych przez bazę z zapytania query
		function generate_table($query)
    	{
	    	$result = pg_query($query) or die('Nieprawidłowe zapytanie: ' . pg_last_error()); 
			echo "\n<br/><br/>\n";
			$arrayTmp =  pg_fetch_row ($result , 0);
			if(count($arrayTmp) == 1)
			{
				echo "<h2>Brak rekordów do wyświetlenia</h2>";
			}
			else
			{
				echo "<table>\n";
				echo "<thead>";
				echo "<tr>";
				for ($i = 0; $i < count($arrayTmp); $i++) {
		    		echo "<th>" . pg_field_name($result, $i) . "</th>";
				}
				echo "</tr>";
				echo "</thead>";
				echo "<tbody>";
				while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
				    echo "\t<tr>\n";
				    foreach ($line as $col_value) {
				        echo "\t\t<td>$col_value</td>\n";
				    }
				    echo "\t</tr>\n";
				}
				echo "</tbody>";
				echo "</table>";
			}
			
			pg_free_result($result);   
    	}

    	// wykonanie polecenia query w bazie danych np. wywołanie funkcji w bazie
    	function perform_query($query) 
	    {
			$result = pg_query($query) or die('Nieprawidłowe zapytanie: ' . pg_last_error()); 
			$arrayTmp =  pg_fetch_row($result);
			pg_free_result($result); 
			return $arrayTmp;
	    }

	    // generuje pole wyboru select dla danego zapytania query
	    function generate_select($name, $query) 
	    {
			$result = pg_query($query) or die('Nieprawidłowe zapytanie: ' . pg_last_error()); 
			$arrayTmp =  pg_fetch_row ($result , 0);
			echo "<select name=\"$name\" style=\"margin-top: 10px\">\n";
			while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
			    echo "\t<option ";
			    foreach ($line as $col_value) {
			        echo "value=\"$col_value\">$col_value";
			    }
			    echo "\t</option>\n";
			}
			echo "</select>";
			pg_free_result($result);   
	    }

	    // zamyka połączenie z bazą danych
    	function disconnect() 
    	{
    		pg_close($this->dbconn);
    	}
	}
?>