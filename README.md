# 🏙️ Rockstar Valle - Sistema de NPCs Autónomos

Este recurso transforma a los NPCs básicos de GTA V en ciudadanos inteligentes con memoria, rutinas laborales y participación económica activa en el servidor.

## 🚀 Características Principales
- **Memoria Persistente:** Los NPCs recuerdan al jugador y registran CK mediante MySQL.
- **IA de Conducción:** Manejo avanzado que esquiva obstáculos y reacciona al clima.
- **Fuerza Laboral:** NPCs que acuden a zonas de trabajo y realizan animaciones reales.
- **Sistema de Testigos:** Llamadas al 911 si presencian crímenes.
- **Economía:** Generación de ingresos para negocios de jugadores y propinas de delivery.

## 🛠️ Instalación
1. Importar el archivo `utils/npcs.sql` en la base de datos.
2. Asegurar las dependencias: `ox_lib`, `ox_inventory`, `oxmysql`.
3. Añadir `ensure rv-npc-system` en el `server.cfg`.

## 📂 Estructura
- `/client`: Lógica de comportamiento, tráfico y trabajos.
- `/server`: Gestión de base de datos, inventarios y alertas.
- `/utils`: Utilidades compartidas y esquemas SQL.
