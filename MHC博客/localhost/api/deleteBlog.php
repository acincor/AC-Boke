<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "Ls713568","mhc_inc");
if(isset($_POST['access_token']) && isset($_POST['id'])) {
    $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                exit(json_encode(["msg"=>"code expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            $file = mysqli_query($mysql,"select uid from blogs WHERE id = ".$_POST['id']);
            if(!is_bool($file)){
                $arr = mysqli_fetch_array($file,MYSQLI_ASSOC);
                if($array['uid'] == $arr['uid']){
                    $pic_urls = mysqli_query($mysql,"SELECT pic_urls FROM blogs WHERE id = ".$_POST['id']);
                    if(!is_bool($pic_urls)){
                        $pic_urls = json_decode(mysqli_fetch_array($pic_urls,MYSQLI_ASSOC)['pic_urls'],true);
                        for ($i = 0; $i < count($pic_urls); $i++) {
                             unlink(".".explode("http://localhost:8000/api",$pic_urls[$i]['pic'.$i])[1]);
                        }
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM likes WHERE id = ".$_POST['id']."");
                    while($arr = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM likes WHERE id = ".$_POST['id']."");
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM clikes WHERE id = ".$_POST['id']."");
                    while($arr = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM clikes WHERE id = ".$_POST['id']."");
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM qlikes WHERE id = ".$_POST['id']."");
                    while($arr = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM qlikes WHERE id = ".$_POST['id']."");
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM comments WHERE id = ".$_POST['id']."");
                    while($arr = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM comments WHERE id = ".$_POST['id']."");
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM quote WHERE id = ".$_POST['id']."");
                    while($arr = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM quote WHERE id = ".$_POST['id']."");
                    }
                    $delete_bool = mysqli_query($mysql,"DELETE FROM blogs WHERE id = ".$_POST['id']."");
                    exit(json_encode(["msg"=>$delete_bool]));
            } else {
                exit(json_encode(["error"=>"不能删除别人的博客"]));
            }
        }
    }
        }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
