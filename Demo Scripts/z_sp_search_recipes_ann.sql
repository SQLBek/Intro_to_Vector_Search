USE [RecipesDemoDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_search_recipes_ann]    Script Date: 7/23/2025 7:57:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SET STATISTICS IO ON
SET STATISTICS TIME ON

EXEC dbo.sp_search_recipes_ann N'Find all cajun chicken noodle recipes';

*/
CREATE OR ALTER PROCEDURE [dbo].[sp_search_recipes_ann] (
	@my_query NVARCHAR(4000) = N'Find all asian inspired chicken noodle recipes that are gluten-free',
	@debug BIT = 0
)
AS
BEGIN
	DECLARE @query_vector VECTOR(768);

	-----
	-- This stored procedure with execute an ANN search against
	-- vector embeddings in the following tables:
	--
	-- vectors.recipe_description
	-- vectors.recipe_ingredients
	-- vectors.recipe_other_cols
	-- vectors.recipe_tags

	-----
	-- Check dbo.prior_search_query_vectors to see if @my_query has been used 
	-- before and if we can re-use the vector embedding
	SELECT @query_vector = my_vector
	FROM dbo.prior_search_query_vectors
	WHERE my_query = @my_query;


	IF @query_vector IS NULL
	BEGIN
		-- This is a new query, generate a new embedding then save it
		SELECT @query_vector = AI_GENERATE_EMBEDDINGS(
				 @my_query USE MODEL ollama_nomic_embed_text
			);

		INSERT INTO dbo.prior_search_query_vectors (my_query, my_vector)
		SELECT @my_query, @query_vector
		WHERE NOT EXISTS (
			-- technically this double-check is not necessary 
			-- but I'm keeping it here just because
			SELECT 1
			FROM dbo.prior_search_query_vectors
			WHERE my_query = @my_query
		);
	END;

	
	WITH cte_vector_search AS (
		-- vectors.recipe_description
		SELECT v_search.distance, recipe_description.recipe_id, 'recipe_description' AS source_vector
		FROM 
		vector_search (
			TABLE = vectors.recipe_description,
			COLUMN = embedding,
			similar_to = @query_vector,
			metric = 'cosine',
			top_n = 10
		) AS v_search
		UNION ALL
		-- vectors.recipe_ingredients
		SELECT v_search.distance, recipe_ingredients.recipe_id, 'recipe_ingredients' AS source_vector
		FROM vector_search (
			TABLE = vectors.recipe_ingredients,
			COLUMN = embedding,
			similar_to = @query_vector,
			metric = 'cosine',
			top_n = 10
		) AS v_search
		UNION ALL
		-- vectors.recipe_other_cols
		SELECT v_search.distance, recipe_other_cols.recipe_id, 'recipe_other_cols' AS source_vector
		FROM vector_search (
			TABLE = vectors.recipe_other_cols,
			COLUMN = embedding,
			similar_to = @query_vector,
			metric = 'cosine',
			top_n = 10
		) AS v_search
		UNION ALL
		-- vectors.recipe_tags
		SELECT v_search.distance, recipe_tags.recipe_id, 'recipe_tags' AS source_vector
		FROM vector_search (
			TABLE = vectors.recipe_tags,
			COLUMN = embedding,
			similar_to = @query_vector,
			metric = 'cosine',
			top_n = 10
		) AS v_search
	)
	SELECT TOP 10 
		recipes.recipe_id, recipes.name, recipes.description, recipes.ingredients, recipes.tags, 
		recipes.ingredients_raw, recipes.steps, recipes.servings, recipes.serving_size,
		cte_vector_search.distance, 
		cte_vector_search.source_vector,
		'ANN-_description_ingredients_other_cols_tags' AS search_type
	FROM cte_vector_search
	INNER JOIN dbo.recipes
		ON cte_vector_search.recipe_id = recipes.recipe_id
	ORDER BY cte_vector_search.distance ASC;

END