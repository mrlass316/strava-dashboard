#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Strava Dashboard — Auto Deploy to GitHub → Netlify
# ═══════════════════════════════════════════════════════════
# Uso: doble clic para ejecutar, o desde Terminal: ./deploy.sh
# Crontab: se puede programar para ejecutar diariamente

# ──── CONFIGURACIÓN ────
REPO_DIR="/Users/luisalgenissanchez/Documents/Claude/Salud/TrainingPeaks/Algenis/netlify-deploy"
# ───────────────────────

TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
LOG_FILE="$REPO_DIR/deploy.log"
SCRIPT_LOCK="/tmp/deploy_strava.lock"

# ── Protección contra ejecuciones simultáneas ──────────────
# Si ya hay una instancia corriendo, salir silenciosamente.
if [ -f "$SCRIPT_LOCK" ]; then
    OLD_PID=$(cat "$SCRIPT_LOCK")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "⏭️  Deploy ya en curso (PID $OLD_PID). Saliendo." | tee -a "$LOG_FILE"
        exit 0
    else
        rm -f "$SCRIPT_LOCK"
    fi
fi
echo $$ > "$SCRIPT_LOCK"
trap 'rm -f "$SCRIPT_LOCK"' EXIT

# Ir a la carpeta del repo
cd "$REPO_DIR" || {
    echo "❌ Error: No se encontró la carpeta $REPO_DIR" | tee -a "$LOG_FILE"
    exit 1
}

# ── Limpiar archivos .lock huérfanos de git ─────────────────
find "$REPO_DIR/.git" -name "*.lock" -type f -delete 2>/dev/null

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "🏃 Deploy iniciado: $TIMESTAMP" | tee -a "$LOG_FILE"

# Verificar si hay cambios sin commitear
HAS_UNCOMMITTED=false
HAS_UNPUSHED=false

if ! (git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]); then
    HAS_UNCOMMITTED=true
fi

# Verificar si hay commits locales sin pushear
LOCAL=$(git rev-parse HEAD 2>/dev/null)
REMOTE=$(git rev-parse origin/main 2>/dev/null)
if [ "$LOCAL" != "$REMOTE" ]; then
    HAS_UNPUSHED=true
fi

if [ "$HAS_UNCOMMITTED" = false ] && [ "$HAS_UNPUSHED" = false ]; then
    echo "✅ No hay cambios nuevos. Nada que deployar." | tee -a "$LOG_FILE"
    exit 0
fi

# Stage y commit si hay cambios sin commitear
if [ "$HAS_UNCOMMITTED" = true ]; then
    git add .
    git commit -m "Update dashboard — $TIMESTAMP" 2>&1 | tee -a "$LOG_FILE"
fi

# Push (ya sea commit nuevo o commits pendientes)
git push origin main 2>&1 | tee -a "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Deploy exitoso! Netlify actualizará en ~30 segundos." | tee -a "$LOG_FILE"
else
    echo "❌ Error en git push. Verifica tu conexión y credenciales." | tee -a "$LOG_FILE"
    exit 1
fi

echo "" | tee -a "$LOG_FILE"
