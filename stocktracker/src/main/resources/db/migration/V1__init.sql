CREATE TABLE currency(
    id bigserial primary key,
    currency char(3) not null unique,
    name varchar(80) not null,
    created_at timestamptz not null default now(),
    is_crypto boolean not null default false
);

create table users(
    id bigserial primary key,
    email varchar(255) not null unique,
    phone varchar(50),
    password text not null,
    created_at timestamptz not null default now()
);

create table portfolio(
    id bigserial primary key,
    user_id bigint not null,
    name varchar(120) not null,
    base_currecy char(3) not null,

    constraint fk_portofolio_user
        foreign key (user_id) references users(id)
        on delete cascade,
    constraint fk_portfolio_currency
        foreign key (base_currecy) references currency(currency)
);
create unique index uq_portfolio_user_name on portfolio(user_id, name);
create unique index idx_portfolio_user on portfolio(user_id);

create table exchange(
                         id bigserial primary key,
                         name varchar(100) not null unique,
                         timezone varchar(50),
                         created_at timestamptz not null default now()
);
create table instruments(
    id bigserial primary key,
    symbol varchar(20)not null unique ,
    name varchar(100) not null,
    type varchar(30) not null,
    curency_id bigint not null,
    exchange_id bigint not null,
    created_at timestamptz not null default now(),

    constraint fk_instrument_currency
        foreign key (curency_id) references currency(id),

    constraint fk_instrument_exchange
        foreign key (exchange_id) references exchange(id)

);

create table prices(
    id bigserial primary key,
    instrument_id bigint not null,
    price numeric(18,6) not null,
    close numeric (18,6),
    volume numeric(18,2),
    ts timestamptz not null,


    constraint fk_prices_instrument
        foreign key (instrument_id) references instruments(id)
                   on delete cascade
);


create index idx_prices_instrument_ts on prices(instrument_id,ts);

create table positions(
    id bigserial primary key,
    portfolio_id bigint not null,
    instrument_id bigint not null,
    quantity numeric(20,6) not null,
    avg_price numeric(18,6),
    created_at timestamptz not null default now(),

    constraint fk_positions_portfolio
         foreign key (portfolio_id) references portfolio(id)
               on delete cascade,

    constraint fk_positions_instrument
        foreign key (instrument_id) references instruments(id)
                 on delete cascade
);

create unique index uq_positions_portfolio_instrument
    on positions(portfolio_id, instrument_id);
create table transactions(
    id bigserial primary key,
    portfolio_id bigint not null,
    instrument_id bigint not null,
    side varchar(4) not null check (side in ('BUY','SELL')),
    qty numeric(20,6) not null check (qty > 0),
    price numeric(18,6) not null check (price >= 0),
    fee numeric(18,6) not null default 0,
    trade_ts timestamptz not null default now(),
    status varchar(20) not null default 'DONE',

    constraint fk_trx_portfolio
        foreign key (portfolio_id) references portfolio(id)
            on delete cascade,

    constraint fk_trx_instrument
        foreign key (instrument_id) references instruments(id)
            on delete cascade
);

create index idx_trx_portfolio_ts on transactions(portfolio_id, trade_ts desc);
create index idx_trx_instrument on transactions(instrument_id);

create table watchlist(
    id bigserial primary key,
    user_id bigint not null,
    name varchar(120) not null,
    created_at timestamptz not null default now(),

    constraint fk_watchlist_user
        foreign key (user_id) references users(id)
            on delete cascade
);

create unique index uq_watchlist_user_name
    on watchlist(user_id, name);

create table watchlist_instruments(
    watchlist_id bigint not null,
    instrument_id bigint not null,

    constraint fk_wlinst_watchlist
        foreign key (watchlist_id) references watchlist(id)
        on delete cascade,

    constraint fk_wlinst_instrument
        foreign key (instrument_id) references instruments(id)
        on delete cascade,

    constraint pk_watchlist_instruments
        primary key (watchlist_id, instrument_id)
);
create table alerts(
    id bigserial primary key,
    user_id bigint not null,
    instrument_id bigint not null,
    condition varchar(20) not null,
    target_price numeric(18,6) not null,
    created_at timestamptz not null default now(),
    active boolean not null default true,

    constraint fk_alerts_user
        foreign key (user_id) references users(id)
            on delete cascade,

    constraint fk_alerts_instrument
        foreign key (instrument_id) references instruments(id)
            on delete cascade
);

create index idx_alerts_user on alerts(user_id);
create index idx_alerts_instrument on alerts(instrument_id);

