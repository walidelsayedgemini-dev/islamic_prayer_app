{{flutter_js}}
{{flutter_build_config}}

// Use the bundled renderer, not a CDN, so a saved app can start offline.
_flutter.loader.load({config: {canvasKitBaseUrl: 'canvaskit/'}});

if ('serviceWorker' in navigator) {
  let controlled = Boolean(navigator.serviceWorker.controller);
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    if (controlled) location.reload();
    controlled = true;
  });
  navigator.serviceWorker.register('offline-worker.js', {updateViaCache: 'none'})
    .then(registration => {
      function offerUpdate() {
        if (!registration.waiting || !navigator.serviceWorker.controller ||
            document.getElementById('app-update')) return;
        const button = document.createElement('button');
        button.id = 'app-update';
        button.textContent = 'تحديث جديد متاح. اضغط لإعادة تشغيل التطبيق';
        button.style.cssText = 'position:fixed;bottom:90px;left:16px;right:16px;z-index:10000;padding:14px;border:0;border-radius:12px;background:#e6c65c;color:#142d22;font:16px sans-serif;cursor:pointer';
        button.onclick = () => {
          registration.waiting?.postMessage('ACTIVATE_UPDATE');
        };
        document.body.appendChild(button);
      }
      offerUpdate();
      registration.addEventListener('updatefound', () => {
        const worker = registration.installing;
        worker?.addEventListener('statechange', () => {
          if (worker.state === 'installed') offerUpdate();
        });
      });
      // Browser HTTP cache must not hide a newer worker on return visits.
      registration.update().catch(() => {});
    }).catch(error => console.warn('Offline save unavailable', error));
}
