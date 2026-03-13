Terminal close -- exit!
não existir ainda
CREATE DATABASE IF NOT EXISTS matchvagas;

# Seleciona a database matchvagas
USE matchvagas;

CREATE TABLE IF NOT EXISTS paises
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL UNIQUE,
    codigo_iso CHAR(2)      NOT NULL UNIQUE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS estados
(
    id      INT AUTO_INCREMENT PRIMARY KEY,
    nome    VARCHAR(100) NOT NULL,
    uf      CHAR(2)      NOT NULL,
    pais_id INT          NOT NULL,
    FOREIGN KEY (pais_id) REFERENCES paises (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY unique_estado_pais (nome, pais_id),
    UNIQUE KEY unique_uf (uf, pais_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela de cidades (dependência total da chave primária)
CREATE TABLE IF NOT EXISTS cidades
(
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    estado_id INT          NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES estados (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY unique_cidade_estado (nome, estado_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE bairros
-- (
--    id INT AUTO_INCREMENT PRIMARY KEY,
--    nome VARCHAR(100) NOT NULL,
--    cidade INT,
--    FOREIGN KEY (cidade) REFERENCES cidades(id)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabela de departamentos (para administradores)
CREATE TABLE IF NOT EXISTS departamentos
(
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela de níveis de escolaridade
CREATE TABLE IF NOT EXISTS niveis_escolaridade
(
    id    INT AUTO_INCREMENT PRIMARY KEY,
    nome  VARCHAR(50) NOT NULL UNIQUE, -- 'Fundamental', 'Médio', 'Técnico', 'Graduação', 'Pós-graduação', 'Mestrado', 'Doutorado'
    ordem INT         NOT NULL         -- para ordenação hierárquica
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela de status de formação
CREATE TABLE IF NOT EXISTS status_formacao
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'Concluído', 'Em andamento', 'Trancado', 'Desistência'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela de tipos de notificação
CREATE TABLE IF NOT EXISTS tipos_notificacao
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'info', 'sucesso', 'aviso', 'erro'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela de status de candidatura
CREATE TABLE IF NOT EXISTS status_candidatura
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'pendente', 'em_andamento', 'aprovado', 'rejeitado', 'cancelado'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela de tipos de telefone
CREATE TABLE IF NOT EXISTS tipos_telefone
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- 'celular', 'residencial', 'comercial', 'recado'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela do porta da empresa
CREATE TABLE IF NOT EXISTS portes
(
    id        INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- Tabela do ramo de atuação da empresa
CREATE TABLE IF NOT EXISTS ramos_atuacao
(
    id        INT PRIMARY KEY,
    descricao VARCHAR(100) UNIQUE NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS modalidades (
    id INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tipos_vaga (
    id INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS status_vaga (
    id INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS usuarios
(
    id               INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(255),
    email            VARCHAR(255),
    senha_hash       TEXT,
    dataNascimento   DATE,
    idade            INT,
    ativo            BOOLEAN,
    dataCadastro     TIMESTAMP,
    dataUltimoAcesso TIMESTAMP
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE empresas
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    cnpj          VARCHAR(18)  NOT NULL,
    razao_social  VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(150),
    descricao     TEXT,
    porte_id      INT,
    ramo_id       INT,
    site          VARCHAR(150),
    FOREIGN KEY (porte_id) REFERENCES portes (id),
    FOREIGN KEY (ramo_id) REFERENCES ramos_atuacao (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS administradores
(
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT NOT NULL,
    nivel           VARCHAR(50),
    departamento_id INT NOT NULL,
    permissoes      TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
    FOREIGN KEY (departamento_id) REFERENCES departamentos (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS telefones
(
    id            INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    numero        VARCHAR(15),
    tipo_telefone INT,
    wpp           BOOLEAN,
    FOREIGN KEY (tipo_telefone) REFERENCES tipos_telefone (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS telefones_usuario
(
    usuario_id  INT NOT NULL,
    telefone_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
    FOREIGN KEY (telefone_id) REFERENCES telefones (id),
    PRIMARY KEY (usuario_id, telefone_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS telefones_empresa
(
    empresa_id  INT NOT NULL,
    telefone_id INT NOT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas (id),
    FOREIGN KEY (telefone_id) REFERENCES telefones (id),
    PRIMARY KEY (empresa_id, telefone_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS enderecos
(
    id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    logradouro  VARCHAR(255),
    numero      VARCHAR(20),
    complemento VARCHAR(100),
    estado      INT,
    cidade      INT,
    bairro      VARCHAR(100),
    cep         VARCHAR(9),
    FOREIGN KEY (estado) REFERENCES estados (id),
    FOREIGN KEY (cidade) REFERENCES cidades (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE candidatos
(
    id                    INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    cpf                   VARCHAR(20) UNIQUE,
    endereco_id           INT,
    objetivo_profissional TEXT,
    pretensao_salarial    NUMERIC(12, 2),
    disponibilidade       VARCHAR(100),
    usuario_id             INT NOT NULL,
    -- curriculo_id          INT,
    -- FOREIGN KEY (curriculo_id) REFERENCES curriculo (id)
    --    ON DELETE CASCADE,
    FOREIGN KEY (endereco_id) REFERENCES enderecos (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE curriculo
(
    id              INT PRIMARY KEY,
    candidato_id    INT ,
    nome_arquivo    VARCHAR(255),
    caminho_arquivo VARCHAR(500),
    data_upload     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tamanho_arquivo BIGINT,
    formato_arquivo VARCHAR(50),
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE formacoes
(
    id             SERIAL PRIMARY KEY,
    candidato_id   INT,
    instituicao    VARCHAR(200),
    curso          VARCHAR(200),
    nivel          INT,
    situacao       INT,
    data_inicio    DATE,
    data_conclusao DATE,
    FOREIGN KEY (candidato_id) REFERENCES candidatos (id)
        ON DELETE CASCADE,
    FOREIGN KEY (nivel) REFERENCES niveis_escolaridade (id),
    FOREIGN KEY (situacao) REFERENCES status_formacao (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE experiencias
(
    id               INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    candidato_id     INT,
    empresa          VARCHAR(255),
    cargo            VARCHAR(150),
    descricao        TEXT,
    data_inicio      DATE,
    data_fim         DATE,
    empregador_atual BOOLEAN DEFAULT FALSE,
    trabalho_remoto  BOOLEAN DEFAULT FALSE,
    finalizada       BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (candidato_id) REFERENCES candidatos (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notificacoes
(
    id         INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    titulo     VARCHAR(200),
    mensagem   TEXT,
    tipo       INT,
    dataEnvio  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida       BOOLEAN,
    usuario_id INT             NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
    FOREIGN KEY (tipo) REFERENCES tipos_notificacao (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE vagas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    requisito TEXT,
    tipo_vaga_id INT NOT NULL,
    modalidade_vaga_id INT NOT NULL,
    salario_min DECIMAL(10,2),
    salario_max DECIMAL(10,2),
    beneficios TEXT,
    carga_horaria VARCHAR(50),
    idade_minima INT,
    idade_maxima INT,
    nivel_escolaridade_minimo_id INT, -- nível mínimo exigido
    area_atuacao VARCHAR(100),
    data_publicacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_expiracao DATETIME,
    status_vaga_id INT NOT NULL,
    numero_vagas INT DEFAULT 1,
    cidade_id INT, -- localização da vaga tabela cidade ou endereço
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ,
    FOREIGN KEY (tipo_vaga_id) REFERENCES tipos_vaga(id) ,
    FOREIGN KEY (modalidade_vaga_id) REFERENCES modalidades(id) ,
    FOREIGN KEY (nivel_escolaridade_minimo_id) REFERENCES niveis_escolaridade(id) ,
    FOREIGN KEY (status_vaga_id) REFERENCES status_vaga(id) ,
    FOREIGN KEY (cidade_id) REFERENCES cidades(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE candidaturas
(
    id               INT PRIMARY KEY,
    candidato_id     INTEGER NOT NULL,
    vaga_id          INTEGER NOT NULL,
    data_candidatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP,
    status_id        INTEGER,
    UNIQUE (candidato_id, vaga_id),
    FOREIGN KEY (candidato_id)
        REFERENCES candidatos (id)
        ON DELETE CASCADE,
    FOREIGN KEY (vaga_id)
        REFERENCES vagas (id)
        ON DELETE CASCADE,
    FOREIGN KEY (status_id)
        REFERENCES status_candidatura (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela para registro de logs e auditoria do sistema
CREATE TABLE IF NOT EXISTS logs_eventos (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id    INT,
    tabela_nome   VARCHAR(100) NOT NULL,
    registro_id   INT,              -- O ID do registro afetado
    acao          ENUM('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT'),
    descricao     TEXT,
    dados_antigos LONGTEXT,
    dados_novos   LONGTEXT,
    data_evento   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE SET NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;