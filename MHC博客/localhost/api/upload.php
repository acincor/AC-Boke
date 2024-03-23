<?php
header('Content-Type:application/json; charset=utf-8');
date_default_timezone_set("Etc/GMT-8");
$mysql = mysqli_connect("localhost", "root", "Ls713568","mhc_inc");
$sql = "create table if not exists blogs (".
"uid BIGINT NOT NULL,".
"id BIGINT NOT NULL,".
"pic_urls TEXT,".
"pic_count INTEGER NOT NULL,".
"have_pic INTEGER NOT NULL,".
"create_at TEXT,".
"status TEXT,".
"comment_count INTEGER NOT NULL,".
"like_count INTEGER NOT NULL,".
"source TEXT,".
"createTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,".
"primary key(id)".
");";
mysqli_query($mysql, $sql);
$sql = "create table if not exists comments (".
"comment_uid BIGINT NOT NULL,".
"comment_id BIGINT NOT NULL,".
"comment TEXT,".
"like_count INTEGER NOT NULL,".
"comment_count INTEGER NOT NULL,".
"id BIGINT NOT NULL,".
"create_at TEXT,".
"source TEXT,".
"primary key(comment_id)".
");";
mysqli_query($mysql, $sql);
$sql = "create table if not exists quote (".
"comment_uid BIGINT NOT NULL,".
"comment_id BIGINT NOT NULL,".
"comment TEXT,".
"like_count INTEGER NOT NULL,".
"comment_count INTEGER NOT NULL,".
"quote_id BIGINT NOT NULL,".
"id BIGINT NOT NULL,".
"create_at TEXT,".
"source TEXT,".
"primary key(quote_id)".
");";
mysqli_query($mysql, $sql);
$sql = "create table if not exists likes (".
"like_uid BIGINT NOT NULL,".
"id BIGINT NOT NULL,".
"create_at TEXT,".
"source TEXT".
");";
mysqli_query($mysql, $sql);
$sql = "create table if not exists clikes (".
"like_uid BIGINT NOT NULL,".
"comment_id BIGINT NOT NULL,".
"id BIGINT NOT NULL,".
"create_at TEXT,".
"source TEXT".
");";
mysqli_query($mysql, $sql);
$sql = "create table if not exists qlikes (".
"like_uid BIGINT NOT NULL,".
"quote_id BIGINT NOT NULL,".
"comment_id BIGINT NOT NULL,".
"id BIGINT NOT NULL,".
"create_at TEXT,".
"source TEXT".
");";
mysqli_query($mysql, $sql);
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
if(isset($_POST['access_token']) && isset($_POST['status'])) {
            $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
    if(!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if($array != NULL) {
            if($array["seconds"]+$array["expires_in"] <= time()) {
                mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
    $query = mysqli_query($mysql,"select uid from users where uid = ".$array['uid']);
    if(!is_bool($query)) {
        $assoc = mysqli_fetch_assoc($query);
        if($assoc != null) {
            $data = ['uid'=>$assoc['uid']];
            $id = "";
            for($i=0;$i<12;$i++) {
                $id .= rand(1,9);
            }
            $query = mysqli_query($mysql,"select * from blogs where id = ".$id);
            while(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
                for($i=0;$i<12;$i++) {
                    $id .= rand(1,9);
                }
            }
            $data['id'] = $id;
            $pic_urls = [];
            $index = 0;
            while(isset($_FILES["pic".$index])) {
                if(isset($_FILES['pic'.$index]) && $_FILES['pic'.$index]['error'] === UPLOAD_ERR_OK) {
                    $fileType = $_FILES['pic'.$index]['type']; // 获取文件的MIME类型
                    
                    if($fileType == 'image/png' || $fileType == 'image/jpeg' || $fileType == 'video/mp4'){
                        $sourcePath = $_FILES['pic'.$index]['tmp_name']; // 获取临时存放位置的源文件路径
                        $fd = "";
                        for($i=0;$i<12;$i++) {
                            $fd .= rand(1,9);
                        }
                        $targetPath = './'.$data['uid']."/".$fd.".".explode('/',$fileType)[1]; // 设置要保存的目标路径及文件名
                        while(file_exists($targetPath)) {
                            for($i=0;$i<12;$i++) {
                                $fd .= rand(1,9);
                                $targetPath = './'.$data['uid']."/".$fd.".".explode('/',$fileType)[1];
                            }
                        }
                        if (move_uploaded_file($sourcePath, $targetPath)) {
                            array_push($pic_urls,['pic'.$index=>'http://localhost:8000/api/'.$data['uid']."/".$fd.".".explode('/',$fileType)[1]]);
                            $index++;
                        } else {
                            exit(json_encode(['error'=>"the file of upload emerged fatal error when it moved"]));
                        }
                    } else {
                        exit(json_encode(['error'=>"the type of file was error."]));
                    }
                } else {
                    exit(json_encode(['error'=>"Upload failed."]));
                }
            }
            $sql = "insert into blogs(uid, id, pic_urls, pic_count, have_pic, create_at, status, like_count, comment_count, source) values (".$data['uid'].", ".$data['id'].", '".json_encode($pic_urls,JSON_UNESCAPED_SLASHES)."', ".($pic_urls != [] ? $index : "0").", ".($pic_urls != [] ? 1 : "0").", '".date("Y-m-d H:i:s")."', '".$_POST["status"]."', 0, 0, '".mobile_type()."');";
            exit(json_encode(["msg"=>mysqli_query($mysql, $sql)],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
