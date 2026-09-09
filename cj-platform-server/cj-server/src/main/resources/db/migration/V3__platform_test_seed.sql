-- S1-01 测试数据：部门/角色扩充 + 约 200 个测试用户（密码均为 Admin@123）
-- 幂等：WHERE NOT EXISTS；正式环境勿依赖本脚本账号

-- 扩充子部门（挂在「创界总部」下）
INSERT INTO platform_dept (parent_id, name, sort_no, status, creator, updater, deleted, version)
SELECT (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '创界总部' AND parent_id = 0 ORDER BY id LIMIT 1),
       '市场部', 1, 'active', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_dept d WHERE d.deleted = FALSE AND d.name = '市场部');

INSERT INTO platform_dept (parent_id, name, sort_no, status, creator, updater, deleted, version)
SELECT (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '创界总部' AND parent_id = 0 ORDER BY id LIMIT 1),
       '技术部', 2, 'active', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_dept d WHERE d.deleted = FALSE AND d.name = '技术部');

INSERT INTO platform_dept (parent_id, name, sort_no, status, creator, updater, deleted, version)
SELECT (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '创界总部' AND parent_id = 0 ORDER BY id LIMIT 1),
       '人事部', 3, 'active', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_dept d WHERE d.deleted = FALSE AND d.name = '人事部');

INSERT INTO platform_dept (parent_id, name, sort_no, status, creator, updater, deleted, version)
SELECT (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '创界总部' AND parent_id = 0 ORDER BY id LIMIT 1),
       '财务部', 4, 'active', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_dept d WHERE d.deleted = FALSE AND d.name = '财务部');

INSERT INTO platform_dept (parent_id, name, sort_no, status, creator, updater, deleted, version)
SELECT (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '创界总部' AND parent_id = 0 ORDER BY id LIMIT 1),
       '运营部', 5, 'active', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_dept d WHERE d.deleted = FALSE AND d.name = '运营部');

INSERT INTO platform_dept (parent_id, name, sort_no, status, creator, updater, deleted, version)
SELECT (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '创界总部' AND parent_id = 0 ORDER BY id LIMIT 1),
       '归档观察部', 99, 'disabled', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_dept d WHERE d.deleted = FALSE AND d.name = '归档观察部');

INSERT INTO platform_role (code, name, remark, status, data_scope, creator, updater, deleted, version)
SELECT 'OPERATOR', '业务经办', '测试角色', 'active', 'DEPT', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_role r WHERE r.deleted = FALSE AND r.code = 'OPERATOR');

INSERT INTO platform_role (code, name, remark, status, data_scope, creator, updater, deleted, version)
SELECT 'VIEWER', '只读访客', '测试角色', 'active', 'SELF', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_role r WHERE r.deleted = FALSE AND r.code = 'VIEWER');

INSERT INTO platform_role (code, name, remark, status, data_scope, creator, updater, deleted, version)
SELECT 'LEGACY', '历史停用角色', '用于筛选联调', 'disabled', 'SELF', 'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_role r WHERE r.deleted = FALSE AND r.code = 'LEGACY');

-- 200 个测试用户：user001~user200；每 10 个停用 1 个；部门轮询；角色 OPERATOR/VIEWER 轮询
INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user001', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户001', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user001');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user001' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user002', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户002', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user002');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user002' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user003', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户003', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user003');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user003' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user004', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户004', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user004');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user004' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user005', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户005', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user005');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user005' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user006', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户006', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user006');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user006' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user007', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户007', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user007');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user007' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user008', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户008', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user008');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user008' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user009', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户009', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user009');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user009' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user010', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户010', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user010');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user010' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user011', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户011', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user011');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user011' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user012', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户012', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user012');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user012' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user013', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户013', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user013');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user013' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user014', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户014', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user014');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user014' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user015', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户015', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user015');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user015' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user016', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户016', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user016');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user016' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user017', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户017', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user017');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user017' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user018', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户018', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user018');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user018' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user019', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户019', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user019');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user019' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user020', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户020', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user020');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user020' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user021', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户021', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user021');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user021' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user022', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户022', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user022');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user022' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user023', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户023', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user023');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user023' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user024', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户024', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user024');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user024' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user025', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户025', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user025');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user025' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user026', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户026', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user026');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user026' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user027', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户027', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user027');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user027' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user028', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户028', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user028');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user028' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user029', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户029', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user029');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user029' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user030', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户030', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user030');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user030' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user031', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户031', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user031');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user031' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user032', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户032', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user032');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user032' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user033', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户033', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user033');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user033' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user034', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户034', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user034');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user034' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user035', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户035', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user035');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user035' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user036', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户036', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user036');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user036' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user037', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户037', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user037');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user037' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user038', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户038', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user038');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user038' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user039', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户039', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user039');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user039' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user040', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户040', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user040');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user040' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user041', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户041', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user041');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user041' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user042', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户042', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user042');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user042' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user043', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户043', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user043');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user043' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user044', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户044', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user044');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user044' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user045', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户045', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user045');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user045' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user046', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户046', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user046');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user046' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user047', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户047', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user047');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user047' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user048', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户048', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user048');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user048' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user049', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户049', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user049');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user049' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user050', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户050', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user050');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user050' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user051', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户051', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user051');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user051' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user052', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户052', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user052');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user052' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user053', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户053', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user053');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user053' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user054', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户054', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user054');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user054' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user055', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户055', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user055');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user055' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user056', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户056', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user056');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user056' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user057', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户057', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user057');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user057' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user058', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户058', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user058');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user058' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user059', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户059', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user059');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user059' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user060', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户060', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user060');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user060' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user061', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户061', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user061');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user061' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user062', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户062', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user062');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user062' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user063', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户063', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user063');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user063' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user064', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户064', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user064');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user064' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user065', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户065', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user065');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user065' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user066', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户066', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user066');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user066' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user067', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户067', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user067');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user067' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user068', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户068', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user068');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user068' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user069', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户069', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user069');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user069' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user070', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户070', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user070');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user070' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user071', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户071', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user071');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user071' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user072', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户072', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user072');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user072' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user073', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户073', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user073');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user073' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user074', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户074', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user074');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user074' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user075', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户075', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user075');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user075' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user076', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户076', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user076');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user076' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user077', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户077', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user077');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user077' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user078', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户078', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user078');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user078' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user079', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户079', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user079');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user079' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user080', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户080', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user080');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user080' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user081', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户081', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user081');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user081' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user082', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户082', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user082');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user082' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user083', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户083', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user083');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user083' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user084', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户084', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user084');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user084' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user085', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户085', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user085');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user085' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user086', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户086', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user086');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user086' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user087', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户087', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user087');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user087' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user088', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户088', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user088');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user088' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user089', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户089', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user089');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user089' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user090', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户090', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user090');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user090' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user091', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户091', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user091');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user091' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user092', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户092', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user092');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user092' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user093', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户093', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user093');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user093' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user094', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户094', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user094');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user094' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user095', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户095', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user095');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user095' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user096', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户096', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user096');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user096' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user097', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户097', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user097');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user097' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user098', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户098', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user098');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user098' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user099', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户099', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user099');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user099' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user100', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户100', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user100');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user100' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user101', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户101', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user101');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user101' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user102', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户102', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user102');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user102' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user103', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户103', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user103');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user103' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user104', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户104', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user104');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user104' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user105', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户105', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user105');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user105' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user106', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户106', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user106');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user106' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user107', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户107', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user107');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user107' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user108', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户108', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user108');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user108' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user109', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户109', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user109');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user109' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user110', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户110', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user110');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user110' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user111', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户111', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user111');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user111' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user112', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户112', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user112');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user112' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user113', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户113', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user113');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user113' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user114', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户114', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user114');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user114' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user115', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户115', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user115');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user115' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user116', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户116', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user116');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user116' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user117', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户117', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user117');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user117' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user118', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户118', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user118');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user118' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user119', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户119', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user119');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user119' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user120', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户120', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user120');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user120' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user121', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户121', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user121');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user121' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user122', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户122', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user122');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user122' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user123', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户123', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user123');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user123' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user124', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户124', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user124');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user124' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user125', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户125', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user125');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user125' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user126', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户126', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user126');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user126' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user127', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户127', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user127');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user127' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user128', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户128', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user128');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user128' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user129', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户129', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user129');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user129' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user130', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户130', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user130');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user130' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user131', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户131', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user131');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user131' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user132', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户132', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user132');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user132' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user133', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户133', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user133');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user133' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user134', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户134', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user134');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user134' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user135', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户135', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user135');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user135' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user136', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户136', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user136');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user136' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user137', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户137', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user137');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user137' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user138', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户138', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user138');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user138' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user139', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户139', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user139');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user139' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user140', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户140', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user140');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user140' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user141', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户141', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user141');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user141' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user142', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户142', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user142');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user142' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user143', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户143', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user143');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user143' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user144', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户144', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user144');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user144' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user145', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户145', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user145');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user145' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user146', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户146', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user146');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user146' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user147', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户147', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user147');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user147' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user148', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户148', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user148');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user148' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user149', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户149', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user149');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user149' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user150', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户150', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user150');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user150' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user151', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户151', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user151');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user151' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user152', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户152', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user152');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user152' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user153', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户153', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user153');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user153' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user154', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户154', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user154');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user154' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user155', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户155', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user155');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user155' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user156', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户156', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user156');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user156' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user157', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户157', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user157');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user157' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user158', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户158', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user158');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user158' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user159', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户159', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user159');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user159' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user160', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户160', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user160');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user160' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user161', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户161', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user161');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user161' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user162', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户162', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user162');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user162' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user163', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户163', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user163');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user163' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user164', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户164', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user164');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user164' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user165', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户165', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user165');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user165' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user166', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户166', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user166');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user166' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user167', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户167', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user167');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user167' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user168', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户168', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user168');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user168' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user169', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户169', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user169');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user169' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user170', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户170', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user170');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user170' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user171', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户171', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user171');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user171' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user172', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户172', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user172');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user172' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user173', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户173', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user173');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user173' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user174', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户174', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user174');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user174' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user175', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户175', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user175');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user175' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user176', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户176', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user176');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user176' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user177', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户177', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user177');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user177' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user178', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户178', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user178');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user178' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user179', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户179', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user179');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user179' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user180', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户180', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user180');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user180' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user181', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户181', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user181');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user181' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user182', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户182', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user182');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user182' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user183', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户183', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user183');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user183' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user184', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户184', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user184');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user184' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user185', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户185', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user185');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user185' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user186', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户186', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user186');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user186' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user187', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户187', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user187');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user187' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user188', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户188', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user188');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user188' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user189', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户189', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user189');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user189' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user190', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户190', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user190');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user190' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user191', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户191', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user191');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user191' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user192', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户192', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user192');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user192' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user193', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户193', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user193');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user193' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user194', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户194', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user194');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user194' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user195', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户195', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user195');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user195' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user196', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户196', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '市场部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user196');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user196' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user197', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户197', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '技术部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user197');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user197' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user198', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户198', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '人事部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user198');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user198' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user199', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户199', 'INTERNAL', 'active',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '财务部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user199');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user199' AND u.deleted = FALSE AND r.code = 'OPERATOR' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

INSERT INTO platform_user (username, password_hash, display_name, user_type, status, dept_id, creator, updater, deleted, version)
SELECT 'user200', '$2a$10$c7aYJqxIeZbdPbF6ETWFo.F8infVfl9TrBZzZ3cgh3wHZxNaBz2pu', '测试用户200', 'INTERNAL', 'disabled',
       (SELECT id FROM platform_dept WHERE deleted = FALSE AND name = '运营部' ORDER BY id LIMIT 1),
       'system', 'system', FALSE, 0
WHERE NOT EXISTS (SELECT 1 FROM platform_user u WHERE u.deleted = FALSE AND u.username = 'user200');
INSERT INTO platform_user_role (user_id, role_id, create_time)
SELECT u.id, r.id, CURRENT_TIMESTAMP FROM platform_user u CROSS JOIN platform_role r
WHERE u.username = 'user200' AND u.deleted = FALSE AND r.code = 'VIEWER' AND r.deleted = FALSE
  AND NOT EXISTS (SELECT 1 FROM platform_user_role ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

