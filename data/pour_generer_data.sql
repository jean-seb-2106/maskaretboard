#génération d'un CSV avec le nombre de connexions uniques mensuelles
SELECT
    COUNT(DISTINCT l.userid) AS nombre_connexions_uniques,
    DATE_FORMAT(FROM_UNIXTIME(l.timecreated), '%Y-%m') AS mois
INTO OUTFILE 'C:/Users/Public/Downloads/connexions_uniques.csv'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM
    mdl_logstore_standard_log l
WHERE
    l.eventname LIKE '%user_loggedin%'
    AND FROM_UNIXTIME(l.timecreated) BETWEEN '2025-01-01' AND '2025-12-30 23:59:59'
GROUP BY
    DATE_FORMAT(FROM_UNIXTIME(l.timecreated), '%Y-%m');