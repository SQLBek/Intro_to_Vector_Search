/*-----------------------------------------------------------------------------
-- 1_Quick Tour.sql
--
-- Written By: Andy Yun
-- Created On: 2025-07-22
-- 
-- Summary: 
-- Introduce RecipesDemoDB
-----------------------------------------------------------------------------*/
USE RecipesDemoDB
GO




-----
-- dbo.recipes
-- Data source: 
-- https://www.kaggle.com/datasets/realalexanderwei/food-com-recipes-with-ingredients-and-tags
--
SELECT COUNT(1)
FROM dbo.recipes;
GO

SELECT TOP 10 *
FROM dbo.recipes;
GO

EXEC sp_help 'dbo.recipes';
GO








-----
-- List all vector embedding tables
SELECT schemas.name + '.' + objects.name
FROM sys.objects
INNER JOIN sys.schemas
	ON objects.schema_id = schemas.schema_id
WHERE objects.type = 'U'
	AND schemas.name = 'vectors'
ORDER BY 1;
GO








-----
-- dbo.recipes
SELECT TOP 10 *
FROM vectors.recipe_description;
GO

EXEC sp_help 'vectors.recipe_description';
GO








-----
-- Explain AI_GENERATE_EMBEDDINGS() & AI_GENERATE_CHUNKS()
SELECT TOP 100
    recipes.recipe_id,
    chunks.chunk_order,
    recipes.description,
    chunks.chunk,
    chunks.chunk_offset,
    chunks.chunk_length, 
    AI_GENERATE_EMBEDDINGS(
            chunks.chunk USE MODEL ollama_nomic_embed_text
        ) AS embedding
FROM dbo.recipes
CROSS APPLY AI_GENERATE_CHUNKS(
        source = recipes.description, 
        chunk_type = FIXED, 
        chunk_size = 200,
        overlap = 10
    ) AS chunks
ORDER BY 
    recipes.recipe_id, chunks.chunk_order
GO








-----
-- What's ollama_nomic_embed_text?
SELECT *
FROM sys.external_models;
GO


-----
-- Practical AI in SQL Server 2025: Ollama Quick Start: 
-- https://sqlbek.wordpress.com/2025/05/19/ollama-quick-start/








--------------------------------------------------
-- Generate concatenated JSON for all shorter
-- valued columns
--------------------------------------------------
SELECT 
	recipe_id,
	(
		SELECT 
			name, 
			servings, 
			serving_size
		FOR JSON PATH
	) AS recipe_json
INTO #tmp_recipe_other_cols
FROM dbo.recipes;

SELECT TOP 500
    recipes.recipe_id,
    chunk,
    chunk_order,
    chunk_offset,
    chunk_length, 
    AI_GENERATE_EMBEDDINGS(
            chunks.chunk USE MODEL ollama_nomic_embed_text
        ) AS embedding
FROM #tmp_recipe_other_cols AS recipes
CROSS APPLY AI_GENERATE_CHUNKS(
        source = recipes.recipe_json, 
        chunk_type = FIXED, 
        chunk_size = 200,
        overlap = 10
    ) AS chunks
GO 
