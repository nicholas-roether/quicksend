'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "01d75b385acf29bba13aea3208e86562",
"assets/assets/fonts/quicksand-bold.ttf": "809cd8ab97c465b57cb1a44b1795f12c",
"assets/assets/fonts/quicksand-light.ttf": "5d51b01f8405b8c5ae5df55a8c3019cc",
"assets/assets/fonts/quicksand-medium.ttf": "f65d1a07e0f4521c99d900e31e4bc530",
"assets/assets/fonts/quicksand-regular.ttf": "678b12a6a938c32eb5fa88f2f439c2df",
"assets/assets/img/icon.png": "c8d5993b69efb5591e89b30ea0f773dc",
"assets/assets/img/icon_transparent.png": "be88aeb3eb323c0fa4a7a793afe7a2b5",
"assets/assets/img/loading_anim.gif": "f924799363ab9946135ade7c8253b9e6",
"assets/assets/img/profile-pic.png": "5a021ab95b4d2a0c8e7511c40ca7bb2f",
"assets/FontManifest.json": "ec9bb9b8212b2c83452637dcdcda4374",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/NOTICES": "8804177c3b5b283d9f9be09a25ca4eab",
"assets/packages/fast_rsa/web/assets/rsa.wasm": "aa77518307b6836f87c13f0cdc20d19c",
"assets/packages/fast_rsa/web/assets/wasm_exec.js": "2051f5cd4ddbe193b2379e6517830da6",
"assets/packages/fast_rsa/web/assets/worker.js": "58138f21ef423745f694f8324a5ccec9",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"favicon.ico": "5b46f83d4ece12223559038d1c17d8ca",
"flutter.js": "eb2682e33f25cd8f1fc59011497c35f8",
"icons/android-icon-144x144.png": "f43d70b7fe87243a26f31ecdd2a6c04f",
"icons/android-icon-192x192.png": "4c75b157a4d22fa9599f46f949e764eb",
"icons/android-icon-36x36.png": "c9ad16cb7dc87cac498cf830517d7da7",
"icons/android-icon-48x48.png": "849199599788b150595bcc220c585dce",
"icons/android-icon-72x72.png": "964dd96a1f8bf6375bd8bb19e2fcf362",
"icons/android-icon-96x96.png": "0bdabd2abfc19b429c68500d08a68504",
"icons/apple-icon-114x114.png": "69f3e6937f260e3db746586e0501a2d0",
"icons/apple-icon-120x120.png": "a880068a333d07f25c97fe84dd7c28af",
"icons/apple-icon-144x144.png": "f43d70b7fe87243a26f31ecdd2a6c04f",
"icons/apple-icon-152x152.png": "8dc69cf968c01585452cf93c32786214",
"icons/apple-icon-180x180.png": "6330e9aa8ddbda5407912bb86503979f",
"icons/apple-icon-57x57.png": "a255fed4f8b7f314ab4377dac6ce9c2c",
"icons/apple-icon-60x60.png": "ae9ab238b31dcf951d718ec30fd326ef",
"icons/apple-icon-72x72.png": "964dd96a1f8bf6375bd8bb19e2fcf362",
"icons/apple-icon-76x76.png": "69d1ba0d360d52e49ca5f87a9d0734e1",
"icons/apple-icon-precomposed.png": "37c8ea47bfd2da9b4c32e6b270193526",
"icons/apple-icon.png": "37c8ea47bfd2da9b4c32e6b270193526",
"icons/favicon-16x16.png": "36ad4286970c25864cea2dcdabad5b60",
"icons/favicon-32x32.png": "150bf2d7647d2ca5da883a6ba55b7a5b",
"icons/favicon-96x96.png": "0bdabd2abfc19b429c68500d08a68504",
"icons/ms-icon-144x144.png": "f43d70b7fe87243a26f31ecdd2a6c04f",
"icons/ms-icon-150x150.png": "42049db8739a5c30febeb1f08ec8c925",
"icons/ms-icon-310x310.png": "ae085a33319f9ed3bacc2295bd4b91d2",
"icons/ms-icon-70x70.png": "aeeb1fa3fbdc69757b7b424ab86c970c",
"index.html": "7318c63583770c675ccd1c9c79ec7b51",
"/": "7318c63583770c675ccd1c9c79ec7b51",
"main.dart.js": "d1e1b48bc095e537a316b2af376abceb",
"manifest.json": "36ab6e16419088b3fa20f3ad6692071e",
"splash/img/dark-1x.png": "48bc062ad51194b95bae4cb521ecafb8",
"splash/img/dark-2x.png": "9badbafdca3eed763c9433c9c077b5a8",
"splash/img/dark-3x.png": "0ee06d803ed82287a57e769f3837713a",
"splash/img/dark-4x.png": "91eb033ad633c6af4f709c8018a6af6b",
"splash/img/light-1x.png": "48bc062ad51194b95bae4cb521ecafb8",
"splash/img/light-2x.png": "9badbafdca3eed763c9433c9c077b5a8",
"splash/img/light-3x.png": "0ee06d803ed82287a57e769f3837713a",
"splash/img/light-4x.png": "91eb033ad633c6af4f709c8018a6af6b",
"splash/splash.js": "f6ee10f0a11f96089a97623ece9a1367",
"splash/style.css": "16fcaf2dfc0fbe0903040db962203a32",
"version.json": "98759ccada64860ee674a3e88233dd04"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
