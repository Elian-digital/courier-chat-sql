CREATE TABLE customer_courier_chat_messages (
    sender_app_type VARCHAR(50),
    customer_id INT,
    from_id INT,
    to_id INT,
    chat_started_by_message BOOLEAN,
    order_id INT,
    order_stage VARCHAR(50),
    courier_id INT,
    message_sent_time DATETIME
);

INSERT INTO customer_courier_chat_messages
(sender_app_type, customer_id, from_id, to_id, chat_started_by_message, order_id, order_stage, courier_id, message_sent_time)
VALUES
('Customer IOS', 99, 99, 21, FALSE, 555, 'PICKING_UP', 21, '2022-08-09 08:02'),
('Courier IOS', 99, 21, 99, FALSE, 555, 'ARRIVING', 21, '2022-08-09 08:01'),
('Customer IOS', 99, 99, 21, FALSE, 555, 'PICKING_UP', 21, '2022-08-09 08:00'),
('Courier Android', 122, 87, 122, TRUE, 38, 'ADDRESS_DELIVERY', 87, '2022-08-09 07:55'),
('Customer Android', 43, 43, 75, FALSE, 875, 'PICKING_UP', 75, '2022-08-07 14:55'),
('Courier Android', 43, 75, 43, FALSE, 875, 'ARRIVING', 75, '2022-08-07 14:53'),
('Customer Android', 43, 43, 75, FALSE, 875, 'PICKING_UP', 75, '2022-08-07 14:51'),
('Courier Android', 43, 75, 43, TRUE, 875, 'ADDRESS_DELIVERY', 75, '2022-08-07 14:50'),
('Customer IOS', 23, 23, 21, FALSE, 134, 'PICKING_UP', 21, '2022-08-07 10:02'),
('Courier IOS', 23, 21, 23, FALSE, 134, 'ARRIVING', 21, '2022-08-07 10:01'),
('Customer IOS', 23, 23, 21, FALSE, 134, 'PICKING_UP', 21, '2022-08-07 10:00');


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    city_code VARCHAR(10)
);

INSERT INTO orders (order_id, city_code) VALUES
(38, 'BCN'),
(134, 'OPO'),
(555, 'BCN'),
(875, 'VAL');

