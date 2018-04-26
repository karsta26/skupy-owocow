<!DOCTYPE HTML>
<html>
	<head>
		<meta charset="utf-8">
		<title>Logowanie</title>
		<link rel="StyleSheet" href="style_baza2.css" type="text/css"/>
	</head>
	<body>
		<fieldset style="width: 300px; padding: 10px">
			<legend>Logowanie</legend>
			<form name="log" method="post" action="index.php">
				Podaj login:<input type="text" name="login"><br/>
				Podaj hasło:<input type="text" name="pass" style="margin-top: 5px;"><br/>
				<input type="submit" value="ZALOGUJ" style="margin-top: 10px">
			</form>   
			<br/>
			<form method="post" action="rejestracja.php">
    			<input type="submit" name="rejestracja" value="Nowy właściciel">
			</form>
		</fieldset>
		
<?php
	// ładowanie potrzebnych plików
	function __autoload($class_name) {
		include $class_name . '.php';
	}

	// zmienna zajmująca sie wyglądem strony
	$user = new Register;

	// obsługa żądania zalogowania
	if($_SERVER['REQUEST_METHOD'] == "POST" and isset($_POST['login']))
	{
	    echo $user->_login();
	}

	// obsługa żądania wylogowania
	if($_SERVER['REQUEST_METHOD'] == "POST" and isset($_POST['logout']))
	{
	    $user->_logout();
	}

	// obsługa żądania dodania nowego właściciela do bazy
	if($_SERVER['REQUEST_METHOD'] == "POST" and isset($_POST['login_rej']) and isset($_POST['pass_rej']))
	{
	    $user->_add_user();
	    echo '<h1 style="color: red">Właściciel dodany!</h1>';
	}

	// przekierowanie w razie zalogowania i wyświetlenie przykładowych danych do logowania
	if ( !$user->_is_logged() )
	{  
		echo "<br/>";
		echo "<h3>Przykładowe dane do logowania:</h3>";
		echo "<table style=\"margin-left: 10px; margin-top:10px;\">
			<thead>
				<tr><td></td><th>Właściciel</th><th>Właściciel</th><th>Dostawca</th><th>Dostawca</th></tr>
			</thead>
			<tbody>
				<tr><th>login</th><td>admin</td><td>admin2</td><td>Ewa</td><td>Dariusz</td></tr>
				<tr><th>hasło</th><td>admin</td><td>admin2</td><td>Baran</td><td>Wilk</td></tr>
			</tbody>
		</table>";
	} 
	else
	{
		header("Location: baza.php");
	}
?>
	</body>
</html>
