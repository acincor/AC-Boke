<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "mhc_inc", "Ls713568","mhc_inc");
function hasSpecialCharacters($password) {
    $pattern = '/[!@#$%^&*()\_=+{};:\'",.<>]/'; // 定义特殊字符的正则表达式模式
    
    if (preg_match($pattern,$password)) {
        return false; // 如果密码中有任何一个特殊字符，返回true
    } else {
        return true; // 没有特殊字符时返回false
    }
}
$str = explode(".","A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z");
if(isset($_POST['rename']) && isset($_POST['access_token'])) {
    if(hasSpecialCharacters($_POST['rename'])) {
        if(strlen($_POST['rename']) > 0 && strlen($_POST['rename']) <= 20) {
            $query = mysqli_query($mysql,"select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '".$_POST['access_token']."'");
            if(!is_bool($query)) {
                $array = mysqli_fetch_assoc($query);
                if($array != NULL) {
                    if($array["seconds"]+$array["expires_in"] <= time()) {
                        mysqli_query($mysql,"DELETE FROM access_tokens WHERE access_token = '".$_POST['access_token']."'");
                        exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
    $query = mysqli_query($mysql,"update users set user = '".$_POST['rename']."' where uid = ".$array["uid"]);
                    exit(json_encode(["msg"=>$query],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
                }
            }
        exit(json_encode(["msg"=>"The counts of password are too big or they are too small!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }
    exit(json_encode(["msg"=>"password error"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
