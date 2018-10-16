@drop;
---------TABLE---------

CREATE TABLE Clients
	(
		id_client VARCHAR(20),
		nom VARCHAR(20),
        prenom VARCHAR(20),
		adresse VARCHAR(400),
		CONSTRAINT client_pk PRIMARY KEY (id_client)
	);

CREATE TABLE Employes
	(
		id_employe VARCHAR(20),
		nom VARCHAR(20),
        prenom VARCHAR(20),
		adresse VARCHAR(400),
        RIB VARCHAR(40),
		CONSTRAINT employe_pk PRIMARY KEY (id_employe)
	);

CREATE TABLE Commandes
	(
		id_commande VARCHAR(20),
		id_client VARCHAR(20),
        id_employe VARCHAR(20),
		prix NUMBER,
		contenu VARCHAR(400),
		adresse_facture VARCHAR(100),
        date_commande DATE,
		CONSTRAINT commande_pk PRIMARY KEY (id_commande)
	);

---------VIEW---------

CREATE VIEW Employes_Comptable AS 
    SELECT id_employe, adresse, RIB 
    FROM Employes;

CREATE VIEW Commandes_du_jour AS
    SELECT *
    FROM Commandes
    WHERE date_commande = '09-OCT-18'; 

---------ROLE---------

CREATE ROLE admin8_Role_comptable;
CREATE ROLE admin8_Role_client;
CREATE ROLE admin8_Role_employe;
CREATE ROLE admin8_Role_gerant;

CREATE ROLE admin8_RoleAbs_SelectCommande;

---------ROLE VIEW---------

GRANT SELECT ON Commandes_du_jour TO admin8_Role_employe;
GRANT SELECT ON Employes_Comptable TO admin8_Role_comptable;

---------ROLE Commandes---------
GRANT SELECT ON Commandes TO admin8_RoleAbs_SelectCommande;

GRANT admin8_RoleAbs_SelectCommande TO admin8_Role_comptable;
GRANT admin8_RoleAbs_SelectCommande TO admin8_Role_client;

GRANT INSERT, UPDATE ON Commandes TO admin8_Role_employe;

GRANT admin8_Role_employe TO admin8_Role_gerant;

---------ROLE Clients---------

GRANT SELECT, UPDATE ON Clients TO admin8_Role_client;
GRANT admin8_Role_client TO admin8_Role_employe;
GRANT INSERT ON Clients TO admin8_Role_employe;

GRANT DELETE ON Clients TO admin8_Role_gerant;

---------ROLE Employes---------

GRANT SELECT, UPDATE ON Employes TO admin8_Role_employe;
GRANT INSERT, DELETE ON Employes TO admin8_Role_gerant;
GRANT admin8_Role_employe TO admin8_Role_gerant;

---------ROLE & USER---------

GRANT admin8_Role_gerant to user1 WITH ADMIN OPTION;
GRANT admin8_Role_comptable to user2;
GRANT admin8_Role_client to user3;
GRANT admin8_Role_client to user7;
GRANT admin8_Role_employe to user4;
GRANT admin8_Role_employe to user6;

---------SEQUENCE---------

CREATE SEQUENCE incrIDCommande START WITH 111 INCREMENT BY 1;

---------INSERTION---------

insert into Clients VALUES ('USER3', 'Su', 'Jay', '2 rue de la paix' );
insert into Clients VALUES ('USER7', 'Omet', 'Emma', '3 rue de la paix' );

insert into Employes VALUES ('USER4', 'Croche', 'Sarah', '3 rue du telephone', '00021851613' );
insert into Employes VALUES ('USER6', 'Pelle', 'Sarah', '4 rue du telephone', '00021851713' );

insert into Commandes VALUES (incrIDCommande.nextval, 'USER3', 'USER4', '25', 'ISI_BURGER_1', '3 rue de la paix', '09-OCT-18');
insert into Commandes VALUES (incrIDCommande.nextval, 'USER3', 'USER4', '22', 'ISI_BURGER_3', '1 rue de la paix', '09-JAN-17');
insert into Commandes VALUES (incrIDCommande.nextval, 'USER3', 'USER4', '25', 'ISI_BURGER_2', '2 rue de la paix', '09-JAN-18');

insert into Commandes VALUES (incrIDCommande.nextval, 'USER7', 'USER4', '25', 'ISI_BURGER_1', '3 rue de la paix', '09-JAN-16');
insert into Commandes VALUES (incrIDCommande.nextval, 'USER7', 'USER4', '22', 'ISI_BURGER_3', '1 rue de la paix','09-JAN-15');
insert into Commandes VALUES (incrIDCommande.nextval, 'USER7', 'USER4', '25', 'ISI_BURGER_2', '2 rue de la paix','09-JAN-14');

insert into Commandes VALUES (incrIDCommande.nextval, 'USER3', 'USER6', '25', 'ISI_BURGER_1', '3 rue de la paix','09-JAN-13');
insert into Commandes VALUES (incrIDCommande.nextval, 'USER3', 'USER6', '22', 'ISI_BURGER_3', '1 rue de la paix','09-JAN-12');
insert into Commandes VALUES (incrIDCommande.nextval, 'USER3', 'USER6', '25', 'ISI_BURGER_2', '2 rue de la paix', '09-OCT-18');

---------CONTEXT---------

CREATE OR REPLACE CONTEXT connexion_admin8 USING set_connexion_admin8_pkg;
CREATE OR REPLACE PACKAGE set_connexion_admin8_pkg IS PROCEDURE set_connexion;
END;
/

---------PACKAGE---------

CREATE OR REPLACE PACKAGE BODY set_connexion_admin8_pkg IS
    PROCEDURE set_connexion 
    IS
       nom_ctx VARCHAR(20);
       role_ctx VARCHAR(40);
    BEGIN
        nom_ctx := SYS_CONTEXT('USERENV','SESSION_USER');
        DBMS_SESSION.SET_CONTEXT('connexion_admin8','nom',nom_ctx);
        SELECT GRANTED_ROLE INTO role_ctx
        FROM DBA_ROLE_PRIVS 
        WHERE GRANTEE = nom_ctx and granted_role like 'ADMIN8%';
        DBMS_SESSION.SET_CONTEXT('connexion_admin8', 'role', role_ctx);
        dbms_output.put_line(role_ctx);
    END set_connexion;
END set_connexion_admin8_pkg;
/
GRANT EXECUTE ON admin8.set_connexion_admin8_pkg TO user1, user2,user3,user4, user5,user6,user7;

---------FONCTIONS AUTHENTIFICATION---------

CREATE OR REPLACE FUNCTION auth_commande(
    schema_var IN VARCHAR2,
    table_var IN VARCHAR2)
RETURN VARCHAR2
IS
    return_val VARCHAR2 (400);
BEGIN
    IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_EMPLOYE' THEN
        return_val := 'id_employe=SYS_CONTEXT(''connexion_admin8'', ''nom'')';
    ELSE
        IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_CLIENT' THEN
            return_val := 'id_client=SYS_CONTEXT(''connexion_admin8'', ''nom'')';
        ELSE 
            IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_GERANT' OR SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_COMPTABLE'  THEN
                return_val := '1=1';
            END IF;
        END IF;
    END IF;
    RETURN return_val;
END;
/

CREATE OR REPLACE FUNCTION auth_employe(
    schema_var IN VARCHAR2,
    table_var IN VARCHAR2)
RETURN VARCHAR2
IS
    return_val VARCHAR2 (400);
BEGIN
    IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_EMPLOYE' THEN
        return_val := 'id_employe=SYS_CONTEXT(''connexion_admin8'', ''nom'')';
    ELSE
        IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_GERANT' OR SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_COMPTABLE'  THEN
            return_val := '1=1';
        END IF;
    END IF;
    RETURN return_val;
END;
/

CREATE OR REPLACE FUNCTION auth_client(
    schema_var IN VARCHAR2,
    table_var IN VARCHAR2)
RETURN VARCHAR2
IS
    return_val VARCHAR2 (400);
BEGIN
    IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_EMPLOYE' THEN
        return_val := '1=1';
    ELSE
        IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_CLIENT' THEN
            return_val := 'id_client=SYS_CONTEXT(''connexion_admin8'', ''nom'')';
        ELSE 
            IF SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_GERANT' OR SYS_CONTEXT('connexion_admin8', 'role') = 'ADMIN8_ROLE_COMPTABLE'  THEN
                return_val := '1=1';
            END IF;
        END IF;
    END IF;
    RETURN return_val;
END;
/

---------POLICIES---------

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'admin8',
        object_name => 'Clients',
        policy_name => 'com_policy',
        function_schema => 'admin8',
        policy_function => 'auth_client',
        statement_types => 'select, insert, update, delete'
    );
END;
/


BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'admin8',
        object_name => 'Commandes',
        policy_name => 'com_policy',
        function_schema => 'admin8',
        policy_function => 'auth_commande',
        statement_types => 'select, insert, update'
    );
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'admin8',
        object_name => 'Employes',
        policy_name => 'com_policy',
        function_schema => 'admin8',
        policy_function => 'auth_employe',
        statement_types => 'select, insert, update, delete'
    );
END;
/        

