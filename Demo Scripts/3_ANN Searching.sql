/*-----------------------------------------------------------------------------
-- 3_ANN Searching.sql
--
-- Written By: Andy Yun
-- Created On: 2025-07-22
-- 
-- Summary: 
-- Fun with ANN Search
-----------------------------------------------------------------------------*/
USE RecipesDemoDB
GO




-----
-- ANN Search example against vectors.recipe_description
DECLARE 
	@query_vector VECTOR(768),
	@my_query NVARCHAR(4000) = 
		N'Find all asian inspired chicken noodle recipes that are gluten-free';


SELECT @query_vector = AI_GENERATE_EMBEDDINGS(
							@my_query USE MODEL ollama_nomic_embed_text
						);


SELECT TOP 10 
	recipes.recipe_id, 
	recipes.name, 
	recipes.description, 	
	v_search.distance,
	recipe_description.embedding
FROM 
	vector_search (
		TABLE = vectors.recipe_description,
		COLUMN = embedding,
		similar_to = @query_vector,
		metric = 'cosine',
		top_n = 10
	) AS v_search
INNER JOIN dbo.recipes
	ON recipe_description.recipe_id = recipes.recipe_id
ORDER BY v_search.distance ASC;
GO








-----
-- Queries from the audience?
-- Give me three prompts - nothing inappropriate please :-)
--

-----
-- While we wait, show z_sp_search_recipes_ann.sql
-- Highlight code for ANN searching multiple tables 


EXEC dbo.sp_search_recipes_ann '';
GO


EXEC dbo.sp_search_recipes_ann '';
GO


EXEC dbo.sp_search_recipes_ann '';
GO








-----
-- One more example
EXEC dbo.sp_search_recipes_ann 
N'Give me chicken recipes that use chicken thighs, 
not chicken breasts.  
Also exclude recipes that contain garlic and onions.
Nothing spicy either';
GO








-----
-- Another variant
EXEC dbo.sp_search_recipes_ann 
N'Give me recipes that have chicken thighs and 
does NOT contain celery AND carrots';
GO








----
-- Why is this?
-- 
-- A vector embedding is a value based on semantics...
-- taking keywords and knowing what other words are 
-- semantically similar.
--
-- But unlike an LLM, doesn't understand the context
-- when a logic statement or negative value is present.
--
-- NOT, does not include, OR sequences... 
