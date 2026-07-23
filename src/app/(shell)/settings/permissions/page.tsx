import { createClient } from "@/lib/supabase/server";
import { requirePermission } from "@/lib/auth/session";
import { redirect } from "next/navigation";
import { DataTable } from "@/components/shared/DataTable";

export default async function PermissionsPage() {
  const ctx = await requirePermission("master.permission.manage");
  if (!ctx) redirect("/dashboard");

  const supabase = await createClient();
  const { data: permissions } = await supabase
    .schema("master")
    .from("permission")
    .select("code, module, action, resource, description")
    .is("deleted_at", null)
    .order("code");

  return (
    <div>
      <h1 style={{ marginTop: 0 }}>Permissions</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Master Permission — <code>module.resource.action</code>
      </p>
      <DataTable
        columns={["Code", "Module", "Action", "Resource", "Description"]}
        rows={(permissions ?? []).map((p) => [
          p.code,
          p.module,
          p.action,
          p.resource,
          p.description ?? "—",
        ])}
      />
    </div>
  );
}
