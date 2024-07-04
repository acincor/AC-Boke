<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "mhc_inc", "Ls713568","mhc_inc");
if(isset($_POST['access_token']) && isset($_POST['to_uid'])) {
    $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            if ($array["uid"] != $_POST['to_uid']) {
            $query = mysqli_query($mysql,"select friend_list from users where uid = ".$array['uid']);
            if(!is_bool($query)) {
                $arr1 = mysqli_fetch_assoc($query);
                if($arr1 != NULL) {
                    $arr1["friend_list"] = json_decode($arr1["friend_list"],true);
                    $key = array_search(["uid"=>$_POST['to_uid']], $arr1["friend_list"]);
                    if ($key !== false) {
                        unset($arr1["friend_list"][$key]);
                        $sql = "update users set friend_list = '".json_encode($arr1["friend_list"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."' where uid = ".$array['uid'];
                        $query = mysqli_query($mysql,"select friend_list from users where uid = ".$_POST['to_uid']);
                        if(!is_bool($query)) {
                            $arr = mysqli_fetch_assoc($query);
                            if($arr != NULL) {
                                $arr["friend_list"] = json_decode($arr["friend_list"],true);
                                $key = array_search(["uid"=>$array['uid']], $arr["friend_list"]);
                                if ($key !== false) {
                                    unset($arr["friend_list"][$key]);
                                $sql2 = "update users set friend_list = '".json_encode($arr["friend_list"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."' where uid = ".$_POST['to_uid'];
                                exit(json_encode(["msg"=>mysqli_query($mysql,$sql) && mysqli_query($mysql,$sql2),"code"=>"delete"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                                    }
                            }
                            exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                        }
                        exit(json_encode($array,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    } else {
                    array_push($arr1["friend_list"],["uid"=>$_POST['to_uid']]);
                    $sql = "update users set friend_list = '".json_encode($arr1["friend_list"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."' where uid = ".$array['uid'];
                    $query = mysqli_query($mysql,"select friend_list from users where uid = ".$_POST['to_uid']);
                    if(!is_bool($query)) {
                        $arr = mysqli_fetch_assoc($query);
                        if($arr != NULL) {
                            $arr["friend_list"] = json_decode($arr["friend_list"],true);
                            array_push($arr["friend_list"],["uid"=>$array['uid']]);
                            $sql2 = "update users set friend_list = '".json_encode($arr["friend_list"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."' where uid = ".$_POST['to_uid'];
                            exit(json_encode(["msg"=>mysqli_query($mysql,$sql) && mysqli_query($mysql,$sql2),"code"=>"add"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                        }
                        exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
                    exit(json_encode($array,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                        }
                }
                }
                exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            } else {
                exit(json_encode(["error"=>"不能添加自己为好友！"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            exit(json_encode(["msg"=>"uid error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
