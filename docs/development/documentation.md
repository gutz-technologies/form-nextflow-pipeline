# Writing and publishing documentation

The site uses [Zensical](https://zensical.org/), pinned to **0.1.2** in
`docs/requirements.txt`. Markdown and provenance inventories live in `docs/`;
`zensical.toml` defines navigation and rendering.

## Preview locally

Use Python 3.12, the version the documentation CI uses. From the repository root:

```bash
./.zensical-serve.sh
```

The helper uses `$PYTHON` if set. Otherwise it tries `python3.12`, `python3.13`,
`python3.11`, then `python3`, and uses the first that is 3.11 or later and can
create a virtual environment (on Debian/Ubuntu, install `python3.12-venv`).
Zensical 0.1.2 requires Python 3.11 or later. If no candidate works, the helper
stops with a message. It creates this repository's own `.venv-docs` and installs the pinned
documentation dependencies, and rebuilds `.venv-docs` if Zensical is missing or
the environment uses an older Python. For example:

```bash
PYTHON=/path/to/python3.12 ./.zensical-serve.sh
```

The helper serves FORM on
[http://127.0.0.1:8001/](http://127.0.0.1:8001/) so another preview can use
port 8000. Stop it with **Ctrl+C**. To choose a different address:

```bash
./.zensical-serve.sh --dev-addr 127.0.0.1:8002
```

The equivalent manual setup is:

```bash
python3 -m venv .venv-docs
source .venv-docs/bin/activate
python -m pip install -r docs/requirements.txt
zensical serve --dev-addr 127.0.0.1:8001
```

Rerun the install command when `docs/requirements.txt` changes. To perform the
same strict site build as CI with this repository's environment:

```bash
.venv-docs/bin/zensical build --clean --strict
```

The output directory `site/`, virtual environment, and build cache are ignored
by Git. No populated bioBakery submodule, containers, database downloads, or
DNAnexus credentials are required to build the documentation.

## Maintain the eight-stage structure

Keep stage pages and navigation in this order: samplesheet building, KneadData,
MetaPhlAn, HUMAnN, BAQLaVa, StrainPhlAn, MEDI, and omixer-rpm (GBMs).
Each page should include its role, integration status, flagship software version,
major dependency versions, database sources/checksums, and evidence links.

Link between documentation pages with relative Markdown paths. Use repository
URLs for source files outside `docs/`. Include new pages in `project.nav` and
run a strict build to catch missing pages and invalid internal anchors.

The [software inventory](../reference/software-inventory.json) stores observed
images and package evidence; the [database inventory](../reference/database-inventory.json)
stores reference sources, byte sizes, checksum scope, and explicit pending values.
Update the affected Markdown tables and inventories together. Keep dates and
integration states current, and distinguish measured values from source recipe
constraints or planned defaults.

For checksum procedures and the pending database work, see
[Provenance and verification](../reference/provenance.md).

## GitHub Actions and Pages

The `Documentation` workflow builds and validates the site on pull requests
and pushes that touch `docs/`, `zensical.toml`, or the workflow itself. It can
also be started with `workflow_dispatch`. Pull requests and non-default branches
only build; successful default-branch runs upload a Pages artifact and deploy it.

Before the first deployment, select **Settings → Pages → Build and deployment
→ Source → GitHub Actions** in this repository. The workflow uses GitHub's
generated token and `github-pages` environment; no deployment secret or
`gh-pages` branch is needed.

The build job has read permissions. Only the deploy job receives `pages: write`
and `id-token: write`. Deployment concurrency prevents overlapping Pages
publishes. A protected Pages environment may require its normal repository
review before a deployment runs.

CI reads the Pages base URL and current repository/default-branch metadata, so
custom domains and forks receive matching canonical/source links. Do not publish
a documentation-site link before the first Pages deployment succeeds; it returns
404 until Pages is configured and the workflow runs on the default branch.

See [Zensical publishing](https://zensical.org/docs/publish-your-site/) and
[GitHub's Pages workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).
