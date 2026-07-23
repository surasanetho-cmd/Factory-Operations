export default function PlaceholderMasterPage({ title }: { title: string }) {
  return (
    <div>
      <h1 style={{ marginTop: 0 }}>{title}</h1>
      <p style={{ color: "var(--text-muted)" }}>
        Master screen shell ready — CRUD UI follows after Auth phase.
      </p>
    </div>
  );
}
