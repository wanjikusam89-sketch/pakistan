create table food_price like pakistan_food_prices_2025;
insert food_price
select * from pakistan_food_prices_2025;
-- null values
select * from food_price where Item is null or Item = null or Item = ''; 
select * from food_price where Category is null or Category = null or Category = '';
select * from food_price where City is null or City  = null or City = '';
select * from food_price where Price_per_Kg is null or Price_per_Kg = null or Price_per_Kg = ''; 
select * from food_price where Month is null or Month = null or Month = '';
select * from food_price where Source is null or Source = null or Source = '';
-- standardization
select distinct Item, (trim(trailing '.' from Item)) from food_price;
select distinct Category, (trim(trailing '.' from Category)) from food_price;
select distinct City, (trim(trailing '.' from City)) from food_price;
select Price_per_Kg, (trim(trailing '.' from Price_per_Kg)) from food_price;
select distinct Month, (trim(trailing '.' from Month)) from food_price;
select Source, (trim(trailing '.' from Source)) from food_price;
-- duplicates
select *, row_number() over(partition by Item, Category, City, Price_per_Kg, Month, Source) as row_num from food_price;
with duplicates as(select *, row_number() over(partition by Item, Category, City, Price_per_Kg, Month, Source) as row_num from food_price)
select * from duplicates where row_num > 1;

select * from food_price where City like 'Faisalabad%' and Price_per_Kg like '217.66%';
-- removing duplicates
CREATE TABLE `food_price_2` (
  `Item` text,
  `Category` text,
  `City` text,
  `Price_per_Kg` double DEFAULT NULL,
  `Month` text,
  `Source` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into food_price_2
select *, row_number() over(partition by Item, Category, City, Price_per_Kg, Month, Source) as row_num from food_price;
delete from food_price_2 where row_num > 1;
-- removing column
alter table food_price_2
drop column row_num;
-- Exploratory Data Analysis.
-- How many unique food items are in the dataset?
select distinct Item, count(Item) as cnt from food_price_2 group by 1 order by count(Item) desc;
-- How many unique categories (grains, fruits, vegetables, dairy, meat, pulses, oils)?
select distinct Category, count(Category) from food_price_2 group by Category order by count(Category) desc;
-- How many unique cities/markets?
select distinct City, count(City) from food_price_2 group by City order by count(City) desc;
-- What is the average price across all items?
select distinct Item, avg(Price_per_Kg) from food_price_2 group by Item order by avg(Price_per_Kg) desc;
-- What are the min, median, max prices in the dataset?
select distinct Item, min(Price_per_Kg), max(Price_per_Kg) from food_price_2 group by Item;

select Price_per_Kg,
row_number() over(order by Price_per_Kg) as r, count(Price_per_Kg) over() as c from food_price_2;

with ranked as (select Price_per_Kg,
row_number() over(order by Price_per_Kg) as r, count(Price_per_Kg) over() as c from food_price_2),
median as (select Price_per_Kg from ranked where r in (floor((c+1)/2), ceiling((c+1)/2)))
select avg(Price_per_Kg) as median from median;
-- Which food item appears most frequently in the dataset?
select Item, count(*) from food_price_2 group by Item order by count(*) desc; -- limit 1;
-- Which city has the highest price variation (standard deviation)?
select *, stddev(Price_per_Kg) over(partition by City order by Price_per_Kg ) as standard_deviation from food_price_2;
-- What are the top 10 cheapest cities (average price)?
select City , avg(Price_per_Kg) from food_price_2 group by City order by avg(Price_per_Kg) asc limit 10;
-- What are the top 10 most expensive cities (average price)?
select City , avg(Price_per_Kg) from food_price_2 group by City order by avg(Price_per_Kg) desc limit 10;
-- How many unique categories are represented?
select distinct Category from food_price_2;
-- Which category has the highest average price?
select Category, avg(Price_per_Kg) from food_price_2 group by Category order by avg(Price_per_Kg) desc limit 1; 
-- Which category has the highest price variability?
select *, stddev(Price_per_Kg) over(partition by Category order by Price_per_Kg ) as standard_deviation  from food_price_2;
-- Which category includes the most expensive items?
select Category, Price_per_Kg from food_price_2 order by Price_per_Kg desc;
-- Which category includes the cheapest items?
select Category, Price_per_Kg from food_price_2 order by Price_per_Kg asc;
-- What is the average price per category?
select Category, avg(Price_per_Kg) from food_price_2 group by Category order by avg(Price_per_Kg);
-- Which category has the most entries (most surveyed)?
select Category, count(*) from food_price_2 group by Category order by count(*) desc limit 1;
-- Which food item is most expensive on average?
select Item, avg(Price_per_Kg) from food_price_2 group by Item order by avg(Price_per_Kg) desc limit 1; 
-- Which food item is cheapest on average?
select Item, avg(Price_per_Kg) from food_price_2 group by Item order by avg(Price_per_Kg) asc limit 1;
-- What month had the highest food prices overall?
select Month, Price_per_Kg from food_price_2 order by Price_per_Kg desc limit 1; 
-- What month had the lowest overall prices?
select Month, Price_per_Kg from food_price_2 order by Price_per_Kg asc limit 1; 















    
