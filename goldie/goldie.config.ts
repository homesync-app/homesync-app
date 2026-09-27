import type { GoldieConfig } from "goldie";

// Capturas de Play Store con la cuenta demo (Sofi & Mati, ver
// docs/playbooks/store-screenshots.md). Solo Android: en Windows no hay
// simulador de iOS.
//
// OJO: `goldie capture` desinstala y reinstala la app, y eso borra la sesion
// de la cuenta demo. Las capturas crudas se sacan con goldie/capture.sh (no
// reinstala); goldie se usa para frame / manifest / verify / studio.
// Titulos y paleta: flutter_client/playstore_assets/STORE_LISTING_2026-09.md.
// Rutas relativas a este archivo (goldie las resuelve desde aca).
const APP_ROOT = ".";

const config: GoldieConfig = {
  appRoot: APP_ROOT,
  android: {
    appPath: `../flutter_client/build/app/outputs/flutter-apk/app-release.apk`,
    applicationId: "com.blas.homesync",
  },
  devices: ["pixel-10-pro"],
  locales: ["es-AR", "en-US"],
  appearance: "light",
  frame: { variant: "17-pro-silver" },

  theme: {
    background: "linear-gradient(165deg, #FDE6D8 0%, #FFF4EC 45%, #FFFCF9 100%)",
    headlineColor: "#3A2A22",
    subheadColor: "#8A6E60",
    fontFamily: "Montserrat",
    copyHeightRatio: 0.24,
    deviceWidthRatio: 0.84,
    layout: "classic",
  },

  store: {
    name: "HomeSync",
    subtitle: {
      "es-AR": "Tareas y gastos en pareja",
      "en-US": "Chores & expenses, together",
    },
    developer: "HomeSync",
    category: "Estilo de vida",
    rating: 4.8,
    ratingCount: "120",
    ageRating: "3+",
    price: "Gratis",
    description: {
      "es-AR":
        "HomeSync es para que la casa sea pareja. Las tareas, la plata y las compras quedan repartidas entre los dos y a la vista, sin planillas y sin llevar la cuenta de cabeza.\n\nUna pestaña para mirar la semana juntos: cuántas tareas hizo cada uno, qué quedó cargado de un solo lado y una propuesta concreta para emparejarlo.",
      "en-US":
        "HomeSync helps you and your partner share the load at home. Chores, money and groceries are split between the two of you and out in the open. No spreadsheets, no keeping score in your head.\n\nOne tab to look at the week together: how many chores each of you did, what landed on one side, and a concrete suggestion to even it out.",
    },
  },

  scenes: [
    {
      kind: "screenshot",
      id: "couple",
      flow: "store-01-couple",
      headline: { "es-AR": "Vean cómo se repartió la semana", "en-US": "See how the week was split" },
      subhead: {
        "es-AR": "Sin ranking ni reproches: qué quedó de un solo lado y cómo emparejarlo.",
        "en-US": "No scores, no blame: what landed on one side and how to even it out.",
      },
    },
    {
      kind: "screenshot",
      id: "home",
      flow: "store-02-home",
      headline: { "es-AR": "La casa, en un vistazo", "en-US": "Your home at a glance" },
      subhead: {
        "es-AR": "Lo de hoy, lo que gastaron y lo que pasó en casa.",
        "en-US": "Today's chores, spending and what's new at home.",
      },
    },
    {
      kind: "screenshot",
      id: "finance",
      flow: "store-03-finance",
      headline: { "es-AR": "Quién pagó qué, sin hacer cuentas", "en-US": "Who paid what, no mental math" },
      subhead: {
        "es-AR": "Gastos compartidos, ingresos y el balance del mes.",
        "en-US": "Shared expenses, income and the month's balance.",
      },
    },
    {
      kind: "screenshot",
      id: "tasks",
      flow: "store-04-tasks",
      headline: { "es-AR": "Cada tarea en su momento", "en-US": "Every chore, right on time" },
      subhead: {
        "es-AR": "Lo de hoy y lo de mañana, sin listas en la heladera.",
        "en-US": "Today and tomorrow, no more lists on the fridge.",
      },
    },
    {
      kind: "screenshot",
      id: "shopping",
      flow: "store-05-shopping",
      headline: { "es-AR": "Una lista para los dos, en vivo", "en-US": "One list, shared live" },
      subhead: {
        "es-AR": "Lo que anota uno, el otro lo ve al instante.",
        "en-US": "What one adds, the other sees instantly.",
      },
    },
    {
      kind: "screenshot",
      id: "proposals",
      flow: "store-06-proposals",
      headline: { "es-AR": "Pídanse cosas sin reclamos", "en-US": "Ask without it becoming a fight" },
      subhead: {
        "es-AR": "Planes, pedidos y charlas. \u201cAhora no\u201d también es una respuesta.",
        "en-US": "Plans, asks and talks. \u201cNot now\u201d is always a fine answer.",
      },
    },
  ],
};

export default config;
