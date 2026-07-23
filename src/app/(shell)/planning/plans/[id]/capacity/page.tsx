import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { DataTable } from "@/components/shared/DataTable";

export default async function PlanCapacityPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: plan } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("id, plan_no")
    .eq("id", id)
    .is("deleted_at", null)
    .maybeSingle();
  if (!plan) notFound();

  const { data, error } = await supabase.rpc("rpc_plan_capacity_summary", {
    p_plan_id: id,
  });

  const rows = (data ?? []) as Array<{
    line_code: string;
    planned_date: string;
    jobs_scheduled: number;
    jobs_capacity: number;
    hours_scheduled: number;
    hours_capacity: number;
    load_pct: number | null;
  }>;

  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Capacity</h2>
      <p style={{ color: "var(--text-muted)" }}>
        Jobs scheduled vs nominal line capacity (from <code>master.capacity</code>).
      </p>
      {error ? <p style={{ color: "var(--danger)" }}>{error.message}</p> : null}
      <DataTable
        columns={["Date", "Line", "Jobs", "Cap jobs", "Hours", "Cap hours", "Load %"]}
        rows={rows.map((r) => [
          r.planned_date,
          r.line_code,
          String(r.jobs_scheduled),
          String(r.jobs_capacity),
          String(r.hours_scheduled),
          String(r.hours_capacity),
          r.load_pct == null ? "—" : `${r.load_pct}%`,
        ])}
      />
      {rows.some((r) => (r.load_pct ?? 0) > 100) ? (
        <p style={{ color: "var(--danger)", marginTop: "1rem" }}>
          One or more cells exceed capacity — resolve before release.
        </p>
      ) : null}
    </div>
  );
}
