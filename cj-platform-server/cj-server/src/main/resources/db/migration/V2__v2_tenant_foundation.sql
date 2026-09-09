-- R1共享数据面隔离基础：业务事务通过SET LOCAL设置可信租户变量。
-- 未设置或事务结束后变量为空时函数返回NULL，使RLS策略默认拒绝所有租户行。

CREATE SCHEMA tenant_runtime;

COMMENT ON SCHEMA tenant_runtime IS '共享数据库租户隔离运行时函数；不存放业务表';

CREATE FUNCTION tenant_runtime.current_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
PARALLEL SAFE
AS $$
    SELECT NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
$$;

COMMENT ON FUNCTION tenant_runtime.current_tenant_id() IS '读取当前事务可信租户UUID；未设置时返回NULL以使RLS默认拒绝';

GRANT USAGE ON SCHEMA tenant_runtime TO PUBLIC;
GRANT EXECUTE ON FUNCTION tenant_runtime.current_tenant_id() TO PUBLIC;
