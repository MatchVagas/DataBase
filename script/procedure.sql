DELIMITER $$

CREATE PROCEDURE sp_candidato_insert(
    IN  p_cpf VARCHAR(20),
    IN  p_endereco_id INT,
    IN  p_objetivo_profissional TEXT,
    IN  p_pretensao_salarial DECIMAL(10,2),
    IN  p_disponibilidade VARCHAR(50),
    IN  p_usuario_id INT,
    OUT p_id INT
)
BEGIN
    DECLARE v_dados_novos JSON;

    INSERT INTO candidatos (cpf, endereco_id, objetivo_profissional, pretensao_salarial, disponibilidade, usuario_id)
    VALUES (p_cpf, p_endereco_id, p_objetivo_profissional, p_pretensao_salarial, p_disponibilidade, p_usuario_id);

    SET p_id = LAST_INSERT_ID();

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'cpf', p_cpf,
        'endereco_id', p_endereco_id,
        'objetivo_profissional', p_objetivo_profissional,
        'pretensao_salarial', p_pretensao_salarial,
        'disponibilidade', p_disponibilidade,
        'usuario_id', p_usuario_id
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, descricao, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'candidatos', p_id, 'INSERT', 'Operação INSERT', v_dados_novos);
END$$

CREATE PROCEDURE sp_candidato_update(
    IN p_id INT,
    IN p_cpf VARCHAR(20),
    IN p_endereco_id INT,
    IN p_objetivo_profissional TEXT,
    IN p_pretensao_salarial DECIMAL(10,2),
    IN p_disponibilidade VARCHAR(50),
    IN p_usuario_id INT
)
BEGIN
    -- dados antigos
    DECLARE v_old_cpf VARCHAR(20);
    DECLARE v_old_endereco_id INT;
    DECLARE v_old_objetivo_profissional TEXT;
    DECLARE v_old_pretensao_salarial DECIMAL(10,2);
    DECLARE v_old_disponibilidade VARCHAR(50);
    DECLARE v_old_usuario_id INT;
    DECLARE v_dados_antigos JSON;
    DECLARE v_dados_novos JSON;
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM candidatos WHERE id = p_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Candidato não encontrado';
    END IF;

    SELECT cpf, endereco_id, objetivo_profissional, pretensao_salarial, disponibilidade, usuario_id
    INTO v_old_cpf, v_old_endereco_id, v_old_objetivo_profissional, v_old_pretensao_salarial, v_old_disponibilidade, v_old_usuario_id
    FROM candidatos WHERE id = p_id;

    SET v_dados_antigos = JSON_OBJECT(
        'id', p_id,
        'cpf', v_old_cpf,
        'endereco_id', v_old_endereco_id,
        'objetivo_profissional', v_old_objetivo_profissional,
        'pretensao_salarial', v_old_pretensao_salarial,
        'disponibilidade', v_old_disponibilidade,
        'usuario_id', v_old_usuario_id
    );

    UPDATE candidatos
    SET cpf = p_cpf,
        endereco_id = p_endereco_id,
        objetivo_profissional = p_objetivo_profissional,
        pretensao_salarial = p_pretensao_salarial,
        disponibilidade = p_disponibilidade,
        usuario_id = p_usuario_id
    WHERE id = p_id;

    SET v_dados_novos = JSON_OBJECT(
        'id', p_id,
        'cpf', p_cpf,
        'endereco_id', p_endereco_id,
        'objetivo_profissional', p_objetivo_profissional,
        'pretensao_salarial', p_pretensao_salarial,
        'disponibilidade', p_disponibilidade,
        'usuario_id', p_usuario_id
    );

    INSERT INTO logs_eventos (usuario_id, tabela_nome, registro_id, acao, dados_antigos, dados_novos)
    VALUES (COALESCE(@usuario_logado, NULL), 'candidatos', p_id, 'UPDATE', v_dados_antigos, v_dados_novos);
END$$

DELIMITER ;

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
