<?php
$mysql = mysqli_connect("localhost", "root", "ac132452","ac_inc");
if(isset($_GET['name'])) {
    $sql = "insert into live(uid) values (".$_GET['name'].");";
    exit(json_encode(["msg"=>mysqli_query($mysql, $sql)]));
}
header('HTTP/1.1 403 Forbidden');
exit(json_encode(["msg"=>"name无效"]));
