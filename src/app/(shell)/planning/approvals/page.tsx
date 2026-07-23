import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { StatusPill } from "../plans/page";

export default async function ApprovalsInboxPage() {
  const supabase = await createClient();
  const { data: plans } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("id, plan_no, title, status_code, period_start, period_end, updated_at")
    .in("status_code", ["submitted", "approved"])
    .is("deleted_at", null)
    .order("updated_at", { ascending: false });

  return (
    <div>
      <h1 style={{ marginTop: 0 }}>Approvals</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Inbox for submit / approve / release actions
      </p>
      <table style={{ width: "100%", borderCollapse: "collapse", border: "1px solid var(--border)", borderRadius: 12, overflow: "hidden" }}>
        <thead>
          <tr style={{ background: "var(--bg-elevated)" }}>
            {["Plan", "Period", "Status", ""].map((h) => (
              <th key={h} style={{ textAlign: "left", padding: "0.75rem 1rem", color: "var(--text-muted)", fontSize: 13 }}>
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {(plans ?? []).map((p) => (
            <tr key={p.id}>
              <td style={td}>
                <div style={{ fontWeight: 600 }}>{p.plan_no}</div>
                <div style={{ color: "var(--text-muted)", fontSize: 12 }}>{p.title}</div>
              </td>
              <td style={td}>
                {p.period_start} → {p.period_end}
              </td>
              <td style={td}>
                <StatusPill status={p.status_code} />
              </td>
              <td style={td}>
                <Link
                  href={
                    p.status_code === "approved"
                      ? `/planning/plans/${p.id}/release`
                      : `/planning/plans/${p.id}/approve`
                  }
                  style={{ color: "var(--accent)" }}
                >
                  Review
                </Link>
              </td>
            </tr>
          ))}
          {(plans ?? []).length === 0 ? (
            <tr>
              <td colSpan={4} style={{ ...td, color: "var(--text-muted)" }}>
                No plans waiting
              </td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </div>
  );
}

const td: React.CSSProperties = {
  padding: "0.7rem 1rem",
  borderBottom: "1px solid var(--border)",
  fontSize: 14,
};
