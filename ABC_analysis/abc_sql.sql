-- Проведу АВС-анализ на языке SQL, используя базу данных nordwind. 
-- product_id - идентификатор товара
-- quantity - количество проданных единиц
with a as (select product_id, sum(quantity) as quantity
  from order_details od
  group by product_id),
b as (select product_id, quantity, quantity/sum(quantity) over() as ratio 
  from a
  order by quantity desc),
c as (select product_id, sum(ratio) over (range between unbounded preceding and current row) as cumsum
  from b)
select product_id, 
case
 when cumsum <= 0.8 then 'A'
 when cumsum <= 0.95 then 'B'
 else 'C' 
end groups
from c
