-- ============================================================
# Bloque 1 — Exploración básica
-- ============================================================

# ¿Cómo se ve el histórico completo de mensajes ordenado por pedido? 

SELECT * FROM orders ORDER BY order_id;

# ¿Y si lo ordenamos por ciudad para detectar patrones geográficos? 

SELECT * FROM orders ORDER BY city_code;
