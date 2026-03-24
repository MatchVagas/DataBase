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
    -- armazena os novos dados em um json
    DECLARE v_dados_novos JSON;

    INSERT INTO usuarios (nome, email, senha_hash, dataNascimento, idade, ativo, dataCadastro, dataUltimoAcesso)
    VALUES (p_nome, p_email, p_senha_hash, p_dataNascimento, p_idade,
            p_ativo, p_dataCadastro, p_dataUltimoAcesso);

    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'nome', p_nome,
        'email', p_email,
        'senha_hash', p_senha_hash,
        'dataNascimento', p_dataNascimento,
        'idade', p_idade,
        'ativo', p_ativo,
        'dataCadastro', p_dataCadastro,
        'dataUltimoAcesso', p_dataUltimoAcesso
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, descricao, dados_novos)
    VALUES (@usuario_logado, 'usuarios', p_id, 'INSERT','Operação INSERT', v_dados_novos);


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
    -- dados antigos
    DECLARE v_old_nome VARCHAR(255);
    DECLARE v_old_email VARCHAR(255);
    DECLARE v_old_senha_hash TEXT;
    DECLARE v_old_dataNascimento DATE;
    DECLARE v_old_idade INT;
    DECLARE v_old_ativo BOOLEAN;
    DECLARE v_old_dataCadastro TIMESTAMP;
    DECLARE v_old_dataUltimoAcesso TIMESTAMP;
    DECLARE v_dados_antigos JSON;
    DECLARE v_dados_novos JSON;
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM usuarios WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
    END IF;

    SELECT nome, email, senha_hash, dataNascimento, idade, ativo, dataCadastro, dataUltimoAcesso
    INTO v_old_nome, v_old_email, v_old_senha_hash, v_old_dataNascimento, v_old_idade, v_old_ativo, v_old_dataCadastro, v_old_dataUltimoAcesso
    FROM usuarios WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'nome', v_old_nome,
        'email', v_old_email,
        'senha_hash', v_old_senha_hash,
        'dataNascimento', v_old_dataNascimento,
        'idade', v_old_idade,
        'ativo', v_old_ativo,
        'dataCadastro', v_old_dataCadastro,
        'dataUltimoAcesso', v_old_dataUltimoAcesso
    );

    UPDATE usuarios
    SET nome             = p_nome,
        email            = p_email,
        senha_hash       = p_senha_hash,
        dataNascimento   = p_dataNascimento,
        idade            = p_idade,
        ativo            = p_ativo,
        dataUltimoAcesso = p_dataUltimoAcesso
    WHERE id = p_id;

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'nome', p_nome,
        'email', p_email,
        'senha_hash', p_senha_hash,
        'dataNascimento', p_dataNascimento,
        'idade', p_idade,
        'ativo', p_ativo,
        'dataCadastro', v_old_dataCadastro,
        'dataUltimoAcesso', p_dataUltimoAcesso
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (@usuario_logado, 'usuarios', p_id, 'UPDATE', v_dados_antigos, v_dados_novos);

END$$

CREATE PROCEDURE sp_usuarios_delete(IN p_id INT)
BEGIN

    -- dados antigos
    DECLARE v_old_nome VARCHAR(255);
    DECLARE v_old_email VARCHAR(255);
    DECLARE v_old_senha_hash TEXT;
    DECLARE v_old_dataNascimento DATE;
    DECLARE v_old_idade INT;
    DECLARE v_old_ativo BOOLEAN;
    DECLARE v_old_dataCadastro TIMESTAMP;
    DECLARE v_old_dataUltimoAcesso TIMESTAMP;
    DECLARE v_dados_antigos JSON;
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM usuarios WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
    END IF;

    SELECT nome, email, senha_hash, dataNascimento, idade, ativo, dataCadastro, dataUltimoAcesso
    INTO v_old_nome, v_old_email, v_old_senha_hash, v_old_dataNascimento, v_old_idade, v_old_ativo, v_old_dataCadastro, v_old_dataUltimoAcesso
    FROM usuarios WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'nome', v_old_nome,
        'email', v_old_email,
        'senha_hash', v_old_senha_hash,
        'dataNascimento', v_old_dataNascimento,
        'idade', v_old_idade,
        'ativo', v_old_ativo,
        'dataCadastro', v_old_dataCadastro,
        'dataUltimoAcesso', v_old_dataUltimoAcesso
    );

    DELETE FROM usuarios WHERE id = p_id;

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos)
    VALUES (@usuario_logado, 'usuarios', p_id, 'DELETE', v_dados_antigos);

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

    DECLARE v_dados_novos JSON;
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

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'cnpj', p_cnpj,
        'razao_social', p_razao_social,
        'nome_fantasia', p_nome_fantasia,
        'descricao', p_descricao,
        'porte_id', p_porte_id,
        'ramo_id', p_ramo_id,
        'site', p_site
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_novos)
    VALUES (@usuario_logado, 'empresas', p_id, 'INSERT', v_dados_novos);

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
    DECLARE v_old_cnpj VARCHAR(18);
    DECLARE v_old_razao_social VARCHAR(150);
    DECLARE v_old_nome_fantasia VARCHAR(150);
    DECLARE v_old_descricao TEXT;
    DECLARE v_old_porte_id INT;
    DECLARE v_old_ramo_id INT;
    DECLARE v_old_site VARCHAR(150);
    DECLARE v_dados_antigos JSON;
    DECLARE v_dados_novos JSON;
    DECLARE v_count INT;


    IF p_porte_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM portes WHERE id = p_porte_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'porte_id inválido';
    END IF;
    IF p_ramo_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ramos_atuacao WHERE id = p_ramo_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ramo_id inválido';
    END IF;

    -- se não encontrar a empresa -> error
    SELECT COUNT(*) INTO v_count FROM empresas WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empresa não encontrada';
    END IF;

    -- pega os dados da empresa
    SELECT cnpj, razao_social, nome_fantasia, descricao, porte_id, ramo_id, site
    INTO v_old_cnpj, v_old_razao_social, v_old_nome_fantasia, v_old_descricao, v_old_porte_id, v_old_ramo_id, v_old_site
    FROM empresas WHERE id = p_id;

    UPDATE empresas
    SET cnpj          = p_cnpj,
        razao_social  = p_razao_social,
        nome_fantasia = p_nome_fantasia,
        descricao     = p_descricao,
        porte_id      = p_porte_id,
        ramo_id       = p_ramo_id,
        site          = p_site
    WHERE id = p_id;

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'cnpj', p_cnpj,
        'razao_social', p_razao_social,
        'nome_fantasia', p_nome_fantasia,
        'descricao', p_descricao,
        'porte_id', p_porte_id,
        'ramo_id', p_ramo_id,
        'site', p_site
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (@usuario_logado, 'empresas', p_id, 'UPDATE', v_dados_antigos, v_dados_novos);

END$$

CREATE PROCEDURE sp_empresas_delete(IN p_id INT)
BEGIN
    DECLARE v_old_cnpj VARCHAR(18);
    DECLARE v_old_razao_social VARCHAR(150);
    DECLARE v_old_nome_fantasia VARCHAR(150);
    DECLARE v_old_descricao TEXT;
    DECLARE v_old_porte_id INT;
    DECLARE v_old_ramo_id INT;
    DECLARE v_old_site VARCHAR(150);
    DECLARE v_dados_antigos JSON;
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM empresas WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empresa não encontrada';
    END IF;

    SELECT cnpj, razao_social, nome_fantasia, descricao, porte_id, ramo_id, site
    INTO v_old_cnpj, v_old_razao_social, v_old_nome_fantasia, v_old_descricao, v_old_porte_id, v_old_ramo_id, v_old_site
    FROM empresas WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'cnpj', v_old_cnpj,
        'razao_social', v_old_razao_social,
        'nome_fantasia', v_old_nome_fantasia,
        'descricao', v_old_descricao,
        'porte_id', v_old_porte_id,
        'ramo_id', v_old_ramo_id,
        'site', v_old_site
    );

    DELETE FROM empresas WHERE id = p_id;

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos)
    VALUES (@usuario_logado, 'empresas', p_id, 'DELETE', v_dados_antigos);

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
    DECLARE v_novo_id INT;
    DECLARE v_dados_novos JSON;

    INSERT INTO matchvagas.administradores(usuario_id, nivel, departamento_id, permissoes)
    VALUES (p_usuario_id,
            p_nivel,
            p_departamento_id,
            p_permissoes);

    SET v_novo_id = LAST_INSERT_ID();

    SET v_dados_novos = JSON_OBJECT(
        'id', v_novo_id,
        'usuario_id', p_usuario_id,
        'nivel', p_nivel,
        'departamento_id', p_departamento_id,
        'permissoes', p_permissoes
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_novos)
    VALUES (@usuario_logado, 'administradores', v_novo_id, 'INSERT', v_dados_novos);
END$$

CREATE PROCEDURE sp_administradores_update(
    IN p_id INT,
    IN p_usuario_id INT,
    IN p_nivel VARCHAR(50),
    IN p_departamento_id INT,
    IN p_permissoes TEXT
)
BEGIN
    DECLARE v_old_usuario_id INT;
    DECLARE v_old_nivel VARCHAR(50);
    DECLARE v_old_departamento_id INT;
    DECLARE v_old_permissoes TEXT;
    DECLARE v_dados_antigos JSON;
    DECLARE v_dados_novos JSON;
    DECLARE v_count INT;

    IF p_usuario_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'usuario_id inválido';
    END IF;

    IF p_departamento_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM departamentos WHERE id = p_departamento_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'departamento_id inválido';
    END IF;

    SELECT COUNT(*) INTO v_count FROM administradores WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Administrador não encontrado';
    END IF;

    SELECT usuario_id, nivel, departamento_id, permissoes
    INTO v_old_usuario_id, v_old_nivel, v_old_departamento_id, v_old_permissoes
    FROM administradores WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'usuario_id', v_old_usuario_id,
        'nivel', v_old_nivel,
        'departamento_id', v_old_departamento_id,
        'permissoes', v_old_permissoes
    );

    UPDATE matchvagas.administradores
    SET usuario_id      = p_usuario_id,
        nivel           = p_nivel,
        departamento_id = p_departamento_id,
        permissoes      = p_permissoes
    WHERE id = p_id;

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'usuario_id', p_usuario_id,
        'nivel', p_nivel,
        'departamento_id', p_departamento_id,
        'permissoes', p_permissoes
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (@usuario_logado, 'administradores', p_id, 'UPDATE', v_dados_antigos, v_dados_novos);

END$$

CREATE PROCEDURE sp_administradores_delete(IN p_id INT)
BEGIN
    DECLARE v_old_usuario_id INT;
    DECLARE v_old_nivel VARCHAR(50);
    DECLARE v_old_departamento_id INT;
    DECLARE v_old_permissoes TEXT;
    DECLARE v_dados_antigos JSON;
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM administradores WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Administrador não encontrado';
    END IF;

    SELECT usuario_id, nivel, departamento_id, permissoes
    INTO v_old_usuario_id, v_old_nivel, v_old_departamento_id, v_old_permissoes
    FROM administradores WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'usuario_id', v_old_usuario_id,
        'nivel', v_old_nivel,
        'departamento_id', v_old_departamento_id,
        'permissoes', v_old_permissoes
    );

    DELETE FROM administradores WHERE id = p_id;

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos)
    VALUES (@usuario_logado, 'administradores', p_id, 'DELETE', v_dados_antigos);
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
    IN p_empresa_id INT,
    IN p_titulo VARCHAR(255),
    IN p_descricao TEXT,
    IN p_requisito TEXT,
    IN p_tipo_vaga_id INT,
    IN p_modalidade_vaga_id INT,
    IN p_salario_min DECIMAL(10, 2),
    IN p_salario_max DECIMAL(10, 2),
    IN p_beneficios TEXT,
    IN p_carga_horaria VARCHAR(50),
    IN p_idade_minima INT,
    IN p_idade_maxima INT,
    IN p_nivel_escolaridade_minimo_id INT,
    IN p_area_atuacao VARCHAR(100),
    IN p_data_expiracao DATETIME,
    IN p_status_vaga_id INT,
    IN p_numero_vagas INT,
    IN p_cidade_id INT,
    OUT p_novo_id INT,
    OUT p_erro_mensagem VARCHAR(255)
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

    INSERT INTO vagas (empresa_id,
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
                       cidade_id)
    VALUES (p_empresa_id,
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
            p_cidade_id);

    SET p_novo_id = LAST_INSERT_ID();

    -- Preparar log (dados novos)
    SET v_dados_novos = JSON_OBJECT(
        'id',                   p_novo_id,
        'empresa_id',           p_empresa_id,
        'titulo',               TRIM(p_titulo),
        'descricao',            LEFT(p_descricao, 200),          -- limitar texto grande
        'requisito',            LEFT(p_requisito, 200),
        'tipo_vaga_id',         p_tipo_vaga_id,
        'modalidade_vaga_id',   p_modalidade_vaga_id,
        'salario_min',          p_salario_min,
        'salario_max',          p_salario_max,
        'beneficios',           LEFT(p_beneficios, 200),
        'carga_horaria',        p_carga_horaria,
        'cidade_id',            p_cidade_id,
        'status_vaga_id',       p_status_vaga_id,
        'data_publicacao',      CURRENT_TIMESTAMP,
        'data_expiracao',       p_data_expiracao,
        'numero_vagas',         COALESCE(p_numero_vagas, 1)
    );

    INSERT INTO logs_eventos (
        usuario_id,
        tabela_nome,
        registro_id,
        acao,
        descricao,
        dados_novos
    )
    VALUES (
        @usuario_logado,
        'vagas',
        p_novo_id,
        'INSERT',
        'Criação de nova vaga',
        v_dados_novos
    );

    COMMIT;

END $$


-- =============================================
-- Procedure: sp_vaga_atualizar
-- Descrição: Atualiza dados de uma vaga existente
-- =============================================
CREATE PROCEDURE sp_vaga_atualizar(
    IN p_id INT,
    IN p_titulo VARCHAR(255),
    IN p_descricao TEXT,
    IN p_requisito TEXT,
    IN p_tipo_vaga_id INT,
    IN p_modalidade_vaga_id INT,
    IN p_salario_min DECIMAL(10, 2),
    IN p_salario_max DECIMAL(10, 2),
    IN p_beneficios TEXT,
    IN p_carga_horaria VARCHAR(50),
    IN p_idade_minima INT,
    IN p_idade_maxima INT,
    IN p_nivel_escolaridade_minimo_id INT,
    IN p_area_atuacao VARCHAR(100),
    IN p_data_expiracao DATETIME,
    IN p_status_vaga_id INT,
    IN p_numero_vagas INT,
    IN p_cidade_id INT,
    OUT p_sucesso BOOLEAN,
    OUT p_erro_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_count                   INT DEFAULT 0;
    DECLARE v_old_titulo              VARCHAR(255);
    DECLARE v_old_descricao           TEXT;
    DECLARE v_old_requisito           TEXT;
    DECLARE v_old_tipo_vaga_id        INT;
    DECLARE v_old_modalidade_vaga_id  INT;
    DECLARE v_old_salario_min         DECIMAL(10,2);
    DECLARE v_old_salario_max         DECIMAL(10,2);
    DECLARE v_old_beneficios          TEXT;
    DECLARE v_old_carga_horaria       VARCHAR(50);
    DECLARE v_old_cidade_id           INT;
    DECLARE v_old_status_vaga_id      INT;
    DECLARE v_old_data_expiracao      DATETIME;
    DECLARE v_old_numero_vagas        INT;

    DECLARE v_dados_antigos           JSON;
    DECLARE v_dados_novos             JSON;

    SET p_sucesso = FALSE;
    SET p_erro_mensagem = NULL;

    SELECT COUNT(*) INTO v_count FROM vagas WHERE id = p_id;

    IF v_count = 0 THEN
        SET p_erro_mensagem = 'Vaga não encontrada';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_erro_mensagem;
    END IF;

    START TRANSACTION;

    UPDATE vagas
    SET titulo                       = TRIM(p_titulo),
        descricao                    = p_descricao,
        requisito                    = p_requisito,
        tipo_vaga_id                 = p_tipo_vaga_id,
        modalidade_vaga_id           = p_modalidade_vaga_id,
        salario_min                  = p_salario_min,
        salario_max                  = p_salario_max,
        beneficios                   = p_beneficios,
        carga_horaria                = p_carga_horaria,
        idade_minima                 = p_idade_minima,
        idade_maxima                 = p_idade_maxima,
        nivel_escolaridade_minimo_id = p_nivel_escolaridade_minimo_id,
        area_atuacao                 = TRIM(p_area_atuacao),
        data_expiracao               = p_data_expiracao,
        status_vaga_id               = p_status_vaga_id,
        numero_vagas                 = COALESCE(p_numero_vagas, numero_vagas),
        cidade_id                    = p_cidade_id,
        data_publicacao              = data_publicacao -- mantém a data original
    WHERE id = p_id;

    -- Preparar JSONs de log (limitando textos longos)
    SET v_dados_antigos = JSON_OBJECT(
        'id',                   p_id,
        'titulo',               v_old_titulo,
        'descricao',            LEFT(v_old_descricao, 200),
        'requisito',            LEFT(v_old_requisito, 200),
        'tipo_vaga_id',         v_old_tipo_vaga_id,
        'modalidade_vaga_id',   v_old_modalidade_vaga_id,
        'salario_min',          v_old_salario_min,
        'salario_max',          v_old_salario_max,
        'cidade_id',            v_old_cidade_id,
        'status_vaga_id',       v_old_status_vaga_id,
        'data_expiracao',       v_old_data_expiracao,
        'numero_vagas',         v_old_numero_vagas
    );

    SET v_dados_novos = JSON_OBJECT(
        'id',                   p_id,
        'titulo',               TRIM(p_titulo),
        'descricao',            LEFT(p_descricao, 200),
        'requisito',            LEFT(p_requisito, 200),
        'tipo_vaga_id',         p_tipo_vaga_id,
        'modalidade_vaga_id',   p_modalidade_vaga_id,
        'salario_min',          p_salario_min,
        'salario_max',          p_salario_max,
        'cidade_id',            p_cidade_id,
        'status_vaga_id',       p_status_vaga_id,
        'data_expiracao',       p_data_expiracao,
        'numero_vagas',         COALESCE(p_numero_vagas, v_old_numero_vagas)
    );

    INSERT INTO logs_eventos (
        usuario_id,
        tabela_nome,
        registro_id,
        acao,
        descricao,
        dados_antigos,
        dados_novos
    )
    VALUES (
        @usuario_logado,
        'vagas',
        p_id,
        'UPDATE',
        'Atualização de vaga',
        v_dados_antigos,
        v_dados_novos
    );

    SET p_sucesso = TRUE;
    COMMIT;

END $$


-- =============================================
-- Procedure: sp_vaga_excluir
-- Descrição: Remove uma vaga (soft ou hard delete)
-- =============================================
CREATE PROCEDURE sp_vaga_excluir(
    IN p_id INT,
    OUT p_sucesso BOOLEAN,
    OUT p_erro_mensagem VARCHAR(255)
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
    IN p_empresa_id INT, -- NULL = todas
    IN p_status_vaga_id INT, -- NULL = todos
    IN p_cidade_id INT, -- NULL = todas
    IN p_titulo_parcial VARCHAR(100), -- filtro LIKE
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    DECLARE v_limit INT DEFAULT 50;
    DECLARE v_offset INT DEFAULT 0;

    -- verifica se p_limit é NULL, se for usa o valor default
    IF p_limit IS NOT NULL THEN
        SET v_limit = p_limit;
    END IF;

    -- verifica se p_offset é NULL, se for usa o valor default
    IF p_offset IS NOT NULL THEN
        SET v_offset = p_offset;
    END IF;

    SELECT v.id,
           v.titulo,
           e.nome_fantasia AS empresa,
           tv.descricao    AS tipo_vaga,
           mv.descricao    AS modalidade,
           sv.descricao    AS status,
           v.salario_min,
           v.salario_max,
           v.numero_vagas,
           v.data_publicacao,
           cid.nome        AS cidade,
           est.uf
    FROM vagas v
             INNER JOIN empresas e ON e.id = v.empresa_id
             INNER JOIN tipos_vaga tv ON tv.id = v.tipo_vaga_id
             INNER JOIN modalidades mv ON mv.id = v.modalidade_vaga_id
             INNER JOIN status_vaga sv ON sv.id = v.status_vaga_id
             LEFT JOIN cidades cid ON cid.id = v.cidade_id
             LEFT JOIN estados est ON est.id = cid.estado_id

    WHERE 1 = 1
      AND (p_empresa_id IS NULL OR v.empresa_id = p_empresa_id)
      AND (p_status_vaga_id IS NULL OR v.status_vaga_id = p_status_vaga_id)
      AND (p_cidade_id IS NULL OR v.cidade_id = p_cidade_id)
      AND (p_titulo_parcial IS NULL OR v.titulo LIKE CONCAT('%', TRIM(p_titulo_parcial), '%'))

    ORDER BY v.data_publicacao DESC
    LIMIT p_limit OFFSET p_offset;

END $$

-- ====YASMIM====

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `enderecos`
-- =====================================================
BEGIN
    -- armazena os novos dados em um json
    DECLARE v_dados_novos ENDERECO;

    INSERT INTO endereco (id,)
    VALUES (p_id, p_lagradouro, p_numero_, p_completo, p_estado,
            p_cidade, p_bairro, p_cep);

    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = ENDERECO(
        'id', p_id,
        'lagradouro', p_lagradouro,
        'numero' , p_numero,
        'completo', p_completo,
        'estado', p_estado,
        'cidade', p_cidade,
        'bairro' , p_bairro,
        'cep', p_cep,
    );

    INSERT INTO logs_endereco (endereco_id, p_ladrouro, p_numero, p_completo, p_estado, p_cidade, p_bairro, p_cep)
    VALUES (@endereco_, 'endereco', p_id, 'INSERT','Operação INSERT', v_dados_novos);


END$$

-- ====YASMIM====

-- =====================================================
-- PROCEDURES PARA A TABELA `telefones`
-- =====================================================
DELIMITER $$
    BEGIN
    -- armazena os novos dados em um json
    DECLARE v_dados_novos ;

    INSERT INTO telefones ()
    VALUES (p_id,  p_numero, tipo_telefone, p_wpp);
    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = ENDERECO(
        'id', p_id,
        'numero' , p_numero,
        'tipo_telefone' , p_tipo_telefone,
        'wpp' , p_wpp,
    );

    INSERT INTO logs_eventos (telefone_id, p_numero, p_tipo_telefone, p_wpp)
    VALUES (@usuario_logado, 'endereco', p_id, 'INSERT','Operação INSERT', v_dados_novos);


END$$

DELIMITER ;

-- ====YASMIM====

-- =====================================================
-- PROCEDURES PARA A TABELA `tipo_notificacao`
-- =====================================================
DELIMITER $$
BEGIN
    -- armazena os novos dados em um json
    DECLARE v_dados_novos JSON;

    INSERT INTO tipo_notificacao ()
    VALUES (p_id, p_nome,);

    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'nome', p_nome,
    );

    INSERT INTO logs_eventos (id, nome)
    VALUES (@notificacao, 'tipo_notificacao', p_id, 'INSERT','Operação INSERT', v_dados_novos);


END$$

DELIMITER $$

CREATE PROCEDURE sp_experiencia_insert(
    IN  p_candidato_id INT,
    IN  p_empresa VARCHAR(255),
    IN  p_cargo VARCHAR(255),
    IN  p_descricao TEXT,
    IN  p_data_inicio DATE,
    IN  p_data_fim DATE,
    IN  p_empregador_atual TINYINT,   -- 0 = FALSE, 1 = TRUE
    IN  p_trabalho_remoto TINYINT,    -- 0 = FALSE, 1 = TRUE
    IN  p_finalizada TINYINT,         -- 0 = FALSE, 1 = TRUE
    OUT p_id BIGINT
)
BEGIN
    DECLARE v_dados_novos JSON;

    INSERT INTO experiencias (
        candidato_id,
        empresa,
        cargo,
        descricao,
        data_inicio,
        data_fim,
        empregador_atual,
        trabalho_remoto,
        finalizada
    ) VALUES (
        p_candidato_id,
        p_empresa,
        p_cargo,
        p_descricao,
        p_data_inicio,
        p_data_fim,
        p_empregador_atual,
        p_trabalho_remoto,
        p_finalizada
    );

    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'candidato_id', p_candidato_id,
        'empresa', p_empresa,
        'cargo', p_cargo,
        'descricao', p_descricao,
        'data_inicio', IF(p_data_inicio IS NULL, NULL, DATE_FORMAT(p_data_inicio, '%Y-%m-%d')),
        'data_fim', IF(p_data_fim IS NULL, NULL, DATE_FORMAT(p_data_fim, '%Y-%m-%d')),
        'empregador_atual', p_empregador_atual,
        'trabalho_remoto', p_trabalho_remoto,
        'finalizada', p_finalizada
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, descricao, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'experiencias', p_id, 'INSERT', 'Operação INSERT', v_dados_novos);
END$$

CREATE PROCEDURE sp_experiencia_update(
    IN p_id BIGINT,
    IN p_descricao TEXT,
    IN p_data_fim DATE,
    IN p_empregador_atual TINYINT,   -- 0 = FALSE, 1 = TRUE, NULL = manter (se quiser parcial, adapte)
    IN p_trabalho_remoto TINYINT,    -- 0 = FALSE, 1 = TRUE, NULL = manter
    IN p_finalizada TINYINT          -- 0 = FALSE, 1 = TRUE, NULL = manter
)
BEGIN
    -- dados antigos
    DECLARE v_old_candidato_id INT;
    DECLARE v_old_empresa VARCHAR(255);
    DECLARE v_old_cargo VARCHAR(255);
    DECLARE v_old_descricao TEXT;
    DECLARE v_old_data_inicio DATE;
    DECLARE v_old_data_fim DATE;
    DECLARE v_old_empregador_atual TINYINT;
    DECLARE v_old_trabalho_remoto TINYINT;
    DECLARE v_old_finalizada TINYINT;
    DECLARE v_dados_antigos JSON;
    DECLARE v_dados_novos JSON;
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM experiencias WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Experiência não encontrada';
    END IF;

    SELECT candidato_id, empresa, cargo, descricao, data_inicio, data_fim, empregador_atual, trabalho_remoto, finalizada
    INTO v_old_candidato_id, v_old_empresa, v_old_cargo, v_old_descricao, v_old_data_inicio, v_old_data_fim, v_old_empregador_atual, v_old_trabalho_remoto, v_old_finalizada
    FROM experiencias WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'candidato_id', v_old_candidato_id,
        'empresa', v_old_empresa,
        'cargo', v_old_cargo,
        'descricao', v_old_descricao,
        'data_inicio', IF(v_old_data_inicio IS NULL, NULL, DATE_FORMAT(v_old_data_inicio, '%Y-%m-%d')),
        'data_fim', IF(v_old_data_fim IS NULL, NULL, DATE_FORMAT(v_old_data_fim, '%Y-%m-%d')),
        'empregador_atual', v_old_empregador_atual,
        'trabalho_remoto', v_old_trabalho_remoto,
        'finalizada', v_old_finalizada
    );

    -- Atualiza (sobrescreve os campos informados)
    UPDATE experiencias
    SET
        descricao = p_descricao,
        data_fim = p_data_fim,
        empregador_atual = p_empregador_atual,
        trabalho_remoto = p_trabalho_remoto,
        finalizada = p_finalizada
    WHERE id = p_id;

    -- monta dados novos (busca estado atual)
    SELECT candidato_id, empresa, cargo, descricao, data_inicio, data_fim, empregador_atual, trabalho_remoto, finalizada
    INTO v_old_candidato_id, v_old_empresa, v_old_cargo, v_old_descricao, v_old_data_inicio, v_old_data_fim, v_old_empregador_atual, v_old_trabalho_remoto, v_old_finalizada
    FROM experiencias WHERE id = p_id;

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'candidato_id', v_old_candidato_id,
        'empresa', v_old_empresa,
        'cargo', v_old_cargo,
        'descricao', v_old_descricao,
        'data_inicio', IF(v_old_data_inicio IS NULL, NULL, DATE_FORMAT(v_old_data_inicio, '%Y-%m-%d')),
        'data_fim', IF(v_old_data_fim IS NULL, NULL, DATE_FORMAT(v_old_data_fim, '%Y-%m-%d')),
        'empregador_atual', v_old_empregador_atual,
        'trabalho_remoto', v_old_trabalho_remoto,
        'finalizada', v_old_finalizada
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'experiencias', p_id, 'UPDATE', v_dados_antigos, v_dados_novos);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_formacao_insert(
    IN  p_candidato_id INT,
    IN  p_instituicao VARCHAR(255),
    IN  p_curso VARCHAR(255),
    IN  p_nivel TINYINT,
    IN  p_situacao TINYINT,
    IN  p_data_inicio DATE,
    IN  p_data_conclusao DATE,
    OUT p_id BIGINT
)
BEGIN
    DECLARE v_dados_novos JSON;

    INSERT INTO formacoes (
        candidato_id,
        instituicao,
        curso,
        nivel,
        situacao,
        data_inicio,
        data_conclusao
    ) VALUES (
        p_candidato_id,
        p_instituicao,
        p_curso,
        p_nivel,
        p_situacao,
        p_data_inicio,
        p_data_conclusao
    );

    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'candidato_id', p_candidato_id,
        'instituicao', p_instituicao,
        'curso', p_curso,
        'nivel', p_nivel,
        'situacao', p_situacao,
        'data_inicio', IF(p_data_inicio IS NULL, NULL, DATE_FORMAT(p_data_inicio, '%Y-%m-%d')),
        'data_conclusao', IF(p_data_conclusao IS NULL, NULL, DATE_FORMAT(p_data_conclusao, '%Y-%m-%d'))
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, descricao, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'formacoes', p_id, 'INSERT', 'Operação INSERT', v_dados_novos);
END$$

CREATE PROCEDURE sp_formacao_update(
    IN p_id BIGINT,
    IN p_candidato_id INT,
    IN p_instituicao VARCHAR(255),
    IN p_curso VARCHAR(255),
    IN p_nivel TINYINT,
    IN p_situacao TINYINT,
    IN p_data_inicio DATE,
    IN p_data_conclusao DATE
)
BEGIN
    -- dados antigos
    DECLARE v_old_candidato_id INT;
    DECLARE v_old_instituicao VARCHAR(255);
    DECLARE v_old_curso VARCHAR(255);
    DECLARE v_old_nivel TINYINT;
    DECLARE v_old_situacao TINYINT;
    DECLARE v_old_data_inicio DATE;
    DECLARE v_old_data_conclusao DATE;
    DECLARE v_dados_antigos JSON;
    DECLARE v_dados_novos JSON;
    DECLARE v_count INT;

    -- Verifica existência
    SELECT COUNT(*) INTO v_count FROM formacoes WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formação não encontrada';
    END IF;

    -- Busca valores antigos
    SELECT candidato_id, instituicao, curso, nivel, situacao, data_inicio, data_conclusao
    INTO v_old_candidato_id, v_old_instituicao, v_old_curso, v_old_nivel, v_old_situacao, v_old_data_inicio, v_old_data_conclusao
    FROM formacoes WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'candidato_id', v_old_candidato_id,
        'instituicao', v_old_instituicao,
        'curso', v_old_curso,
        'nivel', v_old_nivel,
        'situacao', v_old_situacao,
        'data_inicio', IF(v_old_data_inicio IS NULL, NULL, DATE_FORMAT(v_old_data_inicio, '%Y-%m-%d')),
        'data_conclusao', IF(v_old_data_conclusao IS NULL, NULL, DATE_FORMAT(v_old_data_conclusao, '%Y-%m-%d'))
    );

    -- Validação de datas quando ambas fornecidas
    IF p_data_inicio IS NOT NULL AND p_data_conclusao IS NOT NULL THEN
        IF p_data_inicio > p_data_conclusao THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'data_inicio nao pode ser maior que data_conclusao';
        END IF;
    END IF;

    -- Atualiza (sobrescreve todos os campos informados)
    UPDATE formacoes
    SET
        candidato_id = p_candidato_id,
        instituicao = p_instituicao,
        curso = p_curso,
        nivel = p_nivel,
        situacao = p_situacao,
        data_inicio = p_data_inicio,
        data_conclusao = p_data_conclusao
    WHERE id = p_id;

    -- Monta dados novos (estado atual após update)
    SELECT candidato_id, instituicao, curso, nivel, situacao, data_inicio, data_conclusao
    INTO v_old_candidato_id, v_old_instituicao, v_old_curso, v_old_nivel, v_old_situacao, v_old_data_inicio, v_old_data_conclusao
    FROM formacoes WHERE id = p_id;

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'candidato_id', v_old_candidato_id,
        'instituicao', v_old_instituicao,
        'curso', v_old_curso,
        'nivel', v_old_nivel,
        'situacao', v_old_situacao,
        'data_inicio', IF(v_old_data_inicio IS NULL, NULL, DATE_FORMAT(v_old_data_inicio, '%Y-%m-%d')),
        'data_conclusao', IF(v_old_data_conclusao IS NULL, NULL, DATE_FORMAT(v_old_data_conclusao, '%Y-%m-%d'))
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'formacoes', p_id, 'UPDATE', v_dados_antigos, v_dados_novos);
END$$

DELIMITER ;

   DELIMITER $$

-- Procedure sp_candidatura_insert
CREATE PROCEDURE sp_candidatura_insert(
    IN  p_id INT,                   
    IN  p_candidato_id INT,
    IN  p_vaga_id INT,
    IN  p_data_candidatura DATETIME,
    IN  p_data_atualizacao DATETIME,
    IN  p_status_id INT,
    OUT p_new_id BIGINT
)
BEGIN
    DECLARE v_log_id BIGINT DEFAULT NULL;
    DECLARE v_err_msg TEXT DEFAULT NULL;
    DECLARE v_sqlstate CHAR(5) DEFAULT NULL;
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_dados_novos JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_err_msg = MESSAGE_TEXT;
        ROLLBACK;
        IF v_log_id IS NOT NULL THEN
            UPDATE procedures_log_table
            SET status = 'FAILED',
                error_message = v_err_msg,
                finished_at = NOW()
            WHERE id = v_log_id;
        END IF;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Insere log de início
    INSERT INTO procedures_log_table (procedure_name, status, input_params, created_by)
    VALUES (
      'sp_candidatura_insert',
      'STARTED',
      JSON_OBJECT(
        'p_id', p_id,
        'p_candidato_id', p_candidato_id,
        'p_vaga_id', p_vaga_id,
        'p_data_candidatura', IF(p_data_candidatura IS NULL, NULL, DATE_FORMAT(p_data_candidatura, '%Y-%m-%d %H:%i:%s')),
        'p_data_atualizacao', IF(p_data_atualizacao IS NULL, NULL, DATE_FORMAT(p_data_atualizacao, '%Y-%m-%d %H:%i:%s')),
        'p_status_id', p_status_id
      ),
      @usuario_logado
    );
    SET v_log_id = LAST_INSERT_ID();

    -- Validações básicas: candidato e vaga (se existirem tabelas)
    IF p_candidato_id IS NULL OR p_vaga_id IS NULL THEN
        UPDATE procedures_log_table
        SET status = 'FAILED',
            error_message = 'candidato_id e vaga_id sao obrigatorios',
            finished_at = NOW()
        WHERE id = v_log_id;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'candidato_id e vaga_id sao obrigatorios';
    END IF;

    IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'candidatos') > 0 THEN
        SELECT COUNT(*) INTO v_count FROM candidatos WHERE id = p_candidato_id;
        IF v_count = 0 THEN
            UPDATE procedures_log_table
            SET status = 'FAILED',
                error_message = 'candidato_id nao encontrado',
                finished_at = NOW()
            WHERE id = v_log_id;
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'candidato_id nao encontrado';
        END IF;
    END IF;

    IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vagas') > 0 THEN
        SELECT COUNT(*) INTO v_count FROM vagas WHERE id = p_vaga_id;
        IF v_count = 0 THEN
            UPDATE procedures_log_table
            SET status = 'FAILED',
                error_message = 'vaga_id nao encontrado',
                finished_at = NOW()
            WHERE id = v_log_id;
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'vaga_id nao encontrado';
        END IF;
    END IF;

    -- Normaliza data_atualizacao se nao informada
    IF p_data_atualizacao IS NULL THEN
        SET p_data_atualizacao = NOW();
    END IF;

    -- Inserção (respeita p_id se informado)
    IF p_id IS NULL THEN
        INSERT INTO candidaturas (candidato_id, vaga_id, data_candidatura, data_atualizacao, status_id)
        VALUES (p_candidato_id, p_vaga_id, p_data_candidatura, p_data_atualizacao, p_status_id);
        SET p_new_id = LAST_INSERT_ID();
    ELSE
        -- evita conflito de PK
        SELECT COUNT(*) INTO v_count FROM candidaturas WHERE id = p_id;
        IF v_count > 0 THEN
            UPDATE procedures_log_table
            SET status = 'FAILED',
                error_message = 'ID informado ja existe',
                finished_at = NOW()
            WHERE id = v_log_id;
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID informado ja existe';
        END IF;
        INSERT INTO candidaturas (id, candidato_id, vaga_id, data_candidatura, data_atualizacao, status_id)
        VALUES (p_id, p_candidato_id, p_vaga_id, p_data_candidatura, p_data_atualizacao, p_status_id);
        SET p_new_id = p_id;
    END IF;

    -- Monta JSON de dados novos
    SET v_dados_novos = JSON_OBJECT(
        'id', p_new_id,
        'candidato_id', p_candidato_id,
        'vaga_id', p_vaga_id,
        'data_candidatura', IF(p_data_candidatura IS NULL, NULL, DATE_FORMAT(p_data_candidatura, '%Y-%m-%d %H:%i:%s')),
        'data_atualizacao', IF(p_data_atualizacao IS NULL, NULL, DATE_FORMAT(p_data_atualizacao, '%Y-%m-%d %H:%i:%s')),
        'status_id', p_status_id
    );

    -- Insere auditoria
    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'candidaturas', p_new_id, 'INSERT', v_dados_novos);

    -- Atualiza log de procedure
    UPDATE procedures_log_table
    SET status = 'COMPLETED',
        result = JSON_OBJECT('action', 'inserted', 'id', p_new_id),
        finished_at = NOW()
    WHERE id = v_log_id;

    COMMIT;
END$$

-- Procedure sp_candidatura_update_by_id (retorna old/new)
CREATE PROCEDURE sp_candidatura_update_by_id(
    IN  p_id BIGINT,
    IN  p_data_candidatura DATETIME,
    IN  p_data_atualizacao DATETIME,
    IN  p_status_id INT,
    IN  p_overwrite TINYINT,          -- 0 = parcial (mantem valores quando NULL), 1 = sobrescrever
    IN  p_changed_by VARCHAR(100),    -- opcional: usuário que fez a alteração
    OUT p_affected_rows INT
)
BEGIN
    DECLARE v_log_id BIGINT DEFAULT NULL;
    DECLARE v_err_msg TEXT DEFAULT NULL;
    DECLARE v_sqlstate CHAR(5) DEFAULT NULL;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_old_candidato_id INT;
    DECLARE v_old_vaga_id INT;
    DECLARE v_old_data_candidatura DATETIME;
    DECLARE v_old_data_atualizacao DATETIME;
    DECLARE v_old_status_id INT;
    DECLARE v_old_json JSON;
    DECLARE v_new_json JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_err_msg = MESSAGE_TEXT;
        ROLLBACK;
        IF v_log_id IS NOT NULL THEN
            UPDATE procedures_log_table
            SET status = 'FAILED',
                error_message = v_err_msg,
                finished_at = NOW()
            WHERE id = v_log_id;
        END IF;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Insere log de início
    INSERT INTO procedures_log_table (procedure_name, status, input_params, created_by)
    VALUES (
      'sp_candidatura_update_by_id',
      'STARTED',
      JSON_OBJECT(
        'p_id', p_id,
        'p_data_candidatura', IF(p_data_candidatura IS NULL, NULL, DATE_FORMAT(p_data_candidatura, '%Y-%m-%d %H:%i:%s')),
        'p_data_atualizacao', IF(p_data_atualizacao IS NULL, NULL, DATE_FORMAT(p_data_atualizacao, '%Y-%m-%d %H:%i:%s')),
        'p_status_id', p_status_id,
        'p_overwrite', p_overwrite
      ),
      COALESCE(p_changed_by, @usuario_logado)
    );
    SET v_log_id = LAST_INSERT_ID();

    -- Verifica existência
    SELECT COUNT(*) INTO v_exists FROM candidaturas WHERE id = p_id;
    IF v_exists = 0 THEN
        UPDATE procedures_log_table
        SET status = 'FAILED',
            error_message = 'Candidatura nao encontrada',
            finished_at = NOW()
        WHERE id = v_log_id;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Candidatura nao encontrada';
    END IF;

    -- Busca valores antigos
    SELECT candidato_id, vaga_id, data_candidatura, data_atualizacao, status_id
    INTO v_old_candidato_id, v_old_vaga_id, v_old_data_candidatura, v_old_data_atualizacao, v_old_status_id
    FROM candidaturas WHERE id = p_id LIMIT 1;

    SET v_old_json = JSON_OBJECT(
        'id', p_id,
        'candidato_id', v_old_candidato_id,
        'vaga_id', v_old_vaga_id,
        'data_candidatura', IF(v_old_data_candidatura IS NULL, NULL, DATE_FORMAT(v_old_data_candidatura, '%Y-%m-%d %H:%i:%s')),
        'data_atualizacao', IF(v_old_data_atualizacao IS NULL, NULL, DATE_FORMAT(v_old_data_atualizacao, '%Y-%m-%d %H:%i:%s')),
        'status_id', v_old_status_id
    );

    -- Validação de datas quando ambas fornecidas
    IF p_data_candidatura IS NOT NULL AND p_data_atualizacao IS NOT NULL THEN
        IF p_data_candidatura > p_data_atualizacao THEN
            UPDATE procedures_log_table
            SET status = 'FAILED',
                error_message = 'data_candidatura nao pode ser maior que data_atualizacao',
                finished_at = NOW()
            WHERE id = v_log_id;
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'data_candidatura nao pode ser maior que data_atualizacao';
        END IF;
    END IF;

    -- Atualização (parcial ou overwrite)
    IF p_overwrite = 1 THEN
        UPDATE candidaturas
        SET
            data_candidatura = p_data_candidatura,
            data_atualizacao = p_data_atualizacao,
            status_id = p_status_id
        WHERE id = p_id;
    ELSE
        UPDATE candidaturas
        SET
            data_candidatura = COALESCE(p_data_candidatura, data_candidatura),
            data_atualizacao = COALESCE(p_data_atualizacao, data_atualizacao),
            status_id = COALESCE(p_status_id, status_id)
        WHERE id = p_id;
    END IF;

    SET p_affected_rows = ROW_COUNT();

    -- Busca valores novos
    SELECT id, candidato_id, vaga_id, data_candidatura, data_atualizacao, status_id
    INTO @new_id, @new_candidato_id, @new_vaga_id, @new_data_candidatura, @new_data_atualizacao, @new_status_id
    FROM candidaturas WHERE id = p_id LIMIT 1;

    SET v_new_json = JSON_OBJECT(
        'id', @new_id,
        'candidato_id', @new_candidato_id,
        'vaga_id', @new_vaga_id,
        'data_candidatura', IF(@new_data_candidatura IS NULL, NULL, DATE_FORMAT(@new_data_candidatura, '%Y-%m-%d %H:%i:%s')),
        'data_atualizacao', IF(@new_data_atualizacao IS NULL, NULL, DATE_FORMAT(@new_data_atualizacao, '%Y-%m-%d %H:%i:%s')),
        'status_id', @new_status_id
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (COALESCE(p_changed_by, @usuario_logado), 'candidaturas', p_id, 'UPDATE', v_old_json, v_new_json);

    -- Atualiza log de procedure
    UPDATE procedures_log_table
    SET status = 'COMPLETED',
        result = JSON_OBJECT('action', 'updated', 'id', p_id, 'affected_rows', p_affected_rows),
        finished_at = NOW()
    WHERE id = v_log_id;

    -- Retorna result sets: old_values e new_values
    SELECT JSON_PRETTY(v_old_json) AS old_values;
    SELECT JSON_PRETTY(v_new_json) AS new_values;

    COMMIT;
END$$

DELIMITER ;


-- esse é um comentário de teste

