<?php
if(isset($_GET['name'])) {
    $sql = "insert into live(uid) values (".$_GET['name'].");";
    exit(["msg"=>mysqli_query($mysql, $sql)]);
}
