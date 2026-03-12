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
    SET p_id = LAST_INSERT_ID();
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
    SET nome = p_nome,
        email = p_email,
        senha_hash = p_senha_hash,
        dataNascimento = p_dataNascimento,
        idade = p_idade,
        ativo = p_ativo,
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
    SET cnpj = p_cnpj,
        razao_social = p_razao_social,
        nome_fantasia = p_nome_fantasia,
        descricao = p_descricao,
        porte_id = p_porte_id,
        ramo_id = p_ramo_id,
        site = p_site
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
-- PROCEDURES PARA A TABELA `candidatos`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_candidatos_insert(
    IN p_cpf VARCHAR(20),
    IN p_endereco_id INT,
    IN p_objetivo_profissional TEXT,
    IN p_pretensao_salarial NUMERIC(12,2),
    IN p_disponibilidade VARCHAR(100),
    IN p_usuario_id INT,
    OUT p_id INT
)
BEGIN
    -- Verifica se usuario_id existe
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'usuario_id não encontrado';
    END IF;
    -- Verifica se endereco_id existe (se informado)
    IF p_endereco_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM enderecos WHERE id = p_endereco_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'endereco_id inválido';
    END IF;

    INSERT INTO candidatos (cpf, endereco_id, objetivo_profissional, pretensao_salarial, disponibilidade, usuario_id)
    VALUES (p_cpf, p_endereco_id, p_objetivo_profissional, p_pretensao_salarial, p_disponibilidade, p_usuario_id);
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_candidatos_update(
    IN p_id INT,
    IN p_cpf VARCHAR(20),
    IN p_endereco_id INT,
    IN p_objetivo_profissional TEXT,
    IN p_pretensao_salarial NUMERIC(12,2),
    IN p_disponibilidade VARCHAR(100)
)
BEGIN
    IF p_endereco_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM enderecos WHERE id = p_endereco_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'endereco_id inválido';
    END IF;

    UPDATE candidatos
    SET cpf = p_cpf,
        endereco_id = p_endereco_id,
        objetivo_profissional = p_objetivo_profissional,
        pretensao_salarial = p_pretensao_salarial,
        disponibilidade = p_disponibilidade
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_candidatos_delete(IN p_id INT)
BEGIN
    DELETE FROM candidatos WHERE id = p_id;
END$$

CREATE PROCEDURE sp_candidatos_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM candidatos WHERE id = p_id;
END$$

CREATE PROCEDURE sp_candidatos_get_by_usuario_id(IN p_usuario_id INT)
BEGIN
    SELECT * FROM candidatos WHERE usuario_id = p_usuario_id;
END$$

CREATE PROCEDURE sp_candidatos_list_all()
BEGIN
    SELECT * FROM candidatos;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `vagas`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_vagas_insert(
    IN p_empresa_id INT,
    IN p_titulo VARCHAR(255),
    IN p_descricao TEXT,
    IN p_requisito TEXT,
    IN p_tipo_vaga_id INT,
    IN p_modalidade_vaga_id INT,
    IN p_salario_min DECIMAL(10,2),
    IN p_salario_max DECIMAL(10,2),
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
    OUT p_id INT
)
BEGIN
    -- Validações de chaves estrangeiras
    IF NOT EXISTS (SELECT 1 FROM empresas WHERE id = p_empresa_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'empresa_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tipos_vaga WHERE id = p_tipo_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_vaga_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM modalidades WHERE id = p_modalidade_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'modalidade_vaga_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM status_vaga WHERE id = p_status_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'status_vaga_id inválido';
    END IF;
    IF p_nivel_escolaridade_minimo_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM niveis_escolaridade WHERE id = p_nivel_escolaridade_minimo_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'nivel_escolaridade_minimo_id inválido';
    END IF;
    IF p_cidade_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cidades WHERE id = p_cidade_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'cidade_id inválido';
    END IF;

    INSERT INTO vagas (
        empresa_id, titulo, descricao, requisito, tipo_vaga_id, modalidade_vaga_id,
        salario_min, salario_max, beneficios, carga_horaria, idade_minima, idade_maxima,
        nivel_escolaridade_minimo_id, area_atuacao, data_expiracao, status_vaga_id,
        numero_vagas, cidade_id
    ) VALUES (
        p_empresa_id, p_titulo, p_descricao, p_requisito, p_tipo_vaga_id, p_modalidade_vaga_id,
        p_salario_min, p_salario_max, p_beneficios, p_carga_horaria, p_idade_minima, p_idade_maxima,
        p_nivel_escolaridade_minimo_id, p_area_atuacao, p_data_expiracao, p_status_vaga_id,
        p_numero_vagas, p_cidade_id
    );
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_vagas_update(
    IN p_id INT,
    IN p_empresa_id INT,
    IN p_titulo VARCHAR(255),
    IN p_descricao TEXT,
    IN p_requisito TEXT,
    IN p_tipo_vaga_id INT,
    IN p_modalidade_vaga_id INT,
    IN p_salario_min DECIMAL(10,2),
    IN p_salario_max DECIMAL(10,2),
    IN p_beneficios TEXT,
    IN p_carga_horaria VARCHAR(50),
    IN p_idade_minima INT,
    IN p_idade_maxima INT,
    IN p_nivel_escolaridade_minimo_id INT,
    IN p_area_atuacao VARCHAR(100),
    IN p_data_expiracao DATETIME,
    IN p_status_vaga_id INT,
    IN p_numero_vagas INT,
    IN p_cidade_id INT
)
BEGIN
    -- Validações (idempotentes)
    IF NOT EXISTS (SELECT 1 FROM empresas WHERE id = p_empresa_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'empresa_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tipos_vaga WHERE id = p_tipo_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_vaga_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM modalidades WHERE id = p_modalidade_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'modalidade_vaga_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM status_vaga WHERE id = p_status_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'status_vaga_id inválido';
    END IF;
    IF p_nivel_escolaridade_minimo_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM niveis_escolaridade WHERE id = p_nivel_escolaridade_minimo_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'nivel_escolaridade_minimo_id inválido';
    END IF;
    IF p_cidade_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cidades WHERE id = p_cidade_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'cidade_id inválido';
    END IF;

    UPDATE vagas
    SET empresa_id = p_empresa_id,
        titulo = p_titulo,
        descricao = p_descricao,
        requisito = p_requisito,
        tipo_vaga_id = p_tipo_vaga_id,
        modalidade_vaga_id = p_modalidade_vaga_id,
        salario_min = p_salario_min,
        salario_max = p_salario_max,
        beneficios = p_beneficios,
        carga_horaria = p_carga_horaria,
        idade_minima = p_idade_minima,
        idade_maxima = p_idade_maxima,
        nivel_escolaridade_minimo_id = p_nivel_escolaridade_minimo_id,
        area_atuacao = p_area_atuacao,
        data_expiracao = p_data_expiracao,
        status_vaga_id = p_status_vaga_id,
        numero_vagas = p_numero_vagas,
        cidade_id = p_cidade_id
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_vagas_delete(IN p_id INT)
BEGIN
    DELETE FROM vagas WHERE id = p_id;
END$$

CREATE PROCEDURE sp_vagas_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM vagas WHERE id = p_id;
END$$

CREATE PROCEDURE sp_vagas_list_all()
BEGIN
    SELECT * FROM vagas;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `candidaturas`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_candidaturas_insert(
    IN p_candidato_id INT,
    IN p_vaga_id INT,
    IN p_status_id INT,
    OUT p_id INT
)
BEGIN
    -- Verifica duplicidade (chave única)
    IF EXISTS (SELECT 1 FROM candidaturas WHERE candidato_id = p_candidato_id AND vaga_id = p_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Candidatura já existe para este candidato e vaga';
    END IF;
    -- Valida chaves estrangeiras
    IF NOT EXISTS (SELECT 1 FROM candidatos WHERE id = p_candidato_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'candidato_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM vagas WHERE id = p_vaga_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'vaga_id inválido';
    END IF;
    IF p_status_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM status_candidatura WHERE id = p_status_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'status_id inválido';
    END IF;

    INSERT INTO candidaturas (id, candidato_id, vaga_id, data_candidatura, data_atualizacao, status_id)
    VALUES (DEFAULT, p_candidato_id, p_vaga_id, DEFAULT, NULL, p_status_id);
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_candidaturas_update(
    IN p_id INT,
    IN p_status_id INT,
    IN p_data_atualizacao TIMESTAMP
)
BEGIN
    IF p_status_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM status_candidatura WHERE id = p_status_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'status_id inválido';
    END IF;

    UPDATE candidaturas
    SET status_id = p_status_id,
        data_atualizacao = IFNULL(p_data_atualizacao, CURRENT_TIMESTAMP)
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_candidaturas_delete(IN p_id INT)
BEGIN
    DELETE FROM candidaturas WHERE id = p_id;
END$$

CREATE PROCEDURE sp_candidaturas_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM candidaturas WHERE id = p_id;
END$$

CREATE PROCEDURE sp_candidaturas_list_all()
BEGIN
    SELECT * FROM candidaturas;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `enderecos`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_enderecos_insert(
    IN p_logradouro VARCHAR(255),
    IN p_numero VARCHAR(20),
    IN p_complemento VARCHAR(100),
    IN p_estado INT,
    IN p_cidade INT,
    IN p_bairro VARCHAR(100),
    IN p_cep VARCHAR(9),
    OUT p_id INT
)
BEGIN
    IF p_estado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM estados WHERE id = p_estado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'estado inválido';
    END IF;
    IF p_cidade IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cidades WHERE id = p_cidade) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'cidade inválida';
    END IF;

    INSERT INTO enderecos (logradouro, numero, complemento, estado, cidade, bairro, cep)
    VALUES (p_logradouro, p_numero, p_complemento, p_estado, p_cidade, p_bairro, p_cep);
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_enderecos_update(
    IN p_id INT,
    IN p_logradouro VARCHAR(255),
    IN p_numero VARCHAR(20),
    IN p_complemento VARCHAR(100),
    IN p_estado INT,
    IN p_cidade INT,
    IN p_bairro VARCHAR(100),
    IN p_cep VARCHAR(9)
)
BEGIN
    IF p_estado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM estados WHERE id = p_estado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'estado inválido';
    END IF;
    IF p_cidade IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cidades WHERE id = p_cidade) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'cidade inválida';
    END IF;

    UPDATE enderecos
    SET logradouro = p_logradouro,
        numero = p_numero,
        complemento = p_complemento,
        estado = p_estado,
        cidade = p_cidade,
        bairro = p_bairro,
        cep = p_cep
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

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA A TABELA `telefones`
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_telefones_insert(
    IN p_numero VARCHAR(15),
    IN p_tipo_telefone INT,
    IN p_wpp BOOLEAN,
    OUT p_id INT
)
BEGIN
    IF p_tipo_telefone IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tipos_telefone WHERE id = p_tipo_telefone) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_telefone inválido';
    END IF;

    INSERT INTO telefones (numero, tipo_telefone, wpp)
    VALUES (p_numero, p_tipo_telefone, p_wpp);
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_telefones_update(
    IN p_id INT,
    IN p_numero VARCHAR(15),
    IN p_tipo_telefone INT,
    IN p_wpp BOOLEAN
)
BEGIN
    IF p_tipo_telefone IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tipos_telefone WHERE id = p_tipo_telefone) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_telefone inválido';
    END IF;

    UPDATE telefones
    SET numero = p_numero,
        tipo_telefone = p_tipo_telefone,
        wpp = p_wpp
    WHERE id = p_id;
END$$

CREATE PROCEDURE sp_telefones_delete(IN p_id INT)
BEGIN
    DELETE FROM telefones WHERE id = p_id;
END$$

CREATE PROCEDURE sp_telefones_get_by_id(IN p_id INT)
BEGIN
    SELECT * FROM telefones WHERE id = p_id;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA AS TABELAS DE ASSOCIAÇÃO (telefones_usuario / telefones_empresa)
-- =====================================================
DELIMITER $$

CREATE PROCEDURE sp_telefones_usuario_insert(
    IN p_usuario_id INT,
    IN p_telefone_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'usuario_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM telefones WHERE id = p_telefone_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'telefone_id inválido';
    END IF;
    IF EXISTS (SELECT 1 FROM telefones_usuario WHERE usuario_id = p_usuario_id AND telefone_id = p_telefone_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'associação já existe';
    END IF;

    INSERT INTO telefones_usuario (usuario_id, telefone_id) VALUES (p_usuario_id, p_telefone_id);
END$$

CREATE PROCEDURE sp_telefones_usuario_delete(IN p_usuario_id INT, IN p_telefone_id INT)
BEGIN
    DELETE FROM telefones_usuario WHERE usuario_id = p_usuario_id AND telefone_id = p_telefone_id;
END$$

CREATE PROCEDURE sp_telefones_empresa_insert(
    IN p_empresa_id INT,
    IN p_telefone_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM empresas WHERE id = p_empresa_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'empresa_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM telefones WHERE id = p_telefone_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'telefone_id inválido';
    END IF;
    IF EXISTS (SELECT 1 FROM telefones_empresa WHERE empresa_id = p_empresa_id AND telefone_id = p_telefone_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'associação já existe';
    END IF;

    INSERT INTO telefones_empresa (empresa_id, telefone_id) VALUES (p_empresa_id, p_telefone_id);
END$$

CREATE PROCEDURE sp_telefones_empresa_delete(IN p_empresa_id INT, IN p_telefone_id INT)
BEGIN
    DELETE FROM telefones_empresa WHERE empresa_id = p_empresa_id AND telefone_id = p_telefone_id;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURES PARA TABELAS AUXILIARES (opcional)
-- =====================================================
DELIMITER $$

-- Exemplo: formacoes
CREATE PROCEDURE sp_formacoes_insert(
    IN p_candidato_id INT,
    IN p_instituicao VARCHAR(200),
    IN p_curso VARCHAR(200),
    IN p_nivel INT,
    IN p_situacao INT,
    IN p_data_inicio DATE,
    IN p_data_conclusao DATE,
    OUT p_id BIGINT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM candidatos WHERE id = p_candidato_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'candidato_id inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM niveis_escolaridade WHERE id = p_nivel) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'nível inválido';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM status_formacao WHERE id = p_situacao) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'situação inválida';
    END IF;

    INSERT INTO formacoes (candidato_id, instituicao, curso, nivel, situacao, data_inicio, data_conclusao)
    VALUES (p_candidato_id, p_instituicao, p_curso, p_nivel, p_situacao, p_data_inicio, p_data_conclusao);
    SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_experiencias_insert(
    IN p_candidato_id INT,
    IN p_empresa VARCHAR(255),
    IN p_cargo VARCHAR(150),
    IN p_descricao TEXT,
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    IN p_empregador_atual BOOLEAN,
    IN p_trabalho_remoto BOOLEAN,
    IN p_finalizada BOOLEAN,
    OUT p_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM candidatos WHERE id = p_candidato_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'candidato_id inválido';
    END IF;

    INSERT INTO experiencias (candidato_id, empresa, cargo, descricao, data_inicio, data_fim, empregador_atual, trabalho_remoto, finalizada)
    VALUES (p_candidato_id, p_empresa, p_cargo, p_descricao, p_data_inicio, p_data_fim, p_empregador_atual, p_trabalho_remoto, p_finalizada);
    SET p_id = LAST_INSERT_ID();
END$$

DELIMITER ;
