# Internet Radio SomaFM plugin for Spotube

A **radio directory** plugin for [Spotube](https://github.com/Adamyabhatt01/spotube),
written in [Hetu](https://github.com/hetu-community/hetu). Maintained by
**Adamya Bhatt**; version `1.0.1`, plugin API `2.0.0`.

It turns [SomaFM](https://somafm.com/) — a listener-supported catalog of
curated streaming channels — into Spotube's **Radio** page. Small, curated,
and consistent: about 46 channels of electronic, ambient, lounge, downtempo
and indie, all streaming 128 kbps MP3.

## What it gives you

- **Stations** — every SomaFM channel, with its title, description, DJ,
  genre, artwork and the direct stream URL.
- **Search and genre filtering** — the genre list is derived from the
  catalog itself, most-used first, and the search matches titles,
  descriptions and genres.
- **One request, then local** — the whole catalog is a single JSON document,
  so paging and filtering happen on the device instead of on a server.
- **No key, no sign-in** — the channel list is public.

## Install

Spotube → Settings → Metadata plugins → paste this URL → install:

```
https://raw.githubusercontent.com/Adamyabhatt01/spotube-plugin-internet-radio-somafm/1.0.1/dist/plugin.smplug
```

The artifact is a file in this repository, so the URL works without a GitHub
release. A local `plugin.smplug` works too (the file picker accepts it).

Requires a Spotube build that speaks plugin API 2.x with the `radio` ability —
that is this fork ([Adamyabhatt01/spotube](https://github.com/Adamyabhatt01/spotube)),
not upstream release builds. Spotube also bundles this plugin, so a fresh
install already has it and does not need this URL at all; use it when you
want the standalone build or a newer version than the one bundled.

## Choose this, or the Radio Browser one?

Spotube can hold several radio directories at once and fans the Radio page
out across them, so these two are complements rather than rivals.

| | **Internet Radio SomaFM** (this repo) | **Internet Radio Browser** |
|---|---|---|
| Catalog | Curated, ~46 channels | Community-submitted, tens of thousands of stations |
| Geography | US only — country browsing falls through to the other plugin | Worldwide, filterable by country |
| Search | Local, over one fetched document | Server-side, paginated |
| Character | Electronic, ambient, lounge, downtempo, indie — listener-supported | Anything: local stations, talk radio, obscure genres, world music |
| Quality | Consistent: 128 kbps MP3, curated and maintained | Varies; the catalog is user-submitted, so some streams are dead or low bitrate |
| Best for | Background listening — a small set of good channels | Discovery — finding a station for a specific place, language or genre |

If you only install one: **this one**, if you want curated channels that
always work. Install both if you want SomaFM's curation on top of the open
directory.

## How it talks to the app

The plugin exposes a `radio` endpoint with four calls, and every one returns
plain JSON-shaped values so nothing leaks across the Hetu boundary:

| Call | Returns |
|---|---|
| `stations({query, offset, limit, tag, country})` | a page of channels plus the pagination envelope (`limit`, `nextOffset`, `total`, `hasMore`) |
| `byId(id)` | one channel, or an empty map |
| `tags({limit})` | the genres, most used first (computed from the catalog) |
| `countries({limit})` | nothing — SomaFM has no country axis, so the browse-by-country rail falls through to a directory that does |

The shapes match Spotube's `RadioStation`, `RadioTag` and `RadioCountry`
models, and the app's `MetadataPluginRadioEndpoint` parses them.

Stream addresses are derived from the well-known Icecast mount pattern
(`ice1.somafm.com/<id>-128-mp3`) with the scheme pinned to https.

## Build from source

```bash
git clone https://github.com/Adamyabhatt01/spotube-plugin-internet-radio-somafm.git
cd spotube-plugin-internet-radio-somafm

# Pinned: this dev-tools release carries hetu_script 0.4.2+1, the version
# Spotube's Hetu VM loads. A newer one compiles with hetu_script 0.6.x and
# emits bytecode the app cannot load.
dart pub global activate hetu_script_dev_tools 0.1.0+2

make compile   # src/plugin.ht -> build/plugin.out (Hetu bytecode)
make archive   # plugin.json + plugin.out -> build/plugin.smplug
make publish   # ... and copy it to dist/plugin.smplug, which the install URL serves
```

`make archive` needs `zip` on `PATH`. The bytecode embeds its compile
timestamp, so two compiles of identical sources differ in hash but not in
code — compare them by behaviour, not by checksum.

Spotube bundles the same artifact at
`assets/plugins/spotube-plugin-internet-radio-somafm/plugin.smplug`; the
version here and the bundled one are kept in step.

## Licence

BSD-4-Clause, like Spotube itself. See [LICENSE](LICENSE).
