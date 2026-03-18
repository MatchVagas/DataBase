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
                                               