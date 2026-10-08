-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: 202610080001_init
-- Database:  MySQL 8.x
-- Project:   Still – Project Management System
-- ─────────────────────────────────────────────────────────────────────────────

-- ── User ─────────────────────────────────────────────────────────────────────
CREATE TABLE `User` (
    `id`           VARCHAR(36)  NOT NULL,
    `fullName`     VARCHAR(100) NOT NULL,
    `email`        VARCHAR(254) NOT NULL,
    `passwordHash` TEXT         NOT NULL,
    `avatarUrl`    VARCHAR(512) NULL,
    `bio`          VARCHAR(300) NULL,
    `timezone`     VARCHAR(64)  NOT NULL DEFAULT 'UTC',
    `isActive`     BOOLEAN      NOT NULL DEFAULT TRUE,
    `createdAt`    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt`    DATETIME(3)  NOT NULL,
    `deletedAt`    DATETIME(3)  NULL,

    UNIQUE INDEX `User_email_key` (`email`),
    INDEX `User_email_isActive_idx` (`email`, `isActive`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── AuthSession ───────────────────────────────────────────────────────────────
CREATE TABLE `AuthSession` (
    `id`        VARCHAR(36)  NOT NULL,
    `userId`    VARCHAR(36)  NOT NULL,
    `csrfHash`  TEXT         NOT NULL,
    `userAgent` VARCHAR(512) NULL,
    `ipAddress` VARCHAR(45)  NULL,
    `expiresAt` DATETIME(3)  NOT NULL,
    `revokedAt` DATETIME(3)  NULL,
    `createdAt` DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `AuthSession_userId_expiresAt_idx` (`userId`, `expiresAt`),
    INDEX `AuthSession_userId_revokedAt_idx` (`userId`, `revokedAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── Project ───────────────────────────────────────────────────────────────────
CREATE TABLE `Project` (
    `id`          VARCHAR(36)                                                         NOT NULL,
    `ownerId`     VARCHAR(36)                                                         NOT NULL,
    `name`        VARCHAR(120)                                                        NOT NULL,
    `description` TEXT                                                                NOT NULL,
    `status`      ENUM('Not Started','In Progress','On Hold','Completed','Cancelled') NOT NULL DEFAULT 'Not Started',
    `priority`    ENUM('Low','Medium','High','Critical')                              NOT NULL DEFAULT 'Medium',
    `coverColor`  VARCHAR(7)                                                          NOT NULL DEFAULT '#6366f1',
    `startDate`   DATE                                                                NOT NULL,
    `endDate`     DATE                                                                NOT NULL,
    `isArchived`  BOOLEAN                                                             NOT NULL DEFAULT FALSE,
    `createdAt`   DATETIME(3)                                                         NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt`   DATETIME(3)                                                         NOT NULL,

    INDEX `Project_ownerId_status_createdAt_idx` (`ownerId`, `status`, `createdAt`),
    INDEX `Project_ownerId_isArchived_createdAt_idx` (`ownerId`, `isArchived`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── ProjectMember ─────────────────────────────────────────────────────────────
CREATE TABLE `ProjectMember` (
    `id`        VARCHAR(36)                              NOT NULL,
    `projectId` VARCHAR(36)                              NOT NULL,
    `userId`    VARCHAR(36)                              NOT NULL,
    `role`      ENUM('Owner','Admin','Member','Viewer')  NOT NULL DEFAULT 'Member',
    `joinedAt`  DATETIME(3)                              NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `ProjectMember_projectId_userId_key` (`projectId`, `userId`),
    INDEX `ProjectMember_userId_idx` (`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── Milestone ─────────────────────────────────────────────────────────────────
CREATE TABLE `Milestone` (
    `id`          VARCHAR(36)  NOT NULL,
    `projectId`   VARCHAR(36)  NOT NULL,
    `name`        VARCHAR(120) NOT NULL,
    `description` TEXT         NULL,
    `dueDate`     DATE         NOT NULL,
    `completedAt` DATETIME(3)  NULL,
    `createdAt`   DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt`   DATETIME(3)  NOT NULL,

    INDEX `Milestone_projectId_dueDate_idx` (`projectId`, `dueDate`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── Task ──────────────────────────────────────────────────────────────────────
CREATE TABLE `Task` (
    `id`             VARCHAR(36)                                          NOT NULL,
    `projectId`      VARCHAR(36)                                          NOT NULL,
    `milestoneId`    VARCHAR(36)                                          NULL,
    `assigneeId`     VARCHAR(36)                                          NULL,
    `parentTaskId`   VARCHAR(36)                                          NULL,
    `name`           VARCHAR(120)                                         NOT NULL,
    `description`    TEXT                                                 NOT NULL,
    `priority`       ENUM('Low','Medium','High','Critical')               NOT NULL DEFAULT 'Medium',
    `status`         ENUM('Pending','In Progress','In Review','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
    `dueDate`        DATE                                                 NOT NULL,
    `estimatedHours` DECIMAL(6,2)                                         NULL,
    `actualHours`    DECIMAL(6,2)                                         NULL,
    `position`       INT                                                  NOT NULL DEFAULT 0,
    `createdAt`      DATETIME(3)                                          NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt`      DATETIME(3)                                          NOT NULL,

    INDEX `Task_projectId_status_priority_createdAt_idx` (`projectId`, `status`, `priority`, `createdAt`),
    INDEX `Task_assigneeId_status_dueDate_idx` (`assigneeId`, `status`, `dueDate`),
    INDEX `Task_milestoneId_idx` (`milestoneId`),
    INDEX `Task_parentTaskId_idx` (`parentTaskId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── Label ─────────────────────────────────────────────────────────────────────
CREATE TABLE `Label` (
    `id`        VARCHAR(36) NOT NULL,
    `projectId` VARCHAR(36) NOT NULL,
    `name`      VARCHAR(50) NOT NULL,
    `color`     VARCHAR(7)  NOT NULL DEFAULT '#94a3b8',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `Label_projectId_name_key` (`projectId`, `name`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── TaskLabel (join) ──────────────────────────────────────────────────────────
CREATE TABLE `TaskLabel` (
    `taskId`  VARCHAR(36) NOT NULL,
    `labelId` VARCHAR(36) NOT NULL,

    INDEX `TaskLabel_labelId_idx` (`labelId`),
    PRIMARY KEY (`taskId`, `labelId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── TaskComment ───────────────────────────────────────────────────────────────
CREATE TABLE `TaskComment` (
    `id`       VARCHAR(36) NOT NULL,
    `taskId`   VARCHAR(36) NOT NULL,
    `authorId` VARCHAR(36) NOT NULL,
    `body`     TEXT        NOT NULL,
    `editedAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `TaskComment_taskId_createdAt_idx` (`taskId`, `createdAt`),
    INDEX `TaskComment_authorId_idx` (`authorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── TaskAttachment ────────────────────────────────────────────────────────────
CREATE TABLE `TaskAttachment` (
    `id`         VARCHAR(36)   NOT NULL,
    `taskId`     VARCHAR(36)   NOT NULL,
    `fileName`   VARCHAR(255)  NOT NULL,
    `fileUrl`    VARCHAR(1024) NOT NULL,
    `mimeType`   VARCHAR(127)  NULL,
    `sizeBytes`  INT           NULL,
    `uploadedBy` VARCHAR(36)   NOT NULL,
    `createdAt`  DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `TaskAttachment_taskId_idx` (`taskId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── ActivityLog ───────────────────────────────────────────────────────────────
CREATE TABLE `ActivityLog` (
    `id`        VARCHAR(36) NOT NULL,
    `projectId` VARCHAR(36) NOT NULL,
    `taskId`    VARCHAR(36) NULL,
    `actorId`   VARCHAR(36) NOT NULL,
    `action`    VARCHAR(80) NOT NULL,
    `detail`    TEXT        NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `ActivityLog_projectId_createdAt_idx` (`projectId`, `createdAt`),
    INDEX `ActivityLog_taskId_createdAt_idx` (`taskId`, `createdAt`),
    INDEX `ActivityLog_actorId_idx` (`actorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── Notification ──────────────────────────────────────────────────────────────
CREATE TABLE `Notification` (
    `id`        VARCHAR(36)  NOT NULL,
    `userId`    VARCHAR(36)  NOT NULL,
    `title`     VARCHAR(120) NOT NULL,
    `body`      VARCHAR(500) NOT NULL,
    `link`      VARCHAR(512) NULL,
    `isRead`    BOOLEAN      NOT NULL DEFAULT FALSE,
    `createdAt` DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Notification_userId_isRead_createdAt_idx` (`userId`, `isRead`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- Foreign Keys
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE `AuthSession`
    ADD CONSTRAINT `AuthSession_userId_fkey`
    FOREIGN KEY (`userId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Project`
    ADD CONSTRAINT `Project_ownerId_fkey`
    FOREIGN KEY (`ownerId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ProjectMember`
    ADD CONSTRAINT `ProjectMember_projectId_fkey`
    FOREIGN KEY (`projectId`) REFERENCES `Project`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ProjectMember`
    ADD CONSTRAINT `ProjectMember_userId_fkey`
    FOREIGN KEY (`userId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Milestone`
    ADD CONSTRAINT `Milestone_projectId_fkey`
    FOREIGN KEY (`projectId`) REFERENCES `Project`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Task`
    ADD CONSTRAINT `Task_projectId_fkey`
    FOREIGN KEY (`projectId`) REFERENCES `Project`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Task`
    ADD CONSTRAINT `Task_milestoneId_fkey`
    FOREIGN KEY (`milestoneId`) REFERENCES `Milestone`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `Task`
    ADD CONSTRAINT `Task_assigneeId_fkey`
    FOREIGN KEY (`assigneeId`) REFERENCES `User`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `Task`
    ADD CONSTRAINT `Task_parentTaskId_fkey`
    FOREIGN KEY (`parentTaskId`) REFERENCES `Task`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `Label`
    ADD CONSTRAINT `Label_projectId_fkey`
    FOREIGN KEY (`projectId`) REFERENCES `Project`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `TaskLabel`
    ADD CONSTRAINT `TaskLabel_taskId_fkey`
    FOREIGN KEY (`taskId`) REFERENCES `Task`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `TaskLabel`
    ADD CONSTRAINT `TaskLabel_labelId_fkey`
    FOREIGN KEY (`labelId`) REFERENCES `Label`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `TaskComment`
    ADD CONSTRAINT `TaskComment_taskId_fkey`
    FOREIGN KEY (`taskId`) REFERENCES `Task`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `TaskComment`
    ADD CONSTRAINT `TaskComment_authorId_fkey`
    FOREIGN KEY (`authorId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `TaskAttachment`
    ADD CONSTRAINT `TaskAttachment_taskId_fkey`
    FOREIGN KEY (`taskId`) REFERENCES `Task`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ActivityLog`
    ADD CONSTRAINT `ActivityLog_projectId_fkey`
    FOREIGN KEY (`projectId`) REFERENCES `Project`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ActivityLog`
    ADD CONSTRAINT `ActivityLog_taskId_fkey`
    FOREIGN KEY (`taskId`) REFERENCES `Task`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `ActivityLog`
    ADD CONSTRAINT `ActivityLog_actorId_fkey`
    FOREIGN KEY (`actorId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Notification`
    ADD CONSTRAINT `Notification_userId_fkey`
    FOREIGN KEY (`userId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
