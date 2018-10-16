DELETE FROM admin8.Employes WHERE id_employe = 'USER7';
DELETE FROM admin8.Clients WHERE id_client = 'USER10';
DELETE FROM admin8.Commandes WHERE id_commande = 207;
DELETE FROM admin8.Commandes WHERE id_commande = 208;
commit;

SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE like 'ADMIN8%';
