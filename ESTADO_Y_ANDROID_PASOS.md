# Estado Actual de la Aplicación y Guía para Producción en Android

## 1. Análisis del Funcionamiento Actual de la Aplicación

La aplicación "HomeSync" (Aplicación de Pareja) cuenta actualmente con un backend robusto con principios de Clean Architecture (operativo y funcionando en Supabase PostgreSQL) y un cliente escrito en Flutter (Dart).

### Funcionalidades Implementadas (Eje transversal de capas conectadas)

- **Autenticación**:
  - Login robusto con manejo automatizado de tokens (JWT).
  - Manejo de estados 401: El cliente Flutter ejecuta un auto-refresh del token de manera transparente sin que el usuario lo note al perder sesión.
- **Gestión de Hogares (Households)**:
  - Un usuario puede crear un hogar y tipificarlo (Ej: "Pareja", "Familia", "Roommates"). Estas variantes definen las reglas (ej: los papás verifican las tareas en "familia", pero en versión "pareja" ambos pueden auto-verificarse mutuamente).
  - Se generan códigos de invitación de corta vida (alfanuméricos de 6 posiciones).
- **Módulo Central: Tareas**:
  - Creación de tareas, con posibilidad de programarlas asincrónicamente o asignarlas con _recurrencias_ (tareas diarias, semanales).
  - Flujo protegido de estados de la tarea: la aplicación impide la progresión errónea usando protección de concurrencia e _Idempotencia_ desde el originador para que doble-touch de un botón no cuente doble puntos a nadie.
- **Módulo Financiero y Gamificación (Sistema Gamificado)**:
  - _Ledger Inmutable_: Las finanzas de puntos del hogar son inmutables haciendo que todo cálculo se base en una historia segura, dando XP (experiencia) y Coins.
  - El usuario compite "sanamente" consiguiendo puntos a medida que se validan sus labores completadas, impactando visuales como "Avatares/Emojis" de forma dinámica frente a sus seres queridos.
- **Tienda y Gastos de Recompensas**:
  - Se implementa el canje de los "Gains" para comprar "Premios Personalizados del Hogar" de una lista editable desde app, o poder transferir esas monedas a la pareja.

## 2. Estado Actual de los Tests de la Aplicación

Revisando todo el sistema (específicamente la capeta interna `/flutter_client/test/` y su documentación subyacente de Supabase), nos encontramos en el siguiente status:

- **Testeo de Backend / PostgreSQL RPC's**: Alto. Se evidencian configuraciones estrictas anti redundancia donde no puedes hacer multi-canjeo y tests de concurrencia donde transferir sin balance arroja error.
- **Testeo Frontend (Flutter)**:
  - **Lo que SÍ está implementado**: Integración Lógica y Validadores. El archivo `backend_integration_test.dart` prueba reglas financieras como validadores de transferencia (no auto transferir dinero propio, montos mayores a 0); validación de la generación de tareas (verificación de repeticiones); y chequeo de cálculos de fechas.
  - **Lo que FALTA y hay que hacer (Brechas críticas en UI)**:
    1. **Widget Testing** (Componentes unitarios): No existe comprobación automática que nos asegure que un nuevo cambio del programador no borre el botón de Login porque el "widget" principal `widget_test.dart` solo tiene un "dummy code" vacío. Se deben testear el render y llenado real de los TextFields visuales.
    2. **End-to-End Test y Riverpod Providers**: Pruebas sobre la manipulación del árbol de la app mediante Providers. Nos queda simular (Integration Test) cómo interactúa todo bajo simulación de "tocar en App -> va al server -> responde -> mueve a HomeScreen".

## 3. Guía de Cierre: ¿Cuántos pasos nos faltan para que sea una App de Android pública instalable?

Actualmente el ecosistema técnico es altamente funcional, pero es puramente estructural y de desarrollo corriendo local. Para transformarlo en un artefacto publicable final (Ej. Listarlo en el **Google Play Store / Instalar como APK final en un celular**), nos restan **exactamente 8 pasos obligatorios/recomendados**:

### A. Preparación Visual e Identificatoria (Pasos 1-3)

1.  **Rebautizar el Android Package Name**: El proyecto actualmente en `build.gradle` todavía se debe instanciar bajo nombres de test. Hay que definirlo como `com.tunombre.homesync` (tu nombre formal en la red interna de Android).
2.  **Generación de Launcher Icons Generales (Icono de la App)**: Se mantiene el logo default de Flutter en miniatura. Hay que usar tu rediseño de UI Premium para aplicar (mediante lib como `flutter_launcher_icons`) la insignia final para los escritorios de Android limitados adaptativamente.
3.  **Configurar The Splash Screen Nativos**: Evitar el parpadeo negro y blanco que dan las apps de Flutter en frío, integrándoles con XML en el Android Folder o con `flutter_native_splash` tu iconografía.

### B. Funcionalidades Nativas Extras (Pasos 4-5)

4.  **Configuración del AndroidManifest.xml**: Se agregarán permisos puntuales nativos si fuera necesario guardar fotos, y colocar los links de conexión ("Deep Linking") que usa Supabase para poder hacer recovery de cuentas o inicio OAuth redirigiendo Chrome de vuelta a esta tuya App.
5.  **Notificaciones Push Directas (FCM - Opcional para arrancar, crítico a largo plazo)**: Configurar Firebase interconectado a este ambiente para obtener el `google-services.json` necesario y enviar notificaciones de "¡Alguien asignó X!".

### C. Proceso de Firma de Aplicación para Distribución (Pasos 6-8)

6.  **Creación de un "Android Release Keystore"**: Android restringe la distribución a las apps que NO tengan una llave firmada única tuya de encriptación que valide que, de base, tu fuiste y sigues siendo el creador de versión en versión.
7.  **Propiedades de Firma y Compiladores `ProGuard/R8`**: Modificar el archivo `android/app/build.gradle` especificándole explícitamente el uso de la llave anterior y la obfucación (el R8 oculta tus procesos a terceros previniendo ingeniería inversa basíca).
8.  **Generación del AppBundle Final (AAB)**: Compilar en la terminal mediante `flutter build appbundle`. Google Play Store _ya no acepta APKs públicos para nuevas apps_. Requiere este "AAB" que usa sus sistemas para hacer APKs particionados según el tamaño exacto del smartphone que lo va descargar pesando mucho menos megabytes.
