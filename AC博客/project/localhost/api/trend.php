<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "ac132452","ac_inc");
$sql = "create table if not exists trends (".
"uid BIGINT NOT NULL,".
"trend VARCHAR(190) NOT NULL,".
"createTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,".
"primary key(trend)".
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
    if(isset($_GET['trend'])) {
        if($_GET['trend'] != null) {
    $query = mysqli_query($mysql,"select * from trends where trend = '".$_GET['trend']."'");
    if(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
        exit(json_encode(["error"=>"trend exists!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }
    $sql = "insert into trends(uid, trend) values (".$array["uid"].", '".$_GET['trend']."');";
    exit(json_encode(["msg"=>mysqli_query($mysql, $sql)],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
        }
            $query = mysqli_query($mysql,"select * from trends where TIMESTAMPDIFF(HOUR, createTime, NOW()) < 24 ORDER BY createTime DESC");
            $some = [];
            while($arr = mysqli_fetch_assoc($query)) {
                $some[] = $arr["trend"];
            }
            exit(json_encode($some,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
}
    }
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
