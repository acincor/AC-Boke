<?php
header('Content-Type:application/json; charset=utf-8');
$mysql = mysqli_connect("localhost", "root", "123456","ac_inc");
            if(isset($_POST["uid"])) {
            $arr0 = [];
            $query = mysqli_query($mysql,"select id from likes where like_uid = ".$_POST["uid"]);
            while($arr = mysqli_fetch_assoc($query)) {
                $q = mysqli_query($mysql,"select * from blogs where id = ".$arr['id']);
                if(!is_bool($q)) {
                    $blog = mysqli_fetch_assoc($q);
                    $q1 = mysqli_query($mysql,"select user,portrait,fans from users where uid = ".$blog["uid"]);
                    if(!is_bool($q1)) {
                        $array = mysqli_fetch_assoc($q1);
                    if($blog != NULL && $array != NULL) {
                        $blog['user'] = $array['user'];
                        $blog['portrait'] = $array['portrait'];
                        $blog['isfollowed'] = array_search(["uid"=>$_POST["uid"]],json_decode($array['fans'],true)) !== false;
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
                            array_push($blog["like_list"],$like);
                        }
                        while($comment = mysqli_fetch_assoc($cq)) {
                            $comment['id'] = intval($comment['id']);
                            $comment['comment_uid'] = intval($comment['comment_uid']);
                            $cq = mysqli_query($mysql,"select * from clikes where comment_id = ".$comment['comment_id']);
                            $comment["like_list"] = [];
                            while($clike = mysqli_fetch_assoc($cq)) {
                                $clike['comment_id'] = intval($clike['comment_id']);
                                $clike['like_uid'] = intval($clike['like_uid']);
                                array_push($comment["like_list"],$clike);
                            }
                            $cuq = mysqli_query($mysql,"select user,portrait,fans from users where uid = ".$comment['comment_uid']);
                            if(!is_bool($cuq)) {
                                $array = mysqli_fetch_assoc($cuq);
                                if($array != NULL) {
                                    $comment['user'] = $array['user'];
                                    $comment['portrait'] = $array['portrait'];
                                    $comment['isfollowed'] = array_search(["uid"=>$_POST["uid"]],json_decode($array['fans'],true)) !== false;
                                    $qq = mysqli_query($mysql,"select * from quote where comment_id = ".$comment['comment_id']);
                                    $comment["comment_list"] = [];
                                    while($quote = mysqli_fetch_assoc($qq)) {
                                        $quote["like_list"] = [];
                                        $qq = mysqli_query($mysql,"select * from qlikes where quote_id = ".$quote['quote_id']);
                                        while($qlike = mysqli_fetch_assoc($qq)) {
                                            $qlike['comment_id'] = $qlike['quote_id'];
                                            $qlike['like_uid'] = intval($qlike['like_uid']);
                                            array_push($quote["like_list"],$qlike);
                                        }
                                        $quote['id'] = intval($quote['id']);
                                        $quote['comment_id'] = $quote['quote_id'];
                                        $quq = mysqli_query($mysql,"select user,portrait,fans from users where uid = ".$comment['comment_uid']);
                                        if(!is_bool($quq)) {
                                            $array = mysqli_fetch_assoc($quq);
                                            if($array != NULL) {
                                                $quote['user'] = $array['user'];
                                                $quote['portrait'] = $array['portrait'];
                                                $quote['isfollowed'] = array_search(["uid"=>$_POST["uid"]],json_decode($array['fans'],true)) !== false;
                                            }
                                        }
                                        array_push($comment["comment_list"],$quote);
                                    }
                                }
                            }
                            array_push($blog["comment_list"],$comment);
                        }
                        unset($blog['createTime']);
                        array_unshift($arr0,$blog);
                    }
                }
                    }
            }
                exit(json_encode($arr0,JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
                }
exit(json_encode(["msg"=>"params error!"],JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
