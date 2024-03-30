<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "Ls713568","mhc_inc");
if(isset($_GET['access_token']) && isset($_GET['trend'])) {
    $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_GET['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_GET['access_token']."'");
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
    $query = mysqli_query($mysql,"select * from trends where trend = '".$_GET['trend']."'");
    if(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
        $sql = "delete from trends where trend = '".$_GET['trend']."';";
        exit(json_encode(["msg"=>mysqli_query($mysql, $sql)],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }
            exit(json_encode(["error"=>"trend did not exist!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
}
    }
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
