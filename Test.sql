@Logon.sql;
SELECT * FROM admin8.Commandes;
SELECT * FROM admin8.Employes;
SELECT * FROM admin8.Clients;

prompt 'PRESS X TO CONTINUE :';
accept temp default '100';

SELECT * FROM admin8.Commandes_du_jour;
SELECT * FROM admin8.Employes_Comptable;

prompt 'PRESS X TO CONTINUE :';
accept temp default '100';

insert into admin8.Clients VALUES ('USER10', 'Dassin', 'Joe', '2 rue de la paix' );

insert into admin8.Employes VALUES ('USER7', 'Piaf', 'Edith', '3 rue du telephone', '0002454545451851613' );

insert into admin8.Commandes VALUES (207, 'USER10', 'USER7', '25', 'ISI_BURGER_1', '3 rue de la paix', '09-OCT-18');

insert into admin8.Commandes VALUES (208, 'USER10', 'USER4', '25', 'ISI_BURGER_1', '3 rue de la paix', '09-OCT-18');

commit;

prompt 'PRESS X TO CONTINUE :';
accept temp default '100';

UPDATE admin8.Commandes
SET contenu = 'ISI_BURGER_3'
WHERE id_commande = 207;

UPDATE admin8.Commandes
SET contenu = 'ISI_BURGER_3'
WHERE id_commande = 208;

UPDATE admin8.Employes
SET nom = 'Brassens'
WHERE id_employe = 'USER7';

UPDATE admin8.Employes
SET nom = 'Courci'
WHERE id_employe = 'USER4';

UPDATE admin8.Clients
SET nom = 'Ferrat'
WHERE id_client = 'USER10';

UPDATE admin8.Clients
SET prenom = 'Doku'
WHERE id_client = 'USER3';

commit;

prompt 'PRESS X TO CONTINUE :';
accept temp default '100';

DELETE FROM admin8.Commandes WHERE id_commande = 207;

DELETE FROM admin8.Employes WHERE id_employe = 'USER7';

DELETE FROM admin8.Clients WHERE id_client = 'USER10';

commit;
