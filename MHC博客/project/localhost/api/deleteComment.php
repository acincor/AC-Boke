<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
if(isset($_POST['access_token']) && isset($_POST['comment_id'])) {
    $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                exit(json_encode(["msg"=>"code expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            if(isset($_POST["to_comment_id"])) {
            $file = mysqli_query($mysql,"select comment_uid from quote WHERE quote_id = ".$_POST['comment_id']);
            if(!is_bool($file)){
                $arr = mysqli_fetch_array($file,MYSQLI_ASSOC);
                if($array['uid'] == $arr['comment_uid']){
                    $select_bool = mysqli_query($mysql,"SELECT * FROM qlikes WHERE quote_id = ".$_POST['comment_id']."");
                    while($arr = mysqli_fetch_assoc($select_bool)) {
                        mysqli_query($mysql,"DELETE FROM qlikes WHERE quote_id = ".$_POST['comment_id']."");
                        }
                    $delete_bool = mysqli_query($mysql,"DELETE FROM quote WHERE quote_id = ".$_POST['comment_id']);
                    $query = mysqli_query($mysql,"select comment_count from comments where comment_id = ".$_POST["to_comment_id"]);
                    if(!is_bool($query)) {
                        $assoc = mysqli_fetch_assoc($query);
                        if($assoc != null) {
                            exit(json_encode(["msg"=>$delete_bool && mysqli_query($mysql,"UPDATE comments set comment_count = ".json_encode(intval($assoc["comment_count"])-1)." WHERE comment_id = ".$_POST['to_comment_id']."")]));
                        } else {
                            exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                        }
                    } else {
                        exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
            }
        }
                } else {
                    $file = mysqli_query($mysql,"select comment_uid from comments WHERE comment_id = ".$_POST['comment_id']);
                    if(!is_bool($file)){
                        $arr = mysqli_fetch_array($file,MYSQLI_ASSOC);
                        if($array['uid'] == $arr['comment_uid']){
                            $select_bool = mysqli_query($mysql,"SELECT * FROM qlikes WHERE comment_id = ".$_POST['comment_id']."");
                            while($arr = mysqli_fetch_assoc($select_bool)) {
                                mysqli_query($mysql,"DELETE FROM qlikes WHERE comment_id = ".$_POST['comment_id']."");
                                }
                            $select_bool = mysqli_query($mysql,"SELECT * FROM clikes WHERE comment_id = ".$_POST['comment_id']."");
                            while($arr = mysqli_fetch_assoc($select_bool)) {
                                mysqli_query($mysql,"DELETE FROM clikes WHERE comment_id = ".$_POST['comment_id']."");
                                }
                            $select_bool = mysqli_query($mysql,"SELECT * FROM quote WHERE comment_id = ".$_POST['comment_id']."");
                            while($arr = mysqli_fetch_assoc($select_bool)) {
                                mysqli_query($mysql,"DELETE FROM quote WHERE comment_id = ".$_POST['comment_id']."");
                                }
                            $delete_bool = mysqli_query($mysql,"DELETE FROM comments WHERE comment_id = ".$_POST['comment_id']."");
                            $query = mysqli_query($mysql,"select comment_count from blogs where id = ".$_POST["id"]);
                            if(!is_bool($query)) {
                                $assoc = mysqli_fetch_assoc($query);
                                if($assoc != null) {
                                    exit(json_encode(["msg"=>$delete_bool && mysqli_query($mysql,"UPDATE blogs set comment_count = ".json_encode(intval($assoc["comment_count"])-1)." WHERE id = ".$_POST['id']."")]));
                                } else {
                                    exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                                }
                            } else {
                                exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                            }
                    }
                }
                }
    }
        }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
