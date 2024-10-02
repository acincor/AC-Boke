-- 微博数据表 --
CREATE TABLE IF NOT EXISTS "T_Status" (
    "statusId" INTEGER NOT NULL,
    "status" TEXT,
    "to_uid" TEXT,
    "userId" INTEGER,
    "create_at" TEXT,
    "type" TEXT,
    "createTime" TEXT DEFAULT (datetime('now', 'localtime')),
    PRIMARY KEY("statusId")
);
