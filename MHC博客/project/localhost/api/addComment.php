<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
date_default_timezone_set("Etc/GMT-8");
function mobile_type()
{
        $user_agent = $_SERVER['HTTP_USER_AGENT'];
        if (stripos($user_agent, "iPhone")!==false) {
            $brand = 'iPhone';
        } else if (stripos($user_agent, "SAMSUNG")!==false || stripos($user_agent, "Galaxy")!==false || strpos($user_agent, "GT-")!==false || strpos($user_agent, "SCH-")!==false || strpos($user_agent, "SM-")!==false) {
            $brand = '三星';
        } else if (stripos($user_agent, "Huawei")!==false || stripos($user_agent, "Honor")!==false || stripos($user_agent, "H60-")!==false || stripos($user_agent, "H30-")!==false) {
            $brand = '华为';
        } else if (stripos($user_agent, "Lenovo")!==false) {
            $brand = '联想';
        } else if (strpos($user_agent, "MI-ONE")!==false || strpos($user_agent, "MI 1S")!==false || strpos($user_agent, "MI 2")!==false || strpos($user_agent, "MI 3")!==false || strpos($user_agent, "MI 4")!==false || strpos($user_agent, "MI-4")!==false) {
            $brand = '小米';
        } else if (strpos($user_agent, "HM NOTE")!==false || strpos($user_agent, "HM201")!==false) {
            $brand = '红米';
        } else if (stripos($user_agent, "Coolpad")!==false || strpos($user_agent, "8190Q")!==false || strpos($user_agent, "5910")!==false) {
            $brand = '酷派';
        } else if (stripos($user_agent, "ZTE")!==false || stripos($user_agent, "X9180")!==false || stripos($user_agent, "N9180")!==false || stripos($user_agent, "U9180")!==false) {
            $brand = '中兴';
        } else if (stripos($user_agent, "OPPO")!==false || strpos($user_agent, "X9007")!==false || strpos($user_agent, "X907")!==false || strpos($user_agent, "X909")!==false || strpos($user_agent, "R831S")!==false || strpos($user_agent, "R827T")!==false || strpos($user_agent, "R821T")!==false || strpos($user_agent, "R811")!==false || strpos($user_agent, "R2017")!==false) {
            $brand = 'OPPO';
        } else if (strpos($user_agent, "HTC")!==false || stripos($user_agent, "Desire")!==false) {
            $brand = 'HTC';
        } else if (stripos($user_agent, "vivo")!==false) {
            $brand = 'vivo';
        } else if (stripos($user_agent, "K-Touch")!==false) {
            $brand = '天语';
        } else if (stripos($user_agent, "Nubia")!==false || stripos($user_agent, "NX50")!==false || stripos($user_agent, "NX40")!==false) {
            $brand = '努比亚';
        } else if (strpos($user_agent, "M045")!==false || strpos($user_agent, "M032")!==false || strpos($user_agent, "M355")!==false) {
            $brand = '魅族';
        } else if (stripos($user_agent, "DOOV")!==false) {
            $brand = '朵唯';
        } else if (stripos($user_agent, "GFIVE")!==false) {
            $brand = '基伍';
        } else if (stripos($user_agent, "Gionee")!==false || strpos($user_agent, "GN")!==false) {
            $brand = '金立';
        } else if (stripos($user_agent, "HS-U")!==false || stripos($user_agent, "HS-E")!==false) {
            $brand = '海信';
        } else if (stripos($user_agent, "Nokia")!==false) {
            $brand = '诺基亚';
        } else {
            $brand = '其他手机';
        }
        return $brand;
}
if(isset($_POST['access_token']) && isset($_POST['comment']) && isset($_POST['id'])) {
            $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
    $query = mysqli_query($mysql,"select uid from users where uid = ".$array['uid']);
    $sql2 = "";
    $sql = "";
    if(!is_bool($query)) {
        $assoc = mysqli_fetch_assoc($query);
        if($assoc != null) {
            $data = ['comment_uid'=>$assoc['uid']];
            $id = "";
            if(!isset($_POST["comment_id"])) {
            for($i=0;$i<12;$i++) {
                $id .= rand(1,9);
            }
            $query = mysqli_query($mysql,"select * from comments where comment_id = ".$id);
            while(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
                for($i=0;$i<12;$i++) {
                    $id .= rand(1,9);
                }
            }
            $data['comment_id'] = $id;
            $sql = "insert into comments(id, comment_uid, comment_id, create_at, comment, like_count, comment_count, source) values (".$_POST['id'].", ".$data['comment_uid'].", ".$data['comment_id'].", '".date("Y-m-d H:i:s")."', '".$_POST["comment"]."', 0, 0, '".mobile_type()."');";
            $query = mysqli_query($mysql,"select comment_count from blogs where id = ".$_POST['id']);
            if(!is_bool($query)) {
                $assoc = mysqli_fetch_assoc($query);
                if($assoc != null) {
                    $sql2 = "update blogs set comment_count = ".json_encode(intval($assoc['comment_count'])+1)." where id = ".$_POST['id'];
                } else {
                    exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
            } else {
                exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            } else {
                for($i=0;$i<12;$i++) {
                    $id .= rand(1,9);
                }
                $query = mysqli_query($mysql,"select * from quote where quote_id = ".$id);
                while(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
                    for($i=0;$i<12;$i++) {
                        $id .= rand(1,9);
                    }
                }
                $data['quote_id'] = $id;
                $sql = "insert into quote(id, comment_uid, quote_id, comment_id, create_at, comment, like_count, comment_count, source) values (".$_POST['id'].", ".$data['comment_uid'].", ".$data['quote_id'].", ".$_POST["comment_id"].", '".date("Y-m-d H:i:s")."', '".$_POST["comment"]."', 0, 0, '".mobile_type()."');";
                $query = mysqli_query($mysql,"select comment_count from comments where comment_id = ".$_POST['comment_id']);
                if(!is_bool($query)) {
                    $assoc = mysqli_fetch_assoc($query);
                    if($assoc != null) {
                        $sql2 = "update comments set comment_count = ".json_encode(intval($assoc['comment_count'])+1)." where comment_id = ".$_POST['comment_id'];
                    } else {
                        exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
                } else {
                    exit(json_encode(["error"=>"blog error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
            }
            exit(json_encode(["msg"=>mysqli_query($mysql, $sql) && mysqli_query($mysql, $sql2)],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
