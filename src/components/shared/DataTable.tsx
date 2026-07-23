export function DataTable({
  columns,
  rows,
}: {
  columns: string[];
  rows: string[][];
}) {
  return (
    <div
      style={{
        marginTop: "1rem",
        overflow: "auto",
        border: "1px solid var(--border)",
        borderRadius: 12,
      }}
    >
      <table style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr>
            {columns.map((c) => (
              <th
                key={c}
                style={{
                  textAlign: "left",
                  padding: "0.75rem 1rem",
                  background: "var(--bg-elevated)",
                  borderBottom: "1px solid var(--border)",
                  color: "var(--text-muted)",
                  fontSize: 13,
                  fontWeight: 600,
                }}
              >
                {c}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td
                colSpan={columns.length}
                style={{ padding: "1rem", color: "var(--text-muted)" }}
              >
                No rows
              </td>
            </tr>
          ) : (
            rows.map((row, i) => (
              <tr key={i}>
                {row.map((cell, j) => (
                  <td
                    key={j}
                    style={{
                      padding: "0.7rem 1rem",
                      borderBottom: "1px solid var(--border)",
                      fontSize: 14,
                    }}
                  >
                    {cell}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
