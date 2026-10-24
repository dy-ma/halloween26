// Identity is only a display label; it is not an authentication credential.
const storageKey = 'fx.display-client.v1'
const encoder = new TextEncoder()
const bounded = (value: string) => {
  let result = '', bytes = 0
  for (const character of value) {
    bytes += encoder.encode(character).length
    if (bytes > 128) break
    result += character
  }
  return result
}

export function displayIdentity(pageUrl: string): { clientId: string; clientName?: string } {
  const query = new URL(pageUrl).searchParams
  const explicit = query.get('client')
  let id = explicit
  if (!id) {
    try { id = localStorage.getItem(storageKey) } catch { /* Private browsing may deny storage. */ }
    if (!id) {
      id = `display-${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`
      try { localStorage.setItem(storageKey, id) } catch { /* This session can still connect. */ }
    }
  }
  const name = query.get('name')
  return { clientId: bounded(id), ...(name ? { clientName: bounded(name) } : {}) }
}
