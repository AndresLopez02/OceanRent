
# 🚢 OceanRent

Aplicación móvil multiplataforma para la gestión de alquiler de
embarcaciones, desarrollada con Flutter y Dart durante las
prácticas de DAM en Zaitec.

---

## 📱 Capturas de pantalla

### Panel de Administración
| Panel Admin | Resumen de actividad | Gestión de reservas |
|---|---|---|
| ![Panel Admin](<img width="2400" height="1080" alt="1000115225" src="https://github.com/user-attachments/assets/c58a9fc5-668e-42af-9d40-bb52f8cdddf4" />/panel_admin_1.jpg) | ![Resumen](screenshots/panel_admin_2.jpg) | ![Reservas](screenshots/reservas.jpg) |

### Gestión Admin
| Fianzas retenidas | Titulaciones | Calendario de flota |
|---|---|---|
| ![Fianzas](screenshots/fianzas.jpg) | ![Titulaciones](screenshots/titulaciones.jpg) | ![Calendario](screenshots/calendario.jpg) |

### Vista Cliente
| Detalle barco | Selección de fechas | Mapa | Perfil cliente |
|---|---|---|---|
| ![Detalle](screenshots/detalle_barco.jpg) | ![Fechas](screenshots/fechas.jpg) | ![Mapa](screenshots/mapa.jpg) | ![Perfil](screenshots/perfil_cliente.jpg) |

### Formularios Admin
| Crear barco | Editar barco | Perfil Admin |
|---|---|---|
| ![Crear](screenshots/crear_barco.jpg) | ![Editar](screenshots/editar_barco.jpg) | ![Perfil Admin](screenshots/perfil_admin.jpg) |

---

## ✨ Funcionalidades

### 👤 Cliente
- Registro e inicio de sesión con Firebase Authentication
- Exploración de embarcaciones con filtros avanzados
- Vista detallada: tipo, precio/día, capacidad, puerto,
  licencia requerida
- Calendario de disponibilidad por embarcación
- Selección de fechas con cálculo automático del precio total
- Sistema de reservas con estados: pendiente, confirmada, cancelada
- Titulación náutica: subida de documento acreditativo y verificación
- Valoraciones y reseñas de embarcaciones
- Chat por reserva con el equipo
- Perfil editable con datos personales

### 🛠️ Administrador
- Panel con resumen de actividad en tiempo real:
  reservas activas, fianzas retenidas, barcos registrados,
  titulaciones pendientes
- CRUD completo de embarcaciones (crear, editar, eliminar,
  activar/desactivar en catálogo)
  - Nombre, tipo, capacidad, puerto, precio, fianza,
    licencia requerida, descripción
  - Subida de imagen y autocompletado de coordenadas GPS por puerto
- Gestión de reservas: confirmar o cancelar, con detalle de
  tripulantes y fianza
- Gestión de fianzas: devolver o marcar como cobradas
- Validación de titulaciones náuticas de clientes
- Calendario de flota: consulta de disponibilidad y bloqueo
  por mantenimiento o avería
- Gestión de mensajes de clientes por reserva
- Respuesta a reseñas de clientes

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter / Dart | Desarrollo de la app multiplataforma |
| Firebase Authentication | Registro e inicio de sesión de usuarios |
| Cloud Firestore | Base de datos en tiempo real |
| flutter_map | Integración de mapas interactivos |
| Figma | Diseño UI/UX del prototipo completo |
| Git + GitHub Projects | Control de versiones y gestión ágil |

> ⚠️ Firebase Storage fue descartado durante el desarrollo
> por costes. Las imágenes se gestionan mediante URLs externas.

---

## 👤 Mi contribución

Proyecto desarrollado en equipo de 4 personas durante las
prácticas FCT. Mis áreas de responsabilidad:

- 🗄️ **Base de datos** – Diseño del esquema NoSQL completo en
  Cloud Firestore: colecciones `users`, `boats`, `bookings` y
  `chats`. Documentación de la estructura, guía de uso para
  el equipo y definición de reglas de seguridad por rol
  (admin/customer), testeadas con Firebase Emulator.
- 🗺️ **Mapa** – Implementación completa de la pantalla de
  localización con `flutter_map`: pins interactivos por
  categoría, popup de información, gestión de barcos en el
  mismo puerto con dispersión en abanico y bottom sheet, y
  autocompletado de coordenadas GPS por puerto en el
  formulario de admin.
- 🔍 **Filtros** – Desarrollo del sistema de filtrado del
  catálogo de embarcaciones.
- 👤 **Perfiles** – Pantallas de perfil de cliente y
  administrador: formulario de datos personales, sección de
  titulación náutica con subida de documento y estado de
  verificación, botón guardar con mensajes de confirmación.
- 🎨 **Diseño Figma** – Prototipo visual de las pantallas home
  de admin y customer con sus variantes.
- 🔧 **Calidad de código** – Refactorización de pantallas de
  perfil: extracción de widgets reutilizables, unificación de
  colores con el tema de la app y limpieza general del código.
- 📋 **Mantenimiento** – Revisión de PRs, resolución de
  conflictos de merge, recuperación de código eliminado
  accidentalmente y verificación de dependencias.

> El proyecto siguió metodología ágil con sprints y feature
> branches con merges periódicos a develop. Las branches de
> trabajo se eliminaban tras el merge, por lo que el historial
> de commits visible refleja solo la rama final activa.

---

## 🎨 Diseño UI/UX

Prototipo completo diseñado en Figma por el equipo, incluyendo
todos los flujos: onboarding, login/registro, cliente y
administrador.

👉 [Ver prototipo en Figma](https://www.figma.com/proto/BRIalzCrIB53eJ9NyUbRQ8/OceanRent?node-id=0-1)

---

## ⚙️ Configuración del proyecto

1. Clona el repositorio
2. Crea tu propio proyecto en
   [Firebase Console](https://console.firebase.google.com/)
3. Activa **Authentication** (email/contraseña),
   **Firestore** y **Storage**
4. Descarga `google-services.json` y colócalo en `android/app/`
5. Ejecuta `flutter pub get`
6. Lanza la app con `flutter run`

> ⚠️ El archivo `google-services.json` no está incluido
> por seguridad. Necesitas configurarlo en tu propio proyecto
> Firebase para ejecutar la app.

---

## 👨‍💻 Contexto

Desarrollado durante las prácticas FCT del Grado Superior en DAM.  
**Empresa:** Zaitec · Almería, España  
**Período:** Marzo 2026 – Junio 2026
