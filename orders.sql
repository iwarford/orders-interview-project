create table if not exists orders (
       order_id integer primary key autoincrement,
       order_date text,
       customer_id integer,
       order_number text,
       item_name text,
       item_manufacturer text,
       item_price_cents integer,
       foreign key(customer_id) references customer(customer_id)       
);

create table if not exists customers (
      customer_id integer primary key autoincrement,
      customer_code integer,
      first_name text,
      last_name text
);

create table if not exists upload_log (
      md5sum text
);
