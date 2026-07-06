-- ==========================================================================
#  Pipeline de conversaciones
-- ==========================================================================
# ¿Cómo se agregan todos los mensajes de un pedido en una única fila de conversación con todas sus métricas?


CREATE TABLE customer_courier_conversations AS                                                           -- i. Creo la tabla resumen de conversaciones por pedido
SELECT 
    m.order_id,
    o.city_code,
    MIN(CASE WHEN m.from_id = m.courier_id THEN m.message_sent_time END) AS first_courier_message,       -- iii. Primera marca de tiempo del courier
    MIN(CASE WHEN m.from_id = m.customer_id THEN m.message_sent_time END) AS first_customer_message,     -- iv. Primera marca de tiempo del cliente
    SUM(CASE WHEN m.from_id = m.courier_id THEN 1 ELSE 0 END) AS num_messages_courier,                   -- v. Conteo total mensajes courier
    SUM(CASE WHEN m.from_id = m.customer_id THEN 1 ELSE 0 END) AS num_messages_customer,                 -- vi. Conteo total mensajes cliente
    (SELECT from_id FROM customer_courier_chat_messages m2                                               -- vii. Quién inició: busco el from_id del primer mensaje por orden cronológico
     WHERE m2.order_id = m.order_id ORDER BY message_sent_time ASC LIMIT 1) AS first_message_by,
    MIN(m.message_sent_time) AS conversation_started_at,                                                     -- viii. Inicio absoluto de la conversación
      TIMESTAMPDIFF(SECOND, MIN(m.message_sent_time),                                                        -- ix. Tiempo hasta la primera respuesta (diferencia entre inicio y primer mensaje de otra parte)
         MIN(CASE WHEN m.from_id != (SELECT from_id FROM customer_courier_chat_messages m2 
                                   WHERE m2.order_id = m.order_id ORDER BY message_sent_time ASC LIMIT 1) 
            THEN m.message_sent_time END)
    ) AS first_responsetime_delay_seconds,
    MAX(m.message_sent_time) AS last_message_time,                                                                   -- x. Fin absoluto de la conversación
    (SELECT order_stage FROM customer_courier_chat_messages m3                                                       -- xi. Etapa del pedido en el último mensaje, uso subconsulta para recuperar el valor de la fila máxima 
     WHERE m3.order_id = m.order_id ORDER BY message_sent_time DESC LIMIT 1) AS last_message_order_stage
FROM customer_courier_chat_messages m
JOIN Orders o ON m.order_id = o.order_id                                                                      -- Uno con Orders para obtener city_code (ii)
GROUP BY m.order_id, o.city_code;                                                                             -- Agrupo por orden y ciudad para garantizar la unicidad de la conversación
