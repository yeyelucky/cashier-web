-- ============================================================
-- 收银系统 Supabase 建表脚本
-- 使用方法：Supabase 控制台 → SQL Editor → 粘贴本文件全部内容 → Run
-- ============================================================

-- ---------- 表 1：goods 商品库 ----------
-- 商品条码、商品名称、售卖单价、当前库存（成本/利润/折扣等保留在本地）
create table if not exists goods (
  id bigint generated always as identity primary key,
  barcode text unique not null,          -- 商品条码
  name text not null,                    -- 商品名称
  price numeric not null default 0,      -- 售卖单价
  qty integer not null default 0,        -- 当前库存
  created_at timestamp default now()
);

-- ---------- 表 2：sales_all 订单汇总（看板·订单明细每单一行） ----------
create table if not exists sales_all (
  id bigint generated always as identity primary key,
  order_no text unique not null,         -- 订单号
  time timestamp default now(),          -- 下单时间
  total numeric not null default 0,      -- 实付
  cost numeric not null default 0,       -- 成本
  profit numeric not null default 0,     -- 毛利
  discount numeric not null default 0,   -- 优惠
  original numeric not null default 0,   -- 原价
  qty integer not null default 0         -- 件（本单总件数）
);

-- ---------- 表 3：sales 订单商品明细（每单每个商品一行） ----------
create table if not exists sales (
  id bigint generated always as identity primary key,
  order_no text not null,                -- 订单号（关联 sales_all.order_no）
  time timestamp default now(),          -- 下单时间
  barcode text,                          -- 商品条码
  name text,                             -- 商品名称
  price numeric not null default 0,      -- 单价
  discount numeric not null default 1,   -- 折扣
  qty integer not null default 0,        -- 数量
  subtotal numeric not null default 0    -- 小计 = 单价×折扣×数量
);

-- ---------- 开启 RLS + 公开策略（内部收银使用） ----------
alter table goods enable row level security;
alter table sales_all enable row level security;
alter table sales enable row level security;

-- goods：允许匿名公开读写
drop policy if exists "public_goods_select" on goods;
drop policy if exists "public_goods_insert" on goods;
drop policy if exists "public_goods_update" on goods;
drop policy if exists "public_goods_delete" on goods;
create policy "public_goods_select" on goods for select to anon using (true);
create policy "public_goods_insert" on goods for insert to anon with check (true);
create policy "public_goods_update" on goods for update to anon using (true) with check (true);
create policy "public_goods_delete" on goods for delete to anon using (true);

-- sales_all：允许匿名公开读写
drop policy if exists "public_sales_all_select" on sales_all;
drop policy if exists "public_sales_all_insert" on sales_all;
drop policy if exists "public_sales_all_update" on sales_all;
drop policy if exists "public_sales_all_delete" on sales_all;
create policy "public_sales_all_select" on sales_all for select to anon using (true);
create policy "public_sales_all_insert" on sales_all for insert to anon with check (true);
create policy "public_sales_all_update" on sales_all for update to anon using (true) with check (true);
create policy "public_sales_all_delete" on sales_all for delete to anon using (true);

-- sales：允许匿名公开读写
drop policy if exists "public_sales_select" on sales;
drop policy if exists "public_sales_insert" on sales;
drop policy if exists "public_sales_update" on sales;
drop policy if exists "public_sales_delete" on sales;
create policy "public_sales_select" on sales for select to anon using (true);
create policy "public_sales_insert" on sales for insert to anon with check (true);
create policy "public_sales_update" on sales for update to anon using (true) with check (true);
create policy "public_sales_delete" on sales for delete to anon using (true);
