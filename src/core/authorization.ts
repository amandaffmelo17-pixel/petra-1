import type { TenantContext } from "./tenant-context.js";

export interface Permission {
  module: string;
  action: string;
}

export interface AuthorizationSubject {
  tenantId: string;
  userId: string;
  roles: string[];
  permissions: Permission[];
}

export function assertAuthorized(
  context: TenantContext,
  subject: AuthorizationSubject,
  permission: Permission,
): void {
  if (context.tenantId !== subject.tenantId) {
    throw new Error("PETRA: tenant context does not match authorization subject");
  }

  const allowed = subject.permissions.some(
    (item) => item.module === permission.module && item.action === permission.action,
  );

  if (!allowed) {
    throw new Error(`PETRA: permission denied for ${permission.module}:${permission.action}`);
  }
}

export function hasPermission(subject: AuthorizationSubject, permission: Permission): boolean {
  return subject.permissions.some(
    (item) => item.module === permission.module && item.action === permission.action,
  );
}
