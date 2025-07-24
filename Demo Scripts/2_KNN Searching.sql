/*-----------------------------------------------------------------------------
-- 2_KNN Searching.sql
--
-- Written By: Andy Yun
-- Created On: 2025-07-22
-- 
-- Summary: 
-- Fun with KNN search
-----------------------------------------------------------------------------*/
USE RecipesDemoDB
GO




-----
-- KNN Search example against vectors.recipe_description
DECLARE 
	@query_vector VECTOR(768),
	@my_query NVARCHAR(4000) = 
		N'Find all asian inspired chicken noodle recipes that are gluten-free';


SELECT @query_vector = AI_GENERATE_EMBEDDINGS(
							@my_query USE MODEL ollama_nomic_embed_text
						);

-----
-- Need DISTINCT because some vectors.* tables have multiple entries per
-- recipe_id, due to chunking.  Without that, dupes will present.
SELECT TOP 10 
	recipes.recipe_id, 
	recipes.name, 
	recipes.description, 
	VECTOR_DISTANCE('cosine', recipe_description.embedding, @query_vector) AS distance,
	@query_vector AS query_vector,
	recipe_description.embedding,
	chunk_id
FROM dbo.recipes
INNER JOIN vectors.recipe_description
	ON recipes.recipe_id = recipe_description.recipe_id
ORDER BY 
	distance ASC;
GO








-----
-- What's this up to?
-- Ctrl-L to get Est Execution Plan








-----
-- What if I need to search multiple data points?
--
-- LEAST()
-- KNN Search example against multiple vectors.* tables
-- Source: https://devblogs.microsoft.com/azure-sql/efficiently-and-elegantly-modeling-embeddings-in-azure-sql-and-sql-server/

DECLARE 
	@query_vector VECTOR(768),
	@my_query NVARCHAR(4000) = 
		N'Find all asian inspired chicken noodle recipes that are gluten-free';

SELECT @query_vector = AI_GENERATE_EMBEDDINGS(
							@my_query USE MODEL ollama_nomic_embed_text
						);


SELECT DISTINCT TOP 10 
	recipes.recipe_id, recipes.name, recipes.description, recipes.ingredients, recipes.tags, 
	recipes.ingredients_raw, recipes.steps, recipes.servings, recipes.serving_size,

	-----
	-- Use LEAST() when multiple embedding tables are in play
	LEAST(
		VECTOR_DISTANCE('cosine', recipe_description.embedding, @query_vector),
		VECTOR_DISTANCE('cosine', recipe_ingredients.embedding, @query_vector),
		VECTOR_DISTANCE('cosine', recipe_other_cols.embedding, @query_vector),
		VECTOR_DISTANCE('cosine', recipe_tags.embedding, @query_vector)
	) AS distance,

	'KNN-_description_ingredients_other_cols_tags' AS search_source
FROM dbo.recipes
INNER JOIN vectors.recipe_description
	ON recipes.recipe_id = recipe_description.recipe_id
INNER JOIN vectors.recipe_ingredients
	ON recipes.recipe_id = recipe_ingredients.recipe_id
INNER JOIN vectors.recipe_other_cols
	ON recipes.recipe_id = recipe_other_cols.recipe_id
INNER JOIN vectors.recipe_tags
	ON recipes.recipe_id = recipe_tags.recipe_id
ORDER BY 
	distance ASC
GO

-- Reminder: DO NOT run this
-- Look at estimated exec plan - Ctrl-L
-----








-----
-- KNN search can be expensive.
-- 2a_KNN Searching.sql should be pre-executed
-- Review that now