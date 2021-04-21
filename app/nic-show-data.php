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

$sql = "SELECT name, sarcastic_gloat, witticism FROM info";
$result = $conn->query($sql);
echo "<br> <br> <u>Results:</u> <br>";
if ($result->num_rows > 0) {
   while($row = $result->fetch_assoc()) {
   echo "<br> name: " . $row["name"]. " - witticism: " . $row["witticism"]. " - sarcastic gloat: " . $row["sarcastic_gloat"]. "<br>";
   }
} else {
   echo "0 results";
}

$conn->close();
?>
