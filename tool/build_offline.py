"""Generate an atomic, per-build offline shell after flutter build web."""
import hashlib
import json
from pathlib import Path

root = Path('build/web')
# Keep install small. Media is cached only when used, never downloaded in bulk.
files = sorted(p.relative_to(root).as_posix() for p in root.rglob('*')
               if p.is_file() and p.name not in {
                   'flutter_service_worker.js', 'offline-worker.js', '.nojekyll'}
               and not p.relative_to(root).as_posix().startswith(
                   ('assets/assets/images/', 'assets/assets/audio/')))
digest = hashlib.sha256()
for name in files:
    digest.update(name.encode())
    digest.update((root / name).read_bytes())
version = digest.hexdigest()[:16]
script = r'''
const VERSION = __VERSION__;
const PREFIX = 'firdaws:' + self.registration.scope;
const CACHE = PREFIX + VERSION;
const CORE = __FILES__;
self.addEventListener('install', event => {
  // No skipWaiting here: never replace a running app without consent.
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    try {
      await cache.addAll(CORE.map(name => new Request(name, {cache: 'reload'})));
    } catch (error) {
      await caches.delete(CACHE);
      throw error;
    }
  })());
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      if (key.startsWith(PREFIX) && key !== CACHE) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});
self.addEventListener('message', event => {
  if (event.data === 'ACTIVATE_UPDATE') self.skipWaiting();
});
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  const scope = new URL(self.registration.scope);
  if (event.request.method !== 'GET' || url.origin !== scope.origin ||
      !url.pathname.startsWith(scope.pathname) ||
      url.pathname.endsWith('/offline-worker.js') ||
      url.pathname.endsWith('/version.json')) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    const request = event.request.mode === 'navigate'
      ? new Request(new URL('index.html', scope)) : event.request;
    const cached = await cache.match(request, {ignoreSearch: true});
    if (cached) return cached;
    const response = await fetch(event.request);
    if (response.ok && response.type === 'basic' &&
        !event.request.headers.has('range')) {
      await cache.put(request, response.clone());
    }
    return response;
  })());
});
'''
(root / 'offline-worker.js').write_text(
    script.replace('__VERSION__', json.dumps(version)).replace(
        '__FILES__', json.dumps(files)), encoding='utf-8')
print(f'Offline shell {version}: {len(files)} files')
