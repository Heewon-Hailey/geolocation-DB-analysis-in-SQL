/* Print each user’s name, along with the number of times they have
recorded a location. */
SELECT u.name, COUNT(l.id) AS 'Recorded Times'
FROM User u
LEFT JOIN Location l
ON u.id = l.user
GROUP BY u.id;


/* How many cities are in the same state as Melbourne?
(Don’t count Melbourne in your answer.) */
SELECT COUNT(*) AS 'The Number of Cities in VIC'
FROM City c1
WHERE (c1.state = 
               (SELECT c2.state FROM City c2
  	WHERE cityName = 'Melbourne'))
AND NOT (c1.cityName = 'Melbourne');


/* List the names of any members of Academia gym who have been
north of Brunswick gym. */
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


/* How many users are registered with gyms in the state of Vic?*/
SELECT COUNT(*) AS 'Registered user in VIC'
FROM User u
INNER JOIN Gym g
INNER JOIN City c
ON u.gym = g.id
AND g.city = c.id
WHERE c.state = 'Vic';


/* What percentage of the total number of users are not affiliated
with gyms?*/
SELECT DISTINCT FORMAT((
	(SELECT COUNT(*)
	FROM User u1 
	WHERE u1.gym IS NULL)/
	(SELECT COUNT(*) 
    	FROM User u2)*100),2) AS 'Percentage %'
FROM User;	


/* How much time elapsed between the first and last recorded locations
of the user with id 4? */
SELECT TIMEDIFF(MAX(whenRecorded),MIN(whenRecorded)) AS 'Time elapsed (hh:mm:ss)'
FROM Location 
WHERE user = 4;	


/* Print as two columns: the average number of locations recorded by
registered users, and the average number of locations recorded by
unregistered users. */
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


/* List the names of users who have run within 100m of the Doug McDonell
building. (DMD is at longitude 144.9630, latitude -37.7990 .) */
SELECT DISTINCT u.name AS 'Name within 100m of the Doug McDonell building'
FROM Location l
INNER JOIN User u
ON u.id = l.user
WHERE	100*SQRT(
	POW(l.longitude-(144.9630),2)+
        	POW(l.latitude-(-37.799),2)) < 0.1
GROUP BY u.id;        


/* What is the distance between the northern-most and southern-most
locations to which Alice has run? */
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


/* Show the total distance that Alice has run. Calculate this by summing
the individual distances between each successive pair of locations.*/
SELECT SUM(100*SQRT(POW((l1.latitude -l2.latitude),2) +
		(POW((l1.longitude - l2.longitude),2)))) 
		AS 'The total distance (Alice), km'
        
FROM Location l1 
	JOIN Location l2 
    ON l2.id = (SELECT MAX(l.id) 
        FROM Location l
        WHERE l.id < l1.id 
		AND l.user = l1.user)

WHERE l1.user = (SELECT u.id 
		FROM User u 
		WHERE u.name = 'Alice');
