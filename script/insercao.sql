-- =====================================================
-- 0. SELECIONAR O BANCO DE DADOS MATCHVAGAS E INSERIR DADOS DE TESTE
-- =====================================================

use matchvagas;

-- =====================================================
-- 1. TABELAS INDEPENDENTES (SEM CHAVES ESTRANGEIRAS)
-- =====================================================

-- Inserir países
INSERT INTO paises (nome, codigo_iso) VALUES
('Brasil', 'BR'),
('Estados Unidos', 'US'),
('Portugal', 'PT'),
('Espanha', 'ES'),
('Canadá', 'CA');

-- Inserir departamentos
INSERT INTO departamentos (nome, descricao) VALUES
('Recursos Humanos', 'Departamento responsável pela gestão de pessoas'),
('Tecnologia da Informação', 'Departamento responsável pela infraestrutura de TI'),
('Financeiro', 'Departamento responsável pelas finanças'),
('Marketing', 'Departamento responsável pelo marketing e comunicação'),
('Comercial', 'Departamento responsável pelas vendas');

-- Inserir níveis de escolaridade
INSERT INTO niveis_escolaridade (nome, ordem) VALUES
('Fundamental', 1),
('Médio', 2),
('Técnico', 3),
('Graduação', 4),
('Pós-graduação', 5),
('Mestrado', 6),
('Doutorado', 7);

-- Inserir status de formação
INSERT INTO status_formacao (nome) VALUES
('Concluído'),
('Em andamento'),
('Trancado'),
('Desistência');

-- Inserir tipos de notificação
INSERT INTO tipos_notificacao (nome) VALUES
('info'),
('sucesso'),
('aviso'),
('erro'),
('promoção');

-- Inserir status de candidatura
INSERT INTO status_candidatura (nome) VALUES
('pendente'),
('em_andamento'),
('aprovado'),
('rejeitado'),
('cancelado');

-- Inserir tipos de telefone
INSERT INTO tipos_telefone (nome) VALUES
('celular'),
('residencial'),
('comercial'),
('recado'),
('whatsapp');

-- Inserir portes de empresa
INSERT INTO portes (id, descricao) VALUES
(1, 'Microempresa'),
(2, 'Pequena Empresa'),
(3, 'Média Empresa'),
(4, 'Grande Empresa'),
(5, 'Multinacional');

-- Inserir ramos de atuação
INSERT INTO ramos_atuacao (id, descricao) VALUES
(1, 'Tecnologia da Informação'),
(2, 'Comércio Varejista'),
(3, 'Serviços Financeiros'),
(4, 'Saúde'),
(5, 'Educação');

-- Inserir modalidades de vaga
INSERT INTO modalidades (id, descricao) VALUES
(1, 'Presencial'),
(2, 'Remoto'),
(3, 'Híbrido'),
(4, 'Home Office'),
(5, 'Temporário');

-- Inserir tipos de vaga
INSERT INTO tipos_vaga (id, descricao) VALUES
(1, 'CLT'),
(2, 'PJ'),
(3, 'Estágio'),
(4, 'Trainee'),
(5, 'Temporário');

-- Inserir status de vaga
INSERT INTO status_vaga (id, descricao) VALUES
(1, 'Aberta'),
(2, 'Em andamento'),
(3, 'Pausada'),
(4, 'Fechada'),
(5, 'Cancelada');

-- Inserir usuários (agora com senha_hash)
INSERT INTO usuarios (nome, email, senha_hash, dataNascimento, idade, ativo, dataCadastro, dataUltimoAcesso) VALUES
('João Silva', 'joao.silva@email.com', '$2y$10$YourHashedPasswordHere1', '1990-05-15', 33, TRUE, NOW(), NOW()),
('Maria Santos', 'maria.santos@email.com', '$2y$10$YourHashedPasswordHere2', '1988-08-22', 35, TRUE, NOW(), NOW()),
('Pedro Oliveira', 'pedro.oliveira@email.com', '$2y$10$YourHashedPasswordHere3', '1995-03-10', 28, TRUE, NOW(), NOW()),
('Ana Costa', 'ana.costa@email.com', '$2y$10$YourHashedPasswordHere4', '1992-11-30', 31, TRUE, NOW(), NOW()),
('Carlos Souza', 'carlos.souza@email.com', '$2y$10$YourHashedPasswordHere5', '1985-07-18', 38, TRUE, NOW(), NOW()),
('Lucia Ferreira', 'lucia.ferreira@email.com', '$2y$10$YourHashedPasswordHere6', '1993-09-25', 30, TRUE, NOW(), NULL),
('Roberto Almeida', 'roberto.almeida@email.com', '$2y$10$YourHashedPasswordHere7', '1987-12-05', 36, FALSE, NOW(), NULL),
('Fernanda Lima', 'fernanda.lima@email.com', '$2y$10$YourHashedPasswordHere8', '1991-04-12', 34, TRUE, NOW(), NULL),
('Marcos Paulo', 'marcos.paulo@email.com', '$2y$10$YourHashedPasswordHere9', '1989-07-30', 36, TRUE, NOW(), NULL),
('Juliana Mendes', 'juliana.mendes@email.com', '$2y$10$YourHashedPasswordHere10', '1994-11-05', 31, TRUE, NOW(), NULL);

-- =====================================================
-- 2. TABELAS QUE DEPENDEM APENAS DAS INDEPENDENTES
-- =====================================================

-- Inserir estados (depende de paises)
INSERT INTO estados (nome, uf, pais_id) VALUES
('São Paulo', 'SP', 1),
('Rio de Janeiro', 'RJ', 1),
('Minas Gerais', 'MG', 1),
('Bahia', 'BA', 1),
('Paraná', 'PR', 1),
('Rio Grande do Sul', 'RS', 1),
('Santa Catarina', 'SC', 1),
('Pernambuco', 'PE', 1),
('Ceará', 'CE', 1),
('Distrito Federal', 'DF', 1);

-- Inserir telefones (depende de tipos_telefone)
INSERT INTO telefones (numero, tipo_telefone, wpp) VALUES
('(11) 99999-1111', 1, TRUE),
('(11) 3333-2222', 2, FALSE),
('(21) 98888-3333', 1, TRUE),
('(31) 97777-4444', 1, TRUE),
('(41) 96666-5555', 3, TRUE),
('(71) 95555-6666', 4, FALSE),
('(11) 94444-7777', 1, TRUE),
('(21) 93333-8888', 1, TRUE),
('(31) 92222-9999', 2, FALSE),
('(41) 91111-0000', 3, TRUE),
('(51) 98888-1111', 1, TRUE),
('(48) 97777-2222', 1, TRUE),
('(81) 96666-3333', 3, TRUE),
('(85) 95555-4444', 4, FALSE),
('(61) 94444-5555', 1, TRUE);

-- Inserir empresas (depende de portes e ramos_atuacao)
INSERT INTO empresas (cnpj, razao_social, nome_fantasia, descricao, porte_id, ramo_id, site) VALUES
('12.345.678/0001-90', 'Tech Solutions Ltda', 'TechSol', 'Empresa de soluções em TI', 2, 1, 'www.techsol.com.br'),
('23.456.789/0001-01', 'Comércio Varejista S/A', 'MegaStore', 'Rede de lojas de varejo', 4, 2, 'www.megastore.com.br'),
('34.567.890/0001-12', 'Banco Nacional S/A', 'Banco Nacional', 'Instituição financeira', 5, 3, 'www.bnacional.com.br'),
('45.678.901/0001-23', 'Clínica Saúde Total', 'Saúde Total', 'Clínica médica multiespecialidades', 3, 4, 'www.saudetotal.com.br'),
('56.789.012/0001-34', 'Educação Futuro Ltda', 'Futuro Educação', 'Escola de ensino fundamental e médio', 2, 5, 'www.futuroeducacao.com.br'),
('67.890.123/0001-45', 'Consultoria RH Brasil', 'RH Brasil', 'Consultoria em recursos humanos', 2, 1, 'www.rhbrasil.com.br'),
('78.901.234/0001-56', 'Construtora Alpha', 'Alpha Construtora', 'Construção civil', 3, 2, 'www.alpha.com.br'),
('89.012.345/0001-67', 'Escritório de Advocacia Mendes', 'Mendes Advogados', 'Serviços jurídicos', 1, 3, 'www.mendesadv.com.br'),
('90.123.456/0001-78', 'Agência de Marketing Digital', 'Agência Web', 'Marketing e publicidade', 2, 4, 'www.agenciaweb.com.br'),
('01.234.567/0001-89', 'Transportadora Rápida', 'TransRápida', 'Serviços de logística', 3, 5, 'www.transrapida.com.br');

-- =====================================================
-- 3. TABELAS QUE DEPENDEM DE ESTADOS
-- =====================================================

-- Inserir cidades (depende de estados)
INSERT INTO cidades (nome, estado_id) VALUES
('São Paulo', 1),
('Rio de Janeiro', 2),
('Belo Horizonte', 3),
('Salvador', 4),
('Curitiba', 5),
('Porto Alegre', 6),
('Florianópolis', 7),
('Recife', 8),
('Fortaleza', 9),
('Brasília', 10),
('Campinas', 1),
('Niterói', 2),
('Uberlândia', 3),
('Feira de Santana', 4),
('Londrina', 5);

-- =====================================================
-- 4. TABELAS QUE DEPENDEM DE ESTADOS E CIDADES
-- =====================================================

-- Inserir endereços (depende de estados e cidades)
INSERT INTO enderecos (logradouro, numero, complemento, estado, cidade, bairro, cep) VALUES
('Avenida Paulista', '1000', 'Sala 101', 1, 1, 'Bela Vista', '01310-100'),
('Rua da Quitanda', '50', NULL, 2, 2, 'Centro', '20091-005'),
('Avenida Afonso Pena', '2000', 'Apto 501', 3, 3, 'Centro', '30130-001'),
('Rua Chile', '300', NULL, 4, 4, 'Comércio', '40010-000'),
('Rua das Flores', '150', 'Casa', 5, 5, 'Centro', '80020-100'),
('Avenida Ipiranga', '1000', 'Apto 202', 6, 6, 'Centro Histórico', '90010-001'),
('Rua Felipe Schmidt', '500', 'Sala 5', 7, 7, 'Centro', '88010-001'),
('Avenida Boa Viagem', '2000', 'Apto 1001', 8, 8, 'Boa Viagem', '51011-000'),
('Rua Barão do Rio Branco', '800', NULL, 9, 9, 'Centro', '60010-001'),
('SHS Quadra 6', '100', 'Bloco A', 10, 10, 'Asa Sul', '70322-000'),
('Rua José Paulino', '500', NULL, 1, 11, 'Centro', '13010-000'),
('Avenida Amaral Peixoto', '200', 'Sala 301', 2, 12, 'Centro', '24020-000'),
('Rua Coronel Antônio Alves', '300', NULL, 3, 13, 'Centro', '38400-000'),
('Avenida Getúlio Vargas', '400', 'Sala 10', 4, 14, 'Centro', '44010-000'),
('Rua Minas Gerais', '600', 'Casa', 5, 15, 'Centro', '86010-000');

-- =====================================================
-- 5. TABELAS QUE DEPENDEM DE USUÁRIOS E DEPARTAMENTOS
-- =====================================================

-- Inserir administradores (depende de usuarios e departamentos)
INSERT INTO administradores (usuario_id, nivel, departamento_id, permissoes) VALUES
(1, 'Master', 2, '{"vagas": true, "usuarios": true, "relatorios": true}'),
(2, 'Supervisor', 1, '{"vagas": true, "usuarios": false, "relatorios": true}'),
(3, 'Operador', 3, '{"vagas": false, "usuarios": false, "relatorios": true}'),
(4, 'Supervisor', 4, '{"vagas": true, "usuarios": false, "relatorios": true}'),
(5, 'Operador', 5, '{"vagas": true, "usuarios": false, "relatorios": false}');

-- Inserir notificações (depende de usuarios e tipos_notificacao)
INSERT INTO notificacoes (titulo, mensagem, tipo, dataEnvio, lida, usuario_id) VALUES
('Candidatura recebida', 'Sua candidatura para a vaga Desenvolvedor Full Stack foi recebida', 2, NOW(), FALSE, 1),
('Atualização de candidatura', 'Sua candidatura está em andamento', 1, DATE_SUB(NOW(), INTERVAL 1 DAY), TRUE, 2),
('Vaga nova', 'Nova vaga de Analista Financeiro disponível', 3, DATE_SUB(NOW(), INTERVAL 2 DAY), FALSE, 3),
('Entrevista agendada', 'Sua entrevista foi agendada para amanhã', 2, DATE_SUB(NOW(), INTERVAL 1 DAY), FALSE, 4),
('Currículo visualizado', 'Seu currículo foi visualizado pela empresa', 1, DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, 5),
('Vaga encerrada', 'A vaga que você se candidatou foi encerrada', 4, DATE_SUB(NOW(), INTERVAL 5 DAY), TRUE, 6),
('Promoção', 'Nova vaga de estágio disponível', 5, DATE_SUB(NOW(), INTERVAL 1 DAY), FALSE, 7),
('Candidatura aprovada', 'Sua candidatura foi aprovada para a próxima fase', 2, NOW(), FALSE, 8),
('Novo curso disponível', 'Confira os novos cursos da plataforma', 1, NOW(), FALSE, 9),
('Atualize seus dados', 'Complete seu perfil para melhores oportunidades', 3, NOW(), FALSE, 10);

-- =====================================================
-- 6. TABELAS QUE RELACIONAM TELEFONES
-- =====================================================

-- Inserir telefones_usuario (depende de usuarios e telefones)
INSERT INTO telefones_usuario (usuario_id, telefone_id) VALUES
(1, 1),
(2, 3),
(3, 4),
(4, 5),
(5, 7),
(6, 8),
(7, 9),
(8, 11),
(9, 12),
(10, 13);

-- Inserir telefones_empresa (depende de empresas e telefones)
INSERT INTO telefones_empresa (empresa_id, telefone_id) VALUES
(1, 2),
(2, 6),
(3, 10),
(4, 14),
(5, 15),
(6, 1),
(7, 3),
(8, 4),
(9, 5),
(10, 7);

-- =====================================================
-- 7. TABELAS QUE DEPENDEM DE ENDEREÇOS E USUÁRIOS
-- =====================================================

-- Inserir candidatos (depende de enderecos e usuarios)
INSERT INTO candidatos (id, cpf, endereco_id, objetivo_profissional, pretensao_salarial, disponibilidade, usuario_id) VALUES
(1, '123.456.789-00', 1, 'Atuar como desenvolvedor full stack', 8000.00, 'Imediata', 1),
(2, '234.567.890-11', 2, 'Cargo de gerência de RH', 12000.00, '30 dias', 2),
(3, '345.678.901-22', 3, 'Posição como analista financeiro', 7000.00, 'Imediata', 3),
(4, '456.789.012-33', 4, 'Atuar com marketing digital', 6000.00, '15 dias', 4),
(5, '567.890.123-44', 5, 'Cargo de vendas executivas', 5000.00, 'Imediata', 5),
(6, '678.901.234-55', 6, 'Primeira oportunidade como desenvolvedor', 3500.00, 'Imediata', 6),
(7, '789.012.345-66', 7, 'Posição em RH ou DP', 4500.00, 'Imediata', 7),
(8, '890.123.456-77', 8, 'Atuar como analista de sistemas', 6000.00, '30 dias', 8),
(9, '901.234.567-88', 9, 'Cargo de coordenação de marketing', 8000.00, '45 dias', 9),
(10, '012.345.678-99', 10, 'Posição como gerente de vendas', 10000.00, 'Imediata', 10);

-- =====================================================
-- 8. TABELAS QUE DEPENDEM DE CANDIDATOS
-- =====================================================

-- Inserir currículos (agora depende de candidatos - FK para candidatos)
INSERT INTO curriculo (id, candidato_id, nome_arquivo, caminho_arquivo, data_upload, tamanho_arquivo, formato_arquivo) VALUES
(1, 1, 'curriculo_joao.pdf', '/curriculos/joao_silva.pdf', NOW(), 1024000, 'PDF'),
(2, 2, 'curriculo_maria.pdf', '/curriculos/maria_santos.pdf', NOW(), 2048000, 'PDF'),
(3, 3, 'curriculo_pedro.pdf', '/curriculos/pedro_oliveira.pdf', NOW(), 1536000, 'PDF'),
(4, 4, 'curriculo_ana.pdf', '/curriculos/ana_costa.pdf', NOW(), 1126400, 'PDF'),
(5, 5, 'curriculo_carlos.pdf', '/curriculos/carlos_souza.pdf', NOW(), 1843200, 'PDF'),
(6, 6, 'curriculo_lucia.pdf', '/curriculos/lucia_ferreira.pdf', NOW(), 950000, 'PDF'),
(7, 7, 'curriculo_roberto.pdf', '/curriculos/roberto_almeida.pdf', NOW(), 1250000, 'PDF'),
(8, 8, 'curriculo_fernanda.pdf', '/curriculos/fernanda_lima.pdf', NOW(), 2100000, 'PDF'),
(9, 9, 'curriculo_marcos.pdf', '/curriculos/marcos_paulo.pdf', NOW(), 1780000, 'PDF'),
(10, 10, 'curriculo_juliana.pdf', '/curriculos/juliana_mendes.pdf', NOW(), 1350000, 'PDF');

-- Inserir formações (depende de candidatos, niveis_escolaridade, status_formacao)
INSERT INTO formacoes (candidato_id, instituicao, curso, nivel, situacao, data_inicio, data_conclusao) VALUES
(1, 'USP', 'Ciência da Computação', 4, 1, '2010-02-01', '2014-12-15'),
(2, 'FGV', 'Administração de Empresas', 5, 1, '2008-03-01', '2012-12-20'),
(3, 'PUC', 'Ciências Contábeis', 4, 1, '2009-02-01', '2013-12-10'),
(4, 'ESPM', 'Publicidade e Propaganda', 4, 1, '2011-02-01', '2015-12-18'),
(5, 'Mackenzie', 'Marketing', 4, 1, '2007-02-01', '2011-12-15'),
(6, 'SENAC', 'Desenvolvimento de Sistemas', 3, 2, '2022-02-01', NULL),
(7, 'Unip', 'Gestão de RH', 3, 2, '2023-02-01', NULL),
(8, 'Unicamp', 'Análise de Sistemas', 4, 1, '2012-02-01', '2016-12-10'),
(9, 'USP', 'Marketing', 5, 1, '2010-02-01', '2014-12-15'),
(10, 'FGV', 'Gestão Comercial', 4, 1, '2009-02-01', '2013-12-20');

-- Inserir experiências (depende de candidatos)
INSERT INTO experiencias (candidato_id, empresa, cargo, descricao, data_inicio, data_fim, empregador_atual, trabalho_remoto, finalizada) VALUES
(1, 'Google', 'Desenvolvedor Júnior', 'Desenvolvimento de aplicações web', '2015-01-10', '2018-03-15', FALSE, TRUE, TRUE),
(1, 'Microsoft', 'Desenvolvedor Pleno', 'Desenvolvimento full stack', '2018-04-01', '2022-12-31', FALSE, TRUE, TRUE),
(2, 'Ambev', 'Analista de RH', 'Recrutamento e seleção', '2013-02-01', '2018-05-30', FALSE, FALSE, TRUE),
(2, 'Itaú', 'Coordenadora de RH', 'Gestão de equipe de RH', '2018-06-15', NULL, TRUE, FALSE, FALSE),
(3, 'Deloitte', 'Analista Financeiro', 'Análise de demonstrações financeiras', '2014-03-01', '2019-08-31', FALSE, FALSE, TRUE),
(3, 'PwC', 'Analista Financeiro Sênior', 'Consultoria financeira', '2019-09-15', NULL, TRUE, TRUE, FALSE),
(4, 'Wunderman Thompson', 'Analista de Marketing', 'Marketing digital e redes sociais', '2016-01-10', '2020-12-20', FALSE, TRUE, TRUE),
(4, 'DPZ', 'Coordenadora de Marketing', 'Gestão de campanhas', '2021-01-15', NULL, TRUE, FALSE, FALSE),
(5, 'Oracle', 'Executivo de Vendas', 'Vendas de soluções corporativas', '2012-02-01', '2018-06-30', FALSE, TRUE, TRUE),
(5, 'Salesforce', 'Gerente de Vendas', 'Gestão de equipe de vendas', '2018-07-15', NULL, TRUE, TRUE, FALSE),
(6, 'Tech Startup', 'Estagiário de TI', 'Suporte e desenvolvimento', '2023-06-01', NULL, TRUE, TRUE, FALSE),
(7, 'Consultoria RH', 'Assistente de RH', 'Auxílio em processos de RH', '2024-01-15', NULL, TRUE, FALSE, FALSE),
(8, 'IBM', 'Analista de Sistemas', 'Desenvolvimento de sistemas', '2017-03-01', '2022-05-31', FALSE, TRUE, TRUE),
(8, 'Accenture', 'Analista de Sistemas Sênior', 'Arquitetura de soluções', '2022-06-15', NULL, TRUE, TRUE, FALSE),
(9, 'Natura', 'Coordenadora de Marketing', 'Gestão de marca', '2015-04-01', '2020-07-31', FALSE, FALSE, TRUE),
(9, 'Unilever', 'Gerente de Marketing', 'Estratégias de marketing', '2020-08-15', NULL, TRUE, FALSE, FALSE),
(10, 'B2W', 'Gerente de Vendas', 'Gestão de equipe comercial', '2014-02-01', '2019-11-30', FALSE, FALSE, TRUE),
(10, 'Amazon', 'Diretor de Vendas', 'Estratégias de vendas B2B', '2019-12-15', NULL, TRUE, TRUE, FALSE);

-- =====================================================
-- 9. TABELAS QUE DEPENDEM DE EMPRESAS E OUTRAS
-- =====================================================

-- Inserir vagas (depende de empresas, tipos_vaga, modalidades, niveis_escolaridade, status_vaga, cidades)
INSERT INTO vagas (empresa_id, titulo, descricao, requisito, tipo_vaga_id, modalidade_vaga_id, salario_min, salario_max, beneficios, carga_horaria, idade_minima, idade_maxima, nivel_escolaridade_minimo_id, area_atuacao, data_expiracao, status_vaga_id, numero_vagas, cidade_id) VALUES
(1, 'Desenvolvedor Full Stack', 'Desenvolvimento de aplicações web com React e Node.js', 'Experiência com JavaScript, React, Node.js', 1, 2, 8000.00, 12000.00, 'VR, VA, Plano de saúde', '40h semanais', 22, 45, 4, 'Tecnologia', DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 3, 1),
(1, 'Analista de Suporte Técnico', 'Suporte a usuários e infraestrutura', 'Conhecimentos em Windows e redes', 1, 1, 3000.00, 4500.00, 'VR, VT', '40h semanais', 18, 40, 2, 'Tecnologia', DATE_ADD(NOW(), INTERVAL 15 DAY), 1, 2, 1),
(2, 'Vendedor', 'Atendimento ao cliente e vendas', 'Experiência com vendas', 1, 1, 1500.00, 2500.00, 'Comissão', '44h semanais', 18, 35, 1, 'Comercial', DATE_ADD(NOW(), INTERVAL 20 DAY), 1, 5, 2),
(3, 'Analista Financeiro', 'Análise de investimentos e relatórios', 'Formação em Administração ou Contábeis', 1, 3, 5000.00, 7000.00, 'Plano de saúde, Previdência privada', '40h semanais', 25, 50, 4, 'Financeiro', DATE_ADD(NOW(), INTERVAL 45 DAY), 1, 2, 3),
(4, 'Enfermeiro', 'Atendimento em clínica médica', 'COREN ativo, experiência em clínica', 1, 1, 4000.00, 5500.00, 'Plano de saúde, Vale alimentação', '36h semanais', 22, 55, 4, 'Saúde', DATE_ADD(NOW(), INTERVAL 25 DAY), 1, 3, 4),
(5, 'Professor de Matemática', 'Aulas para ensino fundamental e médio', 'Licenciatura em Matemática', 1, 1, 2500.00, 3500.00, 'Plano de saúde', '30h semanais', 22, 60, 4, 'Educação', DATE_ADD(NOW(), INTERVAL 60 DAY), 1, 2, 5),
(1, 'Estagiário de TI', 'Auxílio em desenvolvimento e suporte', 'Cursando TI ou áreas correlatas', 3, 2, 1200.00, 1800.00, 'VT, VR', '30h semanais', 18, 25, 3, 'Tecnologia', DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 4, 11),
(3, 'Gerente de Contas PJ', 'Gestão de carteira de clientes empresariais', 'Experiência com banking', 1, 3, 8000.00, 15000.00, 'Participação nos lucros', '40h semanais', 30, 55, 5, 'Financeiro', DATE_ADD(NOW(), INTERVAL 40 DAY), 1, 1, 3),
(4, 'Médico Clínico Geral', 'Atendimento ambulatorial', 'CRM ativo', 2, 1, 10000.00, 15000.00, 'Plantão', '20h semanais', 28, 65, 6, 'Saúde', DATE_ADD(NOW(), INTERVAL 15 DAY), 1, 2, 4),
(2, 'Analista de Marketing', 'Gestão de redes sociais e campanhas', 'Experiência com marketing digital', 1, 2, 3500.00, 5000.00, 'VR, VT', '40h semanais', 22, 40, 4, 'Marketing', DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 1, 12),
(6, 'Consultor de RH', 'Recrutamento e seleção para clientes', 'Experiência em RH', 2, 3, 4500.00, 6000.00, 'Comissão', '40h semanais', 25, 50, 4, 'Recursos Humanos', DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 2, 6),
(7, 'Engenheiro Civil', 'Gerenciamento de obras', 'CREA ativo', 1, 1, 8000.00, 12000.00, 'VT, VR', '44h semanais', 25, 55, 4, 'Engenharia', DATE_ADD(NOW(), INTERVAL 60 DAY), 1, 2, 7),
(8, 'Advogado Trabalhista', 'Atuação em direito trabalhista', 'OAB ativa', 2, 3, 5000.00, 8000.00, 'Plano de saúde', '40h semanais', 25, 60, 5, 'Jurídico', DATE_ADD(NOW(), INTERVAL 45 DAY), 1, 1, 8),
(9, 'Social Media', 'Gestão de redes sociais', 'Experiência com criação de conteúdo', 1, 2, 2500.00, 3500.00, 'VR, VT', '40h semanais', 20, 35, 3, 'Marketing', DATE_ADD(NOW(), INTERVAL 20 DAY), 1, 2, 9),
(10, 'Motorista de Caminhão', 'Entregas regionais', 'CNH E', 1, 1, 3000.00, 4500.00, 'VT, VR', '44h semanais', 25, 50, 2, 'Logística', DATE_ADD(NOW(), INTERVAL 15 DAY), 1, 3, 10);

-- =====================================================
-- 10. TABELAS QUE DEPENDEM DE CANDIDATOS E VAGAS
-- =====================================================

-- Inserir candidaturas (depende de candidatos, vagas e status_candidatura)
INSERT INTO candidaturas (id, candidato_id, vaga_id, data_candidatura, data_atualizacao, status_id) VALUES
(1, 1, 1, NOW(), NOW(), 1),
(2, 1, 2, NOW(), NOW(), 2),
(3, 2, 3, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 2),
(4, 3, 4, DATE_SUB(NOW(), INTERVAL 3 DAY), NOW(), 3),
(5, 4, 9, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 4),
(6, 5, 5, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), 1),
(7, 6, 7, NOW(), NOW(), 1),
(8, 7, 2, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), 2),
(9, 2, 8, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), 1),
(11, 8, 11, NOW(), NOW(), 1),
(12, 9, 14, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), 1),
(13, 10, 15, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 2),
(14, 1, 7, NOW(), NOW(), 1),
(15, 4, 10, DATE_SUB(NOW(), INTERVAL 5 DAY), NOW(), 3);