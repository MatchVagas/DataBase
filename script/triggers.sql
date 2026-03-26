-- =====================================================
-- 1. SELECIONAR O BANCO DE DADOS MATCHVAGAS
-- =====================================================

use matchvagas;

-- =====================================================
-- 2. TRIGGERS PARA A TABELA `usuarios`
-- =====================================================
DELIMITER $$

DROP TRIGGER IF EXISTS before_insert_usuarios$$
CREATE TRIGGER before_insert_usuarios
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    -- Calcula a idade automaticamente com base na data de nascimento
    IF NEW.dataNascimento IS NOT NULL THEN
        SET NEW.idade = TIMESTAMPDIFF(YEAR, NEW.dataNascimento, CURDATE());
    END IF;
END$$

DROP TRIGGER IF EXISTS before_update_usuarios$$
CREATE TRIGGER before_update_usuarios
BEFORE UPDATE ON usuarios
FOR EACH ROW
BEGIN
    -- Recalcula a idade se a data de nascimento foi alterada
    IF NEW.dataNascimento IS NOT NULL AND 
        (OLD.dataNascimento IS NULL OR NEW.dataNascimento <> OLD.dataNascimento) THEN
    SET NEW.idade = TIMESTAMPDIFF(YEAR, NEW.dataNascimento, CURDATE());
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_insert_candidato
BEFORE INSERT ON candidatos
FOR EACH ROW
BEGIN
    DECLARE cnt INT;

    -- Verifica se já existe o usuario_id
    SELECT COUNT(*) INTO cnt
    FROM candidatos
    WHERE usuario_id = NEW.usuario_id;

    -- Se já existir, gera um erro
    IF cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'usuario_id já existe na tabela candidato. Inserção não permitida.';
    END IF;
END;

DELIMITER ;

DELIMITER $$

DROP TRIGGER IF EXISTS before_insert_formacoes$$
CREATE TRIGGER before_insert_formacoes
BEFORE INSERT ON formacoes
FOR EACH ROW
BEGIN
    -- Valida se a data_fim não é anterior à data_inicio
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de término não pode ser anterior à data de início.';
    END IF;

    -- Valida consistência da situação
    -- Exemplo: se situação = 'concluído', data_fim deve estar preenchida
    IF NEW.situacao = 'concluído' AND NEW.data_fim IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formação marcada como concluída deve ter data_fim preenchida.';
    END IF;

    -- Exemplo: se situação = 'em andamento', data_fim deve ser nula
    IF NEW.situacao = 'em andamento' AND NEW.data_fim IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formação em andamento não pode ter data_fim preenchida.';
    END IF;
END;

CREATE TRIGGER before_update_formacoes
BEFORE UPDATE ON formacoes
FOR EACH ROW
BEGIN
    -- Valida se a data_fim não é anterior à data_inicio
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de término não pode ser anterior à data de início.';
    END IF;

    -- Valida consistência da situação
    -- Exemplo: se situação = 'concluído', data_fim deve estar preenchida
    IF NEW.situacao = 'concluído' AND NEW.data_fim IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formação marcada como concluída deve ter data_fim preenchida.';
    END IF;

    -- Exemplo: se situação = 'em andamento', data_fim deve ser nula
    IF NEW.situacao = 'em andamento' AND NEW.data_fim IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formação em andamento não pode ter data_fim preenchida.';
    END IF;
END;

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_insert_experiencias
BEFORE INSERT ON experiencias
FOR EACH ROW
BEGIN
    -- Valida se a data_fim não é anterior à data_inicio
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de término não pode ser anterior à data de início.';
    END IF;

    -- Valida consistência com emprego atual
    IF NEW.emprego_atual = TRUE AND NEW.data_fim IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Emprego atual não pode ter data de término preenchida.';
    END IF;

    IF NEW.emprego_atual = FALSE AND NEW.data_fim IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Emprego encerrado deve ter data de término preenchida.';
    END IF;
END;

CREATE TRIGGER before_update_experiencias
BEFORE UPDATE ON experiencias
FOR EACH ROW
BEGIN
    -- Valida se a data_fim não é anterior à data_inicio
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de término não pode ser anterior à data de início.';
    END IF;

    -- Valida consistência com emprego atual
    IF NEW.emprego_atual = TRUE AND NEW.data_fim IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Emprego atual não pode ter data de término preenchida.';
    END IF;

    IF NEW.emprego_atual = FALSE AND NEW.data_fim IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Emprego encerrado deve ter data de término preenchida.';
    END IF;
END;

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_insert_candidaturas
BEFORE INSERT ON candidaturas
FOR EACH ROW
BEGIN
    DECLARE vaga_status VARCHAR(20);

    -- Busca o status da vaga
    SELECT status INTO vaga_status
    FROM vagas
    WHERE id = NEW.vaga_id;

    -- Se a vaga estiver encerrada, bloqueia a inserção
    IF vaga_status = 'encerrada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido candidatar-se a uma vaga encerrada.';
    END IF;
END;

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_update_candidaturas
BEFORE UPDATE ON candidaturas
FOR EACH ROW
BEGIN
    -- Atualiza automaticamente a data_atualizacao com o momento atual
    SET NEW.data_atualizacao = NOW();
END;

DELIMITER ;



DELIMITER $$

DROP TRIGGER IF EXISTS before_insert_vagas_validador$$
CREATE TRIGGER before_insert_vagas_validador
BEFORE INSERT ON vagas
FOR EACH ROW
BEGIN
    -- Salários
    IF NEW.salario_min IS NOT NULL AND NEW.salario_max IS NOT NULL 
       AND NEW.salario_min > NEW.salario_max THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salário mínimo > salário máximo';
    END IF;

    -- Idade
    IF NEW.idade_minima IS NOT NULL AND NEW.idade_maxima IS NOT NULL 
       AND NEW.idade_minima > NEW.idade_maxima THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Idade mínima > idade máxima';
    END IF;

    -- Datas
    IF NEW.data_publicacao IS NULL THEN
        SET NEW.data_publicacao = CURRENT_TIMESTAMP;
    END IF;

    IF NEW.data_expiracao IS NOT NULL 
       AND NEW.data_expiracao < NEW.data_publicacao THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data expiração < data publicação';
    END IF;
END$$

DROP TRIGGER IF EXISTS before_update_vagas_validador$$
CREATE TRIGGER before_update_vagas_validador
BEFORE UPDATE ON vagas
FOR EACH ROW
BEGIN
    -- Salários
    IF NEW.salario_min IS NOT NULL AND NEW.salario_max IS NOT NULL 
       AND NEW.salario_min > NEW.salario_max THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salário mínimo > salário máximo';
    END IF;

    -- Idade
    IF NEW.idade_minima IS NOT NULL AND NEW.idade_maxima IS NOT NULL 
       AND NEW.idade_minima > NEW.idade_maxima THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Idade mínima > idade máxima';
    END IF;

    -- Datas
    SET NEW.data_publicacao = OLD.data_publicacao;

    IF NEW.data_expiracao IS NOT NULL 
       AND NEW.data_expiracao < NEW.data_publicacao THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data expiração < data publicação';
    END IF;
END$$

DELIMITER ;
                                               
