import { getSessionContext } from "@/lib/auth/session";

export default async function DashboardPage() {
  const ctx = await getSessionContext();

  return (
    <div>
      <h1 style={{ marginTop: 0 }}>Home</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Phase 5 Authentication — session loaded from{" "}
        <code>rpc_auth_session_context</code>.
      </p>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(180px,1fr))",
          gap: "1rem",
          marginTop: "1.25rem",
        }}
      >
        <Card title="Roles" value={String(ctx?.roles?.length ?? 0)} />
        <Card title="Permissions" value={String(ctx?.permissions?.length ?? 0)} />
        <Card title="Menus" value={String(ctx?.menus?.length ?? 0)} />
      </div>
      {ctx?.message ? (
        <p style={{ color: "var(--danger)", marginTop: "1rem" }}>{ctx.message}</p>
      ) : null}
    </div>
  );
}

function Card({ title, value }: { title: string; value: string }) {
  return (
    <div
      style={{
        background: "var(--bg-elevated)",
        border: "1px solid var(--app-border)",
        borderRadius: 12,
        padding: "1rem 1.1rem",
      }}
    >
      <div style={{ color: "var(--text-muted)", fontSize: 13 }}>{title}</div>
      <div style={{ fontSize: 28, fontWeight: 700, marginTop: 4 }}>{value}</div>
    </div>
  );
}
