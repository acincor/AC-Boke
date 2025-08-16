<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "123456","ac_inc");
$sql = "create table if not exists live (".
"uid BIGINT NOT NULL,".
"createTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,".
"primary key(uid)".
");";
mysqli_query($mysql, $sql);
if(isset($_GET['access_token'])) {
    $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_GET['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_GET['access_token']."'");
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            $arr = [];
            $query = mysqli_query($mysql,"select * from live where TIMESTAMPDIFF(HOUR, createTime, NOW()) < 24"." ORDER BY createTime DESC");
            while($blog = mysqli_fetch_assoc($query)) {
                $q = mysqli_query($mysql,"select user,portrait from users where uid = ".$blog['uid']);
                if(!is_bool($q)) {
                    $array = mysqli_fetch_assoc($q);
                    if($array != NULL) {
                        $blog['user'] = $array['user'];
                        $blog['portrait'] = $array['portrait'];
                        $blog['uid'] = intval($blog['uid']);
                        unset($blog['createTime']);
                        array_push($arr,$blog);
                    }
                }
            }
            exit(json_encode($arr,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
