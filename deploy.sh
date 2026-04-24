#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Strava Dashboard — Auto Deploy to GitHub → Netlify
# ═══════════════════════════════════════════════════════════
# Uso: doble clic para ejecutar, o desde Terminal: ./deploy.sh
# Crontab: se puede programar para ejecutar diariamente

# ──── CONFIGURACIÓN ────
# IMPORTANTE: Cambia esta ruta a donde está tu carpeta netlify-deploy
REPO_DIR="/Users/luisalgenissanchez/Documents/Claude/Salud/TrainingPeaks/Algenis/netlify-deploy"
# ───────────────────────

TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
LOG_FILE="$REPO_DIR/deploy.log"

# Ir a la carpeta del repo
cd "$REPO_DIR" || {
    echo "❌ Error: No se encontró la carpeta $REPO_DIR"
    echo "   Edita la variable REPO_DIR en este script con la ruta correcta."
    echo "   Para encontrarla: abre Terminal, navega a la carpeta y escribe 'pwd'"
    exit 1
}

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
