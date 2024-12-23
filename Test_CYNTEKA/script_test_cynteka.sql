/* Задача: найти проблемные области, подсветить их, вычислить основные метрики и показатели. 
 Сразу отмечу, что я работа в программе DBeaver с использованием СУБД PоstgreSQL, дашборд строился в системе визуализации Power BI. Базу данных авиаперевозок я выгружала в самом маленьком размере для ускорения работы. Все запросы, приведённые ниже, можно переложить на больший объём данных.
 В кусочке базы данных, с которым работаю я, содержатся данные об авиаперевозках за месяц. Теперь приступим к работе:)*/

--1. Для начала посчитаем для каждого рейса общую выручку, среднюю выручку на пассажира и количество проданных билетов, чтобы понимать самые выгодные направления, рейсы.
set search_path = bookings, public;

select f.flight_no, max(f.departure_airport) as departure_airport, max(f.arrival_airport) as arrival_airport, max(a.city) as departure_city, max(a2.city) as arrival_city, sum(tf.amount) as total_revenue, count(tf.ticket_no) as total_tickets, round(sum(tf.amount)*1.00/count(tf.ticket_no),2) as rev_per_passanger
from bookings.ticket_flights tf
join bookings.flights f
on tf.flight_id = f.flight_id 
join bookings.airports a 
on f.departure_airport = a.airport_code 
join bookings.airports a2
on f.arrival_airport = a2.airport_code
group by f.flight_no
order by total_revenue desc;


--В запросе выше я создала таблицу, в которой выведены номера рейсов, аэропорты отправления и прибытия, выручка (общая и средняя) и количество проданных билетов на каждый рейс. Города расположения аэропортов для удобства подтянуты в эту же таблицу из таблицы "airports". Рейсы отсортированы по убыванию выручки. Уже на этапе получения таблицы, без визуализации, видно, что выручка положительно коррелирует с дальностью полёта. К сожалению, в базе данных нет информации о затратах на осуществление перевозки (цены на топливо, обслуживание самолета и тд)б потому что было бы интересно посмотреть на разницу доходов и расходов для каждого рейса и найти самые прибыльные.
--Поскольку для одного рейса города отправления и прибытия всегда одинаковы, вывела эти поля с "фиктивной" агрегацией текстовых полей функцией max. Таблицу сохранила в базу под названием total

--Посмотрим распределение выручки по аэропортам прилёта. 

select f.arrival_airport, max(a.airport_name) as airport, sum(tf.amount) as total_revenue, count(tf.ticket_no) as total_tickets, round(sum(tf.amount)*1.00/count(tf.ticket_no),2) as rev_per_passanger
from bookings.ticket_flights tf
join bookings.flights f
on tf.flight_id = f.flight_id 
join bookings.airports a 
on f.arrival_airport = a.airport_code
group by f.arrival_airport 
order by total_revenue desc;

--Итак, рейсы, прилетающие в Домодедово, Шереметьево и Пулково приносят больше всего суммарного дохода и составляют топ-3. Далее идут аэропорты Хабаровск_Новый и Толмачёво. Но они не являются лидерами по средней выручке на пассажира! 

--2. Теперь посмотрим общий доход для разных классов обслуживания

select 
    tf.fare_conditions,
    sum(tf.amount) AS total_revenue, count(tf.ticket_no) as cnt
from bookings.ticket_flights tf
group by tf.fare_conditions;

--Видно, что больше всего приносят билеты класса Econom (за счёт количества проданных билетов, которое тоже выведено в таблице), затем идёт Business и затем Comfort.
--Можно также посмотреть этот показатель по рейсам, проводя снчала группировку по номеру рейса, а затем уже внутри неё -- группировку по классам обслуживания

--3. Теперь посмотрю заполняемость рейсов. Её буду считать как отношение количесвта выданных посадочных и количеству сидений в самолёте.

with bookedseats as (select bp.flight_id, count(bp.seat_no) as booked_seats
from bookings.boarding_passes bp
group by bp.flight_id),
totalseats as (select f.flight_id, count(s.seat_no) as total_seats
from bookings.flights f
join bookings.seats s 
on f.aircraft_code = s.aircraft_code
group by f.flight_id
)
select f.flight_id, f.status, f.flight_no, f.scheduled_departure, bs.booked_seats, ts.total_seats, (bs.booked_seats * 1.00 / ts.total_seats)::numeric(10, 2) as load
from bookings.flights f
join bookedseats bs on f.flight_id = bs.flight_id
join totalseats ts on f.flight_id = ts.flight_id
where bs.booked_seats != 0 and f.status in ('Departed', 'Arrived');

--Вывела таблицу, отражающую айди рейса, его номер, дату вылета и заполненность. Сохраню её в базе данных под именем load и в дальнейшем использую в создании дашборда.
--В последней строке отфильтровала рейсы по статусу, поскольку для всех других статусов, кроме Отправлен и Прибыл, данных о посадочных талонах и занятых местах в самолёте нет, следовательно рассматривать их бессмысленно.

--Пусть теперь мне интересны 10 рейсов (именно направлений, характеризующихся номером рейса, а не его айди) с минимальной заполняемостью. Выведу их с использованием предыдущего запроса.

with bookedseats as (select bp.flight_id, count(bp.seat_no) as booked_seats
from bookings.boarding_passes bp
group by bp.flight_id),
totalseats as (select f.flight_id, count(s.seat_no) as total_seats
from bookings.flights f
join bookings.seats s 
on f.aircraft_code = s.aircraft_code
group by f.flight_id
),
f_id_load as (select f.flight_id, f.status, f.flight_no, f.scheduled_departure, bs.booked_seats,
    ts.total_seats, (bs.booked_seats * 1.0 / ts.total_seats)::numeric(10, 2) as load
from bookings.flights f
join bookedseats bs 
on f.flight_id = bs.flight_id
join totalseats ts 
on f.flight_id = ts.flight_id
where bs.booked_seats != 0 and f.status in ('Departed', 'Arrived'))
select f.flight_no, round(avg(load),2) as av_load
from bookings.flights f 
join f_id_load fil
on f.flight_id = fil.flight_id
group by f.flight_no
order by av_load asc 
limit 10;

--Возможно, для этих рейсов нужно поменять маркетинговую стратегию, уменьшить количество рейсов по данным направлениям, чтобы повысить заполняемость, или поменять время рейса.

--Теперь хочу увидеть заполняемость по классам обслуживания для каждого рейса:

with seats_cl as (select aircraft_code, fare_conditions, count(seat_no) as s_cl
from bookings.seats s
group by aircraft_code , fare_conditions),
tickets_cl as (select flight_id, fare_conditions, count(ticket_no) as t_cl
from bookings.ticket_flights tf 
group by flight_id, fare_conditions)
select tcl.flight_id, tcl.fare_conditions, round(avg(t_cl)*1.000/avg(scl.s_cl),2) as class_load
from bookings.flights f
join seats_cl scl
on f.aircraft_code = scl.aircraft_code 
join tickets_cl tcl
on f.flight_id = tcl.flight_id
join seats_cl scl2
on tcl.fare_conditions = scl.fare_conditions
group by tcl.flight_id, tcl.fare_conditions
order by tcl.flight_id;

--Так видим внутри каждого рейса заполняемость ещё и по классам. Агрегатная функция усреднения количества сидений здесь фиктивна, поскольку для каждой связки рейс-класс обслуживания количество общих и занятых сидений одинаково.


--4. Посчитаем процент задержанных и отменённых рейсов среди всех, чтобы знать, в каких аэропортах/в какое время/по каким направлениям такое чаще всего происходит, и постараться устранить эти проблемы.
-- При этом уберём из рассмотрения Scheduled, тк эти рейсы ещё только запланированы, и никакой информации относительно того, вылетел он вовремя или нет, у нас не имеется.
--Отменённые можно посчитать просто
SELECT 
    status,
    COUNT(*) AS total_flights,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM bookings.flights
where status != 'Scheduled'
GROUP BY status;

--Здесь функцию суммирования использовала как оконную, тк без этого вложенное использование агрегатных функций даёт ошибку. Запрос выведет доли всех статусов в общем количестве рейсов. Проценты отменённых и задержанных рейсов получились 2.33% и 0.23% соответственно. Отменённые рейсы такой запрос выводит корректно, но с задержанными картина посложнее: поскольку в базе отражается статус рейса в момент резервного копирования, рейсы со статусом Arrived тоже могли быть задержаны, но в процент не посчитались. Разберёмся с задержанными по-другому.
--Будем считать, что если запланированное и фактическое время вылета отличаются более, чем на 30 минут, рейс считается задержанным. В таком случае будем писать новый статуc Delayed, иначе On Time

with date_diff as (select flight_id, extract(epoch from (actual_departure - scheduled_departure))/60*1.00 as delay_minutes
from bookings.flights f 
where actual_departure is not null), 
new as (select *, 
case 
	when delay_minutes >= 30 then 'Delayed'
	else 'On Time'
end as new_status
from date_diff)
select f.flight_id, coalesce(n.new_status, f.status) as real_status
from bookings.flights f
left join new n
on f.flight_id = n.flight_id;

--Эта таблица даёт "настоящий" статус рейсов, так что теперь я могу посчитать перцентиль задержанных. Эту таблицу я сохранила в схеме bookings под названием real_time.
--Функция epoch ищет разницу между датами в секундах (я затем перевожу в минуты для удобства), coalesce ставит значение нового статуса, если оно существует (то есть для отправленных и прибывших рейсов) и старый в места, где значения нового статуса пусто.

select real_status, count(*), round(count(*)*100.0/sum(count(*)) over (), 2) as perc
from bookings.real_time rt
where real_status != 'Scheduled'
group by real_status

--Таким образом, процент задержанных рейсов получился 4.74%, что значительно больше, чем мы получали до этого. Здесь же мы можем увидеть долю рейсов, выполняющихся вовремя - она составляет порядка 93%.
--Далее, на этапе визуализации, будет интересно посмотреть на этот показатель для разных дат, аэропортов вылета и прилёта, моделей самолетов. 

--5. Теперь для задержанных рейсов выведем среднее время задержки в минутах по каждому номеру рейса (СТЕ), а затем выведем 10 рейсов с самыми долгими задержками.

with av_del as (select f.flight_id, avg(extract(epoch from (f.actual_departure - f.scheduled_departure))/60*1.00) as avg_delay
from bookings.flights f
join bookings.real_time rt
on f.flight_id = rt.flight_id
where f.actual_departure is not null and rt.real_status = 'Delayed'
group by f.flight_id)
select ad.*, f.flight_no, a.city as departure_city, a2.city as arrival_city, f.scheduled_departure as date
from av_del ad
join bookings.flights f
on ad.flight_id = f.flight_id
join bookings.airports a 
on f.departure_airport = a.airport_code
join bookings.airports a2
on f.arrival_airport = a2.airport_code
order by avg_delay desc 
limit 10

--Также посмотрим топ 5 аэропортов вылета с самыми долгими задержками. В этих аэропортах, возможно, следует наладить логистику и работу для ускорения процессов.
select a.city as departure_city, avg(extract(epoch from (f.actual_departure - f.scheduled_departure))/60*1.00) as avg_delay
from bookings.flights f
join bookings.real_time rt
on f.flight_id = rt.flight_id
join bookings.airports a 
on f.departure_airport = a.airport_code
where f.actual_departure is not null and rt.real_status = 'Delayed'
group by departure_city
order by avg_delay desc
limit 5

--Получили результат Салехард, Липецк, Воронеж, Урай, Стрежевой. Можно будет выяснить причину задержек у них и затем постараться минимизировать.
--Подобным образом найдём топ 5 напралений (пар аэропортов вылет-прилёт) с наибольшей задержкой. В этом случае будем считать её как разницу между запланированным и настоящим временем прилёта, а не вылета.

select a.city as departure_city, aa.city as arrival_city, avg(extract(epoch from (f.actual_arrival - f.scheduled_arrival))/60*1.00) as avg_delay
from bookings.flights f
join bookings.real_time rt
on f.flight_id = rt.flight_id
join bookings.airports a 
on f.departure_airport = a.airport_code
join bookings.airports aa 
on f.arrival_airport = aa.airport_code
where f.actual_departure is not null and rt.real_status = 'Delayed'
group by departure_city, arrival_city
order by avg_delay desc
limit 5

--Видно, что направления Сургут-Екатеринбург, Салехард-Новосибирск, Екатеринбург-Москва, Советский-Уфа, Мирный-Новосибирск имеют самые долгие задержки и требуют улучшения в этой области.

--6. Наконец, посмотрю связь доли задержанных рейсов с временем суток. Его мы будем считать по времени запланированного отправления, поделим сутки на интервалы по 3 часа и посмотрим процент задержанных рейсов для этих интервалов.
with h_time as (select flight_id, 
case 
	when extract (hour from scheduled_departure) between 0 and 3 then '0-3'
	when extract (hour from scheduled_departure) <= 6 then '3-6'
	when extract (hour from scheduled_departure) <= 9 then '6-9'
	when extract (hour from scheduled_departure) <= 12 then '9-12'
	when extract (hour from scheduled_departure) <= 15 then '12-15'
	when extract (hour from scheduled_departure) <= 18 then '15-18'
	when extract (hour from scheduled_departure) <= 21 then '18-21'
	when extract (hour from scheduled_departure) <= 24 then '21-00'
end hours
from bookings.flights f)
select ht.hours, real_status, round(count(*)*100.00/sum(count(*)) over(partition by ht.hours), 2) as perc
from bookings.real_time rt
join h_time ht
on rt.flight_id = ht.flight_id 
where real_status != 'Scheduled'
group by hours, real_status
order by hours

--Видим, что самый большой процент задержанных рейсов (5.59%) наблюдается в промежуток времени с 18 до 21 часа. По-видимому, это самое загруженное время и нужно принимать все меры, чтобы облегчить и ускорить работу сотрудников аэропорта в этот период. 


--Отдельным запросом создам таблицу delayed в базе данных, где укажу время задержки для каждого рейса из задержанных. Она нужна мне для отчёта в Power BI.
select f.flight_no, avg(extract(epoch from (f.actual_departure - f.scheduled_departure))/60*1.00)::numeric(10,2) as avg_delay
from bookings.flights f
join bookings.real_time rt
on f.flight_id = rt.flight_id
where f.actual_departure is not null and rt.real_status = 'Delayed'
group by f.flight_no
--И ещё одну таблицу для дашборда

with bookedseats as (select bp.flight_id, count(bp.seat_no) as booked_seats
from bookings.boarding_passes bp
group by bp.flight_id),
totalseats as (select f.flight_id, count(s.seat_no) as total_seats
from bookings.flights f
join bookings.seats s 
on f.aircraft_code = s.aircraft_code
group by f.flight_id
),
f_id_load as (select f.flight_id, f.status, f.flight_no, f.scheduled_departure, bs.booked_seats,
    ts.total_seats, (bs.booked_seats * 1.0 / ts.total_seats)::numeric(10, 2) as load
from bookings.flights f
join bookedseats bs 
on f.flight_id = bs.flight_id
join totalseats ts 
on f.flight_id = ts.flight_id
where bs.booked_seats != 0 and f.status in ('Departed', 'Arrived'))
select f.flight_no, concat_ws('-', max(f.departure_airport), max(f.arrival_airport)) as route, sum(tf.amount)::numeric(20,2) as rev, round(avg(load),2)::numeric(10,2) as av_load
from bookings.flights f 
join f_id_load fil
on f.flight_id = fil.flight_id
join bookings.ticket_flights tf 
on f.flight_id = tf.flight_id 
group by f.flight_no
order by rev desc

/* Благодарю за рассмотрение моего тестового задания и надеюсь на скорую встречу с Вашей компанией! */

