ALTER TABLE stocks RENAME TO old_stocks;

CREATE TABLE stocks (
  id TEXT,
  ticker TEXT,
  company TEXT,
  legal_name TEXT,
  exchange TEXT,
  currency TEXT,
  sector TEXT,
  industry TEXT
);

INSERT INTO stocks SELECT sec_id AS id, ticker, company, legal_name, exchange, currency, sector, industry FROM old_stocks;
DROP TABLE old_stocks;

SELECT 
  name || " (" || ticker || ") - " || exchange AS label,
  id || "_" || currency AS value
FROM stocks WHERE label LIKE %'EQNR'%
LIMIT