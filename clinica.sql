-- 1. CRIAÇÃO DO SCHEMA


CREATE DATABASE IF NOT EXISTS clinica;

USE clinica;

-- 2. CRIAÇÃO DA TABELA PACIENTE

CREATE TABLE PACIENTE (
    id_paciente INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    data_nascimento DATE NOT NULL,

    CONSTRAINT pk_paciente
        PRIMARY KEY (id_paciente),

    CONSTRAINT uq_paciente_cpf
        UNIQUE (cpf)

) ENGINE = InnoDB;

-- 3. CRIAÇÃO DA TABELA MEDICO

CREATE TABLE MEDICO (
    id_medico INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) NOT NULL,
    especialidade VARCHAR(80) NOT NULL,

    CONSTRAINT pk_medico
        PRIMARY KEY (id_medico),

    CONSTRAINT uq_medico_crm
        UNIQUE (crm)

) ENGINE = InnoDB;

-- 4. CRIAÇÃO DA TABELA CONSULTA

CREATE TABLE CONSULTA (
    id_consulta INT AUTO_INCREMENT,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    data_hora DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_consulta
        PRIMARY KEY (id_consulta),

    CONSTRAINT fk_consulta_paciente
        FOREIGN KEY (id_paciente)
        REFERENCES PACIENTE (id_paciente),

    CONSTRAINT fk_consulta_medico
        FOREIGN KEY (id_medico)
        REFERENCES MEDICO (id_medico),

    CONSTRAINT chk_consulta_status
        CHECK (status IN ('AGENDADA', 'REALIZADA', 'CANCELADA'))

) ENGINE = InnoDB;

-- 5. CRIAÇÃO DA TABELA PROCEDIMENTO

CREATE TABLE PROCEDIMENTO (
    id_procedimento INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_procedimento
        PRIMARY KEY (id_procedimento),

    CONSTRAINT uq_procedimento_nome
        UNIQUE (nome),

    CONSTRAINT chk_procedimento_valor
        CHECK (valor > 0)

) ENGINE = InnoDB;
-- 6. CRIAÇÃO DA TABELA CONSULTA_PROCEDIMENTO

CREATE TABLE CONSULTA_PROCEDIMENTO (
    id_consulta INT NOT NULL,
    id_procedimento INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,

    CONSTRAINT pk_consulta_procedimento
        PRIMARY KEY (id_consulta, id_procedimento),

    CONSTRAINT fk_cp_consulta
        FOREIGN KEY (id_consulta)
        REFERENCES CONSULTA (id_consulta),

    CONSTRAINT fk_cp_procedimento
        FOREIGN KEY (id_procedimento)
        REFERENCES PROCEDIMENTO (id_procedimento),

    CONSTRAINT chk_cp_quantidade
        CHECK (quantidade > 0)

) ENGINE = InnoDB;

-- 7. EVOLUÇÃO DO SCHEMA - ALTER TABLE 1

ALTER TABLE PACIENTE
ADD COLUMN telefone VARCHAR(20);

-- 8. EVOLUÇÃO DO SCHEMA - ALTER TABLE 2

ALTER TABLE CONSULTA
ADD COLUMN observacao VARCHAR(255);

-- 9. POVOAMENTO - PACIENTE

INSERT INTO PACIENTE
    (nome, cpf, data_nascimento, telefone)
VALUES
    ('Ana Souza', '11111111111', '1995-03-15', '11988881111'),
    ('Bruno Lima', '22222222222', '1988-07-22', '11988882222'),
    ('Carla Mendes', '33333333333', '2000-11-10', '11988883333');

SELECT *
FROM PACIENTE;

-- 10. POVOAMENTO - MEDICO
INSERT INTO MEDICO
    (nome, crm, especialidade)
VALUES
    ('Dr. Ricardo Alves', 'CRM10001', 'Cardiologia'),
    ('Dra. Fernanda Costa', 'CRM10002', 'Dermatologia'),
    ('Dr. Marcelo Santos', 'CRM10003', 'Ortopedia');

SELECT *
FROM MEDICO;

-- 11. POVOAMENTO - PROCEDIMENTO

INSERT INTO PROCEDIMENTO
    (nome, valor)
VALUES
    ('Eletrocardiograma', 150.00);

INSERT INTO PROCEDIMENTO
    (nome, valor)
VALUES
    ('Consulta dermatológica', 200.00),
    ('Raio-X', 120.00);

SELECT *
FROM PROCEDIMENTO;

-- 12. POVOAMENTO - CONSULTA

INSERT INTO CONSULTA
    (id_paciente, id_medico, data_hora, status, observacao)
VALUES
    (1, 1, '2026-10-05 09:00:00',
     'AGENDADA', 'Primeira consulta'),

    (2, 2, '2026-10-05 10:30:00',
     'AGENDADA', 'Avaliação dermatológica'),

    (3, 3, '2026-10-06 14:00:00',
     'AGENDADA', 'Avaliação ortopédica');

SELECT *
FROM CONSULTA;

INSERT INTO CONSULTA_PROCEDIMENTO
    (id_consulta, id_procedimento, quantidade)
VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 1);

SELECT *
FROM CONSULTA_PROCEDIMENTO;

SELECT *
FROM CONSULTA
WHERE id_medico = 1
  AND status = 'AGENDADA';

UPDATE CONSULTA
SET status = 'REALIZADA'
WHERE id_medico = 1
  AND status = 'AGENDADA';

SELECT *
FROM CONSULTA
WHERE id_medico = 1;

SELECT *
FROM PROCEDIMENTO
WHERE id_procedimento = 3;

SELECT *
FROM CONSULTA_PROCEDIMENTO
WHERE id_procedimento = 3;

-- Se não houver dependências, podemos excluir.

DELETE FROM PROCEDIMENTO
WHERE id_procedimento = 3;


-- Conferir o resultado.
SELECT *
FROM PROCEDIMENTO;


-- 16. ERRO DE INTEGRIDADE 1 - UNIQUE

-- Tentativa de inserir um paciente com CPF já existente.
--
-- O CPF possui uma restrição UNIQUE:
--
--     CONSTRAINT uq_paciente_cpf
--         UNIQUE (cpf)
--
-- Como o CPF 11111111111 já pertence à Ana Souza,
-- o MySQL deve rejeitar a operação.
--
-- ERRO ESPERADO:
-- Duplicate entry ... for key 'uq_paciente_cpf'


/*
INSERT INTO PACIENTE
    (nome, cpf, data_nascimento, telefone)
VALUES
    ('Paciente Duplicado',
     '11111111111',
     '1990-01-01',
     '11999999999');
*/


-- 17. ERRO DE INTEGRIDADE 2 - FOREIGN KEY

-- Tentativa de criar uma consulta para um paciente
-- que não existe.
--
-- O paciente 999 não existe na tabela PACIENTE.
--
-- A tabela CONSULTA possui:
--
--     FOREIGN KEY (id_paciente)
--     REFERENCES PACIENTE (id_paciente)
--
-- Portanto, a operação deve ser rejeitada.
--
-- ERRO ESPERADO:
-- Cannot add or update a child row:
-- a foreign key constraint fails

/*
INSERT INTO CONSULTA
    (id_paciente, id_medico, data_hora, status)
VALUES
    (999,
     1,
     '2026-10-10 09:00:00',
     'AGENDADA');
*/

-- 18. ERRO DE INTEGRIDADE 3 - CHECK

-- Tentativa de inserir um procedimento com valor negativo.
--
-- A tabela PROCEDIMENTO possui:
--
--     CHECK (valor > 0)
--
-- Portanto, o valor -50.00 é inválido.
--
-- ERRO ESPERADO:
-- Check constraint ... is violated

/*
INSERT INTO PROCEDIMENTO
    (nome, valor)
VALUES
    ('Procedimento Inválido', -50.00);
*/


-- 19. ERRO DE INTEGRIDADE 4 - FOREIGN KEY AO EXCLUIR

-- Primeiro verificamos se o paciente 1 possui consultas.


SELECT *
FROM CONSULTA
WHERE id_paciente = 1;


-- Como o paciente 1 possui uma consulta, a tentativa de
-- exclusão deve ser bloqueada pela FK.
--
-- A FK foi criada sem ON DELETE CASCADE.
-- Portanto, o comportamento é RESTRICT.
--
-- O paciente não pode ser excluído enquanto existirem
-- consultas que dependam dele.
--
-- ERRO ESPERADO:
-- Cannot delete or update a parent row:
-- a foreign key constraint fails


/*
DELETE FROM PACIENTE
WHERE id_paciente = 1;
*/


-- 20. EXPLICAÇÃO DOS QUATRO ERROS


/*
ERRO 1 - UNIQUE
---------------------------------------------------------------
Tentativa:
Inserir um CPF que já existe.

Causa:
A coluna CPF possui uma restrição UNIQUE.

Objetivo da regra:
Impedir que dois pacientes tenham o mesmo CPF.


ERRO 2 - FOREIGN KEY NA INSERÇÃO
---------------------------------------------------------------
Tentativa:
Criar uma consulta para o paciente 999.

Causa:
O paciente 999 não existe em PACIENTE.

Objetivo da regra:
Impedir registros filhos que apontem para registros
pais inexistentes.


ERRO 3 - CHECK
---------------------------------------------------------------
Tentativa:
Inserir um procedimento com valor negativo.

Causa:
A regra CHECK exige que o valor seja maior que zero.

Objetivo da regra:
Garantir que os dados respeitem uma condição definida
pelo modelo.


ERRO 4 - FOREIGN KEY NA EXCLUSÃO
---------------------------------------------------------------
Tentativa:
Excluir um paciente que possui consultas.

Causa:
Existem registros em CONSULTA que dependem desse paciente.

Comportamento escolhido:
RESTRICT, pois não foi utilizado ON DELETE CASCADE.

Objetivo da regra:
Evitar que a exclusão do registro pai deixe registros
filhos sem referência válida.
*/

-- 21. INSPEÇÃO FINAL - SHOW CREATE TABLE

SHOW CREATE TABLE PACIENTE;

SHOW CREATE TABLE MEDICO;

SHOW CREATE TABLE CONSULTA;

SHOW CREATE TABLE PROCEDIMENTO;

SHOW CREATE TABLE CONSULTA_PROCEDIMENTO;

-- 22. INSPEÇÃO FINAL - SHOW INDEX

SHOW INDEX FROM PACIENTE;

SHOW INDEX FROM MEDICO;

SHOW INDEX FROM CONSULTA;

SHOW INDEX FROM PROCEDIMENTO;

SHOW INDEX FROM CONSULTA_PROCEDIMENTO;
