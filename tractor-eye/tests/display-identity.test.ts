import assert from 'node:assert/strict'
import { test } from 'node:test'
import { displayIdentity } from '../src/network/display-identity.ts'

test('display identity persists only the versioned client ID', t => {
  const values = new Map<string, string>()
  const original = Object.getOwnPropertyDescriptor(globalThis, 'localStorage')
  Object.defineProperty(globalThis, 'localStorage', { configurable: true, value: {
    getItem: (key: string) => values.get(key) ?? null,
    setItem: (key: string, value: string) => values.set(key, value),
  } })
  t.after(() => {
    if (original) Object.defineProperty(globalThis, 'localStorage', original)
    else Reflect.deleteProperty(globalThis, 'localStorage')
  })
  const first = displayIdentity('http://fx.dylfi/?name=iPad')
  const next = displayIdentity('http://fx.dylfi/')
  assert.equal(first.clientId, next.clientId)
  assert.equal(first.clientName, 'iPad')
  assert.equal(next.clientName, undefined, 'the server should retain the saved name or derive a label from user agent')
  assert.deepEqual([...values.keys()], ['fx.display-client.v1'])
  assert.equal(displayIdentity('http://fx.dylfi/?client=pi-eye&name=Pi-eye').clientId, 'pi-eye')
  assert.equal(values.get('fx.display-client.v1'), first.clientId)
})

test('display identity tolerates denied storage and bounds supplied labels', t => {
  const original = Object.getOwnPropertyDescriptor(globalThis, 'localStorage')
  Object.defineProperty(globalThis, 'localStorage', { configurable: true, get() { throw new Error('Storage denied') } })
  t.after(() => {
    if (original) Object.defineProperty(globalThis, 'localStorage', original)
    else Reflect.deleteProperty(globalThis, 'localStorage')
  })
  assert.ok(displayIdentity('http://fx.dylfi/').clientId.length > 0)
  const long = 'x'.repeat(500)
  const supplied = displayIdentity(`http://fx.dylfi/?client=${long}&name=${long}`)
  assert.equal(supplied.clientId.length, 128)
  assert.equal(supplied.clientName?.length, 128)
  const unicode = displayIdentity(`http://fx.dylfi/?client=${'👁'.repeat(100)}&name=${'👁'.repeat(100)}`)
  assert.ok(new TextEncoder().encode(unicode.clientId).length <= 128)
  assert.ok(new TextEncoder().encode(unicode.clientName).length <= 128)
})
