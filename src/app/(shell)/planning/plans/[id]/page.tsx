import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { DataTable } from "@/components/shared/DataTable";

export default async function PlanDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: plan } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("*")
    .eq("id", id)
    .is("deleted_at", null)
    .maybeSingle();
  if (!plan) notFound();

  const { data: items } = await supabase
    .schema("txn")
    .from("production_plan_item")
    .select(
      "id, planned_date, planned_start_at, planned_end_at, qty, status_code, sort_order, part_id, production_line_id",
    )
    .eq("production_plan_id", id)
    .is("deleted_at", null)
    .order("planned_start_at");

  const partIds = [...new Set((items ?? []).map((i) => i.part_id))];
  const lineIds = [...new Set((items ?? []).map((i) => i.production_line_id))];

  const [{ data: parts }, { data: lines }] = await Promise.all([
    supabase.schema("master").from("part").select("id, code, name").in("id", partIds.length ? partIds : ["00000000-0000-0000-0000-000000000000"]),
    supabase.schema("master").from("production_line").select("id, code, name").in("id", lineIds.length ? lineIds : ["00000000-0000-0000-0000-000000000000"]),
  ]);

  const partMap = Object.fromEntries((parts ?? []).map((p) => [p.id, p]));
  const lineMap = Object.fromEntries((lines ?? []).map((l) => [l.id, l]));

  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Planning Detail</h2>
      <p style={{ color: "var(--text-muted)" }}>
        Job lines for this plan header. Use Calendar for drag-drop scheduling.
      </p>
      <DataTable
        columns={["Date", "Line", "Part", "Start", "End", "Qty", "Status"]}
        rows={(items ?? []).map((i) => [
          i.planned_date,
          lineMap[i.production_line_id]?.code ?? "—",
          partMap[i.part_id]?.code ?? "—",
          new Date(i.planned_start_at).toLocaleString("en-GB", { hour: "2-digit", minute: "2-digit", day: "2-digit", month: "short" }),
          new Date(i.planned_end_at).toLocaleString("en-GB", { hour: "2-digit", minute: "2-digit", day: "2-digit", month: "short" }),
          String(i.qty),
          i.status_code,
        ])}
      />
    </div>
  );
}
