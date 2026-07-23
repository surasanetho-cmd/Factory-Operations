import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { StatusPill } from "../page";

export default async function PlanLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: plan } = await supabase
    .schema("txn")
    .from("production_plan")
    .select("id, plan_no, title, status_code, horizon_type, period_start, period_end, version")
    .eq("id", id)
    .is("deleted_at", null)
    .maybeSingle();

  if (!plan) notFound();

  const tabs = [
    { href: `/planning/plans/${id}`, label: "Detail" },
    { href: `/planning/plans/${id}/calendar`, label: "Calendar" },
    { href: `/planning/plans/${id}/capacity`, label: "Capacity" },
    { href: `/planning/plans/${id}/approve`, label: "Approve" },
    { href: `/planning/plans/${id}/release`, label: "Release" },
  ];

  return (
    <div>
      <div style={{ marginBottom: "1rem" }}>
        <Link href="/planning/plans" style={{ color: "var(--text-muted)", fontSize: 13 }}>
          ← Plans
        </Link>
        <div style={{ display: "flex", gap: "1rem", alignItems: "center", marginTop: 8, flexWrap: "wrap" }}>
          <h1 style={{ margin: 0 }}>{plan.plan_no}</h1>
          <StatusPill status={plan.status_code} />
          <span style={{ color: "var(--text-muted)", fontSize: 14 }}>
            {plan.title} · {plan.horizon_type} · {plan.period_start} → {plan.period_end} · v{plan.version}
          </span>
        </div>
      </div>
      <nav
        style={{
          display: "flex",
          gap: "0.35rem",
          borderBottom: "1px solid var(--border)",
          marginBottom: "1.25rem",
          flexWrap: "wrap",
        }}
      >
        {tabs.map((t) => (
          <Link
            key={t.href}
            href={t.href}
            style={{
              padding: "0.65rem 0.9rem",
              color: "var(--text)",
              borderBottom: "2px solid transparent",
              marginBottom: -1,
            }}
          >
            {t.label}
          </Link>
        ))}
      </nav>
      {children}
    </div>
  );
}
