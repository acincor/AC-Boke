<?php
header('Content-Type:application/json; charset=utf-8');
    $mysql = mysqli_connect("192.168.31.128", "root", "Ls713568","mhc_inc");
    $sql = "create table if not exists users (".
    "uid BIGINT NOT NULL,".
    "portrait TEXT,".
    "user TEXT NOT NULL,".
    "password VARCHAR(1000) NOT NULL,".
    "friend_list VARCHAR(1000),".
    "primary key(uid)".
    ");";
    mysqli_query($mysql, $sql);
    $sql = "create table if not exists access_tokens (".
    "code VARCHAR(1000),".
    "uid BIGINT NOT NULL,".
    "access_token VARCHAR(190),".
    "expires_in BIGINT NOT NULL,".
    "createTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,".
    "primary key(access_token)".
    ");";
    mysqli_query($mysql, $sql);
    function hasSpecialCharacters($password) {
        $pattern = '/[!@#$%^&*()\-_=+{};:\'",.<>]/'; // 定义特殊字符的正则表达式模式
        
        if (preg_match($pattern,$password)) {
            return false; // 如果密码中有任何一个特殊字符，返回true
        } else {
            return true; // 没有特殊字符时返回false
        }
    }
    $str = explode(".","A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z");
    if(isset($_POST['user']) && isset($_POST['password'])) {
        if(hasSpecialCharacters($_POST['password'])) {
            if(strlen($_POST['password']) > 8 || strlen($_POST['password']) < 12) {
                $query = mysqli_query($mysql,"select * from users where user = '".$_POST['user']."'");
                if(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
                    exit(json_encode(["msg"=>"The account of user existed"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
        $uid = "";
        for($i=0;$i<12;$i++) {
            $uid .= rand(1,9);
        }
        $query = mysqli_query($mysql,"select * from users where uid = ".$uid);
        while(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
            for($i=0;$i<12;$i++) {
                $uid .= rand(1,9);
            }
        }
        $png = file_get_contents("./mhc.png");
        if(!file_exists('./'.$uid)) {
            mkdir('./'.$uid);
            chmod('./'.$uid,0777);
        }
        if(!file_exists('./'.$uid."/portrait/")) {
            mkdir('./'.$uid."/portrait/");
            chmod('./'.$uid."/portrait/",0777);
        }
        file_put_contents('./'.$uid."/portrait/portrait.png",$png);
        chmod('./'.$uid."/portrait/portrait.png",0777);
        $sql = "insert into users(uid, friend_list, portrait, user, password) values (".$uid.", '[]', '".'http://192.168.31.128/api/'.$uid."/portrait/portrait.png"."', '".$_POST['user']."', '".password_hash($_POST['password'], PASSWORD_DEFAULT)."');";
        mysqli_query($mysql, $sql);
        //生成code
        $code = "";
        for($i=0;$i<20;$i++) {
            $code .= $str[rand(0,51)];
        }
        $query = mysqli_query($mysql,"select * from access_tokens where code = '".$code."'");
        while(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
            for($i=0;$i<20;$i++) {
                $code .= $str[rand(0,51)];
            }
        }
        $access_token = "";
        for($i=0;$i<20;$i++) {
            $access_token .= $str[rand(0,51)];
        }
        $query = mysqli_query($mysql,"select * from access_tokens where access_token = '".$access_token."'");
        while(is_bool($query) ? true : mysqli_fetch_array($query) != null) {
            for($i=0;$i<20;$i++) {
                $access_token .= $str[rand(0,51)];
            }
        }
                $sql = "insert into access_tokens(uid, access_token, code, expires_in) values (".$uid.", '".$access_token."', '".$code."', 2678400);";
                mysqli_query($mysql, $sql);
        exit(json_encode(["code"=>$code],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
            exit(json_encode(["msg"=>"The counts of password are too big or they are too small!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
        exit(json_encode(["msg"=>"password error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }
    exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
