"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { buildMenuTree, type MenuItem, type SessionContext } from "@/lib/auth/types";

export function AppShell({
  context,
  children,
}: {
  context: SessionContext;
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const tree = buildMenuTree(context.menus ?? []);
  const roots = tree.get(null) ?? [];

  async function signOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.replace("/login");
    router.refresh();
  }

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">
          <strong>Factory Operations</strong>
          <span>Auth · RBAC · Menu</span>
        </div>
        <nav>
          {roots.map((item) => (
            <MenuNode
              key={item.id}
              item={item}
              tree={tree}
              pathname={pathname}
            />
          ))}
        </nav>
      </aside>
      <div className="main">
        <header className="topbar">
          <div>
            <div className="user-name">{context.profile?.display_name ?? "User"}</div>
            <div className="user-meta">
              {(context.roles ?? []).join(", ") || "no roles"} ·{" "}
              {context.profile?.email}
            </div>
          </div>
          <button type="button" onClick={signOut} className="signout">
            Sign out
          </button>
        </header>
        <main className="content">{children}</main>
      </div>
      <style jsx>{`
        .shell {
          display: grid;
          grid-template-columns: 260px 1fr;
          min-height: 100vh;
        }
        .sidebar {
          background: linear-gradient(180deg, #15202b 0%, var(--bg-sidebar) 100%);
          border-right: 1px solid var(--app-border);
          padding: 1.25rem 1rem;
          display: flex;
          flex-direction: column;
          gap: 1.5rem;
        }
        .brand {
          display: grid;
          gap: 0.2rem;
          padding: 0.25rem 0.5rem 0.75rem;
          border-bottom: 1px solid var(--app-border);
        }
        .brand strong {
          font-size: 1.05rem;
          letter-spacing: 0.02em;
        }
        .brand span {
          color: var(--text-muted);
          font-size: 0.8rem;
        }
        nav {
          display: grid;
          gap: 0.25rem;
        }
        .main {
          display: flex;
          flex-direction: column;
          min-width: 0;
        }
        .topbar {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 1rem;
          padding: 1rem 1.5rem;
          border-bottom: 1px solid var(--app-border);
          background: rgba(18, 24, 31, 0.72);
          backdrop-filter: blur(8px);
        }
        .user-name {
          font-weight: 600;
        }
        .user-meta {
          color: var(--text-muted);
          font-size: 0.85rem;
        }
        .signout {
          background: transparent;
          border: 1px solid var(--app-border);
          color: var(--text);
          border-radius: 8px;
          padding: 0.45rem 0.8rem;
          cursor: pointer;
        }
        .content {
          padding: 1.5rem;
        }
        @media (max-width: 900px) {
          .shell {
            grid-template-columns: 1fr;
          }
          .sidebar {
            border-right: 0;
            border-bottom: 1px solid var(--app-border);
          }
        }
      `}</style>
    </div>
  );
}

function MenuNode({
  item,
  tree,
  pathname,
}: {
  item: MenuItem;
  tree: Map<string | null, MenuItem[]>;
  pathname: string;
}) {
  const children = tree.get(item.id) ?? [];
  const active = item.path ? pathname === item.path || pathname.startsWith(item.path + "/") : false;

  if (!item.path && children.length === 0) return null;

  return (
    <div className="node">
      {item.path ? (
        <Link href={item.path} className={active ? "link active" : "link"}>
          {item.label}
        </Link>
      ) : (
        <div className="group">{item.label}</div>
      )}
      {children.length > 0 ? (
        <div className="children">
          {children.map((child) => (
            <MenuNode key={child.id} item={child} tree={tree} pathname={pathname} />
          ))}
        </div>
      ) : null}
      <style jsx>{`
        .node {
          display: grid;
          gap: 0.15rem;
        }
        .group {
          padding: 0.55rem 0.65rem 0.2rem;
          color: var(--text-muted);
          font-size: 0.72rem;
          text-transform: uppercase;
          letter-spacing: 0.06em;
        }
        .link {
          display: block;
          padding: 0.5rem 0.65rem;
          border-radius: 8px;
          color: var(--text);
        }
        .link:hover {
          background: var(--accent-soft);
        }
        .link.active {
          background: var(--accent-soft);
          color: #9ec1ff;
        }
        .children {
          padding-left: 0.65rem;
          display: grid;
          gap: 0.1rem;
        }
      `}</style>
    </div>
  );
}
