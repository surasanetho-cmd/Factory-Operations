import { createClient } from "@/lib/supabase/server";
import { requirePermission } from "@/lib/auth/session";
import { redirect } from "next/navigation";
import { DataTable } from "@/components/shared/DataTable";

export default async function UsersPage() {
  const ctx = await requirePermission("master.user.manage");
  if (!ctx) redirect("/dashboard");

  const supabase = await createClient();
  const { data: users } = await supabase
    .schema("master")
    .from("user_profile")
    .select("employee_code, display_name, email, locale, is_active")
    .is("deleted_at", null)
    .order("employee_code");

  return (
    <div>
      <h1 style={{ marginTop: 0 }}>Users</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Master User — <code>master.user_profile</code> linked to Supabase Auth
      </p>
      <DataTable
        columns={["Employee", "Name", "Email", "Locale", "Active"]}
        rows={(users ?? []).map((u) => [
          u.employee_code,
          u.display_name,
          u.email,
          u.locale,
          u.is_active ? "yes" : "no",
        ])}
      />
    </div>
  );
}
