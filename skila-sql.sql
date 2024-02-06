USE sakila;

/* 데이터 조회 및 필터링 */

-- 1. 특정 배우가 출연한 영화 목록
SELECT f.title FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
WHERE a.first_name = 'PENELOPE' AND a.last_name = 'GUINESS';

-- 2. 모든 카테고리와 해당 카테고리의 영화 수 조회
-- SELECT c.category_id, c.name, COUNT(*) AS film_count FROM category c
-- JOIN film_category fc ON c.category_id = fc.category_id
-- GROUP BY c.category_id
-- ORDER BY film_count DESC;

SELECT c.name, COUNT(fc.film_id) AS film_count FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY film_count DESC;

-- 3. 특정 고객의 대여 기록 조회
-- SELECT * FROM rental r
-- JOIN customer c ON c.customer_id = r.customer_id
-- WHERE c.customer_id = 5
-- ORDER BY r.rental_date ASC;

SELECT r.rental_date, f.title
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = 5;

-- 4. 가장 최근에 추가된 10개의 영화 조회
SELECT release_year, title
FROM film
ORDER BY release_year DESC
LIMIT 10;

/* 조인 및 쿼리 */

-- 1. 특정 영화에 출연한 배우 목록 조회
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f ON f.film_id = fa.film_id
WHERE f.title = 'ACADEMY DINOSAUR';

-- 2. 특정 영화를 대여한 고객 목록 조회
SELECT c.first_name, c.last_name 
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'ACADEMY DINOSAUR';

-- 3. 모든 고객과 그들이 가장 최근에 대여한 영화 조회
SELECT c.customer_id, c.first_name, c.last_name, MAX(r.rental_date) AS last_rental_date, f.title
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY c.customer_id, c.first_name, c.last_name, f.title;

-- 4. 각 영화별 평균 대여 기간 조회
SELECT f.title, AVG(DATEDIFF(r.return_date, r.rental_date)) as avg_rental_period
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY avg_rental_period DESC;

/* 집계 및 그룹화 */

-- 1. 가장 많이 대여된 영화 조회
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 1;

-- 2. 각 카테고리별 평균 대여 요금 계산
SELECT c.name, AVG(f.rental_rate) AS avg_rental_rate
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON f.film_id = fc.film_id
GROUP BY c.name
ORDER BY avg_rental_rate DESC;

-- 3. 월별 총 매출 조회
SELECT YEAR(payment_date) AS year, MONTH(payment_date) AS month, SUM(amount) AS total_sales
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date);

-- 4. 각 배우별 출현한 영화 수 조회
SELECT a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY film_count DESC;

/* 서브쿼리 및 고급 기능 */

-- 1. 가장 수익이 많은 영화 조회
SELECT f.title, SUM(p.amount) AS total_revenue
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.title
ORDER BY total_revenue DESC
LIMIT 1;

-- 2. 평균 대여 요금보다 높은 요금의 영화 조회
SELECT title, rental_rate
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY rental_rate DESC; 

-- 3. 가장 활동적인 고객 조회
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY rental_count DESC
LIMIT 1;

-- 4. 특정 배우가 출현한 영화 중 가장 인기 있는 영화 조회
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE a.first_name = 'PENELOPE' AND a.last_name = 'GUINESS'
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 1;

/* 데이터 수정 및 관리 */

-- 1. 새로운 영화 추가
INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features)
VALUES ('New Adventure Movie', 'A thrilling adventure of the unknown', 2023, 1, 3, 4.99, 120, 19.99, 'PG', 'Trailers,Commentaries');
-- SELECT * FROM film WHERE title = 'New Adventure Movie';

-- 2. 고객 정보 업데이트
UPDATE customer c
JOIN address a ON c.address_id = a.address_id
SET address = '123 New Address, New City'
WHERE customer_id = 5;
-- SELECT c.customer_id, a.address FROM customer c
-- JOIN address a ON a.address_id = c.address_id 
-- WHERE c.customer_id = 5;

-- 3. 영화 대여 상태 변경
UPDATE rental 
SET rental_date = NOW()  -- NOW() : 서버시간 기준
WHERE rental_id = 200;
-- SELECT * FROM rental WHERE rental_id = 200;

-- 4. 배우 정보 삭제
-- DELETE FROM film_actor WHERE actor_id = 10; -- film_actor에서 actor_id 참조로 먼저 삭제
DELETE FROM actor WHERE actor_id = 10; 
-- SELECT * FROM actor WHERE actor_id = 10;
-- SELECT * FROM film_actor WHERE actor_id = 10;