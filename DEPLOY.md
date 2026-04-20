# Deploy en Netlify — Strava Dashboard

## Opción 1: Netlify Drop (30 segundos)

1. Abre **https://app.netlify.com/drop** en tu navegador
2. Arrastra la carpeta **netlify-deploy** completa al área de drop
3. Listo — Netlify te da una URL tipo `https://random-name-123.netlify.app`
4. (Opcional) Click en "Site settings" → "Change site name" para personalizar la URL

## Opción 2: Netlify CLI (más control)

```bash
npm install -g netlify-cli
cd netlify-deploy
netlify deploy --prod --dir .
```

## Ver en celular

- Abre la URL de Netlify en Safari/Chrome del celular
- En **iOS**: toca "Compartir" → "Agregar a pantalla de inicio" → se instala como app
- En **Android**: Chrome muestra banner "Agregar a pantalla de inicio" automáticamente

## Actualizar el dashboard

Cada vez que actualices los datos, sube de nuevo la carpeta a Netlify Drop
(o haz push si conectaste GitHub).
