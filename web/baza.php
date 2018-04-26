<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<link rel="StyleSheet" href="style_baza2.css" type="text/css"/>
	<title>Strona główna</title>
</head>
<body>
	<div id="container">
		<header>
			<h1>System zarządzania skupami owoców</h1>
		</header>
			<nav>
<?php
	// ładowanie potrzebnych plików
	function __autoload($class_name) {
		include $class_name . '.php' ;
	}

	// zmienna zajmująca sie wyglądem strony
	$user = new Register;

	// przekierowanie w razie niezalogowania
	if ( !$user->_is_logged() )
		header("Location: index.php");
	
	// nawiązanie połączenia z baza danych
	$dbconn = new Connection;
	$dbconn->connect();

	// wygenerowanie menu
	$user->generate_menu();
	echo "</nav>";
	echo "<article>";

	// obsługa żądań post
	$user->get_post_request($dbconn);
	// zerwanie połączenia z bazą
    $dbconn->disconnect();
?>
		</article>
	</div>
</body>
</html>