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

-- miguel

DELIMITER $$

-- =============================================
-- Procedure: sp_vaga_inserir
-- Descrição: Insere uma nova vaga
-- =============================================
CREATE PROCEDURE sp_vaga_inserir(
    IN p_empresa_id                     INT,
    IN p_titulo                         VARCHAR(255),
    IN p_descricao                      TEXT,
    IN p_requisito                      TEXT,
    IN p_tipo_vaga_id                   INT,
    IN p_modalidade_vaga_id             INT,
    IN p_salario_min                    DECIMAL(10,2),
    IN p_salario_max                    DECIMAL(10,2),
    IN p_beneficios                     TEXT,
    IN p_carga_horaria                  VARCHAR(50),
    IN p_idade_minima                   INT,
    IN p_idade_maxima                   INT,
    IN p_nivel_escolaridade_minimo_id   INT,
    IN p_area_atuacao                   VARCHAR(100),
    IN p_data_expiracao                 DATETIME,
    IN p_status_vaga_id                 INT,
    IN p_numero_vagas                   INT,
    IN p_cidade_id                      INT,
    
    OUT p_novo_id                       INT,
    OUT p_erro_mensagem                 VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET p_erro_mensagem = 'Erro ao inserir vaga (violação de constraint ou erro de dados)';
        SET p_novo_id = NULL;
        ROLLBACK;
    END;

    SET p_erro_mensagem = NULL;
    
    START TRANSACTION;
    
    INSERT INTO vagas (
        empresa_id,
        titulo,
        descricao,
        requisito,
        tipo_vaga_id,
        modalidade_vaga_id,
        salario_min,
        salario_max,
        beneficios,
        carga_horaria,
        idade_minima,
        idade_maxima,
        nivel_escolaridade_minimo_id,
        area_atuacao,
        data_publicacao,
        data_expiracao,
        status_vaga_id,
        numero_vagas,
        cidade_id
    ) VALUES (
        p_empresa_id,
        TRIM(p_titulo),
        p_descricao,
        p_requisito,
        p_tipo_vaga_id,
        p_modalidade_vaga_id,
        p_salario_min,
        p_salario_max,
        p_beneficios,
        p_carga_horaria,
        p_idade_minima,
        p_idade_maxima,
        p_nivel_escolaridade_minimo_id,
        TRIM(p_area_atuacao),
        CURRENT_TIMESTAMP,
        p_data_expiracao,
        p_status_vaga_id,
        COALESCE(p_numero_vagas, 1),
        p_cidade_id
    );
    
    SET p_novo_id = LAST_INSERT_ID();
    
    COMMIT;
    
END $$


-- =============================================
-- Procedure: sp_vaga_atualizar
-- Descrição: Atualiza dados de uma vaga existente
-- =============================================
CREATE PROCEDURE sp_vaga_atualizar(
    IN p_id                             INT,
    IN p_titulo                         VARCHAR(255),
    IN p_descricao                      TEXT,
    IN p_requisito                      TEXT,
    IN p_tipo_vaga_id                   INT,
    IN p_modalidade_vaga_id             INT,
    IN p_salario_min                    DECIMAL(10,2),
    IN p_salario_max                    DECIMAL(10,2),
    IN p_beneficios                     TEXT,
    IN p_carga_horaria                  VARCHAR(50),
    IN p_idade_minima                   INT,
    IN p_idade_maxima                   INT,
    IN p_nivel_escolaridade_minimo_id   INT,
    IN p_area_atuacao                   VARCHAR(100),
    IN p_data_expiracao                 DATETIME,
    IN p_status_vaga_id                 INT,
    IN p_numero_vagas                   INT,
    IN p_cidade_id                      INT,
    
    OUT p_sucesso                       BOOLEAN,
    OUT p_erro_mensagem                 VARCHAR(255)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    
    SET p_sucesso = FALSE;
    SET p_erro_mensagem = NULL;
    
    SELECT COUNT(*) INTO v_count FROM vagas WHERE id = p_id;
    
    IF v_count = 0 THEN
        SET p_erro_mensagem = 'Vaga não encontrada';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_erro_mensagem;
    END IF;
    
    START TRANSACTION;
    
    UPDATE vagas SET
        titulo                         = TRIM(p_titulo),
        descricao                      = p_descricao,
        requisito                      = p_requisito,
        tipo_vaga_id                   = p_tipo_vaga_id,
        modalidade_vaga_id             = p_modalidade_vaga_id,
        salario_min                    = p_salario_min,
        salario_max                    = p_salario_max,
        beneficios                     = p_beneficios,
        carga_horaria                  = p_carga_horaria,
        idade_minima                   = p_idade_minima,
        idade_maxima                   = p_idade_maxima,
        nivel_escolaridade_minimo_id   = p_nivel_escolaridade_minimo_id,
        area_atuacao                   = TRIM(p_area_atuacao),
        data_expiracao                 = p_data_expiracao,
        status_vaga_id                 = p_status_vaga_id,
        numero_vagas                   = COALESCE(p_numero_vagas, numero_vagas),
        cidade_id                      = p_cidade_id,
        data_publicacao                = data_publicacao   -- mantém a data original
    WHERE id = p_id;
    
    SET p_sucesso = TRUE;
    COMMIT;
    
END $$


-- =============================================
-- Procedure: sp_vaga_excluir
-- Descrição: Remove uma vaga (soft ou hard delete)
-- =============================================
CREATE PROCEDURE sp_vaga_excluir(
    IN p_id              INT,
    OUT p_sucesso        BOOLEAN,
    OUT p_erro_mensagem  VARCHAR(255)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    
    SET p_sucesso = FALSE;
    SET p_erro_mensagem = NULL;
    
    SELECT COUNT(*) INTO v_count FROM vagas WHERE id = p_id;
    
    IF v_count = 0 THEN
        SET p_erro_mensagem = 'Vaga não encontrada';
    ELSE
        START TRANSACTION;
        
        -- Se quiser soft-delete, altere status_vaga_id para um valor de "encerrada/excluída"
        -- Caso contrário, faça DELETE físico:
        DELETE FROM vagas WHERE id = p_id;
        
        -- Alternativa soft-delete (comente/descomente conforme necessidade):
        -- UPDATE vagas 
        --    SET status_vaga_id = 99,   -- exemplo: 99 = excluída/inativa
        --        data_expiracao = NOW()
        --  WHERE id = p_id;
        
        SET p_sucesso = TRUE;
        COMMIT;
    END IF;
    
END $$


-- =============================================
-- Procedure: sp_vaga_listar_simples
-- Descrição: Lista vagas com filtros básicos (exemplo prático)
-- =============================================
CREATE PROCEDURE sp_vaga_listar_simples(
    IN p_empresa_id         INT,          -- NULL = todas
    IN p_status_vaga_id     INT,          -- NULL = todos
    IN p_cidade_id          INT,          -- NULL = todas
    IN p_titulo_parcial     VARCHAR(100), -- filtro LIKE
    IN p_limit              INT DEFAULT 50,
    IN p_offset             INT DEFAULT 0
)
BEGIN
    SELECT 
        v.id,
        v.titulo,
        e.nome_fantasia         AS empresa,
        tv.descricao            AS tipo_vaga,
        mv.descricao            AS modalidade,
        sv.descricao            AS status,
        v.salario_min,
        v.salario_max,
        v.numero_vagas,
        v.data_publicacao,
        cid.nome                AS cidade,
        est.uf
    FROM vagas v
    INNER JOIN empresas e          ON e.id = v.empresa_id
    INNER JOIN tipos_vaga tv       ON tv.id = v.tipo_vaga_id
    INNER JOIN modalidades mv      ON mv.id = v.modalidade_vaga_id
    INNER JOIN status_vaga sv      ON sv.id = v.status_vaga_id
    LEFT  JOIN cidades cid         ON cid.id = v.cidade_id
    LEFT  JOIN estados est         ON est.id = cid.estado_id
    
    WHERE 1=1
      AND (p_empresa_id         IS NULL OR v.empresa_id = p_empresa_id)
      AND (p_status_vaga_id     IS NULL OR v.status_vaga_id = p_status_vaga_id)
      AND (p_cidade_id          IS NULL OR v.cidade_id = p_cidade_id)
      AND (p_titulo_parcial     IS NULL OR v.titulo LIKE CONCAT('%', TRIM(p_titulo_parcial), '%'))
    
    ORDER BY v.data_publicacao DESC
    LIMIT p_limit
    OFFSET p_offset;
    
END $$

====YASMIM====

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `enderecos`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_enderecos_insert(
    IN p_logradouro VARCHAR(255),
    IN p_numero VARCHAR(20),
    IN p_completo VARCHAR(100),
    IN p_estado INT,
    IN p_cidade INT,
    IN p_bairro VARCHAR(100),
    IN p_cep  VARCHAR(19),
    OUT p_id INT
)
BEGIN
    INSERT INTO enderecos (lougradouro, numero, completo, estado, cidade, bairro, cep, id)
    VALUES (p_lougradouro, p_numero, p_completo, p_estado, p_cidade, p_bairro, p_cep, p_id);
    -- SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_enderecos_update(
    IN p_logradouro varchar(255),
    IN p_numero VARCHAR(20),
    IN p_completo VARCHAR(100),
    IN p_estado INT,
    IN p_cidade INT,
    IN p_bairro VARCHAR(100),
    IN p_cep VARCHAR(19),
    IN p_id INT TIMESTAMP
)
BEGIN
    UPDATE enderecos
    SET logradouro       = p_logradouro,
        numero           = p_numero,
        completo         = p_completo,
        estado           = p_estado,
        cidade           = p_cidade,
        bairro           = p_bairro,
        cep              = p_cep,
        id               = p_id,
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_enderecos_delete(IN p_id INT)
BEGIN
    DELETE FROM enderecos WHERE id = p_id;
END$$

CREATE PROCEDURE sp_enderecos_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM enderecos WHERE id = p_id;
END$$

CREATE PROCEDURE sp_enderecos_list_all()
BEGIN
    SELECT * FROM enderecos;
END$$

DELIMITER ;


====YASMIM====

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `telefones`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_telefones_insert(
    IN p_numero VARCHAR(15),
    IN p_tipo_telefone INT
    IN p_wpp TINYINT(1),
    OUT p_id INT
)
BEGIN
    INSERT INTO telefones(numero, tipo telefone, wpp, id)
    VALUES (p_numero, p_tipo_telefone, p_wpp, p_id);
    -- SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_telefones_update(
    IN p_numero VARCHAR(255),
    IN p_tipo_telefone INT
    IN p_wpp TINYINT(1),
    IN p_id INT TIMESTAMP
)
BEGIN
    UPDATE telefones
    SET
        numero          = p_numero,
        bairro           = p_tipo_telefone,
        cep              = p_wpp,
        id               = p_id,
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_telefones_delete(IN p_id INT)
BEGIN
    DELETE FROM telefone WHERE id = p_id;
END$$

CREATE PROCEDURE sp_telefones_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM telefones WHERE id = p_id;
END$$

CREATE PROCEDURE sp_telefones_list_all()
BEGIN
    SELECT * FROM telefones;
END$$

DELIMITER ;

====YASMIM====

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `tipo_notificacao`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_tipo_notificacao_insert(
    IN p_nome VARCHAR(50),
    OUT p_id INT
)
BEGIN
    INSERT INTO tipo_notificacao (nome, id)
    VALUES (p_tipo_notificacao, p_id);
    -- SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_tipo_notificacao_update(
    IN p_nome VARCHAR(50),
    IN p_id INT TIMESTAMP
)
BEGIN
    UPDATE tipo_notificacao
    SET 
      nome     = p_nome,
      id       = p_id,
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_tipo_notificacao_delete(IN p_id INT)
BEGIN
    DELETE FROM tipo_notificacao WHERE id = p_id;
END$$

CREATE PROCEDURE sp_tipo_notificacao_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM tipo_notificacao WHERE id = p_id;
END$$

CREATE PROCEDURE sp_tipo_notificacao_list_all()
BEGIN
    SELECT * FROM tipo_notificacao;
END$$

DELIMITER ;
