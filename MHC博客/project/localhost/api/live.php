<?php
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
if(isset($_GET['name'])) {
    $sql = "insert into live(uid) values (".$_GET['name'].");";
    exit(["msg"=>mysqli_query($mysql, $sql)]);
}
