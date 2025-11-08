<?php
header('Access-Control-Allow-Origin:*');
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "123456","ac_inc");
$str = explode(".","A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z");
if(isset($_POST['uid']) && isset($_POST['password'])) {
    $query = mysqli_query($mysql,"select password from users where uid = ".$_POST['uid']);
    if(!is_bool($query)) {
        $array = mysqli_fetch_array($query);
        if($array != null) {
    if(password_verify($_POST['password'],$array['password'])) {
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
            $sql = "insert into access_tokens(uid, access_token, code, expires_in) values (".$_POST['uid'].", '".$access_token."', '".$code."', 2678400);";
            mysqli_query($mysql, $sql);
    exit(json_encode(["code"=>$code],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
            }
        exit(json_encode(["msg"=>"uid error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    exit(json_encode(["msg"=>"password error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
