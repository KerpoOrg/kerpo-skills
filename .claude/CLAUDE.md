# kerpo-skills

Kerpo Organization yksityinen APM-skilli-paketti Claude Codelle ja Cursorille. Kaikki skillit käyttävät `kerpo-`-etuliitettä.

## Repon rakenne

```
.apm/skills/kerpo-<name>/
├── SKILL.md                    # vaadittu
├── references/                 # pitkä sisältö (ladataan viittauksella)
├── scripts/                    # suoritettava koodi
├── assets/                     # templateit, resurssit
└── evals/
    ├── evals.json              # output quality test cases
    └── eval_queries.json       # trigger testing queries
```

## Uuden skillin luominen

```bash
./scripts/new-skill.sh kerpo-<name>
```

Tämä luo oikean hakemistorakenteen ja pohja-SKILL.md:n.

## SKILL.md frontmatter

```yaml
---
name: kerpo-<name>
description: >-
  Use when the user... Apply when... (max 1024 merkkiä)
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
```

**Description-kirjoitusohjeet:**
- Aloita "Use when" tai "Apply when"
- Intent ensin, tekniset yksityiskohdat viimeisenä
- Mainitse eksplisiittisesti near-miss-tapaukset joita ei pidä laukaista
- Testaa trigger-tarkkuus ennen deployaamista

**Progressive disclosure — pidä SKILL.md lean:**
- Agentit lataavat `name` + `description` aina (~100 tokenia)
- `SKILL.md` body ladataan vain aktivoituessa (<5000 tokenia)
- `references/`, `scripts/`, `assets/` ladataan vain tarvittaessa → viittaa niihin eksplisiittisesti

## Testaus

### 1. Rakennekelpoisuus
```bash
apm audit --file .apm/skills/kerpo-<name>/SKILL.md
apm pack --dry-run
```

### 2. Trigger-testaus (description)
```bash
./scripts/test-triggers.sh kerpo-<name>
# Lisää ~20 queryä evals/eval_queries.json: 50% should-trigger, 50% should-not
# Should-not -tapaukset: near-missit (sama aihe, eri tarkoitus)
```

### 3. Output quality evals
```bash
./scripts/run-evals.sh kerpo-<name> 1
# Ajaa evals/evals.json test caset with_skill ja without_skill -baseline
# Tulokset: kerpo-<name>-workspace/iteration-1/
```

**Iteraatiosilmukka:**
1. Aja evals → katso tulokset ja timing (tokenit, aika)
2. Lisää assertiot `evals.json`:ään vasta kun näet ensimmäiset outputit
3. Anna eval-signaalit + SKILL.md Claudelle → pyydä parannusehdotuksia
4. Aja uusi iteraatio → vertaa benchmark.json deltaa
5. Lopeta kun parannus pysähtyy

## Deploy

```bash
apm pack                              # luo build/kerpo-skills-x.y.z/
apm install build/kerpo-skills-x.y.z # deployaa .agents/skills/
```

Cursor ja muut harnesses lukevat `.agents/skills/` (jaettu polku).  
`apm install` ilman argumenttia asentaa vain ulkoiset `dependencies.apm`-riippuvuudet.

Committaa: `apm.yml`, `apm.lock.yaml`, `.apm/`, `.agents/skills/`  
Gitignore: `apm_modules/`, `*-workspace/`, `build/`

## Skillit keskenään

- **Shared content:** `.apm/references/` → viittaa `LOAD references/shared.md`
- **Package deps:** `apm.yml` → `dependencies.apm: [kerpo/other@v1.0.0]`
- **Agents:** `.apm/agents/` voi orkestroida useampaa skilliä
