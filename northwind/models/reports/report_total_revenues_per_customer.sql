-- config
{{ config(
    schema='gold',
    materialized='table'
) }}

-- IMPORT

with clientes_com_pedidos as (
    select 
        customers.customer_id,
        customers.company_name, 
        orders.order_id,
        order_details.unit_price,
        order_details.quantity,
        order_details.discount
    from 
        {{ ref('stg_customers') }} as customers
    inner join 
        {{ ref('stg_orders') }} as orders on customers.customer_id = orders.customer_id
    inner join 
        {{ ref('stg_orders_details') }} as order_details on order_details.order_id = orders.order_id
)

-- REGRA DE NEGOCIO

, total_pedidos_por_cliente as (
    select 
        company_name, 
        sum(unit_price * quantity * (1.0 - discount)) as total
    from 
        clientes_com_pedidos
    group by 
        company_name
)

-- QUERY FINAL

select *
from total_pedidos_por_cliente
order by total desc
