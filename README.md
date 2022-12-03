### install `pgcli`

```shell
brew install pgcli
```

### start postgres, create and init DB

```shell
docker compose up -d
```

### connect to DB

```shell
pgcli postgres://postgres:test@localhost:5432/postgres
```

# Phenomenas

## Dirty read

Occurs when  transaction is allowed to **read** data from a row that has been modified by another running transaction and not yet committed

## Lost update

Occurs when two processes read the same data and then try to update the data with a different value and one of the updates is lost

Both transactions:
```postgresql
begin;

SELECT total FROM orders WHERE id=1;

UPDATE orders SET total=100+1 WHERE id=1;

commit;
```

## Non-repeatable read

Occurs when, during the course of the transaction, a row is retrieved twice and the values within the row differ between reads

1st transaction:
```postgresql
begin;

SELECT * FROM orders;

SELECT * FROM orders;

commit;
```

2nd transaction:
```postgresql
begin;

UPDATE orders SET total=100+1 WHERE id=1;

commit;
```

## Phantoms

Occurs when, in the course of a transactions, new rows are added or removed by another transaction to the records being read

1st transaction:
```postgresql
begin;

SELECT * FROM orders;

SELECT * FROM orders;

commit;
```

2nd transaction:
```postgresql
begin;

INSERT INTO orders(description,total,status) VALUES ('one more', 100, 'NEW');

commit;
```

## Serialization anomaly

The result of successfully committing a group of transactions is inconsistent with all possible orderings of running those transactions one at a time

1st transaction:
```postgresql
begin;

SELECT SUM(total) FROM orders WHERE status='NEW';

INSERT INTO orders(description,total,status) VALUES ('one failed', 100, 'FAILED');

commit;
```

2nd transaction:
```postgresql
begin;

SELECT SUM(total) FROM orders WHERE status='FAILED';

INSERT INTO orders(description,total,status) VALUES ('one new', 250, 'NEW');

commit;
```

# Isolation levels

* Read uncommitted
* Read committed
* Repeatable read
* Serializable

## Isolation levels in PostgreSQL

| level           | Dirty read | Non-repeatable read | Lost update | Phantoms | Serialization anomaly |
|-----------------|------------|---------------------|-------------|----------|-----------------------|
| Read committed  | +          | -                   | -           | -        | -                     |
| Repeatable read | +          | +                   | +           | +        | -                     |
| Serializable    | +          | +                   | +           | +        | +                     |

Read uncommitted behaves exactly as read committed, which is default

## Repeatable read

1st transaction:
```postgresql
begin;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT * FROM orders;

SELECT * FROM orders;

UPDATE orders SET total=100+1 WHERE id=1;

rollback;
```

2nd transaction:
```postgresql
begin;

UPDATE orders SET total=100+1 WHERE id=1;

INSERT INTO orders(description,total,status) VALUES ('one more', 100, 'NEW');

commit;
```

## Serializable

1st transaction:
```postgresql
begin;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT SUM(total) FROM orders WHERE status='NEW';

INSERT INTO orders(description,total,status) VALUES ('one failed', 100, 'FAILED');

commit;
```

2nd transaction:
```postgresql
begin;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT SUM(total) FROM orders WHERE status='FAILED';

INSERT INTO orders(description,total,status) VALUES ('one new', 250, 'NEW');

commit;
```

# Retries

* Repeatable read
  * ERROR: could not serialize access due to concurrent update
* Serializable
  * ERROR: could not serialize access due to read/write dependencies among transactions

# Tradeoff
consistency / concurrency
