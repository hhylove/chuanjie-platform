package com.chuanjie.platform.framework.error;

/**
 * 业务错误码号段预留（与项目规范一致）。
 * <ul>
 *   <li>100xxx — platform / 系统与权限</li>
 *   <li>200xxx — OA / collaboration</li>
 *   <li>300xxx — 人事与培训 (oa-hr)</li>
 *   <li>400xxx — 创业项目 (project)</li>
 *   <li>500xxx — 商品与运营 (product / operation-creative)</li>
 *   <li>600xxx — 采购与供应商 (supply-chain)</li>
 *   <li>700xxx — 仓库与库存 (supply-chain)</li>
 *   <li>800xxx — 财务 (finance)</li>
 *   <li>900xxx — 数据与 AI (analytics-ai)</li>
 * </ul>
 */
public final class ErrorCodeRanges {
    private ErrorCodeRanges() {}

    /** platform / 系统与权限 */
    public static final int PLATFORM = 100000;
    /** OA / collaboration */
    public static final int COLLABORATION = 200000;
    /** 人事与培训 */
    public static final int OA_HR = 300000;
    /** 创业项目 */
    public static final int PROJECT = 400000;
    /** 商品与运营 */
    public static final int PRODUCT = 500000;
    /** 采购与供应商 */
    public static final int PROCUREMENT = 600000;
    /** 仓库与库存 */
    public static final int WAREHOUSE = 700000;
    /** 财务 */
    public static final int FINANCE = 800000;
    /** 数据与 AI */
    public static final int ANALYTICS_AI = 900000;
}
