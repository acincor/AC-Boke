<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "Ls713568","mhc_inc");
if(isset($_POST['code'])) {
    $query = mysqli_query($mysql,"select access_token,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where code = '".$_POST['code']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE code = '".$_POST['code']."'");
                exit(json_encode(["msg"=>"code expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            $array["expires_in"] = 2678400;
            unset($array["seconds"]);
            exit(json_encode($array,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
