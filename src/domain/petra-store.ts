import { emptyStore, type PetraStore } from "./petra-data.js";

const KEY = "petra-store-v1";

export function loadStore(): PetraStore {
  try {
    const raw = globalThis.localStorage?.getItem(KEY);
    return raw ? JSON.parse(raw) as PetraStore : emptyStore();
  } catch { return emptyStore(); }
}

export function saveStore(store: PetraStore): void {
  globalThis.localStorage?.setItem(KEY, JSON.stringify(store));
}
