CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  pass_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE memberships (
  user_id TEXT NOT NULL REFERENCES users(id),
  project TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  PRIMARY KEY (user_id, project)
);

CREATE TABLE items (
  id TEXT PRIMARY KEY,
  project TEXT NOT NULL,
  collection TEXT NOT NULL,
  user_id TEXT NOT NULL REFERENCES users(id),
  data TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_items_lookup ON items(project, collection, user_id);