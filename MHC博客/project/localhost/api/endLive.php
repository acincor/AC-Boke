<?php
$mysql = mysqli_connect("localhost", "mhc_inc", "Ls713568","mhc_inc");
if(isset($_GET['name'])) {
    $sql = "DELETE FROM live WHERE uid = ".$_GET['name'];
    exit(json_encode(["msg"=>mysqli_query($mysql, $sql)]));
}
