# Supabase Setup Guide

## 1. Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Copy your **Project URL** and **anon/public key** from Settings → API

## 2. Configure Credentials

Open `lib/core/constants/app_constants.dart` and replace:

```dart
static const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://YOUR_PROJECT.supabase.co',  // ← Replace this
);
static const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_ANON_KEY',  // ← Replace this
);
```

**Or** pass them at build time:
```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## 3. Run the SQL Migration

In Supabase Dashboard → SQL Editor, run the full schema:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PROFILES
CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  business_name TEXT,
  email         TEXT UNIQUE NOT NULL,
  avatar_url    TEXT,
  currency      TEXT NOT NULL DEFAULT 'USD',
  timezone      TEXT NOT NULL DEFAULT 'UTC',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- CLIENTS
CREATE TABLE clients (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  display_name     TEXT NOT NULL,
  full_name        TEXT NOT NULL,
  business_name    TEXT,
  business_type    TEXT,
  industry         TEXT,
  email            TEXT,
  phone            TEXT,
  website          TEXT,
  address_line1    TEXT,
  address_line2    TEXT,
  city             TEXT,
  state            TEXT,
  postal_code      TEXT,
  country          TEXT,
  client_since     DATE,
  status           TEXT NOT NULL DEFAULT 'active'
                   CHECK (status IN ('active','inactive','lead','churned')),
  tier             TEXT NOT NULL DEFAULT 'standard'
                   CHECK (tier IN ('free','standard','premium','enterprise')),
  payment_terms    TEXT DEFAULT 'net30',
  tax_id           TEXT,
  currency         TEXT DEFAULT 'USD',
  credit_limit     NUMERIC(15,2),
  notes            TEXT,
  tags             TEXT[] DEFAULT '{}',
  avatar_color     TEXT DEFAULT '#6366F1',
  is_archived      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- NODES (Worktree)
CREATE TABLE nodes (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id     UUID REFERENCES nodes(id) ON DELETE CASCADE,
  client_id     UUID REFERENCES clients(id) ON DELETE SET NULL,
  name          TEXT NOT NULL,
  node_type     TEXT NOT NULL
                CHECK (node_type IN ('root','income','expense','client','service','donation','category','subscription')),
  icon          TEXT DEFAULT '📁',
  color         TEXT DEFAULT '#6366F1',
  sort_order    INTEGER NOT NULL DEFAULT 0,
  amount        NUMERIC(15,2),
  currency      TEXT DEFAULT 'USD',
  billing_cycle TEXT CHECK (billing_cycle IN ('one_time','daily','weekly','monthly','quarterly','yearly')),
  start_date    DATE,
  renewal_date  DATE,
  end_date      DATE,
  status        TEXT DEFAULT 'active'
                CHECK (status IN ('active','paused','cancelled','pending')),
  notes         TEXT,
  tags          TEXT[] DEFAULT '{}',
  is_archived   BOOLEAN NOT NULL DEFAULT FALSE,
  depth         INTEGER NOT NULL DEFAULT 0 CHECK (depth <= 6),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TRANSACTIONS
CREATE TABLE transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  node_id         UUID REFERENCES nodes(id) ON DELETE SET NULL,
  client_id       UUID REFERENCES clients(id) ON DELETE SET NULL,
  type            TEXT NOT NULL CHECK (type IN ('income','expense','transfer','donation')),
  amount          NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  currency        TEXT NOT NULL DEFAULT 'USD',
  exchange_rate   NUMERIC(10,6) DEFAULT 1.000000,
  amount_base     NUMERIC(15,2),
  category        TEXT,
  sub_category    TEXT,
  description     TEXT NOT NULL,
  payment_method  TEXT DEFAULT 'bank_transfer'
                  CHECK (payment_method IN ('bank_transfer','credit_card','paypal','crypto','cash','stripe','other')),
  reference_no    TEXT,
  transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date         DATE,
  paid_date        DATE,
  status          TEXT NOT NULL DEFAULT 'completed'
                  CHECK (status IN ('pending','completed','failed','refunded','cancelled')),
  receipt_url     TEXT,
  invoice_url     TEXT,
  is_taxable      BOOLEAN DEFAULT FALSE,
  tax_rate        NUMERIC(5,2) DEFAULT 0,
  tax_amount      NUMERIC(15,2) DEFAULT 0,
  is_recurring    BOOLEAN DEFAULT FALSE,
  recurrence_id   UUID,
  notes           TEXT,
  tags            TEXT[] DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RECURRING RULES
CREATE TABLE recurring_rules (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  node_id         UUID REFERENCES nodes(id),
  client_id       UUID REFERENCES clients(id),
  name            TEXT NOT NULL,
  type            TEXT NOT NULL CHECK (type IN ('income','expense','donation')),
  amount          NUMERIC(15,2) NOT NULL,
  currency        TEXT DEFAULT 'USD',
  frequency       TEXT NOT NULL CHECK (frequency IN ('daily','weekly','monthly','quarterly','yearly')),
  start_date      DATE NOT NULL,
  end_date        DATE,
  next_run_date   DATE NOT NULL,
  last_run_date   DATE,
  is_active       BOOLEAN DEFAULT TRUE,
  auto_create     BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date DESC);
CREATE INDEX idx_transactions_client    ON transactions(client_id);
CREATE INDEX idx_transactions_node      ON transactions(node_id);
CREATE INDEX idx_nodes_parent           ON nodes(parent_id);
CREATE INDEX idx_nodes_user             ON nodes(user_id);
CREATE INDEX idx_clients_user           ON clients(user_id);

-- ROW LEVEL SECURITY
ALTER TABLE profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients      ENABLE ROW LEVEL SECURITY;
ALTER TABLE nodes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own_data" ON profiles     FOR ALL USING (id = auth.uid());
CREATE POLICY "own_data" ON clients      FOR ALL USING (user_id = auth.uid());
CREATE POLICY "own_data" ON nodes        FOR ALL USING (user_id = auth.uid());
CREATE POLICY "own_data" ON transactions FOR ALL USING (user_id = auth.uid());
CREATE POLICY "own_data" ON recurring_rules FOR ALL USING (user_id = auth.uid());

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, business_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    new.raw_user_meta_data->>'business_name'
  );
  RETURN new;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

## 4. Enable Google OAuth (optional)
In Supabase Dashboard → Authentication → Providers → Google, enable and add your Google OAuth credentials.

## 5. Run the App

```bash
# Local
flutter run

# Web
flutter run -d chrome

# With Supabase credentials
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```
