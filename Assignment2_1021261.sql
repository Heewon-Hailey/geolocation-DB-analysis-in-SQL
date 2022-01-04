SELECT u.name, COUNT(l.id) AS 'Recorded Times'
FROM User u
LEFT JOIN Location l
ON u.id = l.user
GROUP BY u.id;


SELECT COUNT(*) AS 'The Number of Cities in VIC'
FROM City c1
WHERE (c1.state = 
               (SELECT c2.state FROM City c2
  	WHERE cityName = 'Melbourne'))
AND NOT (c1.cityName = 'Melbourne');


SELECT u.name
FROM User u
INNER JOIN Gym g 
INNER JOIN Location l 
ON u.gym = g.id
AND u.id = l.user
WHERE g.name = 'Academia' 
AND l.latitude >= 
	(SELECT g.latitude 
	FROM Gym g
    	WHERE g.name = 'Brunswick');


SELECT COUNT(*) AS 'Registered user in VIC'
FROM User u
INNER JOIN Gym g
INNER JOIN City c
ON u.gym = g.id
AND g.city = c.id
WHERE c.state = 'Vic';


SELECT DISTINCT FORMAT((
	(SELECT COUNT(*)
	FROM User u1 
	WHERE u1.gym IS NULL)/
	(SELECT COUNT(*) 
    	FROM User u2)*100),2) AS 'Percentage %'
FROM User;	


SELECT TIMEDIFF(MAX(whenRecorded),MIN(whenRecorded)) AS 'Time elapsed (hh:mm:ss)'
FROM Location l
INNER JOIN User u
ON l.user = u.id
WHERE u.id = 4;	


SELECT FORMAT(AVG(cnt1),2) AS 'AVG location recorded by unregisted users',
	   FORMAT(AVG(cnt2),2) AS 'AVG location recorded by registed users'
FROM (SELECT COUNT(l.id) AS cnt1
	FROM Location l
  	RIGHT JOIN User u
    	ON u.id = l.user
    	WHERE u.gym IS NULL
    	GROUP BY l.user) table1,
            (SELECT COUNT(l2.id) AS cnt2
	FROM Location l2
RIGHT JOIN User u2
ON u2.id = l2.user
WHERE u2.gym IS NOT NULL
GROUP BY l2.user) table2;

SELECT u.name AS 'Name within 100m of the Doug McDonell building'
FROM Location l
INNER JOIN User u
ON u.id = l.user
WHERE	100*SQRT(
	POW(l.longitude-(144.9630),2)+
        	POW(l.latitude-(-37.799),2)) <= 0.1
GROUP BY u.id;        


SELECT FORMAT((100*SQRT
(POW(t1.latitude-t2.latitude,2)+
(POW((t1.longitude)-(t2.longitude),2)))),2) 
		AS 'Distance between the northen-most and southern-most location (Alice), km'
FROM 
(SELECT latitude, longitude 
	FROM Location 
	WHERE latitude = (SELECT MAX(l.latitude) 
			FROM Location l
			WHERE l.user = (SELECT u.id 
					FROM User u 
					WHERE u.name = 'Alice')
			ORDER BY l.id)
LIMIT 1) t1,
	(SELECT latitude, longitude 
	FROM Location
	WHERE latitude = (SELECT MIN(l2.latitude) 
			FROM Location l2
			WHERE l2.user = (SELECT u2.id 
					FROM User u2 
					WHERE u2.name = 'Alice')
			ORDER BY l2.id) 
                LIMIT 1) t2;

SELECT FORMAT(SUM(100*SQRT
(POW((t1.latitude -t2.latitude),2) +
		(POW((t1.longitude - t2.longitude),2)))),2) 
AS 'The total distance (Alice), km'

FROM (SELECT * 
FROM Location l 
	WHERE l.user = 
		(SELECT u.id 
       		 FROM User u 
        		WHERE u.name = 'Alice')) t1

INNER JOIN (SELECT * 
	FROM Location l2 
	WHERE l2.user = 
		(SELECT u2.id 
     		 FROM User u2 
        		WHERE u2.name = 'Alice')) t2

ON TIMESTAMPDIFF(MINUTE, t1.whenRecorded, t2.whenRecorded) = 1;


