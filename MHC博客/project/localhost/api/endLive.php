<?php
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
if(isset($_GET['name'])) {
    $sql = "DELETE FROM live WHERE uid = ".$_GET['name'];
    exit(["msg"=>mysqli_query($mysql, $sql)]);
}
