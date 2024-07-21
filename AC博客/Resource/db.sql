-- 微博数据表 --
CREATE TABLE IF NOT EXISTS "T_Status" (
    "statusId" INTEGER NOT NULL,
    "status" TEXT,
    "userId" INTEGER,
    "create_at" TEXT,
    "createTime" TEXT DEFAULT (datetime('now', 'localtime')),
    PRIMARY KEY("statusId")
);
-- 微博数据表 --
CREATE TABLE IF NOT EXISTS "T_Chats" (
    "to_uid" INTEGER NOT NULL,
    "content" TEXT,
    "portrait" TEXT,
    "userId" INTEGER NOT NULL,
    "timeInterval" INTEGER NOT NULL,
    "createTime" TEXT DEFAULT (datetime('now', 'localtime'))
);
