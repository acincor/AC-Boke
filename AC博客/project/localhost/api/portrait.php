<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "ac132452","ac_inc");
if(isset($_FILES['pic']) && isset($_POST['access_token'])) {
            $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
            if(!is_bool($query)) {
                $array = mysqli_fetch_assoc($query);
                if($array != NULL) {
                    if($array["seconds"]+$array["expires_in"] <= time()) {
                        mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                        exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
                    $fileType = $_FILES['pic']['type']; // 获取文件的MIME类型
                    if($fileType == 'image/png' || $fileType == 'image/jpeg' || $fileType == 'video/mp4'){
                        $sourcePath = $_FILES['pic']['tmp_name'];
                        $query = mysqli_query($mysql,"select portrait from users where uid = ".$array["uid"]);
                        if(!is_bool($query)){
                            $arr = mysqli_fetch_assoc($query);
                            if($arr != null) {
                                unlink(".".explode("https://mhcincapi.top/api",$arr["portrait"])[1]);
                                exit(json_encode(["msg"=>move_uploaded_file($_FILES["pic"]['tmp_name'], ".".explode("https://mhcincapi.top/api",$arr["portrait"])[1])],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                            }
                        }
                    }
                    }
                }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
