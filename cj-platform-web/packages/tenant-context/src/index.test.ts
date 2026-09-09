import { describe, expect, it, vi } from "vitest";

import { createTenantContext } from "./index";

describe("tenant context", () => {
  it("starts without a selected tenant", () => {
    const context = createTenantContext();

    expect(context.current()).toBeNull();
  });

  it("clears tenant-scoped caches before switching tenants", () => {
    const clearTenantCache = vi.fn();
    const context = createTenantContext({ clearTenantCache });

    context.select({ tenantId: "tenant-a", membershipId: "member-a" });
    context.select({ tenantId: "tenant-b", membershipId: "member-b" });

    expect(clearTenantCache).toHaveBeenCalledTimes(1);
    expect(context.current()?.tenantId).toBe("tenant-b");
  });

  it("does not expose a client-editable tenant header", () => {
    const context = createTenantContext();

    context.select({ tenantId: "tenant-a", membershipId: "member-a" });

    expect(context.sessionHint()).toEqual({ membershipId: "member-a" });
    expect(context.sessionHint()).not.toHaveProperty("tenantId");
  });
});
