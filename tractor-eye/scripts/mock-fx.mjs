// Local integration fixture, not a production fx replacement. No serial/audio.
import { createServer } from 'node:http'
import { readFile } from 'node:fs/promises'
import { resolve, extname, sep } from 'node:path'
import { fileURLToPath } from 'node:url'
import { randomUUID } from 'node:crypto'
import { createInterface } from 'node:readline'
import { WebSocketServer, WebSocket } from 'ws'

const port = Number(process.env.MOCK_FX_PORT ?? 4174)
const root = fileURLToPath(new URL('../dist/', import.meta.url))
const sessionId = randomUUID()
let seq = 0
let state = { mode: 'sleeping', gaze: { x: 0, y: 0 } }
const synced = new Set()
const mime = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.json': 'application/json' }
const server = createServer(async (req, res) => {
  res.setHeader('Cache-Control', 'no-store')
  if (req.method !== 'GET') { res.writeHead(405).end(); return }
  try {
    const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname)
    if (pathname === '/config.json') {
      res.setHeader('Content-Type', 'application/json')
      res.end(JSON.stringify({ screenId: 'tractor-eye', websocket: { enabled: true, url: '/ws' } }))
      return
    }
    if (pathname === '/healthz') { res.end('ok'); return }
    const path = resolve(root, `.${pathname === '/' ? '/index.html' : pathname}`)
    if (!path.startsWith(root.endsWith(sep) ? root : root + sep)) { res.writeHead(403).end(); return }
    const data = await readFile(path)
    res.setHeader('Content-Type', mime[extname(path)] ?? 'application/octet-stream')
    res.end(data)
  } catch { res.writeHead(404).end('Build first with npm run build') }
})
const wss = new WebSocketServer({
  server, path: '/ws', maxPayload: 8192,
  verifyClient: ({ origin }) => origin === `http://127.0.0.1:${port}` || origin === `http://localhost:${port}`,
})
wss.on('error', error => { console.error(error.message); process.exitCode = 1 })
const send = (socket, message) => {
  if (socket.readyState === WebSocket.OPEN) socket.send(JSON.stringify(message))
}
wss.on('connection', socket => {
  socket.on('error', () => {})
  socket.on('close', () => synced.delete(socket))
  socket.on('message', (data, binary) => {
    try {
      if (binary) throw new Error('text frames only')
      const message = JSON.parse(data.toString())
      if (message.v !== 1) throw new Error('version')
      if (message.type === 'hello' && message.screenId === 'tractor-eye' && !synced.has(socket)) {
        send(socket, { v: 1, type: 'snapshot', sessionId, seq, state })
        synced.add(socket)
        console.log('Eye synchronized at sequence', seq)
      } else if (message.type === 'ping' && synced.has(socket)) {
        send(socket, { v: 1, type: 'pong', id: message.id })
      } else throw new Error('unexpected message')
    } catch { socket.close(1008, 'Invalid mock protocol message') }
  })
})
const input = createInterface({ input: process.stdin })
input.on('line', line => {
  const action = line.trim()
  if (action === 'disconnect') {
    for (const socket of synced) socket.close(1012, 'Mock restart')
    return
  }
  if (!['wake', 'close', 'reset'].includes(action)) {
    console.log('Commands: wake | close | reset | disconnect')
    return
  }
  state = action === 'wake'
    ? { mode: 'tipping', gaze: { x: -.25, y: -.65 } }
    : { mode: 'sleeping', gaze: { x: 0, y: 0 } }
  const command = { type: action === 'reset' ? 'system/reset' : `eye/${action}` }
  const envelope = { v: 1, type: 'command', sessionId, seq: ++seq, expiresAtMs: Date.now() + 2000, command }
  for (const socket of synced) send(socket, envelope)
  console.log('Sent', command.type, 'sequence', seq, 'to', synced.size, 'screen(s)')
})
server.on('error', error => { console.error(error.message); process.exit(1) })
server.listen(port, '127.0.0.1', () => {
  console.log(`Mock fx: http://127.0.0.1:${port}/ — type wake, close, reset, or disconnect then Enter`)
})
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => {
  input.close()
  for (const socket of wss.clients) socket.terminate()
  wss.close()
  server.close()
})
