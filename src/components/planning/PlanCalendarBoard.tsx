"use client";

import { useMemo, useState, useTransition } from "react";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export type CalendarItem = {
  id: string;
  production_line_id: string;
  machine_id: string | null;
  shift_id: string | null;
  planned_date: string;
  planned_start_at: string;
  planned_end_at: string;
  qty: number;
  version: number;
  part_code: string;
  line_code: string;
  status_code: string;
};

export type LineOption = { id: string; code: string; name: string };

export function PlanCalendarBoard({
  planId,
  editable,
  items: initialItems,
  lines,
  dates,
}: {
  planId: string;
  editable: boolean;
  items: CalendarItem[];
  lines: LineOption[];
  dates: string[];
}) {
  const router = useRouter();
  const [items, setItems] = useState(initialItems);
  const [draggingId, setDraggingId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  const byCell = useMemo(() => {
    const map = new Map<string, CalendarItem[]>();
    for (const item of items) {
      const key = `${item.production_line_id}|${item.planned_date}`;
      const list = map.get(key) ?? [];
      list.push(item);
      map.set(key, list);
    }
    return map;
  }, [items]);

  async function dropOn(lineId: string, date: string) {
    if (!draggingId || !editable) return;
    const item = items.find((i) => i.id === draggingId);
    if (!item) return;
    setDraggingId(null);

    const start = new Date(item.planned_start_at);
    const end = new Date(item.planned_end_at);
    const durationMs = end.getTime() - start.getTime();
    const [y, m, d] = date.split("-").map(Number);
    const newStart = new Date(item.planned_start_at);
    newStart.setFullYear(y, m - 1, d);
    const newEnd = new Date(newStart.getTime() + durationMs);

    setMessage("Moving…");
    const supabase = createClient();
    const { data, error } = await supabase.rpc("rpc_plan_item_move", {
      p_item_id: item.id,
      p_expected_version: item.version,
      p_production_line_id: lineId,
      p_machine_id: item.machine_id,
      p_shift_id: item.shift_id,
      p_planned_date: date,
      p_planned_start_at: newStart.toISOString(),
      p_planned_end_at: newEnd.toISOString(),
    });

    if (error) {
      setMessage(error.message);
      return;
    }
    const result = data as { ok: boolean; error?: string; item?: CalendarItem & { version: number } };
    if (!result.ok) {
      setMessage(result.error === "version_conflict" ? "Conflict — refresh and retry" : result.error ?? "Move failed");
      startTransition(() => router.refresh());
      return;
    }

    const line = lines.find((l) => l.id === lineId);
    setItems((prev) =>
      prev.map((i) =>
        i.id === item.id
          ? {
              ...i,
              production_line_id: lineId,
              line_code: line?.code ?? i.line_code,
              planned_date: date,
              planned_start_at: newStart.toISOString(),
              planned_end_at: newEnd.toISOString(),
              version: (result.item?.version as number) ?? i.version + 1,
            }
          : i,
      ),
    );
    setMessage("Moved");
    startTransition(() => router.refresh());
  }

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", gap: "1rem", marginBottom: "0.75rem" }}>
        <p style={{ color: "var(--text-muted)", margin: 0 }}>
          Drag jobs across line × day cells{editable ? "" : " (read-only — plan not draft/rejected)"}.
        </p>
        <span style={{ color: "var(--text-muted)", fontSize: 13 }}>
          {pending ? "Refreshing…" : message}
        </span>
      </div>
      <div style={{ overflow: "auto", border: "1px solid var(--border)", borderRadius: 12 }}>
        <table style={{ borderCollapse: "collapse", minWidth: 900, width: "100%" }}>
          <thead>
            <tr style={{ background: "var(--bg-elevated)" }}>
              <th style={th}>Line</th>
              {dates.map((d) => (
                <th key={d} style={th}>
                  {d.slice(5)}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {lines.map((line) => (
              <tr key={line.id}>
                <td style={{ ...td, fontWeight: 600, whiteSpace: "nowrap" }}>{line.code}</td>
                {dates.map((date) => {
                  const cellItems = byCell.get(`${line.id}|${date}`) ?? [];
                  return (
                    <td
                      key={date}
                      style={{ ...td, minWidth: 140, verticalAlign: "top", background: "rgba(255,255,255,0.02)" }}
                      onDragOver={(e) => editable && e.preventDefault()}
                      onDrop={(e) => {
                        e.preventDefault();
                        void dropOn(line.id, date);
                      }}
                    >
                      <div style={{ display: "grid", gap: 6, minHeight: 64 }}>
                        {cellItems.map((item) => (
                          <div
                            key={item.id}
                            draggable={editable}
                            onDragStart={() => setDraggingId(item.id)}
                            style={{
                              background: "var(--accent-soft)",
                              border: "1px solid rgba(61,139,253,0.35)",
                              borderRadius: 8,
                              padding: "0.4rem 0.5rem",
                              cursor: editable ? "grab" : "default",
                              fontSize: 12,
                            }}
                          >
                            <div style={{ fontWeight: 600 }}>{item.part_code}</div>
                            <div style={{ color: "var(--text-muted)" }}>
                              {fmtTime(item.planned_start_at)}–{fmtTime(item.planned_end_at)} · qty {item.qty}
                            </div>
                          </div>
                        ))}
                      </div>
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p style={{ color: "var(--text-muted)", fontSize: 12, marginTop: 8 }}>Plan {planId.slice(0, 8)}…</p>
    </div>
  );
}

function fmtTime(iso: string) {
  return new Date(iso).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
}

const th: React.CSSProperties = {
  textAlign: "left",
  padding: "0.65rem 0.75rem",
  borderBottom: "1px solid var(--border)",
  color: "var(--text-muted)",
  fontSize: 12,
  position: "sticky",
  top: 0,
};
const td: React.CSSProperties = {
  padding: "0.5rem",
  borderBottom: "1px solid var(--border)",
  borderRight: "1px solid var(--border)",
};
