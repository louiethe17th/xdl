# xdl

Download the video, image, or GIF from an X (Twitter) post — one command, no browser extension, no sketchy website.

```console
$ xdl https://x.com/someone/status/1234567890
==> https://x.com/someone/status/1234567890
✓ saved 3 file(s) to /home/you/Downloads/x-media
    someone-1234567890-1.jpg
    someone-1234567890-2.jpg
    someone-1234567890-3.jpg
```

## Install

```bash
git clone https://github.com/louiethe17th/xdl.git
cd xdl
./install.sh
```

The installer drops `xdl` in `~/.local/bin` and builds an isolated virtualenv at
`~/.local/share/xdl-venv` holding [gallery-dl](https://github.com/mikf/gallery-dl)
and [yt-dlp](https://github.com/yt-dlp/yt-dlp). Nothing is installed system-wide,
nothing touches your system Python, and no `sudo` is required.

Make sure `~/.local/bin` is on your `PATH`:

```bash
# bash / zsh — add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```
```fish
# fish
fish_add_path ~/.local/bin
```

**Requirements:** Python 3.8+, `git`, and `ffmpeg` (only needed when a video's
audio and video arrive as separate streams and have to be merged).

## Usage

```
xdl [OPTIONS] URL [URL...]
```

| Option | Description |
| --- | --- |
| `-o DIR` | Output directory (default `~/Downloads/x-media`, or `$XDL_DIR`) |
| `-c BROWSER` | Load cookies from a browser: `firefox`, `chrome`, `chromium`, `brave`, `edge` |
| `-O` | Open the output directory when finished |
| `-u` | Update gallery-dl and yt-dlp, then exit |
| `-h` | Show help |

### Examples

```bash
# Basic — grabs every piece of media attached to the post
xdl https://x.com/someone/status/1234567890

# Save somewhere else
xdl -o ~/Pictures/memes https://x.com/someone/status/1234567890

# Download several posts in one go
xdl https://x.com/a/status/111 https://x.com/b/status/222

# Post requires a login (age-restricted, protected, or X being X)
xdl -c firefox https://x.com/someone/status/1234567890

# Change the default output directory permanently
export XDL_DIR="$HOME/Pictures/x"
```

## What it handles

**URL formats.** All of these normalize to the same post, so paste whatever you
copied:

- `x.com/user/status/123` and `twitter.com/user/status/123`
- `mobile.twitter.com/...`
- The embed-fixer mirrors: `fxtwitter.com`, `vxtwitter.com`, `fixupx.com`, `twittpr.com`
- Tracking parameters (`?s=20&t=AbCdEf`) are stripped
- A `/photo/1` or `/video/1` suffix is stripped **on purpose** — clicking one image
  in a four-image post gives you a URL pointing at just that image, and dropping
  the suffix means you get all four instead of only the one you clicked

**Media types.** Images download in their original resolution. Videos download at
the highest available quality. GIFs come down as `.mp4`, because that is what X
actually stores — it converts every uploaded GIF to a silent looping video, so
there is no original GIF left on their servers to fetch.

**Naming.** Files are saved as `username-tweetid-N.ext`. The index keeps
multi-image posts from overwriting each other, and the tweet ID means you can
always trace a file back to its source post.

## How it works

`gallery-dl` runs first, since it reliably pulls *every* attachment from a post.
If it comes back empty-handed, `xdl` retries with `yt-dlp`, which occasionally
succeeds on video posts that gallery-dl misses. This costs nothing when the first
tool works and saves the download when it doesn't.

Keeping both in a dedicated virtualenv matters more than it might seem. X changes
its internal API regularly and these tools ship fixes within days, so you want to
be able to upgrade them the moment something breaks:

```bash
xdl -u
```

That is usually the entire fix when downloads suddenly stop working.

## Troubleshooting

**`unknown command: xdl`** — `~/.local/bin` isn't on your `PATH` (see Install).
On fish, an existing session also caches its command list; run `rehash` or open a
new tab.

**`no media downloaded`** — Usually one of:

- The post has no media (text-only), or it was deleted
- The account is protected, or the post is age-restricted → retry with `-c firefox`
- X requires a login for that content → same fix, `-c <your browser>`
- The tools are out of date → run `xdl -u`

**Cookies aren't working** — Close the browser first. Chrome and Chromium lock
their cookie database while running, so extraction fails or returns stale data.
Firefox is generally the least troublesome source.

**Everything fails with a login wall.** X has been tightening anonymous access
over time. Individual public posts generally still work without credentials, but
if your posts of interest don't, `-c <browser>` with a logged-in session is the
answer.

## Notes

This is a convenience wrapper. All the difficult work — X's private GraphQL API,
guest tokens, video stream selection — is done by
[gallery-dl](https://github.com/mikf/gallery-dl) and
[yt-dlp](https://github.com/yt-dlp/yt-dlp). If `xdl` breaks, those projects are
where the fix will land, and `xdl -u` is how you get it.

Download things you have the right to download. Respect the rights of the people
whose work you're saving.

## License

MIT — see [LICENSE](LICENSE).
