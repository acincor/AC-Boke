-- 微博数据表 --
CREATE TABLE IF NOT EXISTS "T_Chats" (
    "to_uid" INTEGER NOT NULL,
    "content" TEXT,
    "userId" INTEGER NOT NULL,
    "timeInterval" INTEGER NOT NULL,
    "createTime" TEXT DEFAULT (datetime('now', 'localtime'))
);
