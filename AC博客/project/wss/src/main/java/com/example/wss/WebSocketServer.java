package com.example.wss;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InvalidObjectException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * WebSocket的操作类
 */
@Component
@Slf4j
@ServerEndpoint(value="/{uid}/{sid}")
public class WebSocketServer {

    /**
     * 静态变量，用来记录当前在线连接数，线程安全的类。
     */
    private static final AtomicInteger onlineSessionClientCount = new AtomicInteger(0);
    private static final List<Long> IdList = new ArrayList<>();
    /**
     * 存放所有在线的客户端
     */
    private static final Map<String, Session> onlineSessionClientMap = new ConcurrentHashMap<>();
    @OnOpen
    public void onOpen(@PathParam("uid") String uid, Session session) {
        onlineSessionClientMap.put(uid, session);
        onlineSessionClientCount.incrementAndGet();
        //在线数加1
    }
    /**
     * 连接关闭调用的方法。由前端<code>socket.close()</code>触发
     *
     */
    @OnClose
    public void onClose(@PathParam("uid") String uid, Session session) {
        //onlineSessionIdClientMap.remove(session.getId());
        // 从 Map中移除
        onlineSessionClientMap.remove(uid);

        //在线数减1
        onlineSessionClientCount.decrementAndGet();
        log.info("连接关闭成功，当前在线数为：{} ==> 关闭该连接信息：session_id = {}， uid = {},。", onlineSessionClientCount, session.getId(), uid);
    }
    @OnMessage(maxMessageSize = 52428800)
    public void onMessage(@PathParam("sid") String sid,String message, Session session) throws IOException {
        if ("Ping".equals(message)) {
            // 如果收到心跳包，回复一个Pong包
            session.getBasicRemote().sendText("Pong");
        } else {
            // 处理其他业务逻辑
            sendToOne(sid,message,session);
        }
    }
    @OnError
    public void onError(Session session, Throwable error) {
        log.error("WebSocket发生错误，错误信息为：" + error.getMessage());
        error.printStackTrace();
    }
    private void sendToOne(String toSid, String message, Session session) throws IOException {
        // 通过sid查询map中是否存在
        Session toSession = onlineSessionClientMap.get(toSid);
        JSONObject jsonObject = JSON.parseObject(message);
        Random random = new Random();
        int length = 10;
        StringBuilder stringBuilder = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            int digit = random.nextInt(10);
            stringBuilder.append(digit);
        }
        Long randomLong = Long.parseLong(stringBuilder.toString());
        while(IdList.contains(randomLong)) {
            stringBuilder = new StringBuilder(length);
            for (int i = 0; i < length; i++) {
                int digit = random.nextInt(10);
                stringBuilder.append(digit);
            }
            randomLong = Long.parseLong(stringBuilder.toString());
        }
        IdList.add(randomLong);
        jsonObject.put("id", randomLong);
        String jsonString = jsonObject.toJSONString();
        session.getBasicRemote().sendText(jsonString);
        if (toSession == null) {
            log.error("服务端给客户端发送消息 ==> toSid = " + toSid + " 不存在, message = " + jsonString);
            return;
        }
        // 异步发送
        //log.info("服务端给客户端发送消息 ==> toSid = {}, message = {}", toSid, message);
        toSession.getBasicRemote().sendText(jsonString);
        /*
        // 同步发送
        try {
            toSession.getBasicRemote().sendText(message);
        } catch (IOException e) {
            log.error("发送消息失败，WebSocket IO异常");
            e.printStackTrace();
        }*/
    }
}