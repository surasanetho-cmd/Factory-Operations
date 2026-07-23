import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { WorkflowActions } from "@/components/planning/WorkflowActions";
import { DataTable } from "@/components/shared/DataTable";

export default async function PlanReleasePage({
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

  const { data: releases } = await supabase
    .schema("txn")
    .from("plan_release")
    .select("released_at, effective_from, released_by")
    .eq("production_plan_id", id)
    .is("deleted_at", null)
    .order("released_at", { ascending: false });

  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Release</h2>
      <p style={{ color: "var(--text-muted)" }}>
        Release approved plan to Production. Items flip to <code>released</code>.
      </p>
      <WorkflowActions
        planId={plan.id}
        version={plan.version}
        status={plan.status_code}
        mode="release"
      />
      <h3 style={{ marginTop: "1.75rem" }}>Release history</h3>
      <DataTable
        columns={["Released at", "Effective from"]}
        rows={(releases ?? []).map((r) => [
          new Date(r.released_at).toLocaleString(),
          new Date(r.effective_from).toLocaleString(),
        ])}
      />
    </div>
  );
}
