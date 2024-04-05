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
                exit(json_encode(["msg"=>"access_token expired!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
            }
            $arr = [];
            $query = mysqli_query($mysql,"select * from blogs where id = ".$_POST['id']);
            if(!is_bool($query)) {
            $blog = mysqli_fetch_assoc($query);
                if($blog != NULL) {
                $q = mysqli_query($mysql,"select user,portrait from users where uid = ".$blog['uid']);
                if(!is_bool($q)) {
                    $array = mysqli_fetch_assoc($q);
                    if($array != NULL) {
                        $blog['user'] = $array['user'];
                        $blog['portrait'] = $array['portrait'];
                        $blog['have_pic'] = intval($blog['have_pic']);
                        $blog['pic_urls'] = json_decode($blog['pic_urls'],true);
                        $blog['uid'] = intval($blog['uid']);
                        $blog['id'] = intval($blog['id']);
                        $blog['pic_count'] = intval($blog['pic_count']);
                        $cq = mysqli_query($mysql,"select * from comments where id = ".$blog['id']);
                        $blog["comment_list"] = [];
                        $blog["like_list"] = [];
                        $lq = mysqli_query($mysql,"select * from likes where id = ".$blog['id']);
                        while($like = mysqli_fetch_assoc($lq)) {
                            $like['id'] = intval($like['id']);
                            $mess = mysqli_query($mysql,"select user,portrait from users where uid = ".$like['like_uid']);
                            if(!is_bool($mess)) {
                                $m = mysqli_fetch_assoc($mess);
                                if($m != NULL) {
                                    array_push($blog["like_list"],$like);
                                } else {
                                    mysqli_query($mysql,"delete from likes where like_uid = ".$like['like_uid']." && id = ".$blog['id']);
                                    $s = intval($blog["like_count"])-1;
                                    mysqli_query($mysql,"update blogs set like_count = ".$s." where id = ".$blog['id']);
                                }
                            } else {
                                mysqli_query($mysql,"delete from likes where like_uid = ".$like['like_uid']." && id = ".$blog['id']);
                                $s = intval($blog["like_count"])-1;
                                mysqli_query($mysql,"update blogs set like_count = ".$s." where id = ".$blog['id']);
                            }
                        }
                        while($comment = mysqli_fetch_assoc($cq)) {
                            $comment['id'] = intval($comment['id']);
                            $comment['comment_uid'] = intval($comment['comment_uid']);
                            $clq = mysqli_query($mysql,"select * from clikes where comment_id = ".$comment['comment_id']);
                            $comment["like_list"] = [];
                            while($clike = mysqli_fetch_assoc($clq)) {
                                $mess = mysqli_query($mysql,"select user,portrait from users where uid = ".$clike['like_uid']);
                                if(!is_bool($mess)) {
                                    $m = mysqli_fetch_assoc($mess);
                                    if($m != NULL) {
                                        array_push($comment["like_list"],$clike);
                                    } else {
                                        mysqli_query($mysql,"delete from clikes where like_uid = ".$clike['like_uid']." && comment_id = ".$comment['comment_id']);
                                        $s = intval($comment["like_count"])-1;
                                        mysqli_query($mysql,"update comments set like_count = ".$s." where comment_id = ".$comment['comment_id']);
                                    }
                                } else {
                                    mysqli_query($mysql,"delete from clikes where like_uid = ".$clike['like_uid']." && comment_id = ".$comment['comment_id']);
                                    $s = intval($comment["like_count"])-1;
                                    mysqli_query($mysql,"update comments set like_count = ".$s." where comment_id = ".$comment['comment_id']);
                                }
                            }
                            $cuq = mysqli_query($mysql,"select user,portrait from users where uid = ".$comment['comment_uid']);
                            if(!is_bool($cuq)) {
                                $array = mysqli_fetch_assoc($cuq);
                                if($array != NULL) {
                                    $comment['user'] = $array['user'];
                                    $comment['portrait'] = $array['portrait'];
                                    $qq = mysqli_query($mysql,"select * from quote where comment_id = ".$comment['comment_id']);
                                    $comment["comment_list"] = [];
                                    while($quote = mysqli_fetch_assoc($qq)) {
                                        $quote["like_list"] = [];
                                        $qlq = mysqli_query($mysql,"select * from qlikes where quote_id = ".$quote['quote_id']);
                                        while($qlike = mysqli_fetch_assoc($qlq)) {
                                            $qlike['comment_id'] = $qlike['quote_id'];
                                            $mess = mysqli_query($mysql,"select user,portrait from users where uid = ".$qlike['like_uid']);
                                            if(!is_bool($mess)) {
                                                $m = mysqli_fetch_assoc($mess);
                                                if($m != NULL) {
                                                    array_push($quote["like_list"],$qlike);
                                                } else {
                                                    mysqli_query($mysql,"delete from qlikes where like_uid = ".$qlike['like_uid']." && quote_id = ".$quote['quote_id']);
                                                    $s = intval($quote["like_count"])-1;
                                                    mysqli_query($mysql,"update quote set like_count = ".$s." where quote_id = ".$quote['quote_id']);
                                                }
                                            } else {
                                                mysqli_query($mysql,"delete from qlikes where like_uid = ".$qlike['like_uid']." && quote_id = ".$quote['quote_id']);
                                                $s = intval($quote["like_count"])-1;
                                                mysqli_query($mysql,"update quote set like_count = ".$s." where quote_id = ".$quote['quote_id']);
                                            }
                                        }
                                        $quote['id'] = intval($quote['id']);
                                        $quote['comment_id'] = $quote['quote_id'];
                                        $quq = mysqli_query($mysql,"select user,portrait from users where uid = ".$quote['comment_uid']);
                                        if(!is_bool($quq)) {
                                            $array = mysqli_fetch_assoc($quq);
                                            if($array != NULL) {
                                                $quote['user'] = $array['user'];
                                                $quote['portrait'] = $array['portrait'];
                                                array_push($comment["comment_list"],$quote);
                                            } else {
                                                mysqli_query($mysql,"delete from quote where quote_id = ".$quote['quote_id']);
                                                $s = intval($comment["comment_count"])-1;
                                                mysqli_query($mysql,"update comments set comment_count = ".$s." where comment_id = ".$comment['comment_id']);
                                            }
                                        } else {
                                            mysqli_query($mysql,"delete from quote where quote_id = ".$quote['quote_id']);
                                            $s = intval($comment["comment_count"])-1;
                                            mysqli_query($mysql,"update comments set comment_count = ".$s." where comment_id = ".$comment['comment_id']);
                                        }
                                    }
                                    array_push($blog["comment_list"],$comment);
                                } else {
                                    mysqli_query($mysql,"delete from comments where comment_id = ".$comment['comment_id']);
                                    $s = intval($blog["comment_count"])-1;
                                    mysqli_query($mysql,"update blogs set comment_count = ".$s." where id = ".$blog['id']);
                                }
                            } else {
                                mysqli_query($mysql,"delete from comments where comment_id = ".$comment['comment_id']);
                                $s = intval($blog["comment_count"])-1;
                                mysqli_query($mysql,"update blogs set comment_count = ".$s." where id = ".$blog['id']);
                            }
                        }
                        unset($blog['createTime']);
                        exit(json_encode($blog,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                    }
                }
            }
                }
            exit(json_encode(["msg"=>"uid error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        }
    }
}
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
