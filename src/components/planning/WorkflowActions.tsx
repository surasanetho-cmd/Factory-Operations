"use client";

import { useState, useTransition } from "react";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export function WorkflowActions({
  planId,
  version,
  status,
  mode,
}: {
  planId: string;
  version: number;
  status: string;
  mode: "approve" | "release";
}) {
  const router = useRouter();
  const [comment, setComment] = useState("");
  const [msg, setMsg] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  const actions =
    mode === "approve"
      ? [
          { action: "submit", label: "Submit", enabled: status === "draft" || status === "rejected", permHint: "update" },
          { action: "approve", label: "Approve", enabled: status === "submitted", permHint: "approve" },
          { action: "reject", label: "Reject", enabled: status === "submitted", permHint: "reject" },
        ]
      : [{ action: "release", label: "Release to Production", enabled: status === "approved", permHint: "release" }];

  async function run(action: string) {
    setMsg(null);
    const supabase = createClient();
    const { data, error } = await supabase.rpc("rpc_plan_workflow", {
      p_plan_id: planId,
      p_action: action,
      p_comment: comment || null,
      p_expected_version: version,
    });
    if (error) {
      setMsg(error.message);
      return;
    }
    const result = data as { ok: boolean; error?: string };
    if (!result.ok) {
      setMsg(result.error ?? "Failed");
      startTransition(() => router.refresh());
      return;
    }
    setMsg(`${action} ok`);
    startTransition(() => router.refresh());
  }

  return (
    <div style={{ display: "grid", gap: "0.85rem", maxWidth: 520 }}>
      {mode === "approve" ? (
        <label style={{ display: "grid", gap: 6, color: "var(--text-muted)", fontSize: 14 }}>
          Comment
          <textarea
            value={comment}
            onChange={(e) => setComment(e.target.value)}
            rows={3}
            style={{
              background: "var(--bg)",
              border: "1px solid var(--app-border)",
              borderRadius: 8,
              color: "var(--text)",
              padding: "0.65rem 0.75rem",
            }}
          />
        </label>
      ) : null}
      <div style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap" }}>
        {actions.map((a) => (
          <button
            key={a.action}
            type="button"
            disabled={!a.enabled || pending}
            onClick={() => void run(a.action)}
            style={{
              background: a.action === "reject" ? "transparent" : "var(--app-accent)",
              color: a.action === "reject" ? "var(--danger)" : "#fff",
              border: a.action === "reject" ? "1px solid var(--danger)" : "0",
              borderRadius: 8,
              padding: "0.6rem 1rem",
              fontWeight: 600,
              cursor: a.enabled ? "pointer" : "not-allowed",
              opacity: a.enabled ? 1 : 0.45,
            }}
          >
            {a.label}
          </button>
        ))}
      </div>
      {msg ? <p style={{ margin: 0, color: "var(--text-muted)" }}>{msg}</p> : null}
    </div>
  );
}
