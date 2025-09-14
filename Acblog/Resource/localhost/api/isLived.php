<?php
$mysql = mysqli_connect("localhost", "root", "123456","ac_inc");
if(isset($_POST['access_token'])) {
    $query = mysqli_query($mysql, "select uid,UNIX_TIMESTAMP(createTime) AS seconds,expires_in from access_tokens where access_token = '" . $_POST['access_token'] . "'");
    if (!is_bool($query)) {
        $array = mysqli_fetch_assoc($query);
        if ($array != NULL) {
            $sql = "select * from live where uid = " . $array['uid'] . ";";
            exit(json_encode(["msg" => mysqli_fetch_assoc(mysqli_query($mysql, $sql)) != null]));
        }
    }
}
exit(json_encode(["error"=>"params error!"]));
