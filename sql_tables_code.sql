-- 1. СТВОРЕННЯ ТАБЛИЦЬ
DROP database if exists assignm2;
CREATE database assignm2;
USE assignm2;
DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    team VARCHAR(50),
    hire_date DATE
);

CREATE TABLE IF NOT EXISTS calls (
    call_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    call_time DATETIME NOT NULL,
    phone VARCHAR(20),
    direction VARCHAR(10),
    status VARCHAR(20),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 2. ДОДАВАННЯ 50 ПРАЦІВНИКІВ
INSERT INTO employees (full_name, team, hire_date) VALUES 
('Олександр Мельник', 'Technical Support', '2021-05-12'), ('Марія Шевченко', 'Billing', '2022-11-23'),
('Іван Бойко', 'Customer Success', '2020-03-15'), ('Олена Коваленко', 'Sales', '2023-01-10'),
('Дмитро Бондаренко', 'Technical Support', '2019-08-30'), ('Наталія Ткаченко', 'Billing', '2021-07-19'),
('Сергій Кравченко', 'Technical Support', '2022-02-28'), ('Анна Ковальчук', 'Customer Success', '2020-10-05'),
('Віктор Олійник', 'Sales', '2023-04-14'), ('Юлія Поліщук', 'Technical Support', '2018-12-01'),
('Андрій Ткач', 'Billing', '2022-09-09'), ('Тетяна Лисенко', 'Customer Success', '2021-06-22'),
('Максим Марченко', 'Technical Support', '2020-01-17'), ('Катерина Руденко', 'Sales', '2023-08-03'),
('Володимир Савченко', 'Billing', '2019-11-11'), ('Ірина Мороз', 'Technical Support', '2022-03-08'),
('Олег Петренко', 'Customer Success', '2020-05-25'), ('Світлана Левченко', 'Sales', '2021-09-14'),
('Микола Романенко', 'Technical Support', '2018-07-07'), ('Галина Панченко', 'Billing', '2023-02-18'),
('Василь Макаренко', 'Customer Success', '2020-12-30'), ('Вікторія Харченко', 'Technical Support', '2021-04-04'),
('Роман Тарасенко', 'Sales', '2022-10-21'), ('Дарія Павленко', 'Billing', '2019-06-16'),
('Євген Кузьменко', 'Technical Support', '2023-05-05'), ('Аліна Пономаренко', 'Customer Success', '2020-08-12'),
('Богдан Іващенко', 'Technical Support', '2021-12-20'), ('Оксана Гриценко', 'Sales', '2018-09-29'),
('Тарас Сидоренко', 'Billing', '2022-07-15'), ('Людмила Карпенко', 'Technical Support', '2019-04-24'),
('Ігор Федоренко', 'Customer Success', '2023-11-08'), ('Яна Гавриленко', 'Sales', '2020-02-02'),
('Віталій Мартинюк', 'Technical Support', '2021-01-19'), ('Марина Мельничук', 'Billing', '2022-06-06'),
('Олексій Степаненко', 'Customer Success', '2019-10-10'), ('Анастасія Демченко', 'Technical Support', '2023-03-27'),
('Михайло Козаченко', 'Sales', '2018-05-08'), ('Надія Даниленко', 'Billing', '2021-08-26'),
('Юрій Василенко', 'Technical Support', '2020-11-13'), ('Валентина Ісаєнко', 'Customer Success', '2022-04-11'),
('Артем Клименко', 'Technical Support', '2019-02-21'), ('Софія Матвієнко', 'Sales', '2023-09-30'),
('Руслан Захаренко', 'Billing', '2020-07-03'), ('Христина Прокопенко', 'Technical Support', '2021-10-16'),
('Денис Тимошенко', 'Customer Success', '2018-11-28'), ('Ольга Антоненко', 'Sales', '2022-01-05'),
('Павло Кириленко', 'Technical Support', '2023-07-07'), ('Єлизавета Литвиненко', 'Billing', '2019-03-12'),
('Степан Власенко', 'Customer Success', '2020-09-24'), ('Любов Захарченко', 'Technical Support', '2021-05-18');

-- 3. ДОДАВАННЯ ТЕСТОВИХ ДЗВІНКІВ
-- Дати виставлені так, щоб можна було тестувати логіку "нових" дзвінків
INSERT INTO calls (employee_id, call_time, phone, direction, status) VALUES 
(5, '2026-03-14 08:15:00', '+380501112233', 'inbound', 'resolved'),
(12, '2026-03-14 09:30:00', '+380671112233', 'outbound', 'escalated'),
(42, '2026-03-14 10:45:00', '+380931112233', 'inbound', 'dropped'),
(3, '2026-03-15 11:20:00', '+380661112233', 'inbound', 'resolved'),
(18, '2026-03-15 14:10:00', '+380991112233', 'outbound', 'resolved');