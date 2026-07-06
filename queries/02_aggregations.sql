-- ============================================================
# Bloque 2 — Comportamiento de conversación
-- ============================================================

# ¿Quién inicia la conversación habitualmente, el cliente o el repartidor?

SELECT * FROM customer_courier_chat_messages ORDER BY conversation_started_at LIMIT 1;

# ¿Cuántos mensajes envía el cliente por pedido? 

SELECT order_id, sender_app_type, 
	COUNT(*) AS Mensajes_mandados
	FROM customer_courier_chat_messages 
	WHERE sender_app_type LIKE "Customer%" 
	GROUP BY order_id, sender_app_type;

# ¿Cuál es el primer mensaje de cada conversación?

SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY message_sent_time) AS RN
    FROM customer_courier_chat_messages
) AS subconsulta
WHERE RN = 1;
    
# ¿Cuál es el último, y en qué fase del pedido ocurrió?

SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY message_sent_time DESC) AS RN
    FROM customer_courier_chat_messages
) AS subconsulta
WHERE RN = 1;

# ¿Cuánto tiempo pasa hasta que el primer mensaje recibe respuesta?

SELECT 
    -- Agrupo por order_id para calcular el tiempo de respuesta específico de cada pedido
    order_id,
    -- TIMESTAMPDIFF calcula la resta en segundos entre el inicio (MIN) y la primera respuesta hallada
    TIMESTAMPDIFF(SECOND, 
        -- Aquí saco el inicio real del chat: la fecha del primer mensaje total
        MIN(message_sent_time), 
        -- Busco la primera fecha de alguien que no sea el que inició el chat
        MIN(CASE 
            WHEN from_id != (
                -- Subconsulta para saber quién envió el primer mensaje del chat (el iniciador)
                SELECT from_id 
                FROM customer_courier_chat_messages m2 
                WHERE m2.order_id = customer_courier_chat_messages.order_id 
                ORDER BY message_sent_time ASC 
                LIMIT 1
            ) THEN message_sent_time 
        END)
    ) AS first_responsetime_delay_seconds
FROM customer_courier_chat_messages
-- Obligatorio agrupar por el ID del pedido para que las funciones (MIN, etc.) operen por cada chat
GROUP BY order_id;