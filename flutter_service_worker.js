'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "678e5e019a79526d0fcca5e29f6e5f78",
".git/config": "ec211835b5685778d5b35fcbde004fb0",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "c3f38333b8fc32dd8b8a3b9cde45adfa",
".git/HEAD": "d6628019dca291cf79c10adb10b6a597",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "35812c34d33d5e5af78a5670767bade6",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "f27318ddc1f90767c4add664ba7eb407",
".git/logs/refs/heads/web": "b553dba6b29d26bb8d114fde80465c8b",
".git/logs/refs/remotes/web/web": "1ee042b8ca7af28baa091d9e29278a01",
".git/objects/07/74c17c0fa7a7e87e24a6935830998d92b52c75": "cd62ee54b7ceea7b2a7804e69b1d9134",
".git/objects/09/cef113a70f6c39a7a65fd01c6634ae6e2a7e68": "d5f457ba31b0553006503803689a1c48",
".git/objects/10/2f843d8c067db718c9b61d49e9a58ab02cc89c": "a559c7ac1718794584a59a06c1626e67",
".git/objects/11/b449bf47ab32be531022dcf4b11daedabb31ec": "1f3de772b5769b61105f8d631e0bce8d",
".git/objects/11/bb98f6d60c9b310571331f5091d255809361e5": "9a43e312df761e697a382f3c9d228ea4",
".git/objects/16/5ce0ddf03a820a38f48cba9aa0c9df9b6e6b79": "71df17c95c3124eada62b59e7dabda78",
".git/objects/1c/84b5aba2d4ec80e9358f89f12ad1a48bdf3533": "57581381ee443f0b462b81abd9dbe299",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/20/1afe538261bd7f9a38bed0524669398070d046": "82a4d6c731c1d8cdc48bce3ab3c11172",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/objects/27/c258b4b5860e2bde30a02d4203cb20b9d263d4": "babf9830315ffaf02b839aa779f9d1ef",
".git/objects/2e/2618d6187c2c0bb871612c764034af54c83d28": "eda6426e95b279b838bf1003f9e57477",
".git/objects/36/f56cdd138ef29a0a98f46b4f7fb619e61af232": "3a9045b18cdab75e54ff1a96b3b3cb15",
".git/objects/37/5b54c20f9a235694cd1ca8db8bdd5d8ff62e11": "a2470aa2c60391de8d1b3adc55e62f34",
".git/objects/3c/54bdc6fc375093f972da81038cf3ec3de8071e": "6432bb460148f49aa076dad5533e0237",
".git/objects/3c/ac54dbc8343ab0c11180f82aabfe705478522d": "c6af3ffd17a68fb55d6075c51dac76b6",
".git/objects/3d/6700677ccf5b799a648bbccc18623822b4ae05": "e4c120fe610fab59c314ca0acf35f6ec",
".git/objects/40/0be8cc74770a02ce7f5072708c9e5c736c08ea": "db143c9ad469728380914e4e5c4d2e48",
".git/objects/41/5c059c8094b888b0159fdedfd4e3cb08a8028e": "86914685ccd40e82a7fe5b70459fb9f7",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4a/39079e580dc9be820cba2fae41238c49eaa798": "ada1a19fea32fbb6719120809b9eae60",
".git/objects/53/ff4fc1e26856ad0dcc5b072f2c511d58b30a57": "377823093ff1d3236401eb6f67ef280e",
".git/objects/5a/471ba9a6c7a6a705f1b0019ca12bb4e8528f8d": "3d1081af79722bcd5af938e24695f5e4",
".git/objects/5a/7b05e1be311772247124911182fda78fde2cec": "d38bfbb93663df272dc4920186bd1040",
".git/objects/65/56120424615a13d0d3db9b02a325bcefd08326": "643908397dcb452a88b63643c1501e38",
".git/objects/68/75dd6b19db7346cae32db7148e6411e122fcab": "f2e2914fabf6d8ec863c25c7c3ea8fab",
".git/objects/6a/d23c7c97d62ad792da31b427828cc4a7cee5a1": "63d0db652338825dfc7d26fe8d674d66",
".git/objects/6f/9cad4c116bc8d72e2497226abb5c05ee64982c": "0d104480d68c1652a53721377a02a882",
".git/objects/71/6ed3a69d9dd33f75aa832be2b9253af570e7a4": "83f17c9e6d1f89c63ca6412b8f650f4b",
".git/objects/71/7117947090611c3967f8681ab1ac0f79bca7fc": "ad4e74c0da46020e04043b5cf7f91098",
".git/objects/71/7809363ed19bdd7e1d78f6e421e40a96bc29e3": "9414a3044cb191cc3f57340f57c3dc93",
".git/objects/71/feb23aa191a5ba683baf1329f55e793ac2e5ef": "ac20414a2ba540a24a4f49c77faac897",
".git/objects/73/05cd3adf193fd96b0f9beed49baf6231e2e308": "1e936d9b3bf5e7da2bbd4207b87e0439",
".git/objects/76/0ff6af40e4946e3b2734c0e69a6e186ab4d8f4": "009b8f1268bb6c384d233bd88764e6f8",
".git/objects/7b/d9ab766417066628bd1871e199fff7c3f1d563": "95e84fd83eee5ca244ecb9b4ef4d1fa4",
".git/objects/7d/60dac4bb82e5a9a666321dffa2fb713c620d12": "6a72869756fdf4ba3a7d759c52e69e3f",
".git/objects/7f/be4f4384e58c3aabaca0cabfa51de16a20f53c": "db60ca0412358a562b27c1add5e07c55",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/87/b59b289dc603f0dfa53ba7b75e6c3953bf07ca": "3a5364668b4fa1cb12b390736e1b2b3e",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8b/78f4e4855004bda15508f350b4f994cbd95d4c": "77444d7a05dc7012a5f8e8b9fe6727b9",
".git/objects/8c/99266130a89547b4344f47e08aacad473b14e0": "41375232ceba14f47b99f9d83708cb79",
".git/objects/92/bafac5f22a7e6ed70290123e06d8be99f6c842": "ba1686fcb5d7dbd5a64eb545cdc722e1",
".git/objects/92/eab450609b7dc5d076ddf6c8416de8209373e0": "9b3d4cb7f5916a87f36a18b466ea7ac4",
".git/objects/94/bfb1463ad8331bfd687bc751b8920b133da744": "fd2d8c0d844b234856b36b93f652048f",
".git/objects/98/6be0840aeb4d3acaceeceb06758356f740a4db": "4781af0529c0155770a4266b7c0397b2",
".git/objects/9b/be0b0482e3cc9c7c575113c1167fe8b4bb1c8d": "2bcde3ed76cd1e4a2122d1e832be2399",
".git/objects/9e/6d61bf7e96d985f347e0c692664e1d43021e82": "c236e9e0c1a7c7fab6af7fff5e1c4b33",
".git/objects/9e/7827a5911fa7455b749e5400b561a721e37031": "aac920f612ad56299bbd23a322bfbca1",
".git/objects/a0/9c340e87b289bd284953c3e8bc847022baee31": "5e3dc38e5119ceb9e1d9ee4a7629a4ee",
".git/objects/a1/16d4ce7d6f5a60d3a22ce2895387c4b621cf2a": "8ff6da2ae882c3a02b1e2bcbebe4e8af",
".git/objects/a4/32a8adcd9952e16b7686987bb5c2a45d3f97af": "bd591f33f00f7ab0a17c7d0c16fd6dc7",
".git/objects/a5/644bc3ae5b9533f8add09f78708e168dae8fdd": "05d0d028e2f6bf22bf475468ccaeca9e",
".git/objects/a5/d98d0a121750d4941545382713fb1723e4fe8a": "42332dc1d116a25e2578f5e039a94457",
".git/objects/a9/8c7be7efb6eeaf46d2c3e638a12f51874cee11": "882417a120266e8808629605c92c8593",
".git/objects/ad/4c0ba9842f4de544316a62269732d33f652961": "d2648c4f7ac6a01d24dedabffef3980b",
".git/objects/ae/a9ee8d015c7b105f2998f72f1a58467c070226": "4ab1de0840a5f930075dfb3f38b2e604",
".git/objects/af/742adee0a85dd21ea96cbd84182e30e085d6cf": "aa25b932ec40efacb1efe27e7cf25d82",
".git/objects/b2/1a64dd66afe07207e8bd633a70659c3f8a44dd": "aa4d36126aa97424da7b4f685cfcca3b",
".git/objects/b5/0254288cc6319d153c4af1d64870d95ee2436f": "468a6506934a07c970a4739eae75eedd",
".git/objects/b5/fbd0eaca4f16e127f2e3223023d6501378bd3d": "2572db9565a028043557511da4575fe2",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b8/e7987b5ffebbb1f76e9f534d67ef507c53f14f": "4e11477a447eab0a2203131bbd46bc71",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/c5/f4bc2a4da91586f3005813077f0d0aa9040f82": "3191028b787554cee4652f5050144bff",
".git/objects/c7/ce739ad5d9a0b605c589faf67fd5c8f1f5e3bb": "d6ec3426a9537852dac973899ef9ae1f",
".git/objects/ca/2d63ee325d7a6c0c56bf50d0d55861a9db1a0a": "5726ccb0e4bfc917678a029ae72da019",
".git/objects/ce/6b7350012d66e232af8e741e45280f9fe70d19": "cb4f592cea5069015a4531fca240c5bf",
".git/objects/d0/faf501dd734e60683b6558ee8f815ca1913e0c": "73c6a3059609a4ae3e4217a01242c58f",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/80ce749ea55b12b92f5db7747290419c975070": "8b0329dbc6565154a5434e6a0f898fdb",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/db/5aceec272c9ec5b278a5deb6a05b4da5b1b47f": "7bc240b422a420904e037c4a6d4902c5",
".git/objects/df/5cfe9e3d9aed4d85c93ae12e5b7b141e6bd87d": "4c537083b1f64229df76e3b426bd94cb",
".git/objects/e0/4636e2b879cc49c87a67a261e0ccdd48ac2d20": "c99b8e15dd04362f7720178fbaac2e25",
".git/objects/e0/ee89774fedc802aae85cb9d59be5adbcbb2f00": "8308cbf44b1684a94cc52c3731bf0aa1",
".git/objects/e0/f847e99c077fa03b02c4760ef900fd34f13ece": "78ab18d92a88e30d816158a7e02c0c41",
".git/objects/e1/a3b486b31e66ad7a5ed5f482b2e89c439eb320": "5cb62bd2035e1a292df391c7dc5dee61",
".git/objects/e7/d6c1cc5f73ccc898455e047343591cbdc7533c": "8275662907851d37eb28f0bee2626ab9",
".git/objects/e8/2c5850db3a3482d0c954a4dc122c02de555ce7": "d357cd906b3805bf81477f5527cca086",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/eb/c0a28ebc90dc3a8cd9eab4f5cba3f79aa8dace": "9b896e9e38315682aa6334aee3d61391",
".git/objects/ec/1af6c5bf26b1825bd49b8c0b8251271ce4e66d": "44b5972c50b04b299909f4715ffec58c",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/5c32f1779c14922f236d01c901871fa9123125": "f39329df81985007e2cc4e3a89ebf17b",
".git/objects/f5/7dac9ae90e8f6ea581e06ef82ce583bec2821a": "8fe9571654c0c6d394110f3160826101",
".git/objects/fe/b5d2cd7d773fee026fc401e0c62a2d9b429828": "d57c4dfe564b5be1ea1fa069bcd9a185",
".git/ORIG_HEAD": "d6a68538d50be48de8bec92556fd4279",
".git/refs/heads/web": "39bd4451abe28bb150d62eb37964015c",
".git/refs/remotes/web/web": "39bd4451abe28bb150d62eb37964015c",
"assets/AssetManifest.bin": "f8d7f32afae3fc4254f23f5bd29e53b9",
"assets/AssetManifest.bin.json": "e15bb66f2e5fc68fcbc9360196f4d2d5",
"assets/AssetManifest.json": "5b9dd378d01abdb2f3a7b77e5b627a01",
"assets/assets/cargos.xlsx": "0b33fb2043786b23f691d73eee0b9781",
"assets/assets/parametros.xlsx": "a231ccc2951e6917253cb3ada7a21c92",
"assets/assets/prof.xlsx": "852098ec5478a0ceda8cae83a0e1f4df",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "c89d9bf33622a44334c16aded0c3f75f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "4724c4f74035f543186b2aa17e831c47",
"/": "4724c4f74035f543186b2aa17e831c47",
"main.dart.js": "e70326c4192366cd374aff114a265f51",
"manifest.json": "4ec450d09bf400b815161bbba43670c8",
"README.md": "d8a082569b792e3913d0d5ffdaeba864",
"version.json": "816d3d59e4c330071fdde0507ec1791d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
