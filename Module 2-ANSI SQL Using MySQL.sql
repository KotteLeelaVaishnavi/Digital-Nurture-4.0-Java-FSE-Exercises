-- Create the database and switch to it

DROP DATABASE IF EXISTS cognizant;
CREATE DATABASE cognizant;
USE cognizant;

-- Create Users table


CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL
);

-- Create Events table


CREATE TABLE Events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    city VARCHAR(100) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status ENUM('upcoming', 'completed', 'cancelled') NOT NULL,
    organizer_id INT,
    FOREIGN KEY (organizer_id) REFERENCES Users(user_id)
);

-- Create Sessions table


CREATE TABLE Sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    speaker_name VARCHAR(100) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- Create Registrations table


CREATE TABLE Registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- Create Feedback table


CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    feedback_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- Create Resources table


CREATE TABLE Resources (
    resource_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    resource_type ENUM('pdf', 'image', 'link') NOT NULL,
    resource_url VARCHAR(255) NOT NULL,
    uploaded_at DATETIME NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- Insert sample data into Users

INSERT INTO Users (user_id, full_name, email, city, registration_date) VALUES
(1, 'Aarav Mehta', 'aarav.mehta@desimail.com', 'Mumbai', '2024-12-01'),
(2, 'Diya Sharma', 'diya.sharma@desimail.com', 'Bangalore', '2024-12-05'),
(3, 'Kabir Singh', 'kabir.singh@desimail.com', 'Delhi', '2024-12-10'),
(4, 'Meera Nair', 'meera.nair@desimail.com', 'Mumbai', '2025-01-15'),
(5, 'Rohan Verma', 'rohan.verma@desimail.com', 'Bangalore', '2025-02-01');

-- Insert sample data into Events

INSERT INTO Events (event_id, title, description, city, start_date, end_date, status, organizer_id) VALUES
(1, 'CodeYatra Meetup', 'A journey for devs across India.', 'Mumbai', '2025-06-10 10:00:00', '2025-06-10 16:00:00', 'upcoming', 1),
(2, 'AI Mahotsav', 'India's AI and ML tech carnival.', 'Delhi', '2025-05-15 09:00:00', '2025-05-15 17:00:00', 'completed', 3),
(3, 'Frontend Fusion Bootcamp', 'Hands-on with frontend stack.', 'Bangalore', '2025-07-01 10:00:00', '2025-07-03 16:00:00', 'upcoming', 2);

-- Insert sample data into Sessions

INSERT INTO Sessions (session_id, event_id, title, speaker_name, start_time, end_time) VALUES
(1, 1, 'Opening Notes', 'Dr. Techno Bhatt', '2025-06-10 10:00:00', '2025-06-10 11:00:00'),
(2, 1, 'Future of Bharat Web', 'Aarav Mehta', '2025-06-10 11:15:00', '2025-06-10 12:30:00'),
(3, 2, 'AI for Health Bharat', 'Kabir Singh', '2025-05-15 09:30:00', '2025-05-15 11:00:00'),
(4, 3, 'HTML5 Masala Intro', 'Diya Sharma', '2025-07-01 10:00:00', '2025-07-01 12:00:00');

-- Insert sample data into Registrations

INSERT INTO Registrations (registration_id, user_id, event_id, registration_date) VALUES
(1, 1, 1, '2025-05-01'),
(2, 2, 1, '2025-05-02'),
(3, 3, 2, '2025-04-30'),
(4, 4, 2, '2025-04-28'),
(5, 5, 3, '2025-06-15');

-- Insert sample data into Feedback

INSERT INTO Feedback (feedback_id, user_id, event_id, rating, comments, feedback_date) VALUES
(1, 3, 2, 4, 'Loved the vibe!', '2025-05-16'),
(2, 4, 2, 5, 'Super insightful!', '2025-05-16'),
(3, 2, 1, 3, 'Could be more desi-focused.', '2025-06-11');

-- Insert sample data into Resources

INSERT INTO Resources (resource_id, event_id, resource_type, resource_url, uploaded_at) VALUES
(1, 1, 'pdf', https://bharatportal.in/resources/codeyatra_agenda.pdf, '2025-05-01 10:00:00'),
(2, 2, 'image', https://bharatportal.in/resources/ai_mahotsav_poster.jpg, '2025-04-20 09:00:00'),
(3, 3, 'link', https://bharatportal.in/resources/frontend_docs, '2025-06-25 15:00:00');


-- 1. User Upcoming Events
SELECT 
    u.user_id, u.full_name, e.event_id, e.title AS event_title, e.city, e.start_date, e.end_date
FROM Users u
JOIN Registrations r ON u.user_id = r.user_id
JOIN Events e ON r.event_id = e.event_id
WHERE e.status = 'upcoming' AND u.city = e.city
ORDER BY u.user_id, e.start_date;


-- 2. Top Rated Events (only if feedbacks >= 10)
SELECT 
    e.event_id, e.title, COUNT(f.feedback_id) AS total_feedbacks, AVG(f.rating) AS average_rating
FROM Events e
JOIN Feedback f ON e.event_id = f.event_id
GROUP BY e.event_id, e.title
HAVING COUNT(f.feedback_id) >= 10
ORDER BY average_rating DESC;


-- 3. Inactive Users
SELECT u.user_id, u.full_name, u.email, u.city
FROM Users u
WHERE u.user_id NOT IN (
    SELECT r.user_id FROM Registrations r
    WHERE r.registration_date >= CURDATE() - INTERVAL 90 DAY
);


-- 4. Peak Session Hours
SELECT e.event_id, e.title AS event_title, COUNT(s.session_id) AS session_count
FROM Events e
JOIN Sessions s ON e.event_id = s.event_id
WHERE TIME(s.start_time) >= '10:00:00' AND TIME(s.end_time) <= '12:00:00'
GROUP BY e.event_id, e.title;


-- 5. Most Active Cities
SELECT u.city, COUNT(DISTINCT r.user_id) AS total_users
FROM Users u
JOIN Registrations r ON u.user_id = r.user_id
GROUP BY u.city
ORDER BY total_users DESC
LIMIT 5;


-- 6. Event Resource Summary
SELECT 
    e.event_id, e.title AS event_title,
    SUM(CASE WHEN r.resource_type = 'pdf' THEN 1 ELSE 0 END) AS pdf_count,
    SUM(CASE WHEN r.resource_type = 'image' THEN 1 ELSE 0 END) AS image_count,
    SUM(CASE WHEN r.resource_type = 'link' THEN 1 ELSE 0 END) AS link_count,
    COUNT(r.resource_id) AS total_resources
FROM Events e
LEFT JOIN Resources r ON e.event_id = r.event_id
GROUP BY e.event_id, e.title;


-- 7. Low Feedback Alerts
SELECT u.full_name, f.rating, f.comments, e.title AS event_title
FROM Feedback f
JOIN Users u ON f.user_id = u.user_id
JOIN Events e ON f.event_id = e.event_id
WHERE f.rating < 3;


-- 8. Sessions per Upcoming Event
SELECT e.event_id, e.title AS event_title, COUNT(s.session_id) AS session_count
FROM Events e
LEFT JOIN Sessions s ON e.event_id = s.event_id
WHERE e.status = 'upcoming'
GROUP BY e.event_id, e.title;


-- 9. Organizer Event Summary
SELECT u.user_id, u.full_name, e.status, COUNT(e.event_id) AS event_count
FROM Users u
LEFT JOIN Events e ON u.user_id = e.organizer_id
GROUP BY u.user_id, u.full_name, e.status;


-- 10. Feedback Gap
SELECT e.event_id, e.title AS event_title
FROM Events e
JOIN Registrations r ON e.event_id = r.event_id
LEFT JOIN Feedback f ON e.event_id = f.event_id
GROUP BY e.event_id, e.title
HAVING COUNT(f.feedback_id) = 0;


-- 11. Daily New User Count 
SELECT registration_date, COUNT(user_id) AS users_registered
FROM Users
WHERE registration_date >= CURDATE() - INTERVAL 6 DAY
GROUP BY registration_date
ORDER BY registration_date;


-- 12. Event with Maximum Sessions
SELECT e.event_id, e.title AS event_title, COUNT(s.session_id) AS session_count
FROM Events e
JOIN Sessions s ON e.event_id = s.event_id
GROUP BY e.event_id, e.title
HAVING session_count = (
    SELECT MAX(session_counts) FROM (
        SELECT COUNT(session_id) AS session_counts FROM Sessions GROUP BY event_id
    ) AS counts_subquery
);


-- 13. Average Rating per City 
SELECT e.city, AVG(f.rating) AS average_rating
FROM Events e
JOIN Feedback f ON e.event_id = f.event_id
GROUP BY e.city;


-- 14. Most Registered Events 
SELECT e.event_id, e.title AS event_title, COUNT(r.registration_id) AS total_registrations
FROM Events e
LEFT JOIN Registrations r ON e.event_id = r.event_id
GROUP BY e.event_id, e.title
ORDER BY total_registrations DESC
LIMIT 3;


-- 15. Event Session Time Conflict
SELECT s1.event_id, e.title AS event_title, 
       s1.session_id AS session1_id, s1.title AS session1_title, s1.start_time, s1.end_time,
       s2.session_id AS session2_id, s2.title AS session2_title, s2.start_time, s2.end_time
FROM Sessions s1
JOIN Sessions s2 
  ON s1.event_id = s2.event_id AND s1.session_id < s2.session_id
  AND s1.start_time < s2.end_time AND s2.start_time < s1.end_time
JOIN Events e ON s1.event_id = e.event_id;


-- 16. Unregistered Active Users
SELECT u.user_id, u.full_name, u.email, u.registration_date
FROM Users u
LEFT JOIN Registrations r ON u.user_id = r.user_id
WHERE u.registration_date >= CURDATE() - INTERVAL 30 DAY AND r.registration_id IS NULL;


-- 17. Multi-Session Speakers 
SELECT speaker_name, COUNT(session_id) AS session_count
FROM Sessions
GROUP BY speaker_name
HAVING session_count > 1;


-- 18. Resource Availability Check
SELECT e.event_id, e.title AS event_title
FROM Events e
LEFT JOIN Resources r ON e.event_id = r.event_id
WHERE r.resource_id IS NULL;


-- 19. Completed Events with Feedback Summary 
SELECT e.event_id, e.title AS event_title,
       COUNT(DISTINCT r.registration_id) AS total_registrations,
       AVG(f.rating) AS average_feedback_rating
FROM Events e
LEFT JOIN Registrations r ON e.event_id = r.event_id
LEFT JOIN Feedback f ON e.event_id = f.event_id
WHERE e.status = 'completed'
GROUP BY e.event_id, e.title;


-- 20. User Engagement Index
SELECT u.user_id, u.full_name,
       COUNT(DISTINCT r.event_id) AS events_attended,
       COUNT(DISTINCT f.feedback_id) AS feedbacks_submitted
FROM Users u
LEFT JOIN Registrations r ON u.user_id = r.user_id
LEFT JOIN Feedback f ON u.user_id = f.user_id
GROUP BY u.user_id, u.full_name;


-- 21. Top Feedback Providers
SELECT u.user_id, u.full_name, COUNT(f.feedback_id) AS feedback_count
FROM Users u
JOIN Feedback f ON u.user_id = f.user_id
GROUP BY u.user_id, u.full_name
ORDER BY feedback_count DESC
LIMIT 5;


-- 22.  Duplicate Registrations Check
SELECT user_id, event_id, COUNT(*) AS registration_count
FROM Registrations
GROUP BY user_id, event_id
HAVING registration_count > 1;


-- 23. Registration Trends
SELECT DATE_FORMAT(registration_date, '%Y-%m') AS month, COUNT(registration_id) AS registrations_count
FROM Registrations
WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY month
ORDER BY month;


-- 24. Average Session Duration per Event 
SELECT e.event_id, e.title AS event_title,
       AVG(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time)) AS avg_session_duration_minutes
FROM Events e
JOIN Sessions s ON e.event_id = s.event_id
GROUP BY e.event_id, e.title;


-- 25. Events Without Sessions 
SELECT e.event_id, e.title AS event_title
FROM Events e
LEFT JOIN Sessions s ON e.event_id = s.event_id
WHERE s.session_id IS NULL;
