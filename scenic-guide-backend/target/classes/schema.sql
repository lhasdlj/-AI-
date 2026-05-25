-- 确保使用正确的数据库
USE `scenic_guide`;

-- 禁用外键检查以防删除表时发生冲突
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `faq_match_log`;
DROP TABLE IF EXISTS `visitor_log`;
DROP TABLE IF EXISTS `chat_message`;
DROP TABLE IF EXISTS `chat_session`;
DROP TABLE IF EXISTS `faq_knowledge`;
DROP TABLE IF EXISTS `guide_route`;
DROP TABLE IF EXISTS `attraction`;
DROP TABLE IF EXISTS `scenic_spot`;
DROP TABLE IF EXISTS `sys_user`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. 管理系统用户表
CREATE TABLE `sys_user` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
  `password` VARCHAR(100) NOT NULL COMMENT '密码(加密)',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `role` VARCHAR(20) DEFAULT 'operator' COMMENT '角色',
  `status` TINYINT DEFAULT 1 COMMENT '状态(1启用,0禁用)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='后台管理员用户表';

-- 2. 景区基本信息表
CREATE TABLE `scenic_spot` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '景区ID',
  `name` VARCHAR(100) NOT NULL COMMENT '景区名称',
  `description` TEXT COMMENT '景区描述',
  `address` VARCHAR(255) COMMENT '景区地址',
  `open_hours` VARCHAR(100) COMMENT '开放时间',
  `ticket_price` DECIMAL(10,2) DEFAULT 0.00 COMMENT '门票价格',
  `cover_image` VARCHAR(255) COMMENT '封面图URL',
  `status` TINYINT DEFAULT 1 COMMENT '运营状态(1启用,0下线)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='景区基本信息表';

-- 3. 景点/游玩节点表
CREATE TABLE `attraction` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '景点ID',
  `scenic_spot_id` INT NOT NULL COMMENT '所属景区ID',
  `name` VARCHAR(100) NOT NULL COMMENT '景点名称',
  `description` TEXT COMMENT '景点详细介绍',
  `longitude` DECIMAL(10,7) COMMENT '经度',
  `latitude` DECIMAL(10,7) COMMENT '纬度',
  `audio_url` VARCHAR(255) COMMENT '语音讲解URL',
  `image_url` VARCHAR(255) COMMENT '景点图片URL',
  `sort_order` INT DEFAULT 0 COMMENT '排序权重',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (`scenic_spot_id`) REFERENCES `scenic_spot`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='景点/游玩节点表';

-- 4. 推荐导览路线表
CREATE TABLE `guide_route` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '路线ID',
  `scenic_spot_id` INT NOT NULL COMMENT '所属景区ID',
  `name` VARCHAR(100) NOT NULL COMMENT '路线名称',
  `description` TEXT COMMENT '路线简介',
  `route_type` VARCHAR(20) DEFAULT 'walking' COMMENT '路线类型(walking,sightseeing_car,mixed)',
  `estimated_time` INT COMMENT '预计用时(分钟)',
  `estimated_distance` DECIMAL(5,2) COMMENT '预计距离(公里)',
  `attraction_ids` TEXT COMMENT '串联景点ID列表(JSON数组)',
  `status` TINYINT DEFAULT 1 COMMENT '启用状态',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  FOREIGN KEY (`scenic_spot_id`) REFERENCES `scenic_spot`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='推荐导览路线表';

-- 5. FAQ/文旅知识库表
CREATE TABLE `faq_knowledge` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '知识点ID',
  `scenic_spot_id` INT NOT NULL COMMENT '所属景区ID',
  `category` VARCHAR(50) COMMENT '分类',
  `question` VARCHAR(255) NOT NULL COMMENT '常见问题/标准问',
  `answer` TEXT NOT NULL COMMENT '标准答案',
  `keywords` VARCHAR(255) COMMENT '关键词(JSON或逗号分隔)',
  `vector_status` TINYINT DEFAULT 0 COMMENT '向量化状态(0待同步,1已同步)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (`scenic_spot_id`) REFERENCES `scenic_spot`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='FAQ/文旅知识库表';

-- 6. 游客对话会话表
CREATE TABLE `chat_session` (
  `session_id` VARCHAR(50) PRIMARY KEY COMMENT '会话ID',
  `user_identifier` VARCHAR(100) NOT NULL COMMENT '游客唯一标识/设备码',
  `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '会话开始时间',
  `last_active_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后活跃时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游客对话会话表';

-- 7. 对话消息历史表
CREATE TABLE `chat_message` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '消息ID',
  `session_id` VARCHAR(50) NOT NULL COMMENT '所属会话ID',
  `role` VARCHAR(10) NOT NULL COMMENT '发送者角色(user/assistant)',
  `content_type` VARCHAR(10) DEFAULT 'text' COMMENT '消息类型(text,voice)',
  `content` TEXT COMMENT '对话文本内容',
  `audio_url` VARCHAR(255) COMMENT 'TTS语音文件URL',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  FOREIGN KEY (`session_id`) REFERENCES `chat_session`(`session_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='对话消息历史表';

-- 8. 景区客流/行为日志表
CREATE TABLE `visitor_log` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
  `scenic_spot_id` INT NOT NULL COMMENT '景区ID',
  `attraction_id` INT DEFAULT NULL COMMENT '景点ID',
  `visit_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
  `visitor_ip` VARCHAR(45) COMMENT '游客IP',
  `action_type` VARCHAR(20) NOT NULL COMMENT '操作类型(enter,view_poi,ask_ai,buy_ticket)',
  FOREIGN KEY (`scenic_spot_id`) REFERENCES `scenic_spot`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='景区客流/行为日志表';

-- 9. FAQ匹配日志表
CREATE TABLE `faq_match_log` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '匹配记录ID',
  `session_id` VARCHAR(50) NOT NULL COMMENT '所属会话ID',
  `question` VARCHAR(255) NOT NULL COMMENT '游客提问',
  `matched_faq_id` INT DEFAULT NULL COMMENT '匹配的知识点ID',
  `similarity_score` DECIMAL(4,3) COMMENT '匹配相似度',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  FOREIGN KEY (`session_id`) REFERENCES `chat_session`(`session_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='FAQ匹配日志表';
