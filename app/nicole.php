<?php
$dbServerName = "sqlsrv-a.us-central1-a.c.it-228-sprint-2021.internal";
$dbUsername = "MyApp";
$dbPassword = "P@ssw0rd1";
$dbName = "back_end";

// create connection
$conn = new mysqli($dbServerName, $dbUsername, $dbPassword, $dbName);

// check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";

if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$sql = "INSERT INTO info (name, sarcastic_gloat, witticism)
VALUES ('Nicole', 'Real fresh', 'never argue with an idiot, they\'ll just bring you down to their level and beat you with experience.')";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
