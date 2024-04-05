<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
if(isset($_POST['access_token'])) {
    $query = mysqli_query($mysql,"select uid from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            $select_bool = mysqli_query($mysql,"SELECT * FROM access_tokens WHERE uid = ".$array['uid']);
            while($arr = mysqli_fetch_assoc($select_bool)) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE uid = ".$array['uid']);
            }
            $file = mysqli_query($mysql,"select id from blogs WHERE uid = ".$array['uid']);
            while($arr = mysqli_fetch_assoc($file)){
                    $pic_urls = mysqli_query($mysql,"SELECT pic_urls FROM blogs WHERE id = ".$arr['id']);
                    if(!is_bool($pic_urls)){
                        $pic_urls = json_decode(mysqli_fetch_array($pic_urls,MYSQLI_ASSOC)['pic_urls'],true);
                        for ($i = 0; $i < count($pic_urls); $i++) {
                             unlink(".".explode("http://192.168.31.128/api",$pic_urls[$i]['pic'.$i])[1]);
                        }
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM likes WHERE id = ".$arr['id']);
                    while($arr0 = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM likes WHERE id = ".$arr['id']);
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM clikes WHERE id = ".$arr['id']);
                    while($arr0 = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM clikes WHERE id = ".$arr['id']);
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM qlikes WHERE id = ".$arr['id']);
                    while($arr0 = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM qlikes WHERE id = ".$arr['id']);
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM comments WHERE id = ".$arr['id']);
                    while($arr0 = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM comments WHERE id = ".$arr['id']);
                    }
                    $select_bool = mysqli_query($mysql,"SELECT * FROM quote WHERE id = ".$arr['id']);
                    while($arr0 = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM quote WHERE id = ".$arr['id']);
                    }
                    $delete_bool = mysqli_query($mysql,"DELETE FROM blogs WHERE id = ".$arr['id']);
        }
            $select_bool = mysqli_query($mysql,"SELECT * FROM trends WHERE uid = ".$array['uid']);
            while($arr0 = mysqli_fetch_assoc($select_bool)) {
                mysqli_query($mysql,"DELETE FROM trends WHERE uid = ".$array['uid']);
            }
        $select_bool = mysqli_query($mysql,"SELECT * FROM users WHERE uid = ".$array['uid']);
            if(!is_bool($select_bool)) {
                $arr = mysqli_fetch_assoc($select_bool);
                if($arr != NULL) {
                    if(file_exists(".".explode("http://192.168.31.128/api",$arr['portrait'])[1])) {
                        unlink(".".explode("http://192.168.31.128/api",$arr['portrait'])[1]);
                    }
                    if(is_dir("./".$array["uid"]."/portrait")) {
                        rmdir("./".$array["uid"]."/portrait");
                    }
                    if(is_dir("./".$array["uid"])) {
                        rmdir("./".$array["uid"]);
                    }
                }
            }
        exit(json_encode(["msg"=>intval(mysqli_query($mysql,"DELETE FROM users WHERE uid = '".$array['uid']."'"))],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    } else {
        exit(json_encode(["msg"=>1],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }
        } else {
            exit(json_encode(["msg"=>1],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
