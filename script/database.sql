-- MySQL DDL for MatchVagas system (V1.0) - 3rd Normal Form
-- Fully normalized to eliminate transitive dependencies and partial dependencies

-- Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS candidaturas;
DROP TABLE IF EXISTS notificacoes;
DROP TABLE IF EXISTS experiencias;
DROP TABLE IF EXISTS formacoes;
DROP TABLE IF EXISTS telefones;
DROP TABLE IF EXISTS enderecos;
DROP TABLE IF EXISTS candidatos;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS vagas;
DROP TABLE IF EXISTS administradores;
DROP TABLE IF EXISTS niveis_escolaridade;
DROP TABLE IF EXISTS tipos_vaga;
DROP TABLE IF EXISTS modalidades_vaga;
DROP TABLE IF EXISTS status_vaga;
DROP TABLE IF EXISTS departamentos;
DROP TABLE IF EXISTS cidades;
DROP TABLE IF EXISTS estados;
DROP TABLE IF EXISTS paises;

-- =====================================================
-- TABELAS DE DOMÍNIO (LOOKUP TABLES) - 1FN e 2FN
-- =====================================================

-- Tabela de países (evita repetição de strings)
CREATE TABLE paises
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL UNIQUE,
    codigo_iso CHAR(2)      NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de estados (dependência total da chave primária)
CREATE TABLE estados
(
    id      INT AUTO_INCREMENT PRIMARY KEY,
    nome    VARCHAR(100) NOT NULL,
    uf      CHAR(2)      NOT NULL,
    pais_id INT          NOT NULL,
    FOREIGN KEY (pais_id) REFERENCES paises (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY unique_estado_pais (nome, pais_id),
    UNIQUE KEY unique_uf (uf, pais_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de cidades (dependência total da chave primária)
CREATE TABLE cidades
(
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    estado_id INT          NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES estados (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY unique_cidade_estado (nome, estado_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de departamentos (para administradores)
CREATE TABLE departamentos
(
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de níveis de escolaridade
CREATE TABLE niveis_escolaridade
(
    id    INT AUTO_INCREMENT PRIMARY KEY,
    nome  VARCHAR(50) NOT NULL UNIQUE, -- 'Fundamental', 'Médio', 'Técnico', 'Graduação', 'Pós-graduação', 'Mestrado', 'Doutorado'
    ordem INT         NOT NULL         -- para ordenação hierárquica
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de tipos de vaga
CREATE TABLE tipos_vaga
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'CLT', 'PJ', 'Estágio', 'Temporário', 'Freelance'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de modalidades de trabalho
CREATE TABLE modalidades_vaga
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'Presencial', 'Remoto', 'Híbrido'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de status de vaga
CREATE TABLE status_vaga
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'aberta', 'pausada', 'encerrada', 'cancelada'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de disponibilidade (para candidatos)
CREATE TABLE disponibilidades
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'Imediata', '30 dias', '60 dias', 'A combinar'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de status de formação
CREATE TABLE status_formacao
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'Concluído', 'Em andamento', 'Trancado', 'Desistência'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de tipos de notificação
CREATE TABLE tipos_notificacao
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'info', 'sucesso', 'aviso', 'erro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de status de candidatura
CREATE TABLE status_candidatura
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'pendente', 'em_andamento', 'aprovado', 'rejeitado', 'cancelado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de tipos de telefone
CREATE TABLE tipos_telefone
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'celular', 'residencial', 'comercial', 'recado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELAS PRINCIPAIS - 1FN, 2FN e 3FN
-- =====================================================

-- Table administradores (3FN)
CREATE TABLE administradores
(
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nivel           VARCHAR(50) NOT NULL, -- mantido como string pois é um nível hierárquico, não uma entidade separada
    departamento_id INT         NOT NULL,
    permissoes      TEXT,                 -- armazenado como JSON para flexibilidade, não normalizável
    FOREIGN KEY (departamento_id) REFERENCES departamentos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX           idx_nivel (nivel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table usuarios (3FN - sem dependências transitivas)
CREATE TABLE usuarios
(
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    nome               VARCHAR(255) NOT NULL,
    email              VARCHAR(255) NOT NULL UNIQUE,
    data_nascimento    DATE,
    senha_hash         VARCHAR(255) NOT NULL,
    ativo              BOOLEAN  DEFAULT TRUE,
    data_cadastro      DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_ultimo_acesso DATETIME,
    -- idade removida (derivada de data_nascimento, dependência transitiva)
    INDEX              idx_email (email),
    INDEX              idx_nome (nome),
    INDEX              idx_data_cadastro (data_cadastro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table candidatos (3FN)
CREATE TABLE candidatos
(
    id                    INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id            INT         NOT NULL UNIQUE,
    cpf                   VARCHAR(11) NOT NULL UNIQUE,
    objetivo_profissional TEXT,
    pretensao_salarial    DECIMAL(10, 2),
    disponibilidade_id    INT,
    data_atualizacao      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (disponibilidade_id) REFERENCES disponibilidades (id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX                 idx_cpf (cpf),
    INDEX                 idx_pretensao (pretensao_salarial)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table enderecos (3FN)
CREATE TABLE enderecos
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id    INT NOT NULL,
    logradouro    VARCHAR(255),
    numero        VARCHAR(20),
    complemento   VARCHAR(100),
    bairro        VARCHAR(100),
    cep           VARCHAR(10),
    cidade_id     INT NOT NULL,
    tipo_endereco VARCHAR(50) DEFAULT 'residencial',
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cidade_id) REFERENCES cidades (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX         idx_cep (cep),
    INDEX         idx_bairro (bairro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table telefones (3FN)
CREATE TABLE telefones
(
    id               INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id       INT         NOT NULL,
    numero           VARCHAR(20) NOT NULL,
    tipo_telefone_id INT         NOT NULL,
    principal        BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tipo_telefone_id) REFERENCES tipos_telefone (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX            idx_numero (numero)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table formacoes (3FN)
CREATE TABLE formacoes
(
    id                    INT AUTO_INCREMENT PRIMARY KEY,
    candidato_id          INT          NOT NULL,
    instituicao           VARCHAR(255) NOT NULL,
    curso                 VARCHAR(255) NOT NULL,
    nivel_escolaridade_id INT          NOT NULL,
    status_formacao_id    INT          NOT NULL,
    data_inicio           DATE,
    data_conclusao        DATE,
    concluido             BOOLEAN GENERATED ALWAYS AS (data_conclusao IS NOT NULL) STORED,
    FOREIGN KEY (candidato_id) REFERENCES candidatos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nivel_escolaridade_id) REFERENCES niveis_escolaridade (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (status_formacao_id) REFERENCES status_formacao (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX                 idx_instituicao (instituicao),
    INDEX                 idx_curso (curso),
    INDEX                 idx_periodo (data_inicio, data_conclusao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table experiencias (3FN)
CREATE TABLE experiencias
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    candidato_id  INT          NOT NULL,
    empresa       VARCHAR(255) NOT NULL,
    cargo         VARCHAR(255) NOT NULL,
    descricao     TEXT,
    data_inicio   DATE,
    data_fim      DATE,
    emprego_atual BOOLEAN DEFAULT FALSE,
    CHECK ((emprego_atual = TRUE AND data_fim IS NULL) OR (emprego_atual = FALSE)),
    FOREIGN KEY (candidato_id) REFERENCES candidatos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX         idx_empresa (empresa),
    INDEX         idx_cargo (cargo),
    INDEX         idx_periodo (data_inicio, data_fim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table vagas (3FN)
CREATE TABLE vagas
(
    id                           INT AUTO_INCREMENT PRIMARY KEY,
    admin_id                     INT          NOT NULL,
    titulo                       VARCHAR(255) NOT NULL,
    descricao                    TEXT,
    requisito                    TEXT,
    tipo_vaga_id                 INT          NOT NULL,
    modalidade_vaga_id           INT          NOT NULL,
    salario_min                  DECIMAL(10, 2),
    salario_max                  DECIMAL(10, 2),
    beneficios                   TEXT,
    carga_horaria                VARCHAR(50),
    idade_minima                 INT,
    idade_maxima                 INT,
    nivel_escolaridade_minimo_id INT, -- nível mínimo exigido
    area_atuacao                 VARCHAR(100),
    data_publicacao              DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_expiracao               DATETIME,
    status_vaga_id               INT          NOT NULL,
    numero_vagas                 INT      DEFAULT 1,
    cidade_id                    INT, -- localização da vaga
    CHECK (idade_maxima >= idade_minima OR idade_maxima IS NULL),
    FOREIGN KEY (admin_id) REFERENCES administradores (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (tipo_vaga_id) REFERENCES tipos_vaga (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (modalidade_vaga_id) REFERENCES modalidades_vaga (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nivel_escolaridade_minimo_id) REFERENCES niveis_escolaridade (id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (status_vaga_id) REFERENCES status_vaga (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (cidade_id) REFERENCES cidades (id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX                        idx_status (status_vaga_id),
    INDEX                        idx_data_publicacao (data_publicacao),
    INDEX                        idx_area_atuacao (area_atuacao),
    INDEX                        idx_salario (salario_min, salario_max),
    FULLTEXT                     INDEX idx_busca (titulo, descricao, requisito)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table notificacoes (3FN)
CREATE TABLE notificacoes
(
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id          INT          NOT NULL,
    titulo              VARCHAR(255) NOT NULL,
    mensagem            TEXT         NOT NULL,
    tipo_notificacao_id INT          NOT NULL,
    data_envio          DATETIME DEFAULT CURRENT_TIMESTAMP,
    lida                BOOLEAN  DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tipo_notificacao_id) REFERENCES tipos_notificacao (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX               idx_lida (lida),
    INDEX               idx_data_envio (data_envio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table candidaturas (3FN - relacionamento entre candidatos e vagas)
CREATE TABLE candidaturas
(
    id                    INT AUTO_INCREMENT PRIMARY KEY,
    candidato_id          INT NOT NULL,
    vaga_id               INT NOT NULL,
    data_candidatura      DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_candidatura_id INT NOT NULL,
    observacoes           TEXT,
    data_status           DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (candidato_id) REFERENCES candidatos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (vaga_id) REFERENCES vagas (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (status_candidatura_id) REFERENCES status_candidatura (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY unique_candidatura (candidato_id, vaga_id),
    INDEX                 idx_status (status_candidatura_id),
    INDEX                 idx_data (data_candidatura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERÇÃO DE DADOS BÁSICOS (OPCIONAL)
-- =====================================================

-- Inserir país padrão
INSERT INTO paises (nome, codigo_iso)
VALUES ('Brasil', 'BR');

-- Inserir estados brasileiros (exemplo)
INSERT INTO estados (nome, uf, pais_id)
VALUES ('São Paulo', 'SP', 1),
       ('Rio de Janeiro', 'RJ', 1),
       ('Minas Gerais', 'MG', 1);

-- Inserir tipos de vaga
INSERT INTO tipos_vaga (nome)
VALUES ('CLT'),
       ('PJ'),
       ('Estágio'),
       ('Temporário'),
       ('Freelance');

-- Inserir modalidades
INSERT INTO modalidades_vaga (nome)
VALUES ('Presencial'),
       ('Remoto'),
       ('Híbrido');

-- Inserir status de vaga
INSERT INTO status_vaga (nome)
VALUES ('aberta'),
       ('pausada'),
       ('encerrada'),
       ('cancelada');

-- Inserir níveis de escolaridade com ordem
INSERT INTO niveis_escolaridade (nome, ordem)
VALUES ('Fundamental', 1),
       ('Médio', 2),
       ('Técnico', 3),
       ('Graduação', 4),
       ('Pós-graduação', 5),
       ('Mestrado', 6),
       ('Doutorado', 7);

-- Inserir disponibilidades
INSERT INTO disponibilidades (nome)
VALUES ('Imediata'),
       ('30 dias'),
       ('60 dias'),
       ('A combinar');

-- Inserir status de formação
INSERT INTO status_formacao (nome)
VALUES ('Concluído'),
       ('Em andamento'),
       ('Trancado'),
       ('Desistência');

-- Inserir tipos de notificação
INSERT INTO tipos_notificacao (nome)
VALUES ('info'),
       ('sucesso'),
       ('aviso'),
       ('erro');

-- Inserir status de candidatura
INSERT INTO status_candidatura (nome)
VALUES ('pendente'),
       ('em_andamento'),
       ('aprovado'),
       ('rejeitado'),
       ('cancelado');

-- Inserir tipos de telefone
INSERT INTO tipos_telefone (nome)
VALUES ('celular'),
       ('residencial'),
       ('comercial'),
       ('recado');