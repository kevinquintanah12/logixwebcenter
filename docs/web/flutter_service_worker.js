'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "c606f082693f32bfa37f89373877ef8b",
"assets/AssetManifest.bin.json": "38d83145a87464f9e6ac607971d5f952",
"assets/AssetManifest.json": "ecc68fa0a9ce74cb7e82053c7e86ff97",
"assets/assets/flags/England.svg": "2150fadb14eed260feacc7c3c88e3b47",
"assets/assets/flags/france.svg": "87a495513d6c192906899920b1acc94d",
"assets/assets/flags/German.svg": "72df5c08d2a5502dcebd31d7894fe1f4",
"assets/assets/flags/India.svg": "a35b607be71759cdcf3855c1fa197986",
"assets/assets/flags/Italy.svg": "ab2569cbf2b9eca5b497000f28382ad9",
"assets/assets/flags/japanese.svg": "879f4b827db0e6539e2dfca6f9e770ac",
"assets/assets/fonts/grandis_extended/GrandisExtended-Black.ttf": "1b09b3c563c0ebb0ee3f3a989fdb24dd",
"assets/assets/fonts/grandis_extended/GrandisExtended-Bold.ttf": "9f2aef3f47545255d4f4d2de33798ca8",
"assets/assets/fonts/grandis_extended/GrandisExtended-Medium.ttf": "a0d504c50c6af5629bc400cf6fba517d",
"assets/assets/fonts/grandis_extended/GrandisExtended-Regular.ttf": "33d75e67d7986763ff0e8609bce63fe6",
"assets/assets/fonts/grandis_extended/GrandisExtended-Thin.ttf": "05776a08da7cccec80e7bb862cac761d",
"assets/assets/fonts/plus_jakarta/PlusJakartaDisplay-Bold.otf": "1e5642fdde54004e7ac175ceb48b9a1f",
"assets/assets/fonts/plus_jakarta/PlusJakartaDisplay-Medium.otf": "1f27f846a2a8e5c0b3162e3fb1d78865",
"assets/assets/fonts/plus_jakarta/PlusJakartaDisplay-Regular.otf": "a81ce9b45769e9a0227e6949a9b4b9c8",
"assets/assets/icons/Accessories.svg": "2a6cee8ef674c6e5421f172e7cacce2d",
"assets/assets/icons/Address.svg": "482cae5fc5a6e5f53c31bb21f9cae8a4",
"assets/assets/icons/Arrow%2520-%2520Down.svg": "d63a6c9f90c0bfec2462b74e8081ffc7",
"assets/assets/icons/Arrow%2520-%2520Left.svg": "b0178c95f40ca6abcccea2bce3ce38c4",
"assets/assets/icons/Arrow%2520-%2520Right.svg": "2bb9300824633b8beb92fbd8897abb5b",
"assets/assets/icons/Arrow%2520-%2520Up.svg": "0eca929b8073ce4c8c4cf5a56d4a0e01",
"assets/assets/icons/Bag.svg": "3d6872b253693631428f57248df83b5b",
"assets/assets/icons/bag_full.svg": "fce80aaa4be7a75b67119baa641eaf6d",
"assets/assets/icons/Behance.svg": "deea4904ef087695e7d69c5ec62ec74e",
"assets/assets/icons/Bookmark.svg": "5ac947ef310d30b458345e3f8d6af4b8",
"assets/assets/icons/Calender.svg": "a76476d0106c84f1f1ec8e70d35f7020",
"assets/assets/icons/Call.svg": "b409188d7192a5fe6e6b6fc2f8a209fd",
"assets/assets/icons/Camera-add.svg": "111202d08c081b13a01c7c7f6aa4f594",
"assets/assets/icons/Camera-Bold.svg": "861a201a87e921b263c0f96f08a18028",
"assets/assets/icons/card.svg": "0fbcd318614a350505c69737ee9ff50b",
"assets/assets/icons/Card_Pattern.svg": "a6c10f8624ff8fc248c12cd1d8a23f17",
"assets/assets/icons/Cash.svg": "4db30cad04df02f3272b73b0b1db81f2",
"assets/assets/icons/Category.svg": "83bedadff1b411792b0b2190a754bec6",
"assets/assets/icons/Chat-add.svg": "f0f28cd7e8b7bd034ff3936e3ccbae18",
"assets/assets/icons/Chat.svg": "bc67db756016b2d5efe26a9ba515004f",
"assets/assets/icons/Child.svg": "f785030f16ae6d996b394c27bb2c5adc",
"assets/assets/icons/Clock.svg": "2ae9b447f785b786d0f7cc13f7e65fe4",
"assets/assets/icons/Close-Circle.svg": "92750584201af5fa9d0081e495e47efd",
"assets/assets/icons/Close.svg": "35151040b045a54ba4264707a6efa424",
"assets/assets/icons/Coupon.svg": "83fd9f477473270d9bddbcc6fdc0dae8",
"assets/assets/icons/CVV.svg": "d843cbbabcbe9f9f4da0aa629eb2609e",
"assets/assets/icons/Danger%2520Circle.svg": "6e7e430fff0b7cb2c1d62935b397254a",
"assets/assets/icons/Delete.svg": "7dc67a67b739abf12f2b3c84336c69f2",
"assets/assets/icons/Delivery.svg": "a9f803f9003d013e4c2b23880ada6e29",
"assets/assets/icons/diamond.svg": "252b34d4a4a27e0422bcc7d49b340448",
"assets/assets/icons/Discount.svg": "dc3fce65b71cb267268f2345fe823844",
"assets/assets/icons/Discount_tag.svg": "43d20207e8e8b85ecb5411e115144671",
"assets/assets/icons/Dislike.svg": "68110b499d4fccb18e6e06fc70d2a460",
"assets/assets/icons/dot.svg": "f9bf3af217ddfb33aaa5474d0471f12b",
"assets/assets/icons/DotsH.svg": "b3166c0569e9b2855ccd504e4a97bcc9",
"assets/assets/icons/DotsV.svg": "e2c719b975ed6bb67d10cff103d26fa8",
"assets/assets/icons/Doublecheck.svg": "7cf9316efb71b58ecdc6166275c471d8",
"assets/assets/icons/Dribbble.svg": "dfac2d297e6d2d5c4827dc728297dcb8",
"assets/assets/icons/Edit%2520Square.svg": "15cc6eff0b30aaa6d1d19587d375c6ec",
"assets/assets/icons/Edit-Bold.svg": "0c80771c4bb414198df955a317c85f2a",
"assets/assets/icons/Emoji.svg": "18f793180b9c4b34919d047028098a9f",
"assets/assets/icons/Facebook.svg": "21247ef09c0bde91367781b8a1f69109",
"assets/assets/icons/FaceId.svg": "21d3df947a5a59ca930dcee1d649a810",
"assets/assets/icons/FAQ.svg": "4bf93ee85282c364b8046af77f057a15",
"assets/assets/icons/Filter.svg": "a0342114cb79b5cc9f4b3a958c0f1ed8",
"assets/assets/icons/Fingerprint.svg": "01a8bb07e402b7c85475765f0d3f37f8",
"assets/assets/icons/Flashlight.svg": "8bf62049bf778404442cef91bb024a53",
"assets/assets/icons/Gift.svg": "3f4d8a3acb176effee2201a0c5d66795",
"assets/assets/icons/Help.svg": "60d6b153e0301ee4a28b9c9de7c4c9b9",
"assets/assets/icons/Image.svg": "6f4c27958e4558c04f64f988778ad2f1",
"assets/assets/icons/info.svg": "25ecbd8a34e907cdde7558e9ab3726a0",
"assets/assets/icons/Instagram.svg": "2a981272313ab565b169de53b771f36b",
"assets/assets/icons/Language.svg": "a4248a8a6e4308364c4fcc2ff6d9ea61",
"assets/assets/icons/Like.svg": "f21a6eeeba41976bbb2d88e5533a8dbd",
"assets/assets/icons/Link.svg": "eeaa36f38bbd8cc2442a9d2dafc9998a",
"assets/assets/icons/Linkedin.svg": "e8c05e63206e6b1e19ee9856c343205d",
"assets/assets/icons/Loading.svg": "10f37efe1d477572e399c90664ffb334",
"assets/assets/icons/Location.svg": "cb1ad1ca63ce294f471c9d2b07c7f2c1",
"assets/assets/icons/Lock.svg": "84871668c425b3d453c9c07a9edb375b",
"assets/assets/icons/Logout.svg": "3437047a2def4b7003e623c82fb92006",
"assets/assets/icons/Man&Woman.svg": "7c766ba1d677c3d9b3143d8581fa79fb",
"assets/assets/icons/Man.svg": "b0bc5a119023b9c188e68af365bf382b",
"assets/assets/icons/Message.svg": "8bc665df7c2d21baebb0335088790a34",
"assets/assets/icons/miniDown.svg": "96742d60dbe4e4983f25e8cae3ad65a0",
"assets/assets/icons/miniLeft.svg": "91b28bf477ed7458b3d10602c78a97b9",
"assets/assets/icons/miniRight.svg": "1c530b78f629abe3192c47b8e252e1b5",
"assets/assets/icons/miniTop.svg": "35e1635ef245ea41d240db02239dabbb",
"assets/assets/icons/Minus.svg": "91f3832437f8a8fd342e673b6c8fb9c0",
"assets/assets/icons/Mylocation.svg": "02a7b431b41e778c5e1810f243bb3ed9",
"assets/assets/icons/Newcard.svg": "50e9da3822eff4accba030e73da67c51",
"assets/assets/icons/Notification.svg": "fb90504a46709d006109b2d916833251",
"assets/assets/icons/Order.svg": "102c885f33e9dc17248c4320cb71645e",
"assets/assets/icons/package.svg": "6eb8c2985e6d8ed1a6af6fdb183da5f6",
"assets/assets/icons/Payonline.svg": "ddb6351f1952c24ca0c7dadd67a3ae87",
"assets/assets/icons/Plus1.svg": "082fab37118b5c87ad97218a3c7b1c55",
"assets/assets/icons/Preferences.svg": "b26f8c31b887ed8ac257b7893c26e25e",
"assets/assets/icons/Product.svg": "c050f613012500ad8179104275654e80",
"assets/assets/icons/Profile.svg": "06e07af4a7b9b9b18e0551e20062ce67",
"assets/assets/icons/RECETA%25204%2520MARZO.pdf": "a8b4cc4b7b14c28ddd1f818b3156fcc6",
"assets/assets/icons/Return.svg": "71d5fd134a9642d13da12f1b38cdfdd8",
"assets/assets/icons/Sale.svg": "d7575e82f0ba870b4ff8e52c003d6517",
"assets/assets/icons/Scan.svg": "443731f739069ceedb6b09e827d100d1",
"assets/assets/icons/Search.svg": "faf1640821c283fd4a3b0b0c867faf8c",
"assets/assets/icons/Send.svg": "e8d1337eb1a24eb46bac5975b810b333",
"assets/assets/icons/Setting.svg": "ed47eb1a5c474af9801bfe5936f04e85",
"assets/assets/icons/Share.svg": "a07230ceaaff01117a3351c2090bd5da",
"assets/assets/icons/Shop.svg": "61c0ff8e6d64a22379ad7df3c5464f05",
"assets/assets/icons/Show.svg": "c22761d2e45e304594f0e17159066e9a",
"assets/assets/icons/Singlecheck.svg": "e132858fc7d8510c9f4654253d859489",
"assets/assets/icons/Sizeguid.svg": "c0c70c222fc287cc6632b54c75ba85e7",
"assets/assets/icons/Sort.svg": "1f036ed3ffc2f6be63e7d8bfdacf8756",
"assets/assets/icons/Standard.svg": "c534f926996d0111afe0d30cad932b13",
"assets/assets/icons/Star-bold.svg": "209ca45311f67c499d368f658fedd0e6",
"assets/assets/icons/Star.svg": "b098fd9ed04d0582b0b0a927f07b9f82",
"assets/assets/icons/Star_filled.svg": "8da656b625dff45a2c48a56c36f84605",
"assets/assets/icons/Stores.svg": "dd8ae6d55c3084baa3bfa2d276d25256",
"assets/assets/icons/Trackorder.svg": "583d0d4ef6c3f6124f9bfc1b72e95721",
"assets/assets/icons/transport.png": "2615cebf759dea91526a07c2af3d0f36",
"assets/assets/icons/Travel.svg": "4888b869cf149a09d075cbb83e96ea76",
"assets/assets/icons/twitter.svg": "2d8b6184ad31b892cb473dcffe791411",
"assets/assets/icons/Wallet.svg": "a8b46a29acc5631746899b7ffbb223de",
"assets/assets/icons/Wishlist.svg": "5c3a40ef9eb9ff9755db295486804afd",
"assets/assets/icons/Woman.svg": "8271221148a7895d6b091b47112746eb",
"assets/assets/icons/world_map.svg": "78c374aaf76123d02e879e769181127a",
"assets/assets/Illustration/EmptyState_darkTheme.png": "75f4dcd3bdf18519d4b0de2e06fe9ff7",
"assets/assets/Illustration/EmptyState_lightTheme.png": "fecfdc9a1ab653ea959606536b623055",
"assets/assets/Illustration/faceId.png": "431f634f005f5c32b0296b91ad0116e8",
"assets/assets/Illustration/faceId_dark.png": "3cb8ef92fb2f96124053b0af1afcf5f6",
"assets/assets/Illustration/Failed_darkTheme.png": "c9672b901f22fa2cfbad41d0fb418d2a",
"assets/assets/Illustration/Failed_lightTheme.png": "b9b329580b9b8dadc0c0d4f46cba0867",
"assets/assets/Illustration/fingerprint.png": "a30d227ef529907b1ce828d760bea6c7",
"assets/assets/Illustration/fingerprint_dark.png": "9e16723e6aac9d2aa99e52f7365ceb04",
"assets/assets/Illustration/Help_darkTheme.png": "47cd37ac3532d9d1d8c60b57cdc61ca7",
"assets/assets/Illustration/Help_lightTheme.png": "828da80b74d5d77f6f536ad2c9f618e4",
"assets/assets/Illustration/Illustration-1.png": "1f1b5ee4ae9f5347c8d758bd0d085f40",
"assets/assets/Illustration/Illustration-2.png": "34a279296f06659a0d39907877693aed",
"assets/assets/Illustration/Illustration-3.png": "d9bea71f50cb8c8a4764b930a7f4f086",
"assets/assets/Illustration/Illustration-4.png": "a4be058ed6d0cb0a37a0bbfa1dd7c335",
"assets/assets/Illustration/Illustration_darkTheme_0.png": "9c2b5e6a33cfcabe77f5e3381d3eadcc",
"assets/assets/Illustration/Illustration_darkTheme_1.png": "4b39992b72df432578a47ee5ccaffca1",
"assets/assets/Illustration/Illustration_darkTheme_2.png": "35088005212f0547c388b3f36058d599",
"assets/assets/Illustration/Illustration_darkTheme_3.png": "c0d50929286c6b0ff4d3cf74fd299baa",
"assets/assets/Illustration/Illustration_darkTheme_4.png": "084ee2708e30feb5b4b05e61f992f0a1",
"assets/assets/Illustration/Ilustracion_0.png": "13d47e13b27a818b4b5a64b2f13eca6e",
"assets/assets/Illustration/Ilustracion_1.png": "b5dfe2f9e210ca1c4cb0eb8c39085766",
"assets/assets/Illustration/Ilustracion_2.png": "634e7f0277527fb8695745469d85e5ce",
"assets/assets/Illustration/NoResult.png": "6bdc365ba2174f871a5379cd9e9a478a",
"assets/assets/Illustration/NoResultDarkTheme.png": "770577343ebe3c99f4f2ae2d5be25daf",
"assets/assets/Illustration/no_internet.png": "7b5a1b34f5998bfb3da137fc1ec15ee8",
"assets/assets/Illustration/no_internet_dark.png": "d6ee0c6ad10d1e65296090b9ab5d342c",
"assets/assets/Illustration/Password.png": "fc4e536c734c7c7d0a5c946f73084dec",
"assets/assets/Illustration/Password_dark.png": "5b2f0f984b84a41dd504cfa623ea71b4",
"assets/assets/Illustration/PayWithCash_darkTheme.png": "53b7d493d04a64992bcecbaa47249433",
"assets/assets/Illustration/PayWithCash_lightTheme.png": "6893db365d958535c4b00f61a936d15b",
"assets/assets/Illustration/server_error.png": "44832349231a3d9a37d31b28ff2d1999",
"assets/assets/Illustration/server_error_dark.png": "29af4089621e9ab466212f9011a80287",
"assets/assets/Illustration/success.png": "aefb15ea2c339e2537730b72ef3e5c05",
"assets/assets/Illustration/success_dark.png": "ace1a133b0f0b662e3d32232498ebdc0",
"assets/assets/Illustration/Success_darkTheme.png": "cbe539d0a957f963e526514b74514481",
"assets/assets/Illustration/Success_lightTheme.png": "b2ef00dad08bec5a0104e4a9851bc7d2",
"assets/assets/Illustration/TurnOnNotification_darkTheme.png": "3f2908d3b3a5cf906f1278211aa6f59a",
"assets/assets/Illustration/TurnOnNotification_lightTheme.png": "9791e133e17a0b09d15c16ddd5f973bc",
"assets/assets/Illustration/VerificationCode_dark.png": "c4d4af3d747d98aba2adc3a961d7de7d",
"assets/assets/images/Login-dark.png": "5fe0ea7efcede378968ff902be1719ad",
"assets/assets/images/Login-light.png": "5fe0ea7efcede378968ff902be1719ad",
"assets/assets/images/login_trailer_dark.png": "05004b350e7b88f5c0a3a9899b082127",
"assets/assets/images/login_trailer_light.png": "05004b350e7b88f5c0a3a9899b082127",
"assets/assets/images/maps.jpeg": "e1f030a8e83150d5bcc88bd01f537eea",
"assets/assets/images/mapss.png": "e8e1329a3063eaed538318ff42e9fa12",
"assets/assets/images/model_trailer.png": "8dff49985d0d8afa53751d9ba8907aed",
"assets/assets/images/notification.png": "79ccecb5bddc42de4c29056fea7ec24b",
"assets/assets/images/SignUp-dark.png": "50fb8dbd39f40dbf2a3a85ec270cdeee",
"assets/assets/images/SignUp-light.png": "50fb8dbd39f40dbf2a3a85ec270cdeee",
"assets/assets/logo/Shoplon.svg": "2dde7abfeb875dd44b9f18ee0471825a",
"assets/assets/screens/Add%2520review%2520rate.png": "7b6bb43a3f2c0404bec402ce8bea1179",
"assets/assets/screens/Addresses.png": "75e65580c9dd7bc6a09264ab4bdc6350",
"assets/assets/screens/Cancel%2520order%2520-%2520Select%2520a%2520reason.png": "ef11eb51088dd48d892894d9f81338df",
"assets/assets/screens/Cart_1.png": "1feaed2a4e3556ce880b2e6258ae14a3",
"assets/assets/screens/Cart_2.png": "915f92568e2f56cbf5fa6d8ea1587448",
"assets/assets/screens/Cart_3.png": "aac87bac017ac26608ff16b329ed41a0",
"assets/assets/screens/Cart_4.png": "2f206c88a0490f26e6c209d7ef0d6834",
"assets/assets/screens/Cart_5.png": "b79d021962b50a1e36566002c4e3b496",
"assets/assets/screens/Cart_6.png": "aedfccf47cd5ab9ec28751433dff201e",
"assets/assets/screens/Edit%2520profile.png": "6b6f56f154e52d87df859789225d3ec3",
"assets/assets/screens/Enable%2520notification.png": "5a580371bab5aa780deb9bcdb533eb05",
"assets/assets/screens/Enter%2520verification%2520code.png": "2b4a6123450c7f9058902c5770c140b0",
"assets/assets/screens/Forgot%2520password%25206.png": "9e126e18cbb401033331b2014665f33c",
"assets/assets/screens/Forgot_password.png": "600f3b1040cb0cb82712e18aa7843091",
"assets/assets/screens/Kids.png": "573a977a514f8ff9c92e42154cc2a990",
"assets/assets/screens/No%2520notification.png": "7d33b1d61a65182a6fb7034c7ce07483",
"assets/assets/screens/notification%2520setting.png": "4f794064ddfbc5d3bbf5fc2ff0aa9beb",
"assets/assets/screens/Notification.png": "9b4c1a5220627acafd1d573d3caaea5a",
"assets/assets/screens/On%2520sales.png": "3d5ccf5526760533de3d52369bba12e2",
"assets/assets/screens/Orders.png": "749b59438f60585f3ea5df5f55446e7e",
"assets/assets/screens/Product%2520detail.png": "90f7a574832633af128fdf7a0a0da8b8",
"assets/assets/screens/Profile.png": "a4aaf48d9767451f3f59a800a778c71a",
"assets/assets/screens/Reset%2520password.png": "74132e32c7af8b94fddb9a6c268a601a",
"assets/assets/screens/reviews.png": "2d03c6131d381328758af62c7b929bc1",
"assets/assets/screens/SEARCH_1.png": "87998c3a4725758b9122636e01bf1dcf",
"assets/assets/screens/Search_2.png": "14b1eeee801d5eb7a0934f2694f818dc",
"assets/assets/screens/Search_3.png": "3682e061ca7fbe5d8682c9f7c4aa9e03",
"assets/assets/screens/Search_4.png": "7a26687f71b300072d257f27c7d56135",
"assets/assets/screens/Search_5.png": "dbff51069a6ed981ac423d4f5a13eab1",
"assets/assets/screens/Search_6.png": "35cdc47eb7ee32534a436cc794e0a03a",
"assets/assets/screens/Search_7.png": "6e64a3766d1bcaf5f30b2bbca06a4d95",
"assets/assets/screens/Search_8.png": "1ac774d1978359691be7c0e8b5b592e9",
"assets/assets/screens/Shipping%2520information.png": "2df9cf72bab89b6c9fe13174cbb13a30",
"assets/assets/screens/Size%2520Guide.png": "f3a68d010287e7984c741dd129b2fa31",
"assets/assets/screens/Verificaition%2520code.png": "78ee32ac473bde0bde920ec6a6eec1f3",
"assets/FontManifest.json": "434c1559d4dd3c00dee03d4b4999d122",
"assets/fonts/MaterialIcons-Regular.otf": "34505658f342af1e8cbb84ae5e6833ca",
"assets/NOTICES": "351e423f5b878c97d573a1b454fd2c5d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "9cc00755f1d5a547336b178d36c071d8",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "cb40b0324775cd379c92e62e78c32475",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "4c01c2ef08502afa28bd1dae5c41c589",
"/": "4c01c2ef08502afa28bd1dae5c41c589",
"main.dart.js": "55593022fbf724c0904fa19e16acdc53",
"manifest.json": "82235d800dcf8fd9d10f7bb0d8fb27db",
"version.json": "36161e6bf8e0c1899eb48a8a91637865"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
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
