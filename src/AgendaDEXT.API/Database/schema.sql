-- Script de Inicialização da Base de Dados — AgendaDEXT (SQL Server)
-- Transação de criação da tabela e índices de otimização

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AgendaBDMG')
BEGIN
    CREATE DATABASE AgendaBDMG;
END
GO

USE AgendaBDMG;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tarefas')
BEGIN
    CREATE TABLE Tarefas (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Titulo VARCHAR(150) NOT NULL,
        Descricao VARCHAR(1000) NULL,
        Prioridade INT NOT NULL CHECK (Prioridade BETWEEN 1 AND 5),
        Status VARCHAR(30) NOT NULL CHECK (Status IN ('PENDENTE', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')),
        DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
        DataConclusao DATETIME NULL,
        DataExclusao DATETIME NULL
    );

    -- Criação de Índices Otimizados Filtrados (Filtered Indexes) para consultas concorrentes e métricas
    -- 1. Índice em Status (Considerando apenas tarefas ativas)
    CREATE NONCLUSTERED INDEX IX_Tarefas_Status 
    ON Tarefas (Status) 
    WHERE DataExclusao IS NULL;

    -- 2. Índice de exclusão lógica (Soft Delete)
    CREATE NONCLUSTERED INDEX IX_Tarefas_DataExclusao 
    ON Tarefas (DataExclusao);

    -- 3. Índice em DataConclusao focado nas métricas de tarefas concluídas nos últimos 7 dias
    CREATE NONCLUSTERED INDEX IX_Tarefas_DataConclusao 
    ON Tarefas (DataConclusao) 
    WHERE Status = 'CONCLUIDA';

    -- 4. Índice de Prioridade focado na média de tarefas ativas
    CREATE NONCLUSTERED INDEX IX_Tarefas_Prioridade 
    ON Tarefas (Prioridade) 
    WHERE DataExclusao IS NULL;
END
GO
