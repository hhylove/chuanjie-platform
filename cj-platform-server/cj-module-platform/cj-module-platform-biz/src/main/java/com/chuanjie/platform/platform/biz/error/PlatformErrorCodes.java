package com.chuanjie.platform.platform.biz.error;

import com.chuanjie.platform.framework.error.ErrorCodeRanges;

/** platform 模块业务错误码（100xxx）。 */
public final class PlatformErrorCodes {
    private PlatformErrorCodes() {}

    public static final int USER_NOT_FOUND = ErrorCodeRanges.PLATFORM + 1;
    public static final int BAD_PASSWORD = ErrorCodeRanges.PLATFORM + 2;
    public static final int USER_DISABLED = ErrorCodeRanges.PLATFORM + 3;
    public static final int UNAUTHORIZED = ErrorCodeRanges.PLATFORM + 401;
    public static final int TOKEN_INVALID = ErrorCodeRanges.PLATFORM + 402;
    public static final int USERNAME_EXISTS = ErrorCodeRanges.PLATFORM + 10;
    public static final int DEPT_NOT_FOUND = ErrorCodeRanges.PLATFORM + 20;
    public static final int ROLE_NOT_FOUND = ErrorCodeRanges.PLATFORM + 30;
    public static final int ROLE_PROTECTED = ErrorCodeRanges.PLATFORM + 31;
    public static final int POST_NOT_FOUND = ErrorCodeRanges.PLATFORM + 40;
}
