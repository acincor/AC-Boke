<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
if(isset($_POST['access_token'])) {
    $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            $query = mysqli_query($mysql,"select friend_list from users where uid = ".$array['uid']);
            $arr0 = [];
            if(!is_bool($query)) {
                $arr1 = mysqli_fetch_assoc($query);
                if($arr1 != NULL) {
                    $arr1['friend_list'] = json_decode($arr1['friend_list'],true);
                    for($i = 0; $i < count($arr1['friend_list']); $i ++) {
                        $query = mysqli_query($mysql,"select user,portrait,uid from users where uid = ".$arr1['friend_list'][$i]['uid']);
                        if(!is_bool($query)) {
                            $arr = mysqli_fetch_assoc($query);
                            if($arr != NULL) {
                                array_push($arr0,$arr);
                            } else {
                                unset($arr1['friend_list'][$i]);
                                mysqli_query($mysql,"update users set friend_list = '".json_encode($arr1['friend_list'],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."' where uid = ".$array["uid"]);
                            }
                        } else {
                            unset($arr1['friend_list'][$i]);
                            mysqli_query($mysql,"update users set friend_list = '".json_encode($arr1['friend_list'],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."' where uid = ".$array["uid"]);
                        }
                    }
                    exit(json_encode($arr0,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
                exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            exit(json_encode(["msg"=>"uid error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
