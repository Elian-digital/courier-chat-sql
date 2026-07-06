# Courier Chat SQL Analysis
### Transformar mensajes individuales en métricas de conversación accionables

---

> Una app de delivery genera cientos de mensajes entre clientes y repartidores cada hora. El reto no es almacenarlos — es convertirlos en algo útil: ¿quién abre la conversación? ¿cuánto tarda la primera respuesta? ¿en qué momento del pedido se concentran los problemas?

Este proyecto responde esas preguntas con SQL puro, desde consultas básicas hasta un pipeline de agregación que construye una tabla de conversaciones lista para análisis.

---

## El dataset

Dos tablas:

**`customer_courier_chat_messages`** — cada fila es un mensaje individual entre cliente y repartidor. Incluye quién lo envió (`sender_app_type`), cuándo (`message_sent_time`), en qué fase del pedido se encontraba (`order_stage`) y los IDs de ambas partes.

**`orders`** — relaciona cada `order_id` con su `city_code`.

---

## Preguntas de negocio

Las queries están organizadas por complejidad en tres bloques.

### Bloque 1 — Exploración básica

- ¿Cómo se ve el histórico completo de mensajes ordenado por pedido?
- ¿Y si lo ordenamos por ciudad para detectar patrones geográficos?

### Bloque 2 — Comportamiento de conversación

- ¿Quién inicia la conversación habitualmente, el cliente o el repartidor?
- ¿Cuántos mensajes envía el cliente por pedido?
- ¿Cuál es el primer mensaje de cada conversación?
- ¿Cuál es el último, y en qué fase del pedido ocurrió?
- ¿Cuánto tiempo pasa hasta que el primer mensaje recibe respuesta?

### Bloque 3 — Pipeline de conversaciones

- ¿Cómo se agregan todos los mensajes de un pedido en una única fila de conversación con todas sus métricas?

---

## El pipeline de conversación

La query más relevante del proyecto es la que construye `customer_courier_conversations`: una tabla donde cada fila representa una conversación completa, con sus timestamps de inicio y fin, conteos por sender, tiempo de primera respuesta y el estado del pedido cuando se cerró el chat.

La lógica se articula en cuatro CTEs encadenadas:

1. **`ordered_msgs`** — añade un ranking temporal a cada mensaje dentro de su pedido (`ROW_NUMBER() OVER PARTITION BY order_id`).
2. **`first_msg`** — extrae el primer mensaje de cada conversación y quién lo envió.
3. **`first_reply`** — encuentra la primera respuesta del lado contrario al que abrió.
4. **`last_msg`** — recupera el último mensaje y el `order_stage` en ese momento.

El `SELECT` final agrega el resto de métricas con `COUNT` y `MIN` condicionales sobre `sender_app_type`.

Un `LEFT JOIN` en `first_reply` garantiza que las conversaciones sin respuesta no desaparezcan del resultado — aparecen con `NULL` en `first_responsetime_delay_seconds`.

---

## Stack técnico

- MySQL
- Window functions: `ROW_NUMBER()`, `PARTITION BY`, `ORDER BY`
- CTEs encadenadas
- Agregaciones condicionales (`COUNT CASE WHEN`, `MIN CASE WHEN`)
- TIMESTAMPDIFF(SECOND, ...) para diferencias de tiempo en segundos
- `LEFT JOIN` para preservar casos sin respuesta

---

## Estructura del repositorio

```
courier-chat-sql/
├── queries/
│   ├── 01_basic_selects.sql          # Q1–Q2: SELECTs con JOIN y ORDER BY
│   ├── 02_aggregations.sql           # Q3–Q6: primeros/últimos mensajes, conteos
│   └── 03_conversation_pipeline.sql  # Q7–Q8: tiempos de respuesta y tabla final
└── data/
    └── sample_data.sql               # DDL + INSERT con datos de ejemplo
```

---

## Contacto

[LinkedIn](https://www.linkedin.com/in/eliandaghoum/) · eliandaghoum@gmail.com · [GitHub](https://github.com/Elian-digital)
