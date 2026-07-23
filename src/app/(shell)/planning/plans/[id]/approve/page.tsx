import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { WorkflowActions } from "@/components/planning/WorkflowActions";
import { DataTable } from "@/components/shared/DataTable";

export default async function PlanApprovePage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: plan } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("id, plan_no, status_code, version")
    .eq("id", id)
    .is("deleted_at", null)
    .maybeSingle();
  if (!plan) notFound();

  const { data: events } = await supabase
    .schema("txn")
    .from("plan_approval")
    .select("action, comment, acted_at, acted_by")
    .eq("production_plan_id", id)
    .is("deleted_at", null)
    .order("acted_at", { ascending: false });

  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Approve</h2>
      <p style={{ color: "var(--text-muted)" }}>
        Workflow: draft → submit → approve / reject. Current status: <strong>{plan.status_code}</strong>
      </p>
      <WorkflowActions
        planId={plan.id}
        version={plan.version}
        status={plan.status_code}
        mode="approve"
      />
      <h3 style={{ marginTop: "1.75rem" }}>Approval history</h3>
      <DataTable
        columns={["When", "Action", "Comment"]}
        rows={(events ?? []).map((e) => [
          new Date(e.acted_at).toLocaleString(),
          e.action,
          e.comment ?? "—",
        ])}
      />
    </div>
  );
}
