<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
if(isset($_POST['access_token'])) {
    $query = mysqli_query($mysql,"select * from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
            exit(json_encode(["msg"=>mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'")],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
        exit(json_encode(["msg"=>1],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
