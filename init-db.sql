CREATE TYPE order_status_type AS ENUM('NEW','DONE','FAILED');

CREATE TABLE orders
(
    id          SERIAL PRIMARY KEY,
    description text,
    total       decimal,
    status      order_status_type,
    created_at  timestamp NOT NULL DEFAULT now()
);

INSERT INTO orders(description, total, status)
values ('new order', 100.0, 'NEW'),
       ('done order', 50.0, 'FAILED'),
       ('failed order', 200.0, 'FAILED');
