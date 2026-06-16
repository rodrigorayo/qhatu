# Tareas: Calificar otros Stands y Rediseño de Evaluación

- [x] **1. Backend: Endpoints de Evaluación**
  - [x] Implementar `getFeriaStands` en `evaluation.controller.ts` para retornar todos los stands de la feria con sus miembros.
  - [x] Agregar la ruta en `evaluation.routes.ts`.

- [x] **2. Frontend: Modelos y Base de Datos Local**
  - [x] Crear el modelo `LocalStand` en `local_models.dart`.
  - [x] Ejecutar el comando para regenerar esquemas de Isar (`build_runner`).
  - [x] Registrar `LocalStandSchema` en `isar_service.dart`.
  - [x] Implementar `saveAllStands` y `getAllStands` en `isar_service.dart`.
  - [x] Corregir la serialización a `jsonEncode` en `saveAssignments` en `isar_service.dart`.

- [x] **3. Frontend: Pantalla de Selección de Stand**
  - [x] Crear `select_stand_screen.dart` con búsqueda y opción de rol (JURADO / DELEGADO).
  - [x] Registrar la ruta `/evaluator/select_stand` in `main.dart`.

- [x] **4. Frontend: Dashboard del Evaluador**
  - [x] Añadir botón "Calificar otro Stand" en `evaluator_dashboard.dart`.
  - [x] Sincronizar todos los stands en `_syncData`.

- [x] **5. Frontend: Rediseño de Pantalla de Calificación**
  - [x] Modificar `evaluation_form_screen.dart` para agrupar criterios por área en `ExpansionTile`s.
  - [x] Implementar doble entrada (Slider + TextField numérico sincronizados) en `evaluation_form_screen.dart`.
  - [x] Validar que solo acepte números enteros positivos.
