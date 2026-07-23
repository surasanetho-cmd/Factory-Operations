import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getSessionContext } from "@/lib/auth/session";
import { redirect } from "next/navigation";

export default async function PlansPage() {
  const ctx = await getSessionContext();
  if (!ctx?.permissions.includes("plan.production_plan.read") && !ctx?.roles.includes("admin")) {
    redirect("/dashboard");
  }

  const supabase = await createClient();
  const { data: plans } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("id, plan_no, title, horizon_type, period_start, period_end, status_code, version")
    .is("deleted_at", null)
    .order("period_start", { ascending: false });

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", gap: "1rem", alignItems: "end" }}>
        <div>
          <h1 style={{ marginTop: 0, marginBottom: 4 }}>Planning Header</h1>
          <p style={{ color: "var(--text-muted)", margin: 0 }}>
            Production plans — open a plan for detail, calendar, capacity, approve & release
          </p>
        </div>
      </div>
      <div style={{ marginTop: "1rem" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", border: "1px solid var(--border)", borderRadius: 12, overflow: "hidden" }}>
          <thead>
            <tr style={{ background: "var(--bg-elevated)" }}>
              {["Plan No", "Title", "Horizon", "Period", "Status", ""].map((h) => (
                <th key={h} style={{ textAlign: "left", padding: "0.75rem 1rem", color: "var(--text-muted)", fontSize: 13 }}>
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {(plans ?? []).map((p) => (
              <tr key={p.id}>
                <td style={td}>{p.plan_no}</td>
                <td style={td}>{p.title ?? "—"}</td>
                <td style={td}>{p.horizon_type}</td>
                <td style={td}>
                  {p.period_start} → {p.period_end}
                </td>
                <td style={td}>
                  <StatusPill status={p.status_code} />
                </td>
                <td style={td}>
                  <Link href={`/planning/plans/${p.id}`} style={{ color: "var(--accent)" }}>
                    Open
                  </Link>
                </td>
              </tr>
            ))}
            {(plans ?? []).length === 0 ? (
              <tr>
                <td colSpan={6} style={{ ...td, color: "var(--text-muted)" }}>
                  No plans
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const td: React.CSSProperties = {
  padding: "0.7rem 1rem",
  borderBottom: "1px solid var(--border)",
  fontSize: 14,
};

export function StatusPill({ status }: { status: string }) {
  const color =
    status === "draft"
      ? "#8b9aab"
      : status === "submitted"
        ? "#e0a458"
        : status === "approved"
          ? "#3d8bfd"
          : status === "released"
            ? "#3ecf8e"
            : status === "rejected"
              ? "#e35d6a"
              : "#8b9aab";
  return (
    <span
      style={{
        display: "inline-block",
        padding: "0.15rem 0.55rem",
        borderRadius: 999,
        background: `${color}22`,
        color,
        fontSize: 12,
        fontWeight: 600,
        textTransform: "uppercase",
      }}
    >
      {status}
    </span>
  );
}
