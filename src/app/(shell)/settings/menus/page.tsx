import { createClient } from "@/lib/supabase/server";
import { requirePermission } from "@/lib/auth/session";
import { redirect } from "next/navigation";
import { DataTable } from "@/components/shared/DataTable";

export default async function MenusPage() {
  const ctx = await requirePermission("master.menu.manage");
  if (!ctx) redirect("/dashboard");

  const supabase = await createClient();
  const { data: menus } = await supabase
    .schema("master")
    .from("menu")
    .select("code, label, path, sort_order, permission_code, module")
    .is("deleted_at", null)
    .order("sort_order");

  return (
    <div>
      <h1 style={{ marginTop: 0 }}>Menus</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Master Menu — drives the sidebar via <code>authz.my_menus()</code>
      </p>
      <DataTable
        columns={["Code", "Label", "Path", "Sort", "Permission", "Module"]}
        rows={(menus ?? []).map((m) => [
          m.code,
          m.label,
          m.path ?? "—",
          String(m.sort_order),
          m.permission_code ?? "—",
          m.module ?? "—",
        ])}
      />
    </div>
  );
}
