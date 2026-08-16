# Bob marketing site

Public site for **Bob**, the Helium fork. Ships at [bob.solved.gg](https://bob.solved.gg).

Astro 7 + Tailwind 4, deployed as a Cloudflare Worker.

## Local

```bash
bun install
bun run dev
```

## Build and deploy

```bash
bun run build
bunx wrangler deploy
```

The Worker is named `bob` and is bound to the `bob.solved.gg` custom domain in `wrangler.jsonc`.
