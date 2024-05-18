<?php
$mysql = mysqli_connect("localhost", "root", "Ls713568","mhc_inc");
if(isset($_GET['name'])) {
    $sql = "insert into live(uid) values (".$_GET['name'].");";
    exit(json_encode(["msg"=>mysqli_query($mysql, $sql)]));
}
