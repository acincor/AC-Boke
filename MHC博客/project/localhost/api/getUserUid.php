<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "mhc_inc", "Ls713568","mhc_inc");
        if($_POST["uid"] != NULL) {
            $query = mysqli_query($mysql,"select * from users where uid = ".$_POST['uid']);
            if(!is_bool($query)) {
                $array = mysqli_fetch_assoc($query);
                if($array != NULL) {
                    unset($array["password"]);
                    exit(json_encode($array,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
                exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            exit(json_encode(["msg"=>"uid error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
