-- Accounts: the ledger's balance side. vpa (Virtual Payment Address) is a
-- natural key, not a surrogate id, because it's what every packet and every
-- API call references.
CREATE TABLE accounts (
    vpa          VARCHAR(255)   NOT NULL PRIMARY KEY,
    holder_name  VARCHAR(255)   NOT NULL,
    balance      NUMERIC(19,2)  NOT NULL,
    version      BIGINT         NOT NULL DEFAULT 0
);

-- Transactions: append-only settlement record. packet_hash is the
-- idempotency key — its uniqueness constraint is the database's own
-- defense-in-depth if the in-process (later: Redis) claim layer ever misses.
CREATE TABLE transactions (
    id             BIGSERIAL     PRIMARY KEY,
    packet_hash    VARCHAR(64)   NOT NULL,
    sender_vpa     VARCHAR(255)  NOT NULL,
    receiver_vpa   VARCHAR(255)  NOT NULL,
    amount         NUMERIC(19,2) NOT NULL,
    signed_at      TIMESTAMPTZ   NOT NULL,
    settled_at     TIMESTAMPTZ   NOT NULL,
    bridge_node_id VARCHAR(255)  NOT NULL,
    hop_count      INTEGER       NOT NULL,
    status         VARCHAR(20)   NOT NULL,
    CONSTRAINT uk_transactions_packet_hash UNIQUE (packet_hash)
);
