# Cria um schema se ele não existir ainda
CREATE DATABASE IF NOT EXISTS matchvagas;

# Seleciona a database matchvagas
USE matchvagas;

CREATE TABLE IF NOT EXISTS usuarios(
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255),
    email VARCHAR(255),
    dataNascimento DATE,
    idade INT,
    telefone INT,
    ativo BOOLEAN,
    dataCadastro DATE,
    dataUltimoAcesso DATE,
    FOREIGN KEY (telefone_id) REFERENCES telefones(id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS notificacoes(
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    titulo varchar(255),
    mensagem TEXT,
    tipo enum('NOVA_VAGA','STATUS_CANDIDATURA',
        'MENSAGEM_EMPRESA','ALERTA_SISTEMA','VAGA_EXPIRADA'),
    dataEnvio date,
    lida bool,
    usuario_id int not null ,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;