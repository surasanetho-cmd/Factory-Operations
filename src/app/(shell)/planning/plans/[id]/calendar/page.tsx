import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PlanCalendarBoard, type CalendarItem } from "@/components/planning/PlanCalendarBoard";

export default async function PlanCalendarPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: plan } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("id, status_code, period_start, period_end")
    .eq("id", id)
    .is("deleted_at", null)
    .maybeSingle();
  if (!plan) notFound();

  const [{ data: items }, { data: lines }, { data: parts }] = await Promise.all([
    supabase
      .schema("txn")
      .from("production_plan_item")
      .select(
        "id, production_line_id, machine_id, shift_id, planned_date, planned_start_at, planned_end_at, qty, version, part_id, status_code",
      )
      .eq("production_plan_id", id)
      .is("deleted_at", null),
    supabase
      .schema("master")
      .from("production_line")
      .select("id, code, name, sort_order")
      .is("deleted_at", null)
      .order("sort_order"),
    supabase.schema("master").from("part").select("id, code").is("deleted_at", null),
  ]);

  const partMap = Object.fromEntries((parts ?? []).map((p) => [p.id, p.code]));
  const lineMap = Object.fromEntries((lines ?? []).map((l) => [l.id, l.code]));

  const boardItems: CalendarItem[] = (items ?? []).map((i) => ({
    id: i.id,
    production_line_id: i.production_line_id,
    machine_id: i.machine_id,
    shift_id: i.shift_id,
    planned_date: i.planned_date,
    planned_start_at: i.planned_start_at,
    planned_end_at: i.planned_end_at,
    qty: Number(i.qty),
    version: i.version,
    part_code: partMap[i.part_id] ?? "?",
    line_code: lineMap[i.production_line_id] ?? "?",
    status_code: i.status_code,
  }));

  const dates = eachDate(plan.period_start, plan.period_end);
  const editable = plan.status_code === "draft" || plan.status_code === "rejected";

  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Calendar</h2>
      <PlanCalendarBoard
        planId={id}
        editable={editable}
        items={boardItems}
        lines={(lines ?? []).map((l) => ({ id: l.id, code: l.code, name: l.name }))}
        dates={dates}
      />
    </div>
  );
}

function eachDate(start: string, end: string) {
  const out: string[] = [];
  const cur = new Date(start + "T00:00:00");
  const last = new Date(end + "T00:00:00");
  while (cur <= last) {
    out.push(cur.toISOString().slice(0, 10));
    cur.setDate(cur.getDate() + 1);
  }
  return out;
}
