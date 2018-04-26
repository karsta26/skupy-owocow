<!DOCTYPE HTML>
<html>
	<head>
		<meta charset="utf-8">
		<title>Logowanie</title>
		<link rel="StyleSheet" href="style_baza2.css" type="text/css"/>
	</head>
	<body>
		<fieldset style="width: 300px; padding: 10px">
			<legend>Rejestracja</legend>
			<form method="post" action="index.php">
				Podaj login:<input type="text" name="login_rej"><br/>
				Podaj hasło:<input type="text" name="pass_rej" style="margin-top: 5px;"><br/>
				<input type="submit" value="Zarejestruj" style="margin-top: 10px">
			</form>   
			<br/>
			<a href="index.php">Cofnij</a>
		</fieldset>
		
<?php
	include 'Register.php';
	$user = new Register;

	// przekierowanie w razie zalogowania
	if ( $user->_is_logged() )
		header("Location: baza.php");
?>
	</body>
</html>
