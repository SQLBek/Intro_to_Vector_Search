/*-----------------------------------------------------------------------------
-- 4_End to End Searching.sql
--
-- Written By: Andy Yun
-- Created On: 2025-07-22
-- 
-- Summary: 
-- Fun with ANN Search
-----------------------------------------------------------------------------*/
USE RecipesDemoDB
GO




EXEC dbo.sp_search_recipes 'Have any good french fry recipes?';
GO




-----
-- If time allows
-- Review dbo.sp_search_recipes code
--
-- Else pseudocode
-- 
-- 1.  Execute sp_search_recipes_ann for vector search.
--
-- 2.  Save relevant output as JSON. Using recipe name, 
--     description, & tags in this example.
--
-- 3.  Construct JSON payload to pass to Ollama LLM. Will
--     include output from prior, plus custom prompt, plus
--     user query.  
--
--     Prompt: You are a helpful cooking assistant that summarizes 
--             recipe search results based user queries from a recipes 
--             database. Provide a summary of resulting recipes based 
--             on the user query
--
-- 4.  Using sp_invoke_external_rest_endpoint, pass JSON payload
--     to Ollama.  
-- 
-- 5.  Extract human friendly response from JSON output and print.


-- Execute with @debug to see JSON 
EXEC dbo.sp_search_recipes 'Have any french fry recipes?', @debug = 1;
GO
