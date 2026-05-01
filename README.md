# DatabasePaymentDataEntry — Payment Data Entry (SSDT)

Proyecto **SQL Server Database** con **SQL Server Data Tools (SSDT)**: esquema `dbo` versionado como código (tablas, vistas, procedimientos almacenados y scripts) para la base lógica **`PaymentDataEntry`** — captura y procesamiento de transferencias / pagos, preparación en agencia, integraciones con APIs y flujos de socio (partners).

## Estructura del repositorio

| Elemento | Descripción |
|----------|-------------|
| **`Databases.PaymentDataEntry.sln`** | Solución Visual Studio que referencia el único proyecto de base de datos. |
| **`Databases.PaymentDataEntry/`** | Proyecto **`Databases.PaymentDataEntry.sqlproj`** (DSP orientado a **SQL Server 2016+**, `Sql130DatabaseSchemaProvider`). |
| **`dbo/Tables`** | Definiciones de tablas (p. ej. preparación de wires, socios, tarjetas, logs, CFPB, geolocalización, etc.). |
| **`dbo/Stored Procedures`** | Lógica principal: creación y actualización de preparaciones, WebApi/WebAgent, bill payment, partners, ImxDirect, búsqueda de recibos (`PaymentDataEntrySearchReceipt*`), anulaciones (`WebAgent_VoidPaymentDataEntry`), puentes con otras bases, jobs de alerta, etc. |
| **`dbo/Views`** | Vistas de consulta (p. ej. wires del día, joins con datos de cliente). |
| **`azure-pipelines.yml`** | Pipeline de **Azure DevOps**: NuGet, `VSBuild` de la solución, copia del **`.dacpac`** desde `Databases.PaymentDataEntry/bin/$(buildConfiguration)` y publicación de artefactos. |

## Requisitos

- **Visual Studio** con la carga de trabajo **Almacenamiento y procesamiento de datos** (incluye SSDT / proyectos de base de datos).
- Instancia de **SQL Server** (local o remota) compatible con el nivel de compatibilidad que definas al publicar.
- Ajusta el **pool de agentes** y la rama `trigger` en `azure-pipelines.yml` a tu organización.

## Compilar y publicar

1. Abre **`Databases.PaymentDataEntry.sln`**.
2. Compila el proyecto (Debug o Release); el artefacto típico es **`Databases.PaymentDataEntry.dacpac`** bajo `bin\<Configuración>\`.
3. Publica contra tu servidor con el asistente de publicación de SSDT o con **`SqlPackage.exe`**, según tu entorno.

Los scripts pueden referenciar **otras bases** del mismo ecosistema (por ejemplo catálogos o transacciones en otras bases con nombre de tres partes). Revisa y adapta esas referencias si despliegas en un entorno aislado o de demostración.


## Contribución

1. No subir **credenciales**, cadenas de producción ni datos personales en scripts.
2. Probar el despliegue del `.dacpac` en una base de desarrollo antes de integrar cambios grandes.
3. Mantener scripts **idempotentes** donde aplique (creación condicional, migraciones coordinadas con el equipo).

---

*README del proyecto de base de datos; complementa servicios de aplicación (por ejemplo APIs de bill payment o data entry) en otros repositorios.*
