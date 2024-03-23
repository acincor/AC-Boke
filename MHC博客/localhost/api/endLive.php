<?php
$mysql = mysqli_connect("localhost", "root", "Ls713568","mhc_inc");
if(isset($_GET['name'])) {
    $sql = "DELETE FROM live WHERE uid = ".$_GET['name'];
    exit(["msg"=>mysqli_query($mysql, $sql)]);
}