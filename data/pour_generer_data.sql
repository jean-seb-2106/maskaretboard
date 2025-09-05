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

 
#Génération d'un CSV avec les 10 cours les plus populaires sur un mois donné.   
SELECT
    c.id AS course_id,
    c.fullname AS nom_du_cours,
    cc.name AS categorie_cours,  -- Ajout de la catégorie
    COUNT(*) AS nombre_activites_etudiants,
    COUNT(DISTINCT l.userid) AS nombre_etudiants_actifs,
    (SELECT COUNT(DISTINCT ra.userid)
     FROM mdl_role_assignments ra
     JOIN mdl_context ctx ON ra.contextid = ctx.id AND ctx.contextlevel = 50
     JOIN mdl_role r ON ra.roleid = r.id AND r.shortname = 'student'
     WHERE ctx.instanceid = c.id) AS nombre_inscriptions_etudiants
INTO OUTFILE 'C:/Users/Public/Downloads/cours_populaires.csv'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM
    mdl_course c
JOIN
    mdl_course_categories cc ON c.category = cc.id  -- Jointure pour la catégorie
JOIN
    mdl_logstore_standard_log l ON c.id = l.courseid
JOIN
    mdl_user u ON l.userid = u.id
JOIN
    mdl_role_assignments ra ON u.id = ra.userid
JOIN
    mdl_context ctx ON ra.contextid = ctx.id AND ctx.contextlevel = 50  -- Niveau "cours"
JOIN
    mdl_role r ON ra.roleid = r.id AND r.shortname = 'student'  -- Filtre les étudiants
WHERE
    c.visible = 1  -- Cours visibles uniquement
    AND FROM_UNIXTIME(l.timecreated) BETWEEN
        DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m-01')
        AND LAST_DAY(NOW() - INTERVAL 1 MONTH)  -- Période : mois dernier
GROUP BY
    c.id, c.fullname, cc.name  -- Ajout de cc.name dans le GROUP BY
HAVING
    COUNT(*) > 0  -- Exclut les cours sans activité étudiante
ORDER BY
    nombre_activites_etudiants DESC,  -- Tri par activités étudiants
    nombre_inscriptions_etudiants DESC  -- Puis par inscriptions étudiants
LIMIT 10;