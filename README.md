# 🎭 Rockstar Valle: Sistema de NPCs Autónomos (Edición NEO-EVO)

Este recurso transforma a los NPCs genéricos de San Andreas en entes con **conciencia biométrica**. Gracias a la integración con el sistema **NEO-EVO**, los ciudadanos, conductores y bandas reaccionan dinámicamente según el ADN, la Clase y la Humanidad del jugador.

## 🧬 Integración NEO-EVO
El sistema utiliza un **Puente de ADN** (`sh_utils.lua`) para escanear a los jugadores en tiempo real.

- **Detección de Clase:** Los NPCs identifican si eres *Solo, Netrunner o Corpo*.
- **Estado de Humanidad:** Si el jugador entra en fase de **Ciberpsicosis** (Humanidad < 20), se activa un protocolo de pánico global.
- **Nivel de ADN:** Influye directamente en el respeto social y las bonificaciones económicas.

---

## 🛠️ Estructura del Proyecto

### 📁 Lado Cliente (`/client`)
| Archivo | Función Principal |
| :--- | :--- |
| `cl_main.lua` | **Núcleo de Sentidos:** Gestiona el spawn y el escaneo biométrico constante. |
| `cl_gangs.lua` | **IA de Combate:** Las bandas detectan amenazas según la clase del jugador. |
| `cl_driving.lua` | **Tráfico Inteligente:** Los conductores se apartan ante sujetos peligrosos. |
| `cl_jobs.lua` | **Rutinas Laborales:** Los trabajadores muestran respeto o huyen según tu aura. |
| `cl_delivery.lua` | **Economía Social:** Propinas y trato según tu carisma (Temple). |

### 📁 Lado Servidor (`/server`)
| Archivo | Función Principal |
| :--- | :--- |
| `sv_main.lua` | **Gestión de Entidades:** Registro de muertes, dispatch policial y stashes. |
| `sv_economy.lua` | **Cajero Bio:** Procesa pagos, robos y bonos basados en estadísticas de ADN. |

### 📁 Shared & Utils
| Archivo | Función Principal |
| :--- | :--- |
| `config.lua` | **Panel de Control:** Ajuste de distancias, probabilidades y umbrales bio. |
| `utils/sh_utils.lua` | **El Puente:** La función maestra `GetPlayerBioData` que une ambos scripts. |

---

## 🚦 Requisitos e Instalación

1. Asegúrate de tener instalados los siguientes recursos:
   - `ox_lib`
   - `ox_inventory`
   - `neo_evo` (Indispensable para la lógica de ADN)

2. Orden de carga en el `server.cfg`:
   ```bash
   ensure ox_lib
   ensure neo_evo
   ensure rockstar_valle



El sistema creará automáticamente una tabla en tu base de datos llamada rv_npcs para guardar la reputación y estado de cada ciudadano.


🔧 Configuración Rápida
Para ajustar la sensibilidad de los NPCs, edita el archivo config.lua:
Config.PanicHumanity: Umbral de miedo.
Config.BioScanDistance: Qué tan cerca deben estar para reconocerte.
Config.CorpoBonus: Dinero extra para la clase ejecutiva.
Desarrollado bajo el protocolo Modo Arquitecto - Conexión Rockstar Valle + NEO-EVO (2026).