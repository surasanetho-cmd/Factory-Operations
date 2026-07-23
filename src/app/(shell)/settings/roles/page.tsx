import { createClient } from "@/lib/supabase/server";
import { requirePermission } from "@/lib/auth/session";
import { redirect } from "next/navigation";
import { DataTable } from "@/components/shared/DataTable";

export default async function RolesPage() {
  const ctx = await requirePermission("master.role.manage");
  if (!ctx) redirect("/dashboard");

  const supabase = await createClient();
  const { data: roles } = await supabase
    .schema("master")
    .from("role")
    .select("id, code, name, description, is_active")
    .is("deleted_at", null)
    .order("code");

  return (
    <div>
      <h1 style={{ marginTop: 0 }}>Roles</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Master Role — from <code>master.role</code>
      </p>
      <DataTable
        columns={["Code", "Name", "Description", "Active"]}
        rows={(roles ?? []).map((r) => [
          r.code,
          r.name,
          r.description ?? "—",
          r.is_active ? "yes" : "no",
        ])}
      />
    </div>
  );
}
