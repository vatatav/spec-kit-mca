# Spec-Kit MCA (Distribution — PowerShell)

This folder is the packaged Spec-Kit MCA distribution. It contains:
- `.specify/templates/*` - authoring templates (spec/plan/tasks)
- `.specify/scripts/*` - helper scripts (init, hygiene, provenance, export)
- `.codex/prompts/*` - mc00→mc08 and `org/` prompts

Quick Start (SAF users)
- Zip (codex-ps veya codex-sh) içeriğini boş bir klasöre çıkarın ve `git init -b main` çalıştırın.
- Agent üzerinden mc akışını kullanın; komutları elle çalıştırmayın.
- `/mc00-init` ile başlayın (agent init işlemini kendisi yapar).
- Sırayla ilerleyin: `/mc01-constitution` … `/mc08-reflect`.
- `pwsh-LOCAL.bat` / `sh-LOCAL.sh`: `CODEX_HOME` değişkenini proje klasörüne ayarlar; Codex CLI'nin /mc komutlarını bu projede görmesini sağlar.
- İlk çalıştırmada yetkilendirme gerekir; `.codex/` altında çalışma dosyaları oluşur. Bunlar repoya/public'a dahil edilmemelidir (constitution kuralları buna engel olur; yine de kontrol edin).
- `/mc01` ve `/mc02` öncesi, `user_prompts` altındaki ilgili `.md` dosyalarını kendi ihtiyaçlarınıza göre güncelleyin.

MCA Flow (mc00 → mc08)
- `/mc00-init` → initialize kit (mode/base)
- `/mc01-constitution` → review/tweak constitution
- `/mc02-specify` → write/extend spec
- `/mc03-clarify` → resolve ambiguities
- `/mc04-plan` → phased plan
- `/mc05-tasks` → TDD-first tasks
- `/mc06-analyze` → checks + gates
- `/mc07-implement` → focused changes
- `/mc08-reflect` → lessons back to specs/constitution

Which zip should I use?
- Curated: `spec-kit-mca-codex-ps-X.Y.Z.zip` veya `spec-kit-mca-codex-sh-X.Y.Z.zip` (projeye başlamak için bunları kullanın).
- "Source code (zip)" ise ilgili tag anındaki repo anlık görüntüsüdür.

For Kit Developers
- Paketleme: `pwsh .specify/scripts/package_dist.ps1 -Flavor codex-ps -Version X.Y.Z` ve/veya `-Flavor codex-sh`

