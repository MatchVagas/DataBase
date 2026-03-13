-- =====================================================
-- SELECIONA A DATABASE `matchvagas`
-- =====================================================
USE matchvagas;

-- =====================================================
-- PROCEDURES PARA A TABELA `usuarios`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_usuarios_insert(
    IN p_nome VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_senha_hash TEXT,
    IN p_dataNascimento DATE,
    IN p_idade INT,
    IN p_ativo BOOLEAN,
    IN p_dataCadastro TIMESTAMP,
    IN p_dataUltimoAcesso TIMESTAMP,
    OUT p_id INT
)
BEGIN
    INSERT INTO usuarios (nome, email, senha_hash, dataNascimento, idade, ativo, dataCadastro, dataUltimoAcesso)
    VALUES (p_nome, p_email, p_senha_hash, p_dataNascimento, p_idade, p_ativo, p_dataCadastro, p_dataUltimoAcesso);
    -- SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_usuarios_update(
    IN p_id INT,
    IN p_nome VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_senha_hash TEXT,
    IN p_dataNascimento DATE,
    IN p_idade INT,
    IN p_ativo BOOLEAN,
    IN p_dataUltimoAcesso TIMESTAMP
)
BEGIN
    UPDATE usuarios
    SET nome             = p_nome,
        email            = p_email,
        senha_hash       = p_senha_hash,
        dataNascimento   = p_dataNascimento,
        idade            = p_idade,
        ativo            = p_ativo,
        dataUltimoAcesso = p_dataUltimoAcesso
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_usuarios_delete(IN p_id INT)
BEGIN
    DELETE FROM usuarios WHERE id = p_id;
END$$

CREATE PROCEDURE sp_usuarios_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM usuarios WHERE id = p_id;
END$$

CREATE PROCEDURE sp_usuarios_list_all()
BEGIN
    SELECT * FROM usuarios;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `empresas`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_empresas_insert(
    IN p_cnpj VARCHAR(18),
    IN p_razao_social VARCHAR(150),
    IN p_nome_fantasia VARCHAR(150),
    IN p_descricao TEXT,
    IN p_porte_id INT,
    IN p_ramo_id INT,
    IN p_site VARCHAR(150),
    OUT p_id INT
)
BEGIN
    -- Verifica se porte_id e ramo_id existem (opcional, mas recomendado)
    IF p_porte_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM portes WHERE id = p_porte_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'porte_id inválido';
    END IF;
    IF p_ramo_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ramos_atuacao WHERE id = p_ramo_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ramo_id inválido';
    END IF;

    INSERT INTO empresas (cnpj, razao_social, nome_fantasia, descricao, porte_id, ramo_id, site)
    VALUES (p_cnpj, p_razao_social, p_nome_fantasia, p_descricao, p_porte_id, p_ramo_id, p_site);
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_empresas_update(
    IN p_id INT,
    IN p_cnpj VARCHAR(18),
    IN p_razao_social VARCHAR(150),
    IN p_nome_fantasia VARCHAR(150),
    IN p_descricao TEXT,
    IN p_porte_id INT,
    IN p_ramo_id INT,
    IN p_site VARCHAR(150)
)
BEGIN
    IF p_porte_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM portes WHERE id = p_porte_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'porte_id inválido';
    END IF;
    IF p_ramo_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ramos_atuacao WHERE id = p_ramo_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ramo_id inválido';
    END IF;

    UPDATE empresas
    SET cnpj          = p_cnpj,
        razao_social  = p_razao_social,
        nome_fantasia = p_nome_fantasia,
        descricao     = p_descricao,
        porte_id      = p_porte_id,
        ramo_id       = p_ramo_id,
        site          = p_site
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_empresas_delete(IN p_id INT)
BEGIN
    DELETE FROM empresas WHERE id = p_id;
END$$

CREATE PROCEDURE sp_empresas_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM empresas WHERE id = p_id;
END$$

CREATE PROCEDURE sp_empresas_list_all()
BEGIN
    SELECT * FROM empresas;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `empresas`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_administradores_insert(
    IN p_usuario_id INT,
    IN p_nivel VARCHAR(50),
    IN p_departamento_id INT,
    IN p_permissoes TEXT
)
BEGIN
    INSERT INTO matchvagas.administradores(usuario_id, nivel, departamento_id, permissoes)
    VALUES (p_usuario_id,
            p_nivel,
            p_departamento_id,
            p_permissoes);
END$$

CREATE PROCEDURE sp_administradores_update(
    IN p_id INT,
    IN p_usuario_id INT,
    IN p_nivel VARCHAR(50),
    IN p_departamento_id INT,
    IN p_permissoes TEXT
)
BEGIN
    IF p_usuario_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'usuario_id inválido';
    END IF;

    IF p_departamento_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM departamentos WHERE id = p_departamento_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'departamento_id inválido';
    END IF;

    UPDATE matchvagas.administradores
    SET usuario_id      = p_usuario_id,
        nivel           = p_nivel,
        departamento_id = p_departamento_id,
        permissoes      = p_permissoes
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_administradores_delete(IN p_id INT)
BEGIN
    DELETE FROM administradores WHERE id = p_id;
END$$

CREATE PROCEDURE sp_administradores_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM administradores WHERE id = p_id;
END$$

CREATE PROCEDURE sp_administradores_list_all()
BEGIN
    SELECT * FROM administradores;
END$$

DELIMITER ;