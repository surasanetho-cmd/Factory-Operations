export type MenuItem = {
  id: string;
  parent_id: string | null;
  code: string;
  label: string;
  path: string | null;
  icon: string | null;
  sort_order: number;
  module: string | null;
  permission_code: string | null;
};

export type SessionContext = {
  authenticated: boolean;
  profile: {
    id: string;
    employee_code: string;
    display_name: string;
    email: string;
    default_plant_id: string | null;
    locale: string;
    theme_pref: string;
    sidebar_collapsed: boolean;
  } | null;
  roles: string[];
  permissions: string[];
  menus: MenuItem[];
  message?: string;
};

export function buildMenuTree(items: MenuItem[]) {
  const byParent = new Map<string | null, MenuItem[]>();
  for (const item of items) {
    const key = item.parent_id;
    const list = byParent.get(key) ?? [];
    list.push(item);
    byParent.set(key, list);
  }
  for (const list of byParent.values()) {
    list.sort((a, b) => a.sort_order - b.sort_order || a.label.localeCompare(b.label));
  }
  return byParent;
}
